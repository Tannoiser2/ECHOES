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
const SignLabels := preload("res://scripts/core/sign_labels.gd")

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


## La fustella dei segni delle Regioni (ISSUES 22, D-107): un segnalino
## quadrato per ogni segno che il gioco può posare sulla mappa, con la stessa
## parola italiana che l'app mostra. Le condizioni (curabili) in doppia copia
## e col bordo tratteggiato; le strutture e le Cicatrici in copia singola, le
## Cicatrici nel rosso dei segni permanenti. Quattro segnalini d'insediamento
## portano l'angolo bianco per l'iniziale della casa, scritta a mano.
static func region_signs_svg() -> String:
	var out: Array = []
	_open_page(out, "ECHOES · i segni delle Regioni · si posano sulla mappa, fustella 15 mm")
	var y: float = MARGIN + 10.0

	y = _sign_section(out, y, "Condizioni (2 copie: si tolgono quando la cura arriva)",
		_words_with_prefix("condition:"), 2, "#8a8172", true)
	y = _sign_section(out, y, "Strutture e insediamenti (restano finché qualcuno non li disfa)",
		_words_with_prefix("structure:") + _words_with_prefix("settlement:"), 1, "#5a5244", false)
	# L'insediamento di una casa: il segno porta l'angolo per l'iniziale.
	out.append(_text(MARGIN, y, "Insediamento di una casa (scrivi l'iniziale nell'angolo)", 3.0, "#333333", true))
	y += 6.0
	for index in range(4):
		var x: float = MARGIN + float(index) * STEP
		out.append(_sign_square(x, y, "insediamento", "#5a5244", false))
		out.append(
			'<rect x="%.1f" y="%.1f" width="4.5" height="4.5" fill="none" stroke="#5a5244" stroke-width="0.3"/>'
			% [x + 0.8, y + 0.8]
		)
	y += TOKEN_R * 2.0 + 9.0
	y = _sign_section(out, y, "Cicatrici (una sola: la mappa non le dimentica)",
		_words_with_prefix("scar:"), 1, "#c8553d", false)

	out.append(_text(MARGIN, y + 2.0,
		"Quando il verbale posa un segno, il segnalino va sulla Regione; quando la cura lo toglie, torna nella riserva.",
		2.8, "#666666", false))
	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


## La fustella dei segni delle case: la fama, le scoperte, la scorta giurata -
## si tengono accanto al tarocco della casata. La porta sbarrata (cacciata) e
## il giuramento spezzato in più copie: possono toccare più case insieme.
static func entity_signs_svg() -> String:
	var out: Array = []
	_open_page(out, "ECHOES · i segni delle case · accanto al tarocco della casata, fustella 15 mm")
	var y: float = MARGIN + 10.0

	var words: Array = []
	for tag in SignLabels.ENTITY_WORDS:
		words.append(str(SignLabels.ENTITY_WORDS[tag]))
	words.sort()
	y = _sign_section(out, y, "I segni di una casa (una copia)", words, 1, "#5a5244", false)
	y = _sign_section(out, y, "La porta sbarrata (la cacciata dura fino a fine atto)",
		["cacciata"], 4, "#c8553d", true)
	y = _sign_section(out, y, "Il giuramento spezzato (sta fra le due case che si sono tradite)",
		["giuramento spezzato"], 2, "#c8553d", false)

	out.append("</svg>")
	return "\n".join(PackedStringArray(out)) + "\n"


static func _open_page(out: Array, caption: String) -> void:
	out.append(
		'<svg xmlns="http://www.w3.org/2000/svg" width="%dmm" height="%dmm" viewBox="0 0 %d %d">'
		% [int(PAGE_W), int(PAGE_H), int(PAGE_W), int(PAGE_H)]
	)
	out.append('<rect width="%d" height="%d" fill="#ffffff"/>' % [int(PAGE_W), int(PAGE_H)])
	out.append(_text(MARGIN, MARGIN - 5.0, caption, 3.0, "#999999", false))


static func _words_with_prefix(prefix: String) -> Array:
	var words: Array = []
	var tags: Array = SignLabels.REGION_WORDS.keys()
	tags.sort()
	for tag in tags:
		if str(tag).begins_with(prefix):
			words.append(str(SignLabels.REGION_WORDS[tag]))
	return words


static func _sign_section(
	out: Array, y: float, caption: String, words: Array, copies: int,
	tint: String, dashed: bool
) -> float:
	out.append(_text(MARGIN, y, caption, 3.0, "#333333", true))
	y += 6.0
	var column: int = 0
	var per_row: int = 8
	for word in words:
		for _copy in range(copies):
			var x: float = MARGIN + float(column) * STEP
			out.append(_sign_square(x, y, str(word), tint, dashed))
			column += 1
			if column >= per_row:
				column = 0
				y += TOKEN_R * 2.0 + 6.0
	if column > 0:
		y += TOKEN_R * 2.0 + 6.0
	return y + 3.0


## Un segnalino quadrato 15 mm con la parola dentro, spezzata su due righe se
## serve: la stessa parola che l'app scrive sotto la Regione.
static func _sign_square(x: float, y: float, word: String, tint: String, dashed: bool) -> String:
	var side: float = TOKEN_R * 2.0
	var dash: String = ' stroke-dasharray="1.6,1.1"' if dashed else ""
	var parts: PackedStringArray = word.split(" ")
	var lines: Array = []
	var line: String = ""
	for part in parts:
		var joined: String = part if line == "" else line + " " + part
		if joined.length() > 9 and line != "":
			lines.append(line)
			line = str(part)
		else:
			line = joined
	if line != "":
		lines.append(line)
	var svg: String = (
		'<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="1.5" fill="%s" stroke="%s" stroke-width="0.45"%s/>'
		% [x, y, side, side, PrintSheet.PAPER, tint, dash]
	)
	var line_h: float = 2.9
	var top: float = y + side * 0.5 - line_h * float(lines.size() - 1) * 0.5 + 0.9
	for index in range(lines.size()):
		var text: String = str(lines[index])
		svg += (
			'<text x="%.1f" y="%.1f" font-family="Georgia, serif" font-size="2.5" fill="%s" text-anchor="middle">%s</text>'
			% [x + side * 0.5, top + float(index) * line_h, PrintSheet.INK, text.xml_escape()]
		)
	return svg


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
