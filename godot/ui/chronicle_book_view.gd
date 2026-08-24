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

var _pages: Array = []
var _index: int = 0
var _label: String = "La cronaca dell'anno"
var _page: Control
var _footer: Label


func _ready() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#0d0b09")
	add_theme_stylebox_override("panel", background)

	var rows := VBoxContainer.new()
	rows.set_anchors_preset(Control.PRESET_FULL_RECT)
	rows.add_theme_constant_override("separation", 8)
	add_child(rows)

	_page = Page.new()
	_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_child(_page)

	_footer = Label.new()
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_footer.add_theme_font_size_override("font_size", 12)
	_footer.add_theme_color_override("font_color", Color("#8a8172"))
	rows.add_child(_footer)


## Impagina un salvataggio e mostra la prima pagina.
func show_year(save: Dictionary, data: RefCounted) -> void:
	_pages = ChronicleBook.laid_out(save, data)
	_label = "La cronaca dell'anno"
	_index = 0
	_show()


## Il libro dell'intera saga (D-096): la Timeline in apertura, poi la cronaca
## di ogni anno giocato. Con un anno solo e' il libro di sempre.
func show_saga(saves: Array, data: RefCounted) -> void:
	_pages = ChronicleBook.saga_laid_out(saves, data)
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
		_page.lines = []
		_page.queue_redraw()
		_footer.text = "Nessuna cronaca da mostrare."
		return
	_page.lines = (_pages[_index] as Dictionary)["lines"]
	_page.queue_redraw()
	_footer.text = (
		"%s · pagina %d di %d%s" % [
			_label, _index + 1, _pages.size(),
			" · frecce per sfogliare" if _pages.size() > 1 else "",
		]
	)


## La pagina, disegnata da Godot.
##
## Le righe arrivano gia' impaginate in millimetri (`ChronicleBook.laid_out`) e
## qui si scalano al riquadro che c'e': stessa pagina della stampa, stesse
## posizioni, ma **scritta da chi il testo lo sa scrivere**. Il foglio resta
## proporzionato come un A4 e centrato, perche' una cronaca che cambia forma con
## la finestra non somiglia piu' a quello che uscira' dalla stampante.
class Page extends Control:
	const PrintSheet := preload("res://scripts/core/print_sheet.gd")
	const PAGE_W: float = PrintSheet.PAGE_W
	const PAGE_H: float = PrintSheet.PAGE_H
	const MARGIN: float = 24.0

	## `[[testo, corpo, colore, grassetto, spazio], baseline]` per riga.
	var lines: Array = []

	func _draw() -> void:
		var scale: float = minf(size.x / PAGE_W, size.y / PAGE_H)
		if scale <= 0.0:
			return
		var sheet: Vector2 = Vector2(PAGE_W, PAGE_H) * scale
		var origin: Vector2 = (size - sheet) * 0.5
		draw_rect(Rect2(origin, sheet), Color(PrintSheet.PAPER))
		if lines.is_empty():
			return
		var font: Font = ThemeDB.fallback_font
		for entry in lines:
			var block: Array = (entry as Array)[0]
			var baseline: float = float((entry as Array)[1])
			# Il corpo e' in millimetri: un 3.4 su un A4 alto 297. Moltiplicato
			# per la scala diventa pixel, e sotto i nove non si legge piu' —
			# meglio una pagina un filo piu' grande di una illeggibile.
			var body: int = maxi(9, int(round(float(block[1]) * scale * 1.35)))
			draw_string(
				font, origin + Vector2(MARGIN * scale, baseline * scale),
				str(block[0]), HORIZONTAL_ALIGNMENT_LEFT, sheet.x - MARGIN * scale * 2.0,
				body, Color(str(block[2]))
			)
