extends PanelContainer
## La cronaca dell'anno, sullo schermo (ISSUES voce 10, D-086).
##
## A fine Chronicle il registro delle Truth smette di essere righe di log e
## diventa le pagine che `chronicle_book.gd` impagina per la stampa - **le
## stesse**: questa vista rasterizza l'SVG delle pagine, cosi' quello che si
## vede al tavolo e' esattamente quello che uscira' dal Chronicle Book, non
## una cosa che gli somiglia (la stessa disciplina dell'anteprima di stampa,
## D-056).

const ChronicleBook := preload("res://scripts/core/chronicle_book.gd")

## Quanti pixel per unita' SVG (millimetro): 4 rende un A4 a 840x1188, nitido
## anche su uno schermo grande senza pesare come una scansione.
const RASTER_SCALE: float = 4.0

var _pages: Array = []
var _index: int = 0
var _picture: TextureRect
var _footer: Label


func _ready() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#0d0b09")
	add_theme_stylebox_override("panel", background)

	var rows := VBoxContainer.new()
	rows.set_anchors_preset(Control.PRESET_FULL_RECT)
	rows.add_theme_constant_override("separation", 8)
	add_child(rows)

	_picture = TextureRect.new()
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_picture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_picture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_child(_picture)

	_footer = Label.new()
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_footer.add_theme_font_size_override("font_size", 12)
	_footer.add_theme_color_override("font_color", Color("#8a8172"))
	rows.add_child(_footer)


## Impagina un salvataggio e mostra la prima pagina.
func show_year(save: Dictionary, data: RefCounted) -> void:
	_pages = ChronicleBook.pages(save, data)
	_index = 0
	_show()


func page_count() -> int:
	return _pages.size()


func step(by: int) -> void:
	if _pages.is_empty():
		return
	_index = clampi(_index + by, 0, _pages.size() - 1)
	_show()


func _show() -> void:
	if _pages.is_empty():
		_picture.texture = null
		_footer.text = "Nessuna cronaca da mostrare."
		return
	var image := Image.new()
	if image.load_svg_from_string(str(_pages[_index]), RASTER_SCALE) != OK:
		_footer.text = "La pagina non si e' lasciata disegnare."
		return
	_picture.texture = ImageTexture.create_from_image(image)
	_footer.text = (
		"La cronaca dell'anno · pagina %d di %d%s" % [
			_index + 1, _pages.size(),
			" · frecce per sfogliare" if _pages.size() > 1 else "",
		]
	)
