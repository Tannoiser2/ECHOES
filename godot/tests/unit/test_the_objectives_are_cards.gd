extends "res://tests/test_case.gd"
## **I tre Obiettivi sono tre carte** (D-473, parola del committente: *«La
## scheda Obiettivi ha anche informazioni ripetute (chi sei cosa vuoi), mentre
## dovrebbero esserci le tre carte obiettivo pescate che ti danno punti alla
## fine della chronicle»*).
##
## Le carte c'erano gia' — si pescano per saga (D-237), stanno in
## `entities[id].objectives`, e le diciannove del mazzo si stampano dai fogli —
## ma la scheda le scriveva come tre righe di testo sotto il Destino.
##
## Queste prove pretendono tre cose: che le carte ci siano, che siano **quelle
## pescate da questo seggio**, e che il Destino non si conti fra loro (ha il
## suo tarocco, e sarebbe il quarto doppione).

const StatusPanel := preload("res://ui/status_panel.gd")
const FaceCard := preload("res://ui/face_card.gd")

## Il seggio guardato, e i tre obiettivi che gli sono stati dati.
var _seat: String = ""


func before_each() -> void:
	new_session()
	_seat = str(session.world["turn_order"][0])


## **Fabbricati, non cercati**: la Chronicle di prova non dichiara `objectives`,
## e una prova che cercasse tre obiettivi fra i dati spediti smetterebbe di
## provare il giorno in cui la regola cambia. Qui si scrivono a mano tre
## obiettivi veri sul seggio, e si accende la regola che li fa contare.
func _deal_three() -> Array:
	var ids: Array = []
	for objective_id in session.data.objectives:
		ids.append(str(objective_id))
	ids.sort()
	var three: Array = ids.slice(0, 3)
	(session.world["entities"][_seat] as Dictionary)["objectives"] = three.duplicate()
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	chronicle["objectives"] = {"hidden": 3, "public_from": "victory"}
	return three


func after_each() -> void:
	# La Chronicle di prova e' condivisa: la regola accesa qui si spegne.
	var chronicle: Dictionary = data().chronicles["CHR_TEST"] as Dictionary
	chronicle.erase("objectives")
	super.after_each()


func _goals_panel() -> Node:
	var panel: Node = StatusPanel.new()
	panel.set("only_goals", true)
	panel.render(session, _seat)
	return panel


func _cards_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is FaceCard and (child as Control).visible:
			into.append(child)
		_cards_of(child, into)


func test_the_three_drawn_objectives_are_drawn_as_cards() -> void:
	var three: Array = _deal_three()
	assert_eq(three.size(), 3, "il seggio ha tre obiettivi da mostrare")
	var panel: Node = _goals_panel()
	var cards: Array = []
	_cards_of(panel, cards)
	assert_eq(cards.size(), 3, "e sulla scheda ci sono tre carte")
	var said: Array = []
	_titles_of(panel, said)
	var page: String = " · ".join(PackedStringArray(said))
	for objective_id in three:
		var title: String = str(session.data.objectives[str(objective_id)]["title"])
		assert_true(page.contains(title), "la carta «%s» si legge sulla scheda" % title)
	panel.free()


## Il Destino ha gia' il suo tarocco grande: se comparisse anche fra le carte
## sarebbe il doppione che questo giro sta togliendo.
func test_the_destiny_is_not_one_of_the_three() -> void:
	_deal_three()
	var panel: Node = _goals_panel()
	var cards: Array = []
	_cards_of(panel, cards)
	var destiny_id: String = session.service.destiny_of(_seat)
	for card in cards:
		assert_ne(
			str((card as Node).get("shown_id")), destiny_id,
			"il Destino non e' una delle tre carte Obiettivo"
		)
	assert_eq(cards.size(), 3, "restano tre, non quattro")
	panel.free()


## Senza obiettivi dichiarati la scheda non inventa carte: si torna ai tre
## gradini del Destino, che e' quello che una Chronicle senza la regola ha.
func test_without_objectives_no_cards_are_invented() -> void:
	var panel: Node = _goals_panel()
	var cards: Array = []
	_cards_of(panel, cards)
	assert_eq(cards.size(), 0, "nessuna carta Obiettivo dove la regola non c'e'")
	panel.free()


func _titles_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label:
			into.append(str((child as Label).text))
		_titles_of(child, into)
