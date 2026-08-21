extends "res://tests/test_case.gd"
## La sonda delle viste (voce 27, fase 1 — D-134): il tavolo mostra il tavolo,
## la console mostra il seggio. I modelli di vista sono i futuri messaggi di
## rete (fase 2): se un segreto non entra nel modello, non potra' entrare nel
## filo — la disciplina si prova qui, serializzando e cercando.

const TableModel := preload("res://scripts/views/table_model.gd")
const ConsoleModel := preload("res://scripts/views/console_model.gd")
const Protocol := preload("res://scripts/net/console_protocol.gd")
const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return Effect.source("test", "TEST", "", 1, 1, 0)


## La domanda coperta mostra il dorso al tavolo — anche se un seggio l'ha
## sbirciata con lo SCHEME: il numero vive solo sulla console di chi sa.
func test_the_veiled_question_shows_its_back_to_the_table() -> void:
	# La DataSet e' condivisa: si prova la regola vecchia e la si rimette.
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	var before_rule: String = str(chronicle.get("veiled_tensions", ""))
	chronicle["veiled_tensions"] = "HIDES_ALL"
	var seats: Array = session.world["turn_order"]
	var scout: String = str(seats[0])
	var blind: String = str(seats[1])
	session.applier.apply(Effect.make(
		"SET_TENSION_VISIBILITY", "tension", "TEN_FAMINE", {"visibility": "VEILED"}, _source()
	))
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", scout,
		{"tag": Ids.knows_tension_tag("TEN_FAMINE")}, _source()
	))
	var real: int = session.tensions.value("TEN_FAMINE")

	var table: Dictionary = TableModel.build(session)
	var covered: int = -2
	for tension in table["tensions"]:
		if str((tension as Dictionary)["title"]) == "La Carestia":
			covered = int((tension as Dictionary)["value"])
	assert_eq(covered, -1, "il tavolo vede il dorso della domanda coperta")

	var knowing: Dictionary = ConsoleModel.build(session, scout)
	var unknowing: Dictionary = ConsoleModel.build(session, blind)
	var seen: int = -2
	var hidden: int = -2
	for tension in knowing["tensions"]:
		if str((tension as Dictionary)["title"]) == "La Carestia":
			seen = int((tension as Dictionary)["value"])
	for tension in unknowing["tensions"]:
		if str((tension as Dictionary)["title"]) == "La Carestia":
			hidden = int((tension as Dictionary)["value"])
	assert_eq(seen, real, "chi ha sbirciato legge il numero sulla sua console")
	assert_eq(hidden, -1, "chi non sa vede il dorso anche sulla propria")
	chronicle["veiled_tensions"] = before_rule


## Il modello del tavolo, serializzato e perquisito: nessuna carta di nessuna
## mano, nessun gradino di nessun Destino. Se non sta nel modello, non potra'
## stare nel messaggio.
func test_the_table_model_carries_no_seat_secrets() -> void:
	var stringified: String = JSON.stringify(TableModel.build(session))
	for entity_id in session.world["turn_order"]:
		for asset_id in session.service.hand(str(entity_id)):
			var title: String = str(session.data.assets[str(asset_id)]["title"])
			assert_false(
				stringified.contains(title),
				"la mano di %s non sta sul tavolo («%s»)" % [str(entity_id), title]
			)
		var destiny: Dictionary = session.data.destinies[
			session.service.destiny_of(str(entity_id))
		]
		for level in ["minimum", "victory", "triumph"]:
			assert_false(
				stringified.contains(str(destiny[level]["label"])),
				"il Destino di %s non sta sul tavolo" % str(entity_id)
			)


## E nemmeno le carte del Narratore in mano (D-144). Questo test e' nato da una
## fuga vera: la vetrina leggeva `echo_deck.drawn` — tutto cio' che il mazzo ha
## lasciato — e la chiamava «il mondo ha calato», mentre meta' di quelle carte
## erano ancora nelle mani dei seggi. Il test sopra non poteva prenderla:
## cercava i titoli degli **Asset**, e le carte di Propp sono un altro mazzo.
func test_the_narrator_hands_are_not_on_the_table() -> void:
	var seat: String = str(session.world["turn_order"][0])
	# La mano del Narratore si riempie a inizio Atto; qui la si mette a mano e
	# si finge che la carta venga dal mazzo, che e' esattamente lo stato in cui
	# la vetrina la svelava.
	var card_id: String = "ECH_LACK"
	(session.world["entities"][seat]["echo_hand"] as Array).append(card_id)
	(session.world["echo_deck"]["drawn"] as Array).append(card_id)
	var hand: Array = (session.world["entities"][seat] as Dictionary).get("echo_hand", [])
	assert_true(hand.size() > 0, "il seggio deve avere carte del Narratore in mano")
	var model: Dictionary = TableModel.build(session)
	var stringified: String = JSON.stringify(model)
	for held in hand:
		var title: String = str(session.data.echo_cards[str(held)]["title"])
		assert_false(
			stringified.contains(title),
			"«%s» e in mano a %s: il tavolo non la nomina" % [title, seat]
		)
	assert_true(
		Protocol.audit_table({"kind": "table", "model": model}, session).is_empty(),
		"la perquisizione della vetrina non trova niente"
	)


## E la perquisizione della vetrina morde davvero: se una carta in mano finisce
## fra le calate, deve dirlo. Una guardia che non ha mai detto di no non si sa
## se funziona.
func test_the_table_audit_catches_a_planted_leak() -> void:
	var seat: String = str(session.world["turn_order"][0])
	var card_id: String = "ECH_LACK"
	(session.world["entities"][seat]["echo_hand"] as Array).append(card_id)
	var model: Dictionary = TableModel.build(session)
	(model["echoes_played"] as Array).append({
		"id": card_id, "title": str(session.data.echo_cards[card_id]["title"]),
	})
	var found: Array = Protocol.audit_table({"kind": "table", "model": model}, session)
	assert_eq(found.size(), 1, "una carta piantata, una fuga trovata")


## La console di un seggio contiene i SUOI segreti e nessuno di quelli altrui.
func test_a_console_holds_only_its_own_seat() -> void:
	var seats: Array = session.world["turn_order"]
	var mine: String = str(seats[0])
	var theirs: String = str(seats[1])
	var model: Dictionary = ConsoleModel.build(session, mine)
	var stringified: String = JSON.stringify(model)

	var my_destiny: Dictionary = session.data.destinies[session.service.destiny_of(mine)]
	assert_true(
		stringified.contains(str(my_destiny["title"])),
		"la console porta il Destino del suo seggio"
	)
	assert_eq(
		(model["hand"] as Array).size(), session.service.hand(mine).size(),
		"e tutta la sua mano"
	)

	var their_destiny: Dictionary = session.data.destinies[session.service.destiny_of(theirs)]
	assert_false(
		stringified.contains(str(their_destiny["title"])),
		"il Destino altrui non entra in questa console"
	)
	for asset_id in session.service.hand(theirs):
		var title: String = str(session.data.assets[str(asset_id)]["title"])
		if _also_in_my_hand(title, mine):
			continue
		assert_false(
			stringified.contains(title),
			"la mano altrui non entra in questa console («%s»)" % title
		)


func _also_in_my_hand(title: String, mine: String) -> bool:
	for asset_id in session.service.hand(mine):
		if str(session.data.assets[str(asset_id)]["title"]) == title:
			return true
	return false


## Le viste guardano e basta: costruire i modelli non muove il mondo.
func test_the_views_read_without_moving_the_world() -> void:
	var before: String = str(session.world)
	TableModel.build(session)
	for entity_id in session.world["turn_order"]:
		ConsoleModel.build(session, str(entity_id))
	assert_eq(str(session.world), before, "solo lettura, come i pannelli")


## Le due viste compilano e si disegnano (il debito di 0.1.60, pagato anche
## qui): la vetrina col suo dettaglio d'ispezione, la console col suo say.
func test_the_two_views_draw_side_by_side() -> void:
	var table: Control = preload("res://ui/table_view.gd").new()
	table.render(session)
	table._on_region_clicked("REG_VALLE_VERDE")
	assert_true(
		str(table._detail.text).contains("Valle Verde"),
		"l'ispezione racconta la Regione toccata"
	)
	table.free()

	var console: Control = preload("res://ui/console_view.gd").new()
	var seat: String = str(session.world["turn_order"][0])
	console.render(session, seat)
	console.say("  ⚠ Questa mossa spegne: una clausola di prova")
	assert_true(console._said.size() == 1, "l'avviso resta sulla console")
	console.free()
