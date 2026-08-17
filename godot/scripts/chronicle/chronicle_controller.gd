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
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")

signal phase_changed(act: int, round: int, phase: String)
signal confluence_resolved(result: Dictionary)
## The Act-end Echo card, with the Effects it applied. Emitted after they land,
## so whoever draws it can say what the card *did* and not only what it says.
## Nothing in the engine listens: it exists because three times a Chronicle the
## story turns on a card nobody at the table ever sees (D-044).
signal act_echo_drawn(card: Dictionary, applied: Array)

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
##
## A coroutine, and only because of one thing: a decider may need to *wait*.
## A CLI decider answers immediately and this never suspends - `await` on a
## synchronous call returns straight away, so the headless runs are unchanged
## down to the byte. A decider driven by a mouse cannot answer immediately, and
## without this the browser would have to freeze the whole Chronicle to ask a
## question (D-038).
func run(decider: Object) -> Dictionary:
	# A restored world is one that has already been dealt: setting it up again
	# would deal every opening hand a second time. `act` is 0 only before the
	# first round of a fresh Chronicle, which is exactly the test (D-052).
	if int(world["act"]) == 0:
		setup()
		for act in range(1, int(_chronicle["acts"]) + 1):
			await play_act(act, decider)
		return chronicle_end()

	# Where to pick up. The world carries the round it was *in*, and the phase
	# says whether that round finished: anything past ACTIONS means it did, so
	# the next one is where to stand. Getting this off by one replays a round -
	# the same actions twice, the same Drift twice - and the year comes out
	# different from the one that was never interrupted.
	var from_act: int = int(world["act"])
	var phase: String = str(world["phase"])
	var from_round: int = int(world["round"]) + (0 if phase == "ACTIONS" else 1)
	var rounds: int = int(_chronicle["rounds_per_act"])

	# Un salvataggio preso fra le azioni e il Consiglio - DRIFT o THRESHOLD_CHECK
	# - ha il round quasi finito: le azioni sono spese, ma la domanda del round
	# non e' ancora stata posta. Riprendere dal round dopo la salterebbe, e
	# rigiocare il round rifarebbe le azioni due volte. Il buco e' rimasto
	# invisibile finche' nessun Consiglio si apriva cosi' presto nell'anno: e'
	# stata la policy che forza i Consigli col Claim (D-069) a scoprirlo. Si
	# riprende esattamente da li': l'eventuale Drift dovuto, il Consiglio dovuto,
	# e poi il resto dell'anno.
	if phase == "DRIFT" or phase == "THRESHOLD_CHECK":
		log.section("SI RIPRENDE - Atto %d, round %d, alla soglia" % [from_act, int(world["round"])])
		if phase == "DRIFT":
			session.tensions.apply_drift()
			_apply_overextension(from_act, int(world["round"]))
		_set_phase(from_act, int(world["round"]), "THRESHOLD_CHECK")
		await _end_of_round_confluence(decider)
		for tension_id in world["tensions"]:
			log.bullet(session.tensions.public_status(str(tension_id)))
		if from_round > rounds:
			await end_of_act(from_act, decider)
			from_act += 1
			from_round = 1
	# And if that round is off the end of the Act, the Act's own ending has not
	# happened yet: the Echo card is drawn there, and skipping it would lose the
	# one move the world makes on its own.
	elif from_round > rounds:
		log.section("SI RIPRENDE - fine dell'Atto %d" % from_act)
		await end_of_act(from_act, decider)
		from_act += 1
		from_round = 1
	else:
		log.section("SI RIPRENDE - Atto %d, round %d" % [from_act, from_round])

	for act in range(from_act, int(_chronicle["acts"]) + 1):
		await play_act(act, decider, from_round if act == from_act else 1)
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


func play_act(act: int, decider: Object, from_round: int = 1) -> void:
	log.section("ATTO %d" % act)
	# Solo all'apertura vera dell'atto: una ripresa a meta' atto (`from_round` > 1)
	# ha gia' avuto il suo giro di stagione, e rifarlo cambierebbe la partita.
	if from_round == 1:
		_lift_evictions(act)
		_deal_narrator_hands(act)
	for round_number in range(from_round, int(_chronicle["rounds_per_act"]) + 1):
		await play_round(act, round_number, decider)
	await end_of_act(act, decider)


## La stagione gira e le porte si riaprono: i tag `evicted:` messi dai Consigli
## dell'atto precedente (D-067) si tolgono qui, con un Effect come ogni altra
## mutazione. All'Atto 1 non c'e' niente da togliere e il giro e' un no-op.
func _lift_evictions(act: int) -> void:
	for entity_id in world["turn_order"]:
		var tags: Array = (world["entities"][str(entity_id)]["tags"] as Array).duplicate()
		for tag in tags:
			if not str(tag).begins_with("evicted:"):
				continue
			var source: Dictionary = Effect.source(
				"system", "SEASON_TURNS", "", act, 1, int(world["effect_sequence"])
			)
			session.applier.apply(Effect.make(
				"REMOVE_ENTITY_TAG", "entity", str(entity_id), {"tag": str(tag)}, source
			))
			log.bullet("La stagione gira: %s puo tornare dov'era stato cacciato." % _name(str(entity_id)))


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
			var request: Variant = await decider.choose_action(str(entity_id), ao_index, session)
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
	await _end_of_round_confluence(decider)

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
	# Una Tensione a soglia con le domande esaurite non ha niente di nuovo da
	# decidere: si salta, invece di aprire un Consiglio che ridirebbe una cosa
	# gia' detta (D-077).
	var ready: Array = session.tensions.tensions_at_threshold().filter(
		func(id: Variant) -> bool: return session.confluence.has_fresh_question(str(id))
	)
	var forced: Variant = world.get("forced_confluence", null)
	var tension_id: String = ""
	var trigger: Dictionary = {}

	if forced != null:
		tension_id = str(forced["tension_id"])
		trigger = {"kind": "CLAIM", "entity_id": str(forced["entity_id"])}
	elif not ready.is_empty():
		tension_id = str(ready[0])
		trigger = {"kind": "THRESHOLD", "entity_id": ""}
	else:
		tension_id = _bring_the_year_to_a_head()
		if tension_id != "":
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
	await run_confluence(tension_id, trigger, decider)


## The floor under a Chronicle: the year does not close with nothing decided
## (D-047).
##
## A ten-Chronicle saga produced three years with **zero** Councils. The cause is
## arithmetic, not luck: the world's Drift deals one chip per round across every
## question in play - nine chips over four questions - while the smallest gap
## between a question's opening value and its threshold is three. The world can
## therefore be one chip short of *all four at once*, and in the silent years it
## was, every time. Every Council in the game needs a seat to push, and a table
## with nothing left to play for pushes nothing.
##
## That is a hole in the rules, not a quiet year: a Chronicle with no Council is
## a Chronicle in which nobody played. So when the last round arrives and the
## year is still short of the Councils the Chronicle guarantees, the question
## that came closest is brought to a head. The push is an Effect like any other,
## so the log says who did it - the world - and it inverts like everything else.
##
## The floor is checked at the close of each Act, against a quota that grows with
## the Act - `floor * act / acts`, rounded down. Only one Council opens per round
## (§7), so a floor of two checked once at the very end could only ever deliver
## one: the year has to be owed its Councils on a schedule, or the guarantee is
## not one. With three Acts and a floor of two that is nothing owed after Act I,
## one after Act II, two after Act III - which leaves the first two thirds of a
## Chronicle exactly as they were.
##
## `minimum_confluences: 0` turns the floor off; a Chronicle that wants to be
## able to end in silence is allowed to say so.
func _bring_the_year_to_a_head() -> String:
	var floor_count: int = int(_chronicle.get("minimum_confluences", 0))
	if floor_count <= 0:
		return ""
	if int(world["round"]) < int(_chronicle["rounds_per_act"]):
		return ""
	var owed: int = floor_count * int(world["act"]) / int(_chronicle["acts"])
	if int(world["confluence_count"]) >= owed:
		return ""

	# The question that came closest, ties broken by the Chronicle's own order -
	# the same rule `tensions_at_threshold` uses, so a forced Council and a
	# threshold one never disagree about which question was the loudest.
	var closest: String = ""
	var smallest_gap: int = 0
	for tension_id in world["tensions"]:
		var id: String = str(tension_id)
		# Il pavimento non forza una domanda gia' decisa: una Tensione con le
		# domande esaurite non e' una domanda aperta (D-077).
		if not session.confluence.has_fresh_question(id):
			continue
		var gap: int = session.tensions.threshold(id) - session.tensions.value(id)
		if closest == "" or gap < smallest_gap:
			closest = id
			smallest_gap = gap
	if closest == "" or smallest_gap <= 0:
		return ""

	log.bullet(
		"L'anno non si chiude con la domanda ancora aperta: %s arriva al punto."
		% str(data.tensions[closest]["title"])
	)
	var source: Dictionary = Effect.source(
		"system", "YEAR_END", "", int(world["act"]), int(world["round"]), 0
	)
	session.applier.apply(
		Effect.make("ADJUST_TENSION", "tension", closest, {"delta": smallest_gap}, source)
	)
	session.tensions.fire_omens(source)
	return closest


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
		var question_id: String = str(await decider.choose_question(context, questions, session))
		if question_id != "" and question_id != str(context["question_id"]):
			if not controller.set_question(question_id):
				log.bullet("Domanda non valida (%s): si mantiene quella di default." % controller.last_error)
				illegal_actions += 1

	var options: Array = controller.available_propositions()
	if options.is_empty():
		log.bullet("Confluence senza proposte disponibili: annullata.")
		controller.current = {}
		return {}
	var proposition_id: String = str(await decider.choose_proposition(context, options, session))
	if not controller.set_proposition(proposition_id):
		# A scripted plan that names an unavailable proposition must not stall
		# the Chronicle: fall back to the first legal option and say so.
		log.bullet("Proposta non valida (%s): si ripiega sulla prima disponibile." % controller.last_error)
		illegal_actions += 1
		controller.set_proposition(str(options[0]["id"]))

	for entity_id in controller.stance_order():
		var declaration: Dictionary = await decider.choose_stance(str(entity_id), context, session)
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
		var committed: Array = await decider.choose_commit(str(entity_id), context, limit, session)
		if not controller.commit(str(entity_id), committed):
			log.bullet("Impegno rifiutato (%s): %s impegna 0 Asset." % [controller.last_error, _name(str(entity_id))])
			illegal_actions += 1
			controller.commit(str(entity_id), [])

	var recovery: Dictionary = await decider.choose_recovery(context, session)
	var result: Dictionary = controller.resolve(recovery)
	if not result.is_empty():
		confluence_results.append(result)
		confluence_resolved.emit(result)
	return result


## ISSUES 23 (D-118): la carta di Propp non si pesca piu' da sola a fine atto —
## la cala un giocatore, nel suo turno, pagandola. Qui resta solo il sipario:
## se in tutto l'atto nessuno ha parlato, il silenzio e' una scelta del tavolo
## (decisione del committente: nessuna rete di sicurezza).
func end_of_act(act: int, _decider: Object) -> void:
	_set_phase(act, int(_chronicle["rounds_per_act"]), "ACT_ECHO")
	var played: int = int(world.get("echoes_played_in_act", 0))
	world["echoes_played_in_act"] = 0
	if played == 0:
		log.bullet("L'Atto %d si chiude senza una carta del Narratore: il silenzio resta scritto." % act)


## La mano del Narratore (ISSUES 23, D-118): all'apertura dell'atto ogni seggio
## pesca due carte di Propp dal sacchetto pesato dell'atto (§15) - le famiglie
## ripetute pescano piu' spesso, l'ordine lo decide l'RNG a seme, e
## l'eleggibilita' NON si guarda qui: una carta puo' diventare giocabile piu'
## tardi, quando la funzione che aspetta e' stata compiuta (D-030).
const NARRATOR_CARDS_PER_ACT: int = 2


func _deal_narrator_hands(act: int) -> void:
	var bag: Array = []
	for pool in _chronicle["act_echo_pools"]:
		if int(pool["act"]) == act:
			bag = (pool["families"] as Array).duplicate()
	for entity_id in session.service.active_entities():
		var dealt: int = 0
		for _i in range(NARRATOR_CARDS_PER_ACT):
			var card_id: String = _draw_from_bag(bag)
			if card_id == "":
				break
			(world["entities"][str(entity_id)]["echo_hand"] as Array).append(card_id)
			dealt += 1
		if dealt > 0:
			log.bullet("%s riceve %d carte del Narratore." % [_name(str(entity_id)), dealt])


## Una carta dal sacchetto: le famiglie mescolate col seme, la prima famiglia
## che ha ancora una carta nel mazzo vince, dentro la famiglia decide l'ordine
## mescolato del mazzo. Niente eleggibilita': quella si giudica quando si cala.
func _draw_from_bag(bag: Array) -> String:
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
			(deck["draw"] as Array).remove_at(i)
			(deck["drawn"] as Array).append(card_id)
			return card_id
	return ""


## ISSUES 23 (D-118): la carta calata da una mano. Costo e legalita' li ha gia'
## giudicati l'ActionResolver; qui la carta parla - la funzione diventa un fatto
## del mondo (D-030), gli effetti si applicano e si raccontano, i presagi
## scattano, e un eventuale Consiglio prescritto si prenota nello stesso posto
## del CLAIM (`forced_confluence`), per aprirsi a fine round.
func play_narrator_card(entity_id: String, card_id: String, source: Dictionary) -> Array:
	var card: Dictionary = data.echo_cards[card_id]
	log.section("LA CARTA DEL NARRATORE - %s (%s)" % [str(card["title"]), str(card["dramatic_family"])])
	log.bullet("%s la cala sul tavolo." % _name(entity_id))
	log.line(str(card["description"]))
	session.applier.apply(
		Effect.make(
			"SET_GLOBAL_TAG", "world", "WORLD",
			{"tag": "function:%s" % str(card["function_id"])}, source
		)
	)
	var applied: Array = []
	for hook in card["effect_hooks"]:
		# Chi cala la carta e' il suo proponente: gli effetti scritti per un
		# Consiglio ($proponent, $rival) leggono la mano che l'ha giocata.
		var bindings: Dictionary = card_bindings(hook, entity_id)
		if str(hook["kind"]) == "CONSEQUENCE":
			for effect in session.compiler.compile(str(hook["consequence_id"]), bindings, source):
				var stored: Dictionary = session.applier.apply(effect)
				if not stored.is_empty():
					applied.append(stored)
		else:
			var effect: Dictionary = session.compiler.compile_spec(hook["effect"], bindings, source)
			var stored: Dictionary = session.applier.apply(effect)
			if not stored.is_empty():
				applied.append(stored)
	for effect in applied:
		var said: String = EffectNarrator.narrate(effect, data)
		if said != "":
			log.bullet(said)
	session.tensions.fire_omens(source)
	world["echoes_played_in_act"] = int(world.get("echoes_played_in_act", 0)) + 1
	act_echo_drawn.emit(card, applied)
	var forced: Variant = card.get("forces_confluence_on", null)
	if forced != null and world["tensions"].has(str(forced)):
		world["forced_confluence"] = {"tension_id": str(forced), "entity_id": entity_id}
		log.bullet("La carta prescrive un Consiglio su %s." % str(forced))
	return applied


## An Echo card has no Confluence behind it, so `$region_focus` has nothing to
## resolve against unless the card says which question it is about. `bindings`
## may name a `focus_tension`; without one the Chronicle's first Tension is used,
## which keeps every card written before this still working.
func card_bindings(hook: Dictionary, proponent: String = "") -> Dictionary:
	var bindings: Dictionary = (hook.get("bindings", {}) as Dictionary).duplicate(true)
	var tension_id: String = str(bindings.get("focus_tension", ""))
	if tension_id == "" or not world["tensions"].has(tension_id):
		tension_id = str((world["tensions"] as Dictionary).keys()[0])
	bindings["region_focus"] = session.confluence.narrative.focus_region(tension_id)
	bindings["tension"] = tension_id
	# A card has no proponent, but the Consequences it fires were written for a
	# Confluence and expect one. Whoever would carry that question if it opened
	# now is the honest answer - and it is the same rule the Confluence uses, so
	# a card and a council name the same person in the same world. Una carta
	# calata da una mano (ISSUES 23) il proponente ce l'ha: chi l'ha giocata.
	if proponent != "":
		bindings["proponent"] = proponent
	elif not bindings.has("proponent"):
		bindings["proponent"] = session.service.determine_proponent(tension_id)
	bindings["rival"] = session.confluence.narrative.rival_id(
		str(bindings["region_focus"]), str(bindings["proponent"])
	)
	bindings["capital"] = session.confluence.narrative.capital_region()
	bindings["adjacent"] = session.confluence.narrative.adjacent_to(str(bindings["region_focus"]))
	bindings["rival_seat"] = session.confluence.narrative.seat_of(
		str(bindings["rival"]), str(bindings["region_focus"])
	)
	return bindings


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
		log.section("REGISTRO DELLE VERITÀ")
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
	return entity_id if entity == null else str(session.service.name_of(entity_id))
