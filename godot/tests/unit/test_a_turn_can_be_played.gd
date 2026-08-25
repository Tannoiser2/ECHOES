extends "res://tests/test_case.gd"
## **Il turno si puo' giocare** (D-281).
##
## Il committente, aprendo l'app: *«non mi fa giocare le carte, non so quali
## azioni fare, e la GUI mi dice di trascinare una carta dove voglio usarla — in
## che senso?»*. Sotto c'erano due cose, e la prima era un difetto vero.
##
## `ask()` costruisce `_offers` — cosa porta ogni carta adesso — **dopo** aver
## chiamato `_refresh()`, che e' quello che disegna la mano. Le carte venivano
## quindi disegnate col carico vuoto, e una carta col carico vuoto non si prende
## e non si trascina: per tutta la domanda la mano era morta. Nessuna prova se
## ne accorgeva, perche' quelle sul trascinamento riempiono il carico a mano
## (test_drag_and_drop) e nessuna legava **la domanda alla mano**.
##
## La seconda: D-238 aveva tolto dalla colonna ogni scelta con un posto dove
## cadere, e quando tutte ce l'hanno la colonna resta vuota. Chi non sapeva gia'
## di dover toccare una carta si trovava davanti a un turno con niente da
## premere.
##
## Queste prove tengono il patto minimo: **quando tocca a una persona, sullo
## schermo c'e' almeno una strada visibile, e le carte che portano una mossa
## sono prendibili.**

const GameScreen := preload("res://ui/game_screen.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const AssetCard := preload("res://ui/asset_card.gd")


## **La partita della scatola, non quella di scena.**
##
## `test_case.new_session()` chiama `play_classic()`, che spegne
## `actions_from_cards`: le prove unitarie stanno sul §10 di sempre. Ma un turno
## senza carte non ha niente da dire su una mano che non si puo' giocare — la
## prima stesura di queste prove misurava proprio quello, e diceva zero. Qui la
## Chronicle si apre come e' spedita.
var _mine: RefCounted


func before_each() -> void:
	if _mine != null:
		return
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_01", 4242)
	assert_true(_mine.setup("CHR_01", seats, 4242), "e l'anno si apre")
	for effect in _mine.factory_setup_effects():
		_mine.applier.apply(effect)
	_mine.world["act"] = 1
	_mine.world["round"] = 1
	_mine.world["phase"] = "ACTIONS"
	session = _mine


func _seat() -> String:
	return str(session.world["turn_order"][0])


## Uno schermo costruito ma non avviato: `_ready()` chiamerebbe il menu, che
## chiede e aspetta. Qui serve la sola impalcatura, con dentro la partita.
func _screen(seat: String) -> Node:
	var screen: Node = GameScreen.new()
	screen.call("_build")
	screen.set("_session", session)
	screen.set("_viewer", seat)
	return screen


## La domanda vera, fatta dal decider che guida anche il terminale: cosi' quello
## che si misura e' il ponte, non una lista fabbricata qui.
func _ask_one_action(screen: Node, seat: String) -> void:
	var decider: RefCounted = SeatDecider.new([seat], null)
	decider.io = screen
	# Senza `await`: la funzione corre fino a dove lo schermo si mette in
	# attesa di una risposta, ed e' esattamente li' che vogliamo guardare.
	decider.choose_action(seat, 0, session)


func _cards_of(screen: Node) -> Array:
	var cards: Array = []
	for child in screen.get("_hand").get_children():
		if child is PanelContainer and child.has_method("_get_drag_data"):
			cards.append(child)
	return cards


func _finish(screen: Node) -> void:
	screen.emit_signal("picked", -1)
	screen.free()


## **La mano e' viva mentre la domanda e' aperta.**
##
## Almeno una carta porta il proprio carico, e quel carico e' quello che le
## regole hanno gia' approvato. E' la prova che sarebbe stata rossa il giorno
## in cui il difetto e' entrato.
func test_the_hand_is_alive_while_the_question_is_open() -> void:
	var seat: String = _seat()
	var screen: Node = _screen(seat)
	_ask_one_action(screen, seat)

	var cards: Array = _cards_of(screen)
	assert_true(cards.size() > 0, "il seggio ha delle carte in mano: %d" % cards.size())
	var alive: int = 0
	for card in cards:
		if not (card.get("offers") as Array).is_empty():
			alive += 1
			assert_ne(
				card.call("_get_drag_data", Vector2.ZERO), null,
				"e una carta che porta una mossa si prende"
			)
	assert_true(alive > 0, "almeno una carta della mano porta una mossa: %d" % alive)
	_finish(screen)


## **E lo schermo non lascia mai un turno senza una strada visibile.**
##
## O ci sono bottoni nella colonna, o c'e' una Regione accesa sulla mappa. Un
## turno in cui non si vede niente da fare e' il difetto che il committente ha
## trovato aprendo l'app, e non deve poter tornare in silenzio.
func test_a_turn_always_shows_at_least_one_way_in() -> void:
	var seat: String = _seat()
	var screen: Node = _screen(seat)
	_ask_one_action(screen, seat)

	var buttons: int = screen.get("_buttons").get_child_count()
	var lit: int = (screen.get("_map").get("highlighted") as Dictionary).size()
	assert_true(
		buttons > 0 or lit > 0,
		"c'e' qualcosa da premere: %d bottoni, %d Regioni accese" % [buttons, lit]
	)
	_finish(screen)


## **E la colonna nomina le carte che parlano adesso**, con quante mosse
## portano. E' la strada che nessuno puo' non vedere.
func test_the_column_names_the_cards_that_speak_now() -> void:
	var seat: String = _seat()
	var screen: Node = _screen(seat)
	_ask_one_action(screen, seat)

	var playable: Array = screen.call("_playable_cards")
	assert_true(playable.size() > 0, "qualche carta porta una mossa: %d" % playable.size())
	var said: Array = []
	for child in screen.get("_buttons").get_children():
		if child is Button:
			said.append(str((child as Button).text))
	var column: String = " · ".join(PackedStringArray(said))
	for asset_id in playable:
		var title: String = str((session.data.assets[str(asset_id)] as Dictionary)["title"])
		assert_true(column.contains(title), "«%s» e' nominata: %s" % [title, column])
	assert_false(column.contains("AST_"), "e mai con un id: %s" % column)
	_finish(screen)


## **Toccare la riga e' toccare la carta**: si accende quello che quella carta
## sa fare, e non si e' ancora deciso niente.
func test_touching_the_row_takes_the_card_in_hand() -> void:
	var seat: String = _seat()
	var screen: Node = _screen(seat)
	_ask_one_action(screen, seat)

	var first: String = str((screen.call("_playable_cards") as Array)[0])
	screen.call("_on_card_chosen", first)
	assert_eq(str(screen.get("_held")), first, "la carta e' in mano")
	var lit: int = (screen.get("_map").get("highlighted") as Dictionary).size()
	var buttons: int = screen.get("_buttons").get_child_count()
	assert_true(
		lit > 0 or buttons > 0,
		"e i suoi posti si vedono: %d accesi, %d in colonna" % [lit, buttons]
	)
	# Rimetterla giu' non risponde a niente: la domanda e' ancora aperta.
	screen.call("_on_card_chosen", first)
	assert_eq(str(screen.get("_held")), "", "e si rimette giu'")
	_finish(screen)


## **Il suggerimento parla il gesto che funziona col dito** (D-243, D-281).
##
## «Trascina una carta dove vuoi usarla» descrive un gesto che su un tablet non
## esiste — e che comunque non spiegava dove — ed e' la riga su cui il
## committente si e' fermato.
func test_the_hint_says_a_gesture_a_finger_can_do() -> void:
	var seat: String = _seat()
	var screen: Node = _screen(seat)
	_ask_one_action(screen, seat)

	var hint: String = str(screen.get("_hint").text)
	assert_false(hint.to_lower().contains("trascina"), "niente trascinamento: «%s»" % hint)
	assert_true(hint.to_lower().contains("tocca"), "si dice cosa toccare: «%s»" % hint)
	_finish(screen)
