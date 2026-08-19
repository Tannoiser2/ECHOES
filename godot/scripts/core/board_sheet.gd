extends RefCounted
## Il tabellone in SVG, per la vetrina (D-145).
##
## La mappa sullo schermo grande la disegna `ui/map_view.gd` col canvas di
## Godot; la vetrina e' una pagina in un browser e non ha quel canvas. Fin qui
## mostrava un elenco di riquadri — «Eredan · di Re Aldric · Re Aldric ×1» —
## cioe' la mappa raccontata invece che disegnata, e da bordo tavolo una mappa
## raccontata non e' una mappa.
##
## Qui non si ridisegna niente: si **rileggono gli stessi piani**. Le sagome
## delle tessere e i tratti del terreno vengono da `RegionArt.plan` (coordinate
## normalizzate, quindi valgono su qualunque superficie, D-057); le pedine e i
## vessilli da `IconSet` (icone come dati, D-058); i colori dei seggi dallo
## stesso ordine di turno di `map_view` (D-050). Una tessera che cambia nei dati
## cambia sul canvas, sulla fustella e qui, insieme.
##
## Nessun viewer: il tabellone e' pubblico per costruzione — presenze,
## controllo e segni di una Regione sono fatti che il tavolo vede. Quello che
## non e' del tavolo (le mani, i Destini, i numeri delle domande velate) qui non
## entra proprio, e la perquisizione della vetrina lo prova (D-144).

const RegionArt := preload("res://scripts/core/region_art.gd")
const IconSet := preload("res://scripts/core/icon_set.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

## Il foglio, in unita' SVG. Le Regioni stanno su una griglia normalizzata
## (`map_position`, 0..1), quindi il foglio decide solo quanto e' grande.
const WIDTH: float = 900.0
const HEIGHT: float = 560.0
const TILE: float = 132.0
const MARGIN: float = 74.0

## Gli stessi sei colori di `map_view`, nello stesso ordine e per la stessa
## ragione: il seggio, non il nome (D-050).
const SEAT_COLOURS: Array = ["#e8b563", "#6fa88a", "#7fa6c9", "#b06b8f", "#c8a86b", "#7f9a8b"]

const INK: String = "#12100e"
const PAPER: String = "#1a1712"
const LABEL: String = "#d9d2c5"


## Il tabellone di una partita: terreno, strade, presenze, vessilli, segni.
static func board_svg(session: RefCounted) -> String:
	var world: Dictionary = session.world
	var data: RefCounted = session.data
	var points: Dictionary = _points(world, data)

	var out: Array = []
	out.append(
		'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %.0f %.0f" width="%.0f" height="%.0f">'
		% [WIDTH, HEIGHT, WIDTH, HEIGHT]
	)
	# Nessun fondo: il tabellone si posa sulla pagina che lo ospita invece di
	# ritagliarci dentro un rettangolo di un altro nero. Il colore della carta
	# resta come riferimento per chi un domani lo vorra' stampare.

	out.append_array(_roads(world, data, points))
	for region_id in _sorted(world["regions"].keys()):
		out.append_array(_region(session, str(region_id), points))
	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


## Dove sta ogni Regione. `map_position` e' d'autore e normalizzata; una
## Chronicle che non la scrive finisce in cerchio, come sul canvas — meglio una
## mappa storta di una mappa che non c'e'.
static func _points(world: Dictionary, data: RefCounted) -> Dictionary:
	var points: Dictionary = {}
	var ids: Array = _sorted(world["regions"].keys())
	var index: int = 0
	for region_id in ids:
		var definition: Variant = data.regions.get(str(region_id))
		var spot: Variant = null if definition == null else definition.get("map_position")
		if spot == null:
			var angle: float = TAU * float(index) / float(maxi(1, ids.size())) - PI * 0.5
			points[str(region_id)] = Vector2(WIDTH, HEIGHT) * 0.5 + Vector2(
				cos(angle), sin(angle)
			) * (minf(WIDTH, HEIGHT) * 0.32)
		else:
			points[str(region_id)] = Vector2(
				MARGIN + float((spot as Dictionary)["x"]) * (WIDTH - MARGIN * 2.0),
				MARGIN + float((spot as Dictionary)["y"]) * (HEIGHT - MARGIN * 2.0)
			)
		index += 1
	return points


## Le strade fra Regioni adiacenti. L'adiacenza e' scritta nei due sensi:
## disegnare entrambi lascia una linea doppia, quindi si disegna una volta sola.
static func _roads(world: Dictionary, data: RefCounted, points: Dictionary) -> Array:
	var out: Array = []
	var done: Dictionary = {}
	for region_id in _sorted(world["regions"].keys()):
		var definition: Variant = data.regions.get(str(region_id))
		if definition == null:
			continue
		for other in (definition as Dictionary).get("adjacency", []):
			if not points.has(str(other)):
				continue
			var key: String = "|".join(PackedStringArray(
				[str(region_id), str(other)] if str(region_id) < str(other)
				else [str(other), str(region_id)]
			))
			if done.has(key):
				continue
			done[key] = true
			var from: Vector2 = points[str(region_id)]
			var to: Vector2 = points[str(other)]
			var along: Vector2 = (to - from).normalized()
			var start: Vector2 = from + along * (TILE * 0.43)
			var end: Vector2 = to - along * (TILE * 0.43)
			out.append(
				'<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#2a241c" stroke-width="9" stroke-linecap="round"/>'
				% [start.x, start.y, end.x, end.y]
			)
			out.append(
				'<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#4a4033" stroke-width="3" stroke-linecap="round"/>'
				% [start.x, start.y, end.x, end.y]
			)
	return out


static func _region(session: RefCounted, region_id: String, points: Dictionary) -> Array:
	var world: Dictionary = session.world
	var data: RefCounted = session.data
	var definition: Dictionary = data.regions[region_id]
	var region: Dictionary = world["regions"][region_id]
	var centre: Vector2 = points[region_id]
	var origin: Vector2 = centre - Vector2(TILE, TILE) * 0.5
	var plan: Dictionary = RegionArt.plan(region_id, str(definition["biome"]))

	# Il gruppo porta l'id della Regione e il suo centro: la console lo usa per
	# accendere le Regioni raggiungibili e per capire dove e' caduto il dito
	# (D-146). La vetrina se ne infischia — un tocco sul tabellone non ha
	# identita' di seggio (la C della seduta) — ma il marchio non le costa
	# niente, e una mappa che si sa nominare serve a chi la guarda comunque.
	var out: Array = []
	out.append(
		'<g class="regione" data-region="%s" data-x="%.1f" data-y="%.1f"><title>%s</title>'
		% [region_id, centre.x, centre.y, _escape(str(definition["name"]))]
	)
	out.append(_polygon(plan["outline"], origin, TILE, str(plan["ground"]), "", 0.0))
	for stroke in plan["strokes"]:
		out.append(_stroke(stroke, origin, TILE))

	# L'anello e' chi tiene il posto; nessun anello vuol dire nessuno, ed e' un
	# fatto che vale la pena vedere invece di un vuoto.
	var control: Variant = region.get("control", null)
	var ring: String = "#4a4238" if control == null else _seat_colour(world, str(control))
	out.append(_polygon(plan["outline"], origin, TILE, "none", ring, 2.0 if control == null else 4.0))

	# Il cerchio d'oro «puoi andare qui», spento: lo accende la console quando
	# una domanda offre quella Regione. Sta nell'SVG e non nel CSS perche' la
	# sagoma della tessera la conosce solo chi l'ha disegnata.
	out.append(_polygon(
		plan["outline"], origin - Vector2(7.0, 7.0), TILE + 14.0, "none", "#e8b563", 3.0
	).replace("<path ", '<path class="raggiungibile" '))

	out.append(
		'<text x="%.1f" y="%.1f" fill="%s" font-family="Georgia, serif" font-size="15" text-anchor="middle">%s</text>'
		% [centre.x, centre.y + TILE * 0.5 + 18.0, LABEL, _escape(str(definition["name"]))]
	)

	# Le pedine: una per presenza, in fila sotto il centro. Si contano con la
	# coda dell'occhio come i pezzi veri (D-138).
	var pawns: Array = []
	for entity_id in world["turn_order"]:
		var count: int = session.service.presence_count(str(entity_id), region_id)
		for _i in range(count):
			pawns.append(_seat_colour(world, str(entity_id)))
	var step: float = 21.0
	var start_x: float = centre.x - (float(pawns.size() - 1) * step) * 0.5
	for i in range(pawns.size()):
		out.append(_piece("pawn", Vector2(start_x + float(i) * step, centre.y + 12.0), 26.0, str(pawns[i])))

	# Il vessillo del controllo, piantato sul bordo alto: non si conta, si pianta.
	if control != null:
		out.append(_piece(
			"banner", Vector2(centre.x, centre.y - TILE * 0.42), 24.0, _seat_colour(world, str(control))
		))

	# I segni della Regione, sotto il nome: quello che il posto si porta dietro.
	var marks: Array = []
	for tag in region["tags"]:
		for prefix in ["condition:", "scar:", "structure:", "settlement:"]:
			if str(tag).begins_with(prefix):
				marks.append(SignLabels.label(str(tag), data))
				break
	if not marks.is_empty():
		out.append(
			'<text x="%.1f" y="%.1f" fill="#8a8172" font-family="Georgia, serif" font-size="11" text-anchor="middle">%s</text>'
			% [centre.x, centre.y + TILE * 0.5 + 33.0, _escape(", ".join(PackedStringArray(marks)))]
		)
	out.append("</g>")
	return out


## Un pezzo del set delle icone: l'ombra, il contorno scuro che lo tiene
## leggibile su qualunque fondo, e la sagoma nel colore della casa (D-138).
static func _piece(glyph: String, at: Vector2, side: float, colour: String) -> String:
	return (
		'<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="rgba(5,4,3,0.40)"/>'
		% [at.x, at.y + side * 0.34, side * 0.30, side * 0.18]
		+ _glyph_svg(glyph, at, side * 1.10, INK)
		+ _glyph_svg(glyph, at, side, colour)
	)


static func _glyph_svg(name: String, at: Vector2, side: float, colour: String) -> String:
	var origin: Vector2 = at - Vector2(side, side) * 0.5
	var out: Array = []
	for stroke in IconSet.glyph(name):
		var item: Dictionary = stroke
		var points: Array = []
		for point in item["points"]:
			points.append(origin + (point as Vector2) * side)
		match str(item["kind"]):
			"poly":
				out.append(_path(points, colour, "", 0.0))
			"line":
				out.append(_path(points, "none", colour, maxf(1.0, float(item["width"]) * side)))
			"dot":
				out.append(
					'<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>'
					% [points[0].x, points[0].y, float(item["width"]) * side * 0.5, colour]
				)
	return "".join(PackedStringArray(out))


static func _polygon(
	outline: Array, origin: Vector2, side: float, fill: String, stroke: String, width: float
) -> String:
	var points: Array = []
	for point in outline:
		points.append(origin + (point as Vector2) * side)
	return _path(points, fill, stroke, width)


static func _stroke(stroke: Dictionary, origin: Vector2, side: float) -> String:
	var points: Array = []
	for point in stroke["points"]:
		points.append(origin + (point as Vector2) * side)
	match str(stroke["kind"]):
		"poly":
			return _path(points, str(stroke["colour"]), "", 0.0)
		"line":
			return _path(points, "none", str(stroke["colour"]), maxf(0.6, float(stroke["width"]) * side))
		"dot":
			return (
				'<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>'
				% [points[0].x, points[0].y, float(stroke["width"]) * side * 0.5, str(stroke["colour"])]
			)
	return ""


static func _path(points: Array, fill: String, stroke: String, width: float) -> String:
	if points.is_empty():
		return ""
	var parts: Array = []
	for i in range(points.size()):
		parts.append("%s%.1f %.1f" % ["M" if i == 0 else "L", points[i].x, points[i].y])
	var closing: String = " Z" if fill != "none" and fill != "" else ""
	var paint: String = 'fill="%s"' % (fill if fill != "" else "none")
	if stroke != "" and stroke != "none":
		paint += ' stroke="%s" stroke-width="%.1f" stroke-linecap="round" stroke-linejoin="round"' % [
			stroke, width
		]
	return '<path d="%s%s" %s/>' % [" ".join(PackedStringArray(parts)), closing, paint]


static func _seat_colour(world: Dictionary, entity_id: String) -> String:
	var at: int = (world["turn_order"] as Array).find(entity_id)
	if at < 0:
		return "#8a8172"
	return str(SEAT_COLOURS[at % SEAT_COLOURS.size()])


static func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out


static func _escape(text: String) -> String:
	return (
		text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")
	)
