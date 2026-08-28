extends "res://tests/test_case.gd"
## Il cancello del tavolo (D-203), scelta **b** del committente.
##
## «Una soglia sola per il tavolo, non una per domanda»: il Consiglio si apre
## quando sono scesi tanti gettoni **in tutto**, e a dibattersi va **il mucchio
## più alto** — non la domanda che ha superato la propria soglia.
##
## Quattro cose vanno provate, e la quarta è quella che tiene onesta la regola:
## che una Chronicle senza il cancello continui a decidere a soglie come sempre.

const GATE: int = 3


func before_each() -> void:
	new_session()


func _with_gate(gate: int = GATE) -> Dictionary:
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	chronicle["tension_tokens"] = {
		"per_action": 1, "replaces_drift": true, "table_gate": gate
	}
	session.actions.set("_chronicle", chronicle)
	return chronicle


func _heat(tension_id: String, by: int) -> void:
	(session.world["tensions"][tension_id] as Dictionary)["current_value"] = by


## Finché i gettoni non arrivano al cancello non si apre niente, per quanto
## alta sia una singola domanda: è tutto il punto della scelta b.
func test_a_hot_question_alone_does_not_open_a_council() -> void:
	_with_gate()
	_heat("TEN_FAMINE", 99)
	session.world["tokens_in_bag"] = GATE - 1
	assert_true(
		session.tensions.tensions_at_threshold().is_empty(),
		"con %d gettoni su %d non si apre, anche con una domanda a 99" % [GATE - 1, GATE]
	)


## Arrivati al cancello si apre, e la domanda è il mucchio più alto.
func test_at_the_gate_the_tallest_pile_is_the_question() -> void:
	_with_gate()
	_heat("TEN_FAMINE", 2)
	_heat("TEN_AWAKENING", 5)
	session.world["tokens_in_bag"] = GATE
	var ready: Array = session.tensions.tensions_at_threshold()
	assert_eq(ready.size(), 1, "il cancello apre un Consiglio solo")
	assert_eq(str(ready[0]), "TEN_AWAKENING", "e la domanda è il mucchio più alto")
	assert_eq(str(session.tensions.hottest_pile()), "TEN_AWAKENING", "che è quello che dice la sonda")
	# E se il mucchio cambia, cambia la domanda: non c'è nessuna soglia di mezzo.
	_heat("TEN_FAMINE", 9)
	assert_eq(
		str((session.tensions.tensions_at_threshold() as Array)[0]), "TEN_FAMINE",
		"il mucchio più alto è la domanda, e basta"
	)


## La soglia della singola domanda non apre più niente, quindi non si stampa:
## una persona che legge «4/7» aspetterebbe il sette, e il sette non succede.
func test_the_dead_threshold_is_never_shown() -> void:
	_with_gate()
	_heat("TEN_FAMINE", 4)
	var status: String = session.tensions.public_status("TEN_FAMINE")
	assert_false(status.contains("/"), "il verbale non promette una soglia: «%s»" % status)
	assert_true(status.contains("4"), "ma dice quanto è alto il mucchio: «%s»" % status)
	assert_eq(
		session.service.visible_tension_threshold("TEN_FAMINE", "ENT_ALDRIC"), -1,
		"e chi chiede la soglia riceve «coperta», così nessun pannello la scrive"
	)
	# Il mucchio più alto si vede che è il più alto: è l'informazione che conta.
	_heat("TEN_AWAKENING", 9)
	assert_true(
		session.tensions.public_status("TEN_AWAKENING").contains("il più alto"),
		"il mucchio più alto è segnalato"
	)
	assert_false(
		session.tensions.public_status("TEN_FAMINE").contains("il più alto"),
		"e gli altri no"
	)


## La guardia che tiene onesta la regola: senza il cancello si decide a soglie
## come si è sempre fatto, e la soglia torna visibile.
func test_without_the_gate_the_thresholds_decide_as_always() -> void:
	# `new_session` parte dal lato classico, che spegne il sacchetto.
	assert_eq(session.tensions.table_gate(), 0, "il lato classico non ha cancello")
	_heat("TEN_FAMINE", 99)
	session.world["tokens_in_bag"] = 0
	assert_true(
		(session.tensions.tensions_at_threshold() as Array).has("TEN_FAMINE"),
		"una domanda oltre la sua soglia apre il Consiglio, senza nessun gettone"
	)
	assert_true(
		session.tensions.public_status("TEN_FAMINE").contains("/"),
		"e la soglia si stampa, perché lì decide ancora lei"
	)


## E i dati spediti **non** dichiarano piu' il cancello: il Consiglio si tiene a
## fine Atto (D-214), e due gettoni nel sacchetto non lo fanno piu' partire.
##
## Il meccanismo del cancello resta nel motore e resta provato qui sopra —
## spegnerlo cancellando il codice vorrebbe dire buttare via una regola che una
## Chronicle puo' ancora dichiarare. Quello che cambia e' cosa dichiarano i dati
## spediti, ed e' quello che questa prova guarda: se domani qualcuno riaccende
## il cancello **insieme** al Consiglio di fine Atto, il gioco avrebbe due
## rubinetti sullo stesso Consiglio e lo si saprebbe qui.
func test_the_shipped_chronicles_hold_the_council_at_the_end_of_the_act() -> void:
	var shipped: RefCounted = DataSet.new()
	shipped.load_from("res://data")
	for chronicle_id in shipped.chronicles:
		var chronicle: Dictionary = shipped.chronicles[str(chronicle_id)] as Dictionary
		var closing: bool = bool(
			(chronicle.get("confluence_rules", {}) as Dictionary).get("at_end_of_act", false)
		)
		assert_true(closing, "%s tiene il Consiglio a fine Atto" % chronicle_id)
		var rules: Dictionary = chronicle.get("tension_tokens", {}) as Dictionary
		if rules.is_empty():
			continue
		assert_eq(
			int(rules.get("table_gate", 0)), 0,
			"%s non tiene anche il cancello: sarebbero due rubinetti" % chronicle_id
		)
		assert_eq(
			int(rules.get("threshold_bonus", 0)), 0,
			"%s non ritocca più una soglia che non apre niente" % chronicle_id
		)
