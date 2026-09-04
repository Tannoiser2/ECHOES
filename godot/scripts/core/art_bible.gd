extends RefCounted
## La ART_BIBLE letta invece che ricopiata.
##
## I tre MASTER PROMPT e le loro variation key stanno in `docs/ART_BIBLE.md`, che
## e' un documento per persone. Il brief d'arte ha bisogno degli stessi prompt
## con dentro il soggetto che solo i dati conoscono - il titolo della carta, la
## riga che le ha scritto il suo autore, il bioma di una Regione.
##
## Copiarli qui avrebbe creato la seconda copia di un testo che deve restare
## uno, ed e' esattamente l'errore che questo progetto ha gia' commesso due
## volte (i colori di famiglia, le funzioni di Propp). Quindi si legge il
## documento: il prompt resta della ART_BIBLE, il soggetto resta dei dati, e il
## brief e' la giunzione.
##
## Se il file non c'e' - un export lanciato da un'altra cartella, un pacchetto
## senza `docs/` - il brief esce lo stesso, con il rimando al posto del prompt.
## Un brief incompleto e' utile; un export che fallisce perche' manca un
## documento di prosa non lo e'.

const CardFace := preload("res://scripts/core/card_face.gd")

## Quale MASTER PROMPT vale per quale mazzo, e con quale variazione.
const PROMPT_FOR: Dictionary = {
	"asset": 1, "echo": 2, "region": 3, "entity": 4, "destiny": 5, "objective": 7,
}

## Le intestazioni delle tabelle di variation key. Sono righe di tabella come le
## altre e vanno saltate: senza questo elenco la parola «archetipo» diventerebbe
## una chiave di variazione con dentro la parola «accento».
const HEADERS: Array = ["FAMIGLIA", "BIOME", "ARCHETIPO"]

## Il posto dello stile, che non e' un MASTER PROMPT: i sei sono numerati da 1, e
## `0` gia' vuol dire «non siamo dentro nessuna sezione».
const STYLE: int = -1

## Lo stile, uno per tutta la grafica del gioco (0.1.312). Sta nella ART_BIBLE
## sotto `## LO STILE` e il brief lo stampa **una volta**: fino alla 0.1.311 ogni
## MASTER PROMPT se lo portava dentro, e 146 voci del brief erano 146 copie dello
## stesso paragrafo con dentro un titolo diverso.
var _style: String = ""
var _prompts: Dictionary = {}
## Accenti e guide **per MASTER PROMPT**, non in un unico mucchio: `PEOPLE` e' sia
## una famiglia di Asset sia un archetipo di Casata, e con un dizionario solo il
## ritratto di un popolo si sarebbe preso l'accento della famiglia PEOPLE - o
## viceversa, a seconda di quale tabella il documento elenca per ultima.
var _accents: Dictionary = {}
var _guides: Dictionary = {}
var _path: String = ""


func available() -> bool:
	return not _prompts.is_empty()


## Lo stile del gioco, uno. Vuoto se la ART_BIBLE non e' stata letta.
func style() -> String:
	return _style


func read(path: String) -> bool:
	_path = path
	var text: String = ""
	var handle: FileAccess = FileAccess.open(path, FileAccess.READ)
	if handle != null:
		text = handle.get_as_text()
		handle.close()
	if text == "":
		return false
	var lines: Array = Array(text.split("\n"))
	var current: int = 0
	var in_block: bool = false
	var block: Array = []
	for raw in lines:
		var line: String = str(raw)
		if line.begins_with("## LO STILE"):
			current = STYLE
			continue
		if line.begins_with("## MASTER PROMPT"):
			current = int(line.split("—")[0].split("PROMPT")[1].strip_edges())
			continue
		if current == 0:
			continue
		if line.begins_with("```"):
			in_block = not in_block
			if not in_block and not block.is_empty():
				var text_of_block: String = "\n".join(PackedStringArray(block)).strip_edges()
				if current == STYLE:
					if _style == "":
						_style = text_of_block
				elif not _prompts.has(current):
					_prompts[current] = text_of_block
				block = []
			continue
		if in_block:
			block.append(line)
			continue
		# Le righe di variation key: `| **FORCE** | rosso ossido | soggetti | tono |`
		# oppure `| \`CITY\` | oro spento | descrizione |`.
		if line.begins_with("|") and line.count("|") >= 4:
			var cells: Array = []
			for cell in line.split("|"):
				cells.append(str(cell).strip_edges().replace("**", "").replace("`", ""))
			var key: String = str(cells[1]).to_upper()
			if key == "" or key.begins_with("---") or HEADERS.has(key):
				continue
			if not _accents.has(current):
				_accents[current] = {}
				_guides[current] = {}
			(_accents[current] as Dictionary)[key] = str(cells[2])
			if cells.size() > 3:
				(_guides[current] as Dictionary)[key] = str(cells[3])
	return available()


## Il prompt composto per una faccia, pronto da mandare. Vuoto se il mazzo non
## ha un MASTER PROMPT o se la ART_BIBLE non e' stata letta.
## **I varchi sui lati** (D-390), per chi disegna la tessera. Senza questa
## riga le dieci tessere si illustrano con quattro lati uguali, e la regola —
## *«se due lati hanno adiacenze in comune lo spostamento e' permesso»* — sul
## tavolo **non si vede**: si potrebbe leggere solo nell'app, che e' esattamente
## quello che la direzione di questo progetto vieta.
const VARCHI_DETTI: Dictionary = {
	"N": "top", "E": "right", "S": "bottom", "O": "left",
}


static func _passages_line(face: Dictionary) -> String:
	var sides: Array = face.get("edges", []) as Array
	if sides.is_empty():
		return ""
	# **Quattro varchi disegnati, e i chiusi li copre un gettone** (D-429, strada
	# (2) scelta dal committente). Prima questa riga diceva a chi disegna
	# *«questi due lati sono chiusi dal terreno»*, e allora l'illustrazione aveva
	# un sopra: la tessera si posa **girandola** finche' un varco combacia
	# (D-390), e un disegno che nomina i suoi lati chiusi girato di novanta gradi
	# mente. Adesso ogni tessera si illustra con la strada che arriva a **tutti e
	# quattro i bordi** — cosi' il disegno non gira mai — e i lati che il dato
	# chiude si coprono al tavolo con la pedina «varco chiuso».
	var closed: PackedStringArray = PackedStringArray()
	for side in VARCHI_DETTI:
		if not sides.has(str(side)):
			closed.append(str(VARCHI_DETTI[str(side)]))
	if closed.is_empty():
		return "A visible way in and out reaches all four edges."
	return (
		"A visible way in and out reaches all four edges: draw the way through on"
		+ " every side, including the %s edge%s, which a landslide token covers"
		+ " once the tile is on the table."
	) % [_listed(closed), "" if closed.size() == 1 else "s"]


## «top, right and bottom» invece di «top and right and bottom».
static func _listed(words: PackedStringArray) -> String:
	if words.size() <= 1:
		return "" if words.is_empty() else str(words[0])
	var head: PackedStringArray = PackedStringArray()
	for i in range(words.size() - 1):
		head.append(str(words[i]))
	return "%s and %s" % [", ".join(head), str(words[words.size() - 1])]


func prompt_for(
	face: Dictionary, subject: String, situation: String, accent_key: String
) -> String:
	var which: int = int(PROMPT_FOR.get(str(face["deck"]), 0))
	if which == 0 or not _prompts.has(which):
		return ""
	var text: String = str(_prompts[which])
	text = text.replace("{SOGGETTO}", subject)
	text = text.replace("{SITUAZIONE}", situation if situation != "" else subject)
	text = text.replace("{REGIONE}", str(face["title"]))
	var guides: Dictionary = _guides.get(which, {})
	var accents: Dictionary = _accents.get(which, {})
	text = text.replace("{DESCRIZIONE}", str(guides.get(accent_key, subject)))
	text = text.replace("{ACCENTO}", str(accents.get(accent_key, "l'accento della sua famiglia")))
	text = text.replace("{VARCHI}", _passages_line(face))
	return text


## **Il prompt di una faccia, pronto** (D-445): lo stesso che il brief stampa,
## chiesto da fuori — dalla scheda di ogni tipo di carta — senza rifare il giro
## di soggetto, scena e accento. Vuoto se il mazzo non ha un MASTER PROMPT.
func prompt_of(face: Dictionary, data: RefCounted) -> String:
	var subject: String = _subject(face)
	var situation: String = _situation(face, data).strip_edges()
	return prompt_for(face, subject, situation, _accent_key(face, data))


## La scena di una faccia, scritta dal suo autore: quello che il prompt manda.
func scene_of(face: Dictionary, data: RefCounted) -> String:
	return _situation(face, data).strip_edges()


## Il MASTER PROMPT di un mazzo, coi segnaposto ancora dentro: e' il **prompt
## generale** del tipo di carta, quello che una scheda stampa una volta sola.
func template_of(deck: String) -> String:
	var which: int = int(PROMPT_FOR.get(deck, 0))
	return str(_prompts.get(which, ""))


## Ogni chiave d'arte in uso, con il suo prompt. Raggruppato per mazzo e in
## ordine di id, come tutto il resto dell'export.
func brief(data: RefCounted) -> String:
	var lines: Array = [
		"# ECHOES — brief d'arte",
		"",
		"Ogni `art_prompt_key` in uso nei dati, con **la scena di quella carta** e",
		"l'inquadratura del suo mazzo.",
		"",
		"**Lo stile si incolla una volta, non 146.** Sta qui sotto, e vale per tutta",
		"la grafica del gioco: si manda quello, e poi la scheda della carta. Fino",
		"alla 0.1.311 ogni voce se lo ricopiava dentro, e la scena della carta non",
		"c'era: il prompt di un Asset era il suo titolo dentro un paragrafo di stile.",
		"",
		"**Generato da `cli/run_export.gd`: non si modifica a mano.** Ne esce una",
		"copia in `out/export/` a ogni `tools/run_export.sh`, e quella committata in",
		"`docs/BRIEF_ARTE.md` e' la stessa - la CI le confronta.",
		"",
	]
	if not available():
		lines.append("> **ART_BIBLE non letta** (`%s`). Sotto restano le chiavi e le" % _path)
		lines.append("> scene; lo stile e i prompt sono nel documento.")
		lines.append("")
	if _style != "":
		lines.append("## Lo stile — una volta, per tutto")
		lines.append("")
		lines.append("```")
		lines.append(_style)
		lines.append("```")
		lines.append("")

	for deck in ["asset", "echo", "region", "entity", "destiny", "objective"]:
		var faces: Array = CardFace.deck_of(str(deck), data)
		if faces.is_empty():
			continue
		lines.append("## %s" % str(deck))
		lines.append("")
		if not PROMPT_FOR.has(str(deck)):
			lines.append("La ART_BIBLE non ha un MASTER PROMPT per questo mazzo: i tre esistenti")
			lines.append("sono carta Asset, carta Echo e tessera Regione. Le chiavi sotto sono")
			lines.append("**in uso e senza prompt** — o si scrive il quarto, o si tolgono.")
			lines.append("")
		for face in faces:
			var item: Dictionary = face
			var key: String = str(item["art_prompt_key"])
			if key == "":
				continue
			lines.append("### `%s` — %s" % [key, str(item["title"])])
			lines.append("")
			var subject: String = _subject(item)
			var situation: String = _situation(item, data).strip_edges()
			lines.append("- **soggetto**: %s" % subject)
			lines.append("- **scena**: %s" % (situation if situation != "" else "—"))
			lines.append("- **id**: `%s`" % str(item["id"]))
			var prompt: String = prompt_for(item, subject, situation, _accent_key(item, data))
			if prompt != "":
				lines.append("")
				lines.append("```")
				lines.append(prompt)
				lines.append("```")
			lines.append("")
	return "\n".join(PackedStringArray(lines)) + "\n"


## Le chiavi in uso che nessun MASTER PROMPT copre. Il primo strumento che passa
## in rassegna tutte le chiavi e' anche il primo che puo' accorgersene.
func keys_without_prompt(data: RefCounted) -> Array:
	var out: Array = []
	for deck in CardFace.DECKS + CardFace.TILES:
		if PROMPT_FOR.has(str(deck)):
			continue
		for face in CardFace.deck_of(str(deck), data):
			var key: String = str((face as Dictionary)["art_prompt_key"])
			if key != "":
				out.append(key)
	return out


## Il soggetto e' il **nome** della carta, e basta. Fino alla 0.1.311 provava a
## essere anche la scena, prendendo la prima riga del corpo stampato — e quando
## D-340 ha tolto il racconto dalla faccia, quella riga e' diventata vuota su
## **48 Asset e 39 Echo**: 87 carte il cui prompt d'arte era il titolo dentro un
## paragrafo di stile. La scena adesso e' `_situation`, e viene dal dato.
func _subject(face: Dictionary) -> String:
	return str(face["title"])


## **La scena che la carta racconta**, scritta dal suo autore e ferma nel dato.
##
## D-340 diceva, togliendo il racconto dalla faccia: *«Il racconto esce dalla
## faccia e resta nel dato: lo legge il brief d'arte, che e' il posto dove
## serve.»* Il brief non lo leggeva — leggeva la faccia, che adesso non ce
## l'aveva piu'. Il cancello restava verde perche' confronta il brief con quello
## che il codice produce, e il codice produceva lo stesso niente dalle due parti.
func _situation(face: Dictionary, data: RefCounted) -> String:
	var deck: String = str(face["deck"])
	var id: String = str(face["id"])
	match deck:
		"asset":
			return str((data.assets[id] as Dictionary).get("rules_text", ""))
		"echo":
			return str((data.echo_cards[id] as Dictionary).get("description", ""))
		"region":
			return str((data.regions[id] as Dictionary).get("description", ""))
		"destiny":
			return str((data.destinies[id] as Dictionary).get("description", ""))
		"objective":
			return str((data.objectives[id] as Dictionary).get("description", ""))
		"entity":
			# Il mazzo delle Casate e' fatto di **vite**, non di case: la scena e'
			# quella dell'incarnazione che siede, non quella della casata.
			if data.entities.has(id):
				return str((data.entities[id] as Dictionary).get("description", ""))
			var found: Dictionary = CardFace.life_of(id, data)
			if not found.is_empty():
				return str((found["life"] as Dictionary).get("description", ""))
	return ""


## Ogni chiave d'arte in uso che **non porta una scena**. La guardia del difetto
## che questa versione ha corretto: una carta il cui prompt e' il suo nome.
func keys_without_situation(data: RefCounted) -> Array:
	var out: Array = []
	for deck in CardFace.DECKS + CardFace.TILES:
		for face in CardFace.deck_of(str(deck), data):
			var item: Dictionary = face
			if str(item["art_prompt_key"]) == "":
				continue
			if _situation(item, data).strip_edges() == "":
				out.append(str(item["art_prompt_key"]))
	return out


## Quale riga della variation key vale per questa faccia: la famiglia per un
## Asset, la famiglia drammatica (in italiano, come la scrive la tabella) per un
## Echo, il bioma per una Regione.
func _accent_key(face: Dictionary, data: RefCounted) -> String:
	var deck: String = str(face["deck"])
	var id: String = str(face["id"])
	match deck:
		"asset":
			return str(data.assets[id]["family"])
		"echo":
			var family: String = str(data.echo_cards[id]["dramatic_family"])
			var described: Dictionary = CardFace.DRAMA.get(family, {})
			if described.is_empty():
				return family
			return str(described["label"]).split(" —")[0]
		"region":
			return str(data.regions[id]["biome"])
		"entity":
			# L'archetipo, che e' la cosa che cambia davvero un ritratto: un
			# sovrano, una persona, una fazione, un culto, un popolo e una
			# creatura non si dipingono nello stesso modo (D-065). Una vita del
			# seggio (D-111) porta l'archetipo del suo seggio.
			if data.entities.has(id):
				return str(data.entities[id]["archetype"])
			var found: Dictionary = CardFace.life_of(id, data)
			if not found.is_empty():
				return str((found["seat"] as Dictionary)["archetype"])
			return ""
		"destiny":
			# L'archetipo di chi la desidera: il Destino di una casa porta il
			# colore della casa, cosi' le due carte del pool - l'ambizione di
			# partenza e quella dopo - sono due quadri della stessa parete.
			# Il Destino condivisibile (D-115) non ha una casa: nessun accento.
			var owner: String = str(data.destinies[id]["entity_id"])
			if owner == "$self":
				return ""
			return str(data.entities[owner]["archetype"])
	return ""
