extends "res://tests/test_case.gd"
## **Il tabellone del Consiglio mostra la carta girata** (D-291, taglio 1).
##
## Parola del committente davanti all'app: *«il Concilio e' ancora quello
## vecchio, mi sa che va cambiato tutto»*. Aveva ragione su quello che vedeva:
## lo schermo disegnava la carta, la Domanda, la Proposta, le pose e le
## Conseguenze — cioe' **solo la meta' vecchia**. Dei benefici comprati, del
## prezzo dovuto, della pedina posata dal fronte avverso e della controproposta
## (D-267, D-268, D-280) non mostrava niente, mentre il motore li eseguiva.
##
## Un'economia che gira e non si vede non e' un'economia: e' un conto che fa
## qualcun altro. Queste prove tengono le due liste sullo schermo.

const ConfluenceBoard := preload("res://ui/confluence_board.gd")

const TENSION: String = "TEN_FAMINE"


func before_each() -> void:
	new_session()


func _voices(list_name: String) -> Array:
	var out: Array = []
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
		out.append(str((voice as Dictionary)["id"]))
	return out


func _text_of(list_name: String, voice_id: String) -> String:
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			return str((voice as Dictionary)["text"])
	return ""


func _open() -> void:
	session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	var options: Array = session.confluence.available_propositions()
	session.confluence.set_proposition(str(options[0]["id"]))


func _drawn() -> Array:
	var board: Node = ConfluenceBoard.new()
	board.render(session, str(session.world["turn_order"][0]))
	var said: Array = []
	_labels_of(board, said)
	board.free()
	return said


func _labels_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label and (child as Label).visible:
			into.append(str((child as Label).text))
		_labels_of(child, into)


## Le due liste della carta stanno sul tabellone, tutte e due intere.
func test_the_board_draws_both_lists() -> void:
	_open()
	var column: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(column.contains("COSA SI COMPRA"), "la lista dei benefici c'e': %s" % column)
	assert_true(column.contains("IN CHE MONETA"), "e quella dei costi")
	for voice_id in _voices("benefits"):
		assert_true(
			column.contains(_text_of("benefits", str(voice_id))),
			"il beneficio «%s» si legge" % str(voice_id)
		)
	for voice_id in _voices("costs"):
		assert_true(
			column.contains(_text_of("costs", str(voice_id))),
			"il costo «%s» si legge" % str(voice_id)
		)


## **La pedina comprata si vede posata**, e il prezzo e' in cifre: e' la riga
## che rende il Consiglio una decisione invece di un menu.
func test_what_the_proponent_bought_is_marked() -> void:
	_open()
	var benefits: Array = _voices("benefits")
	assert_true(session.confluence.set_benefits(benefits.slice(0, 2)), "compra due benefici")
	var drawn: Array = _drawn()
	var column: String = " · ".join(PackedStringArray(drawn))
	assert_true(column.contains("2 comprati, prezzo: 1 costo"), "il conto e' scritto: %s" % column)
	var marked: int = 0
	for line in drawn:
		if str(line).begins_with("●"):
			marked += 1
	assert_eq(marked, 2, "e due pedine sono posate, non una lista puntata")
	for i in range(2):
		assert_true(
			drawn.has("● %s" % _text_of("benefits", str(benefits[i]))),
			"la pedina sta sulla voce comprata"
		)


## Chi sceglie la moneta si legge per nome — e finche' non ha scelto, lo
## schermo dice **che sta aspettando lui**, invece di tacere.
func test_the_board_says_who_chooses_the_currency() -> void:
	_open()
	session.confluence.set_benefits(_voices("benefits").slice(0, 2))
	var waiting: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(
		waiting.contains("non ha ancora posato la pedina"),
		"si aspetta il fronte avverso: %s" % waiting
	)
	var proponent: String = str(session.confluence.current["proponent"])
	for entity_id in session.confluence.stance_order():
		if str(entity_id) != proponent:
			session.confluence.declare_stance(str(entity_id), "OPPOSE")
	var opposer: String = session.confluence.first_opposer()
	assert_true(opposer != "", "c'e' un fronte avverso")
	var cost: String = str(_voices("costs")[1])
	assert_true(session.confluence.place_price(opposer, cost, ""), "posa la pedina")
	var drawn: Array = _drawn()
	var column: String = " · ".join(PackedStringArray(drawn))
	assert_true(
		column.contains("la sceglie %s" % session.service.name_of(opposer)),
		"e adesso si sa chi l'ha scelta: %s" % column
	)
	assert_true(
		drawn.has("● %s" % _text_of("costs", cost)),
		"con la pedina sulla voce che ha scelto"
	)


## Senza niente comprato non si paga, e lo schermo lo dice invece di lasciare
## una lista di costi senza spiegazione.
func test_nothing_bought_nothing_paid() -> void:
	_open()
	session.confluence.set_benefits([])
	var column: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(
		column.contains("niente da pagare"),
		"lo schermo dice perche' i costi sono spenti: %s" % column
	)


## E cosa succede se cade: e' l'informazione che rende «opponiti» una scelta e
## non un gesto. La carta ce l'ha stampata, e nessuno la sceglie.
func test_the_board_says_what_happens_if_it_falls() -> void:
	_open()
	var column: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(column.contains("SE CADE"), "c'e' la terza lista: %s" % column)
	for voice in (data().tensions[TENSION]["physical"]["failure"] as Array):
		assert_true(
			column.contains(str((voice as Dictionary)["text"])),
			"e si legge intera"
		)
