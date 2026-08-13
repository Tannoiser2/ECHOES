extends Control
## The board: six Regions, the roads between them, and who is standing where.
##
## Draws from WorldState and nothing else. It does not know a rule, cannot reach
## a decider, and never asks a question - `render(session, viewer_id)` is its
## whole input. That is what lets the same node serve a Chronicle played by a
## person and one played by four policies, and what will let 0.2 swap the
## rendering for real art without touching a line of engine code.
##
## `viewer_id` matters: a Region shows what *that seat* is entitled to see. It is
## the same rule the terminal follows (§11.1), applied to pixels.

const RegionArt := preload("res://scripts/core/region_art.gd")
const Glyph := preload("res://ui/glyph.gd")

## Quanto e' grande una tessera. Cresce con lo spazio che ha: a schermo intero
## una mappa di sei bolli piccoli in mezzo al vuoto spreca l'unica vista che
## racconta dove sono le cose - e il terreno, che e' il motivo per cui la tessera
## e' disegnata, a 46 pixel non si vede.
const RADIUS_MIN: float = 42.0
const RADIUS_MAX: float = 92.0
var _radius: float = RADIUS_MIN

## Region id -> centre, in pixels. Rebuilt on every resize.
var _points: Dictionary = {}
var _regions: Array = []
var _session: RefCounted
var _viewer: String = ""
var _hovered: String = ""

## Region ids the player may act on right now, mapped to whatever the caller
## wants back when one is pressed. The map does not decide what is in here and
## cannot: the set comes from the choices SeatDecider has already had the rules
## accept, so a Region is pressable exactly when the action is legal (D-039).
var highlighted: Dictionary = {}

signal region_clicked(region_id: String)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_relayout)


## The only way in. Called after every phase, and after every action.
func render(session: RefCounted, viewer_id: String) -> void:
	_session = session
	_viewer = viewer_id
	if _regions.is_empty():
		var ids: Array = (session.world["regions"] as Dictionary).keys()
		ids.sort()
		_regions = ids
	_relayout()
	queue_redraw()


func _relayout() -> void:
	if _session == null:
		return
	_points.clear()
	# Sei tessere e la mappa piu grande possibile che le contiene: il raggio esce
	# dallo spazio disponibile invece di essere una costante, cosi la stessa vista
	# funziona in una finestra stretta e a schermo intero.
	_radius = clampf(minf(size.x, size.y) * 0.17, RADIUS_MIN, RADIUS_MAX)
	var area: Vector2 = size - Vector2(_radius * 2.4, _radius * 2.8)
	var origin: Vector2 = Vector2(_radius * 1.2, _radius * 1.2)
	# Le coordinate scritte nei dati vanno da 0.16 a 0.81: prese alla lettera
	# lasciano un quinto di schermo vuoto in basso. Si allunga il **riquadro** che
	# le contiene fino a riempire lo spazio, il che sposta tutto insieme e non
	# cambia di una virgola dove sta una Regione rispetto alle altre.
	var low: Vector2 = Vector2(1.0, 1.0)
	var high: Vector2 = Vector2(0.0, 0.0)
	for region_id in _regions:
		var known: Variant = _session.data.regions.get(str(region_id))
		var spot: Variant = null if known == null else known.get("map_position")
		if spot == null:
			continue
		low = Vector2(minf(low.x, float(spot["x"])), minf(low.y, float(spot["y"])))
		high = Vector2(maxf(high.x, float(spot["x"])), maxf(high.y, float(spot["y"])))
	var span: Vector2 = Vector2(maxf(0.01, high.x - low.x), maxf(0.01, high.y - low.y))

	for i in range(_regions.size()):
		var region_id: String = str(_regions[i])
		var definition: Variant = _session.data.regions.get(region_id)
		var place: Variant = null if definition == null else definition.get("map_position")
		if place == null:
			# No authored position: fall back to a circle, so a Chronicle that
			# forgets its coordinates still draws something readable.
			var angle: float = TAU * float(i) / float(maxi(1, _regions.size())) - PI / 2.0
			_points[region_id] = size * 0.5 + Vector2(cos(angle), sin(angle)) * (minf(size.x, size.y) * 0.34)
		else:
			_points[region_id] = origin + Vector2(
				(float(place["x"]) - low.x) / span.x, (float(place["y"]) - low.y) / span.y
			) * area


## Only the Regions the current question offers answer to the mouse. A Region
## that lights up under the cursor and then does nothing when pressed reads as a
## broken game, so one that cannot be chosen does not light up at all.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var was: String = _hovered
		_hovered = _offered_at((event as InputEventMouseMotion).position)
		if was != _hovered:
			mouse_default_cursor_shape = (
				Control.CURSOR_POINTING_HAND if _hovered != "" else Control.CURSOR_ARROW
			)
			queue_redraw()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
			var hit: String = _offered_at(button.position)
			if hit != "":
				region_clicked.emit(hit)


func _offered_at(point: Vector2) -> String:
	var hit: String = _region_at(point)
	return hit if highlighted.has(hit) else ""


func _region_at(point: Vector2) -> String:
	for region_id in _points:
		if point.distance_to(_points[region_id]) <= _radius:
			return str(region_id)
	return ""


# --- drawing ----------------------------------------------------------------

func _draw() -> void:
	if _session == null or _points.is_empty():
		return
	_draw_roads()
	for region_id in _regions:
		_draw_region(str(region_id))


## Roads first, so the Regions sit on top of them. Drawn once per pair: the
## adjacency list holds both directions and drawing both leaves a doubled line
## that reads as a thicker, more important road.
##
## Due tratti invece di uno: una banda scura larga e un filo chiaro dentro. Una
## strada disegnata con una riga sola e' un collegamento in un diagramma; questa
## e' terra battuta, ed e' la lettura che la mappa deve dare - i posti sono
## posti, non nodi.
func _draw_roads() -> void:
	var drawn: Dictionary = {}
	for region_id in _regions:
		var definition: Variant = _session.data.regions.get(str(region_id))
		if definition == null:
			continue
		for other in definition["adjacency"]:
			var key: String = "|".join(PackedStringArray(
				[str(region_id), str(other)] if str(region_id) < str(other)
				else [str(other), str(region_id)]
			))
			if drawn.has(key) or not _points.has(str(other)):
				continue
			drawn[key] = true
			var from: Vector2 = _points[str(region_id)]
			var to: Vector2 = _points[str(other)]
			var along: Vector2 = (to - from).normalized()
			var start: Vector2 = from + along * (_radius * 0.86)
			var end: Vector2 = to - along * (_radius * 0.86)
			draw_line(start, end, Color("#2a241c"), 9.0, true)
			draw_line(start, end, Color("#4a4033"), 3.0, true)


func _draw_region(region_id: String) -> void:
	var centre: Vector2 = _points[region_id]
	var region: Dictionary = _session.world["regions"][region_id]
	var definition: Dictionary = _session.data.regions[region_id]
	var control: Variant = region.get("control", null)

	var offered: bool = highlighted.has(region_id)
	# Il terreno, generato dal bioma e dall'id: la tessera si riconosce da lontano
	# per quello che e', non per l'etichetta scritta sotto (D-057). Il centro
	# resta calmo perche' e' li che cadono presenze e segni.
	var art: Dictionary = RegionArt.plan(region_id, str(definition["biome"]))
	var box: Rect2 = Rect2(centre - Vector2(_radius, _radius), Vector2(_radius, _radius) * 2.0)
	var lift: float = 0.0
	if offered:
		lift += 0.10
	if _hovered == region_id:
		lift += 0.12
	_draw_terrain(art, box, lift)

	# The ring is who holds the place. No ring means nobody does, which is a
	# fact worth seeing rather than a blank.
	# Segue la sagoma della tessera: un cerchio sopra un esagono sarebbe una
	# seconda forma che non vuol dire niente.
	var ring: Color = Color("#4a4238")
	var width: float = 2.0
	if control != null:
		ring = _entity_colour(str(control))
		width = 4.0
	_draw_outline(art["outline"], box, ring, width)

	# A second ring, outside the first, for "you may go here". Outside because
	# the inner ring already means something else - who holds the place - and the
	# two facts have to stay separable at a glance.
	if offered:
		_draw_outline(
			art["outline"], box.grow(7.0),
			Color("#e8b563") if _hovered == region_id else Color("#7a6338"),
			3.0 if _hovered == region_id else 2.0
		)

	var font: Font = ThemeDB.fallback_font
	var name: String = str(definition["name"])
	var name_size: Vector2 = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(
		font, centre + Vector2(-name_size.x * 0.5, _radius + 16.0),
		name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d9d2c5")
	)

	_draw_presence(centre, region_id)
	_draw_marks(centre, region)


## Il terreno: la sagoma piena, poi i tratti del bioma. `lift` schiarisce tutto
## insieme - la tessera sotto il cursore e' la stessa tessera un po piu vicina
## alla luce, non un'altra tavolozza.
func _draw_terrain(art: Dictionary, box: Rect2, lift: float) -> void:
	draw_colored_polygon(_mapped(art["outline"], box), Color(str(art["ground"])).lightened(lift))
	for stroke in art["strokes"]:
		var item: Dictionary = stroke
		var colour: Color = Color(str(item["colour"])).lightened(lift)
		var at: PackedVector2Array = _mapped(item["points"], box)
		match str(item["kind"]):
			"poly":
				draw_colored_polygon(at, colour)
			"line":
				draw_polyline(at, colour, maxf(1.0, float(item["width"]) * box.size.x), true)
			"dot":
				draw_circle(at[0], float(item["width"]) * box.size.x, colour)


func _draw_outline(outline: Array, box: Rect2, colour: Color, width: float) -> void:
	var points: PackedVector2Array = _mapped(outline, box)
	points.append(points[0])
	draw_polyline(points, colour, width, true)


## Dal quadrato unitario del piano ai pixel di questa tessera.
func _mapped(points: Array, box: Rect2) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for point in points:
		out.append(box.position + (point as Vector2) * box.size)
	return out


## One dot per token, in a ring inside the circle. Counting tokens is something
## a player does constantly, so they are drawn as things to count rather than
## written as a number.
func _draw_presence(centre: Vector2, region_id: String) -> void:
	var tokens: Array = []
	for entity_id in _session.world["turn_order"]:
		var count: int = _session.service.presence_count(str(entity_id), region_id)
		for i in range(count):
			tokens.append(str(entity_id))
	if tokens.is_empty():
		return
	var step: float = TAU / float(maxi(tokens.size(), 3))
	for i in range(tokens.size()):
		var angle: float = -PI / 2.0 + step * float(i)
		var at: Vector2 = centre + Vector2(cos(angle), sin(angle)) * (_radius * 0.52)
		draw_circle(at, 7.0, _entity_colour(str(tokens[i])))
		draw_arc(at, 7.0, 0.0, TAU, 16, Color("#12100e"), 1.5, true)


## Conditions, structures and Scars, as small marks under the name. A Scar is
## drawn differently because it is the one mark that never comes off.
func _draw_marks(centre: Vector2, region: Dictionary) -> void:
	var marks: Array = []
	for tag in region["tags"]:
		var text: String = str(tag)
		for prefix in ["condition:", "structure:", "settlement:", "scar:"]:
			if text.begins_with(prefix):
				marks.append(text)
				break
	if marks.is_empty():
		return
	marks.sort()
	var font: Font = ThemeDB.fallback_font
	var y: float = _radius + 32.0
	for mark in marks:
		var level: String = str(mark).split(":")[0]
		var label: String = str(mark).split(":")[1]
		var tint: Color = Color("#c8553d") if level == "scar" else Color("#8a8172")
		# Il glifo dice di che *livello* e' il segno - una struttura, una
		# condizione, un insediamento, una Cicatrice - e la parola dice quale.
		# Prima c'era solo la parola, e quattro cose diverse si leggevano tutte
		# uguali: una fila di parole in grigio (ISSUES 6).
		var size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		var left: float = centre.x - (size.x + 14.0) * 0.5
		Glyph.paint(self, level, Rect2(Vector2(left, y - 9.0), Vector2(10.0, 10.0)), tint)
		draw_string(
			font, Vector2(left + 14.0, y), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, tint
		)
		y += 14.0


## Four colours, readable next to each other, handed out by seat rather than by
## name (D-050).
##
## They used to be a `match` on `ENT_ALDRIC` and its three neighbours, which was
## fine while there was one saga and stopped being fine the moment there were
## two: every house of the second one came out the same grey, on a map that is
## the same six places. The turn order is the right hook - it is per Chronicle,
## it is stable inside one, and it works for a saga nobody has written yet.
const SEAT_COLOURS: Array = ["#e8b563", "#6fa88a", "#7fa6c9", "#b06b8f", "#c8a86b", "#7f9a8b"]


func _entity_colour(entity_id: String) -> Color:
	if _session == null:
		return Color("#8a8172")
	var at: int = (_session.world["turn_order"] as Array).find(entity_id)
	if at < 0:
		return Color("#8a8172")
	return Color(str(SEAT_COLOURS[at % SEAT_COLOURS.size()]))
