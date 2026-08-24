extends RefCounted
## Il terreno di una Regione, disegnato invece che dipinto (ART_BIBLE §MASTER
## PROMPT 3, §21).
##
## La ART_BIBLE divide il lavoro in due: l'**illustrazione** la fa una persona,
## la **grafica di sistema** la fa il codice - vettoriale, semi-piatta, leggibile
## sopra qualunque cosa. Le tessere Regione stanno sul confine fra le due, e
## questa e' la meta' che tocca al codice: la sagoma del terreno, il bioma che si
## riconosce da lontano, il centro lasciato calmo perche' e' li' che vanno i
## segnalini.
##
## Non e' un ripiego in attesa dell'arte vera. Sei Regioni, sei biomi diversi, e
## quello che un giocatore deve leggere in un colpo d'occhio - *dove sono, cosa
## c'e' qui* - non e' un dettaglio pittorico: e' una silhouette e un colore, ed
## entrambi si generano.
##
## **Un disegno, due supporti.** Restituisce un piano in coordinate normalizzate
## (0..1 nel quadrato della tessera) che disegnano sia `map_view.gd` con le
## primitive di Godot sia `print_sheet.gd` in SVG. La tessera sullo schermo e la
## tessera che si stampa sono la stessa immagine, non due che si somigliano.
##
## Deterministico dalla sola `region_id`: due Regioni dello stesso bioma escono
## diverse, e la stessa Regione esce identica a ogni partita e a ogni export.
## Non tocca l'RNG della sessione - non deve entrare nel flusso di estrazioni.

const ArtPlaceholder := preload("res://scripts/core/art_placeholder.gd")

## Il centro resta calmo: e' dove cadono controllo, presenze, condizioni e Scar
## (ART_BIBLE, MASTER PROMPT 3). Il dettaglio si concentra ai bordi.
const CALM_RADIUS: float = 0.30

## Un colore di terra, uno di rilievo e l'accento del bioma, presi dalla
## variation key della ART_BIBLE. L'accento e' l'unico colore saturo ammesso.
const BIOMES: Dictionary = {
	"CITY": {"ground": "#2a2318", "relief": "#4a3a28", "accent": "#e8b563"},
	"VALLEY": {"ground": "#232a1e", "relief": "#36432c", "accent": "#6fa88a"},
	"STEPPE": {"ground": "#2b2820", "relief": "#4a4130", "accent": "#c9a86a"},
	"MOUNTAIN": {"ground": "#2a2320", "relief": "#463129", "accent": "#c8553d"},
	"UNDERGROUND": {"ground": "#1e2426", "relief": "#2f3a3a", "accent": "#7fa6c9"},
	"ROAD": {"ground": "#2a2419", "relief": "#4a4030", "accent": "#c9a86a"},
	"FOREST": {"ground": "#1f2a1f", "relief": "#2f3f2b", "accent": "#6fa88a"},
	"COAST": {"ground": "#202a2e", "relief": "#2c3c46", "accent": "#7fa6c9"},
	"MARSH": {"ground": "#20261e", "relief": "#33402f", "accent": "#8fae7a"},
	"ISLAND": {"ground": "#1d2530", "relief": "#2a3a4a", "accent": "#9db8d2"},
}
const UNKNOWN: Dictionary = {"ground": "#241f19", "relief": "#3a332a", "accent": "#8a8172"}


static func palette(biome: String) -> Dictionary:
	return BIOMES.get(biome, UNKNOWN)


## Il piano completo: sagoma della tessera piu' i tratti del terreno, in ordine
## di disegno. Le coordinate sono frazioni del quadrato, quindi chi disegna
## moltiplica per le proprie dimensioni e non sa altro.
static func plan(region_id: String, biome: String) -> Dictionary:
	var colours: Dictionary = palette(biome)
	var state: int = ArtPlaceholder.fingerprint(region_id)
	var outline: Array = []
	# Un esagono irregolare invece di un cerchio: una tessera dev'essere un pezzo
	# di terra, e un cerchio perfetto e' l'unica forma che in natura non c'e'.
	# Lo scarto e' piccolo - la mappa deve restare leggibile, non organica.
	for i in range(6):
		var angle: float = TAU * float(i) / 6.0 - PI / 6.0
		var radius: float = 0.46 + 0.05 * (ArtPlaceholder.unit(state) - 0.5)
		state = ArtPlaceholder.step(state)
		outline.append(Vector2(0.5, 0.5) + Vector2(cos(angle), sin(angle)) * radius)

	var strokes: Array = []
	match biome:
		"CITY": strokes = _city(state, colours)
		"VALLEY": strokes = _valley(state, colours)
		"STEPPE": strokes = _steppe(state, colours)
		"MOUNTAIN": strokes = _mountain(state, colours)
		"UNDERGROUND": strokes = _underground(state, colours)
		"ROAD": strokes = _road(state, colours)
		"FOREST": strokes = _forest(state, colours)
		"COAST": strokes = _coast(state, colours)
		"MARSH": strokes = _marsh(state, colours)
		"ISLAND": strokes = _island(state, colours)
		_: strokes = _steppe(state, colours)

	return {
		"region_id": region_id,
		"biome": biome,
		"ground": str(colours["ground"]),
		"relief": str(colours["relief"]),
		"accent": str(colours["accent"]),
		"outline": outline,
		"strokes": _inside(strokes),
	}


## Tutto il disegno rientra nel cerchio inscritto nell'esagono.
##
## I vocabolari qui sotto sono scritti sul quadrato pieno perche' e' cosi' che si
## ragiona disegnando - «i tetti stanno in basso, le mura passano alte». Poi
## tutto viene tirato verso il centro di un fattore fisso: un esagono di raggio
## 0.46 ha un cerchio inscritto di 0.40, e senza questo passaggio i tetti della
## citta' spuntavano sotto il bordo della tessera. Si vedeva solo stampando.
const INSET: float = 0.72


static func _inside(strokes: Array) -> Array:
	var centre: Vector2 = Vector2(0.5, 0.5)
	var out: Array = []
	for stroke in strokes:
		var item: Dictionary = (stroke as Dictionary).duplicate()
		var moved: Array = []
		for point in item["points"]:
			moved.append(centre + ((point as Vector2) - centre) * INSET)
		item["points"] = moved
		item["width"] = float(item["width"]) * INSET
		out.append(item)
	return out


# --- il vocabolario ----------------------------------------------------------
#
# Tre tratti soltanto, perche' devono saperli disegnare due motori diversi:
# `poly` (una figura piena), `line` (una spezzata) e `dot` (un cerchio).

static func _poly(points: Array, colour: String) -> Dictionary:
	return {"kind": "poly", "points": points, "colour": colour, "width": 0.0}


static func _line(points: Array, colour: String, width: float) -> Dictionary:
	return {"kind": "line", "points": points, "colour": colour, "width": width}


static func _dot(at: Vector2, radius: float, colour: String) -> Dictionary:
	return {"kind": "dot", "points": [at], "colour": colour, "width": radius}


## Tetti fitti e un tratto di mura: la citta' si riconosce dal profilo dei tetti,
## non dai dettagli, che a questa dimensione non esistono comunque.
static func _city(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	var roofs: int = 5 + (state % 3)
	state = ArtPlaceholder.step(state)
	for i in range(roofs):
		var x: float = 0.18 + 0.64 * (float(i) + 0.5) / float(roofs)
		var height: float = 0.10 + 0.09 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		var half: float = 0.055 + 0.02 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		var base: float = 0.74 if i % 2 == 0 else 0.80
		out.append(_poly([
			Vector2(x - half, base), Vector2(x, base - height), Vector2(x + half, base),
		], str(colours["relief"])))
	# Le mura passano alte e non chiudono: una tessera deve poter confinare con
	# la vicina, e un anello chiuso la isola.
	out.append(_line([
		Vector2(0.14, 0.40), Vector2(0.34, 0.33), Vector2(0.66, 0.33), Vector2(0.86, 0.41),
	], str(colours["accent"]), 0.022))
	return out


## Campi a strisce e un fiume: la valle e' la sola Regione che si legge dalle
## linee parallele, ed e' anche l'unica che da' da mangiare a tutti.
static func _valley(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	for i in range(4):
		var y: float = 0.62 + 0.075 * float(i)
		var inset: float = 0.16 + 0.05 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		out.append(_line(
			[Vector2(inset, y), Vector2(1.0 - inset, y - 0.03)], str(colours["relief"]), 0.03
		))
	out.append(_line([
		Vector2(0.10, 0.30), Vector2(0.34, 0.40), Vector2(0.58, 0.34), Vector2(0.90, 0.44),
	], str(colours["accent"]), 0.024))
	return out


## Erba bassa, piste, orizzonte alto: la steppa e' quasi tutta spazio, e il
## disegno deve dirlo togliendo invece che aggiungendo.
static func _steppe(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	out.append(_line(
		[Vector2(0.12, 0.38), Vector2(0.88, 0.34)], str(colours["relief"]), 0.02
	))
	for i in range(9):
		var x: float = 0.16 + 0.68 * float(i) / 8.0
		var y: float = 0.62 + 0.18 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		out.append(_line([Vector2(x, y), Vector2(x + 0.02, y - 0.05)], str(colours["relief"]), 0.012))
	out.append(_line([
		Vector2(0.16, 0.78), Vector2(0.44, 0.70), Vector2(0.78, 0.74),
	], str(colours["accent"]), 0.018))
	return out


## Creste e neve su un versante solo: la montagna e' la silhouette piu'
## riconoscibile che esista, e basta non rovinarla.
static func _mountain(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	var peaks: Array = []
	var x: float = 0.12
	var up: bool = true
	while x < 0.90:
		var y: float = (0.34 + 0.10 * ArtPlaceholder.unit(state)) if up else (0.58 - 0.06 * ArtPlaceholder.unit(state))
		state = ArtPlaceholder.step(state)
		peaks.append(Vector2(x, y))
		x += 0.13
		up = not up
	out.append(_poly(
		[Vector2(0.10, 0.82)] + peaks + [Vector2(0.90, 0.82)], str(colours["relief"])
	))
	if peaks.size() >= 2:
		var top: Vector2 = peaks[0]
		for point in peaks:
			if (point as Vector2).y < top.y:
				top = point
		out.append(_poly([
			top, top + Vector2(0.06, 0.09), top + Vector2(-0.05, 0.08),
		], str(colours["accent"])))
	return out


## Imbocchi di galleria e impalcature: sottoterra non si vede niente, quindi si
## disegna quello che ci si e' costruito sopra.
static func _underground(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	for i in range(3):
		var x: float = 0.26 + 0.24 * float(i)
		var y: float = 0.66 + 0.06 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		out.append(_poly([
			Vector2(x - 0.07, y), Vector2(x - 0.05, y - 0.11),
			Vector2(x + 0.05, y - 0.11), Vector2(x + 0.07, y),
		], str(colours["relief"])))
		out.append(_dot(Vector2(x, y - 0.07), 0.022, str(colours["ground"])))
	out.append(_line([
		Vector2(0.16, 0.30), Vector2(0.40, 0.24), Vector2(0.62, 0.30), Vector2(0.84, 0.25),
	], str(colours["accent"]), 0.016))
	return out


## Una strada che attraversa tutto, e le soste: e' l'unica Regione che esiste per
## quello che ci passa sopra e non per quello che ci sta.
static func _road(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	var bend: float = 0.42 + 0.10 * ArtPlaceholder.unit(state)
	state = ArtPlaceholder.step(state)
	out.append(_line([
		Vector2(0.06, 0.30), Vector2(0.34, bend), Vector2(0.66, 1.0 - bend), Vector2(0.94, 0.72),
	], str(colours["relief"]), 0.075))
	out.append(_line([
		Vector2(0.06, 0.30), Vector2(0.34, bend), Vector2(0.66, 1.0 - bend), Vector2(0.94, 0.72),
	], str(colours["accent"]), 0.012))
	for i in range(3):
		var t: float = 0.26 + 0.24 * float(i)
		out.append(_dot(Vector2(t, 0.30 + 0.44 * t), 0.02, str(colours["relief"])))
	return out


static func _forest(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	for i in range(7):
		var x: float = 0.16 + 0.68 * float(i) / 6.0
		var y: float = 0.52 + 0.22 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		out.append(_dot(Vector2(x, y), 0.055 + 0.02 * ArtPlaceholder.unit(state), str(colours["relief"])))
		state = ArtPlaceholder.step(state)
	out.append(_line([
		Vector2(0.22, 0.80), Vector2(0.50, 0.72), Vector2(0.76, 0.82),
	], str(colours["accent"]), 0.014))
	return out


static func _coast(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	for i in range(4):
		var y: float = 0.58 + 0.09 * float(i)
		var wave: float = 0.04 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		out.append(_line([
			Vector2(0.14, y), Vector2(0.38, y - wave), Vector2(0.62, y + wave), Vector2(0.86, y),
		], str(colours["relief"]), 0.018))
	out.append(_line([
		Vector2(0.10, 0.44), Vector2(0.42, 0.38), Vector2(0.72, 0.46), Vector2(0.92, 0.40),
	], str(colours["accent"]), 0.02))
	return out


## La palude (D-265): acqua ferma a chiazze, e canne che spuntano dritte —
## il contrario delle onde della costa, che si muovono.
static func _marsh(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	for i in range(5):
		var x: float = 0.18 + 0.15 * float(i)
		var y: float = 0.56 + 0.14 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		out.append(_line([
			Vector2(x, y), Vector2(x + 0.10, y),
		], str(colours["relief"]), 0.02))
		out.append(_line([
			Vector2(x + 0.05, y), Vector2(x + 0.05, y - 0.12 - 0.05 * ArtPlaceholder.unit(state)),
		], str(colours["accent"]), 0.012))
		state = ArtPlaceholder.step(state)
	return out


## L'isola (D-265): un solo rilievo in mezzo all'acqua, e il vuoto attorno —
## nessun'altra tessera lascia tanto spazio non disegnato, ed e' il punto.
static func _island(state: int, colours: Dictionary) -> Array:
	var out: Array = []
	for i in range(2):
		var y: float = 0.66 + 0.10 * float(i)
		var wave: float = 0.03 * ArtPlaceholder.unit(state)
		state = ArtPlaceholder.step(state)
		out.append(_line([
			Vector2(0.16, y), Vector2(0.50, y - wave), Vector2(0.84, y),
		], str(colours["relief"]), 0.016))
	out.append(_line([
		Vector2(0.36, 0.58), Vector2(0.50, 0.34 - 0.05 * ArtPlaceholder.unit(state)), Vector2(0.64, 0.58),
	], str(colours["accent"]), 0.02))
	return out


## Lo stesso piano in SVG, per la tessera stampata.
##
## E' la ragione per cui il piano e' un dato e non una sequenza di chiamate a
## `draw_*`: la tessera sul tavolo e quella sullo schermo devono essere la stessa
## immagine, non due che si somigliano.
static func svg(region_id: String, biome: String, x: float, y: float, w: float, h: float) -> String:
	var drawing: Dictionary = plan(region_id, biome)
	var out: Array = []
	out.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="#15120e"/>' % [x, y, w, h])
	# Il terreno sta in un quadrato centrato: dentro un rettangolo la tessera si
	# schiaccerebbe, e una montagna schiacciata smette di essere una montagna.
	var side: float = minf(w, h)
	x += (w - side) * 0.5
	y += (h - side) * 0.5
	w = side
	h = side
	out.append('<polygon points="%s" fill="%s"/>' % [
		_points(drawing["outline"], x, y, w, h), str(drawing["ground"])
	])
	for stroke in drawing["strokes"]:
		var item: Dictionary = stroke
		match str(item["kind"]):
			"poly":
				out.append('<polygon points="%s" fill="%s"/>' % [
					_points(item["points"], x, y, w, h), str(item["colour"])
				])
			"line":
				out.append(
					'<polyline points="%s" fill="none" stroke="%s" stroke-width="%.2f"'
					% [
						_points(item["points"], x, y, w, h), str(item["colour"]),
						maxf(0.1, float(item["width"]) * w),
					]
					+ ' stroke-linecap="round" stroke-linejoin="round"/>'
				)
			"dot":
				var at: Vector2 = item["points"][0]
				out.append('<circle cx="%.2f" cy="%.2f" r="%.2f" fill="%s"/>' % [
					x + at.x * w, y + at.y * h, float(item["width"]) * w, str(item["colour"])
				])
	# Il centro calmo, segnato come sul segnaposto delle carte: e' lo spazio che
	# un'illustrazione vera dovra' lasciare ai segnalini.
	out.append(
		'<circle cx="%.2f" cy="%.2f" r="%.2f" fill="none" stroke="#4a4237"'
		% [x + w * 0.5, y + h * 0.5, CALM_RADIUS * w]
		+ ' stroke-width="0.15" stroke-dasharray="1.2 2.0" opacity="0.5"/>'
	)
	return "\n".join(PackedStringArray(out))


static func _points(points: Array, x: float, y: float, w: float, h: float) -> String:
	var out: Array = []
	for point in points:
		out.append("%.2f,%.2f" % [x + (point as Vector2).x * w, y + (point as Vector2).y * h])
	return " ".join(PackedStringArray(out))
