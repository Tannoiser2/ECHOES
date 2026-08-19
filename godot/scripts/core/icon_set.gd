extends RefCounted
## Le icone di sistema (ART_BIBLE §Overlay e iconografia, ISSUES 6).
##
## Non sono illustrazione: sono **segni**. La ART_BIBLE lo dice e mette anche il
## vincolo che li governa - *«il set delle sei famiglie deve funzionare in
## monocromatico a 16 px: se un'icona ha bisogno del colore per distinguersi da
## un'altra, va ridisegnata»*. Le famiglie sono gia' distinte per accento
## cromatico sulle carte; l'icona deve reggere anche senza, perche' sulla mappa
## non c'e' accento, perche' un daltonico non lo vede, e perche' una fotocopia
## non lo stampa.
##
## Quindi qui i colori non ci sono. Ogni glifo e' una lista di tratti nello
## stesso vocabolario di tre parole del terreno (`poly`, `line`, `dot`), in
## coordinate normalizzate, e chi disegna decide di che colore. Un glifo che si
## legge solo perche' e' oro non e' un glifo: e' una macchia oro.
##
## Disegnati su una griglia da 16: a quella dimensione un tratto sottile sparisce
## e un dettaglio in piu' diventa fango, quindi ogni segno e' due o tre tratti e
## nessuno di piu'.

## Lo spessore di riferimento, in frazione del lato. A 16 px fa un pixel e mezzo:
## sotto questo si perde, sopra si impasta.
const STROKE: float = 0.09

## Le sei famiglie di Asset. I nomi sono quelli dei dati.
const FAMILIES: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]

## I quattro livelli di overlay della mappa (§19.5), piu' i due marker.
const LEVELS: Array = ["structure", "condition", "settlement", "scar"]
const MARKERS: Array = ["tension", "echo"]

## I pezzi del tavolo: la pedina di chi sta in una Regione e il vessillo di chi
## la tiene. Non sono overlay ne' famiglie - sono le cose che si toccano, e per
## D-097 lo stesso profilo va sullo schermo e sul cartone fustellato. Un tondo
## colorato dice «qualcuno e' qui»; una pedina dice *chi*, e si conta con gli
## occhi come si contano i pezzi veri.
const PIECES: Array = ["pawn", "banner"]


static func names() -> Array:
	return FAMILIES + LEVELS + MARKERS + PIECES


## I tratti di un glifo, in ordine di disegno. Un nome che non esiste torna un
## segno di domanda quadrato invece di niente: un buco sulla mappa si legge come
## un errore, un punto interrogativo si legge come «manca questo».
static func glyph(name: String) -> Array:
	match name:
		"FORCE": return _force()
		"AUTHORITY": return _authority()
		"PEOPLE": return _people()
		"KNOWLEDGE": return _knowledge()
		"WEALTH": return _wealth()
		"BONDS": return _bonds()
		"structure": return _structure()
		"condition": return _condition()
		"settlement": return _settlement()
		"scar": return _scar()
		"tension": return _tension()
		"echo": return _echo()
		"pawn": return _pawn()
		"banner": return _banner()
	return _unknown()


static func _poly(points: Array) -> Dictionary:
	return {"kind": "poly", "points": points, "width": 0.0}


static func _line(points: Array, width: float = STROKE) -> Dictionary:
	return {"kind": "line", "points": points, "width": width}


static func _dot(at: Vector2, radius: float) -> Dictionary:
	return {"kind": "dot", "points": [at], "width": radius}


# --- le sei famiglie ---------------------------------------------------------
#
# Ognuna ha una silhouette che le altre cinque non hanno: una punta, una corona,
# una fila, un angolo, un peso, un anello. E' l'unico modo di reggere il test del
# monocromatico - due icone che differiscono per un dettaglio interno a 16 px
# sono la stessa icona.

## Una lama con l'elsa. La prima versione era una punta di lancia, e a 16 px era
## la stessa cosa del marker di Tensione, che e' una freccia in su: due segni che
## a quella dimensione si confondono sono un segno solo. L'elsa e' quello che li
## separa, ed e' anche l'unico tratto orizzontale del set.
static func _force() -> Array:
	return [
		_poly([Vector2(0.50, 0.04), Vector2(0.66, 0.30), Vector2(0.50, 0.56), Vector2(0.34, 0.30)]),
		_line([Vector2(0.20, 0.62), Vector2(0.80, 0.62)], 0.12),
		_line([Vector2(0.50, 0.62), Vector2(0.50, 0.96)], 0.10),
	]


## Una corona a tre punte su una base: peso e distanza, mai pompa.
static func _authority() -> Array:
	return [
		_poly([
			Vector2(0.10, 0.72), Vector2(0.10, 0.24), Vector2(0.30, 0.46), Vector2(0.50, 0.16),
			Vector2(0.70, 0.46), Vector2(0.90, 0.24), Vector2(0.90, 0.72),
		]),
		_line([Vector2(0.10, 0.86), Vector2(0.90, 0.86)], 0.12),
	]


## Tre teste in fila: numero, non individui.
static func _people() -> Array:
	return [
		_dot(Vector2(0.22, 0.30), 0.13),
		_dot(Vector2(0.50, 0.22), 0.13),
		_dot(Vector2(0.78, 0.30), 0.13),
		_line([
			Vector2(0.08, 0.90), Vector2(0.26, 0.58), Vector2(0.50, 0.50),
			Vector2(0.74, 0.58), Vector2(0.92, 0.90),
		], 0.11),
	]


## Un libro aperto: due pagine e il dorso.
##
## Prima era un compasso, e un compasso e' due gambe e una traversa, cioe' la
## lettera A. Un glifo che si legge come una lettera non e' un glifo: chi lo
## guarda cerca la parola. Il libro non ha questo problema ed e' l'unica forma
## del set fatta di due archi che si specchiano.
static func _knowledge() -> Array:
	return [
		_poly([
			Vector2(0.48, 0.22), Vector2(0.48, 0.86), Vector2(0.24, 0.78), Vector2(0.08, 0.80),
			Vector2(0.08, 0.20), Vector2(0.26, 0.18),
		]),
		_poly([
			Vector2(0.52, 0.22), Vector2(0.52, 0.86), Vector2(0.76, 0.78), Vector2(0.92, 0.80),
			Vector2(0.92, 0.20), Vector2(0.74, 0.18),
		]),
	]


## Un sacco legato: abbondanza precaria, mai opulenza.
static func _wealth() -> Array:
	return [
		_poly([
			Vector2(0.30, 0.34), Vector2(0.70, 0.34), Vector2(0.88, 0.94), Vector2(0.12, 0.94),
		]),
		_line([Vector2(0.32, 0.22), Vector2(0.68, 0.22)], 0.12),
		_line([Vector2(0.40, 0.30), Vector2(0.36, 0.14)], 0.08),
		_line([Vector2(0.60, 0.30), Vector2(0.64, 0.14)], 0.08),
	]


## Due anelli agganciati: l'unico glifo chiuso e tondo.
static func _bonds() -> Array:
	var out: Array = []
	for centre in [Vector2(0.34, 0.50), Vector2(0.66, 0.50)]:
		out.append(_line(_ring(centre, 0.26), 0.10))
	return out


# --- i quattro livelli della mappa -------------------------------------------

## Una torre: quello che qualcuno ha costruito e che resta.
static func _structure() -> Array:
	return [
		_poly([Vector2(0.28, 0.94), Vector2(0.28, 0.34), Vector2(0.50, 0.14), Vector2(0.72, 0.34), Vector2(0.72, 0.94)]),
	]


## Tre righe che scendono: una condizione e' qualcosa che sta succedendo, non
## qualcosa che c'e'.
static func _condition() -> Array:
	return [
		_line([Vector2(0.18, 0.24), Vector2(0.34, 0.84)], 0.10),
		_line([Vector2(0.50, 0.18), Vector2(0.66, 0.78)], 0.10),
		_line([Vector2(0.78, 0.28), Vector2(0.92, 0.72)], 0.10),
	]


## Due tetti: la gente ci abita.
static func _settlement() -> Array:
	return [
		_poly([Vector2(0.06, 0.86), Vector2(0.32, 0.44), Vector2(0.58, 0.86)]),
		_poly([Vector2(0.48, 0.90), Vector2(0.72, 0.54), Vector2(0.96, 0.90)]),
	]


## Una crepa: e' il solo segno che non viene via, ed e' il solo spigoloso.
static func _scar() -> Array:
	return [
		_line([
			Vector2(0.30, 0.06), Vector2(0.58, 0.34), Vector2(0.36, 0.52),
			Vector2(0.70, 0.94),
		], 0.12),
	]


# --- i due marker ------------------------------------------------------------

## Una domanda che sale.
static func _tension() -> Array:
	return [
		_line([Vector2(0.50, 0.94), Vector2(0.50, 0.16)], 0.11),
		_poly([Vector2(0.50, 0.04), Vector2(0.80, 0.40), Vector2(0.20, 0.40)]),
	]


## Un'onda che si allarga: quello che e' successo continua a muoversi.
static func _echo() -> Array:
	var out: Array = [_dot(Vector2(0.5, 0.5), 0.12)]
	for radius in [0.28, 0.44]:
		out.append(_line(_ring(Vector2(0.5, 0.5), radius), 0.09))
	return out


static func _unknown() -> Array:
	return [
		_line([
			Vector2(0.14, 0.14), Vector2(0.86, 0.14), Vector2(0.86, 0.86),
			Vector2(0.14, 0.86), Vector2(0.14, 0.14),
		], 0.10),
	]


## Un cerchio come spezzata chiusa: `line` e' l'unico tratto che i due motori
## disegnano allo stesso modo, e un anello vuoto non si fa con `dot`.
static func _ring(centre: Vector2, radius: float) -> Array:
	var out: Array = []
	for i in range(13):
		var angle: float = TAU * float(i) / 12.0
		out.append(centre + Vector2(cos(angle), sin(angle)) * radius)
	return out


## Il glifo in SVG, di un colore solo, dentro il quadrato che gli si indica.
static func svg(name: String, x: float, y: float, size: float, colour: String) -> String:
	var out: Array = []
	for stroke in glyph(name):
		var item: Dictionary = stroke
		match str(item["kind"]):
			"poly":
				out.append('<polygon points="%s" fill="%s"/>' % [
					_points(item["points"], x, y, size), colour
				])
			"line":
				out.append(
					'<polyline points="%s" fill="none" stroke="%s" stroke-width="%.2f"'
					% [_points(item["points"], x, y, size), colour, float(item["width"]) * size]
					+ ' stroke-linecap="round" stroke-linejoin="round"/>'
				)
			"dot":
				var at: Vector2 = item["points"][0]
				out.append('<circle cx="%.2f" cy="%.2f" r="%.2f" fill="%s"/>' % [
					x + at.x * size, y + at.y * size, float(item["width"]) * size, colour
				])
	return "\n".join(PackedStringArray(out))


static func _points(points: Array, x: float, y: float, size: float) -> String:
	var out: Array = []
	for point in points:
		out.append("%.2f,%.2f" % [x + (point as Vector2).x * size, y + (point as Vector2).y * size])
	return " ".join(PackedStringArray(out))


## La prova che la ART_BIBLE chiede, come pagina: ogni glifo a 16, 24, 32 e 64
## px, in un colore solo, su fondo chiaro e su fondo scuro.
##
## Sta qui e non in un documento perche' un'icona si giudica alla dimensione in
## cui verra' usata, e perche' cosi' la prova si rigenera da sola quando qualcuno
## ritocca un glifo. Le due file servono a due domande diverse: la prima e' la
## carta stampata, la seconda e' lo schermo.
static func proof_svg() -> String:
	var sizes: Array = [16.0, 24.0, 32.0, 64.0]
	var all: Array = names()
	# Larghezza della colonna: la somma delle quattro dimensioni piu' l'aria fra
	# loro. Calcolata invece che scelta a occhio - la prima versione ne aveva 96
	# per 154 di contenuto, e i glifi finivano uno sull'altro.
	var column: float = 24.0
	for size in sizes:
		column += float(size) + 6.0
	var width: float = 60.0 + column * float(all.size())
	var height: float = 300.0
	var out: Array = [
		'<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">'
		% [int(width), int(height), int(width), int(height)],
		'<rect width="%d" height="%d" fill="#f2efe8"/>' % [int(width), int(height)],
		'<rect y="150" width="%d" height="150" fill="#12100e"/>' % int(width),
		'<text x="14" y="24" font-family="sans-serif" font-size="13" fill="#12100e">'
		+ 'ECHOES - icone di sistema, monocromatiche, da 16 a 64 px</text>',
	]
	for index in range(all.size()):
		var name: String = str(all[index])
		var left: float = 46.0 + column * float(index)
		out.append(
			'<text x="%.0f" y="140" font-family="monospace" font-size="9" fill="#5f584c">%s</text>'
			% [left, name]
		)
		var cursor: float = left
		for size in sizes:
			var at: float = 110.0 - float(size)
			out.append(svg(name, cursor, at, float(size), "#12100e"))
			out.append(svg(name, cursor, at + 150.0, float(size), "#efe7d8"))
			cursor += float(size) + 6.0
	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


## La pedina: testa, corpo, base. Tre tratti e non uno di piu' - a 16 px un
## pezzo tornito diventa una macchia, e quello che deve leggersi a colpo
## d'occhio non e' il legno: e' «qualcuno sta qui».
static func _pawn() -> Array:
	return [
		_dot(Vector2(0.50, 0.26), 0.15),
		_poly([
			Vector2(0.35, 0.84), Vector2(0.41, 0.48), Vector2(0.59, 0.48), Vector2(0.65, 0.84),
		]),
		_poly([
			Vector2(0.24, 0.84), Vector2(0.76, 0.84), Vector2(0.76, 0.94), Vector2(0.24, 0.94),
		]),
	]


## Il vessillo di chi tiene il posto: l'asta e il drappo. Il controllo non e'
## una presenza - non si conta, si pianta - e la forma lo dice da sola.
static func _banner() -> Array:
	return [
		_line([Vector2(0.30, 0.08), Vector2(0.30, 0.94)]),
		_poly([Vector2(0.30, 0.14), Vector2(0.82, 0.30), Vector2(0.30, 0.46)]),
	]
