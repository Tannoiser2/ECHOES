extends SceneTree
## Il catalogo delle carte: cosa fanno, quanto valgono, e il prompt per il disegno.
##
##   godot --headless --path godot --script res://cli/run_card_catalogue.gd -- \
##       --out=../docs/CATALOGO_CARTE.md --bible=../docs/ART_BIBLE.md
##
## Il committente lo ha chiesto in una riga: *«il file con tutte le carte con la
## descrizione, gli effetti, i valori e il prompt per fare l'immagine»*. Quelle
## quattro cose esistevano tutte, in **tre posti diversi**: i numeri in
## `ASSET_MANIFEST.md`, gli effetti solo dentro il JSON, e il prompt in
## `BRIEF_ARTE.md`. Chi doveva far disegnare una carta doveva tenere tre
## documenti aperti e sperare che parlassero della stessa carta.
##
## Qui e' una scheda per carta, e nessuna riga e' scritta a mano: i numeri
## vengono dai dati, le frasi da `AssetText` — lo stesso posto che le scrive
## sullo schermo e sul cartone (D-228) — e il prompt da `ArtBible`, lo stesso che
## compone il brief. Tre sorgenti, una pagina, e non possono divergere.
##
## Generato e committato come `BRIEF_ARTE.md` e `CATALOGO_CONSIGLI.md`.

const DataSet := preload("res://scripts/core/data_set.gd")
const AssetText := preload("res://scripts/core/asset_text.gd")
const EchoText := preload("res://scripts/core/echo_text.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const ArtBible := preload("res://scripts/core/art_bible.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var bible: RefCounted = ArtBible.new()
	bible.read(str(options.get("bible", "../docs/ART_BIBLE.md")))

	var lines: Array = [
		"# ECHOES — il catalogo delle carte",
		"",
		"<!-- FILE GENERATO — si rifa' con `tools/run_card_catalogue.sh`. -->",
		"",
		"Una scheda per carta: **cosa dice**, **cosa fa**, **quanto vale** e il",
		"**prompt** da dare a un generatore di immagini.",
		"",
		"Niente qui e' scritto a mano. I numeri vengono dai dati, le frasi dallo",
		"stesso posto che le scrive sullo schermo e sul cartone, il prompt dallo",
		"stesso che compone il brief d'arte. Se una carta cambia, questa pagina",
		"cambia con lei — e la CI va rossa se qualcuno se ne dimentica.",
		"",
	]

	var counted: int = 0
	counted += _assets(lines, data, bible)
	counted += _echoes(lines, data, bible)
	var pieces: int = _pieces(lines, data)

	lines.append("---")
	lines.append("")
	lines.append("*%d carte e %d pezzi diversi da fare.*" % [counted, pieces])
	lines.append("")

	var text: String = "\n".join(PackedStringArray(lines))
	var out: String = str(options.get("out", ""))
	if out == "":
		print(text)
		quit(0)
		return
	var handle: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	if handle == null:
		printerr("non riesco a scrivere %s" % out)
		quit(3)
		return
	handle.store_string(text)
	handle.close()
	print("scritto %s — %d carte" % [out, counted])
	quit(0)


## Le carte Asset: la mano con cui si gioca e si vota.
func _assets(lines: Array, data: RefCounted, bible: RefCounted) -> int:
	lines.append("---")
	lines.append("")
	lines.append("## Le carte Asset (la mano)")
	lines.append("")
	lines.append("La **forza** e' quanto pesa al Consiglio su una domanda che ascolta la")
	lines.append("sua famiglia; su tutte le altre vale **1**. Le copie nel mazzo le decide")
	lines.append("la rarita'.")
	lines.append("")

	var faces: Dictionary = {}
	for face in CardFace.deck_of("asset", data):
		faces[str((face as Dictionary)["id"])] = face

	var families: Dictionary = {}
	for asset_id in data.assets:
		var family: String = str((data.assets[str(asset_id)] as Dictionary)["family"])
		var here: Array = families.get(family, [])
		here.append(str(asset_id))
		families[family] = here

	var names: Array = families.keys()
	names.sort()
	var counted: int = 0
	for family in names:
		lines.append("### Famiglia %s" % str(family).to_lower())
		lines.append("")
		var ids: Array = families[family]
		ids.sort_custom(func(a: Variant, b: Variant) -> bool:
			var one: int = int((data.assets[str(a)] as Dictionary)["strength"])
			var two: int = int((data.assets[str(b)] as Dictionary)["strength"])
			return one > two if one != two else str(a) < str(b)
		)
		for asset_id in ids:
			var asset: Dictionary = data.assets[str(asset_id)] as Dictionary
			counted += 1
			lines.append("#### %s" % str(asset["title"]))
			lines.append("")
			lines.append("| | |")
			lines.append("|---|---|")
			lines.append("| famiglia | %s |" % str(asset["family"]).to_lower())
			lines.append("| forza | %d |" % int(asset["strength"]))
			var copies: int = int(asset.get("deck_copies", 0))
			lines.append("| rarita' | %s · %d %s nel mazzo |" % [
				str(asset.get("rarity", "?")).to_lower(), copies,
				"copia" if copies == 1 else "copie",
			])
			lines.append("| dopo il voto | %s |" % _discard(str(asset.get("discard_or_retain_rule", ""))))
			var verb: String = AssetText.action_note(asset)
			if verb != "":
				lines.append("| se la cali | %s |" % verb)
			var modifier: String = AssetText.modifier_note(asset)
			if modifier != "":
				lines.append("| al Consiglio | %s |" % modifier)
			var leaves: String = AssetText.cost_note(asset, data)
			if leaves != "":
				lines.append("| cosa lascia | %s |" % leaves)
			lines.append("| id | `%s` |" % str(asset_id))
			lines.append("")
			var rules: String = str(asset.get("rules_text", ""))
			if rules != "":
				lines.append("> %s" % rules)
				lines.append("")
			_prompt(lines, faces.get(str(asset_id), {}) as Dictionary, data, bible)
	return counted


## Le carte Echo: la funzione di Propp che qualcuno cala sul tavolo.
func _echoes(lines: Array, data: RefCounted, bible: RefCounted) -> int:
	lines.append("---")
	lines.append("")
	lines.append("## Le carte Echo (il Narratore)")
	lines.append("")
	lines.append("Non si votano: si **calano**, e la storia prende una piega. Ognuna porta")
	lines.append("una funzione di Propp, e alcune convocano un Consiglio.")
	lines.append("")

	var faces: Dictionary = {}
	for face in CardFace.deck_of("echo", data):
		faces[str((face as Dictionary)["id"])] = face

	var ids: Array = []
	for card_id in data.echo_cards:
		ids.append(str(card_id))
	ids.sort()
	var counted: int = 0
	for card_id in ids:
		var card: Dictionary = data.echo_cards[str(card_id)] as Dictionary
		counted += 1
		lines.append("### %s" % str(card["title"]))
		lines.append("")
		lines.append("| | |")
		lines.append("|---|---|")
		lines.append("| famiglia | %s |" % str(card.get("dramatic_family", "")).to_lower())
		lines.append("| funzione | %s |" % str(card.get("function_id", "")).to_lower())
		var forced: Variant = card.get("forces_confluence_on", null)
		if forced != null and str(forced) != "":
			var about: Variant = data.tensions.get(str(forced))
			lines.append("| convoca un Consiglio | su %s |" % (
				str(forced) if about == null else str((about as Dictionary)["title"])
			))
		var does: String = EchoText.note(card, data)
		if does != "":
			lines.append("| cosa fa | %s |" % does)
		lines.append("| id | `%s` |" % str(card_id))
		lines.append("")
		var description: String = str(card.get("description", ""))
		if description != "":
			lines.append("> %s" % description)
			lines.append("")
		_prompt(lines, faces.get(str(card_id), {}) as Dictionary, data, bible)
	return counted


## I pezzi che stanno sulla mappa: cosa serve fabbricare, e quanti.
##
## Il committente lo ha chiesto insieme alle carte: *«tutte le pedine che devo
## generare per indicare le varie cose sulla mappa — castelli, effetti,
## cicatrici, eventi»*. Sono quattro famiglie diverse, e vale la pena tenerle
## separate perche' si comportano in modo diverso al tavolo:
##
## - le **pietre** si alzano e salgono di grado, e hanno un padrone;
## - le **condizioni** vanno e vengono su una Regione;
## - le **cicatrici** restano per sempre, anche fra un'era e l'altra;
## - le **pedine** e i **vessilli** sono di chi siede, e si contano.
func _pieces(lines: Array, data: RefCounted) -> int:
	lines.append("---")
	lines.append("")
	lines.append("## I pezzi sulla mappa")
	lines.append("")
	lines.append("Quello che va fabbricato per far vedere il mondo. La **forma** e' quella")
	lines.append("che l'app disegna gia': un pezzo di cartone che le somiglia si riconosce")
	lines.append("senza leggere niente, ed e' lo scopo.")
	lines.append("")

	var kinds: int = 0

	lines.append("### Le pietre: quello che si costruisce")
	lines.append("")
	lines.append("Ogni pietra sale di grado invece di essere sostituita: **un pezzo per")
	lines.append("grado**, cosi' al tavolo si vede crescere. Quelle con un padrone vanno nel")
	lines.append("colore di chi le tiene — servono in tutti i colori dei seggi.")
	lines.append("")
	lines.append("| pietra | forma | gradi | di chi e' | rovina |")
	lines.append("|---|---|---|---|---|")
	var stones: Array = []
	for structure_id in data.structure_types:
		stones.append(str(structure_id))
	stones.sort()
	for structure_id in stones:
		var stone: Dictionary = data.structure_types[str(structure_id)] as Dictionary
		var grades: Array = []
		for grade in stone.get("grades", []):
			grades.append(str((grade as Dictionary)["name"]))
			kinds += 1
		var ruin: Dictionary = stone.get("ruin", {}) as Dictionary
		if not ruin.is_empty():
			kinds += 1
		lines.append("| %s | %s | %s | %s | %s |" % [
			str(stone.get("name", structure_id)),
			str(stone.get("family", "")).to_lower(),
			" → ".join(PackedStringArray(grades)),
			"di una casa" if bool(stone.get("owned", false)) else "di nessuno",
			str(ruin.get("name", "—")),
		])
	lines.append("")

	lines.append("### Le condizioni: quello che succede a una Regione")
	lines.append("")
	lines.append("Vanno e vengono. Un segnalino piatto da posare sulla Regione, e uno solo")
	lines.append("per tipo basta se non capitano due volte insieme — ma **una Regione puo'")
	lines.append("portarne piu' d'una**, quindi conviene averne qualcuna di scorta.")
	lines.append("")
	var conditions: Array = _written(data, "condition:")
	lines.append("| segnalino | segno |")
	lines.append("|---|---|")
	for tag in conditions:
		kinds += 1
		lines.append("| %s | `%s` |" % [SignLabels.label(str(tag), data), str(tag)])
	lines.append("")

	lines.append("### Le cicatrici: quello che non viene piu' via")
	lines.append("")
	lines.append("Una cicatrice **resta**, e attraversa le ere: si posa e non si toglie piu'.")
	lines.append("Conviene che si distingua a colpo d'occhio da una condizione, perche' la")
	lines.append("differenza fra «adesso» e «per sempre» e' tutta qui.")
	lines.append("")
	var scars: Array = _written(data, "scar:")
	lines.append("| cicatrice | segno |")
	lines.append("|---|---|")
	for tag in scars:
		kinds += 1
		lines.append("| %s | `%s` |" % [SignLabels.label(str(tag), data), str(tag)])
	lines.append("")

	lines.append("### Le pedine e i vessilli: di chi e' cosa")
	lines.append("")
	var seats: int = 0
	for entity_id in data.entities:
		seats += 1
	var tokens: int = 0
	for chronicle_id in data.chronicles:
		tokens = maxi(tokens, int((data.chronicles[str(chronicle_id)] as Dictionary).get(
			"presence_tokens", 0
		)))
	lines.append("| pezzo | quanti |")
	lines.append("|---|---|")
	lines.append("| pedina di presenza | **%d per casa**, in %d colori = %d |" % [
		tokens, seats, tokens * seats,
	])
	kinds += 1
	lines.append("| vessillo del padrone | uno per Regione, in tutti e %d i colori |" % seats)
	kinds += 1
	lines.append("| segnalino di domanda | uno per ognuna delle %d domande |" % data.tensions.size())
	kinds += 1
	lines.append("")
	lines.append("Le case della scatola sono %d e a un tavolo ne siedono quattro: i colori" % seats)
	lines.append("servono tutti, perche' quali quattro lo decide l'anno.")
	lines.append("")
	return kinds


## I segni con questo prefisso che i dati sanno davvero scrivere su una Regione.
## Presi dagli Effetti, non da un elenco a mano: un segnalino per un segno che
## nessuno posa e' cartone sprecato, e uno mancante e' una regola che al tavolo
## non si vede.
func _written(data: RefCounted, prefix: String) -> Array:
	var found: Dictionary = {}
	var writers: Array = []
	for consequence_id in data.consequences:
		var consequence: Dictionary = data.consequences[str(consequence_id)] as Dictionary
		writers.append(consequence.get("effects", []))
		var scar: Dictionary = consequence.get("scar", {}) as Dictionary
		if not scar.is_empty() and str(scar.get("tag", "")).begins_with(prefix):
			found[str(scar["tag"])] = true
	for asset_id in data.assets:
		writers.append((data.assets[str(asset_id)] as Dictionary).get("on_commit_effects", []))
	for card_id in data.echo_cards:
		for hook in (data.echo_cards[str(card_id)] as Dictionary).get("effect_hooks", []):
			if (hook as Dictionary).has("effect"):
				writers.append([(hook as Dictionary)["effect"]])
	for structure_id in data.structure_types:
		var ruin: Dictionary = (
			data.structure_types[str(structure_id)] as Dictionary
		).get("ruin", {}) as Dictionary
		if str(ruin.get("scar", "")).begins_with(prefix):
			found[str(ruin["scar"])] = true
	for effects in writers:
		for effect in effects:
			var tag: String = str(
				((effect as Dictionary).get("payload", {}) as Dictionary).get("tag", "")
			)
			if tag.begins_with(prefix) and not tag.contains("$"):
				found[tag] = true
	var out: Array = found.keys()
	out.sort()
	return out


## Il prompt della carta, esattamente come lo riceve chi disegna.
func _prompt(lines: Array, face: Dictionary, data: RefCounted, bible: RefCounted) -> void:
	if face.is_empty() or not bible.available():
		return
	var said: String = bible.prompt_for(
		face, bible._subject(face), bible._accent_key(face, data)
	)
	if said == "":
		return
	lines.append("<details><summary>Prompt per l'immagine</summary>")
	lines.append("")
	lines.append("```")
	lines.append(said)
	lines.append("```")
	lines.append("")
	lines.append("</details>")
	lines.append("")


func _discard(rule: String) -> String:
	match rule:
		"ALWAYS_DISCARD": return "si scarta sempre"
		"RETAIN_ON_SUCCESS": return "torna in mano se la proposta passa"
		"ALWAYS_RETAIN": return "torna sempre in mano"
	return rule.to_lower()


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		var pair: PackedStringArray = text.substr(2).split("=", true, 1)
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
