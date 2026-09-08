extends VBoxContainer
## **I sei mazzetti dei Temi, come sei carte** (D-464, rifatta da D-473).
##
## Parola del committente, la prima volta: *«le tensioni devono gia' essere
## scoperte, e sopra di esse devono finirci coperti i token che scaldano.
## Potrebbero essere messi su una colonna a sinistra»*. E la seconda, davanti
## alla colonna fatta di righe: *«la colonna delle tensioni potrebbe essere
## fatta a sei schede (come le carte) per visualizzare la carta intera (sulla
## scheda potrebbe apparire quanti token ci sono)»*.
##
## Sei Temi, sei carte, come i sei mazzetti in fila sul bordo del tavolo: la
## carta girata di quel Tema (D-450 le gira tutte all'apertura), col nome del
## Tema sopra e i **gettoni coperti** posati accanto — quanti, non quanto
## valgono (D-261).
##
## Ogni carta e' un posto alto un dito dove una carta della mano puo' cadere
## (INFLUENZARE, TRAMARE), e toccarla la apre grande: e' il gesto di prendere
## in mano la carta girata per leggerla, che al tavolo si fa sempre.
##
## Non decide niente: prende la sessione e la mostra.

const DropSlot := preload("res://ui/drop_slot.gd")
const FaceCard := preload("res://ui/face_card.gd")
const CardFace := preload("res://scripts/core/card_face.gd")

## Alto come un dito (D-243).
const ROW: float = 44.0
const WIDTH: float = 230.0
const TOKEN: float = 8.0

var _session: RefCounted = null
var _viewer: String = ""

## `theme_id -> {"head": Button, "tokens": Control}` e `tension_id -> Control`.
var _themes: Dictionary = {}
var _questions: Dictionary = {}

## I posti dove una carta puo' cadere: `"tension:ID" -> DropSlot`. Stesso
## vocabolario della mappa e della riga dei seggi, e **pubblico**: chi tiene una
## carta in mano ci accende sopra i posti dove quella carta arriva.
var slots: Dictionary = {}

## `"tension:ID" -> indice della scelta`: dove la carta in mano puo' cadere.
var held_places: Dictionary = {}

## Emesso quando si tocca una domanda senza una carta in mano: la si legge.
signal tension_opened(tension_id: String)
## Emesso quando si tocca una domanda con una carta in mano che ci arriva.
signal card_placed(index: int)
## Emesso quando una carta trascinata cade su una domanda.
signal card_dropped_on_question(indices: Array)
## Emesso quando si tocca il nome di un Tema.
signal deck_pressed(theme_id: String)


func _ready() -> void:
	add_theme_constant_override("separation", 6)


## Accende le domande dove la carta in mano puo' cadere.
func hold(places: Dictionary) -> void:
	held_places = places.duplicate()
	for where in slots:
		(slots[where] as Object).call("light", held_places.has(str(where)))


func render(session: RefCounted, viewer_id: String) -> void:
	_session = session
	_viewer = viewer_id
	_ensure_nodes()
	_say()


func _ensure_nodes() -> void:
	var theme_ids: Array = _session.data.themes.keys()
	theme_ids.sort()
	var alive: Dictionary = {}
	for theme_id in theme_ids:
		var id: String = str(theme_id)
		if not _themes.has(id):
			_themes[id] = _build_deck(id)
		(_themes[id] as Dictionary)["tokens"].queue_redraw()
		# La domanda di questo Tema in gioco, scoperta, sotto il suo nome.
		for tension_id in _session.world["tensions"]:
			var tid: String = str(tension_id)
			var about: Dictionary = _session.data.tensions.get(tid, {}) as Dictionary
			if str(about.get("theme", "")) != id:
				continue
			alive[tid] = true
			if _questions.has(tid):
				continue
			_questions[tid] = _build_card(id, tid)
	for tension_id in _questions.keys():
		if not alive.has(str(tension_id)):
			(_questions[tension_id] as Node).queue_free()
			_questions.erase(tension_id)
			slots.erase("tension:%s" % str(tension_id))


## L'intestazione di un mazzetto: il nome del Tema, e i gettoni coperti.
func _build_deck(theme_id: String) -> Dictionary:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	add_child(head)
	var button := Button.new()
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text = str((_session.data.themes[theme_id] as Dictionary).get("title", theme_id)).to_upper()
	# Largo quanto la colonna meno i gettoni: un bersaglio che dichiara solo la
	# larghezza del suo nome e' stretto quanto «VIE».
	button.custom_minimum_size = Vector2(WIDTH - TOKEN * 8.0 - 14.0, ROW)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color("#e8dcc8"))
	button.add_theme_color_override("font_hover_color", Color("#e8b563"))
	button.add_theme_color_override("font_pressed_color", Color("#e8b563"))
	button.pressed.connect(func() -> void: deck_pressed.emit(theme_id))
	head.add_child(button)
	var tokens := Control.new()
	tokens.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tokens.custom_minimum_size = Vector2(TOKEN * 2.0 * 4.0 + 8.0, ROW)
	tokens.draw.connect(_draw_tokens.bind(tokens, theme_id))
	head.add_child(tokens)
	return {"head": button, "tokens": tokens, "row": head}


## La carta girata di quel Tema: un posto dove una carta cade, e dentro la
## carta stessa, compatta — l'immagine, il titolo, e la riga che dice cos'e'.
func _build_card(theme_id: String, tension_id: String) -> Control:
	var slot: PanelContainer = DropSlot.new()
	slot.field = "tension"
	slot.key = tension_id
	slot.custom_minimum_size = Vector2(WIDTH, ROW)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.mouse_filter = Control.MOUSE_FILTER_STOP

	var card := FaceCard.new()
	card.compact = true
	card.set_size_name("piccola")
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(card)

	slot.card_dropped.connect(
		func(indices: Array) -> void: card_dropped_on_question.emit(indices)
	)
	slot.gui_input.connect(func(event: InputEvent) -> void:
		if not (event is InputEventMouseButton):
			return
		var press := event as InputEventMouseButton
		if not press.pressed or press.button_index != MOUSE_BUTTON_LEFT:
			return
		var where: String = "tension:%s" % tension_id
		if held_places.has(where):
			card_placed.emit(int(held_places[where]))
		else:
			tension_opened.emit(tension_id)
	)
	# Sotto il suo Tema: la colonna e' un VBox, e l'ordine e' il posto.
	add_child(slot)
	move_child(slot, ((_themes[theme_id] as Dictionary)["row"] as Node).get_index() + 1 + _under(theme_id))
	slots["tension:%s" % tension_id] = slot
	return slot


## Quante domande stanno gia' sotto questo Tema.
func _under(theme_id: String) -> int:
	var n: int = 0
	for tension_id in _questions:
		var about: Dictionary = _session.data.tensions.get(str(tension_id), {}) as Dictionary
		if str(about.get("theme", "")) == theme_id:
			n += 1
	return n


## Cosa si legge su ogni carta: la **faccia stampata** della Tensione (D-473),
## la stessa che va in stampa. Il mucchio dei gettoni sta sopra, sul mazzetto:
## finche' sono coperti si contano e non si leggono (D-450).
func _say() -> void:
	for tension_id in _questions:
		var id: String = str(tension_id)
		var slot: Control = _questions[id]
		var card: FaceCard = slot.get_child(0) as FaceCard
		var face: Dictionary = CardFace.of("tension", id, _session.data)
		# **Quanti gettoni ci sono, sulla scheda** (D-473, parola del
		# committente: *«sulla scheda potrebbe apparire quanti token ci
		# sono»*). Nell'angolo, dove una carta porta il suo numero: sono i
		# gettoni **coperti** caduti sul mazzetto di quel Tema, quindi si
		# contano e non si leggono (D-261).
		var counts: Dictionary = _session.world.get("theme_tokens", {}) as Dictionary
		var about: Dictionary = _session.data.tensions.get(id, {}) as Dictionary
		var fallen: int = int(counts.get(str(about.get("theme", "")), 0))
		if fallen > 0:
			face = face.duplicate()
			face["corner"] = "%d gettoni" % fallen if fallen > 1 else "1 gettone"
		card.render(face, _session.data)
		# La carta del mucchio piu' alto porta il bordo acceso: al tavolo e' il
		# mazzetto che sta per andare al Consiglio, e si vede da lontano.
		if not _session.tensions.piles_are_covered() and _session.tensions.hottest_pile() == id:
			card.mark(Color("#e8b563"))


## I gettoni caduti sul mazzetto, uno per uno, coperti: si contano, non si leggono.
func _draw_tokens(node: Control, theme_id: String) -> void:
	if _session == null:
		return
	var counts: Dictionary = _session.world.get("theme_tokens", {}) as Dictionary
	var fallen: int = int(counts.get(theme_id, 0))
	var y: float = node.size.y * 0.5
	for token in range(mini(fallen, 4)):
		var at: Vector2 = Vector2(TOKEN + float(token) * (TOKEN * 2.0), y)
		node.draw_circle(at, TOKEN * 0.8, Color("#b06b46"))
		node.draw_arc(at, TOKEN * 0.8, 0.0, TAU, 18, Color("#e8b563"), 1.0, true)
	if fallen > 4:
		node.draw_string(
			ThemeDB.fallback_font, Vector2(TOKEN * 9.0, y + 4.0), "+%d" % (fallen - 4),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#b06b46")
		)
