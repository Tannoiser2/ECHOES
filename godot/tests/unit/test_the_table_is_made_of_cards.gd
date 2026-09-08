extends "res://tests/test_case.gd"
## **La pagina e' fatta di carte** (D-473, parola del committente: *«troppo
## testo app e poco fedele al gioco fisico che dovrebbe prevedere solo
## Carte»*).
##
## Due pezzi, e sono i due che il committente ha nominato:
##
## - la **colonna delle domande** e' fatta di sei carte, una per Tema, con la
##   faccia stampata della Tensione — *«la colonna delle tensioni potrebbe
##   essere fatta a sei schede (come le carte)»*;
## - la **carta che si guarda** sta a destra, grande — *«sulla destra vorrei
##   proprio la carta visualizzata»*.
##
## Le facce sono quelle di `CardFace`, cioe' le stesse che vanno in stampa: se
## un giorno la carta a schermo e la carta stampata divergono, e' perche'
## qualcuno le ha scritte due volte, e queste prove lo vedono.

const QuestionColumn := preload("res://ui/question_column.gd")
const FaceCard := preload("res://ui/face_card.gd")
const GameScreen := preload("res://ui/game_screen.gd")


func before_each() -> void:
	new_session()


func _column() -> Node:
	var column: Node = QuestionColumn.new()
	column.render(session, str(session.world["turn_order"][0]))
	return column


func _cards_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is FaceCard and (child as Control).visible:
			into.append(child)
		_cards_of(child, into)


## Una carta per domanda in gioco, e ognuna porta la sua faccia: non una riga
## col titolo, ma la carta.
func test_every_question_in_play_is_a_card() -> void:
	var column: Node = _column()
	var cards: Array = []
	_cards_of(column, cards)
	assert_eq(
		cards.size(), (session.world["tensions"] as Dictionary).size(),
		"una carta per ogni domanda sul tavolo"
	)
	var shown: Array = []
	for card in cards:
		shown.append(str((card as Node).get("shown_id")))
	for tension_id in session.world["tensions"]:
		assert_true(
			shown.has(str(tension_id)),
			"la domanda %s e' una delle carte" % str(tension_id)
		)
	column.free()


## E la carta e' la faccia stampata: il titolo che si legge sul cartone.
func test_the_card_says_what_the_printed_one_says() -> void:
	var column: Node = _column()
	var cards: Array = []
	_cards_of(column, cards)
	assert_false(cards.is_empty(), "ci sono carte da leggere")
	var said: Array = []
	_labels_of(column, said)
	var page: String = " · ".join(PackedStringArray(said))
	for tension_id in session.world["tensions"]:
		var title: String = str(session.data.tensions[str(tension_id)]["title"])
		assert_true(page.contains(title), "«%s» si legge sulla sua carta" % title)
	column.free()


## **La colonna e' un posto, non un elenco**: ogni carta accetta ancora la
## carta della mano che ci arriva, che e' quello che D-231 aveva aperto.
func test_each_card_is_still_a_place_where_a_card_lands() -> void:
	var column: Node = _column()
	var places: Dictionary = column.get("slots")
	for tension_id in session.world["tensions"]:
		assert_true(
			places.has("tension:%s" % str(tension_id)),
			"sulla carta di %s si posa una carta della mano" % str(tension_id)
		)
	column.free()


## **La carta che si guarda sta a destra, grande.** Toccare una domanda ce la
## mette; toccarla di nuovo la rimette giu'. E' il gesto di prendere in mano la
## carta girata di un mazzetto.
func test_touching_a_question_puts_its_card_on_the_right() -> void:
	var screen: Node = GameScreen.new()
	screen.call("_build")
	screen.set("_session", session)
	screen.set("_viewer", str(session.world["turn_order"][0]))
	var tension_id: String = str(session.world["tensions"].keys()[0])

	var looked: Control = screen.get("_look")
	assert_false(looked.visible, "prima di guardare, il posto e' vuoto")

	screen.call("_on_tension_opened", tension_id)
	assert_true(looked.visible, "la carta toccata si vede a destra")
	assert_eq(
		str(looked.get("shown_id")), tension_id,
		"ed e' proprio quella domanda"
	)

	screen.call("_on_tension_opened", tension_id)
	assert_false(looked.visible, "toccarla di nuovo la rimette giu'")
	screen.free()


func _labels_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label:
			into.append(str((child as Label).text))
		_labels_of(child, into)
