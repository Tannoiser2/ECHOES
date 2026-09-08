extends PanelContainer
## **Una carta, disegnata dalla sua faccia stampata** (D-473).
##
## Parola del committente, davanti alla pagina: *«troppo testo app e poco
## fedele al gioco fisico che dovrebbe prevedere solo Carte»*. Sullo schermo
## c'erano righe, barre e conti; sul tavolo ci sono carte. Questo nodo e' il
## pezzo che mancava per poterle disegnare tutte: prende una faccia di
## `CardFace` — la **stessa** che va in stampa — e la mette a schermo.
##
## Una sorgente sola, come per il testo del Consiglio (D-233): se la carta
## stampata e la carta a schermo dicono due cose diverse, e' perche' qualcuno
## le ha scritte due volte. Qui non si scrive niente: si disegna quello che
## `CardFace.of(deck, id, data)` gia' dice.
##
## Non decide niente e non legge una regola. Chi la usa le passa la faccia.

## Le proporzioni di una carta vera (63x88), in tre taglie: quella del
## mazzetto, quella che si guarda, e quella grande di una scheda.
const WIDTHS: Dictionary = {"piccola": 132.0, "media": 190.0, "grande": 250.0}

## **L'illustrazione non c'e' ancora, e non si finge** (D-473).
##
## `CardArt.texture_for` non da' l'illustrazione di una carta: da' **la carta
## stampata intera**, disegnata in SVG per i fogli di stampa — e ThorVG non
## disegna il testo negli SVG (provato: 0 pixel su 200941, trappola di casa).
## Metterla qui dentro come immagine faceva un rettangolo quasi nero alto meta'
## carta, con sotto la stessa carta riscritta a parole: un doppione che si
## vede. Quando le illustrazioni ci saranno, questa carta le mostrera'; finche'
## non ci sono, mostra quello che c'e' — il cartoncino, il titolo, le righe.

var _title: Label
var _subtitle: Label
var _body: VBoxContainer
var _notes: VBoxContainer
var _corner: Label
var _frame: StyleBoxFlat
var _size: String = "media"

## Che carta e' quella disegnata adesso: `deck` e `id` della faccia. Serve a
## chi la guarda da fuori — una prova, o un posto che deve sapere cosa tiene.
var shown_deck: String = ""
var shown_id: String = ""

## **Il dorso o la faccia** (D-473). Su una carta compatta si legge quello che
## si legge guardando il mazzetto da lontano: l'immagine, il nome, la riga
## sotto. Il resto — cosa fa, cosa costa — si legge quando la si prende in
## mano, cioe' quando la si guarda grande.
var compact: bool = false:
	set(value):
		compact = value
		if _body != null:
			_body.visible = not compact
			_notes.visible = not compact


func _ready() -> void:
	if _title == null:
		_build()


## `size` e' una delle tre taglie: la carta non si stira, si sceglie.
func set_size_name(size: String) -> void:
	_size = size if WIDTHS.has(size) else "media"
	if _title != null:
		_apply_size()


func _apply_size() -> void:
	var wide: float = float(WIDTHS[_size])
	# Larga quanto la sua taglia; **alta quanto quello che ci sta scritto**, e
	# non piu': una carta di testo che riservasse l'altezza dell'illustrazione
	# sarebbe mezza carta vuota.
	custom_minimum_size = Vector2(wide, 0)


func _build() -> void:
	_frame = StyleBoxFlat.new()
	_frame.bg_color = Color("#17150f")
	_frame.border_color = Color("#6b5a3c")
	_frame.set_border_width_all(2)
	_frame.set_corner_radius_all(6)
	_frame.set_content_margin_all(8)
	add_theme_stylebox_override("panel", _frame)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	add_child(column)

	# L'angolo col numero, dove sta sulla carta: in alto, prima di tutto.
	_corner = _label(13, "#e8b563")
	_corner.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(_corner)

	_title = _label(15, "#e8dcc8")
	column.add_child(_title)
	_subtitle = _label(11, "#8a8172")
	column.add_child(_subtitle)

	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 2)
	column.add_child(_body)

	_notes = VBoxContainer.new()
	_notes.add_theme_constant_override("separation", 2)
	column.add_child(_notes)

	_apply_size()


func _label(font_size: int, colour: String) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(colour))
	return label


## Disegna una faccia. `data` resta nella firma per il giorno in cui la carta
## avra' la sua illustrazione da mostrare.
func render(face: Dictionary, _data: RefCounted = null) -> void:
	if _title == null:
		_build()
	if face.is_empty():
		visible = false
		return
	visible = true
	shown_deck = str(face.get("deck", ""))
	shown_id = str(face.get("id", ""))
	var accent: Color = Color(str(face.get("accent", "#8a8172")))
	_frame.border_color = accent
	_frame.set_border_width_all(2)
	_title.text = str(face.get("title", ""))
	_subtitle.text = str(face.get("subtitle", ""))
	_subtitle.visible = _subtitle.text != ""
	_corner.text = str(face.get("corner", ""))
	_corner.visible = _corner.text != ""
	_fill(_body, face.get("body", []) as Array, 12, "#c9bfae")
	_fill(_notes, face.get("notes", []) as Array, 11, "#8a8172")
	_body.visible = not compact
	_notes.visible = not compact


## **Il bordo acceso** (D-473): la carta che al tavolo sta per andare al
## Consiglio si vede da lontano, come il mazzetto piu' alto in fila. Si chiama
## dopo `render`, che rimette il colore della faccia.
func mark(colour: Color) -> void:
	if _frame != null:
		_frame.border_color = colour
		_frame.set_border_width_all(3)


func _fill(box: VBoxContainer, lines: Array, font_size: int, colour: String) -> void:
	for child in box.get_children():
		child.queue_free()
		box.remove_child(child)
	for line in lines:
		var said: String = str(line).strip_edges()
		if said == "":
			continue
		box.add_child(_label(font_size, colour))
		(box.get_child(box.get_child_count() - 1) as Label).text = said
