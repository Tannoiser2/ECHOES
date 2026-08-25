extends Control
## I sei mazzetti dei Temi, come stanno sul tavolo (D-279).
##
## Parola del committente: *«le domande devono essere i sei mazzetti dei sei
## tipi diversi e sopra vanno messi i segnalini che indicano quando sono caldi
## i mazzetti... dopo che vengono posti 2 (o tre) segnalini sopra un mazzetto
## si gira la prima carta per rivelare quale domanda sarà dibattuta»*.
##
## La regola il motore la esegue gia' da D-261: la Risonanza fa cadere gettoni
## **coperti** sul mazzetto del suo Tema, e al conto dichiarato
## (`theme_tokens.reveal_at`) la prima carta si gira. Quello che mancava era
## **vederlo**: sullo schermo c'era una riga di testo che nominava solo i Temi
## gia' caldi. Qui ci sono tutti e sei, sempre, con i loro gettoni sopra e la
## carta girata quando c'e' — che e' esattamente cio' che si vede al tavolo.
##
## Non decide niente e non legge una regola: prende la sessione e disegna.

const Glyph := preload("res://ui/glyph.gd")

## I sei Temi in due file da tre, come i mazzetti si posano.
const COLUMNS: int = 3
const DECK_RATIO: float = 1.4
const TOKEN: float = 9.0

var _session: RefCounted = null
var _themes: Array = []

## Il mazzetto sotto il dito, per il suggerimento.
var _hovered: String = ""

## Emesso quando si tocca un mazzetto: chi guarda vuole leggere la sua carta.
signal deck_pressed(theme_id: String)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)


func render(session: RefCounted) -> void:
	_session = session
	if _themes.is_empty():
		_themes = session.data.themes.keys()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var was: String = _hovered
		_hovered = _deck_at((event as InputEventMouseMotion).position)
		if was != _hovered:
			queue_redraw()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
			var hit: String = _deck_at(button.position)
			if hit != "":
				deck_pressed.emit(hit)


func _deck_at(point: Vector2) -> String:
	for i in range(_themes.size()):
		if _slot(i).has_point(point):
			return str(_themes[i])
	return ""


## Il posto di un mazzetto: due file da tre, e sopra ogni mazzetto la striscia
## dove cadono i gettoni.
func _slot(index: int) -> Rect2:
	var rows: int = int(ceil(float(maxi(1, _themes.size())) / float(COLUMNS)))
	var cell: Vector2 = Vector2(size.x / float(COLUMNS), size.y / float(rows))
	var at: Vector2 = Vector2(float(index % COLUMNS), float(index / COLUMNS)) * cell
	return Rect2(at + Vector2(4.0, 4.0), cell - Vector2(8.0, 8.0))


func _draw() -> void:
	if _session == null or _themes.is_empty():
		return
	var counts: Dictionary = _session.world.get("theme_tokens", {}) as Dictionary
	var fronts: Dictionary = _session.world.get("theme_front", {}) as Dictionary
	var reveal: int = int(_session.tensions.reveal_at())
	var font: Font = ThemeDB.fallback_font
	for i in range(_themes.size()):
		var theme_id: String = str(_themes[i])
		var box: Rect2 = _slot(i)
		var fallen: int = int(counts.get(theme_id, 0))
		var front: String = str(fronts.get(theme_id, ""))

		# La striscia dei gettoni sta **sopra** il mazzetto, come sul tavolo.
		var strip: float = TOKEN * 2.2
		var deck: Rect2 = Rect2(
			box.position + Vector2(0.0, strip), Vector2(box.size.x, box.size.y - strip)
		)
		# Il dorso: un rettangolo scuro col bordo caldo se il mazzetto ha
		# gettoni sopra. Un mazzetto freddo si vede lo stesso — e' li' anche
		# quando non succede niente, e questo e' il punto.
		var warm: bool = fallen > 0
		draw_rect(deck, Color("#1b1815"), true)
		draw_rect(
			deck, Color("#b06b46") if warm else Color("#3a332a"), false, 2.0 if warm else 1.0
		)
		if _hovered == theme_id:
			draw_rect(deck.grow(2.0), Color("#e8b563"), false, 1.0)

		var title: String = str(
			(_session.data.themes[theme_id] as Dictionary).get("title", theme_id)
		)
		draw_string(
			font, deck.position + Vector2(8.0, 16.0), title.to_upper(),
			HORIZONTAL_ALIGNMENT_LEFT, deck.size.x - 12.0, 11, Color("#e8dcc8")
		)

		# I gettoni caduti, uno per uno: quello che il tavolo **vede**. Quanto
		# valgono non si dice — sono coperti fino a fine Atto (D-261).
		for token in range(mini(fallen, 8)):
			var at: Vector2 = box.position + Vector2(
				TOKEN + float(token) * (TOKEN * 1.7), TOKEN
			)
			draw_circle(at, TOKEN * 0.62, Color("#b06b46"))
			draw_arc(at, TOKEN * 0.62, 0.0, TAU, 18, Color("#e8b563"), 1.0, true)
		if fallen > 8:
			draw_string(
				font, box.position + Vector2(TOKEN * 15.0, TOKEN + 4.0), "+%d" % (fallen - 8),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#b06b46")
			)

		# La carta girata, o quanto manca a girarla: la sola cosa che il
		# giocatore deve poter leggere da lontano.
		var said: String = ""
		var tint: Color = Color("#8a8172")
		if front != "":
			said = str((_session.data.tensions[front] as Dictionary)["title"])
			tint = Color("#e8b563")
		elif fallen > 0:
			said = "coperto — %d al giro" % maxi(0, reveal - fallen)
		else:
			said = "freddo"
		draw_string(
			font, deck.position + Vector2(8.0, deck.size.y - 10.0), said,
			HORIZONTAL_ALIGNMENT_LEFT, deck.size.x - 12.0, 12, tint
		)
