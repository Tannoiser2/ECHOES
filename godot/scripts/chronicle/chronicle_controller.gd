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
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")

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
				# **Col nome del luogo, non col suo id** (ISSUES 63): il verbale sta
				# sullo schermo accanto alle domande, e una riga che dice
				# «presenza: REG_MINIERE_ANTICHE» e' un id sotto gli occhi di chi
				# gioca come lo sarebbe su un bottone.
				", ".join(PackedStringArray(_place_names(
					session.service.regions_with_presence(str(entity_id))
				))),
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
	for region_id in world["regions"]:
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
		for region_id in world["regions"]:
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

	# Col Consiglio a fine Atto (D-214) il round non ne apre piu' nessuno da
	# solo: restano i forzati da RIVENDICARE, che sono il modo di portare al
	# tavolo una **seconda** domanda. Il numero di Consigli smette di essere
	# un'incognita del sistema — sono almeno quanti sono gli Atti — e i gettoni
	# smettono di dire *se* si parla per dire soltanto *di cosa*.
	if _council_at_end_of_act():
		# **Il diritto rivendicato si spende a fine Atto** (D-261): il round
		# non apre piu' nemmeno i forzati. Chi ha consumato un RIVENDICARE
		# tiene il suo secondo dibattito per quando i mazzetti si girano, e
		# la questione sara' il secondo mazzetto piu' alto — non quella che
		# ha nominato, che resta solo come ripiego.
		world["confluence_queue"] = []
		return

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
## `claimant` (D-268): il seggio che ha consumato un RIVENDICARE nell'Atto e
## puo' spendere qui il diritto come controproposta invece che nel secondo
## dibattito. Vuoto, il Consiglio e' quello di sempre.
func run_confluence(
	tension_id: String, trigger: Dictionary, decider: Object, claimant: String = ""
) -> Dictionary:
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

	# **Il proponente compra** (D-280): posa le pedine sui benefici della carta,
	# e con esse decide **quanto** pagera' — un costo per ogni beneficio oltre
	# il primo. Un cervello che non sa comprare (has_method) compra il primo
	# beneficio, che e' gratis: nessuna proposta esce dal tavolo a mani vuote
	# senza che qualcuno l'abbia deciso.
	var offered: Array = controller.benefit_menu()
	if not offered.is_empty():
		var bought: Array = []
		if decider.has_method("choose_benefits"):
			bought = await decider.choose_benefits(
				str(context["proponent"]), context, offered, session
			)
		if bought.is_empty():
			bought = [str((offered[0] as Dictionary)["id"])]
		if not controller.set_benefits(bought):
			log.bullet("Acquisto rifiutato (%s): si compra il primo beneficio." % controller.last_error)
			illegal_actions += 1
			controller.set_benefits([str((offered[0] as Dictionary)["id"])])

	for entity_id in controller.stance_order():
		var declaration: Dictionary = await decider.choose_stance(str(entity_id), context, session)
		if not controller.declare_stance(
			str(entity_id), str(declaration.get("stance", "ABSTAIN")), str(declaration.get("clause_id", ""))
		):
			log.bullet("Posizione rifiutata (%s): %s si astiene." % [controller.last_error, _name(str(entity_id))])
			illegal_actions += 1
			controller.declare_stance(str(entity_id), "ABSTAIN")

	# La controproposta del RIVENDICARE (D-268): prima della pedina del
	# prezzo, perche' il diritto pagato con l'azione batte l'ordine delle
	# dichiarazioni. Il rivendicante sceglie: prendersi la pedina del prezzo,
	# rivendicare una voce del beneficio, o tenersi il secondo dibattito.
	var counterclaimed: String = ""
	if claimant != "" and claimant != str(context["proponent"]) \
			and decider.has_method("choose_counterclaim"):
		var offer: Dictionary = {
			"price": controller.price_menu(),
			"benefits": controller.claimable_benefits(),
		}
		var counter: Dictionary = await decider.choose_counterclaim(claimant, context, offer, session)
		var mode: String = str(counter.get("mode", ""))
		if mode == "price":
			if controller.place_counterclaim(
				claimant, "price", str(counter.get("cost", "")), str(counter.get("failure", ""))
			):
				counterclaimed = mode
			else:
				log.bullet("Controproposta rifiutata (%s): resta il secondo dibattito." % controller.last_error)
				illegal_actions += 1
		elif mode == "benefit":
			if controller.place_counterclaim(claimant, "benefit", str(counter.get("voice_id", ""))):
				counterclaimed = mode
			else:
				log.bullet("Controproposta rifiutata (%s): resta il secondo dibattito." % controller.last_error)
				illegal_actions += 1

	# La pedina del prezzo (PZ-5, D-267): a posizioni dichiarate e **prima**
	# degli impegni - che restano segreti - il primo seggio del fronte avverso
	# sceglie dal menu quale voce paghera' chi vince. Un cervello che non sa
	# scegliere (has_method) lascia decidere il mondo: la prima voce, com'era.
	# Se la controproposta si e' presa la pedina, il fronte avverso non sceglie.
	# **Gli avversari scelgono in che moneta paga** (D-280): il conto lo ha
	# fatto l'economia — un costo per ogni beneficio oltre il primo — e il primo
	# seggio del fronte avverso sceglie **quali** costi, fra quelli stampati.
	# Se non sceglie, il mondo prende dall'alto della lista: una carta muta non
	# esce senza prezzo. Se la controproposta si e' presa la pedina, il fronte
	# avverso non sceglie.
	# **Ogni avversario decide se pagare per far pagare** (D-387, ISSUES 122):
	# spende un gettone di rivendicazione e posa una pedina su un costo, oppure
	# si astiene. Nessuno spende, nessun prezzo — e la proposta passa gratis,
	# che e' la cosa che l'aritmetica di D-280 non permetteva.
	if counterclaimed != "price" and decider.has_method("choose_cost_token"):
		for entity_id in controller.stance_order():
			if str(entity_id) == str(context["proponent"]):
				continue
			if controller.claim_tokens(str(entity_id)) <= 0:
				continue
			# **Prima la domanda che chiude l'altra** (D-419, ISSUES 119): lo
			# stesso gettone puo' comprare un costo o l'opposizione, e sono uno
			# la rinuncia dell'altro. Chi lo spende contro non posa nessun
			# prezzo, e la sua riga finisce qui.
			if (
				controller.opposition_weight() > 0
				and decider.has_method("choose_opposition_token")
				and await decider.choose_opposition_token(str(entity_id), context, session)
			):
				if controller.buy_opposition(str(entity_id)):
					continue
				log.bullet("Opposizione rifiutata (%s): %s si astiene." % [
					controller.last_error, _name(str(entity_id))
				])
				illegal_actions += 1
			if controller.costs_placed() >= CouncilEconomy.MAX_COSTS:
				break
			# **Il menu si accorcia** man mano che le pedine si posano: una
			# pedina per voce, e chi arriva dopo sceglie fra quelle libere.
			# Senza questa riga il secondo avversario chiedeva la stessa
			# casella del primo — la piu' dolorosa per il proponente e' sempre
			# la stessa — e il Consiglio lo rifiutava come scelta illegale.
			var menu: Array = []
			for voice_id in (controller.price_menu()["cost"] as Array):
				if not controller.priced_costs().has(str(voice_id)):
					menu.append(str(voice_id))
			if menu.is_empty():
				break
			var picked: String = await decider.choose_cost_token(
				str(entity_id), context, menu, session
			)
			if picked != "" and not controller.place_cost(str(entity_id), picked):
				log.bullet("Prezzo rifiutato (%s): %s si astiene." % [
					controller.last_error, _name(str(entity_id))
				])
				illegal_actions += 1

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
	# Chi ha detto cosa e con quante carte, letto **prima** di `resolve()`, che
	# svuota `current` (D-455): i punti del dibattito si contano su questo.
	var debate_proponent: String = str(controller.current["proponent"])
	var debate_stances: Dictionary = (controller.current["stances"] as Dictionary).duplicate(true)
	var debate_commits: Dictionary = (controller.current["commits"] as Dictionary).duplicate(true)
	var result: Dictionary = controller.resolve(recovery)
	if not result.is_empty():
		result["debate_points"] = _score_the_debate(
			result, debate_proponent, debate_stances, debate_commits
		)
		confluence_results.append(result)
		confluence_resolved.emit(result)
	return result


## **L'astensione ha un prezzo** (D-455, parola del committente: *«chi non
## gioca carte, oltre a fare un favore a chi le gioca, potrebbe perdere punti
## vittoria se perde un dibattito, oppure potrebbero guadagnarle chi li
## vince»*). Due numeri nella Chronicle, `confluence_rules.debate_points`:
## `winners_gain`, quanti punti di campagna prende chi sta sul fronte che ha
## vinto **con almeno una carta impegnata**; `silent_lose`, quanti ne perde chi
## non propone e non impegna niente. Zero e zero, e il Consiglio e' quello di
## prima. Il punteggio di campagna e' un'eccezione dichiarata all'effect-
## sourcing, come a fine anno: qui si scrive e si dice, non si registra.
func _score_the_debate(
	result: Dictionary, proponent: String, stances: Dictionary, commits: Dictionary
) -> Dictionary:
	var rules: Dictionary = (
		(_chronicle.get("confluence_rules", {}) as Dictionary).get("debate_points", {}) as Dictionary
	)
	var winners_gain: int = int(rules.get("winners_gain", 0))
	var silent_lose: int = int(rules.get("silent_lose", 0))
	var deltas: Dictionary = {}
	if winners_gain <= 0 and silent_lose <= 0:
		return deltas
	var won: bool = ConfluenceResolution.is_success(str(result["outcome"]))
	for entity_id in world["turn_order"]:
		var seat: String = str(entity_id)
		var cards: int = (commits.get(seat, []) as Array).size()
		var side: String = (
			"SUPPORT" if seat == proponent
			else str((stances.get(seat, {}) as Dictionary).get("stance", "ABSTAIN"))
		)
		var delta: int = 0
		if winners_gain > 0 and cards > 0 and ((won and side == "SUPPORT") or (not won and side == "OPPOSE")):
			delta += winners_gain
		if silent_lose > 0 and seat != proponent and cards == 0:
			delta -= silent_lose
		if delta == 0:
			continue
		var who: Dictionary = world["entities"][seat] as Dictionary
		who["saga_score"] = int(who.get("saga_score", 0)) + delta
		deltas[seat] = delta
		log.bullet("Punti del dibattito: %s %+d — %s." % [
			_name(seat), delta,
			"ha vinto con le carte in mano" if delta > 0 else "non ha giocato carte",
		])
	return deltas


## ISSUES 23 (D-118): la carta di Propp non si pesca piu' da sola a fine atto —
## la cala un giocatore, nel suo turno, pagandola. Qui resta solo il sipario:
## se in tutto l'atto nessuno ha parlato, il silenzio e' una scelta del tavolo
## (decisione del committente: nessuna rete di sicurezza).
func end_of_act(act: int, decider: Object) -> void:
	_set_phase(act, int(_chronicle["rounds_per_act"]), "ACT_ECHO")
	var played: int = int(world.get("echoes_played_in_act", 0))
	world["echoes_played_in_act"] = 0
	if played == 0:
		log.bullet("L'Atto %d si chiude senza una carta del Narratore: il silenzio resta scritto." % act)
	await _council_closing_the_act(act, decider)


## Il Consiglio di fine Atto (D-214).
##
## *«Il consiglio si puo' aprire alla fine di ogni atto in automatico e la
## domanda con piu' valore sara' quella dibattuta, cosi' e' sicuro che almeno
## tre consigli ci saranno sempre.»*
##
## Quale domanda: **il mucchio piu' alto**, che e' esattamente cio' che i
## gettoni coperti costruiscono per tutto l'Atto ([D-210](DECISIONS.md#d-210)) —
## si girano, si contano, e vince chi ha scaldato di piu'. Se quel mucchio ha
## gia' detto tutto quello che sapeva dire, si scende al successivo invece di
## riaprire una domanda gia' chiusa (D-077).
func _council_closing_the_act(act: int, decider: Object) -> void:
	if not _council_at_end_of_act():
		return
	# **I mazzetti si girano** (D-261, parola del committente): a fine Atto i
	# gettoni coperti scoprono il loro valore, il mazzetto piu' alto porta al
	# Consiglio la sua carta girata, e chi ha guadagnato un secondo dibattito
	# con RIVENDICARE apre il secondo mazzetto. Il mucchio piu' alto delle
	# questioni resta come ripiego dichiarato per l'Atto in cui nessuna
	# Risonanza ha scaldato niente: un tavolo freddo non e' un tavolo senza
	# domande.
	_reveal_the_piles(act)
	# Il diritto rivendicato si legge **prima** del primo Consiglio: risolvere
	# una Confluence azzera `forced_confluence` (e' la sua consumazione, da
	# prima di questa decisione), quindi leggerlo dopo lo trovava sempre vuoto
	# — cento anni a tre Consigli esatti, e il playtest l'ha detto subito.
	var forced: Variant = world.get("forced_confluence", null)
	world["forced_confluence"] = null
	var first_theme: String = ""
	var tension_id: String = _front_of_hottest_theme("")
	if tension_id != "":
		first_theme = str(data.tensions[tension_id].get("theme", ""))
	else:
		tension_id = _hottest_with_something_to_say()
	if tension_id == "":
		log.bullet(
			"L'Atto %d si chiude senza Consiglio: nessuna domanda ha ancora qualcosa di nuovo da decidere."
			% act
		)
	else:
		log.section("IL CONSIGLIO DI FINE ATTO %d" % act)
		_set_phase(act, int(_chronicle["rounds_per_act"]), "CONFLUENCE")
		# Il diritto del RIVENDICARE entra nel primo Consiglio (D-268): il suo
		# titolare puo' spenderlo li' come controproposta. Se lo fa, il secondo
		# dibattito non si apre - un'azione, un uso.
		var claimant: String = "" if forced == null else str((forced as Dictionary).get("entity_id", ""))
		var first_result: Dictionary = await run_confluence(
			tension_id, {"kind": "THRESHOLD", "entity_id": ""}, decider, claimant
		)
		if str(first_result.get("counterclaim", "")) != "":
			log.bullet(
				"Il diritto del RIVENDICARE si e' speso in controproposta: nessun secondo dibattito."
			)
			forced = null
	await _second_council_of_the_act(act, first_theme, forced, decider)
	_spend_the_piles(act)


## Il secondo dibattito (D-261): chi ha consumato un RIVENDICARE durante
## l'Atto non sceglie piu' lui la questione — apre **il secondo mazzetto piu'
## alto**, restando proponente. Se i mazzetti non offrono niente, si ripiega
## sulla questione che aveva nominato, se ha ancora qualcosa da chiedere: il
## diritto guadagnato non evapora in silenzio (ISSUES 53).
func _second_council_of_the_act(act: int, first_theme: String, forced: Variant, decider: Object) -> void:
	if forced == null:
		return
	var claimant: String = str((forced as Dictionary).get("entity_id", ""))
	var tension_id: String = _front_of_hottest_theme(first_theme)
	if tension_id == "":
		var named: String = str((forced as Dictionary).get("tension_id", ""))
		if named != "" and session.confluence.can_open(named):
			tension_id = named
	if tension_id == "":
		log.bullet("Il secondo dibattito rivendicato da %s non trova una questione aperta: il diritto si spegne, e resta scritto." % _name(claimant))
		return
	log.section("IL SECONDO CONSIGLIO DELL'ATTO %d" % act)
	_set_phase(act, int(_chronicle["rounds_per_act"]), "CONFLUENCE")
	await run_confluence(tension_id, {"kind": "CLAIM", "entity_id": claimant}, decider)


func _council_at_end_of_act() -> bool:
	return bool(
		(_chronicle.get("confluence_rules", {}) as Dictionary).get("at_end_of_act", false)
	)


## La rivelazione (D-261): i gettoni coperti si girano, e per la prima volta
## l'Atto dice quanto valeva ogni mazzetto. E' il momento del tavolo — si
## racconta anche quando non cambia niente, perche' girare due gettoni bianchi
## e' una storia («tanto fumo, niente fuoco»).
func _reveal_the_piles(_act: int) -> void:
	var track: Dictionary = world.get("theme_heat", {}) as Dictionary
	var counts: Dictionary = world.get("theme_tokens", {}) as Dictionary
	var said: PackedStringArray = PackedStringArray()
	for theme_id in data.themes:
		var fallen: int = int(counts.get(str(theme_id), 0))
		if fallen <= 0:
			continue
		said.append("%s vale %d (%d gettoni)" % [
			str(data.themes[str(theme_id)]["title"]),
			int(track.get(str(theme_id), 0)), fallen,
		])
	if said.is_empty():
		return
	log.bullet("I mazzetti si girano: %s." % "; ".join(said))


## La carta girata del mazzetto piu' alto (D-261). Si scorrono i Temi dal
## valore rivelato piu' alto in giu' — a parita' l'ordine del dato, che e'
## l'ordine stampato — saltando `exclude` (il Tema gia' dibattuto dal primo
## Consiglio). Per ogni Tema caldo si prende **la sua carta girata**; se non
## s'e' ancora girata (valore alto con pochi gettoni), la gira la rivelazione
## stessa; se la girata ha gia' detto tutto, si gira la prossima. Un Tema il
## cui mazzetto si esaurisce lascia il posto al successivo. I Temi a zero non
## scelgono niente: sotto il freddo decide il mucchio, e la regola vecchia
## resta scritta come ripiego.
func _front_of_hottest_theme(exclude: String) -> String:
	var track: Dictionary = world.get("theme_heat", {}) as Dictionary
	var order: Array = data.themes.keys()
	var ranked: Array = order.duplicate()
	ranked.sort_custom(func(a: String, b: String) -> bool:
		var heat_a: int = int(track.get(a, 0))
		var heat_b: int = int(track.get(b, 0))
		if heat_a == heat_b:
			return order.find(a) < order.find(b)
		return heat_a > heat_b
	)
	for theme_id in ranked:
		if str(theme_id) == exclude:
			continue
		if int(track.get(str(theme_id), 0)) <= 0:
			break
		var tension_id: String = _front_that_can_open(str(theme_id))
		if tension_id != "":
			return tension_id
	return ""


## Il fronte del Tema che si aprirebbe adesso: la carta girata se ha ancora
## qualcosa da chiedere, altrimenti si gira la prossima finche' il mazzetto ne
## ha. `can_open` e non `has_fresh_question`, per la stessa ragione scritta in
## `_hottest_with_something_to_say`.
func _front_that_can_open(theme_id: String) -> String:
	var front: String = session.tensions.theme_front(theme_id)
	if front != "" and session.confluence.can_open(front):
		return front
	while true:
		front = session.tensions.flip_theme_front(theme_id)
		if front == "":
			return ""
		if session.confluence.can_open(front):
			return front
	return ""


## I mazzetti si spendono (D-261): dopo i Consigli dell'Atto ogni Tema torna
## freddo — valori a zero per Effect, gettoni via dal tavolo — e l'Atto nuovo
## ricomincia a contare. Le carte girate **restano girate**: una questione
## scoperta non si copre piu'. Quanto del Calore non speso dovrebbe invece
## sopravvivere all'Atto e' taratura d'autore (ROADMAP §4.1).
func _spend_the_piles(act: int) -> void:
	var track: Dictionary = world.get("theme_heat", {}) as Dictionary
	var counts: Dictionary = world.get("theme_tokens", {}) as Dictionary
	var source: Dictionary = Effect.source(
		"system", "ACT_END", "", act, int(world["round"]), 0
	)
	for theme_id in data.themes:
		var heat: int = int(track.get(str(theme_id), 0))
		if heat > 0:
			session.applier.apply(Effect.make(
				"ADJUST_THEME_HEAT", "theme", str(theme_id), {"delta": -heat}, source
			))
		counts[str(theme_id)] = 0


## Il mucchio piu' alto fra quelli che hanno ancora una domanda fresca. In
## ordine di altezza, a parita' l'ordine in cui le domande sono state pescate -
## la stessa regola di `tensions_at_threshold`, cosi' un Consiglio forzato e uno
## di fine Atto scelgono allo stesso modo.
func _hottest_with_something_to_say() -> String:
	var order: Array = (world["tensions"] as Dictionary).keys()
	var ranked: Array = order.duplicate()
	ranked.sort_custom(func(a: String, b: String) -> bool:
		var value_a: int = session.tensions.value(a)
		var value_b: int = session.tensions.value(b)
		if value_a == value_b:
			return order.find(a) < order.find(b)
		return value_a > value_b
	)
	for tension_id in ranked:
		# `can_open` e non `has_fresh_question`: la seconda dice se resta un
		# quesito mai posto, la prima se ce n'e' uno che **si aprirebbe adesso**.
		# Scegliere sulla seconda faceva rifiutare l'apertura e perdere il
		# Consiglio dell'Atto, invece di scendere al mucchio successivo.
		if session.confluence.can_open(str(tension_id)):
			return str(tension_id)
	return ""


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
	var per_control: int = int(rules.get("per_control", 0))
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
		# Quello che **tiene**, non solo dove sta (D-220). Il rubinetto contava
		# le pedine e basta, quindi il possesso di una Regione non pagava piu'
		# che starci dentro: la maggioranza era un numero nella contesa e niente
		# altro, e alzare una pietra non cambiava una carta in mano a nessuno.
		var held_regions: int = session.service.control_count(str(entity_id)) if per_control > 0 else 0
		var wanted: int = clampi(
			presence.size() * per_token + held_regions * per_control, floor_cards, cap
		)
		# Il tetto sulla **mano**, non sulla pesca: D-185 ha misurato che un
		# tetto per Atto non frena niente, perche' le carte non spese restano
		# in mano e lo scarto si accumula lo stesso. Chi ha ancora carte pesca
		# meno; chi le ha spese pesca pieno.
		#
		# E il tetto **sale con quello che si tiene**: senza, il possesso non si
		# vedrebbe comunque — chiunque converge alla stessa mano piena, e la
		# presenza decide soltanto quanto in fretta. Misurato: col tetto fisso,
		# chi aveva cinque pedine pescava **meno** di chi ne aveva tre.
		if hand_cap > 0:
			var held: int = (
				(world["entities"] as Dictionary)[str(entity_id)] as Dictionary
			)["hand"].size()
			wanted = mini(wanted, hand_cap + held_regions * per_control - held)
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


## L'Eco che parla (D-118, D-359). Costo e legalita' li ha gia' giudicati
## l'ActionResolver, che ha anche gia' scartato la carta calata e il suo prezzo;
## qui l'Eco parla - gli effetti si applicano e si raccontano, i presagi
## scattano, e un eventuale Consiglio prescritto si prenota nello stesso posto
## del CLAIM (`forced_confluence`), per aprirsi a fine round.
##
## Non arriva piu' da un mazzo: arriva dalla faccia della carta Asset che
## qualcuno aveva in mano, ed e' per questo che la pila `echo_played` e' anche
## il registro di quali carte sono state spese per la loro versione potenziata.
func play_narrator_card(entity_id: String, card_id: String, source: Dictionary) -> Array:
	var card: Dictionary = data.echo_cards[card_id]
	log.section("LA CARTA DEL NARRATORE - %s (%s)" % [str(card["title"]), str(card["dramatic_family"])])
	log.bullet("%s la cala sul tavolo." % _name(entity_id))
	log.line(str(card["description"]))
	# La funzione della carta **non si scrive piu' sul mondo** (D-358). Era un
	# segno che il giocatore non vedeva — `effect_text` lo nascondeva apposta — e
	# decideva chi poteva uscire l'anno dopo: viveva solo nell'app. Adesso la
	# carta si posa scoperta sul tavolo, e la domanda «e' gia' successa una cosa
	# di questo genere?» si fa guardando quella pila.
	if not (world["echo_played"] as Array).has(card_id):
		(world["echo_played"] as Array).append(card_id)
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
	# Il consuntivo degli obiettivi si congela **qui**, insieme ai livelli
	# (D-217). `objectives_of` ricalcola dal mondo corrente, e subito sotto
	# `_settle_structures` alza una pietra a chi ha ottenuto quello che voleva:
	# chi chiedesse gli obiettivi dopo `run()` leggerebbe un tavolo di un
	# istante piu' tardi di quello che ha deciso l'anno. Il libro mastro lo
	# faceva, e diceva che «Pietra sopra Pietra» si avvera nel 27% dei casi
	# quando in partita non si avvera mai.
	var objectives_taken: Dictionary = {}
	for entity_id in world["turn_order"]:
		objectives_taken[str(entity_id)] = session.destinies.objectives_of(str(entity_id))
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
		"objectives": objectives_taken,
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
	# **L'Eredita'** (D-385): a saga decisa, e non prima, i gradini si sommano
	# alle leggende che portano il nome di ciascuna casa.
	var final_standing: Array = []
	var said_legacy: bool = false
	for row in standing:
		var seat_id: String = str((row as Array)[2])
		var bonus: int = legacy_points(world, data, seat_id)
		if bonus > 0:
			if not said_legacy:
				log.bullet("L'Eredita' (%d per leggenda):" % LEGACY_PER_LEGEND)
				said_legacy = true
			log.bullet("  %s: +%d — %s" % [
				str((row as Array)[3]), bonus,
				", ".join(PackedStringArray(legends_named_after(world, data, seat_id))),
			])
		final_standing.append([
			int((row as Array)[0]) + bonus, bonus, seat_id, str((row as Array)[3]),
		])
	final_standing.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
	var leaders: Array = []
	for row in final_standing:
		if int((row as Array)[0]) == int((final_standing[0] as Array)[0]):
			leaders.append(str((row as Array)[3]))
	if leaders.size() > 1:
		log.bullet("Dopo %d anni la campagna e' in parita' fra %s: si va avanti." % [
			played, " e ".join(PackedStringArray(leaders)),
		])
	else:
		log.bullet("Dopo %d anni la campagna la vince %s, con %d punti." % [
			played, str((final_standing[0] as Array)[3]),
			int((final_standing[0] as Array)[0]),
		])


## **L'Eredita'** (D-385 — ISSUES 84, la seconda delle tre strade di D-299,
## scelta dal committente): *«a fine saga, +3 per ogni leggenda che porta il tuo
## nome»*.
##
## Una leggenda porta il nome di una casa quando racconta uno dei segni che
## quella casa aveva dichiarato di voler lasciare — i `wants` del suo profilo
## strategico. Le leggende non le scrive nessun giocatore: le fabbrica **il
## tempo**, al salto d'era, trasformando in `legend:<fatto>` i fatti che
## sbiadiscono (D-075). E' la frase del committente — *«il mondo parla ancora la
## lingua che quell'Entita' voleva lasciare?»* — letta su un dato che esiste
## gia', senza inventarne uno.
##
## **Perche' e' un bonus e non un gradino**, e per questo si conta a parte
## invece di finire dentro `saga_score`: la soglia che decide la campagna apre
## la porta e non la chiude (D-181), quindi una saga puo' continuare oltre.
## Sommarlo al totale lo pagherebbe una seconda volta l'anno dopo, e una terza
## quello dopo ancora — cioe' premierebbe la durata, che e' esattamente quello
## che il committente ha scritto di non volere (D-299).
const LEGACY_PER_LEGEND: int = 3


## Quanto vale l'Eredita' di una casa, a fine saga.
static func legacy_points(world_state: Dictionary, data_set: RefCounted, entity_id: String) -> int:
	return legends_named_after(world_state, data_set, entity_id).size() * LEGACY_PER_LEGEND


## Le leggende che portano il nome di una casa, per nome. Solo i fatti globali:
## `legend:` lo scrive **solo** la sbiadita del salto d'era, e lo scrive li'.
static func legends_named_after(
	world_state: Dictionary, data_set: RefCounted, entity_id: String
) -> Array:
	var profile: Variant = (data_set.entity_profiles as Dictionary).get(entity_id)
	if profile == null:
		return []
	var facts: Array = world_state.get("global_tags", [])
	var found: Array = []
	for voice in ((profile as Dictionary).get("wants", []) as Array):
		var tag: String = str((voice as Dictionary).get("tag", ""))
		if tag != "" and facts.has("legend:%s" % tag) and not found.has(tag):
			found.append(tag)
	found.sort()
	return found


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
	for region_id in world["regions"]:
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


## I nomi dei luoghi come si leggono al tavolo (ISSUES 63): una Regione che il
## verbale chiama col suo id e' un id sotto gli occhi di chi gioca.
func _place_names(region_ids: Array) -> Array:
	var out: Array = []
	for region_id in region_ids:
		var region: Variant = data.regions.get(str(region_id))
		out.append(str(region_id) if region == null else str((region as Dictionary)["name"]))
	return out
