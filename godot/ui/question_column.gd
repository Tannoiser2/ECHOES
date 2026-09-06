extends VBoxContainer
## **La colonna delle domande** (D-464, parola del committente: *«le tensioni
## devono gia' essere scoperte, e sopra di esse devono finirci coperti i token
## che scaldano. Potrebbero essere messi su una colonna a sinistra»*).
##
## Sei Temi, uno sotto l'altro, come i sei mazzetti in fila sul bordo del
## tavolo: il nome del Tema, i gettoni **coperti** che ci sono caduti sopra —
## quanti, non quanto valgono (D-261) — e sotto, scoperte, le domande di
## quel Tema in gioco quest'anno. Ogni domanda e' un posto alto un dito dove
## una carta puo' cadere (INFLUENZARE, TRAMARE), e toccarla la legge.
##
## Non decide niente: prende la sessione e la mostra.

const DropSlot := preload("res://ui/drop_slot.gd")

## Alto come un dito (D-243).
const ROW: float = 44.0
const WIDTH: float = 230.0
const TOKEN: float = 8.0

var _session: RefCounted = null
var _viewer: String = ""

## `theme_id -> {"head": Button, "tokens": Control}` e `tension_id -> DropSlot`.
var _themes: Dictionary = {}
var _questions: Dictionary = {}

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
	add_theme_constant_override("separation", 4)


## Accende le domande dove la carta in mano puo' cadere.
func hold(places: Dictionary) -> void:
	held_places = places.duplicate()
	for tension_id in _questions:
		(_questions[tension_id] as Object).call(
			"light", held_places.has("tension:%s" % str(tension_id))
		)


func render(session: RefCounted, viewer_id: String) -> void:
	_session = session
	_viewer = viewer_id
	_ensure_nodes()
	_say()


func _ensure_nodes() -> void:
	var theme_ids: Array = _session.data.themes.keys()
	theme_ids.sort()
	var counts: Dictionary = _session.world.get("theme_tokens", {}) as Dictionary
	var alive: Dictionary = {}
	for theme_id in theme_ids:
		var id: String = str(theme_id)
		if not _themes.has(id):
			var head := HBoxContainer.new()
			head.add_theme_constant_override("separation", 6)
			add_child(head)
			var button := Button.new()
			button.flat = true
			button.focus_mode = Control.FOCUS_NONE
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.text = str((_session.data.themes[id] as Dictionary).get("title", id)).to_upper()
			# Largo quanto la colonna meno i gettoni: un bersaglio che
			# dichiara solo la larghezza del suo nome e' stretto quanto «VIE».
			button.custom_minimum_size = Vector2(WIDTH - TOKEN * 8.0 - 14.0, ROW)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.add_theme_font_size_override("font_size", 11)
			button.add_theme_color_override("font_color", Color("#e8dcc8"))
			button.add_theme_color_override("font_hover_color", Color("#e8b563"))
			button.add_theme_color_override("font_pressed_color", Color("#e8b563"))
			button.pressed.connect(func() -> void: deck_pressed.emit(id))
			head.add_child(button)
			var tokens := Control.new()
			tokens.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tokens.custom_minimum_size = Vector2(TOKEN * 2.0 * 4.0 + 8.0, ROW)
			tokens.draw.connect(_draw_tokens.bind(tokens, id))
			head.add_child(tokens)
			_themes[id] = {"head": button, "tokens": tokens, "row": head}
		(_themes[id] as Dictionary)["tokens"].queue_redraw()
		# Le domande di questo Tema in gioco, scoperte, sotto il suo nome.
		for tension_id in _session.world["tensions"]:
			var tid: String = str(tension_id)
			var about: Dictionary = _session.data.tensions.get(tid, {}) as Dictionary
			if str(about.get("theme", "")) != id:
				continue
			alive[tid] = true
			if _questions.has(tid):
				continue
			var slot: PanelContainer = DropSlot.new()
			slot.field = "tension"
			slot.key = tid
			# Largo quanto la colonna, non quanto il testo: dentro uno
			# scorrimento un'etichetta che va a capo parte da zero, e a zero
			# non si vede niente.
			slot.custom_minimum_size = Vector2(WIDTH, ROW)
			slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slot.mouse_filter = Control.MOUSE_FILTER_STOP
			var line := Label.new()
			line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line.size_flags_vertical = Control.SIZE_EXPAND_FILL
			line.custom_minimum_size = Vector2(WIDTH - 8.0, ROW - 4.0)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			line.add_theme_font_size_override("font_size", 13)
			line.add_theme_color_override("font_color", Color("#c9bfae"))
			line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			line.clip_text = true
			slot.add_child(line)
			slot.card_dropped.connect(
				func(indices: Array) -> void: card_dropped_on_question.emit(indices)
			)
			slot.gui_input.connect(func(event: InputEvent) -> void:
				if not (event is InputEventMouseButton):
					return
				var press := event as InputEventMouseButton
				if not press.pressed or press.button_index != MOUSE_BUTTON_LEFT:
					return
				var where: String = "tension:%s" % tid
				if held_places.has(where):
					card_placed.emit(int(held_places[where]))
				else:
					tension_opened.emit(tid)
			)
			# Sotto il suo Tema: la colonna e' un VBox, e l'ordine e' il posto.
			add_child(slot)
			move_child(slot, ((_themes[id] as Dictionary)["row"] as Node).get_index() + 1 + _under(id))
			_questions[tid] = slot
	for tension_id in _questions.keys():
		if not alive.has(str(tension_id)):
			(_questions[tension_id] as Node).queue_free()
			_questions.erase(tension_id)
	var _unused: int = counts.size()


## Quante domande stanno gia' sotto questo Tema.
func _under(theme_id: String) -> int:
	var n: int = 0
	for tension_id in _questions:
		var about: Dictionary = _session.data.tensions.get(str(tension_id), {}) as Dictionary
		if str(about.get("theme", "")) == theme_id:
			n += 1
	return n


## Cosa si legge su ogni domanda: **quello che il tavolo sa** (D-450) — il
## titolo, e il mucchio dei gettoni finche' sono coperti.
func _say() -> void:
	for tension_id in _questions:
		var id: String = str(tension_id)
		var slot: Control = _questions[id]
		var line: Label = slot.get_child(0) as Label
		var tint: Color = Color("#c9bfae")
		if _session.tensions.table_gate() > 0:
			line.text = _session.tensions.public_status(id)
			if not _session.tensions.piles_are_covered() and _session.tensions.hottest_pile() == id:
				tint = Color("#e8b563")
		else:
			var threshold: int = _session.tensions.threshold(id)
			var value: int = _session.service.visible_tension_value(id, _viewer)
			var title: String = str(_session.data.tensions[id]["title"])
			line.text = title if value < 0 else "%s · %d/%d" % [title, value, threshold]
		line.add_theme_color_override("font_color", tint)


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
