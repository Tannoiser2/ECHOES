extends "res://tests/test_case.gd"
## Il Consiglio di fine Atto (ISSUES 49 / [D-214](DECISIONS.md#d-214)).
##
## «Il consiglio si può aprire alla fine di ogni atto in automatico e la domanda
## con più valore sarà quella dibattuta, così è sicuro che almeno tre consigli
## ci saranno sempre.»
##
## La frase contiene due promesse e vanno provate tutte e due, perché una senza
## l'altra è mezza regola: **almeno un Consiglio per Atto** — cioè il numero di
## Consigli smette di essere un'incognita del sistema — e **quello col mucchio
## più alto**, cioè i gettoni smettono di dire *se* si parla e dicono soltanto
## *di cosa*.
##
## E ce n'è una terza, che è ciò che la regola *toglie*: il cancello a due
## gettoni non deve poter aprire un secondo rubinetto sullo stesso Consiglio.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Effect := preload("res://scripts/core/effect.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


## Quattro persone che non toccano niente. È il tavolo più silenzioso possibile:
## se il Consiglio arriva anche qui, arriva sempre.
class Idle extends RefCounted:
	func choose_action(_entity_id: String, _ao: int, _session: RefCounted) -> Dictionary:
		return {"template": "PASS", "params": {}}

	func choose_question(_context: Dictionary, _options: Array, _session: RefCounted) -> String:
		return ""

	func choose_proposition(_context: Dictionary, options: Array, _session: RefCounted) -> String:
		return "" if options.is_empty() else str(options[0]["id"])

	func choose_stance(_entity_id: String, _context: Dictionary, _session: RefCounted) -> Dictionary:
		return {"stance": "ABSTAIN", "clause_id": ""}

	func choose_commit(
		_entity_id: String, _context: Dictionary, _limit: int, _session: RefCounted
	) -> Array:
		return []

	func choose_recovery(_context: Dictionary, _session: RefCounted) -> Dictionary:
		return {}


func _run(seed_value: int, decider: RefCounted) -> Dictionary:
	if session != null:
		session.dispose()
	session = GameSession.new(data())
	session.setup("CHR_01", SEATS, seed_value)
	return await session.run(decider)


## La promessa numerica, e col tavolo che ne dà meno di chiunque: tre Atti, tre
## Consigli, su ogni seme provato.
func test_a_silent_table_still_gets_one_council_per_act() -> void:
	var acts: int = int(data().chronicles["CHR_01"]["acts"])
	for index in range(6):
		var seed_value: int = 9100 + index * 37
		var report: Dictionary = await _run(seed_value, Idle.new())
		assert_true(
			(report["confluences"] as Array).size() >= acts,
			"seme %d: %d Consigli su %d Atti" % [
				seed_value, (report["confluences"] as Array).size(), acts
			]
		)


## E si tengono **dove** devono: uno per Atto, non tre nell'ultimo. Un anno che
## decide tutto alla fine è un anno in cui i primi due Atti non contano.
func test_the_councils_are_spread_one_per_act() -> void:
	await _run(9100, Idle.new())
	var per_act: Dictionary = {}
	for line in session.log.lines:
		var text: String = str(line)
		if not text.contains("IL CONSIGLIO DI FINE ATTO"):
			continue
		# `section()` incornicia il titolo fra "== ", quindi l'ultimo carattere
		# della riga non e' il numero dell'Atto: e' un uguale.
		var act: String = text.replace("=", "").strip_edges().split(" ")[-1]
		per_act[act] = int(per_act.get(act, 0)) + 1
	for act in ["1", "2", "3"]:
		assert_eq(int(per_act.get(act, 0)), 1, "un Consiglio chiude l'Atto %s" % act)


## La seconda promessa: si dibatte **il mucchio più alto**. Si scalda una
## domanda a mano fino a staccarla dalle altre, e a fine Atto dev'essere lei.
func test_the_tallest_pile_is_the_one_debated() -> void:
	new_session()
	# Il lato classico spegne il Consiglio di chiusura come spegne tutto il
	# resto: qui si riaccende, perché è proprio quello che si prova.
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	var rules: Dictionary = (chronicle["confluence_rules"] as Dictionary).duplicate()
	rules["at_end_of_act"] = true
	chronicle["confluence_rules"] = rules
	session.actions.set("_chronicle", chronicle)
	session.chronicle.set("_chronicle", chronicle)

	var hottest: String = "TEN_ROADS"
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", hottest, {"delta": 9},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	var top: int = session.tensions.value(hottest)
	for tension_id in session.world["tensions"]:
		if str(tension_id) == hottest:
			continue
		assert_true(
			session.tensions.value(str(tension_id)) < top,
			"%s è davvero il mucchio più alto" % hottest
		)

	await session.chronicle.end_of_act(1, PolicyDecider.new(session.log))
	var held: Array = []
	for result in session.chronicle.confluence_results:
		held.append(str((result as Dictionary)["tension_id"]))
	assert_eq(held, [hottest], "si dibatte il mucchio più alto, e solo quello")


## E quello che la regola toglie. Con il Consiglio a fine Atto, un round non ne
## apre più nessuno da solo: né perché una domanda ha passato la sua soglia, né
## perché il sacchetto è pieno. Resta RIVENDICARE, che è il modo di portare al
## tavolo una **seconda** domanda — e senza questa riga la regola sarebbe un
## Consiglio in più invece di un Consiglio al posto degli altri.
func test_a_round_no_longer_opens_a_council_by_itself() -> void:
	new_session()
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	var rules: Dictionary = (chronicle["confluence_rules"] as Dictionary).duplicate()
	rules["at_end_of_act"] = true
	chronicle["confluence_rules"] = rules
	session.actions.set("_chronicle", chronicle)
	session.chronicle.set("_chronicle", chronicle)

	# Una domanda ben oltre la sua soglia: nel regime di prima questo bastava.
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": 12},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_true(
		(session.tensions.tensions_at_threshold() as Array).has("TEN_FAMINE"),
		"la domanda è oltre soglia, quindi la prova non è vuota"
	)
	var before: int = session.chronicle.confluence_results.size()
	await session.chronicle._end_of_round_confluence(PolicyDecider.new(session.log))
	assert_eq(
		session.chronicle.confluence_results.size(), before,
		"il round non apre più niente da solo"
	)
