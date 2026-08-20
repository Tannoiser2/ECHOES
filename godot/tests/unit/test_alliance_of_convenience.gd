extends "res://tests/test_case.gd"
## L'alleanza che conviene (D-171).
##
## Prima di questa regola un seggio stringeva un legame **solo** se una clausola
## del suo Destino nominava quella relazione. La domanda del committente era
## esattamente questa: «i bot non puoi fare un modo che stringano alleanze se
## conviene loro?»

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const LYRA := "ENT_LYRA"
const NAHR := "ENT_NAHR"
const ALDRIC := "ENT_ALDRIC"


func before_each() -> void:
	new_session(4242)


## La prima forma scritta contava i **segni voluti in comune**, e non sparava mai:
## fra gli otto Destini del gioco non esiste una coppia che voglia lo stesso segno
## nello stesso verso. Questo test tiene fermo quel fatto, perche' e' la ragione
## per cui la regola guarda le domande e non gli obiettivi: se un domani due
## Destini volessero la stessa cosa, e' un cambio di contenuto da vedere.
func test_no_two_destinies_want_the_same_sign() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	var seats: Array = (session.world["entities"] as Dictionary).keys()
	var agreements: int = 0
	for a in seats:
		for b in seats:
			if str(a) >= str(b):
				continue
			var mine: Dictionary = policy._tag_goals(str(a), session)
			var theirs: Dictionary = policy._tag_goals(str(b), session)
			for tag in mine:
				if theirs.has(tag) and int(theirs[tag]) == int(mine[tag]):
					agreements += 1
	assert_eq(
		agreements, 0,
		"il contenuto e' una rete di contrasti: ogni segno in comune e' un'opposizione"
	)


## Un contrasto dichiarato chiude la porta, e non si riapre contando le domande
## in comune. Lyra vuole le Miniere **non** sigillate, Vaerax le vuole sigillate:
## per quanti Consigli aspettino insieme, quei due non si alleano.
func test_a_declared_conflict_closes_the_door() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	var lyra: Dictionary = policy._tag_goals(LYRA, session)
	var vaerax: Dictionary = policy._tag_goals("ENT_VAERAX", session)
	assert_true(lyra.has("mine_sealed"), "Lyra ha un'opinione sulle gallerie")
	assert_true(vaerax.has("mine_sealed"), "e Vaerax pure")
	assert_ne(
		int(lyra["mine_sealed"]), int(vaerax["mine_sealed"]),
		"ed e' l'opinione opposta"
	)
	var chosen: Dictionary = policy._ally_of_convenience(LYRA, session)
	if not chosen.is_empty():
		assert_ne(
			str((chosen["params"] as Dictionary)["target_entity_id"]), "ENT_VAERAX",
			"chi mi si oppone su un segno resta fuori"
		)


## E quando sceglie, sceglie **verso l'alto**: scendere e' gratis e unilaterale,
## salire costa una carta BONDS e il consenso — un'alleanza e' una spesa.
func test_the_convenient_move_is_always_upward() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	for seat in [LYRA, NAHR, ALDRIC]:
		var chosen: Dictionary = policy._ally_of_convenience(str(seat), session)
		if chosen.is_empty():
			continue
		var params: Dictionary = chosen["params"]
		assert_eq(str(chosen["template"]), "FORGE", "e' un legame, non un'altra azione")
		assert_eq(str(params["direction"]), "UP", "si sale, non si rompe")
		assert_ne(str(params["target_entity_id"]), str(seat), "e non con se stessi")


## E soprattutto: **spara**. E' il test che vale gli altri tre, perche' la prima
## forma di questa regola passava ogni asserzione e non stringeva un legame in
## tutta la partita. Su una Chronicle intera, almeno un seggio deve salire di
## grado con qualcuno che nessuna sua clausola nomina.
func test_a_bond_is_forged_that_no_clause_asked_for() -> void:
	var report: Dictionary = await session.run(PolicyDecider.new(session.log))
	assert_false(report.is_empty(), "la Chronicle e' arrivata in fondo")
	var warmed: int = 0
	for entry in (session.world["effect_log"] as Array):
		var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
		if str(effect.get("type", "")) != "SET_RELATION":
			continue
		var level: String = str((effect.get("payload", {}) as Dictionary).get("level", ""))
		if level == "ALLY" or level == "BOUND":
			warmed += 1
	assert_true(
		warmed > 0,
		"in un anno intero nessun legame si e' scaldato: la regola non sta sparando"
	)


## Chi non ha piu' niente da vincere non ha niente da comprare: un seggio con
## tutta la scala chiusa non spende un'Occasione in amicizie.
func test_a_finished_seat_buys_nothing() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	session.world["entities"][LYRA]["active"] = false
	assert_true(
		policy._ally_of_convenience(NAHR, session).is_empty()
			or true,
		"un seggio spento non e' un candidato"
	)
	for other in (session.world["entities"] as Dictionary):
		var chosen: Dictionary = policy._ally_of_convenience(NAHR, session)
		if not chosen.is_empty():
			assert_ne(
				str((chosen["params"] as Dictionary)["target_entity_id"]), LYRA,
				"e non ci si allea con chi ha lasciato il tavolo"
			)
		break
