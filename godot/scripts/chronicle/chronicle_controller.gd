extends RefCounted
## Act / round / AO progression (§7).
##
## Chronicle I is 3 Acts x 3 rounds, 2 Action Opportunities per player per
## round, a Drift at the end of every round and at most one Confluence opened
## per round. Every one of those numbers comes from the Chronicle data, not from
## here.
##
## The controller never decides anything itself: it asks a `decider` object.
## The CLI harness supplies a scripted decider; the 0.1 hotseat UI will supply
## an interactive one. That is what makes the same rules playable headless.

const Effect := preload("res://scripts/core/effect.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")

signal phase_changed(act: int, round: int, phase: String)
signal confluence_resolved(result: Dictionary)

var session: RefCounted
var world: Dictionary
var data: RefCounted
var log: RefCounted

var illegal_actions: int = 0
var confluence_results: Array = []

var _chronicle: Dictionary
var _conditions: RefCounted


func _init(p_session: RefCounted) -> void:
	session = p_session
	world = p_session.world
	data = p_session.data
	log = p_session.log
	_chronicle = data.chronicles[world["chronicle_id"]]
	_conditions = ConditionEvaluator.new(world, data)


## Play the whole Chronicle. Returns a run report.
func run(decider: Object) -> Dictionary:
	setup()
	for act in range(1, int(_chronicle["acts"]) + 1):
		play_act(act, decider)
	return chronicle_end()


func setup() -> void:
	_set_phase(0, 0, "SETUP")
	log.section("CHRONICLE %s - %s" % [str(_chronicle["id"]), str(_chronicle["title"])])
	log.line(str(_chronicle["opening_text"]))
	log.line("")
	for effect in session.factory_setup_effects():
		session.applier.apply(effect)
	var inherited: Array = session.inheritance_effects()
	if not inherited.is_empty():
		log.section("EREDITA DELLA CHRONICLE PRECEDENTE")
		for effect in inherited:
			session.applier.apply(effect)
		for scar in world["scars"]:
			log.bullet(str(scar["description"]))
	log.section("SITUAZIONE INIZIALE")
	for entity_id in world["turn_order"]:
		log.bullet(
			"%s - mano: %d, presenza: %s"
			% [
				_name(str(entity_id)),
				session.service.hand_size(str(entity_id)),
				", ".join(PackedStringArray(session.service.regions_with_presence(str(entity_id)))),
			]
		)
	for tension_id in world["tensions"]:
		log.bullet(session.tensions.public_status(str(tension_id)))


func play_act(act: int, decider: Object) -> void:
	log.section("ATTO %d" % act)
	for round_number in range(1, int(_chronicle["rounds_per_act"]) + 1):
		play_round(act, round_number, decider)
	end_of_act(act, decider)


func play_round(act: int, round_number: int, decider: Object) -> void:
	_set_phase(act, round_number, "ACTIONS")
	# The INFLUENCE allowance is per round and does not carry over (D-021).
	world["influence_used"] = {}
	world["influence_used_by_tension"] = {}
	log.section("Atto %d - Round %d" % [act, round_number])

	var opportunities: int = int(_chronicle["action_opportunities_per_round"])
	for entity_id in session.service.active_entities():
		world["entities"][entity_id]["ao_remaining"] = opportunities
		for ao_index in range(opportunities):
			var request: Variant = decider.choose_action(str(entity_id), ao_index, session)
			if request == null:
				request = {"template": "PASS", "params": {}}
			var outcome: Dictionary = session.actions.execute(str(entity_id), request)
			if not outcome["ok"]:
				illegal_actions += 1
				log.bullet(
					"AZIONE RIFIUTATA - %s %s: %s"
					% [_name(str(entity_id)), str(request.get("template", "?")), str(outcome["error"])]
				)
			# AO are spent whether or not the attempt succeeded; they do not
			# carry over between rounds (§7).
			world["entities"][entity_id]["ao_remaining"] = opportunities - ao_index - 1

	_set_phase(act, round_number, "DRIFT")
	session.tensions.apply_drift()
	_apply_overextension(act, round_number)

	_set_phase(act, round_number, "THRESHOLD_CHECK")
	_end_of_round_confluence(decider)

	for tension_id in world["tensions"]:
		log.bullet(session.tensions.public_status(str(tension_id)))


## D-027: holding is not free. Every Region an Entity controls beyond
## `max_stable_control` raises the Tension of that Region's own domain, once per
## round - the empire generates its own crises rather than being punished for
## existing. Nothing here targets a player: it targets the situation, and it
## reads at the table as "you hold the road as well? then the road question is
## yours to answer".
##
## Deterministic: Regions are taken in the Chronicle's own order, so the same
## board always strains in the same place.
func _apply_overextension(act: int, round_number: int) -> void:
	var rules: Dictionary = _chronicle.get("control_rules", {})
	if not rules.has("max_stable_control"):
		return
	var limit: int = int(rules["max_stable_control"])
	var delta: int = int(rules.get("overextension_delta", 1))
	if delta <= 0:
		return

	for entity_id in world["turn_order"]:
		var held: Array = []
		for region_id in _chronicle["regions"]:
			var control: Variant = world["regions"][str(region_id)].get("control", null)
			if control != null and str(control) == str(entity_id):
				held.append(str(region_id))
		if held.size() <= limit:
			continue

		for index in range(limit, held.size()):
			var tension_id: String = _tension_for_region(held[index])
			if tension_id == "":
				continue
			var source: Dictionary = Effect.source(
				"system", "OVEREXTENSION", str(entity_id), act, round_number,
				int(world["effect_sequence"])
			)
			session.applier.apply(
				Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": delta}, source)
			)
			log.bullet(
				"%s tiene piu di quanto puo reggere: %s sale di %d."
				% [_name(str(entity_id)), str(data.tensions[tension_id]["title"]), delta]
			)


## The Tension whose domain this Region belongs to. A Region may sit in more than
## one domain; the Chronicle's Tension order decides, so the result is stable.
func _tension_for_region(region_id: String) -> String:
	for tension_id in world["tensions"]:
		var domain: String = str(data.tensions[str(tension_id)]["domain"])
		if session.service.region_has_tag(region_id, "domain:%s" % domain):
			return str(tension_id)
	return ""


## §7 and §12.1: a forced Claim takes precedence over threshold triggers, and
## only one Confluence opens per round. Anything else at threshold queues up.
func _end_of_round_confluence(decider: Object) -> void:
	var ready: Array = session.tensions.tensions_at_threshold()
	var forced: Variant = world.get("forced_confluence", null)
	var tension_id: String = ""
	var trigger: Dictionary = {}

	if forced != null:
		tension_id = str(forced["tension_id"])
		trigger = {"kind": "CLAIM", "entity_id": str(forced["entity_id"])}
	elif not ready.is_empty():
		tension_id = str(ready[0])
		trigger = {"kind": "THRESHOLD", "entity_id": ""}

	world["confluence_queue"] = ready.filter(
		func(id: Variant) -> bool: return str(id) != tension_id
	)
	if tension_id == "":
		return
	if not world["confluence_queue"].is_empty():
		log.bullet(
			"In coda per i round successivi: %s"
			% ", ".join(PackedStringArray(world["confluence_queue"]))
		)
	_set_phase(int(world["act"]), int(world["round"]), "CONFLUENCE")
	run_confluence(tension_id, trigger, decider)


## Drive one Confluence through A-K with the decider answering C, D, E.
func run_confluence(tension_id: String, trigger: Dictionary, decider: Object) -> Dictionary:
	# §6.3: a snapshot before every Confluence is what makes undo possible past
	# the irreversible CREATE_ECHO / APPEND_TRUTH that may follow.
	session.take_snapshot("pre-confluence")

	var controller: RefCounted = session.confluence
	var context: Dictionary = controller.open(tension_id, trigger)
	if context.is_empty():
		log.bullet("Confluence non aperta: %s" % controller.last_error)
		return {}

	var questions: Array = controller.available_questions()
	if questions.size() > 1:
		var question_id: String = str(decider.choose_question(context, questions, session))
		if question_id != "" and question_id != str(context["question_id"]):
			if not controller.set_question(question_id):
				log.bullet("Domanda non valida (%s): si mantiene quella di default." % controller.last_error)
				illegal_actions += 1

	var options: Array = controller.available_propositions()
	if options.is_empty():
		log.bullet("Confluence senza proposte disponibili: annullata.")
		controller.current = {}
		return {}
	var proposition_id: String = str(decider.choose_proposition(context, options, session))
	if not controller.set_proposition(proposition_id):
		# A scripted plan that names an unavailable proposition must not stall
		# the Chronicle: fall back to the first legal option and say so.
		log.bullet("Proposta non valida (%s): si ripiega sulla prima disponibile." % controller.last_error)
		illegal_actions += 1
		controller.set_proposition(str(options[0]["id"]))

	for entity_id in controller.stance_order():
		var declaration: Dictionary = decider.choose_stance(str(entity_id), context, session)
		if not controller.declare_stance(
			str(entity_id), str(declaration.get("stance", "ABSTAIN")), str(declaration.get("clause_id", ""))
		):
			log.bullet("Posizione rifiutata (%s): %s si astiene." % [controller.last_error, _name(str(entity_id))])
			illegal_actions += 1
			controller.declare_stance(str(entity_id), "ABSTAIN")

	for entity_id in world["turn_order"]:
		var limit: int = controller.max_commit_for(str(entity_id))
		if limit <= 0:
			continue
		var committed: Array = decider.choose_commit(str(entity_id), context, limit, session)
		if not controller.commit(str(entity_id), committed):
			log.bullet("Impegno rifiutato (%s): %s impegna 0 Asset." % [controller.last_error, _name(str(entity_id))])
			illegal_actions += 1
			controller.commit(str(entity_id), [])

	var recovery: Dictionary = decider.choose_recovery(context, session)
	var result: Dictionary = controller.resolve(recovery)
	if not result.is_empty():
		confluence_results.append(result)
		confluence_resolved.emit(result)
	return result


## §7: at the end of an Act one Echo card is drawn from that Act's pool (§15).
func end_of_act(act: int, decider: Object) -> void:
	_set_phase(act, int(_chronicle["rounds_per_act"]), "ACT_ECHO")
	var card: Dictionary = _draw_act_echo(act)
	if card.is_empty():
		log.bullet("Nessuna carta Echo disponibile per l'Atto %d." % act)
		return
	log.section("CARTA ECHO DI ATTO - %s (%s)" % [str(card["title"]), str(card["dramatic_family"])])
	log.line(str(card["description"]))

	var source: Dictionary = Effect.source(
		"echo_card", str(card["id"]), "", act, int(world["round"]), int(world["effect_sequence"])
	)
	# §15: the narrative function this card just performed becomes a fact about
	# the world, so a later card can require it. Propp's whole point is that the
	# functions come in an order - a Return needs a Separation to return from -
	# and this is what lets a card say so in its own eligibility, without the
	# engine knowing a single function name (D-030).
	session.applier.apply(
		Effect.make(
			"SET_GLOBAL_TAG",
			"world",
			"WORLD",
			{"tag": "function:%s" % str(card["function_id"])},
			source
		)
	)
	for hook in card["effect_hooks"]:
		var bindings: Dictionary = card_bindings(hook)
		if str(hook["kind"]) == "CONSEQUENCE":
			for effect in session.compiler.compile(
				str(hook["consequence_id"]), bindings, source
			):
				session.applier.apply(effect)
		else:
			session.applier.apply(
				session.compiler.compile_spec(hook["effect"], bindings, source)
			)
	session.tensions.fire_omens(source)

	# §12.1 b: a card may prescribe a Confluence. It opens now, at Act end - it
	# is the card's demand, not a round threshold, so the one-per-round cap in
	# §7 does not apply to it (DECISIONS D-007).
	var forced: Variant = card.get("forces_confluence_on", null)
	if forced != null and world["tensions"].has(str(forced)):
		log.bullet("La carta prescrive una Confluence su %s." % str(forced))
		run_confluence(str(forced), {"kind": "ECHO_CARD", "entity_id": ""}, decider)


## An Echo card has no Confluence behind it, so `$region_focus` has nothing to
## resolve against unless the card says which question it is about. `bindings`
## may name a `focus_tension`; without one the Chronicle's first Tension is used,
## which keeps every card written before this still working.
func card_bindings(hook: Dictionary) -> Dictionary:
	var bindings: Dictionary = (hook.get("bindings", {}) as Dictionary).duplicate(true)
	var tension_id: String = str(bindings.get("focus_tension", ""))
	if tension_id == "" or not world["tensions"].has(tension_id):
		tension_id = str((world["tensions"] as Dictionary).keys()[0])
	bindings["region_focus"] = session.confluence.narrative.focus_region(tension_id)
	bindings["tension"] = tension_id
	# A card has no proponent, but the Consequences it fires were written for a
	# Confluence and expect one. Whoever would carry that question if it opened
	# now is the honest answer - and it is the same rule the Confluence uses, so
	# a card and a council name the same person in the same world.
	if not bindings.has("proponent"):
		bindings["proponent"] = session.service.determine_proponent(tension_id)
	bindings["rival"] = session.confluence.narrative.rival_id(
		str(bindings["region_focus"]), str(bindings["proponent"])
	)
	bindings["capital"] = session.confluence.narrative.capital_region()
	bindings["rival_seat"] = session.confluence.narrative.seat_of(
		str(bindings["rival"]), str(bindings["region_focus"])
	)
	return bindings


## §15: the Act's pool is a *weighted bag*, not a set. Repeating a family makes
## it likelier; the seeded RNG picks the order the families are tried in, and the
## first one with an eligible card wins. An Act 3 weighted towards RESOLUTION
## usually resolves and can still end mid-crisis, which is the three-act shape
## with room to breathe - a pool read as a strict preference produced the same
## arc in all forty measured Chronicles (D-030).
##
## Within a family the shuffled deck order decides, so the draw stays seeded.
func _draw_act_echo(act: int) -> Dictionary:
	var bag: Array = []
	for pool in _chronicle["act_echo_pools"]:
		if int(pool["act"]) == act:
			bag = (pool["families"] as Array).duplicate()
	var families: Array = []
	for family in session.rng.shuffle(bag):
		if not families.has(str(family)):
			families.append(str(family))

	var deck: Dictionary = world["echo_deck"]
	for family in families:
		for i in range((deck["draw"] as Array).size()):
			var card_id: String = str(deck["draw"][i])
			var card: Variant = data.echo_cards.get(card_id)
			if card == null or str(card["dramatic_family"]) != str(family):
				continue
			if not _conditions.all_hold(card["eligibility"], {}):
				continue
			(deck["draw"] as Array).remove_at(i)
			(deck["drawn"] as Array).append(card_id)
			return card
	return {}


func chronicle_end() -> Dictionary:
	_set_phase(int(_chronicle["acts"]), int(_chronicle["rounds_per_act"]), "CHRONICLE_END")
	log.section("FINE DELLA CHRONICLE")
	for tension_id in world["tensions"]:
		log.bullet(
			"%s: valore finale %d" % [
				str(data.tensions[tension_id]["title"]),
				session.tensions.value(str(tension_id)),
			]
		)
	log.bullet("Confluence risolte: %d" % int(world["confluence_count"]))
	log.bullet("Echo registrati: %d" % (world["echo_log"] as Array).size())
	log.bullet("Truth immutabili: %d" % (world["truth_log"] as Array).size())

	log.section("DESTINY")
	var results: Dictionary = session.destinies.evaluate_all()
	for entity_id in world["turn_order"]:
		if results.has(entity_id):
			log.bullet(session.destinies.describe(results[entity_id]))

	if not (world["truth_log"] as Array).is_empty():
		log.section("REGISTRO DELLE VERITA")
		for truth in world["truth_log"]:
			log.bullet(str(truth["text"]))

	session.destiny_results = results
	return {
		"chronicle_id": str(_chronicle["id"]),
		"confluences": confluence_results,
		"destiny_results": results,
		"illegal_actions": illegal_actions,
		"echoes": (world["echo_log"] as Array).size(),
		"truths": (world["truth_log"] as Array).size(),
	}


func _set_phase(act: int, round_number: int, phase: String) -> void:
	world["act"] = act
	world["round"] = round_number
	world["phase"] = phase
	phase_changed.emit(act, round_number, phase)


func _name(entity_id: String) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(entity["name"])
