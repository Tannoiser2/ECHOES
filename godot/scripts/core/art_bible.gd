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

## Quale MASTER PROMPT vale per quale mazzo, e con quale variazione. Le Entity
## non compaiono: la ART_BIBLE ha tre prompt e nessuno di essi e' un ritratto.
## Vedi `keys_without_prompt()`.
const PROMPT_FOR: Dictionary = {"asset": 1, "echo": 2, "region": 3}

var _prompts: Dictionary = {}
var _accents: Dictionary = {}
var _guides: Dictionary = {}
var _path: String = ""


func available() -> bool:
	return not _prompts.is_empty()


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
		if line.begins_with("## MASTER PROMPT"):
			current = int(line.split("—")[0].split("PROMPT")[1].strip_edges())
			continue
		if current == 0:
			continue
		if line.begins_with("```"):
			in_block = not in_block
			if not in_block and not block.is_empty() and not _prompts.has(current):
				_prompts[current] = "\n".join(PackedStringArray(block)).strip_edges()
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
			if key == "" or key.begins_with("---") or key == "FAMIGLIA" or key == "BIOME":
				continue
			_accents[key] = str(cells[2])
			if cells.size() > 3:
				_guides[key] = str(cells[3])
	return available()


## Il prompt composto per una faccia, pronto da mandare. Vuoto se il mazzo non
## ha un MASTER PROMPT o se la ART_BIBLE non e' stata letta.
func prompt_for(face: Dictionary, subject: String, accent_key: String) -> String:
	var which: int = int(PROMPT_FOR.get(str(face["deck"]), 0))
	if which == 0 or not _prompts.has(which):
		return ""
	var text: String = str(_prompts[which])
	text = text.replace("{SOGGETTO}", subject)
	text = text.replace("{REGIONE}", str(face["title"]))
	text = text.replace("{DESCRIZIONE}", str(_guides.get(accent_key, subject)))
	text = text.replace("{ACCENTO}", str(_accents.get(accent_key, "l'accento della sua famiglia")))
	return text


## Ogni chiave d'arte in uso, con il suo prompt. Raggruppato per mazzo e in
## ordine di id, come tutto il resto dell'export.
func brief(data: RefCounted) -> String:
	var lines: Array = [
		"# ECHOES — brief d'arte",
		"",
		"Ogni `art_prompt_key` in uso nei dati, con il MASTER PROMPT di",
		"`docs/ART_BIBLE.md` gia' composto col soggetto che i dati conoscono.",
		"",
		"**Generato da `cli/run_export.gd`: non si modifica a mano.** Ne esce una",
		"copia in `out/export/` a ogni `tools/run_export.sh`, e quella committata in",
		"`docs/BRIEF_ARTE.md` e' la stessa - la CI le confronta.",
		"",
	]
	if not available():
		lines.append("> **ART_BIBLE non letta** (`%s`). Sotto restano le chiavi e i" % _path)
		lines.append("> soggetti; i prompt sono nel documento.")
		lines.append("")

	for deck in ["asset", "echo", "region", "entity"]:
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
			lines.append("- **soggetto**: %s" % subject)
			lines.append("- **id**: `%s`" % str(item["id"]))
			var prompt: String = prompt_for(item, subject, _accent_key(item, data))
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


func _subject(face: Dictionary) -> String:
	var body: Array = face["body"]
	# Senza il punto finale: il prompt ne mette uno suo, e «una pretesa.. Painterly
	# oil technique» e' il genere di dettaglio che si nota solo dopo averne letti
	# quarantotto.
	var said: String = str(body[0]).strip_edges().trim_suffix(".") if not body.is_empty() else ""
	return "%s — %s" % [str(face["title"]), said] if said != "" else str(face["title"])


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
	return ""
