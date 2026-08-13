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

const RADIUS: float = 46.0

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
	var area: Vector2 = size - Vector2(RADIUS * 2.4, RADIUS * 2.4)
	var origin: Vector2 = Vector2(RADIUS * 1.2, RADIUS * 1.2)
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
			_points[region_id] = origin + Vector2(float(place["x"]), float(place["y"])) * area


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
		if point.distance_to(_points[region_id]) <= RADIUS:
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
			draw_line(
				from + along * RADIUS, to - along * RADIUS,
				Color("#3a332a"), 3.0, true
			)


func _draw_region(region_id: String) -> void:
	var centre: Vector2 = _points[region_id]
	var region: Dictionary = _session.world["regions"][region_id]
	var definition: Dictionary = _session.data.regions[region_id]
	var control: Variant = region.get("control", null)

	var offered: bool = highlighted.has(region_id)
	var fill: Color = Color("#1c1915")
	if offered:
		fill = Color("#2a2418")
	if _hovered == region_id:
		fill = fill.lightened(0.14)
	draw_circle(centre, RADIUS, fill)

	# The ring is who holds the place. No ring means nobody does, which is a
	# fact worth seeing rather than a blank.
	var ring: Color = Color("#4a4238")
	var width: float = 2.0
	if control != null:
		ring = _entity_colour(str(control))
		width = 4.0
	draw_arc(centre, RADIUS, 0.0, TAU, 48, ring, width, true)

	# A second ring, outside the first, for "you may go here". Outside because
	# the inner ring already means something else - who holds the place - and the
	# two facts have to stay separable at a glance.
	if offered:
		draw_arc(
			centre, RADIUS + 7.0, 0.0, TAU, 48,
			Color("#e8b563") if _hovered == region_id else Color("#7a6338"),
			3.0 if _hovered == region_id else 2.0, true
		)

	var font: Font = ThemeDB.fallback_font
	var name: String = str(definition["name"])
	var name_size: Vector2 = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(
		font, centre + Vector2(-name_size.x * 0.5, RADIUS + 16.0),
		name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d9d2c5")
	)

	_draw_presence(centre, region_id)
	_draw_marks(centre, region)


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
		var at: Vector2 = centre + Vector2(cos(angle), sin(angle)) * (RADIUS * 0.52)
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
	var y: float = RADIUS + 32.0
	for mark in marks:
		var scarred: bool = str(mark).begins_with("scar:")
		var label: String = str(mark).split(":")[1]
		var width: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		draw_string(
			font, centre + Vector2(-width.x * 0.5, y), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
			Color("#c8553d") if scarred else Color("#8a8172")
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
