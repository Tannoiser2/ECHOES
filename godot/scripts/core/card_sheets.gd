extends RefCounted
## **La scheda di ogni tipo di carta, e il dato per generarle** (D-445).
##
## Il committente: *«per ogni tipo vorrei la descrizione e quello che bisogna
## scrivere su ogni carta, oltre al prompt generale della grafica scelta e del
## tipo di carta e dell'immagine su di essa: una vera e propria scheda che posso
## usare per generare in automatico le carte con grafica e testo»*.
##
## Tre pezzi esistevano gia' e nessuno era quella scheda: lo scheletro dice i
## blocchi e su quante facce stanno, il catalogo ha una scheda per carta ma solo
## per Asset ed Echi, il brief ha i prompt. Il pezzo che mancava e' uno solo:
## `CardFace.of()` compone per ogni faccia esattamente il record che serve, e
## finiva solo nell'SVG. Qui quel record esce **come dato** — un JSON per mazzo,
## con sopra il prompt composto — e la scheda per tipo si scrive intorno.
##
## Le sole righe scritte a mano sono **cos'e' ogni tipo**, **che immagine
## porta** e **da dove viene ogni campo**: cose che il codice non puo' ricavare.
## Ma la lista delle intestazioni si controlla contro le facce vere, nei due
## versi: un blocco stampato che la scheda non nomina, o nominato che nessuna
## faccia stampa, e la scheda non si scrive. E' la stessa guardia di D-345.

const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")

const SHAPE_NAMES: Dictionary = {
	"CARD": "carta da gioco", "TAROT": "tarocco", "MINI": "mini", "TILE": "tessera",
}

## I campi che ogni carta porta, prima delle righe meccaniche: gli stessi per
## tutti i tipi, e la scheda li elenca una volta sola in testa.
const COMMON_FIELDS: Array = [
	["il titolo", "titolo", "il nome stampato in cima"],
	["il sottotitolo", "sottotitolo", "la riga sotto il titolo: chi e' e di che genere"],
	["la cifra d'angolo", "angolo", "l'unico numero che si legge con la carta a ventaglio; vuoto se il tipo non ne ha"],
	["il colore del bordo", "accento", "un esadecimale: la carta si riconosce dal bordo prima che dal titolo"],
	["il corpo", "corpo", "righe di testo libero, quando il tipo ne ha"],
	["le righe meccaniche", "righe", "ognuna con la sua **voce** in maiuscolo e il testo: sono la carta che si gioca"],
	["l'illustrazione", "arte", "la chiave, la scena scritta dall'autore e **il prompt composto**, pronto; `null` se la carta e' tutta testo"],
	["il pie'", "pie", "l'id, per ritrovarla nei dati"],
	["quante copie", "copie", "quante volte si stampa"],
	["coperta", "segreta", "`true` se sta dietro il paravento e non va lasciata sul tavolo"],
]

## Ogni tipo, scritto a mano: cos'e', che immagine porta, e da dove viene ogni
## riga. `voci` sono le intestazioni che le facce vere devono stampare — tutte
## e sole quelle.
const TYPES: Dictionary = {
	"asset": {
		"nome": "carta Asset",
		"cosa": "La carta che si cala dalla mano: **tu scegli dove e quale delle due Azioni**. Arriva con ACQUISIRE, o dalla mappa a inizio Atto; limite di mano 7. Costa 1 Occasione, o la impegni al Consiglio e vale forza. **Sotto le Azioni porta il suo Eco** (D-359): se le condizioni ci sono si cala quello al posto di un'Azione, e costa la carta.",
		"immagine": "Una **scena** — un luogo, un gesto, persone dentro una cosa che sta succedendo — mai un ritratto singolo centrato. L'accento e' il colore della famiglia.",
		"sottotitolo": "famiglia e rarita' (`family`, `rarity`), in italiano",
		"angolo": "la forza (`strength`)",
		"scena": "`rules_text`, la voce d'autore che la faccia non stampa piu' da D-340",
		"righe": [
			["DOVE", "il bersaglio a segni: `physical.target`"],
			["① e ②", "le due Azioni, nome e effetto: `physical.actions`"],
			["SEMPRE", "la Risonanza, e la parte aggravata: `physical.resonance`"],
			["AL CONSIGLIO", "quanto vale al voto e quando di piu': `physical.council_use`, `strength`"],
			["IMPEGNI", "cosa lascia se la impegni: `on_commit_effects`, `discard_or_retain_rule`"],
			["PRENDI", "come arriva in mano: `acquisition_rule`"],
			["ECO", "l'Eco della carta, la sua versione potenziata: `echo_id`, con titolo, famiglia drammatica e funzione di Propp"],
			["QUANDO ESCE", "le condizioni per calare l'Eco: `eligibility` dell'Eco, generate dai campi"],
			["IL MONDO", "cosa fa l'Eco, in segni: `effect_hooks` (Effetti scritti e Conseguenze chiamate per id)"],
			["CONVOCA IL CONSIGLIO", "la domanda che l'Eco apre, se ne apre una: `forces_confluence_on`"],
		],
		"voci": ["DOVE", "①", "②", "SEMPRE", "AL CONSIGLIO", "IMPEGNI", "PRENDI", "ECO", "QUANDO ESCE", "IL MONDO", "CONVOCA IL CONSIGLIO"],
	},
	"tension": {
		"nome": "carta Domanda (la Tensione), fronte",
		"cosa": "La domanda in gioco: sta accanto alla traccia dei valori tutto l'anno, si gira sul Tema caldo e **dice quando si scalda e su cosa si discute**. Non si gioca e non si tiene in mano. **Sul retro c'e' il suo Consiglio** (D-449): la stessa carta, girata. **La carta non e' mai coperta: coperti sono i gettoni** che ci si posano sopra (D-450) — a fine Atto si girano, si sommano, e la Domanda col mucchio piu' alto si dibatte.",
		"immagine": "Nessuna: e' tutta testo, e il testo prende il posto del quadro.",
		"sottotitolo": "«domanda» e il Tema (`domain`)",
		"angolo": "nessuna: la soglia col cancello del tavolo non decide niente (D-203), e si e' tolta dalla carta (D-450)",
		"scena": "nessuna",
		"righe": [
			["SI DISCUTE DI", "le domande che puo' aprire, nel corpo: `possible_questions`, col testo da `council.questions`"],
			["SI ACCENDE QUANDO", "la regola a segni che la fa salire: `heats_when` (o `triggers`, dove la regola non c'e')"],
			["SI RAFFREDDA", "`decrease_rules`"],
			["SI DIBATTE", "il gesto di fine Atto, fisso: i gettoni coperti si girano e il mucchio piu' alto gira la carta (D-203, D-450)"],
			["AL CONSIGLIO VALGONO", "le famiglie che pesano al voto: `relevant_asset_families`"],
		],
		"voci": ["SI ACCENDE QUANDO", "SI RAFFREDDA", "SI DIBATTE", "AL CONSIGLIO VALGONO"],
	},
	"council": {
		"nome": "carta Domanda, retro (il Consiglio)",
		"cosa": "**Il retro della carta Domanda**: si gira quando il Consiglio si apre, e porta le sue domande e le caselle con cui il tavolo la risolve — in media nove SI OTTIENE, nove SI PAGA e due SE CADE (D-280, D-449). Una per Tensione, nello stesso ordine del fronte.",
		"immagine": "Nessuna: e' un elenco da cui si sceglie.",
		"sottotitolo": "fissa: «il Consiglio che questa domanda apre»",
		"angolo": "nessuna",
		"scena": "nessuna",
		"righe": [
			["le domande", "nel corpo, una per riga, con «— solo se» quando serve una condizione: `council.questions`"],
			["SI OTTIENE", "le caselle beneficio, una per riga con «·»: `physical.benefits`"],
			["SI PAGA", "le caselle costo: `physical.costs`"],
			["SE CADE", "cosa succede se la proposta cade: `physical.failure`"],
		],
		"voci": ["SI OTTIENE", "·", "SI PAGA", "SE CADE"],
	},
	"destiny": {
		"nome": "carta Destino",
		"cosa": "L'ambizione di una casa, **dietro il paravento**: la scala per contare quanto manca. Non si gioca, si guarda.",
		"immagine": "**Niente volti**: la cosa desiderata, non chi la desidera — un oggetto, un luogo, una soglia, composti come un'immagine votiva. L'accento e' quello dell'archetipo della casa.",
		"sottotitolo": "la casa (`entity_id`), o «per chi lo giura» se e' condivisibile",
		"angolo": "nessuna",
		"scena": "`description`",
		"righe": [
			["SOGLIA", "il primo gradino: `minimum.label` e le sue clausole (`conditions[].label`)"],
			["VITTORIA", "`victory`"],
			["TRIONFO", "`triumph`"],
		],
		"voci": ["SOGLIA", "VITTORIA", "TRIONFO"],
	},
	"objective": {
		"nome": "carta Obiettivo",
		"cosa": "La promessa coperta che **qualunque casa puo' pescare**, dietro il paravento come il Destino. Non si gioca: si conta a fine anno, clausola per clausola.",
		"immagine": "**Niente volti** e **nessun colore di casa**: la prova da portare — una cosa costruita, tenuta, contata — come un ex voto.",
		"sottotitolo": "fissa: «obiettivo coperto · si conta a fine anno»",
		"angolo": "nessuna",
		"scena": "`description`",
		"righe": [
			["la promessa", "nel corpo, in una riga: `label`"],
			["CONTA", "le clausole che la contano: `conditions[].label`"],
		],
		"voci": ["CONTA"],
	},
	"entity": {
		"nome": "carta Casata",
		"cosa": "La casa, in vista tutta la partita: **cosa sa fare e cosa vuole lasciare**. Una carta per vita (D-111): la stessa casa cambia nome e volto quando si trasforma.",
		"immagine": "Un **ritratto**: una figura sola, ravvicinata, che guarda chi la guarda. Il taglio lo decide l'archetipo.",
		"sottotitolo": "l'archetipo e il bisogno (`archetype`, `need`), in italiano",
		"angolo": "nessuna",
		"scena": "`description` della vita che siede",
		"righe": [
			["SA FARE", "i valori dei verbi: `action_values`"],
			["VUOI LASCIARE", "i segni del profilo strategico: `entity_profiles[].wants`"],
			["SE NON CE LA FAI", "la vita dopo e la sua porta: `incarnations[].also_enters`"],
		],
		"voci": ["SA FARE", "VUOI LASCIARE", "SE NON CE LA FAI"],
	},
	"region": {
		"nome": "tessera Regione",
		"cosa": "La tessera di mappa: **porta i segni** che ogni carta Azione bersaglia, e i varchi con cui si posa accanto alle altre.",
		"immagine": "Il **terreno**, che prende tutta la tessera: il quadro e' il bioma, e il testo ci sta sopra in basso. I varchi si vedono sui lati.",
		"sottotitolo": "il bioma e i posti (`biome`, `presence_slots`, `build_slots`)",
		"angolo": "nessuna",
		"scena": "`description`",
		"righe": [
			["VARCHI", "i lati aperti: `edges`"],
			["SEGNI", "il dominio e i #segni stampati: `tags`"],
			["CI STANNO", "le Pietre che il bioma accetta: `structure_types[].biomes`"],
			["FONTI", "le famiglie che la tessera da': `asset_sources`"],
		],
		"voci": ["VARCHI", "SEGNI", "CI STANNO", "FONTI"],
	},
}

static var _letters: RegEx = null


## L'intestazione di una riga meccanica, come la stampa la faccia: «DOVE»,
## «SI ACCENDE QUANDO», «①», «·». Vuota per una riga senza voce.
static func headword(line: String) -> String:
	if line.begins_with("①"):
		return "①"
	if line.begins_with("②"):
		return "②"
	if line.begins_with("· "):
		return "·"
	if _letters == null:
		_letters = RegEx.new()
		_letters.compile("^[A-ZÀ-Ü']+$")
	var head: Array = []
	# La voce sta prima del doppio spazio; una riga senza doppio spazio e' una
	# voce da sola (SI OTTIENE) o una riga senza voce.
	var words: PackedStringArray = line.split("  ")[0].split(" ")
	for word in words:
		if word == "" or word.length() < 2 or _letters.search(word) == null:
			return ""
		head.append(word)
	return " ".join(PackedStringArray(head))


## Una riga meccanica spezzata in voce e testo.
static func _row(line: String) -> Dictionary:
	var voce: String = headword(line)
	var testo: String = line
	if voce == "①" or voce == "②":
		testo = line.substr(1).strip_edges()
	elif voce == "·":
		testo = line.substr(2).strip_edges()
	elif voce != "":
		testo = line.substr(voce.length()).strip_edges()
	return {"voce": voce, "testo": testo}


## **La scheda di una carta**: il record di `CardFace.of()` detto in italiano,
## col prompt composto sopra.
static func card_of(face: Dictionary, data: RefCounted, bible: RefCounted) -> Dictionary:
	var corpo: Array = []
	for paragraph in face["body"] as Array:
		if str(paragraph).strip_edges() != "":
			corpo.append(str(paragraph))
	var righe: Array = []
	for note in face["notes"] as Array:
		if str(note).strip_edges() != "":
			righe.append(_row(str(note)))
	var arte: Variant = null
	var key: String = str(face["art_prompt_key"])
	if key != "":
		arte = {
			"chiave": key,
			"scena": bible.scene_of(face, data) if bible != null else "",
			"prompt": bible.prompt_of(face, data) if bible != null else "",
		}
	return {
		"id": str(face["id"]),
		"tipo": str(face["deck"]),
		"titolo": str(face["title"]),
		"sottotitolo": str(face["subtitle"]),
		"angolo": str(face["corner"]),
		"accento": str(face["accent"]),
		"famiglia": str(face.get("family", "")),
		"corpo": corpo,
		"righe": righe,
		"arte": arte,
		"pie": str(face["footer"]),
		"copie": int(face.get("copies", 1)),
		"segreta": bool(face.get("secret", false)),
	}


## **Il dato di un mazzo intero**: la scheda del tipo in testa, e sotto una
## scheda per carta. E' il file che si da' a chi genera le carte.
static func deck_of(deck: String, data: RefCounted, bible: RefCounted) -> Dictionary:
	var faces: Array = CardFace.deck_of(deck, data)
	var about: Dictionary = TYPES.get(deck, {})
	var shape: String = str((faces[0] as Dictionary)["shape"]) if not faces.is_empty() else "CARD"
	var cell: Vector2 = PrintSheet.cell_size(shape)
	var campi: Array = []
	for field in COMMON_FIELDS:
		campi.append({"posto": str(field[0]), "campo": str(field[1]), "da_dove": str(field[2])})
	var righe: Array = []
	for pair in about.get("righe", []) as Array:
		righe.append({"voce": str(pair[0]), "da_dove": str(pair[1])})
	var carte: Array = []
	var copie: int = 0
	for face in faces:
		carte.append(card_of(face as Dictionary, data, bible))
		copie += int((face as Dictionary).get("copies", 1))
	return {
		"tipo": deck,
		"nome": str(about.get("nome", CardFace.DECK_LABELS.get(deck, deck))),
		"formato": {"nome": str(SHAPE_NAMES.get(shape, shape)), "sigla": shape, "mm": [int(cell.x), int(cell.y)]},
		"facce": faces.size(),
		"pezzi": copie,
		"cos_e": str(about.get("cosa", "")),
		"immagine": str(about.get("immagine", "")),
		"sottotitolo": str(about.get("sottotitolo", "")),
		"angolo": str(about.get("angolo", "")),
		"scena": str(about.get("scena", "")),
		"retro": str(CardFace.BACKS.get(deck, "")),
		"fronte": _front_of(deck),
		"stile": bible.style() if bible != null else "",
		"prompt_generale": bible.template_of(deck) if bible != null else "",
		"campi": campi,
		"righe": righe,
		"carte": carte,
	}


## Di quale mazzo questo e' il retro, se lo e'.
static func _front_of(deck: String) -> String:
	for front in CardFace.BACKS:
		if str(CardFace.BACKS[front]) == deck:
			return str(front)
	return ""


## Il JSON di un mazzo, con le chiavi nell'ordine in cui si leggono e non in
## ordine alfabetico: e' un documento, non un dizionario.
static func deck_json(deck: String, data: RefCounted, bible: RefCounted) -> String:
	return JSON.stringify(deck_of(deck, data, bible), "  ", false) + "\n"


## **La guardia**: le voci scritte a mano contro quelle che le facce stampano,
## nei due versi. `types` si puo' passare per provare che morda.
static func complaints(data: RefCounted, types: Dictionary = TYPES) -> Array:
	var out: Array = []
	for deck in CardFace.printed():
		var about: Variant = types.get(str(deck))
		if about == null:
			out.append("il mazzo «%s» non ha una scheda scritta" % str(deck))
			continue
		var promised: Dictionary = {}
		for voce in (about as Dictionary).get("voci", []) as Array:
			promised[str(voce)] = true
		var printed: Dictionary = {}
		for face in CardFace.deck_of(str(deck), data):
			for note in (face as Dictionary)["notes"] as Array:
				var voce: String = headword(str(note))
				if voce != "":
					printed[voce] = true
		for voce in printed:
			if not promised.has(voce):
				out.append("il mazzo «%s» stampa «%s» e la scheda non lo dice" % [str(deck), str(voce)])
		for voce in promised:
			if not printed.has(voce):
				out.append("la scheda del mazzo «%s» promette «%s» e nessuna faccia lo stampa" % [str(deck), str(voce)])
	return out


## Il documento: una scheda per tipo, nell'ordine dei mazzi.
static func document(data: RefCounted, bible: RefCounted, json_dir: String) -> String:
	var lines: Array = []
	lines.append("# ECHOES — la scheda di ogni tipo di carta")
	lines.append("")
	lines.append("<!-- GENERATO da `tools/run_card_sheets.sh` — non si corregge qui. -->")
	lines.append("")
	lines.append("Per ogni tipo di carta: **cos'e'**, **che immagine porta** e il suo prompt")
	lines.append("generale, e **cosa c'e' scritto sopra**, campo per campo, con da dove viene nei")
	lines.append("dati. Accanto a ogni scheda sta **il dato di tutte le carte di quel tipo** —")
	lines.append("`%s/<tipo>.json` — con lo stesso record di ogni carta: titolo, sottotitolo," % json_dir)
	lines.append("cifra, righe meccaniche voce per voce, e il prompt dell'immagine gia' composto.")
	lines.append("E' quello che serve per generare le carte, grafica e testo, senza aprire")
	lines.append("Godot ([D-445](DECISIONS.md#d-445)).")
	lines.append("")
	lines.append("Niente qui e' ricopiato: le carte vengono da `CardFace`, lo stesso che le")
	lines.append("stampa sul foglio e le mostra sullo schermo; i prompt da `ArtBible`, lo")
	lines.append("stesso che compone il brief. Le sole righe scritte a mano — cos'e' un tipo,")
	lines.append("che immagine porta, da dove viene ogni voce — sono controllate contro le")
	lines.append("facce vere: una voce stampata che la scheda tace, o promessa che nessuna")
	lines.append("faccia stampa, e questo documento non si scrive.")
	lines.append("")
	lines.append("Una carta puo' avere **due facce**: la Domanda porta il suo Consiglio sul")
	lines.append("retro (D-449), e l'Asset porta il suo Eco sotto le Azioni (D-359). Il JSON")
	lines.append("di un retro dice di che fronte e' (`fronte`), e viceversa (`retro`).")
	lines.append("")
	lines.append("| tipo | formato | facce | pezzi | immagine | il dato |")
	lines.append("|---|---|---|---|---|---|")
	var decks: Array = []
	for deck in CardFace.printed():
		var sheet: Dictionary = deck_of(str(deck), data, bible)
		decks.append(sheet)
		var formato: Dictionary = sheet["formato"]
		lines.append("| **%s** | %s %d×%d mm | %d | %d | %s | `%s/%s.json` |" % [
			str(sheet["nome"]), str(formato["nome"]), int(formato["mm"][0]), int(formato["mm"][1]),
			int(sheet["facce"]), int(sheet["pezzi"]),
			"si'" if str(sheet["prompt_generale"]) != "" else "no",
			json_dir, str(deck),
		])
	lines.append("")
	lines.append("## Il record di una carta, uguale per tutti i tipi")
	lines.append("")
	lines.append("| campo del JSON | cos'e' |")
	lines.append("|---|---|")
	for field in COMMON_FIELDS:
		lines.append("| `%s` | %s — %s |" % [str(field[1]), str(field[0]), str(field[2])])
	lines.append("")
	lines.append("## Lo stile — una volta, per tutto")
	lines.append("")
	lines.append("Si incolla prima del prompt di ogni carta, ed e' lo stesso per tutto il")
	lines.append("gioco ([ART_BIBLE](ART_BIBLE.md)). Nei JSON sta nel campo `stile`.")
	lines.append("")
	lines.append("```")
	lines.append(bible.style() if bible != null else "")
	lines.append("```")
	lines.append("")
	var number: int = 0
	for sheet_v in decks:
		var sheet: Dictionary = sheet_v
		number += 1
		var formato: Dictionary = sheet["formato"]
		lines.append("## %d. %s — %s %d×%d mm · %d facce · %d pezzi" % [
			number, str(sheet["nome"]), str(formato["nome"]),
			int(formato["mm"][0]), int(formato["mm"][1]), int(sheet["facce"]), int(sheet["pezzi"]),
		])
		lines.append("")
		lines.append("**Cos'e'.** %s" % str(sheet["cos_e"]))
		lines.append("")
		lines.append("**L'immagine.** %s" % str(sheet["immagine"]))
		if str(sheet["prompt_generale"]) != "":
			lines.append("")
			lines.append("Il prompt generale del tipo, coi segnaposto che ogni carta riempie —")
			lines.append("`{SOGGETTO}` e' il titolo, `{SITUAZIONE}` la scena scritta dall'autore")
			lines.append("(%s), `{ACCENTO}` e `{DESCRIZIONE}` la riga di variazione:" % str(sheet["scena"]))
			lines.append("")
			lines.append("```")
			lines.append(str(sheet["prompt_generale"]))
			lines.append("```")
			lines.append("")
			lines.append("Nel JSON ogni carta porta gia' il prompt **composto**, in `arte.prompt`.")
		lines.append("")
		lines.append("**Cosa c'e' scritto sopra**, in ordine di lettura:")
		lines.append("")
		lines.append("| posto | da dove viene |")
		lines.append("|---|---|")
		lines.append("| il titolo | `title` o `name` |")
		lines.append("| il sottotitolo | %s |" % str(sheet["sottotitolo"]))
		if str(sheet["angolo"]) != "nessuna":
			lines.append("| la cifra d'angolo | %s |" % str(sheet["angolo"]))
		for row in sheet["righe"] as Array:
			var voce: String = str((row as Dictionary)["voce"])
			var shown: String = "**%s**" % voce if voce == voce.to_upper() else voce
			lines.append("| %s | %s |" % [shown, str((row as Dictionary)["da_dove"])])
		lines.append("")
		var carte: Array = sheet["carte"]
		if carte.is_empty():
			continue
		lines.append("**Una carta, per intero, com'e' nel JSON:**")
		lines.append("")
		lines.append("```json")
		lines.append(JSON.stringify(carte[0], "  ", false))
		lines.append("```")
		lines.append("")
	return "\n".join(PackedStringArray(lines)).strip_edges() + "\n"
