extends RefCounted
## Il foglio di stampa: le facce di `card_face.gd` impaginate in A4, in SVG.
##
## Perche' SVG e non PNG: un export che si stampa dev'essere **deterministico e
## leggibile**, come i salvataggi (§18.3). Un SVG e' testo - due export dello
## stesso dato escono identici byte per byte, la CI puo' confrontarli, e un
## diff dice *quale carta* e' cambiata invece di dire che sei megabyte di pixel
## sono diversi. In piu' non serve un contesto di rendering: gira sotto
## `--headless` come tutto il resto, senza GPU e senza display.
##
## Misure vere, in millimetri: carta 63x88, tessera 80x80, foglio A4, tre carte
## per tre. Il `viewBox` e' in mm, quindi quello che esce e' in scala 1:1 e si
## stampa senza «adatta alla pagina» - che e' il modo in cui un print-and-play
## esce sbagliato di due millimetri e nessuno capisce perche'.
##
## Non decide niente sul contenuto: riceve facce e le dispone.

const ArtPlaceholder := preload("res://scripts/core/art_placeholder.gd")
const RegionArt := preload("res://scripts/core/region_art.gd")
const IconSet := preload("res://scripts/core/icon_set.gd")
const ArtLibrary := preload("res://scripts/core/art_library.gd")

const PAGE_W: float = 210.0
const PAGE_H: float = 297.0

## I formati delle carte (D-097, voce 7): ogni mazzo ha la taglia del suo
## ruolo al tavolo. 63x88 e' la carta da gioco classica (bustine standard) per
## i mazzi che si mescolano e stanno in mano; 70x120 e' il tarocco per le
## carte-identita' che restano in vista tutta la partita; 44x68 e' la mini per
## i riferimenti che stanno accanto ai tracciati; 80x80 la tessera Regione,
## quadrata come chiede il MASTER PROMPT 3.
const SHAPES: Dictionary = {
	"CARD": {"w": 63.0, "h": 88.0, "cols": 3, "rows": 3},
	"TAROT": {"w": 70.0, "h": 120.0, "cols": 2, "rows": 2},
	"MINI": {"w": 44.0, "h": 68.0, "cols": 4, "rows": 4},
	"TILE": {"w": 80.0, "h": 80.0, "cols": 2, "rows": 3},
}

const CARD_W: float = 63.0
const CARD_H: float = 88.0
const TILE_W: float = 80.0
const TILE_H: float = 80.0

const INK: String = "#efe7d8"
const DIM: String = "#8a8172"
const PAPER: String = "#12100e"


static func cell_size(shape: String) -> Vector2:
	var spec: Dictionary = SHAPES.get(shape, SHAPES["CARD"])
	return Vector2(float(spec["w"]), float(spec["h"]))


static func columns(shape: String) -> int:
	return int((SHAPES.get(shape, SHAPES["CARD"]) as Dictionary)["cols"])


static func per_page(shape: String) -> int:
	var spec: Dictionary = SHAPES.get(shape, SHAPES["CARD"])
	return int(spec["cols"]) * int(spec["rows"])


## Una carta stampata quattro volte e' quattro carte (D-040: comune = 4 copie).
## L'anteprima mostra le facce, il foglio stampa il mazzo.
static func expand(faces: Array) -> Array:
	var out: Array = []
	for face in faces:
		for i in range(maxi(1, int((face as Dictionary).get("copies", 1)))):
			out.append(face)
	return out


static func paginate(faces: Array, shape: String) -> Array:
	var size: int = per_page(shape)
	var pages: Array = []
	var page: Array = []
	for face in faces:
		page.append(face)
		if page.size() == size:
			pages.append(page)
			page = []
	if not page.is_empty():
		pages.append(page)
	return pages


## Una pagina intera. `label` finisce nell'intestazione fuori dall'area di
## taglio, insieme al numero di foglio: un mazzo stampato senza sapere quale
## foglio manca e' un mazzo da ristampare tutto.
static func page_svg(faces: Array, shape: String, label: String, number: int, total: int) -> String:
	var cell: Vector2 = cell_size(shape)
	var cols: int = columns(shape)
	var rows: int = per_page(shape) / cols
	var left: float = (PAGE_W - cell.x * float(cols)) * 0.5
	var top: float = (PAGE_H - cell.y * float(rows)) * 0.5

	var out: Array = []
	out.append(
		'<svg xmlns="http://www.w3.org/2000/svg" width="%dmm" height="%dmm" viewBox="0 0 %d %d">'
		% [int(PAGE_W), int(PAGE_H), int(PAGE_W), int(PAGE_H)]
	)
	# La sfumatura sotto il testo, definita una volta per foglio e usata da ogni
	# carta: in unita' relative al proprio rettangolo, quindi si adatta da sola a
	# quanto testo ha quella carta. Un bordo netto sopra un dipinto e' un taglio;
	# una sfumatura e' un'ombra che sale dal basso.
	out.append('<defs><linearGradient id="velo" x1="0" y1="0" x2="0" y2="1">')
	out.append('<stop offset="0" stop-color="#0d0b09" stop-opacity="0"/>')
	out.append('<stop offset="0.28" stop-color="#0d0b09" stop-opacity="0.66"/>')
	out.append('<stop offset="1" stop-color="#0d0b09" stop-opacity="0.86"/>')
	out.append('</linearGradient></defs>')
	out.append('<rect width="%d" height="%d" fill="#ffffff"/>' % [int(PAGE_W), int(PAGE_H)])
	out.append(
		'<text x="%.1f" y="%.1f" font-family="sans-serif" font-size="3" fill="#999999">%s</text>'
		% [left, top - 5.0, ArtPlaceholder.escape("ECHOES · %s · foglio %d di %d" % [
			label, number, total
		])]
	)

	for index in range(faces.size()):
		var column: int = index % cols
		var row: int = index / cols
		var x: float = left + float(column) * cell.x
		var y: float = top + float(row) * cell.y
		out.append(_crop_marks(x, y, cell))
		out.append(_face_svg(faces[index], x, y, cell))

	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


## Una carta sola, come SVG a sé (D-101): la stessa faccia che va sul foglio
## di stampa, senza segni di taglio, dimensionata sulla propria taglia. E' il
## mattone con cui la GUI mostra i componenti fisici invece di una loro
## parafrasi - la stessa disciplina della cronaca (D-086) e dell'anteprima
## (D-056): quello che si vede al tavolo digitale e' quello che esce dalla
## stampante, non una cosa che gli somiglia.
static func card_svg(face: Dictionary) -> String:
	var cell: Vector2 = cell_size(str(face.get("shape", "CARD")))
	var out: Array = []
	out.append(
		'<svg xmlns="http://www.w3.org/2000/svg" width="%.0fmm" height="%.0fmm" viewBox="0 0 %.0f %.0f">'
		% [cell.x, cell.y, cell.x, cell.y]
	)
	out.append('<defs><linearGradient id="velo" x1="0" y1="0" x2="0" y2="1">')
	out.append('<stop offset="0" stop-color="#0d0b09" stop-opacity="0"/>')
	out.append('<stop offset="0.28" stop-color="#0d0b09" stop-opacity="0.66"/>')
	out.append('<stop offset="1" stop-color="#0d0b09" stop-opacity="0.86"/>')
	out.append('</linearGradient></defs>')
	out.append(_face_svg(face, 0.0, 0.0, cell))
	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


## I segni di taglio stanno **fuori** dalla carta, uno per angolo: dentro
## sarebbero stampati sulla carta finita.
static func _crop_marks(x: float, y: float, cell: Vector2) -> String:
	var marks: Array = []
	var length: float = 3.0
	for corner in [Vector2(x, y), Vector2(x + cell.x, y), Vector2(x, y + cell.y),
			Vector2(x + cell.x, y + cell.y)]:
		var point: Vector2 = corner
		var toward_x: float = -length if is_equal_approx(point.x, x) else length
		var toward_y: float = -length if is_equal_approx(point.y, y) else length
		marks.append(
			'<path d="M %.2f %.2f h %.2f M %.2f %.2f v %.2f" stroke="#bbbbbb" stroke-width="0.15"/>'
			% [point.x, point.y, toward_x, point.x, point.y, toward_y]
		)
	return "\n".join(PackedStringArray(marks))


## L'impaginazione di una faccia, come dati: dove va ogni riga, con che corpo e
## di che colore, in millimetri e con l'origine nell'angolo della carta.
##
## E' una funzione pura e sta qui invece che dentro chi disegna per due motivi.
## Il primo e' che l'anteprima dentro l'app deve mostrare **questa** impaginazione
## e non una che le somiglia, altrimenti non e' un'anteprima. Il secondo e' che
## cosi' un test puo' chiedere a ogni carta del set se il suo testo ci sta, e la
## risposta e' un booleano invece di una lettura a occhio su venticinque fogli -
## che e' esattamente come il testo dei Destini era finito fuori dal bordo.
static func layout(face: Dictionary, cell: Vector2) -> Dictionary:
	var accent: String = str(face["accent"])
	var pad: float = 3.4
	var inner: float = cell.x - pad * 2.0
	var has_art: bool = str(face["art_prompt_key"]) != ""
	# Una carta senza illustrazione non tiene mezzo riquadro vuoto: Destini e
	# Domande si ristampano a ogni Chronicle e vivono di testo, e quel mezzo
	# riquadro e' precisamente lo spazio che al loro testo mancava.
	var art_h: float = 0.0
	if has_art:
		art_h = cell.y * (0.46 if str(face["shape"]) == "CARD" else 0.52)
	# Una tessera Regione e' una tessera di mappa, non una carta con un'immagine
	# sopra: il terreno prende tutto il quadrato e il testo ci sta sopra, in
	# basso a sinistra, dove la sagoma esagonale lascia scoperto il fondo. La
	# descrizione e le fonti non salgono sul tavolo - si leggono altrove - e una
	# tessera che le stampa e' una tessera con l'illustrazione grande la meta'.
	var full_tile: bool = str(face["terrain"]) != ""
	if full_tile:
		art_h = cell.x - pad * 2.0

	# **Una carta con l'illustrazione vera va al vivo**, come la ART_BIBLE la
	# descrive dalla 0.0: «il soggetto occupa i due terzi alti; il terzo basso e'
	# un'area calma riservata a un overlay di testo». Quella riga ha senso solo se
	# il testo sta *sopra* il dipinto - un'immagine dentro un riquadro con il
	# testo sotto e' un'altra carta, e chiederebbe un'altra composizione.
	#
	# Il segnaposto generato resta invece nel riquadro: e' uno schema, non un
	# quadro, e stenderlo su tutta la carta lo farebbe sembrare quello che non e'.
	# Una carta cambia impaginazione il giorno in cui la sua illustrazione arriva.
	var painted: bool = has_art and ArtLibrary.has(str(face["art_prompt_key"]))
	if painted and not full_tile:
		art_h = cell.y

	# Quanto testo c'e', al corpo pieno.
	var blocks: Array = [{"size": 3.6, "bold": true, "colour": INK, "text": str(face["title"]), "gap": 1.4}]
	if str(face["subtitle"]) != "":
		blocks.append({"size": 2.2, "bold": false, "colour": accent, "text": str(face["subtitle"]), "gap": 2.0})
	# Sulla tessera Regione il **racconto** non sale sul tavolo; su una carta
	# Asset il testo di regole ci deve stare, dipinta o no.
	#
	# **Ma le righe meccaniche salgono anche sulla tessera** (D-344): i segni di
	# una Regione sono il bersaglio che ogni carta Azione nomina — «un luogo con
	# #granaio» — e una tessera che non li porta rende quella carta ingiocabile.
	# Fino alla 0.1.308 `_region` costruiva una nota e questo blocco la buttava
	# via: una riga calcolata e mai disegnata, che e' il modo piu' silenzioso di
	# non stampare una regola.
	if not full_tile:
		for paragraph in face["body"]:
			if str(paragraph) != "":
				blocks.append({"size": 2.3, "bold": false, "colour": "#c9bfae", "text": str(paragraph), "gap": 1.6})
	for note in face["notes"]:
		if str(note) != "":
			blocks.append({"size": 2.0, "bold": false, "colour": DIM, "text": str(note), "gap": 0.9})

	# Se il testo non ci sta, la prima cosa che cede e' l'illustrazione, non il
	# corpo del testo: due carte su quarantotto hanno una riga di regole lunga il
	# doppio delle altre, e stringere il testo di tutte per loro sarebbe la
	# scelta sbagliata. L'immagine scende fino al 34% della carta e non oltre -
	# sotto quella soglia non e' piu' l'illustrazione che la ART_BIBLE descrive.
	var needed: float = _height_of(blocks, inner, 1.0)
	# Lo spazio vero, contato fra dove il testo comincia e dove finisce la carta,
	# non una stima: la prima versione ne stimava quattro millimetri di piu' e
	# quattro millimetri sono le due righe che uscivano dal bordo.
	var gap: float = 4.6 if has_art else 3.2
	var bottom: float = cell.y - pad - 2.6
	var available: float = bottom - (pad + art_h + gap)
	if full_tile:
		# Il testo sta *sopra* il terreno, non sotto: parte da dove serve perche'
		# le due righe finiscano appoggiate al bordo basso.
		available = needed
	elif painted:
		# Al vivo il testo ha tutta la carta meno i margini: appoggiato in basso,
		# risale quanto gli serve. Se un giorno servisse piu' di mezza carta e'
		# la carta a doverlo dire, e il test lo dice.
		available = bottom - pad
	elif has_art and needed > available:
		var floor_h: float = cell.y * 0.34
		art_h = maxf(floor_h, art_h - (needed - available))
		available = bottom - (pad + art_h + gap)
	# Sotto il 74% il corpo non si legge piu' a 63 mm: meglio una carta che dice
	# di non entrarci - il test lo vede - che una che si stringe finche' sparisce.
	var scale: float = clampf(available / maxf(needed, 0.01), 0.74, 1.0)

	var lines: Array = []
	var cursor: float = pad + art_h + gap
	if full_tile or painted:
		cursor = bottom - needed * scale
	var overflow: bool = false
	for block in blocks:
		var item: Dictionary = block
		var size: float = float(item["size"]) * scale
		var leading: float = size * 1.26
		for text in wrap_text(str(item["text"]), inner, size):
			if cursor + leading > bottom:
				overflow = true
				break
			cursor += leading
			lines.append({
				"x": pad, "y": cursor, "size": size, "bold": bool(item["bold"]),
				"colour": str(item["colour"]), "text": str(text),
			})
		if overflow:
			break
		cursor += float(item["gap"]) * scale

	var footer: String = str(face["footer"])
	if bool(face["secret"]):
		footer += " · dietro il paravento"
	return {
		"pad": pad, "accent": accent, "art_h": art_h, "has_art": has_art, "full_tile": full_tile,
		"painted": painted,
		"art_key": str(face["art_prompt_key"]), "corner": str(face["corner"]),
		"lines": lines, "footer": footer, "overflow": overflow, "scale": scale,
	}


static func _height_of(blocks: Array, inner: float, scale: float) -> float:
	var total: float = 0.0
	for block in blocks:
		var item: Dictionary = block
		var size: float = float(item["size"]) * scale
		total += float(wrap_text(str(item["text"]), inner, size).size()) * size * 1.26
		total += float(item["gap"]) * scale
	return total


static func _face_svg(face: Dictionary, x: float, y: float, cell: Vector2) -> String:
	var drawn: Dictionary = layout(face, cell)
	var pad: float = float(drawn["pad"])
	var accent: String = str(drawn["accent"])
	var out: Array = ["<g>"]
	out.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="%s"/>' % [
		x, y, cell.x, cell.y, PAPER
	])

	if bool(drawn["has_art"]):
		# L'arte vera, se qualcuno l'ha consegnata: incorporata come `data:` URI
		# perche' un foglio che punta a un file esterno e' due file che si perdono
		# uno senza l'altro (D-059).
		var picture: String = ArtLibrary.data_uri(str(face["art_prompt_key"]))
		if picture != "":
			# Al vivo l'immagine parte dall'angolo della carta, senza margine: e'
			# quello che si taglia, ed e' il motivo per cui il prompt chiede 2:3.
			var edge: float = 0.0 if bool(drawn["painted"]) and not bool(drawn["full_tile"]) else pad
			out.append(
				'<image href="%s" x="%.2f" y="%.2f" width="%.2f" height="%.2f"'
				% [
					picture, x + edge, y + edge,
					cell.x - edge * 2.0,
					cell.y if bool(drawn["painted"]) and not bool(drawn["full_tile"])
						else float(drawn["art_h"]),
				]
				+ ' preserveAspectRatio="xMidYMid slice"/>'
			)
		# Una Regione porta il proprio terreno, non il segnaposto generico: e' la
		# stessa immagine che la mappa disegna sullo schermo (D-057).
		elif bool(drawn["full_tile"]):
			out.append(RegionArt.svg(
				str(face["id"]), str(face["terrain"]), x + pad, y + pad,
				cell.x - pad * 2.0, float(drawn["art_h"])
			))
		else:
			out.append(ArtPlaceholder.svg(
				str(drawn["art_key"]), accent, x + pad, y + pad, cell.x - pad * 2.0,
				float(drawn["art_h"])
			))

	# Su una tessera al vivo il testo sta *sopra* l'illustrazione, e su un'arte
	# chiara sparisce: il nome di Terre Nahr sul suo pascolo giallo non si legge,
	# e l'id nemmeno. Una fascia scura sotto le righe - solo dove ci sono righe -
	# lo rimette a galla senza coprire il quadro.
	if (bool(drawn["full_tile"]) or bool(drawn["painted"])) and not (drawn["lines"] as Array).is_empty():
		var first: Dictionary = (drawn["lines"] as Array)[0]
		# La sfumatura comincia un po' piu' in alto della prima riga: il testo deve
		# posarsi su qualcosa di gia' scuro, non sul bordo della sfumatura.
		var top: float = float(first["y"]) - float(first["size"]) - 5.0
		out.append(
			'<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="url(#velo)"/>'
			% [x, y + top, cell.x, cell.y - top]
		)

	for line in drawn["lines"]:
		var item: Dictionary = line
		out.append(_text(
			x + float(item["x"]), y + float(item["y"]), str(item["text"]),
			float(item["size"]), str(item["colour"]), bool(item["bold"])
		))

	if str(drawn["corner"]) != "":
		var cx: float = x + cell.x - pad - 3.0
		var cy: float = y + pad + 3.0
		out.append('<circle cx="%.2f" cy="%.2f" r="4.2" fill="%s"/>' % [cx, cy, accent])
		out.append(
			'<text x="%.2f" y="%.2f" font-family="sans-serif" font-size="5" font-weight="bold"'
			% [cx, cy + 1.8]
			+ ' text-anchor="middle" fill="%s">%s</text>' % [PAPER, str(drawn["corner"])]
		)

	# Il glifo della famiglia, in basso a destra: e' lo stesso segno che la carta
	# porta sullo schermo, ed e' quello che permette di ordinare un mazzo di
	# centotrentadue carte senza leggerne una (ISSUES 6).
	if str(face["family"]) != "":
		out.append(IconSet.svg(
			str(face["family"]), x + cell.x - pad - 6.0, y + cell.y - pad - 7.4, 6.0, accent
		))

	# Il pie' di pagina e' l'id, che sul tavolo non serve a nessuno e in playtest
	# serve a tutto: e' come si dice «questa carta qui» a chi tiene il registro.
	out.append(_text(x + pad, y + cell.y - pad, str(drawn["footer"]), 1.9, "#5f584c", false))
	out.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="none" stroke="%s"' % [
		x, y, cell.x, cell.y, accent
	] + ' stroke-width="0.4"/>')
	out.append("</g>")
	return "\n".join(PackedStringArray(out))


static func _text(x: float, y: float, text: String, size: float, colour: String, bold: bool) -> String:
	return (
		'<text x="%.2f" y="%.2f" font-family="sans-serif" font-size="%.1f"%s fill="%s">%s</text>'
		% [x, y, size, ' font-weight="bold"' if bold else "", colour, ArtPlaceholder.escape(text)]
	)


## A capo a mano: l'SVG non manda a capo da solo, e una riga che esce dalla carta
## esce anche dalla stampa. La larghezza media di un carattere e' circa 0.52 volte
## il corpo per una sans-serif - stimata, e stimata per difetto.
##
## `wrap` da solo e' una funzione di utilita' del motore: chiamare cosi' questa
## la ombrerebbe silenziosamente.
static func wrap_text(text: String, width_mm: float, size_mm: float) -> Array:
	var per_line: int = maxi(8, int(width_mm / (size_mm * 0.52)))
	var out: Array = []
	var line: String = ""
	for word in text.split(" ", false):
		var candidate: String = str(word) if line == "" else "%s %s" % [line, str(word)]
		if candidate.length() > per_line:
			if line != "":
				out.append(line)
			line = str(word)
		else:
			line = candidate
	if line != "":
		out.append(line)
	return out
