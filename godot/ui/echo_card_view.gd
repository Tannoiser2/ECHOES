extends PanelContainer
## The Act-end Echo card, as a card.
##
## One is drawn at the end of every Act from the pool that Act allows - Act I
## only PRESSURE, Act III mostly RESOLUTION - so the shape of a story is in the
## deck rather than in a narrator's head (§15). Each one is a function of Propp,
## it moves the world, and two of the twenty-four force a Council on the spot.
##
## Until 0.1.7 the whole of that was a title and a paragraph scrolling past in
## the transcript. Three times a Chronicle the story turns, and a player saw the
## turn only if they happened to be reading the log (D-044).
##
## Same seam as the rest of `ui/`: it is handed a card and the Effects that were
## already applied, and it draws them. It decides nothing and applies nothing.

const EffectText := preload("res://scripts/core/effect_text.gd")

## The four dramatic families, and what each one is for. Colour first, because
## across three Acts the colour is the thing a player learns to read.
const FAMILIES: Dictionary = {
	"PRESSURE": {"colour": "#c9a86a", "label": "PRESSIONE — qualcosa si accumula"},
	"RUPTURE": {"colour": "#c8553d", "label": "ROTTURA — qualcosa si spezza"},
	"TURN": {"colour": "#7fa6c9", "label": "SVOLTA — qualcosa cambia direzione"},
	"RESOLUTION": {"colour": "#6fa88a", "label": "RISOLUZIONE — qualcosa si chiude"},
}

## Propp's functions have English names in the data because that is where the
## morphology comes from; the table reads Italian. A name missing from here
## still shows - as the id - rather than disappearing.
const FUNCTIONS: Dictionary = {
	"LACK": "mancanza", "OMEN": "presagio", "BETRAYAL": "tradimento", "LOSS": "perdita",
	"DISCOVERY": "scoperta", "REVELATION": "rivelazione", "SACRIFICE": "sacrificio",
	"RECONCILIATION": "riconciliazione", "PROHIBITION": "divieto", "THREAT": "minaccia",
	"USURPATION": "usurpazione", "ATTACK": "attacco", "GIFT": "dono",
	"TRANSFORMATION": "trasformazione", "LIBERATION": "liberazione", "RETURN": "ritorno",
	"REQUEST": "richiesta", "TEMPTATION": "tentazione", "VIOLATION": "violazione",
	"SEPARATION": "separazione", "ENCOUNTER": "incontro", "CONQUEST": "conquista",
	"PUNISHMENT": "punizione", "SUCCESSION": "successione",
}

signal picked(index: int)

var _family: Label
var _title: Label
var _function: Label
var _body: Label
var _did_title: Label
var _did: VBoxContainer
var _button: Button
var _frame: StyleBoxFlat


func _ready() -> void:
	_frame = StyleBoxFlat.new()
	_frame.bg_color = Color("#16130f")
	_frame.set_border_width_all(2)
	_frame.set_corner_radius_all(6)
	_frame.content_margin_left = 28
	_frame.content_margin_right = 28
	_frame.content_margin_top = 22
	_frame.content_margin_bottom = 22
	add_theme_stylebox_override("panel", _frame)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	add_child(box)

	_family = _label(12, "#8a8172")
	box.add_child(_family)
	_title = _label(26, "#efe7d8")
	box.add_child(_title)
	_function = _label(12, "#8a8172")
	box.add_child(_function)
	_body = _label(15, "#c9bfae")
	box.add_child(_body)

	var rule := ColorRect.new()
	rule.color = Color("#3a332a")
	rule.custom_minimum_size = Vector2(0, 1)
	box.add_child(rule)

	_did_title = _label(12, "#8a8172")
	box.add_child(_did_title)
	_did = VBoxContainer.new()
	_did.add_theme_constant_override("separation", 3)
	box.add_child(_did)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	_button = Button.new()
	_button.text = "Avanti"
	_button.custom_minimum_size = Vector2(180, 40)
	# Narrow and to the left: a full-width bar at the bottom of a card reads as
	# page furniture, and this is a thing you press.
	_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_button.pressed.connect(func() -> void: picked.emit(0))
	box.add_child(_button)


func _label(font_size: int, colour: String) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(colour))
	return label


## `applied` is what the card did, already done. Drawing it beside the card is
## the whole point: a paragraph about a betrayal means nothing until you can see
## that it pushed the Succession up by one and put a Scar in the Valley.
func render(card: Dictionary, applied: Array, data: RefCounted) -> void:
	var family: String = str(card["dramatic_family"])
	var described: Dictionary = FAMILIES.get(family, {"colour": "#8a8172", "label": family})
	_frame.border_color = Color(str(described["colour"]))
	_family.text = str(described["label"])
	_family.add_theme_color_override("font_color", Color(str(described["colour"])))
	_title.text = str(card["title"])
	var function_id: String = str(card["function_id"])
	_function.text = "funzione di Propp: %s" % str(FUNCTIONS.get(function_id, function_id.to_lower()))
	_body.text = str(card["description"])
	# Two of the twenty-four convene a Council on the spot (§12.1 b): that is the
	# card taking the table over, and it should not arrive as a surprise.
	var forced: Variant = card.get("forces_confluence_on", null)
	if forced != null and data.tensions.has(str(forced)):
		_body.text += "\n\nQuesta carta convoca un Consiglio su %s." % str(
			data.tensions[str(forced)]["title"]
		)

	for child in _did.get_children():
		child.queue_free()
		_did.remove_child(child)
	var lines: Array = EffectText.lines(applied, data)
	_did_title.text = "COSA HA CAMBIATO" if not lines.is_empty() else ""
	for line in lines:
		var entry := _label(13, "#c9bfae")
		entry.text = "· %s" % str(line)
		_did.add_child(entry)


## Suspend until the card has been looked at.
func wait() -> void:
	_button.grab_focus()
	await picked
