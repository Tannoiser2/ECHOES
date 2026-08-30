extends SceneTree
## **Lo scheletro delle carte** (D-345).
##
##   godot --headless --path godot --script res://cli/run_card_skeleton.gd -- \
##       --out=docs/SCHELETRO_CARTE.md
##
## Il committente: *«voglio la struttura e lo scheletro di tutte le carte»*.
##
## Lo scheletro **non e' scritto qui**: si ricava dalle facce vere. Per ogni
## mazzo la sonda guarda tutte le facce, raccoglie **i blocchi che portano** —
## il titolo, il sottotitolo, la cifra d'angolo, e l'intestazione di ogni riga
## meccanica — e conta su quante carte ognuno compare. Un blocco che sparisce da
## una faccia sparisce dal documento; uno nuovo entra il giorno che entra.
##
## Le sole righe scritte a mano sono **il mestiere di ogni mazzo**: cosa quel
## pezzo fa al tavolo. Non e' un fatto che il codice possa smentire — e' quello
## che il mazzo e' — e sta qui perche' un documento che elenca blocchi senza
## dire a cosa servono non lo legge nessuno.

const DataSet := preload("res://scripts/core/data_set.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")

## Il mestiere di ogni pezzo al tavolo, e come arriva in mano.
const JOBS: Dictionary = {
	"asset": [
		"La carta che si cala: **tu scegli dove e quale delle due Azioni**.",
		"Arriva con ACQUISIRE, o dalla mappa a inizio Atto. Limite di mano: 7.",
		"Costa 1 Occasione. In alternativa la impegni al Consiglio, e vale forza.",
	],
	"echo": [
		"La carta del Narratore, una funzione di Propp: **tu scegli solo quando**.",
		"Dove cade e cosa lascia lo decide il mondo, non chi la gioca.",
		"Due a testa a inizio Atto, dal sacchetto dell'Atto. Costa 1 Occasione.",
	],
	"tension": [
		"La domanda, appoggiata alla traccia dei valori: dice **quando si scalda**.",
		"Non si gioca e non si tiene in mano: sta sul tavolo tutto l'anno.",
	],
	"council": [
		"La scheda che si tira fuori quando il Consiglio si apre.",
		"Dice la domanda e **le dodici caselle** con cui il tavolo la risolve.",
	],
	"destiny": [
		"L'ambizione di una casa, **dietro il paravento**: la scala per contare.",
		"Non si gioca: si guarda per sapere quanto manca.",
	],
	"entity": [
		"La casa, in vista tutta la partita: cosa sa fare e cosa vuole lasciare.",
	],
	"region": [
		"La tessera di mappa. **Porta i segni** che ogni carta Azione bersaglia.",
	],
}

## Come si chiama un formato al tavolo.
const SHAPES: Dictionary = {
	"CARD": "63x88 — la carta da gioco che sta in mano",
	"TAROT": "70x120 — il tarocco che resta in vista",
	"MINI": "44x68 — la mini che sta accanto a una traccia",
	"TILE": "80x80 — la tessera quadrata della mappa",
}


func _initialize() -> void:
	var out_path: String = "docs/SCHELETRO_CARTE.md"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for e in data.errors:
			printerr("  %s" % e)
		quit(3)
		return

	var decks: Dictionary = {}
	var order: Array = []
	for face_v in CardFace.every(data):
		var face: Dictionary = face_v
		var deck: String = str(face["deck"])
		if not decks.has(deck):
			decks[deck] = {
				"facce": 0, "copie": 0, "shape": str(face["shape"]),
				"blocchi": {}, "ordine": [], "esempio": face,
			}
			order.append(deck)
		var row: Dictionary = decks[deck]
		row["facce"] = int(row["facce"]) + 1
		row["copie"] = int(row["copie"]) + int(face.get("copies", 1))
		for pair in [
			["il titolo", str(face["title"])],
			["il sottotitolo", str(face["subtitle"])],
			["la cifra d'angolo", str(face["corner"])],
			["l'illustrazione", str(face["art_prompt_key"])],
		]:
			if str(pair[1]) != "":
				_count(row, str(pair[0]))
		for paragraph in face["body"] as Array:
			if str(paragraph) != "":
				_count(row, "una riga di testo libero")
		for note in face["notes"] as Array:
			var line: String = str(note)
			if line != "":
				_count(row, _headword(line))

	var lines: Array = []
	lines.append("# ECHOES — Lo scheletro delle carte")
	lines.append("")
	lines.append("<!-- GENERATO da `tools/run_card_skeleton.sh` — non si corregge qui. -->")
	lines.append("")
	lines.append("Cosa porta ogni faccia, **ricavato dalle facce vere**: un blocco che")
	lines.append("sparisce da una carta sparisce da questa pagina, uno nuovo entra il giorno")
	lines.append("che entra. Il numero accanto e' su quante facce del mazzo quel blocco c'e'.")
	lines.append("")
	lines.append("| mazzo | formato | facce | pezzi |")
	lines.append("|---|---|---|---|")
	for deck in order:
		var row: Dictionary = decks[str(deck)]
		lines.append("| **%s** | %s | %d | %d |" % [
			str(deck), str(SHAPES.get(str(row["shape"]), str(row["shape"]))),
			int(row["facce"]), int(row["copie"]),
		])
	lines.append("")
	for deck in order:
		var row: Dictionary = decks[str(deck)]
		lines.append("## Il mazzo `%s`" % str(deck))
		lines.append("")
		for said in JOBS.get(str(deck), []) as Array:
			lines.append(str(said))
		lines.append("")
		lines.append("**Lo scheletro** — %s, %d facce, %d pezzi:" % [
			str(SHAPES.get(str(row["shape"]), "")), int(row["facce"]), int(row["copie"]),
		])
		lines.append("")
		lines.append("| blocco | su quante facce |")
		lines.append("|---|---|")
		for block in row["ordine"]:
			lines.append("| %s | %d su %d |" % [
				str(block), int((row["blocchi"] as Dictionary)[str(block)]), int(row["facce"]),
			])
		lines.append("")
		lines.append("**Una carta vera**, come esce dal foglio di stampa:")
		lines.append("")
		var face: Dictionary = row["esempio"]
		lines.append("> **%s**" % str(face["title"]))
		if str(face["subtitle"]) != "":
			lines.append("> %s" % str(face["subtitle"]))
		if str(face["corner"]) != "":
			lines.append("> angolo: **%s**" % str(face["corner"]))
		for paragraph in face["body"] as Array:
			if str(paragraph) != "":
				lines.append("> %s" % str(paragraph))
		for note in face["notes"] as Array:
			if str(note) != "":
				lines.append("> %s" % str(note))
		lines.append("")

	var file := FileAccess.open(out_path, FileAccess.WRITE)
	file.store_string("\n".join(PackedStringArray(lines)).strip_edges() + "\n")
	file.close()
	print("SCHELETRO -> %s" % out_path)
	for deck in order:
		var row: Dictionary = decks[str(deck)]
		print("  %-10s %3d facce  %4d pezzi  %2d blocchi" % [
			str(deck), int(row["facce"]), int(row["copie"]),
			(row["ordine"] as Array).size(),
		])
	quit(0)


static func _count(row: Dictionary, block: String) -> void:
	var seen: Dictionary = row["blocchi"]
	if not seen.has(block):
		seen[block] = 0
		(row["ordine"] as Array).append(block)
	seen[block] = int(seen[block]) + 1


## L'intestazione di una riga meccanica: **DOVE**, **SEMPRE**, **QUANDO ESCE**.
## Le righe che non ne hanno una si contano per quello che sono.
static func _headword(line: String) -> String:
	if line.begins_with("①") or line.begins_with("②"):
		return "le due Azioni, numerate"
	if line.begins_with("· "):
		return "una casella, una per riga"
	# **Solo lettere**: «+1 sul suo tema» non ha un'intestazione, e prendere «+1»
	# per tale faceva comparire nello scheletro due blocchi che non esistono.
	var words: PackedStringArray = line.split(" ")
	var head: Array = []
	for word in words:
		if word == "":
			continue
		if word != word.to_upper() or word.length() < 2 or not _all_letters(word):
			break
		head.append(word)
	if head.is_empty():
		return "una riga senza intestazione"
	return "**%s**" % " ".join(PackedStringArray(head))


## Una parola fatta di sole lettere: un'intestazione lo e', «+1» no.
static func _all_letters(word: String) -> bool:
	for i in word.length():
		var c: String = word[i]
		if c.to_lower() == c.to_upper():
			return false
	return true
