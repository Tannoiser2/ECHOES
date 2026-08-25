extends Control
## La soglia (D-276): la schermata che si vede aprendo l'app, prima della sala.
##
## Tre cose e basta, come sulla scatola: il nome del gioco, il tavolo — le sei
## tessere di una pesca vera, posate 3x2 come comanda la posa (D-275) — e la
## porta per entrare. Non decide niente e non tocca la partita: la pesca che
## mostra e' un **assaggio** fatto con la stessa mano del motore
## (`WorldStateFactory.resolve_map`, dado derivato dal seme esattamente come in
## `game_session.gd`), cosi' quello che la soglia promette e' quello che il
## tavolo poi da'.
##
## Costruita in codice e non in .tscn, come il resto dell'app: il layout vive
## accanto alle sue ragioni (stessa scelta di game_screen.gd).

const DataSet := preload("res://scripts/core/data_set.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const RegionArt := preload("res://scripts/core/region_art.gd")
const ArtLibrary := preload("res://scripts/core/art_library.gd")
const GameScreen := preload("res://ui/game_screen.gd")

## La porta: dove si entra premendo il bottone. La sala e' la scena di sempre.
const GAME_SCENE: String = "res://ui/main.tscn"

## Il seme si deriva dall'orologio come fa la stanza (room_screen.gd): ogni
## apertura mostra una saga possibile, non sempre la stessa.
var _seed: int = 0


func _ready() -> void:
	_seed = int(Time.get_unix_time_from_system()) % 100000
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		var sorry := Label.new()
		sorry.text = "I dati non si caricano."
		add_child(sorry)
		return
	_build(data)


## L'assaggio del tavolo: la pesca vera, rifatta con la stessa derivazione del
## seme di `game_session.gd` (seme * 53 + 29), posata riga per riga come
## `_lay_the_tiles`. Statico e puro perche' la prova possa pretendere che la
## soglia non menta: stesso seme, stesse tessere della partita.
static func preview(data: RefCounted, seed_value: int) -> Array:
	var chronicle_id: String = GameScreen.first_chronicle(data)
	var chronicle: Dictionary = data.chronicles.get(chronicle_id, {}) as Dictionary
	if chronicle.is_empty():
		return []
	var drawn: Array = WorldStateFactory.resolve_map(
		chronicle, RngService.new(seed_value * 53 + 29)
	)
	var columns: int = int(ceil(sqrt(float(drawn.size()))))
	var tiles: Array = []
	for i in range(drawn.size()):
		var definition: Dictionary = data.regions.get(str(drawn[i]), {}) as Dictionary
		tiles.append({
			"region_id": str(drawn[i]),
			"name": str(definition.get("name", str(drawn[i]))),
			"signs": _printed_signs(definition, data),
			"plan": RegionArt.plan(str(drawn[i]), str(definition.get("biome", ""))),
			"art_key": str(definition.get("art_prompt_key", "")),
			"col": i % columns,
			"row": i / columns,
		})
	return tiles


## I segni stampati sulla tessera, detti come le carte li stampano: #parola
## (D-262). I domini restano fuori — sulla tessera fisica sono iconcine, e
## qui sotto il nome c'e' posto per una riga sola.
static func _printed_signs(definition: Dictionary, data: RefCounted) -> String:
	var words: Array = []
	for tag in definition.get("tags", []):
		if str(tag).begins_with("domain:"):
			continue
		var known: Dictionary = data.tags.get(str(tag), {}) as Dictionary
		words.append("#%s" % str(known.get("title", str(tag))))
	return "  ".join(PackedStringArray(words))


# --- la pagina ---------------------------------------------------------------

func _build(data: RefCounted) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#12100e")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var centred := CenterContainer.new()
	centred.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centred)

	var page := VBoxContainer.new()
	page.alignment = BoxContainer.ALIGNMENT_CENTER
	page.add_theme_constant_override("separation", 10)
	centred.add_child(page)

	page.add_child(_line("IL MONDO RICORDA", 13, "#8a8172"))
	var wordmark := Label.new()
	wordmark.text = "E C H O E S"
	wordmark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wordmark.add_theme_font_size_override("font_size", 58)
	wordmark.add_theme_color_override("font_color", Color("#e8b563"))
	page.add_child(wordmark)
	page.add_child(_line("Le vostre scelte scrivono storia", 16, "#d9d2c5"))
	page.add_child(_line("✦  Il Consiglio delle Case  ✦", 12, "#8a8172"))

	var board := TilePreview.new()
	board.tiles = preview(data, _seed)
	board.custom_minimum_size = Vector2(560, 340)
	page.add_child(board)
	page.add_child(_line(
		"Una pesca vera del motore — seme %d: sei tessere dal parco di dieci,"
		% _seed
		+ " posate 3×2 nell'ordine di pesca. Vicino è chi si tocca.",
		11, "#8a8172"
	))

	var door := Button.new()
	door.text = "Entra nella sala"
	door.add_theme_font_size_override("font_size", 20)
	door.custom_minimum_size = Vector2(260, 46)
	door.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	door.pressed.connect(func() -> void: get_tree().change_scene_to_file(GAME_SCENE))
	page.add_child(door)

	page.add_child(_line("1–4 giocatori   ·   90–150 minuti   ·   14+", 12, "#8a8172"))
	page.add_child(_line("Un gioco di Stefano Ancillai", 12, "#d9d2c5"))
	page.add_child(_line(
		"Pietre. Condizioni. Cicatrici. Ogni scelta lascia un segno.", 11, "#8a8172"
	))


func _line(text: String, size: int, colour: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(colour))
	return label


## Le sei tessere, dipinte con lo stesso pennello della mappa in partita
## (`RegionArt.plan`: sagoma, tratti del bioma, centro calmo). Non un'immagine
## che somiglia al gioco: lo stesso disegno.
class TilePreview extends Control:
	var tiles: Array = []

	func _ready() -> void:
		resized.connect(queue_redraw)

	func _draw() -> void:
		if tiles.is_empty():
			return
		var columns: int = 1
		var rows: int = 1
		for tile in tiles:
			columns = maxi(columns, int((tile as Dictionary)["col"]) + 1)
			rows = maxi(rows, int((tile as Dictionary)["row"]) + 1)
		var radius: float = minf(
			size.x / (float(columns) * 2.15), size.y / (float(rows) * 2.6)
		)
		var font: Font = ThemeDB.fallback_font
		for tile in tiles:
			var entry: Dictionary = tile as Dictionary
			var centre: Vector2 = Vector2(
				(float(int(entry["col"])) + 0.5) / float(columns) * size.x,
				(float(int(entry["row"])) + 0.5) / float(rows) * size.y - 8.0
			)
			var box: Rect2 = Rect2(
				centre - Vector2(radius, radius), Vector2(radius, radius) * 2.0
			)
			var art: Dictionary = entry["plan"]
			# La tessera dipinta se e' stata consegnata (D-277), ritagliata
			# dentro l'esagono come sulla mappa in partita (D-059); senza,
			# il terreno generato di sempre.
			var painted: Texture2D = ArtLibrary.texture(str(entry.get("art_key", "")))
			if painted != null:
				var shape: PackedVector2Array = _mapped(art["outline"], box)
				var uvs: PackedVector2Array = PackedVector2Array()
				for point in art["outline"]:
					uvs.append(point as Vector2)
				draw_colored_polygon(shape, Color(1, 1, 1).darkened(0.12), uvs, painted)
			else:
				draw_colored_polygon(
					_mapped(art["outline"], box), Color(str(art["ground"]))
				)
				for stroke in art["strokes"]:
					var item: Dictionary = stroke
					var colour: Color = Color(str(item["colour"]))
					var at: PackedVector2Array = _mapped(item["points"], box)
					match str(item["kind"]):
						"poly":
							draw_colored_polygon(at, colour)
						"line":
							draw_polyline(
								at, colour, maxf(1.0, float(item["width"]) * box.size.x), true
							)
						"dot":
							draw_circle(at[0], float(item["width"]) * box.size.x, colour)
			var ring: PackedVector2Array = _mapped(art["outline"], box)
			ring.append(ring[0])
			draw_polyline(ring, Color("#4a4238"), 2.0, true)

			var name: String = str(entry["name"])
			var name_size: Vector2 = font.get_string_size(
				name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12
			)
			draw_string(
				font, centre + Vector2(-name_size.x * 0.5, radius + 14.0),
				name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d9d2c5")
			)
			var signs: String = str(entry["signs"])
			var signs_size: Vector2 = font.get_string_size(
				signs, HORIZONTAL_ALIGNMENT_LEFT, -1, 10
			)
			draw_string(
				font, centre + Vector2(-signs_size.x * 0.5, radius + 28.0),
				signs, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#e8b563")
			)

	func _mapped(points: Array, box: Rect2) -> PackedVector2Array:
		var out: PackedVector2Array = PackedVector2Array()
		for point in points:
			out.append(box.position + (point as Vector2) * box.size)
		return out
