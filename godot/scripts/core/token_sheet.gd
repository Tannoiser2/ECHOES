extends RefCounted
## I segnalini e la traccia dei valori (D-097, voce 7).
##
## Il committente ha deciso: i valori che cambiano - presenza, controllo, il
## calore delle domande - vivono su **token e segnalini**, non su ghiere o
## dadi. Questo file genera i due fogli che ne seguono: la fustella dei
## segnalini (un foglio per saga: ogni casa ha i suoi) e la plancia dei
## tracciati su cui i segnalini di valore camminano.
##
## Stessa disciplina dei fogli di stampa: A4 in millimetri, SVG deterministico,
## nessun RNG - due export dello stesso dato escono identici byte per byte.

const PrintSheet := preload("res://scripts/core/print_sheet.gd")
const ArtPlaceholder := preload("res://scripts/core/art_placeholder.gd")

const PAGE_W: float = PrintSheet.PAGE_W
const PAGE_H: float = PrintSheet.PAGE_H
const MARGIN: float = 18.0

## Fustella da 15 mm: la taglia sotto cui un segnalino si perde sul tavolo.
const TOKEN_R: float = 7.5
const STEP: float = 19.0

## Quanti per casa: sei Regioni sulla mappa, quindi al piu' sei presenze e sei
## controlli per Entita' - il pezzo in piu' non esiste, come da §19.4.
const PER_ENTITY: int = 6


## La fustella dei segnalini di una Chronicle: per ogni casa una riga di tondi
## pieni (presenza) e una di anelli (controllo), piu' i segnalini di valore
## (rombi, uno per domanda in gioco piu' due di scorta) e il quadrato del Drift.
static func tokens_svg(data: RefCounted, chronicle_id: String) -> String:
	var chronicle: Dictionary = data.chronicles.get(chronicle_id, {})
	var title: String = str(chronicle.get("title", chronicle_id))
	var out: Array = []
	out.append(
		'<svg xmlns="http://www.w3.org/2000/svg" width="%dmm" height="%dmm" viewBox="0 0 %d %d">'
		% [int(PAGE_W), int(PAGE_H), int(PAGE_W), int(PAGE_H)]
	)
	out.append('<rect width="%d" height="%d" fill="#ffffff"/>' % [int(PAGE_W), int(PAGE_H)])
	out.append(_text(MARGIN, MARGIN - 5.0,
		"ECHOES · segnalini — %s · fustella 15 mm, si stampa al 100%%" % title,
		3.0, "#999999", false))

	var y: float = MARGIN + 12.0
	var ids: Array = (chronicle.get("entities", []) as Array).duplicate()
	ids.sort()
	for entity_id in ids:
		var name: String = str(data.entities[str(entity_id)]["name"])
		var letter: String = str(entity_id).trim_prefix("ENT_").substr(0, 1)
		out.append(_text(MARGIN, y, "%s — %d presenze (tondo pieno), %d controlli (anello)" % [
			name, PER_ENTITY, PER_ENTITY
		], 3.2, "#333333", true))
		y += 7.0
		for index in range(PER_ENTITY):
			var x: float = MARGIN + TOKEN_R + float(index) * STEP
			out.append(_token_full(x, y + TOKEN_R, letter))
		for index in range(PER_ENTITY):
			var x: float = MARGIN + TOKEN_R + float(PER_ENTITY + index) * STEP
			out.append(_token_ring(x, y + TOKEN_R, letter))
		y += TOKEN_R * 2.0 + 8.0

	out.append(_text(MARGIN, y,
		"Valori delle domande (rombo, sulla traccia) e Drift (quadrato)", 3.2, "#333333", true))
	y += 7.0
	for index in range(PER_ENTITY):
		var x: float = MARGIN + TOKEN_R + float(index) * STEP
		out.append(_token_diamond(x, y + TOKEN_R))
	out.append(_token_square(MARGIN + TOKEN_R + float(PER_ENTITY) * STEP, y + TOKEN_R))
	y += TOKEN_R * 2.0 + 10.0

	out.append(_text(MARGIN, y,
		"Il segnalino di valore parte dal valore d'autore scritto sulla carta della domanda.",
		2.8, "#666666", false))
	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


## La plancia dei tracciati: quattro corsie 0-8 su cui camminano i rombi. La
## carta mini della domanda si appoggia a sinistra della sua corsia; la soglia
## sta sulla carta, perche' cambia da domanda a domanda.
static func track_board_svg() -> String:
	var out: Array = []
	out.append(
		'<svg xmlns="http://www.w3.org/2000/svg" width="%dmm" height="%dmm" viewBox="0 0 %d %d">'
		% [int(PAGE_W), int(PAGE_H), int(PAGE_W), int(PAGE_H)]
	)
	out.append('<rect width="%d" height="%d" fill="#ffffff"/>' % [int(PAGE_W), int(PAGE_H)])
	out.append(_text(MARGIN, MARGIN - 5.0,
		"ECHOES · la traccia dei valori · una corsia per domanda in gioco", 3.0, "#999999", false))

	var box: float = 17.0
	var slot_w: float = 46.0
	var y: float = MARGIN + 14.0
	for lane in range(4):
		out.append(_text(MARGIN, y - 3.0, "Domanda %s — la carta mini si appoggia qui:" % [
			["I", "II", "III", "IV"][lane]
		], 3.2, "#333333", true))
		# Il posto della carta mini (44x68 in scala, sdraiata: 68x44 non serve -
		# basta l'ingombro del titolo), poi le caselle 0-8.
		out.append(
			'<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="none" stroke="#bbbbbb" stroke-width="0.3" stroke-dasharray="2,1.5"/>'
			% [MARGIN, y, slot_w, box * 2.0]
		)
		for value in range(9):
			var x: float = MARGIN + slot_w + 6.0 + float(value) * box
			out.append(
				'<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="none" stroke="#333333" stroke-width="0.4"/>'
				% [x, y, box, box]
			)
			out.append(_text(x + box * 0.5 - 1.2, y + box * 0.62, str(value), 4.0, "#333333", false))
		out.append(_text(MARGIN + slot_w + 6.0, y + box + 5.0,
			"La soglia e' scritta sulla carta: raggiunta, si apre il Consiglio.",
			2.6, "#666666", false))
		y += box * 2.0 + 14.0

	out.append(_text(MARGIN, y + 2.0,
		"Il quadrato del Drift avanza sulla corsia che il sacchetto nomina a ogni round.",
		2.8, "#666666", false))
	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


static func _token_full(x: float, y: float, letter: String) -> String:
	return (
		'<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s" stroke="#333333" stroke-width="0.4"/>'
		% [x, y, TOKEN_R, PrintSheet.PAPER]
		+ _text(x - 1.9, y + 2.0, letter, 5.5, PrintSheet.INK, true)
	)


static func _token_ring(x: float, y: float, letter: String) -> String:
	return (
		'<circle cx="%.1f" cy="%.1f" r="%.1f" fill="#ffffff" stroke="%s" stroke-width="1.6"/>'
		% [x, y, TOKEN_R - 0.8, PrintSheet.PAPER]
		+ _text(x - 1.9, y + 2.0, letter, 5.5, "#333333", true)
	)


static func _token_diamond(x: float, y: float) -> String:
	var r: float = TOKEN_R - 0.5
	return (
		'<path d="M %.1f %.1f L %.1f %.1f L %.1f %.1f L %.1f %.1f Z" fill="%s" stroke="#333333" stroke-width="0.4"/>'
		% [x, y - r, x + r, y, x, y + r, x - r, y, PrintSheet.PAPER]
	)


static func _token_square(x: float, y: float) -> String:
	var r: float = TOKEN_R - 1.0
	return (
		'<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="#ffffff" stroke="%s" stroke-width="1.4"/>'
		% [x - r, y - r, r * 2.0, r * 2.0, PrintSheet.PAPER]
	)


static func _text(x: float, y: float, text: String, size: float, colour: String, bold: bool) -> String:
	return (
		'<text x="%.2f" y="%.2f" font-family="sans-serif" font-size="%.1f"%s fill="%s">%s</text>'
		% [x, y, size, ' font-weight="bold"' if bold else "", colour, ArtPlaceholder.escape(text)]
	)
