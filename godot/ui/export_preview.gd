extends PanelContainer
## L'anteprima di stampa: come esce dalla stampante, prima di stamparla (§25.15).
##
## `cli/run_export.gd` scrive venticinque fogli A4 e un brief d'arte. Guardarli
## vuol dire esportare, aprire un file e tornare indietro - lo stesso giro che il
## cruscotto ha tolto alle sonde (D-054), e per lo stesso motivo lo toglie questa.
##
## Due viste, perche' le domande sono due:
##
## - **il foglio**, a sinistra: le carte stanno nella pagina? i segni di taglio
##   cadono dove devono? Non si legge, si guarda l'impaginato.
## - **la carta**, a destra: il testo ci sta? il titolo va a capo bene? il numero
##   d'angolo copre qualcosa?
##
## Disegna passando dalla stessa `PrintSheet.layout()` che scrive l'SVG. Se
## avesse una propria impaginazione «somigliante» non sarebbe un'anteprima: la
## carta buona sullo schermo e sbagliata sul foglio e' esattamente l'errore che
## un'anteprima esiste per non far fare.

const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")
const ArtPlaceholder := preload("res://scripts/core/art_placeholder.gd")

const SECTION: String = "[color=#e8b563][b]%s[/b][/color]"
const DIM: String = "[color=#8a8172]%s[/color]"

var _header: RichTextLabel
var _sheet: Control
var _card: Control

## Tutte le facce del set in ordine di export, e dove ognuna cade nel foglio.
var _faces: Array = []
## E il mazzo come si stampa davvero, copie comprese: il foglio a sinistra deve
## mostrare le nove carte che escono dalla stampante, non le tre facce diverse
## che ci sono sopra.
var _printed: Array = []
var _at: int = 0
var _data: RefCounted = null


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#12100e")
	style.border_color = Color("#3a332a")
	style.set_border_width_all(2)
	style.set_content_margin_all(14)
	add_theme_stylebox_override("panel", style)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	add_child(rows)

	_header = RichTextLabel.new()
	_header.bbcode_enabled = true
	_header.fit_content = true
	_header.custom_minimum_size = Vector2(0, 74)
	_header.add_theme_font_size_override("normal_font_size", 12)
	_header.add_theme_color_override("default_color", Color("#c9c2b4"))
	rows.add_child(_header)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 16)
	rows.add_child(columns)

	_sheet = Sheet.new()
	_sheet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sheet.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(_sheet)

	_card = Card.new()
	_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(_card)


## Il set intero, una faccia alla volta. Le copie non entrano: qui si correggono
## le facce, non si conta il mazzo - quello lo dice l'intestazione.
func render(data: RefCounted) -> void:
	if data == null:
		return
	if _data != data or _faces.is_empty():
		_data = data
		_build()
	if _faces.is_empty():
		return
	_at = wrapi(_at, 0, _faces.size())
	var entry: Dictionary = _faces[_at]
	_sheet.show_page(_printed, entry)
	_card.show_face(entry)
	_header.clear()
	_header.append_text("\n".join(PackedStringArray(_lines(entry))))


func step(by: int) -> void:
	if _faces.is_empty():
		return
	_at = wrapi(_at + by, 0, _faces.size())
	render(_data)


func _build() -> void:
	_faces = []
	_printed = []
	for deck in CardFace.DECKS + CardFace.TILES:
		var faces: Array = CardFace.deck_of(str(deck), _data)
		if faces.is_empty():
			continue
		var shape: String = str((faces[0] as Dictionary)["shape"])
		var per: int = PrintSheet.per_page(shape)
		# Il foglio vero contiene le copie, quindi il numero di foglio va contato
		# sul mazzo espanso: dire «foglio 1 di 6» quando la stampa ne fa quindici
		# sarebbe un'anteprima che mente sulla cosa piu' facile da verificare.
		var printed: int = PrintSheet.expand(faces).size()
		var sheets: int = int(ceil(float(printed) / float(per)))
		var cards: int = 0
		for index in range(faces.size()):
			var face: Dictionary = faces[index]
			_faces.append({
				"face": face, "deck": str(deck), "shape": shape,
				"index": index, "of": faces.size(),
				"slot": cards % per, "sheet": cards / per + 1, "sheets": sheets,
				"printed": printed, "per": per,
			})
			for copy in range(maxi(1, int(face["copies"]))):
				_printed.append({
					"face": face, "deck": str(deck), "shape": shape, "index": index,
					"slot": cards % per, "sheet": cards / per + 1,
				})
				cards += 1


func _lines(entry: Dictionary) -> Array:
	var face: Dictionary = entry["face"]
	var cell: Vector2 = PrintSheet.cell_size(str(entry["shape"]))
	var drawn: Dictionary = PrintSheet.layout(face, cell)
	var out: Array = []
	out.append(SECTION % "ANTEPRIMA DI STAMPA")
	out.append("%s · faccia %d di %d · foglio %d di %d · %.0fx%.0f mm" % [
		str(CardFace.DECK_LABELS.get(str(entry["deck"]), str(entry["deck"]))),
		int(entry["index"]) + 1, int(entry["of"]),
		int(entry["sheet"]), int(entry["sheets"]), cell.x, cell.y,
	])
	var copies: int = int(face["copies"])
	var notes: Array = [
		"%d copie nel mazzo" % copies if copies != 1 else "una copia nel mazzo",
		"segnaposto: %s" % str(face["art_prompt_key"]) if str(face["art_prompt_key"]) != ""
			else "senza illustrazione: si ristampa",
	]
	if bool(face["secret"]):
		notes.append("segreta: si consegna coperta")
	if bool(drawn["overflow"]):
		notes.append("[color=#c8553d]il testo non ci sta: esce dal bordo[/color]")
	elif float(drawn["scale"]) < 0.999:
		notes.append("corpo ridotto al %d%% per farcelo stare" % int(float(drawn["scale"]) * 100.0))
	out.append(DIM % ("  ".join(PackedStringArray(notes))))
	# Le frecce a parole e non come glifo: nel font che il build Web si porta
	# dietro non ci sono, e uscivano come due quadratini vuoti. Stessa lezione
	# del segno di spunta nel cruscotto (D-054).
	out.append(DIM % "frecce destra e sinistra per scorrere · l'export vero lo scrive cli/run_export.gd")
	return out


## Il foglio, piccolo: non si legge, si guarda se ci sta. Le carte sono blocchi -
## l'illustrazione dove andra' l'illustrazione, barre grigie dove andra' il testo -
## e quella in cui si e' dentro e' accesa.
class Sheet extends Control:
	var _entries: Array = []
	var _current: Dictionary = {}

	func show_page(all: Array, current: Dictionary) -> void:
		_entries = []
		for entry in all:
			if str((entry as Dictionary)["deck"]) == str(current["deck"]) \
					and int((entry as Dictionary)["sheet"]) == int(current["sheet"]):
				_entries.append(entry)
		_current = current
		queue_redraw()

	func _draw() -> void:
		if _entries.is_empty():
			return
		var cell: Vector2 = PrintSheet.cell_size(str(_current["shape"]))
		var scale: float = minf(size.x / PrintSheet.PAGE_W, size.y / PrintSheet.PAGE_H)
		var page: Vector2 = Vector2(PrintSheet.PAGE_W, PrintSheet.PAGE_H) * scale
		var origin: Vector2 = Vector2((size.x - page.x) * 0.5, 0.0)
		draw_rect(Rect2(origin, page), Color("#e8e4dc"))

		var columns: int = int(PrintSheet.PAGE_W / cell.x)
		var left: float = (PrintSheet.PAGE_W - cell.x * float(columns)) * 0.5
		var rows: int = int(PrintSheet.per_page(str(_current["shape"])) / columns)
		var top: float = (PrintSheet.PAGE_H - cell.y * float(rows)) * 0.5

		for entry in _entries:
			var item: Dictionary = entry
			var slot: int = int(item["slot"])
			var at: Vector2 = origin + Vector2(
				left + float(slot % columns) * cell.x, top + float(slot / columns) * cell.y
			) * scale
			var box: Rect2 = Rect2(at, cell * scale)
			var face: Dictionary = item["face"]
			draw_rect(box, Color("#12100e"))
			var accent: Color = Color(str(face["accent"]))
			var drawn: Dictionary = PrintSheet.layout(face, cell)
			if bool(drawn["has_art"]):
				var art := Rect2(
					box.position + Vector2(3.4, 3.4) * scale,
					Vector2(cell.x - 6.8, float(drawn["art_h"])) * scale
				)
				draw_rect(art, Color("#2a231b"))
				draw_rect(art, accent * Color(1, 1, 1, 0.45), false, 1.0)
			for line in drawn["lines"]:
				var text: Dictionary = line
				draw_rect(
					Rect2(
						box.position + Vector2(float(text["x"]), float(text["y"]) - float(text["size"])) * scale,
						Vector2(float(str(text["text"]).length()) * float(text["size"]) * 0.52, float(text["size"]) * 0.7) * scale
					),
					Color("#6b6355") * Color(1, 1, 1, 0.8)
				)
			var chosen: bool = int(item["index"]) == int(_current["index"])
			draw_rect(box, accent if chosen else accent * Color(1, 1, 1, 0.35), false, 2.0 if chosen else 1.0)


## La carta, grande: il testo vero, alla stessa impaginazione del foglio.
class Card extends Control:
	var _face: Dictionary = {}
	var _shape: String = "CARD"

	func show_face(entry: Dictionary) -> void:
		_face = entry["face"]
		_shape = str(entry["shape"])
		queue_redraw()

	func _draw() -> void:
		if _face.is_empty():
			return
		var font: Font = ThemeDB.fallback_font
		var cell: Vector2 = PrintSheet.cell_size(_shape)
		var scale: float = minf(size.x / cell.x, size.y / cell.y)
		var origin: Vector2 = Vector2((size.x - cell.x * scale) * 0.5, 0.0)
		var drawn: Dictionary = PrintSheet.layout(_face, cell)
		var accent: Color = Color(str(_face["accent"]))

		draw_rect(Rect2(origin, cell * scale), Color("#12100e"))
		if bool(drawn["has_art"]):
			_draw_art(
				Rect2(
					origin + Vector2(3.4, 3.4) * scale,
					Vector2(cell.x - 6.8, float(drawn["art_h"])) * scale
				),
				str(drawn["art_key"]), accent
			)
		for line in drawn["lines"]:
			var item: Dictionary = line
			draw_string(
				font, origin + Vector2(float(item["x"]), float(item["y"])) * scale,
				str(item["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1,
				maxi(7, int(float(item["size"]) * scale)), Color(str(item["colour"]))
			)
		if str(drawn["corner"]) != "":
			var centre: Vector2 = origin + Vector2(cell.x - 6.4, 6.4) * scale
			draw_circle(centre, 4.2 * scale, accent)
			draw_string(
				font, centre + Vector2(-1.6, 1.8) * scale, str(drawn["corner"]),
				HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(9, int(5.0 * scale)), Color("#12100e")
			)
		draw_string(
			font, origin + Vector2(3.4, cell.y - 3.4) * scale, str(drawn["footer"]),
			HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(7, int(2.0 * scale)), Color("#5f584c")
		)
		draw_rect(Rect2(origin, cell * scale), accent, false, 2.0)

	## Lo stesso piano che l'SVG scrive, disegnato con le primitive di Godot:
	## stesse forme, stessa fascia calma, stessa chiave in chiaro.
	func _draw_art(box: Rect2, key: String, accent: Color) -> void:
		var plan: Dictionary = ArtPlaceholder.plan(key, "")
		draw_rect(box, Color(str(plan["sky"])))
		for shape in plan["shapes"]:
			var item: Dictionary = shape
			var at: Vector2 = box.position + Vector2(
				float(item["x"]) * box.size.x, float(item["y"]) * box.size.y
			)
			var extent: Vector2 = Vector2(
				float(item["w"]) * box.size.x, float(item["h"]) * box.size.y
			)
			var tone: Color = accent if int(item["tone"]) == 1 else Color("#3a332a")
			match str(item["kind"]):
				"spire":
					draw_colored_polygon(
						PackedVector2Array([
							at + Vector2(0, extent.y),
							at + Vector2(extent.x * 0.5, 0),
							at + extent,
						]), tone
					)
				"disc":
					draw_circle(at + extent * 0.5, minf(extent.x, extent.y) * 0.5, tone)
				_:
					draw_rect(Rect2(at, extent), tone)
		var horizon: float = box.position.y + box.size.y * float(plan["horizon"])
		draw_rect(
			Rect2(Vector2(box.position.x, horizon), Vector2(box.size.x, box.end.y - horizon)),
			Color(str(plan["ground"]))
		)
		draw_rect(
			Rect2(
				Vector2(box.position.x, box.position.y + box.size.y * float(plan["calm"])),
				Vector2(box.size.x, box.size.y * ArtPlaceholder.CALM)
			), Color("#4a4237"), false, 1.0
		)
		draw_string(
			ThemeDB.fallback_font, Vector2(box.position.x + 4.0, box.end.y - 4.0), key,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#6b6355")
		)
