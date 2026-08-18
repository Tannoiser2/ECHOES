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
const ArtLibrary := preload("res://scripts/core/art_library.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

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

## L'eco del cambiamento (l'inventario dell'app, ISSUES 22): al tavolo fisico
## vedi la mano che sposta il pezzo, sullo schermo il pezzo e' gia' spostato.
## Quando un effetto tocca una Regione, un anello ambra le si accende intorno
## e sfuma in qualche secondo - un'evidenza, non un'informazione: cosa sia
## cambiato lo dicono il verbale e i segnalini, questo dice solo *dove* guardare.
const ECHO_SECONDS: float = 6.0
var _echoes: Dictionary = {}

signal region_clicked(region_id: String)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_relayout)
	set_process(false)


## La Regione che un Effect applicato ha toccato, o "" se non ne tocca nessuna.
## Pura e statica, cosi' la mappa dei tipi sta in un posto solo ed e' provabile
## in headless. I no-op non accendono niente: non e' cambiato nulla.
static func region_of_effect(effect: Dictionary) -> String:
	if bool(effect.get("inverse_payload", {}).get("noop", false)):
		return ""
	var payload: Dictionary = effect.get("payload", {})
	match str(effect.get("type", "")):
		"SET_CONTROL", "SET_REGION_TAG", "REMOVE_REGION_TAG":
			return str(effect.get("target", {}).get("id", ""))
		"ADD_PRESENCE", "REMOVE_PRESENCE":
			return str(payload.get("region_id", ""))
		"ADD_SCAR", "REMOVE_SCAR":
			return str(payload.get("region_id", ""))
	return ""


func mark_changed(region_id: String) -> void:
	if region_id == "" or _session == null or not _session.world["regions"].has(region_id):
		return
	_echoes[region_id] = 1.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if _echoes.is_empty():
		set_process(false)
		return
	var gone: Array = []
	for region_id in _echoes:
		_echoes[region_id] = float(_echoes[region_id]) - delta / ECHO_SECONDS
		if float(_echoes[region_id]) <= 0.0:
			gone.append(region_id)
	for region_id in gone:
		_echoes.erase(region_id)
	queue_redraw()


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


## Il tabellone dipinto, se qualcuno l'ha messo in `res://art/map/board.png`.
## Quando c'e', il terreno generato si fa da parte: l'immagine **e'** il terreno,
## e la mappa disegna solo quello che il quadro non sa - chi tiene un posto, chi
## ci sta, cosa gli e' successo quest'anno.
func _board() -> Texture2D:
	return ArtLibrary.texture(ArtLibrary.BOARD)


## Il rettangolo del quadro dentro questa vista, a proporzioni rispettate.
func _board_rect(board: Texture2D) -> Rect2:
	var art: Vector2 = board.get_size()
	var scale: float = minf(size.x / art.x, size.y / art.y)
	var span: Vector2 = art * scale
	return Rect2((size - span) * 0.5, span)


func _relayout() -> void:
	if _session == null:
		return
	_points.clear()
	# Sei tessere e la mappa piu grande possibile che le contiene: il raggio esce
	# dallo spazio disponibile invece di essere una costante, cosi la stessa vista
	# funziona in una finestra stretta e a schermo intero.
	_radius = clampf(minf(size.x, size.y) * 0.17, RADIUS_MIN, RADIUS_MAX)

	# Con il quadro le coordinate dei dati si prendono **alla lettera**: chi ha
	# dipinto la mappa ha messo la citta' dove i dati dicevano che stava, e
	# allungare il riquadro come si fa senza quadro sposterebbe i segnalini fuori
	# dai posti dipinti.
	var board: Texture2D = _board()
	if board != null:
		var frame: Rect2 = _board_rect(board)
		# Le presenze stanno nelle aree calme che il quadro lascia libere, quindi
		# il raggio serve solo a tenerle raccolte e a dare un bersaglio al dito.
		_radius = clampf(minf(frame.size.x, frame.size.y) * 0.10, 30.0, 70.0)
		for region_id in _regions:
			var known: Variant = _session.data.regions.get(str(region_id))
			var spot: Variant = null if known == null else known.get("map_position")
			if spot == null:
				continue
			_points[str(region_id)] = frame.position + Vector2(
				float(spot["x"]), float(spot["y"])
			) * frame.size
		return
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
	var board: Texture2D = _board()
	if board != null:
		draw_texture_rect(board, _board_rect(board), false)
	else:
		# Senza quadro le strade sono disegnate; con il quadro ci sono gia'
		# dentro, e ridisegnarle sopra sarebbe una seconda mappa sulla prima.
		_draw_roads()
	for region_id in _regions:
		_draw_region(str(region_id))
	_draw_questions()


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
	if _board() != null:
		_draw_over_board(region_id, centre, control, offered)
		return
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
	# La tessera dipinta, se e' stata consegnata: ritagliata dentro l'esagono
	# invece che appoggiata sopra, cosi' la Regione resta una Regione e non
	# diventa un quadro con un bordo (D-059).
	var painted: Texture2D = ArtLibrary.texture(str(definition.get("art_prompt_key", "")))
	if painted != null:
		_draw_painted(art["outline"], box, painted, lift)
	else:
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

	_draw_echo(centre, region_id)
	_draw_presence(centre, region_id)
	_draw_marks(centre, region)


## Quello che il quadro non sa.
##
## Un velo scuro appena accennato sotto i segnalini - senza, un token chiaro su
## un campo chiaro sparisce - poi l'anello di chi tiene il posto, il nome e i
## segni. Nessuna sagoma piena: l'immagine sotto e' il pezzo forte, e coprirla
## sarebbe come stampare una mappa e incollarci sopra dei cerchi.
func _draw_over_board(region_id: String, centre: Vector2, control: Variant, offered: bool) -> void:
	var veil: float = 0.30
	if offered:
		veil += 0.10
	if _hovered == region_id:
		veil += 0.12
	draw_circle(centre, _radius, Color(0.07, 0.06, 0.05, veil))

	if control != null:
		draw_arc(centre, _radius, 0.0, TAU, 40, _entity_colour(str(control)), 3.0, true)
	if offered:
		draw_arc(
			centre, _radius + 6.0, 0.0, TAU, 40,
			Color("#e8b563") if _hovered == region_id else Color("#7a6338"),
			3.0 if _hovered == region_id else 2.0, true
		)

	var font: Font = ThemeDB.fallback_font
	var name: String = str(_session.data.regions[region_id]["name"])
	var name_size: Vector2 = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	# Il nome su un fondo dipinto ha bisogno di un'ombra per staccarsi: un solo
	# pixel di nero sotto, che e' il trucco piu' vecchio e ancora il migliore.
	var at: Vector2 = centre + Vector2(-name_size.x * 0.5, _radius + 16.0)
	draw_string(font, at + Vector2(1, 1), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0, 0, 0, 0.8))
	draw_string(font, at, name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#efe7d8"))

	_draw_echo(centre, region_id)
	_draw_presence(centre, region_id)
	_draw_marks(centre, _session.world["regions"][region_id])


## L'anello che sfuma: qualcosa e' appena successo qui. Fuori da tutti gli
## altri anelli, perche' quelli vogliono dire altro (chi tiene il posto, dove
## si puo' andare) e i tre fatti devono restare separabili a colpo d'occhio.
func _draw_echo(centre: Vector2, region_id: String) -> void:
	if not _echoes.has(region_id):
		return
	var strength: float = clampf(float(_echoes[region_id]), 0.0, 1.0)
	draw_arc(
		centre, _radius + 12.0, 0.0, TAU, 48,
		Color(0.91, 0.71, 0.39, 0.85 * strength), 2.0 + 2.5 * strength, true
	)


## I marker delle domande (l'inventario dell'app, ISSUES 22): ogni Tensione
## abita la Regione su cui la sua domanda verte adesso - la stessa regola del
## Consiglio (`focus_region`) - e li' pianta il suo marker con la lettura che
## spetta a chi guarda: il numero se ne ha diritto, il glifo spento se la
## questione e' velata (§11.1). I colori sono quelli del pannello: verde
## lontana, ambra a un passo, rossa a soglia.
func _draw_questions() -> void:
	var per_region: Dictionary = {}
	for tension_id in _session.world["tensions"]:
		var home: String = str(_session.confluence.narrative.focus_region(str(tension_id)))
		if home == "" or not _points.has(home):
			continue
		if not per_region.has(home):
			per_region[home] = []
		(per_region[home] as Array).append(str(tension_id))

	var font: Font = ThemeDB.fallback_font
	for region_id in per_region:
		var centre: Vector2 = _points[region_id]
		var at: Vector2 = centre + Vector2(_radius * 0.55, -_radius - 8.0)
		for tension_id in per_region[region_id]:
			var threshold: int = _session.tensions.threshold(str(tension_id))
			var value: int = _session.service.visible_tension_value(str(tension_id), _viewer)
			var reading: String = "?" if value < 0 else "%d/%d" % [value, threshold]
			var tint: Color = Color("#5f584c")
			if value >= 0:
				var margin: int = threshold - value
				tint = Color("#6fa88a")
				if margin <= 0:
					tint = Color("#c8553d")
				elif margin <= 1:
					tint = Color("#e8b563")
			Glyph.paint(self, "tension", Rect2(at, Vector2(11.0, 11.0)), tint)
			var text_at: Vector2 = at + Vector2(15.0, 10.0)
			draw_string(
				font, text_at + Vector2(1, 1), reading,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0, 0, 0, 0.8)
			)
			draw_string(font, text_at, reading, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, tint)
			at.y -= 15.0


## L'illustrazione dentro la sagoma. Le UV sono le stesse coordinate normalizzate
## del piano - il disegno generato e l'immagine vera occupano lo stesso quadrato,
## quindi il ritaglio coincide senza calcoli.
func _draw_painted(outline: Array, box: Rect2, painted: Texture2D, lift: float) -> void:
	var points: PackedVector2Array = _mapped(outline, box)
	var uvs: PackedVector2Array = PackedVector2Array()
	for point in outline:
		uvs.append(point as Vector2)
	draw_colored_polygon(points, Color(1, 1, 1).darkened(0.12 - lift), uvs, painted)


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
	var font: Font = get_theme_default_font()
	for i in range(tokens.size()):
		var angle: float = -PI / 2.0 + step * float(i)
		var at: Vector2 = centre + Vector2(cos(angle), sin(angle)) * (_radius * 0.52)
		draw_circle(at, 7.5, _entity_colour(str(tokens[i])))
		draw_arc(at, 7.5, 0.0, TAU, 16, Color("#12100e"), 1.5, true)
		# L'iniziale della casa, come sul segnalino della fustella (D-097):
		# il tondo sullo schermo e' lo stesso pezzo che si stampa e si punzona.
		var letter: String = str(tokens[i]).trim_prefix("ENT_").substr(0, 1)
		draw_string(
			font, at + Vector2(-3.5, 3.5), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, 10,
			Color("#12100e")
		)


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
		# La parola del segno viene dal dizionario condiviso (D-107): la stessa
		# che sta sul segnalino di cartone, non il suffisso inglese del tag.
		var label: String = SignLabels.label(str(mark), _session.data if _session != null else null)
		var tint: Color = Color("#c8553d") if level == "scar" else Color("#8a8172")
		# Il glifo dice di che *livello* e' il segno - una struttura, una
		# condizione, un insediamento, una Cicatrice - e la parola dice quale.
		# Prima c'era solo la parola, e quattro cose diverse si leggevano tutte
		# uguali: una fila di parole in grigio (ISSUES 6).
		var size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		# Sotto **questa** Regione: `y` e' la distanza dal centro, non una
		# posizione sullo schermo. Aggiungendo il glifo si e' persa la somma con
		# `centre` sull'asse verticale, e per un anno intero i segni di tutte e
		# sei le Regioni sono finiti in cima alla mappa, uno sull'altro. Non si
		# vedeva a inizio partita, perche' le Regioni cominciano senza segni.
		var at: Vector2 = Vector2(centre.x - (size.x + 14.0) * 0.5, centre.y + y)
		Glyph.paint(self, level, Rect2(at - Vector2(0.0, 9.0), Vector2(10.0, 10.0)), tint)
		# Sul quadro dipinto un grigio su terra bruciata non si legge: la stessa
		# ombra di un pixel che porta il nome della Regione.
		draw_string(
			font, at + Vector2(15.0, 1.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
			Color(0, 0, 0, 0.75)
		)
		draw_string(
			font, at + Vector2(14.0, 0.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, tint
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
