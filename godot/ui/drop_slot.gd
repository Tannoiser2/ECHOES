extends PanelContainer
## Un posto del tavolo dove una carta puo' cadere (D-231).
##
## La mappa ha le Regioni; le domande e le case no, e finche' non ce l'hanno le
## carte che parlano a loro — INFLUENZARE, TRAMARE, FORGIARE — restano bottoni.
## Questo e' il posto: si mette intorno a una riga della traccia o a una riga dei
## rapporti, e da quel momento quella riga **e' un bersaglio**.
##
## Non decide niente, come la mappa: accetta una carta esattamente quando quella
## carta porta una scelta **per questo soggetto**, e le scelte gliele ha gia'
## passate le regole (D-039). Quando la carta cade, dice **quali** scelte sono —
## al plurale, perche' su una domanda una carta puo' sapere fare due cose
## opposte, alzarla e abbassarla, e a quel punto la scelta e' di chi gioca.
##
## Al tavolo e' cosi': posi la carta sulla domanda, e *poi* dici se la alzi o la
## abbassi.

## Di che cosa parla questo posto: `"tension"` o `"entity"`.
var field: String = ""

## Quale, per nome: l'id della domanda o della casa.
var key: String = ""

var _lit: bool = false

## Le scelte che la carta caduta porta per questo soggetto, in ordine.
signal card_dropped(indices: Array)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_paint(false)


func _can_drop_data(_at: Vector2, payload: Variant) -> bool:
	var found: Array = _matching(payload)
	if found.is_empty():
		if _lit:
			_paint(false)
		return false
	if not _lit:
		_paint(true)
	return true


func _drop_data(_at: Vector2, payload: Variant) -> void:
	var found: Array = _matching(payload)
	_paint(false)
	if not found.is_empty():
		card_dropped.emit(found)


## Le scelte che questa carta porta per questo soggetto.
func _matching(payload: Variant) -> Array:
	if field == "" or key == "" or typeof(payload) != TYPE_DICTIONARY:
		return []
	var carried: Dictionary = payload as Dictionary
	if str(carried.get("kind", "")) != "asset":
		return []
	var found: Array = []
	for offer in carried.get("offers", []):
		var entry: Dictionary = offer as Dictionary
		if str(entry.get(field, "")) == key:
			found.append(int(entry.get("index", -1)))
	return found


## Il posto acceso perche' **si tiene una carta in mano** (D-239), non perche'
## una carta ci sta passando sopra. Su un tablet il trascinamento non c'e': i
## posti dove la carta scelta puo' andare si accendono tutti insieme, e si tocca
## quello che si vuole. E' la stessa luce, chiesta da un gesto diverso.
func light(on: bool) -> void:
	_paint(on)


## Il posto si accende sotto la carta che sta arrivando, come l'anello d'oro
## sulla mappa: chi trascina vede dove sta per lasciare prima di lasciare.
func _paint(lit: bool) -> void:
	_lit = lit
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#e8b563") if lit else Color(0, 0, 0, 0)
	style.bg_color.a = 0.16 if lit else 0.0
	style.border_color = Color("#e8b563") if lit else Color(0, 0, 0, 0)
	style.set_border_width_all(1 if lit else 0)
	style.set_corner_radius_all(3)
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	add_theme_stylebox_override("panel", style)


## Godot smette di chiedere `_can_drop_data` quando il puntatore esce: senza
## questo il posto resterebbe acceso dopo che la carta se n'e' andata altrove.
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _lit:
		_paint(false)
