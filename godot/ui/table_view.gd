extends Control
## La vista TAVOLO (voce 27, fase 1 — D-134): la vetrina sullo schermo grande.
##
## Mappa, domande, Consigli chiusi, carte del mondo, verbale — e nessun
## segreto di seggio: tutto passa dal viewer pubblico ("") e dal TableModel.
## La C della seduta e' «vetrina + ispezione»: i tocchi *guardano* (il click
## su una Regione apre il suo dettaglio pubblico), non decidono mai — un
## tocco sul tabellone non ha identita' di seggio.
##
## Stesso contratto dei pannelli: `render(session)` e nient'altro. Nessun
## decider, nessuna domanda, nessuna scrittura sul mondo.

const TableModel := preload("res://scripts/views/table_model.gd")
const MapView := preload("res://ui/map_view.gd")

const VERBALE_TAIL: int = 12

var _session: RefCounted = null
var _header: Label = null
var _map: Control = null
var _questions: VBoxContainer = null
var _councils: VBoxContainer = null
var _verbale: VBoxContainer = null
var _detail: Label = null


func _ready() -> void:
	_build()


func render(session: RefCounted) -> void:
	if _header == null:
		_build()
	_session = session
	var model: Dictionary = TableModel.build(session)
	_header.text = "Anno %d — Atto %d, round %d" % [
		int(model["year"]), int(model["act"]), int(model["round"])
	]
	_map.render(session, "")

	_fill(_questions, "LE DOMANDE", _question_lines(model))
	_fill(_councils, "I CONSIGLI DELL'ANNO", _council_lines(model))
	var tail: Array = (model["verbale"] as Array).slice(
		maxi(0, (model["verbale"] as Array).size() - VERBALE_TAIL)
	)
	_fill(_verbale, "IL VERBALE", tail)


func _question_lines(model: Dictionary) -> Array:
	var lines: Array = []
	for tension in model["tensions"]:
		var entry: Dictionary = tension
		if int(entry["value"]) < 0:
			# Il dorso della carta: la domanda coperta non mostra il numero
			# a nessuno schermo comune, nemmeno se un seggio l'ha sbirciata.
			lines.append("%s — domanda coperta" % str(entry["title"]))
		else:
			lines.append("%s — %d su %d" % [
				str(entry["title"]), int(entry["value"]), int(entry["threshold"])
			])
	return lines


func _council_lines(model: Dictionary) -> Array:
	var lines: Array = []
	for council in model["councils"]:
		var entry: Dictionary = council
		lines.append("%s — %s (propose %s)" % [
			str(entry["tension"]), str(entry["outcome"]), str(entry["proponent"])
		])
	for title in model["echoes_played"]:
		lines.append("Il mondo ha calato: %s" % str(title))
	return lines


## L'ispezione: il dettaglio pubblico della Regione toccata.
func _on_region_clicked(region_id: String) -> void:
	if _session == null:
		return
	var region: Dictionary = TableModel.region_detail(_session, region_id)
	if region.is_empty():
		_detail.text = ""
		return
	var pieces: Array = []
	for presence in region["presences"]:
		pieces.append("%s ×%d" % [
			str((presence as Dictionary)["name"]), int((presence as Dictionary)["count"])
		])
	var holder: String = str(region["holder"])
	_detail.text = "%s — %s. %s%s" % [
		str(region["name"]),
		"di nessuno" if holder == "" else "di %s" % holder,
		"" if pieces.is_empty() else "Pedine: %s. " % ", ".join(PackedStringArray(pieces)),
		"" if (region["marks"] as Array).is_empty()
			else "Segni: %s." % ", ".join(PackedStringArray(region["marks"])),
	]


func _build() -> void:
	if _header != null:
		return
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 18)
	root.add_child(_header)

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 12)
	root.add_child(split)

	_map = MapView.new()
	_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_map.size_flags_stretch_ratio = 2.0
	_map.region_clicked.connect(_on_region_clicked)
	split.add_child(_map)

	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 8)
	split.add_child(side)
	_questions = VBoxContainer.new()
	side.add_child(_questions)
	_councils = VBoxContainer.new()
	side.add_child(_councils)

	_detail = Label.new()
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_theme_font_size_override("font_size", 12)
	root.add_child(_detail)

	_verbale = VBoxContainer.new()
	root.add_child(_verbale)


func _fill(box: VBoxContainer, title: String, entries: Array) -> void:
	for child in box.get_children():
		child.queue_free()
		box.remove_child(child)
	var header := Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 12)
	header.add_theme_color_override("font_color", Color("#8a8172"))
	box.add_child(header)
	for entry in entries:
		var line := Label.new()
		line.text = str(entry)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		box.add_child(line)
