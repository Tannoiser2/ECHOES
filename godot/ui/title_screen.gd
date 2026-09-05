extends Control
## La soglia (D-276, rifatta in D-279): la copertina, e il tavolo che si compone.
##
## Il committente: *«lo splash screen deve essere con questa immagine, lì devo
## scegliere i seggi e i giocatori (chi è persona e chi Bot)»*. Quindi la
## soglia fa due cose e basta: mostra la scatola, e chiede **chi siede e chi lo
## gioca**. Da qui in poi la sala non chiede piu' niente — il mondo si pesca
## (niente «che mondo?»), le regole non si spiegano in una schermata.
##
## Costruita in codice come il resto dell'app: il layout vive accanto alle sue
## ragioni.

const DataSet := preload("res://scripts/core/data_set.gd")
const ArtLibrary := preload("res://scripts/core/art_library.gd")
const GameScreen := preload("res://ui/game_screen.gd")
const TableChoice := preload("res://scripts/core/table_choice.gd")

const GAME_SCENE: String = "res://ui/main.tscn"

## seggio -> vero se lo gioca una persona a questo schermo.
var _human: Dictionary = {}
var _seats: Array = []
var _data: RefCounted = null


func _ready() -> void:
	_data = DataSet.new()
	if not _data.load_from("res://data"):
		var sorry := Label.new()
		sorry.text = "I dati non si caricano."
		add_child(sorry)
		return
	_seats = seats_of(_data)
	for seat in _seats:
		_human[str(seat)] = false
	_build()


## I seggi che il tavolo apre: quelli della prima Chronicle giocabile. Statica
## perche' la prova possa chiedere chi siede senza costruire una scena.
static func seats_of(data: RefCounted) -> Array:
	var chronicle_id: String = GameScreen.first_chronicle(data)
	var chronicle: Variant = data.chronicles.get(chronicle_id)
	if chronicle == null:
		return []
	return ((chronicle as Dictionary)["entities"] as Array).duplicate()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#0d0b09")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# **La copertina e' la schermata.** Sta sotto tutto, a proporzioni
	# rispettate: e' la scatola vista da sopra, e il tavolo si compone sopra
	# di lei. Se il file non c'e' resta il fondo scuro e il nome scritto.
	var cover: Texture2D = ArtLibrary.texture(ArtLibrary.COVER)
	if cover != null:
		var art := TextureRect.new()
		art.texture = cover
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_SCALE
		add_child(art)
		# **La copertina si appoggia in alto** (D-463). E' quadrata, e una
		# finestra larga la tagliava sopra e sotto in parti uguali: il nome del
		# gioco usciva senza la meta' superiore delle lettere, su ogni schermo
		# da tablet in orizzontale. Ora riempie la larghezza e mostra il bordo
		# alto — il titolo — mentre a essere coperto dal pannello dei seggi
		# resta il bordo basso, che sono le citta'.
		var place := func() -> void:
			var side: float = maxf(size.x, size.y * 0.75)
			art.size = Vector2(side, side)
			art.position = Vector2((size.x - side) * 0.5, 0.0)
		place.call()
		resized.connect(place)
		# Un velo appena accennato: senza, il pannello dei seggi galleggia su
		# un fondo troppo chiaro e il testo scompare.
		var veil := ColorRect.new()
		veil.color = Color(0.05, 0.04, 0.03, 0.42)
		veil.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(veil)
	else:
		var wordmark := Label.new()
		wordmark.text = "E C H O E S"
		wordmark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wordmark.set_anchors_preset(Control.PRESET_CENTER_TOP)
		wordmark.add_theme_font_size_override("font_size", 54)
		wordmark.add_theme_color_override("font_color", Color("#e8b563"))
		add_child(wordmark)

	_build_table_panel()


## Il pannello del tavolo: una riga per seggio, e su ogni riga chi lo gioca.
## Sta in basso al centro, dove la copertina lascia spazio.
func _build_table_panel() -> void:
	var anchor := CenterContainer.new()
	anchor.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	anchor.offset_top = -300.0
	anchor.offset_bottom = -18.0
	anchor.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(anchor)

	var frame := PanelContainer.new()
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color(0.07, 0.06, 0.05, 0.88)
	skin.border_color = Color("#6b5a3c")
	skin.set_border_width_all(1)
	skin.set_content_margin_all(18)
	frame.add_theme_stylebox_override("panel", skin)
	anchor.add_child(frame)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	frame.add_child(column)

	var head := Label.new()
	head.text = "CHI SIEDE AL TAVOLO"
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 13)
	head.add_theme_color_override("font_color", Color("#e8b563"))
	column.add_child(head)

	var hint := Label.new()
	hint.text = "Tocca un seggio per passarlo da bot a persona."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#8a8172"))
	column.add_child(hint)

	for seat in _seats:
		column.add_child(_seat_row(str(seat)))

	var go := Button.new()
	go.text = "Entra nella sala"
	go.add_theme_font_size_override("font_size", 18)
	go.custom_minimum_size = Vector2(300, 44)
	go.pressed.connect(_start)
	column.add_child(go)

	var credit := Label.new()
	credit.text = "1–4 giocatori · 90–150 minuti · 14+   ·   Un gioco di Stefano Ancillai"
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credit.add_theme_font_size_override("font_size", 10)
	credit.add_theme_color_override("font_color", Color("#8a8172"))
	column.add_child(credit)


## Una riga di seggio: il nome della casa, e il bottone che dice chi la gioca.
## Un bottone solo e non due: al tavolo il posto e' uno, e o ci si siede o no.
func _seat_row(seat: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var who := Label.new()
	who.text = str((_data.entities.get(seat, {}) as Dictionary).get("name", seat))
	who.custom_minimum_size = Vector2(190, 0)
	who.add_theme_font_size_override("font_size", 16)
	who.add_theme_color_override("font_color", Color("#e8dcc8"))
	row.add_child(who)

	var toggle := Button.new()
	toggle.toggle_mode = true
	toggle.custom_minimum_size = Vector2(110, 30)
	toggle.add_theme_font_size_override("font_size", 13)
	toggle.text = "Bot"
	toggle.toggled.connect(func(pressed: bool) -> void:
		_human[seat] = pressed
		toggle.text = "Persona" if pressed else "Bot"
	)
	row.add_child(toggle)
	return row


func _start() -> void:
	var humans: Array = []
	for seat in _seats:
		if bool(_human.get(str(seat), false)):
			humans.append(str(seat))
	TableChoice.take(humans)
	get_tree().change_scene_to_file(GAME_SCENE)
