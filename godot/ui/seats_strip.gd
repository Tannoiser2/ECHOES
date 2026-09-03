extends HBoxContainer
## **Chi siede al tavolo**, in una striscia sotto la mappa (D-444, ISSUES 65).
##
## Al tavolo vero le case stanno **intorno** alla plancia: quando una carta
## parla a un'altra casa — FORGIARE — la posi davanti a chi siede li'. Sullo
## schermo quel posto era una riga della colonna di stato, dentro un pannello
## che scorreva; con la colonna diventata una pagina a parte (D-444) la casa
## deve avere il suo posto **sul tavolo**, e questo e' quel posto.
##
## Stesso contratto dei pannelli: `render(session, viewer_id)` e nient'altro.
## Non decide niente: accetta una carta esattamente quando quella carta porta
## una scelta per quella casa, e le scelte gliele ha gia' passate chi chiede
## (D-039). Ogni posto e' un `DropSlot` come le righe di D-231, alto come un
## dito (D-243).

const DropSlot := preload("res://ui/drop_slot.gd")

## I cinque livelli di un rapporto, col loro colore: gli stessi della colonna.
const RELATIONS: Dictionary = {
	"HOSTILE": "#c8553d", "COLD": "#c99a4e", "NEUTRAL": "#8a8172",
	"WARM": "#6fa88a", "ALLY": "#7fa6c9",
}

## Gli stessi colori dei seggi della mappa, per ordine di turno (D-050).
const SEAT_COLOURS: Array = ["#e8b563", "#6fa88a", "#7fa6c9", "#b06b8f", "#c8a86b", "#7f9a8b"]

## `"entity:ID" -> DropSlot`, lo stesso vocabolario della colonna.
var slots: Dictionary = {}
## `"entity:ID" -> indice della scelta`, riempito da chi tiene la carta in mano.
var held_places: Dictionary = {}

var _names: Dictionary = {}
var _levels: Dictionary = {}
var _order: Array = []

## Una carta trascinata e' caduta su una casa: le scelte che porta per lei.
signal card_dropped(indices: Array)
## Una carta **tenuta in mano** e' stata posata su una casa.
signal card_placed(index: int)


func _ready() -> void:
	add_theme_constant_override("separation", 6)


func render(session: RefCounted, viewer_id: String) -> void:
	var order: Array = (session.world["turn_order"] as Array).duplicate()
	if order != _order:
		_order = order
		_rebuild(session)
	for entity_id in _order:
		var other: String = str(entity_id)
		var name: Label = _names[other]
		var level: Label = _levels[other]
		name.text = session.service.name_of(other)
		if other == viewer_id:
			name.text += " — tu"
			level.text = ""
			continue
		if viewer_id == "":
			level.text = ""
			continue
		var relation: String = session.service.relation_level(viewer_id, other)
		level.text = relation.to_lower()
		level.add_theme_color_override(
			"font_color", Color(str(RELATIONS.get(relation, "#8a8172")))
		)


## Accende i posti dove la carta tenuta in mano puo' andare, e spegne gli altri.
func hold(places: Dictionary) -> void:
	held_places = places.duplicate()
	for where in slots:
		(slots[where] as Object).call("light", held_places.has(str(where)))


func _rebuild(session: RefCounted) -> void:
	for child in get_children():
		child.queue_free()
		remove_child(child)
	slots.clear()
	_names.clear()
	_levels.clear()
	for i in range(_order.size()):
		var other: String = str(_order[i])
		var slot: PanelContainer = DropSlot.new()
		slot.field = "entity"
		slot.key = other
		# Alto un dito (D-243) e largo quanto un nome: la larghezza si dichiara,
		# perche' un posto che chiede zero si stringe dove lo schermo e' stretto.
		slot.custom_minimum_size = Vector2(96, 44)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.card_dropped.connect(func(indices: Array) -> void: card_dropped.emit(indices))
		slot.gui_input.connect(func(event: InputEvent) -> void:
			if not (event is InputEventMouseButton):
				return
			var press := event as InputEventMouseButton
			if not press.pressed or press.button_index != MOUSE_BUTTON_LEFT:
				return
			var where: String = "entity:%s" % other
			if held_places.has(where):
				card_placed.emit(int(held_places[where]))
		)
		add_child(slot)
		slots["entity:%s" % other] = slot

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(row)
		# Il colore della casa: lo stesso della sua pedina sulla mappa, cosi'
		# la striscia e la plancia si leggono insieme.
		var swatch := ColorRect.new()
		swatch.color = Color(str(SEAT_COLOURS[i % SEAT_COLOURS.size()]))
		swatch.custom_minimum_size = Vector2(10, 10)
		swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(swatch)
		var column := VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(column)
		var name := Label.new()
		name.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name.add_theme_font_size_override("font_size", 12)
		name.add_theme_color_override("font_color", Color("#e8dcc8"))
		name.clip_text = true
		column.add_child(name)
		var level := Label.new()
		level.mouse_filter = Control.MOUSE_FILTER_IGNORE
		level.add_theme_font_size_override("font_size", 11)
		column.add_child(level)
		_names[other] = name
		_levels[other] = level
