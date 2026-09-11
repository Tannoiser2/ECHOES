extends "res://tests/test_case.gd"
## **Il ricordo dice di chi è** (ISSUES 136, punto 6).
##
## Il payload dell'Eco portava `participants`, `outcome`, `tension_id` — e non
## chi aveva **ottenuto**. Misurato: le case partecipano a **4,3 Echi l'anno**
## quasi tutte uguali, quindi «c'ero» non distingueva nessuno, e il valutatore
## dei Destini attaccava lo stesso Eco come prova a tutti quanti. La Cronaca che
## la saga eredita non sapeva dire chi aveva ottenuto cosa.
##
## Le prove del ruolo girano su **Echi fabbricati**: cercare fra quelli di una
## partita un Eco vinto, uno perso e uno da spettatore vuol dire misurare la
## partita, e il giorno in cui la porta degli Echi cambia la prova smetterebbe
## di provare in silenzio. L'ultima invece gioca un anno vero, e serve a dire
## che i campi li scrive il motore e non la prova.

const DestinyEvaluator := preload("res://scripts/chronicle/destiny_evaluator.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

var _mine: RefCounted


func _table() -> RefCounted:
	if _mine != null:
		return _mine
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(_mine.setup("CHR_00", seats, 4242), "e l'anno si apre")
	return _mine


func after_each() -> void:
	super.after_each()
	if _mine != null:
		_mine.dispose()
		_mine = null


## Un Eco fabbricato: `mine` l'ha ottenuto guidando il suo lato, `friend` stava
## con lui, `foe` gli stava contro, `watcher` era al tavolo e basta.
func _an_echo(mine: String, friend: String, foe: String, watcher: String) -> Dictionary:
	return {
		"echo_id": "ECO_FINTA",
		"title": "Una cosa che il mondo ricorda",
		"summary": "Il Consiglio rispose: si (A6 B1, mucchio 2).",
		"act": 1,
		"round": 1,
		"participants": [mine, friend, foe, watcher],
		"effect_ids": [],
		"tension_id": "TEN_X",
		"outcome": "DECISIVE",
		"winning_side": "A",
		"won_by": mine,
		"won_with": [mine, friend],
		"lost_by": [foe],
	}


func _evidence_for(live: RefCounted, entity_id: String) -> String:
	var evaluator: RefCounted = DestinyEvaluator.new(live.world, live.data)
	var result: Dictionary = evaluator.evaluate(
		live.service.destiny_of(entity_id), entity_id
	)
	return " / ".join(PackedStringArray(result["evidence"] as Array))


## **Le quattro righe dicono quattro cose diverse.** Prima erano la stessa.
func test_the_evidence_says_what_you_did_in_that_council() -> void:
	var live: RefCounted = _table()
	var order: Array = live.world["turn_order"] as Array
	var mine: String = str(order[0])
	var friend: String = str(order[1])
	var foe: String = str(order[2])
	var watcher: String = str(order[3])
	(live.world["echo_log"] as Array).append(_an_echo(mine, friend, foe, watcher))
	assert_true(
		_evidence_for(live, mine).contains("l'hai ottenuta tu"),
		"chi l'ha ottenuta lo legge: %s" % _evidence_for(live, mine)
	)
	assert_true(
		_evidence_for(live, friend).contains("stavi con chi l'ha ottenuta"),
		"chi stava con lui pure"
	)
	assert_true(
		_evidence_for(live, foe).contains("ti sei opposto e hai perso"),
		"e chi ha perso legge di aver perso"
	)
	assert_true(
		_evidence_for(live, watcher).contains("eri al tavolo"),
		"chi guardava resta uno che guardava"
	)


## **Un Eco vecchio non mente.** Un salvataggio di prima di questo giro, o la
## Cronaca di un'era passata, non ha quei campi: la riga torna quella di sempre
## invece di inventarsi un vincitore.
func test_an_echo_from_before_still_reads() -> void:
	var live: RefCounted = _table()
	var mine: String = str((live.world["turn_order"] as Array)[0])
	(live.world["echo_log"] as Array).append({
		"echo_id": "ECO_VECCHIA",
		"title": "Un ricordo di prima",
		"summary": "Il Consiglio rispose: si (A6 B1, mucchio 2).",
		"act": 1,
		"round": 1,
		"participants": [mine],
		"effect_ids": [],
		"tension_id": "TEN_X",
		"outcome": "DECISIVE",
	})
	assert_true(
		_evidence_for(live, mine).contains("eri al tavolo"),
		"e dice solo quello che sa di se'"
	)


## **E i campi li scrive il motore.** Un anno vero, e ogni Eco che ha un
## vincitore lo dice per intero: la casa che ha guidato sta fra chi ha ottenuto,
## e non sta fra chi ha perso.
func test_a_played_year_writes_who_obtained_what() -> void:
	var live: RefCounted = _table()
	await live.run(PolicyDecider.new(live.log))
	var echoes: Array = live.world["echo_log"] as Array
	assert_true(echoes.size() > 0, "l'anno ha lasciato qualche Eco")
	var with_a_winner: int = 0
	for entry in echoes:
		var echo: Dictionary = entry as Dictionary
		assert_true(echo.has("won_by"), "ogni Eco porta il campo di chi ha ottenuto")
		var leader: String = str(echo["won_by"])
		if leader == "":
			# Nessuna domanda e' arrivata al mucchio: non c'e' un vincitore, e
			# inventarne uno sarebbe peggio di lasciare il campo vuoto.
			assert_true(
				(echo["won_with"] as Array).is_empty(),
				"e senza vincitore non c'e' nessuno che abbia ottenuto"
			)
			continue
		with_a_winner += 1
		assert_true(
			(echo["won_with"] as Array).has(leader),
			"chi ha guidato sta fra chi ha ottenuto"
		)
		assert_false(
			(echo["lost_by"] as Array).has(leader),
			"e non sta fra chi ha perso"
		)
		assert_true(
			(echo["participants"] as Array).has(leader),
			"e c'era, ovviamente"
		)
	assert_true(with_a_winner > 0, "e almeno un Eco ha un vincitore: %d" % with_a_winner)


## **E la Verita' permanente porta il nome.** Un registro che dice cosa il mondo
## ha deciso e non per mano di chi e' meta' verbale.
func test_the_truth_names_the_house_that_obtained_it() -> void:
	var live: RefCounted = _table()
	await live.run(PolicyDecider.new(live.log))
	var named: int = 0
	var with_a_winner: int = 0
	for entry in (live.world["echo_log"] as Array):
		if str((entry as Dictionary)["won_by"]) == "":
			continue
		with_a_winner += 1
		var expected: String = live.service.name_of(str((entry as Dictionary)["won_by"]))
		for truth in (live.world["truth_log"] as Array):
			if str((truth as Dictionary).get("echo_id", "")) != str((entry as Dictionary)["echo_id"]):
				continue
			if str((truth as Dictionary)["text"]).contains(expected):
				named += 1
	assert_true(with_a_winner > 0, "c'e' qualche Eco con un vincitore")
	assert_eq(named, with_a_winner, "e ogni Verita' porta il nome di chi l'ha ottenuta")
