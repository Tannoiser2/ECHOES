extends VBoxContainer
## The year's questions, and where the seat stands on its own ladder.
##
## Same contract as the map: `render(session, viewer_id)` and nothing else. A
## Tension shows a number only to a seat entitled to read it, so a veiled
## question the viewer has not scouted is drawn as a bar with no fill and the
## word "velata" - present, unreadable, and clearly *there*, which is the whole
## point of a veiled Tension.

var _rows: Dictionary = {}
var _destiny: VBoxContainer
var _title: Label


func _ready() -> void:
	add_theme_constant_override("separation", 4)


func render(session: RefCounted, viewer_id: String) -> void:
	if _title == null:
		_build()
	for tension_id in _sorted(session.world["tensions"].keys()):
		var id: String = str(tension_id)
		if not _rows.has(id):
			_rows[id] = _add_row(str(session.data.tensions[id]["title"]))
		_update_row(_rows[id], session, id, viewer_id)
	_update_destiny(session, viewer_id)


func _build() -> void:
	_title = Label.new()
	_title.text = "LE DOMANDE DELL'ANNO"
	_title.add_theme_font_size_override("font_size", 12)
	_title.add_theme_color_override("font_color", Color("#8a8172"))
	add_child(_title)


func _add_row(title: String) -> Dictionary:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	add_child(box)

	var header := HBoxContainer.new()
	box.add_child(header)
	var name := Label.new()
	name.text = title
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.add_theme_font_size_override("font_size", 13)
	name.add_theme_color_override("font_color", Color("#d9d2c5"))
	header.add_child(name)
	var value := Label.new()
	value.add_theme_font_size_override("font_size", 13)
	header.add_child(value)

	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 8)
	box.add_child(bar)
	return {"value": value, "bar": bar}


func _update_row(row: Dictionary, session: RefCounted, tension_id: String, viewer_id: String) -> void:
	var threshold: int = session.tensions.threshold(tension_id)
	var visible_value: int = session.service.visible_tension_value(tension_id, viewer_id)
	var bar: ProgressBar = row["bar"]
	var value: Label = row["value"]
	bar.max_value = float(maxi(threshold, 1))

	if visible_value < 0:
		bar.value = 0.0
		value.text = "velata"
		value.add_theme_color_override("font_color", Color("#5f584c"))
		return
	bar.value = float(visible_value)
	value.text = "%d/%d" % [visible_value, threshold]
	# The colour is the warning: a question one step from its threshold is the
	# one worth spending an action on, and it should be findable at a glance.
	var margin: int = threshold - visible_value
	var tint: Color = Color("#6fa88a")
	if margin <= 0:
		tint = Color("#c8553d")
	elif margin <= 1:
		tint = Color("#e8b563")
	value.add_theme_color_override("font_color", tint)
	var fill := StyleBoxFlat.new()
	fill.bg_color = tint
	bar.add_theme_stylebox_override("fill", fill)


## The ladder, with the rungs that hold already ticked. A player who cannot read
## their own goal cannot steer towards it.
func _update_destiny(session: RefCounted, viewer_id: String) -> void:
	if _destiny == null:
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 12)
		add_child(spacer)
		var header := Label.new()
		header.text = "IL TUO DESTINO"
		header.add_theme_font_size_override("font_size", 12)
		header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(header)
		_destiny = VBoxContainer.new()
		_destiny.add_theme_constant_override("separation", 2)
		add_child(_destiny)

	for child in _destiny.get_children():
		child.queue_free()
		_destiny.remove_child(child)
	if viewer_id == "":
		return
	var entity: Variant = session.data.entities.get(viewer_id)
	if entity == null:
		return
	var destiny: Variant = session.data.destinies.get(str(entity["destiny_id"]))
	if destiny == null:
		return
	for level in ["minimum", "victory", "triumph"]:
		var holds: bool = session.destinies.conditions.all_hold(destiny[level]["conditions"], {})
		var line := Label.new()
		# ASCII on purpose: the fallback font a Web export ships has no check mark,
		# and a missing glyph renders as a tofu box - which reads as a bug in the
		# game rather than a gap in the font.
		line.text = "%s %s" % ["[x]" if holds else "[ ]", str(destiny[level]["label"])]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		line.add_theme_color_override(
			"font_color", Color("#6fa88a") if holds else Color("#5f584c")
		)
		_destiny.add_child(line)


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out
