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

## Quanto nitida vorremmo la pagina, in pixel per millimetro.
const RASTER_SCALE: float = 4.0

## **E quanto grande puo' diventare davvero** (D-248).
##
## Il commento qui sopra diceva «840x1188». E' sbagliato: a scala 4 un A4 esce
## **3175x4490**, cioe' 54 megabyte di texture. Su un iPad quel lato lungo supera
## il massimo che la scheda accetta, la texture non si carica, e la vista mostra
## una pagina nera — *«la cronaca dell'anno e' sempre una pagina vuota»*. Non era
## vuota: era troppo grande per essere disegnata.
##
## Milleseicento e' sotto il tetto di qualunque dispositivo in circolazione e
## resta piu' nitido dello schermo che lo mostra.
const MAX_SIDE: float = 1600.0

var _pages: Array = []
var _index: int = 0
var _label: String = "La cronaca dell'anno"
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
	_label = "La cronaca dell'anno"
	_index = 0
	_show()


## Il libro dell'intera saga (D-096): la Timeline in apertura, poi la cronaca
## di ogni anno giocato. Con un anno solo e' il libro di sempre.
func show_saga(saves: Array, data: RefCounted) -> void:
	_pages = ChronicleBook.saga_pages(saves, data)
	_label = "Il libro della saga" if saves.size() > 1 else "La cronaca dell'anno"
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
	var image: Image = raster(str(_pages[_index]))
	if image == null:
		_footer.text = "La pagina non si e' lasciata disegnare."
		return
	_picture.texture = ImageTexture.create_from_image(image)
	_footer.text = (
		"%s · pagina %d di %d%s" % [
			_label, _index + 1, _pages.size(),
			" · frecce per sfogliare" if _pages.size() > 1 else "",
		]
	)


## La pagina disegnata alla misura piu' nitida che ci sta dentro il tetto.
##
## Si misura prima a scala 1 — costa poco — e da li' si calcola quanto si puo'
## ingrandire senza sfondare `MAX_SIDE`. Cosi' il numero non e' indovinato: se
## domani la pagina cambia formato, la misura si aggiusta da sola invece di
## tornare nera su meta' dei dispositivi.
##
## Statica e pura: e' l'unica parte di questa vista che si puo' provare in
## headless, ed e' quella dove il difetto viveva.
static func raster(svg: String) -> Image:
	var probe := Image.new()
	if probe.load_svg_from_string(svg, 1.0) != OK:
		return null
	var side: float = float(maxi(probe.get_width(), probe.get_height()))
	var wanted: float = clampf(MAX_SIDE / maxf(side, 1.0), 1.0, RASTER_SCALE)
	if wanted <= 1.0:
		return probe
	var image := Image.new()
	if image.load_svg_from_string(svg, wanted) != OK:
		return probe
	return image
