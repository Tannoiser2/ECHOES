extends "res://tests/test_case.gd"
## **L'app mostra il tavolo, non lo stato** (ISSUES 65, la terza rivista, D-444).
##
## Fino alla 0.1.413 la mappa e i mazzetti **dipingevano**: una scritta dipinta
## non ha una misura, non e' un bersaglio, e ne' la sonda della pagina ne' un
## lettore di schermo la vedono. Queste prove tengono il patto nuovo: quello
## che sul tavolo si legge e si tocca e' un nodo — il nome di ogni tessera, la
## domanda che ci abita (un posto dove posare la carta), le parole dei segni,
## il mazzetto di ogni Tema, la casa di ogni seggio.

const MapView := preload("res://ui/map_view.gd")
const ThemeDecksView := preload("res://ui/theme_decks_view.gd")
const SeatsStrip := preload("res://ui/seats_strip.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")


func before_each() -> void:
	new_session()


func _seated(node: Control, size: Vector2) -> Control:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	tree.root.add_child(node)
	node.size = size
	return node


## **Si libera adesso, non a fine giro.** Un nodo lasciato in coda da liberare
## disegna ancora una volta prima di sparire, e a quel punto la sessione che
## guardava e' gia' stata smontata da `after_each`: un errore di script su
## una prova verde, che e' il rumore peggiore.
func _cleared(node: Control) -> void:
	node.get_parent().remove_child(node)
	node.free()


## **Ogni tessera porta il suo nome come un nodo**, e ogni domanda in gioco
## abita una tessera come un posto alto un dito.
func test_the_map_names_its_tiles_and_seats_its_questions() -> void:
	var map: Control = _seated(MapView.new(), Vector2(700, 480))
	var seat: String = str(session.world["turn_order"][0])
	map.render(session, seat)
	var names: Dictionary = map.get("_names")
	for region_id in session.world["regions"]:
		assert_true(names.has(str(region_id)), "la tessera %s ha il suo nome" % region_id)
		var label: Label = names[str(region_id)]
		assert_eq(
			label.text, str(session.data.regions[str(region_id)]["name"]),
			"e il nome e' quello stampato"
		)
	var questions: Dictionary = map.get("_questions")
	for tension_id in session.world["tensions"]:
		assert_true(questions.has(str(tension_id)), "la domanda %s ha il suo posto" % tension_id)
		var slot: Control = questions[str(tension_id)]
		assert_true(
			slot.custom_minimum_size.y >= 44.0,
			"e il posto e' alto almeno un dito (D-243): %.0f" % slot.custom_minimum_size.y
		)
		var line: Label = slot.get_child(0) as Label
		assert_true(
			line.text.begins_with(str(session.data.tensions[str(tension_id)]["title"])),
			"e dice il titolo della domanda: %s" % line.text
		)
	_cleared(map)


## **Tenere una carta accende solo la domanda dove puo' andare**, e posarla li'
## risponde — lo stesso gesto della colonna (D-239), fatto sul tavolo.
func test_holding_a_card_lights_a_question_on_the_map_and_placing_answers() -> void:
	var map: Control = _seated(MapView.new(), Vector2(700, 480))
	var seat: String = str(session.world["turn_order"][0])
	map.render(session, seat)
	var ids: Array = (session.world["tensions"] as Dictionary).keys()
	assert_true(ids.size() >= 2, "ci sono almeno due domande in tavola")
	var lit_id: String = str(ids[0])
	var other: String = str(ids[1])
	map.call("hold", {"tension:%s" % lit_id: 7})
	var questions: Dictionary = map.get("_questions")
	assert_true((questions[lit_id] as Object).get("_lit"), "il posto della domanda e' acceso")
	assert_false((questions[other] as Object).get("_lit"), "e quello dell'altra no")

	var answered: Array = []
	map.connect("card_placed", func(index: int) -> void: answered.append(index))
	var opened: Array = []
	map.connect("tension_opened", func(id: String) -> void: opened.append(id))
	var tap := InputEventMouseButton.new()
	tap.button_index = MOUSE_BUTTON_LEFT
	tap.pressed = true
	(questions[lit_id] as Node).emit_signal("gui_input", tap)
	assert_eq(answered, [7], "il tocco posa la carta e risponde")
	assert_true(opened.is_empty(), "e non apre la scheda")

	map.call("hold", {})
	assert_false((questions[lit_id] as Object).get("_lit"), "rimessa giu', il posto si spegne")
	(questions[lit_id] as Node).emit_signal("gui_input", tap)
	assert_eq(opened, [lit_id], "senza niente in mano il tocco apre la scheda")
	_cleared(map)


## **Le parole dei segni stanno sotto i pezzi, sempre**: al tavolo il cartone
## le stampa, e un dito non ha un «sopra» da cui far uscire un suggerimento.
func test_the_words_of_the_pieces_are_on_the_table() -> void:
	var map: Control = _seated(MapView.new(), Vector2(700, 480))
	var seat: String = str(session.world["turn_order"][0])
	var region_id: String = str((session.world["regions"] as Dictionary).keys()[0])
	(session.world["regions"][region_id]["tags"] as Array).append("condition:unrest")
	map.render(session, seat)
	var words: Label = (map.get("_words") as Dictionary)[region_id]
	assert_true(words.visible, "la tessera con un segno mostra la parola")
	# La parola e' quella del cartone — `SignLabels`, la stessa del catalogo
	# delle pedine — non il titolo lungo del dizionario.
	var word: String = SignLabels.label("condition:unrest", session.data)
	assert_ne(word, "", "il segno ha una parola da giocatore")
	assert_true(
		words.text.contains(word),
		"ed e' la parola italiana del segno: «%s» in «%s»" % [word, words.text]
	)
	assert_false(
		words.text.contains("condition:"), "non il segno crudo"
	)
	_cleared(map)


## **Ogni mazzetto e' un bottone col nome del Tema**, e in una striscia larga
## i sei stanno in fila.
func test_every_deck_is_a_button_and_a_strip_lays_them_in_a_row() -> void:
	var decks: Control = _seated(ThemeDecksView.new(), Vector2(720, 96))
	decks.render(session)
	var nodes: Dictionary = decks.get("_nodes")
	assert_eq(nodes.size(), 6, "sei mazzetti, sei nodi")
	assert_eq(int(decks.call("_columns")), 6, "in una striscia larga stanno in fila")
	var pressed: Array = []
	decks.connect("deck_pressed", func(id: String) -> void: pressed.append(id))
	for theme_id in nodes:
		var button: Button = (nodes[theme_id] as Dictionary)["button"]
		assert_true(
			button.size.y >= 44.0,
			"il mazzetto %s e' alto almeno un dito: %.0f" % [theme_id, button.size.y]
		)
		assert_eq(
			button.text, str(session.data.themes[str(theme_id)]["title"]).to_upper(),
			"e porta il nome del Tema"
		)
		var said: Label = (nodes[theme_id] as Dictionary)["said"]
		assert_eq(said.text, "freddo", "e a inizio anno dice che e' freddo")
	(nodes[nodes.keys()[0]] as Dictionary)["button"].emit_signal("pressed")
	assert_eq(pressed, [str(nodes.keys()[0])], "e premerlo dice quale")
	# E in un riquadro restano tre per due, come prima.
	decks.size = Vector2(320, 190)
	assert_eq(int(decks.call("_columns")), 3, "in un riquadro stanno tre per due")
	_cleared(decks)


## **Chi siede ha un posto sul tavolo**, e la carta che parla a una casa si
## posa li' — come la riga della colonna, che adesso e' una pagina.
func test_every_seat_has_a_place_on_the_table() -> void:
	var strip: Control = _seated(SeatsStrip.new(), Vector2(720, 44))
	var seat: String = str(session.world["turn_order"][0])
	strip.render(session, seat)
	var slots: Dictionary = strip.get("slots")
	for entity_id in session.world["turn_order"]:
		assert_true(slots.has("entity:%s" % entity_id), "la casa %s ha il suo posto" % entity_id)
	var other: String = str(session.world["turn_order"][1])
	strip.call("hold", {"entity:%s" % other: 3})
	assert_true((slots["entity:%s" % other] as Object).get("_lit"), "il posto della casa si accende")
	assert_false((slots["entity:%s" % seat] as Object).get("_lit"), "e il proprio no")
	var answered: Array = []
	strip.connect("card_placed", func(index: int) -> void: answered.append(index))
	var tap := InputEventMouseButton.new()
	tap.button_index = MOUSE_BUTTON_LEFT
	tap.pressed = true
	(slots["entity:%s" % other] as Node).emit_signal("gui_input", tap)
	assert_eq(answered, [3], "e posare la carta li' risponde")
	_cleared(strip)
