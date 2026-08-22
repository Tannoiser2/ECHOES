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


## Le righe che il mondo dice all'apertura, una per domanda in gioco (D-207).
##
## `opening_text` e' la cornice - l'anno, e cosa vale comunque - e le domande
## si raccontano da sole, perche' **quali domande siano non si sa finche' non
## sono pescate**. Prima di 0.1.175 l'apertura era un paragrafo scritto a mano
## che nominava quattro domande, e dava la Carestia per certa: darle la
## biblioteca senza spezzarlo avrebbe fatto leggere al tavolo un anno che non
## stava giocando. Una domanda senza riga tace invece di mentire.
func opening_question_lines() -> Array:
	var out: Array = []
	for tension_id in world["tensions"]:
		var definition: Dictionary = session.data.tensions[str(tension_id)]
		var line: String = str(definition.get("opening_line", ""))
		if line != "":
			out.append(line)
	return out


func setup() -> void:
	_set_phase(0, 0, "SETUP")
	log.section("CHRONICLE %s - %s" % [str(_chronicle["id"]), str(_chronicle["title"])])
	log.line(str(_chronicle["opening_text"]))
	for line in opening_question_lines():
		log.line(str(line))
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
		_refill_hands(act)
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
	# Il conto delle forze prima della sovraestensione: chi tiene cosa si decide
	# adesso, e la fatica si paga su quello che si tiene davvero (D-158).
	_recount_control(act, round_number)
	_apply_overextension(act, round_number)

	_set_phase(act, round_number, "THRESHOLD_CHECK")
	await _end_of_round_confluence(decider)

	for tension_id in world["tensions"]:
		log.bullet(session.tensions.public_status(str(tension_id)))


## La contesa del controllo (D-158). Fino a 0.1.124 il padrone di una Regione
## era **scritto**: una Conseguenza metteva un nome, e quel nome restava finche'
## un'altra Conseguenza non lo cambiava. Da qui, se la Chronicle dichiara
## `control_rules.contested`, il padrone e' **contato**: chi somma di piu' fra
## pietre e pedine, ogni fine round.
##
## Il committente l'ha chiesto cosi': «se una entita' ha un castello (che magari
## vale 3) ma un'altra ha un esercito che occupa la regione (che vale 4) la
## regione viene controllata da chi ha di piu'».
##
## Tre cose che questo cambia, e che vanno dette perche' si vedono al tavolo:
##
## - **una Regione si perde senza che nessuno la prenda**: basta andarsene;
## - **il Consiglio non consegna piu' un possesso definitivo**. Una Conseguenza
##   che scrive un nome vale finche' quel nome regge il conto — il Consiglio
##   da' un titolo, tenerlo e' un'altra cosa;
## - **`lapse_without_presence` diventa un caso particolare**: chi non ha
##   niente li' somma zero, e zero non tiene niente.
##
## Il passaggio resta un `SET_CONTROL` come tutti gli altri: stesso Effect,
## stesso inverso, stessa riga nel registro. Cambia chi lo decide, non come si
## scrive.
func _recount_control(act: int, round_number: int) -> void:
	if not session.service.contest_is_on():
		return
	for region_id in _chronicle["regions"]:
		var region: Dictionary = world["regions"][str(region_id)]
		var before: Variant = region.get("control", null)
		var after: Variant = session.service.rightful_holder(str(region_id))
		if str(before if before != null else "") == str(after if after != null else ""):
			continue
		var source: Dictionary = Effect.source(
			"system", "CONTEST", "", act, round_number, int(world["effect_sequence"])
		)
		session.applier.apply(Effect.make(
			"SET_CONTROL", "region", str(region_id), {"entity_id": after}, source
		))
		if after == null:
			log.bullet(
				"%s non risponde piu' a nessuno: %s non ha piu' la forza per tenerla."
				% [_region_name(str(region_id)), _name(str(before))]
			)
		else:
			log.bullet(
				"%s risponde a %s (%d contro %d)."
				% [
					_region_name(str(region_id)),
					_name(str(after)),
					session.service.control_strength(str(after), str(region_id)),
					_runner_up(str(region_id), str(after)),
				]
			)


## La forza del secondo, per poter dire «tre contro due» invece di «tre».
func _runner_up(region_id: String, winner: String) -> int:
	var best: int = 0
	for entity_id in world["turn_order"]:
		if str(entity_id) == winner:
			continue
		best = maxi(best, session.service.control_strength(str(entity_id), region_id))
	return best


func _region_name(region_id: String) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


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

	# **Col cancello del tavolo il pavimento riempie il sacchetto, non spinge una
	# domanda** (D-203). Sotto il cancello un Consiglio si apre a **gettoni**: la
	# soglia della singola Tensione non apre piu' niente, quindi portarne una al
	# proprio numero non produce nessun Consiglio — e se la domanda piu' vicina
	# era gia' sopra la sua soglia (cosa normale, coi gettoni che alzano i
	# valori) il pavimento usciva zitto senza fare niente.
	#
	# Era un difetto latente da D-203, e l'ha scoperto la fase 3: i mucchi
	# coperti alzano un po' i valori, piu' domande si trovano sopra soglia, e il
	# pavimento smetteva di scattare abbastanza spesso da far scendere un anno a
	# un Consiglio solo. L'ha trovato `test_year_end_floor`.
	var gate: int = session.tensions.table_gate()
	if gate > 0:
		var hottest: String = session.tensions.hottest_pile()
		if hottest == "" or not session.confluence.has_fresh_question(hottest):
			return ""
		var missing: int = gate - int(world.get("tokens_in_bag", 0))
		if missing > 0:
			# Le parentesi non sono decorazione: in GDScript `%` lega piu'
			# stretto di `+`, quindi senza formatterebbe solo l'ultimo pezzo
			# (D-195, e la pagina d'aiuto che errava a ogni apertura).
			log.bullet(
				("L'anno non si chiude con la domanda ancora aperta: %s trova "
				+ "i gettoni che le mancano.") % str(data.tensions[hottest]["title"])
			)
			var gate_source: Dictionary = Effect.source(
				"system", "YEAR_END", "", int(world["act"]), int(world["round"]), 0
			)
			# **I gettoni cadono davvero.** Alzare `tokens_in_bag` e basta
			# aprirebbe un Consiglio che il registro non sa spiegare, ed e'
			# l'unico posto del motore in cui il verbale smetterebbe di
			# raccontare il tavolo. Cadono come Effetti, uno per volta,
			# reversibili come tutto il resto.
			for _i in range(missing):
				session.applier.apply(Effect.make(
					"ADJUST_TENSION", "tension", hottest, {"delta": 1}, gate_source
				))
				world["tokens_in_bag"] = int(world.get("tokens_in_bag", 0)) + 1
			session.tensions.fire_omens(gate_source)
		return hottest

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


## Il rubinetto della mano (ISSUES 47, D-185): a inizio Atto la mappa da' le
## carte.
##
## «La presenza nelle regioni deve essere fondamentale nella pesca delle carte,
## tipo due presenze due carte.» Quante ne pesca un seggio lo dicono le sue
## pedine; **di che famiglia** lo dice la Regione dove stanno, perche' ogni
## Regione dichiara le proprie `asset_sources`. La mappa smette di essere un
## punteggio e diventa il rubinetto.
##
## I tre freni sono nella Chronicle e non nel codice, perche' sono taratura:
## il **pavimento** (`floor`) tiene in gioco chi resta senza pedine; il **tetto
## per Atto** (`cap`) limita quante se ne pescano in un colpo; il **tetto sulla
## mano** (`hand_cap`) e' il vero freno alla divergenza che D-183 ha misurato —
## piu' presenza da' piu' carte, piu' carte danno piu' presenza. D-185 ha
## misurato che il solo `cap` **non frena**: le carte non spese restano in mano
## e lo scarto cresce lo stesso.
##
## Vive solo se la Chronicle dichiara `hand_refill`. Senza, non succede niente.
func _refill_hands(act: int) -> void:
	var rules: Dictionary = _chronicle.get("hand_refill", {}) as Dictionary
	if rules.is_empty():
		return
	var per_token: int = int(rules.get("per_token", 1))
	var floor_cards: int = int(rules.get("floor", 1))
	var cap: int = int(rules.get("cap", 3))
	var hand_cap: int = int(rules.get("hand_cap", 0))
	for entity_id in session.service.active_entities():
		var presence: Array = (
			(world["entities"] as Dictionary)[str(entity_id)] as Dictionary
		).get("presence", []) as Array
		# Le famiglie che la mappa gli offre, una per gettone: la stessa Regione
		# due volte offre due volte le sue.
		var offered: Array = []
		for region_id in presence:
			for family in (data.regions[str(region_id)] as Dictionary).get(
				"asset_sources", []
			):
				offered.append(str(family))
		var wanted: int = clampi(presence.size() * per_token, floor_cards, cap)
		# Il tetto sulla **mano**, non sulla pesca: D-185 ha misurato che un
		# tetto per Atto non frena niente, perche' le carte non spese restano
		# in mano e lo scarto si accumula lo stesso. Chi ha ancora carte pesca
		# meno; chi le ha spese pesca pieno.
		if hand_cap > 0:
			var held: int = (
				(world["entities"] as Dictionary)[str(entity_id)] as Dictionary
			)["hand"].size()
			wanted = mini(wanted, hand_cap - held)
		if wanted <= 0:
			continue
		var source: Dictionary = Effect.source(
			"system", "HAND_REFILL", str(entity_id), act, 1, int(world["effect_sequence"])
		)
		var drawn: Array = []
		for _i in range(wanted):
			# Senza pedine la mappa non offre niente e il pavimento pesca dove
			# il mazzo e' piu' pieno: chi e' a terra non sceglie, ma pesca.
			var family: String = (
				str(offered[drawn.size() % offered.size()]) if not offered.is_empty()
				else _fullest_deck()
			)
			var card: String = session.actions.draw_for_refill(
				str(entity_id), family, source
			)
			if card == "":
				continue
			drawn.append(card)
		if not drawn.is_empty():
			log.bullet("%s pesca %d carte da dove tiene le pedine." % [
				_name(str(entity_id)), drawn.size()
			])


## Il mazzo con piu' carte, per il pavimento di chi non ha piu' mappa.
func _fullest_deck() -> String:
	var best: String = ""
	var most: int = -1
	var families: Array = (world["decks"] as Dictionary).keys()
	families.sort()
	for family in families:
		var pile: int = ((world["decks"][str(family)] as Dictionary)["draw"] as Array).size()
		if pile > most:
			most = pile
			best = str(family)
	return best


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

	# La scala che si muove col Destino (D-159): chi ha trionfato alza una
	# pietra, chi non e' arrivato al Minimo ne perde una. Dopo la valutazione,
	# perche' e' l'esito a decidere.
	_settle_structures(results)
	_score_the_saga(results, log)

	session.destiny_results = results
	return {
		"chronicle_id": str(_chronicle["id"]),
		"confluences": confluence_results,
		"destiny_results": results,
		"illegal_actions": illegal_actions,
		"echoes": (world["echo_log"] as Array).size(),
		"truths": (world["truth_log"] as Array).size(),
	}


## Il vincitore della saga (D-180), su richiesta del committente.
##
## «Per vincere la saga ci vuole un contatore di vittorie nelle singole partite.
## Dare un valore ai livelli di vittoria che si sommano alla fine della saga
## decretando il vincitore.»
##
## La Chronicle resta senza punteggio — nessuna classifica dentro l'anno, come
## e' sempre stato — ed e' la **campagna** ad averne uno: ogni anno chiuso somma
## al seggio il valore del suo livello, e il totale attraversa le ere insieme
## alla mappa.
##
## Vive solo se la Chronicle dichiara `saga_scoring`. Senza, non succede niente
## e nemmeno una riga finisce a verbale.
func _score_the_saga(results: Dictionary, log: RefCounted) -> void:
	var rules: Dictionary = _chronicle.get("saga_scoring", {}) as Dictionary
	if rules.is_empty():
		return
	var value_of: Dictionary = {
		"NONE": int(rules.get("none", -1)),
		"MINIMUM": int(rules.get("minimum", 1)),
		"VICTORY": int(rules.get("victory", 3)),
		"TRIUMPH": int(rules.get("triumph", 6)),
	}
	var standing: Array = []
	for entity_id in world["turn_order"]:
		if not results.has(entity_id):
			continue
		var level: String = str((results[entity_id] as Dictionary).get("level", "NONE"))
		if level == "":
			level = "NONE"
		var gained: int = int(value_of.get(level, 0))
		# Con gli obiettivi, due successi parziali che il livello confonde
		# possono valere numeri diversi (D-198): se la Chronicle scrive
		# `objectives.saga_points`, il conto vince sulla scala dei livelli.
		var points: Array = (
			(_chronicle.get("objectives", {}) as Dictionary).get("saga_points", []) as Array
		)
		if not points.is_empty() and (results[entity_id] as Dictionary).has("objectives_met"):
			var met: int = int((results[entity_id] as Dictionary)["objectives_met"])
			gained = int(points[mini(met, points.size() - 1)])
		var seat: Dictionary = world["entities"][str(entity_id)] as Dictionary
		seat["saga_score"] = int(seat.get("saga_score", 0)) + gained
		standing.append([int(seat["saga_score"]), gained, str(entity_id), str(seat["name"])])
	if standing.is_empty():
		return
	standing.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
	log.section("LA SAGA")
	for row in standing:
		var gained: int = int((row as Array)[1])
		log.bullet("%s: %d punti (%s%d quest'anno)" % [
			str((row as Array)[3]), int((row as Array)[0]),
			"+" if gained >= 0 else "", gained,
		])
	# Quando una campagna puo' dire di avere un vincitore (D-181). Il committente
	# l'ha fissata a dieci Chronicle: prima di allora il conto si tiene ma nessuno
	# ha vinto, perche' una manciata di anni non e' una campagna. La soglia apre
	# la porta e non la chiude - da li' in poi il tavolo smette quando vuole.
	var played: int = int(world.get("chronicles_played", 1))
	var needed: int = int(rules.get("decides_after", 10))
	if played < needed:
		log.bullet("La campagna non e' ancora decisa: %d %s su %d." % [
			played, "anno giocato" if played == 1 else "anni giocati", needed,
		])
		return
	var leaders: Array = []
	for row in standing:
		if int((row as Array)[0]) == int((standing[0] as Array)[0]):
			leaders.append(str((row as Array)[3]))
	if leaders.size() > 1:
		log.bullet("Dopo %d anni la campagna e' in parita' fra %s: si va avanti." % [
			played, " e ".join(PackedStringArray(leaders)),
		])
	else:
		log.bullet("Dopo %d anni la campagna la vince %s, con %d punti." % [
			played, str((standing[0] as Array)[3]), int((standing[0] as Array)[0]),
		])


## Il grado che si muove con l'esito (D-159), §7.3 della seduta sulla terra.
##
## «Il cambio puo' dipendere da come vanno le cose: se la reggia appartiene
## all'entita' che ha perso va in rovina, se invece trionfa diventa una reggia.»
##
## A fine Chronicle, e solo se la Chronicle dichiara `structure_rules`:
##
## - chi ha raggiunto un livello fra quelli di `rise_on` **alza di un grado la
##   sua struttura piu' alta** — una casa che vince costruisce sopra quello che
##   ha gia', non altrove: e' cosi' che nasce una capitale;
## - chi si e' fermato a un livello di `fall_on` **perde un grado sulla piu'
##   bassa** — si perdono prima i margini, come gia' fa il controllo che decade
##   dove non c'e' nessuno. Sotto il primo grado la struttura non scende: **va
##   in rovina**, e la rovina lascia una cicatrice.
##
## Deterministico: le Regioni si guardano nell'ordine della Chronicle, quindi a
## parita' di grado vince sempre la stessa.
func _settle_structures(results: Dictionary) -> void:
	var rules: Dictionary = _chronicle.get("structure_rules", {})
	if rules.is_empty():
		return
	var rise_on: Array = rules.get("rise_on", [])
	var fall_on: Array = rules.get("fall_on", [])
	for entity_id in world["turn_order"]:
		var seat: String = str(entity_id)
		var result: Variant = results.get(seat)
		if result == null:
			continue
		var level: String = str((result as Dictionary)["level"])
		if rise_on.has(level):
			_raise_one(seat)
		elif fall_on.has(level):
			_lower_one(seat)


## La piu' alta che puo' ancora salire.
func _raise_one(seat: String) -> void:
	var found: Dictionary = _pick_structure(seat, true)
	if found.is_empty():
		return
	var definition: Dictionary = data.structure_types[str(found["structure_type"])]
	var grade: int = int(found["grade"]) + 1
	session.applier.apply(Effect.make(
		"SET_STRUCTURE_GRADE", "region", str(found["region_id"]),
		{"structure_type": str(found["structure_type"]), "grade": grade},
		Effect.source("system", "DESTINY_RISE", seat, 0, 0, int(world["effect_sequence"]))
	))
	log.bullet(
		"%s ha ottenuto quello che voleva, e %s adesso e' %s."
		% [
			_name(seat),
			_region_name(str(found["region_id"])),
			str(((definition["grades"] as Array)[grade - 1] as Dictionary)["name"]).to_lower(),
		]
	)


## La piu' bassa. Sotto il primo grado non si scende: si cade.
func _lower_one(seat: String) -> void:
	var found: Dictionary = _pick_structure(seat, false)
	if found.is_empty():
		return
	var type_id: String = str(found["structure_type"])
	var region_id: String = str(found["region_id"])
	var definition: Dictionary = data.structure_types[type_id]
	var source: Dictionary = Effect.source(
		"system", "DESTINY_FALL", seat, 0, 0, int(world["effect_sequence"])
	)
	if int(found["grade"]) > 1:
		session.applier.apply(Effect.make(
			"SET_STRUCTURE_GRADE", "region", region_id,
			{"structure_type": type_id, "grade": int(found["grade"]) - 1}, source
		))
		log.bullet(
			"%s non ha ottenuto niente, e %s in %s ha perso un piano."
			% [_name(seat), str(definition["name"]).to_lower(), _region_name(region_id)]
		)
		return

	session.applier.apply(Effect.make(
		"RAZE_STRUCTURE", "region", region_id, {"structure_type": type_id}, source
	))
	var ruin: Dictionary = definition.get("ruin", {})
	if not ruin.is_empty() and str(ruin.get("scar", "")) != "":
		session.applier.apply(Effect.make(
			"ADD_SCAR", "scar", "SCAR_RUIN_%s_%s" % [type_id, region_id],
			{
				"scar_id": "SCAR_RUIN_%s_%s" % [type_id, region_id],
				"region_id": region_id,
				"tag": str(ruin["scar"]),
				"description": str(ruin.get("description", "")),
			},
			source
		))
	log.bullet(
		"%s non ha ottenuto niente, e %s in %s e' andata in %s."
		% [
			_name(seat), str(definition["name"]).to_lower(), _region_name(region_id),
			str(ruin.get("name", "rovina")).to_lower(),
		]
	)


## La struttura di quel seggio da muovere: la piu' alta che puo' salire, o la
## piu' bassa che puo' scendere. Vuoto se non ne ha nessuna.
func _pick_structure(seat: String, rising: bool) -> Dictionary:
	var best: Dictionary = {}
	for region_id in _chronicle["regions"]:
		for structure in (world["regions"][str(region_id)] as Dictionary).get("structures", []):
			var record: Dictionary = structure as Dictionary
			if str(record.get("owner", "")) != seat:
				continue
			var definition: Variant = data.structure_types.get(str(record["structure_type"]))
			if definition == null or not bool(definition["owned"]):
				continue
			var grade: int = int(record["grade"])
			if rising and grade >= (definition["grades"] as Array).size():
				continue
			if best.is_empty() or (grade > int(best["grade"]) if rising else grade < int(best["grade"])):
				best = {
					"region_id": str(region_id),
					"structure_type": str(record["structure_type"]),
					"grade": grade,
				}
	return best


func _set_phase(act: int, round_number: int, phase: String) -> void:
	world["act"] = act
	world["round"] = round_number
	world["phase"] = phase
	phase_changed.emit(act, round_number, phase)


func _name(entity_id: String) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(session.service.name_of(entity_id))
