extends RefCounted
## La cronaca dell'anno come pagine da stampare (ISSUES voce 10, D-086).
##
## Le Truth sono l'unico pezzo di carta che il gioco **produce** invece di
## consumare (COMPONENTS §6), e fino alla 0.1.42 a fine anno vivevano solo nel
## log. Queste pagine sono la meta' stampabile della voce 10 — il seme del
## Chronicle Book della 1.0: un anno per capitolo, le Verita' in ordine, atto
## per atto, e in fondo come e' andata a ogni seggio.
##
## Stesso linguaggio dei fogli di stampa (print_sheet.gd): A4 in millimetri,
## carta scura del set, testo mandato a capo a mano. Una pagina di cronaca e'
## un oggetto del mondo, non un tabulato.

const PrintSheet := preload("res://scripts/core/print_sheet.gd")
const ArtPlaceholder := preload("res://scripts/core/art_placeholder.gd")

const PAGE_W: float = PrintSheet.PAGE_W
const PAGE_H: float = PrintSheet.PAGE_H
const MARGIN: float = 24.0
const BODY_SIZE: float = 3.4
const LINE: float = 5.2

const ACT_NAMES: Dictionary = {1: "ATTO PRIMO", 2: "ATTO SECONDO", 3: "ATTO TERZO"}
const LEVEL_NAMES: Dictionary = {
	"NONE": "non ha tenuto", "MINIMUM": "ha tenuto il minimo",
	"VICTORY": "ha ottenuto cio' che voleva", "TRIUMPH": "ha trionfato",
}


## Le pagine SVG della cronaca di un anno, da un salvataggio.
## `save` e' il dizionario di `session.to_save()`; `data` il DataSet.
static func pages(save: Dictionary, data: RefCounted) -> Array:
	var world: Dictionary = save.get("world_state", {})
	var chronicle_id: String = str(save.get("chronicle_id", world.get("chronicle_id", "")))
	var chronicle: Dictionary = data.chronicles.get(chronicle_id, {})
	var year: int = int(world.get("year", 0))

	# Il contenuto come righe tipografiche: (testo, corpo, colore, grassetto,
	# spazio prima). La paginazione viene dopo, contando i millimetri.
	var blocks: Array = []
	blocks.append(["LA CRONACA DELL'ANNO", 3.0, PrintSheet.DIM, false, 0.0])
	blocks.append(["Anno %d" % year, 9.0, PrintSheet.INK, true, 9.0])
	if not chronicle.is_empty():
		blocks.append([str(chronicle.get("title", chronicle_id)), 4.2, PrintSheet.DIM, false, 7.0])

	var truths: Array = world.get("truth_log", [])
	if truths.is_empty():
		blocks.append(["Nessuna Verita' e' stata scritta: l'anno passo' senza lasciare storia.",
			BODY_SIZE, PrintSheet.DIM, false, 12.0])
	var act_seen: int = 0
	for truth in truths:
		var record: Dictionary = truth
		var act: int = int(record.get("act", 0))
		if act != act_seen:
			act_seen = act
			blocks.append([str(ACT_NAMES.get(act, "ATTO %d" % act)), 3.0, PrintSheet.DIM, false, 10.0])
		var text: String = str(record.get("text", ""))
		# Il verbale porta "Anno N, Atto M:" in testa a ogni Verita': sulla
		# pagina l'anno e l'atto sono gia' scritti sopra, e ripeterli a ogni
		# riga e' il registro che parla, non la cronaca.
		var separator: int = text.find(": ")
		if separator > 0 and text.substr(0, separator).begins_with("Anno "):
			text = text.substr(separator + 2)
		var first: bool = true
		for line in PrintSheet.wrap_text(text, PAGE_W - MARGIN * 2.0, BODY_SIZE):
			blocks.append([str(line), BODY_SIZE, PrintSheet.INK, false, 5.0 if first else 0.0])
			first = false

	var results: Dictionary = save.get("destiny_results", {})
	if not results.is_empty():
		blocks.append(["COME FINI' PER I SEGGI", 3.0, PrintSheet.DIM, false, 12.0])
		var seats: Array = results.keys()
		seats.sort()
		for entity_id in seats:
			var level: String = str((results[str(entity_id)] as Dictionary).get("level", "NONE"))
			var name: String = str(
				(world.get("entities", {}) as Dictionary)
				.get(str(entity_id), {}).get("name", entity_id)
			)
			blocks.append(["%s — %s" % [name, str(LEVEL_NAMES.get(level, level))],
				BODY_SIZE, PrintSheet.INK, false, 2.5])

	return _paginate(blocks, year)


static func _paginate(blocks: Array, year: int) -> Array:
	var pages_out: Array = []
	var current: Array = []
	var cursor: float = MARGIN + 8.0
	for block in blocks:
		var advance: float = float(block[4]) + maxf(float(block[1]) * 1.25, LINE * 0.0) + (
			LINE - BODY_SIZE if float(block[1]) <= BODY_SIZE + 0.1 else float(block[1]) * 0.6
		)
		if cursor + advance > PAGE_H - MARGIN and not current.is_empty():
			pages_out.append(current)
			current = []
			cursor = MARGIN + 8.0
		cursor += float(block[4])
		cursor += float(block[1]) * 1.2
		current.append([block, cursor])
		cursor += LINE - BODY_SIZE if float(block[1]) <= BODY_SIZE + 0.1 else float(block[1]) * 0.5
	if not current.is_empty():
		pages_out.append(current)

	var out: Array = []
	for index in range(pages_out.size()):
		out.append(_page_svg(pages_out[index], year, index + 1, pages_out.size()))
	return out


static func _page_svg(placed: Array, year: int, number: int, total: int) -> String:
	var out: Array = []
	out.append(
		'<svg xmlns="http://www.w3.org/2000/svg" width="%dmm" height="%dmm" viewBox="0 0 %d %d">'
		% [int(PAGE_W), int(PAGE_H), int(PAGE_W), int(PAGE_H)]
	)
	out.append('<rect width="%d" height="%d" fill="%s"/>' % [int(PAGE_W), int(PAGE_H), PrintSheet.PAPER])
	for entry in placed:
		var block: Array = entry[0]
		var baseline: float = float(entry[1])
		out.append(_line(MARGIN, baseline, str(block[0]), float(block[1]), str(block[2]), bool(block[3])))
	out.append(_line(
		MARGIN, PAGE_H - 12.0,
		"ECHOES · la cronaca dell'anno %d · pagina %d di %d" % [year, number, total],
		2.6, PrintSheet.DIM, false
	))
	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


static func _line(x: float, y: float, text: String, size: float, colour: String, bold: bool) -> String:
	var spacing: String = ' letter-spacing="0.8"' if size <= 3.0 and text == text.to_upper() else ""
	var family: String = "serif" if size >= 4.0 else "sans-serif"
	return (
		'<text x="%.2f" y="%.2f" font-family="%s" font-size="%.1f"%s%s fill="%s">%s</text>'
		% [x, y, family, size, ' font-weight="bold"' if bold else "", spacing, colour,
			ArtPlaceholder.escape(text)]
	)
