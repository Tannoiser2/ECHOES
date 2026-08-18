extends Control
## La vista CONSOLE (voce 27, fase 1 — D-134): il telefono di un seggio.
##
## Pannello del seggio, mano, avvisi — tutto e solo cio' che QUEL seggio ha
## diritto di leggere. E' la ricomposizione dei pezzi che gia' disegnano per
## viewer (status_panel, hand_view), piu' la lista degli avvisi che in fase 2
## arriveranno col messaggio `say`. La vista implementa `say(text)` apposta:
## e' la meta' passiva dell'`io` di D-038 — il `choose` arriva col filo
## (fase 2), non qui.
##
## Contratto dei pannelli: `render(session, seat_id)`, nessuna scrittura.

const StatusPanel := preload("res://ui/status_panel.gd")
const HandView := preload("res://ui/hand_view.gd")

const NOTICE_TAIL: int = 6

var _header: Label = null
var _panel: Control = null
var _hand: Control = null
var _notices: VBoxContainer = null
var _said: Array = []


func _ready() -> void:
	_build()


func render(session: RefCounted, seat_id: String) -> void:
	if _header == null:
		_build()
	_header.text = session.service.name_of(seat_id)
	_panel.render(session, seat_id)
	_hand.render(session, seat_id)


## La meta' passiva dell'io (D-038): gli avvisi del decider per questo seggio
## («questa mossa spegne la tua clausola», la plancia del turno) si mostrano
## qui e non toccano mai il verbale comune.
func say(text: String) -> void:
	if text.strip_edges() == "":
		return
	_said.append(str(text))
	if _said.size() > NOTICE_TAIL:
		_said = _said.slice(_said.size() - NOTICE_TAIL)
	if _notices == null:
		return
	for child in _notices.get_children():
		child.queue_free()
		_notices.remove_child(child)
	for entry in _said:
		var line := Label.new()
		line.text = str(entry)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		line.add_theme_color_override("font_color", Color("#e8b563"))
		_notices.add_child(line)


func _build() -> void:
	if _header != null:
		return
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)
	scroll.add_child(root)

	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 18)
	root.add_child(_header)

	_notices = VBoxContainer.new()
	root.add_child(_notices)

	_panel = StatusPanel.new()
	_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_panel)

	_hand = HandView.new()
	root.add_child(_hand)
