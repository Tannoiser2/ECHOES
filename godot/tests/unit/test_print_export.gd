extends "res://tests/test_case.gd"
## L'export di stampa: cosa c'e' su una carta, e se ci sta (D-056).
##
## Un foglio sbagliato non si vede in una partita e non si vede in un test che
## guarda i numeri: si vede stampando venticinque pagine, cioe' tardi. Questi
## test sono la lettura a occhio fatta dalla macchina - e non e' un'ipotesi: il
## primo giro dell'export mandava il testo dei Destini oltre il bordo inferiore
## e il titolo di `DST_LYRA` oltre quello destro, e li ho visti perche' avevo
## renderizzato un PNG e l'ho guardato. Adesso li vede questo file.

const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")
const ArtPlaceholder := preload("res://scripts/core/art_placeholder.gd")
const ArtBible := preload("res://scripts/core/art_bible.gd")
const AssetText := preload("res://scripts/core/asset_text.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")


## Il test che vale per tutti: ogni faccia del set ci sta nella sua carta.
func test_every_face_fits_on_its_card() -> void:
	var faces: Array = CardFace.every(data())
	assert_true(faces.size() > 100, "il set ha piu di cento facce: %d" % faces.size())
	for face in faces:
		var item: Dictionary = face
		var cell: Vector2 = PrintSheet.cell_size(str(item["shape"]))
		var drawn: Dictionary = PrintSheet.layout(item, cell)
		assert_false(
			bool(drawn["overflow"]),
			"%s: il testo esce dal bordo" % str(item["id"])
		)
		# E ci sta *leggibile*: sotto il 74% il corpo si stringe fino a non
		# leggersi piu a 63 mm, e a quel punto la carta va riscritta, non ridotta.
		assert_true(
			float(drawn["scale"]) >= 0.74,
			"%s: il corpo e sceso al %d%%" % [str(item["id"]), int(float(drawn["scale"]) * 100.0)]
		)


## Niente titolo vuoto, niente id al posto di un nome, niente carta senza corpo:
## una faccia vuota si stampa lo stesso e si scopre sul tavolo.
func test_no_face_is_blank() -> void:
	for face in CardFace.every(data()):
		var item: Dictionary = face
		assert_true(str(item["title"]) != "", "%s ha un titolo" % str(item["id"]))
		assert_true(str(item["footer"]) != "", "%s ha il proprio id stampato" % str(item["id"]))
		var said: int = 0
		for paragraph in item["body"] + item["notes"]:
			if str(paragraph).strip_edges() != "":
				said += 1
		assert_true(said > 0, "%s dice qualcosa" % str(item["id"]))


## Il Destino sta dietro il paravento (COMPONENTS §5), e la carta della Casata
## non deve dirlo. E' l'unico segreto che regge il gioco, e una carta pubblica
## che stampa l'obiettivo del suo giocatore lo brucia in silenzio.
func test_the_house_card_never_prints_its_destiny() -> void:
	var houses: Array = CardFace.deck_of("entity", data())
	assert_true(houses.size() >= 4, "ci sono le Casate")
	for face in houses:
		var item: Dictionary = face
		assert_false(bool(item["secret"]), "%s si tiene scoperta" % str(item["id"]))
		var printed: String = " ".join(PackedStringArray(item["body"] + item["notes"]))
		# **Il mazzo Casata porta anche le incarnazioni** (D-111), e il loro id non
		# e' una chiave di `entities`. Cercarlo li' interrompeva la prova alla
		# prima incarnazione: da INC_ALDRIC_02 in poi nessuna carta veniva piu'
		# guardata, e nemmeno il mazzo Destino qui sotto. La prova diceva ok
		# avendo controllato una casa e mezza — e il segreto che regge il gioco
		# era coperto da un controllo che non girava.
		var destiny_id: String = str(
			data().entities[_house_of(str(item["id"]))]["destiny_id"]
		)
		var destiny: Dictionary = data().destinies[destiny_id]
		assert_false(
			printed.contains(str(destiny["title"])),
			"%s non stampa il proprio Destino" % str(item["id"])
		)
	for face in CardFace.deck_of("destiny", data()):
		assert_true(
			bool((face as Dictionary)["secret"]),
			"%s si consegna coperta" % str((face as Dictionary)["id"])
		)


## Le copie sono quelle del mazzo: 48 facce Asset fanno 132 carte (D-040).
func test_the_deck_is_expanded_by_its_copies() -> void:
	var faces: Array = CardFace.deck_of("asset", data())
	var expanded: Array = PrintSheet.expand(faces)
	assert_eq(faces.size(), 48, "quarantotto facce")
	assert_eq(expanded.size(), 132, "centotrentadue carte")
	var pages: Array = PrintSheet.paginate(expanded, "CARD")
	assert_eq(pages.size(), 15, "quindici fogli da nove")
	assert_eq((pages[0] as Array).size(), 9, "il primo foglio e pieno")


## Il segnaposto: stessa chiave, stessa immagine, su ogni macchina e a ogni
## export. Se cambiasse, cambierebbero venticinque file a ogni rigenerazione.
func test_the_placeholder_is_the_same_every_time() -> void:
	var once: Dictionary = ArtPlaceholder.plan("asset.force.levy", "#c8553d")
	var twice: Dictionary = ArtPlaceholder.plan("asset.force.levy", "#c8553d")
	assert_eq(once, twice, "la stessa chiave da la stessa immagine")
	assert_eq(
		ArtPlaceholder.fingerprint("asset.force.levy"), 4018957862,
		"e l'impronta e quella scritta qui: se cambia, cambia tutto l'export"
	)


## E chiavi diverse danno immagini diverse: cinquanta carte identiche sono
## cinquanta carte che al playtest non si distinguono.
func test_different_keys_look_different() -> void:
	var seen: Dictionary = {}
	var keys: Array = []
	for face in CardFace.every(data()):
		var key: String = str((face as Dictionary)["art_prompt_key"])
		if key != "" and not keys.has(key):
			keys.append(key)
	assert_true(keys.size() >= 90, "il set ha almeno novanta chiavi d'arte: %d" % keys.size())
	for key in keys:
		var plan: Dictionary = ArtPlaceholder.plan(str(key), "#c8553d")
		var shape: String = "%d/%.3f" % [(plan["shapes"] as Array).size(), float(plan["horizon"])]
		for item in plan["shapes"]:
			shape += "|%s%.2f%.2f" % [
				str((item as Dictionary)["kind"]), float((item as Dictionary)["x"]),
				float((item as Dictionary)["h"]),
			]
		seen[shape] = true
	# Non pretende l'unicita assoluta - due chiavi possono cadere sulla stessa
	# composizione - ma pretende che siano quasi tutte diverse.
	assert_true(
		float(seen.size()) / float(keys.size()) > 0.95,
		"%d composizioni diverse su %d chiavi" % [seen.size(), keys.size()]
	)


## L'SVG dev'essere XML: un `&` non protetto in un titolo produce un file che
## nessun visualizzatore apre, e il testo delle carte viene dai dati.
func test_the_sheet_escapes_what_the_data_writes() -> void:
	assert_eq(
		ArtPlaceholder.escape('grano & pane <"vero">'),
		"grano &amp; pane &lt;&quot;vero&quot;&gt;",
		"i caratteri che rompono l'XML sono protetti"
	)
	var page: String = PrintSheet.page_svg(
		CardFace.deck_of("asset", data()).slice(0, 9), "CARD", "prova", 1, 1
	)
	assert_true(page.begins_with("<svg"), "e' un SVG")
	assert_true(page.ends_with("</svg>\n"), "chiuso")
	assert_true(page.contains('width="210mm"'), "in A4 e in millimetri, cioe in scala 1:1")


## Il brief non ricopia i MASTER PROMPT: li legge dalla ART_BIBLE e ci mette
## dentro il soggetto che solo i dati conoscono.
func test_the_brief_reads_the_art_bible() -> void:
	var bible: RefCounted = ArtBible.new()
	# Il documento sta fuori dal progetto Godot: se un giorno si sposta, questo
	# test lo dice prima che se ne accorga l'export.
	assert_true(bible.read("res://../docs/ART_BIBLE.md"), "la ART_BIBLE si legge")
	var face: Dictionary = CardFace.of("asset", "AST_FORCE_LEVY", data())
	var prompt: String = bible.prompt_for(face, "Leva Contadina", "Uomini con attrezzi da lavoro tenuti come lance", "FORCE")
	assert_true(prompt.contains("Leva Contadina"), "il soggetto e dentro il prompt")
	assert_true(prompt.contains("rosso ossido"), "e l'accento e quello della sua famiglia")
	assert_false(prompt.contains("{"), "non resta nessun segnaposto da sostituire")


## Le chiavi in uso che nessun MASTER PROMPT copre. Erano le otto Casate, e con
## il MASTER PROMPT 4 (D-065) non ce ne sono piu'. Il test resta, e adesso e' la
## guardia: chi aggiunge un mazzo senza scriverne il prompt lo scopre qui invece
## che da chi disegna.
func test_every_key_in_use_has_a_master_prompt() -> void:
	var bible: RefCounted = ArtBible.new()
	assert_eq(bible.keys_without_prompt(data()), [], "nessuna chiave in uso resta senza prompt")


## **Il prompt di una carta dice la scena, non il nome**
## ([D-347](../../docs/DECISIONS.md#d-347)).
##
## D-340 tolse il racconto dalla faccia stampata e scrisse, nel commento che lo
## faceva, che il racconto *«resta nel dato: lo legge il brief d'arte, che e' il
## posto dove serve»*. Il brief non lo leggeva: leggeva la **faccia**, che quel
## giorno era rimasta senza. **48 carte Asset e 39 Echo** sono uscite col prompt
## fatto del loro titolo dentro un paragrafo di stile, e il cancello del brief e'
## restato verde perche' confronta il documento con quello che il codice produce
## — e il codice produceva lo stesso niente dalle due parti.
##
## Un cancello che confronta due copie della stessa cosa non si accorge mai che
## la cosa e' vuota. Questa prova guarda **i dati**: ogni chiave d'arte in uso
## deve avere, nel dato della sua carta, la riga d'autore che dice cosa succede.
func test_every_card_sends_its_scene_and_not_its_name() -> void:
	var bible: RefCounted = ArtBible.new()
	assert_eq(
		bible.keys_without_situation(data()), [],
		"nessuna chiave in uso resta col solo titolo da dipingere"
	)


## E la scena arriva davvero dentro il prompt composto, che e' l'altra meta': un
## dato pieno e un segnaposto mai sostituito darebbero la stessa carta muta.
func test_the_scene_reaches_the_composed_prompt() -> void:
	var bible: RefCounted = ArtBible.new()
	if not bible.read("res://../docs/ART_BIBLE.md"):
		return  # senza il documento non c'e' niente da verificare, e il brief lo dice
	var loaded: RefCounted = data()
	var levy: Dictionary = CardFace.of("asset", "AST_FORCE_LEVY", loaded)
	var scene: String = bible._situation(levy, loaded).strip_edges()
	assert_ne(scene, "", "la Leva Contadina ha la sua scena nel dato")
	var prompt: String = bible.prompt_for(levy, str(levy["title"]), scene, "FORCE")
	assert_true(prompt.contains(scene), "e la scena e' dentro il prompt che si manda")
	assert_true(prompt.contains(str(levy["title"])), "insieme al nome della carta")
	assert_false(prompt.contains("{"), "e non resta nessun segnaposto")


## Lo stile sta scritto una volta. Se torna dentro i sei MASTER PROMPT, il brief
## torna a essere 146 copie di un paragrafo: e' com'era, e non si vedeva.
func test_the_style_is_written_once_and_not_in_every_prompt() -> void:
	var bible: RefCounted = ArtBible.new()
	if not bible.read("res://../docs/ART_BIBLE.md"):
		return
	assert_ne(bible.style(), "", "la ART_BIBLE ha il suo blocco di stile")
	var loaded: RefCounted = data()
	var levy: Dictionary = CardFace.of("asset", "AST_FORCE_LEVY", loaded)
	var prompt: String = bible.prompt_for(levy, "Leva Contadina", "una scena", "FORCE")
	assert_false(
		prompt.contains("Painterly concept-art"),
		"e il prompt della carta non se lo ricopia dentro"
	)


## E il ritratto di Casata prende l'accento del proprio archetipo, non quello di
## una famiglia di Asset che si chiama allo stesso modo: `PEOPLE` e' tutt'e due
## le cose, ed e' l'unico posto del documento in cui due tabelle usano la stessa
## parola.
func test_a_house_portrait_is_varied_by_its_archetype() -> void:
	var bible: RefCounted = ArtBible.new()
	if not bible.read("res://../docs/ART_BIBLE.md"):
		return  # senza il documento non c'e' niente da verificare, e il brief lo dice
	var people: Dictionary = CardFace.of("entity", "ENT_NAHR", data())
	var portrait: String = bible.prompt_for(people, str(people["title"]), "chi risponde per la casa", "PEOPLE")
	assert_true(portrait.to_lower().contains("portrait"), "e il prompt del ritratto")
	assert_true(portrait.contains("terracotta"), "con l'accento del proprio archetipo")
	assert_true(portrait.contains("il volto di uno"), "e la guida che dice come si ritrae un popolo")
	assert_false(portrait.contains("{"), "non resta nessun segnaposto da sostituire")

	# E le tabelle non si mescolano nell'altro verso: un archetipo non e' un
	# accento valido per una carta Asset, e chiederlo deve ricadere sul generico
	# invece di pescare dalla tabella dei ritratti.
	var levy: Dictionary = CardFace.of("asset", "AST_FORCE_LEVY", data())
	var scene: String = bible.prompt_for(levy, str(levy["title"]), "uomini con attrezzi tenuti come lance", "SOVEREIGN")
	assert_true(scene.contains("l'accento della sua famiglia"), "l'Asset non vede la tabella 4")
	assert_false(scene.contains("oro spento"), "e non si prende l'accento di un archetipo")


## D-097 (voce 7): ogni mazzo ha la taglia del suo ruolo al tavolo. I mazzi
## che si mescolano restano classici, le carte-identita' diventano tarocchi,
## le domande diventano mini da appoggiare alla traccia dei valori.
func test_each_deck_has_the_size_of_its_table_role() -> void:
	var loaded: RefCounted = data()
	# **E le Asset sono tarocchi da D-421**, con l'Eco che le segue perche' e' un
	# blocco stampato sulla stessa carta (D-359). Su 63x88 quarantasei facce su
	# quarantotto stampavano il corpo rimpicciolito, la piu' stretta al 74%, e
	# l'illustrazione stava al suo pavimento del 34%: una carta che porta sette
	# righe di regole **e** un disegno non ci sta, e stringere e' la scelta che
	# rende la carta illeggibile invece di ammettere che serve piu' spazio.
	assert_eq(str(CardFace.deck_of("asset", loaded)[0]["shape"]), "TAROT",
		"le Asset portano regole e disegno: tarocco")
	assert_eq(str(CardFace.deck_of("echo", loaded)[0]["shape"]), "TAROT",
		"e l'Eco sta sulla stessa carta, quindi la segue")
	assert_eq(str(CardFace.deck_of("tension", loaded)[0]["shape"]), "MINI", "le domande sono mini, per la traccia")
	# **E la scheda del Consiglio e' un tarocco** (D-338). Due pezzi con due
	# mestieri: la mini sta sulla traccia e dice quando la domanda si scalda; il
	# tarocco dice cosa si puo' proporre e cosa costa, e si tira fuori quando il
	# Consiglio si apre. Su una mini quelle 870 righe non entravano, e su una
	# carta sola nemmeno: TEN_SUCCESSION sbordava.
	assert_eq(str(CardFace.deck_of("council", loaded)[0]["shape"]), "TAROT",
		"le schede del Consiglio sono tarocchi: si leggono, non si appoggiano")
	assert_eq(CardFace.deck_of("council", loaded).size(),
		CardFace.deck_of("tension", loaded).size(),
		"una scheda per ogni domanda")
	assert_eq(str(CardFace.deck_of("destiny", loaded)[0]["shape"]), "TAROT", "i Destini sono tarocchi, sempre in vista")
	assert_eq(str(CardFace.deck_of("entity", loaded)[0]["shape"]), "TAROT", "le Casate pure")
	assert_eq(str(CardFace.deck_of("region", loaded)[0]["shape"]), "TILE", "le Regioni restano tessere: la mappa e' fatta")
	assert_eq(PrintSheet.cell_size("TAROT"), Vector2(70.0, 120.0), "il tarocco e' 70x120")
	assert_eq(PrintSheet.cell_size("MINI"), Vector2(44.0, 68.0), "la mini e' 44x68")
	assert_eq(PrintSheet.per_page("TAROT"), 4, "quattro tarocchi per foglio")
	assert_eq(PrintSheet.per_page("MINI"), 16, "sedici mini per foglio")


## E i segnalini si contano: sei presenze e sei controlli per casa (sei
## Regioni: il pezzo in piu' non esiste), i rombi dei valori, il quadrato del
## Drift - e due export identici byte per byte, come tutto il resto.
func test_the_token_sheet_counts_its_pieces() -> void:
	var TokenSheet: GDScript = load("res://scripts/core/token_sheet.gd")
	var svg: String = TokenSheet.tokens_svg(data(), "CHR_TEST")
	# Si contano i **contorni da punzonare** (`class="pezzo"`), non le forme
	# grezze: da quando dentro il tondo c'e' la sagoma della pedina (D-137) un
	# pezzo e' fatto di piu' disegni, e contare i cerchi conterebbe le teste.
	assert_eq(
		svg.count("class=\"pezzo\""), 55,
		"4 case x (6 tondi + 6 anelli) + 6 rombi + il quadrato del Drift"
	)
	assert_eq(svg.count("<circle class=\"pezzo\""), 48, "48 segnalini di casa da fustellare")
	assert_eq(svg.count("<path class=\"pezzo\""), 6, "sei rombi di valore")
	assert_true(svg.contains("<circle cx="), "e dentro i tondi la sagoma della pedina")
	assert_true(svg.contains("Re Aldric"), "le case sono quelle della Chronicle")
	assert_true(svg.contains("width=\"210mm\" height=\"297mm\""), "il foglio e' un A4 vero")
	assert_eq(svg, TokenSheet.tokens_svg(data(), "CHR_TEST"), "deterministico byte per byte")

	var track: String = TokenSheet.track_board_svg()
	assert_eq(track.count("<rect"), 1 + 4 * 10, "il fondo, e per corsia un posto-carta e nove caselle")
	assert_true(track.contains("si apre il Consiglio"), "la regola della soglia e' scritta sul foglio")


## D-101: la GUI mostra le carte fisiche. Una carta si rende da sola - stessa
## faccia del foglio di stampa, taglia propria, niente segni di taglio - e si
## rasterizza, perche' e' cosi' che la mano e la carta Echo finiscono sullo
## schermo.
func test_a_single_card_renders_standalone_for_the_screen() -> void:
	var loaded: RefCounted = data()
	for deck in CardFace.DECKS + CardFace.TILES:
		var face: Dictionary = CardFace.deck_of(str(deck), loaded)[0]
		var svg: String = PrintSheet.card_svg(face)
		var cell: Vector2 = PrintSheet.cell_size(str(face["shape"]))
		assert_true(
			svg.contains('width="%.0fmm" height="%.0fmm"' % [cell.x, cell.y]),
			"%s: la carta esce della sua taglia" % str(deck)
		)
		assert_false(svg.contains("#bbbbbb"), "%s: niente segni di taglio sullo schermo" % str(deck))
		assert_eq(svg, PrintSheet.card_svg(face), "%s: due rese identiche byte per byte" % str(deck))
		var image := Image.new()
		assert_eq(image.load_svg_from_string(svg, 3.0), OK, "%s: la carta si rasterizza" % str(deck))
		assert_true(image.get_width() > 0, "%s: e ha dei pixel" % str(deck))


## L'Entita' a cui appartiene una faccia del mazzo Casata: la carta base porta
## gia' l'id dell'Entita', una vita successiva porta il proprio.
func _house_of(face_id: String) -> String:
	if data().entities.has(face_id):
		return face_id
	for entity_id in data().entities:
		for incarnation in (data().entities[str(entity_id)] as Dictionary).get("incarnations", []):
			if str((incarnation as Dictionary)["id"]) == face_id:
				return str(entity_id)
	_fail("la faccia %s non appartiene a nessuna Casata" % face_id)
	return ""


## **La carta stampa la regola, non la prosa** (D-337).
##
## Fino alla 0.1.301 la faccia della Tensione portava `triggers` — prosa
## d'autore: *«Ogni raccolto mancato nella Valle Verde»* — e un giocatore la
## leggeva senza sapere quando la Tensione sale. La regola vera esiste da D-330,
## e' in segni, il motore la esegue, e non era stampata da nessuna parte: la
## carta diceva la frase che non si puo' giocare e nascondeva quella che si
## gioca.
##
## Le 13 Tensioni senza casella tengono la prosa, perche' per loro vale ancora
## il ponte e non c'e' altro da stampare — e la prova conta anche quelle, cosi'
## se un giorno diventano zero questa riga non passa per un banco vuoto.
func test_the_tension_card_prints_the_rule_not_the_prose() -> void:
	var loaded: RefCounted = data()
	var col_regola: int = 0
	var col_prosa: int = 0
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		if str(card.get("deck", "")) != "tension":
			continue
		var tension: Dictionary = loaded.tensions[str(card["id"])]
		var notes: String = " ".join(PackedStringArray(card.get("notes", []) as Array))
		if (tension.get("heats_when", []) as Array).is_empty():
			col_prosa += 1
			continue
		col_regola += 1
		assert_true(notes.contains("SI ACCENDE QUANDO"),
			"%s ha la casella e la carta non la stampa" % str(card["id"]))
		for rule in tension["heats_when"] as Array:
			var line: String = str((rule as Dictionary).get("text", ""))
			assert_true(notes.contains(line),
				"%s: la riga «%s» non arriva sulla carta" % [str(card["id"]), line])
		# E la prosa vecchia non deve restarci accanto: due regole per la stessa
		# cosa, e una delle due non si puo' giocare.
		for old in tension.get("triggers", []) as Array:
			assert_false(notes.contains(str(old)),
				"%s stampa ancora la prosa insieme alla regola" % str(card["id"]))
	assert_eq(col_regola, 47, "le Tensioni che stampano la regola")
	assert_eq(col_prosa, 13, "e quelle che, senza casella, tengono la prosa")


## **Il cancelletto sta su una parola sola, dappertutto**
## ([D-347](../../docs/DECISIONS.md#d-347)).
##
## D-344 aveva scritto la regola — un nome stampato di piu' parole non e' un
## segnalino, e cucirgli davanti un cancelletto lo fa tornare a somigliare a un
## id — e l'aveva messa in `_sign`. Poi `_hash`, che e' la funzione che stampa il
## segno temuto dalla Risonanza, **lo rimetteva a forza**: `word if
## word.begins_with("#") else "#%s"`. **33 facce su 266** portavano
## `#il tradimento e' stato detto ad alta voce`.
##
## Non un elenco di frasi vietate: la prova prende **i nomi stampati dei segni**
## e chiede che nessuna faccia ne porti uno di piu' parole col cancelletto
## davanti. Un segno nuovo dal nome lungo e' coperto il giorno che entra.
func test_no_face_hashes_a_whole_sentence() -> void:
	var loaded: RefCounted = data()
	var lunghi: Array = []
	for tag_id in loaded.tags:
		var word: String = SignLabels.label(str(tag_id), loaded)
		if word.contains(" "):
			lunghi.append(word)
	assert_true(lunghi.size() >= 20, "i segni dal nome lungo guardati: %d" % lunghi.size())
	var guai: Array = []
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		var said: String = " ".join(PackedStringArray(
			(card["body"] as Array) + (card["notes"] as Array)
		))
		for word in lunghi:
			if said.contains("#%s" % str(word)):
				guai.append("%s: #%s" % [str(card["id"]), str(word)])
	assert_eq(guai, [], "nessuna faccia incolla un cancelletto a una frase")


## **La scena di una carta non porta numeri col segno**
## ([D-347](../../docs/DECISIONS.md#d-347)).
##
## `rules_text` faceva due mestieri: era la regola *e* il quadro. D-340 ha
## portato la regola sulla faccia stampata, e il campo e' rimasto ibrido — **35
## carte su 48** aprivano con `+1 sul fronte Oppose` o `+2 quando Autorita' e'
## rilevante`. Finche' nessuno lo leggeva non dava fastidio; da quando e' la
## **scena che si manda a chi disegna**, un `+1` in cima al prompt e' una riga
## che non si dipinge.
##
## Un `+1` o un `-2` e' sempre una regola e non e' mai un quadro: e' una regola
## sola, non un elenco di frasi, e non invecchia.
func test_a_scene_carries_no_signed_numbers() -> void:
	var loaded: RefCounted = data()
	var guai: Array = []
	var guardate: int = 0
	for asset_id in loaded.assets:
		var scene: String = str((loaded.assets[str(asset_id)] as Dictionary).get("rules_text", ""))
		if scene == "":
			continue
		guardate += 1
		for digit in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
			if scene.contains("+%s" % digit) or scene.contains("-%s" % digit):
				guai.append("%s: %s" % [str(asset_id), scene])
				break
	assert_eq(guardate, 48, "le scene guardate")
	assert_eq(guai, [], "nessuna scena apre con un numero col segno")


## **Nessuna parola interna arriva sulla carta stampata** (D-339).
##
## `domain` e `relevant_asset_families` sono enum, e stamparli minuscoli stampa
## inglese: sulla Carestia si leggeva *«domanda · survival»* e *«al Consiglio
## valgono: wealth, people, authority»*. Le parole italiane esistevano — i
## domini in `SignLabels`, le famiglie chiuse dentro `help_panel.gd`, che e' una
## vista e quindi le vedeva solo lei.
##
## La prova non guarda un elenco di parole vietate: prende **gli enum dai dati**
## e chiede che nessuno arrivi sulla faccia com'e' scritto nel JSON. Cosi' un
## enum nuovo e' coperto il giorno che entra.
func test_no_face_prints_an_internal_word() -> void:
	var loaded: RefCounted = data()
	var interne: Dictionary = {}
	for tension_id in loaded.tensions:
		var tension: Dictionary = loaded.tensions[str(tension_id)]
		interne[str(tension["domain"]).to_lower()] = true
		for family in tension["relevant_asset_families"] as Array:
			interne[str(family).to_lower()] = true
	assert_true(interne.size() >= 8, "gli enum guardati: %d" % interne.size())
	var guai: Array = []
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		var said: String = " ".join(PackedStringArray([
			str(card["title"]), str(card["subtitle"]),
			" ".join(PackedStringArray(card["body"] as Array)),
			" ".join(PackedStringArray(card["notes"] as Array)),
		])).to_lower()
		for word in interne:
			# Parola intera: «sapere» contiene «sape», e «forza» non deve
			# scattare dentro «rinforza».
			for piece in said.split(" "):
				if str(piece).strip_edges(true, true).trim_suffix(",").trim_suffix(".") == str(word):
					guai.append("%s: «%s»" % [str(card["id"]), str(word)])
					break
	assert_eq(guai, [], "nessuna carta stampa un nome interno")


## **La carta Asset stampa la faccia che si gioca, non il racconto** (D-340).
##
## Fino alla 0.1.304 la carta stampava `rules_text` — voce d'autore — e taceva
## il blocco `physical` per intero: bersaglio a segni, due Azioni, Risonanza,
## uso in Consiglio. Quarantotto carte su quarantotto, e ce l'hanno tutte.
##
## La prova non guarda un elenco di frasi buone: prende **il blocco fisico dal
## dato** e chiede che ogni sua parte arrivi sulla faccia. Una carta nuova e'
## coperta il giorno che entra, e una faccia che torna al racconto cade qui.
func test_the_asset_card_prints_the_face_you_play() -> void:
	var loaded: RefCounted = data()
	var con_faccia: int = 0
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		if str(card.get("deck", "")) != "asset":
			continue
		var asset: Dictionary = loaded.assets[str(card["id"])]
		var physical: Dictionary = asset.get("physical", {})
		var printed: String = " ".join(PackedStringArray(card.get("notes", []) as Array))
		if physical.is_empty():
			# Il ripiego e' dichiarato, non muto: la carta dice che non ce l'ha.
			assert_true(printed.contains("non ha ancora una faccia fisica"),
				"%s e' senza blocco fisico e non lo dichiara" % str(card["id"]))
			continue
		con_faccia += 1
		assert_true(printed.contains(str((physical["target"] as Dictionary)["text"])),
			"%s: il bersaglio non arriva sulla carta" % str(card["id"]))
		for action in physical["actions"] as Array:
			var written: Dictionary = action
			assert_true(printed.contains(str(written["label"])),
				"%s: l'Azione «%s» non arriva sulla carta" % [str(card["id"]), str(written["label"])])
			assert_true(printed.contains(str(written["text"])),
				"%s: cosa fa «%s» non arriva sulla carta" % [str(card["id"]), str(written["label"])])
		var resonance: Dictionary = physical["resonance"]
		var theme: String = str((loaded.themes[str(resonance["theme"])] as Dictionary)["title"])
		assert_true(printed.contains("SEMPRE  %s +%d" % [theme, int(resonance["heat"])]),
			"%s: la Risonanza non arriva sulla carta" % str(card["id"]))
		assert_true(printed.contains("AL CONSIGLIO  %d" % int(
			(physical["council_use"] as Dictionary)["base_strength"]
		)), "%s: quanto vale impegnata non arriva sulla carta" % str(card["id"]))
		# **E il racconto non ci resta accanto.** Due testi per lo stesso gesto
		# sono la ragione per cui la carta non ci stava: uno dei due non si gioca.
		var prose: String = str(asset.get("rules_text", ""))
		if prose != "":
			var whole: String = printed + " " + " ".join(
				PackedStringArray(card.get("body", []) as Array)
			)
			assert_false(whole.contains(prose),
				"%s stampa ancora il racconto insieme alla regola" % str(card["id"]))
	assert_eq(con_faccia, 48, "le carte Asset che stampano la faccia fisica")


## **La Risonanza e l'uso in Consiglio si generano, non si scrivono** (D-340).
##
## Sono interamente campi strutturati — `theme`, `heat`, `if_target_tag`,
## `extra_heat`, `extra_tag`, `base_strength`, `bonus_if_theme` — e una riga
## scritta a mano accanto a un campo e' una riga che invecchia da sola: e'
## esattamente quello che D-336 ha trovato sui Consigli, dove 89 frasi su 164
## dicevano il falso perche' erano costanti e i dati no.
##
## Qui la prova pianta una Risonanza aggravata e verifica che la parte
## condizionale compaia: senza questo, una carta che perde la clausola passerebbe
## lo stesso.
func test_the_resonance_is_read_from_the_fields() -> void:
	var loaded: RefCounted = data()
	var aggravate: int = 0
	for id in loaded.assets:
		var asset: Dictionary = loaded.assets[str(id)]
		var physical: Dictionary = asset.get("physical", {})
		if physical.is_empty():
			continue
		var resonance: Dictionary = physical["resonance"]
		var line: String = AssetText.resonance_line(physical, loaded)
		if str(resonance.get("if_target_tag", "")) == "":
			assert_false(line.contains("se il bersaglio ha"),
				"%s non ha clausola e la carta ne stampa una" % str(id))
			continue
		aggravate += 1
		assert_true(line.contains("se il bersaglio ha"),
			"%s ha la clausola e la riga non la dice" % str(id))
		var extra: String = str(resonance.get("extra_tag", ""))
		if extra != "":
			assert_true(line.contains("posa "),
				"%s lascia %s e la riga non lo posa" % [str(id), extra])
	assert_true(aggravate > 0, "nessuna carta ha una Risonanza aggravata: la prova e cieca")


## **La scheda del Consiglio e' le caselle, non le proposte in prosa** (D-341).
##
## Il committente, davanti alla scheda: *«due domande? Perche' due, i costi e
## benefici dove sono? Ci sono testi ridondanti e inutili»*. Le dodici caselle
## di D-280 — la grammatica con cui il tavolo risolve un Consiglio — stavano in
## fondo, dopo quattro proposte in prosa, e tutte e sei schiacciate in un'unica
## riga separata da punti.
##
## La prova parte dai dati: ogni casella dev'essere **una riga sua**, e nessuna
## frase di proposta deve arrivare sulla scheda.
func test_the_council_sheet_is_the_boxes_not_the_prose() -> void:
	var loaded: RefCounted = data()
	var sheets: int = 0
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		if str(card.get("deck", "")) != "council":
			continue
		var tension: Dictionary = loaded.tensions[str(card["id"])]
		var notes: Array = card.get("notes", []) as Array
		sheets += 1
		for group in ["benefits", "costs", "failure"]:
			for voice in tension.get("physical", {}).get(group, []) as Array:
				var text: String = str((voice as Dictionary).get("text", ""))
				assert_true(notes.has("· %s" % text),
					"%s: la casella «%s» non ha una riga sua" % [str(card["id"]), text])
		# E nessuna proposta in prosa: due grammatiche sulla stessa scheda sono
		# la ragione per cui le caselle stavano in fondo, e la misura dice che
		# non ci stanno insieme — due schede su dodici sfondavano il bordo.
		var whole: String = " ".join(PackedStringArray(notes)) + " " + " ".join(
			PackedStringArray(card.get("body", []) as Array)
		)
		for proposal in (tension.get("council", {}) as Dictionary).get("propositions", []) as Array:
			var said: String = str((proposal as Dictionary).get("text", ""))
			assert_false(whole.contains(said),
				"%s stampa ancora una proposta in prosa" % str(card["id"]))
	assert_eq(sheets, 60, "le schede del Consiglio")


## **Una domanda che compare senza ragione** (D-341).
##
## *«Due domande? Perche' due.»* La ragione era scritta e buttata via: undici
## domande su ventitre' portano una `eligibility` con la sua `label` — «La
## Carestia e' al limite» — che `CouncilText.proposition` calcolava gia' e che
## la scheda non stampava.
func test_a_question_that_needs_a_condition_prints_it() -> void:
	var loaded: RefCounted = data()
	var conditioned: int = 0
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		if str(card.get("deck", "")) != "council":
			continue
		var council: Dictionary = loaded.tensions[str(card["id"])].get("council", {})
		var printed: String = " ".join(PackedStringArray(card.get("body", []) as Array))
		for question in council.get("questions", []) as Array:
			for condition in (question as Dictionary).get("eligibility", []) as Array:
				var label: String = str((condition as Dictionary).get("label", ""))
				if label == "":
					continue
				conditioned += 1
				assert_true(printed.contains(label),
					"%s: «%s» non arriva sulla scheda" % [str(card["id"]), label])
	assert_true(conditioned > 0, "nessuna domanda ha una condizione: la prova e cieca")


## **La carta Domanda non stampa il racconto** (D-341), come la carta Asset da
## D-340: la `description` e' voce d'autore, e su una carta che deve dire quando
## la domanda si scalda era il primo blocco che si leggeva.
func test_the_tension_card_prints_no_description() -> void:
	var loaded: RefCounted = data()
	var cards: int = 0
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		if str(card.get("deck", "")) != "tension":
			continue
		cards += 1
		var prose: String = str(loaded.tensions[str(card["id"])].get("description", ""))
		if prose == "":
			continue
		var whole: String = " ".join(PackedStringArray(card.get("notes", []) as Array)) + " " + \
			" ".join(PackedStringArray(card.get("body", []) as Array))
		assert_false(whole.contains(prose),
			"%s stampa ancora il racconto" % str(card["id"]))
	assert_eq(cards, 60, "le carte Domanda")


## **La carta Eco diceva cosa si prova, mai cosa succede** (D-344).
##
## Il committente: *«ogni azione, effetto e #tag deve essere visibile sulla
## carta [...] il 100% delle carte devono essere lette e capite»*. Le carte Eco
## erano il buco piu' grosso: **86 Effetti scritti nel dato e zero stampati**,
## piu' 38 condizioni che dicono quando la carta puo' uscire. Sulla faccia
## c'era la `description`, e basta.
##
## La prova parte dai dati e conta due volte: ogni carta con Effetti deve
## stamparne almeno uno, e il racconto non deve restarci accanto.
func test_the_echo_card_says_what_it_does() -> void:
	var loaded: RefCounted = data()
	var con_effetti: int = 0
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		if str(card.get("deck", "")) != "echo":
			continue
		var written: Dictionary = loaded.echo_cards[str(card["id"])]
		var printed: String = " ".join(PackedStringArray(card.get("notes", []) as Array))
		var whole: String = printed + " " + " ".join(
			PackedStringArray(card.get("body", []) as Array)
		)
		if not (written.get("effect_hooks", []) as Array).is_empty():
			con_effetti += 1
			assert_true(printed.contains("IL MONDO"),
				"%s ha Effetti e la carta non li stampa" % str(card["id"]))
		for condition in written.get("eligibility", []) as Array:
			assert_true(printed.contains("QUANDO ESCE"),
				"%s ha una condizione e la carta non la stampa" % str(card["id"]))
			break
		var prose: String = str(written.get("description", ""))
		if prose != "":
			assert_false(whole.contains(prose),
				"%s stampa ancora il racconto" % str(card["id"]))
	assert_eq(
		con_effetti, loaded.echo_cards.size(),
		"ogni Eco stampa cosa fa: sono il terzo blocco della carta Asset (D-359)"
	)


## **I segni della tessera** (D-344). Una carta Azione si gioca «su un luogo con
## #granaio»: senza i segni stampati sulla tessera quel bersaglio non si trova
## col dito. Trentadue segni su dieci tessere, e non ne arrivava **nessuno** —
## `_region` costruiva una nota e il foglio la buttava via prima di disegnarla.
func test_the_region_tile_shows_its_signs() -> void:
	var loaded: RefCounted = data()
	var tessere: int = 0
	for face in CardFace.every(loaded):
		var tile: Dictionary = face as Dictionary
		if str(tile.get("deck", "")) != "region":
			continue
		tessere += 1
		var region: Dictionary = loaded.regions[str(tile["id"])]
		var drawn: Dictionary = PrintSheet.layout(
			tile, PrintSheet.cell_size(str(tile["shape"]))
		)
		var inked: Array = []
		for line in drawn["lines"] as Array:
			inked.append(str((line as Dictionary)["text"]))
		var printed: String = " ".join(PackedStringArray(inked))
		for tag in region.get("tags", []) as Array:
			# **Disegnato**, non solo calcolato: e' la differenza che questa
			# tessera ha pagato per otto versioni.
			assert_true(printed.contains(AssetText.sign_word(str(tag), loaded)),
				"%s non porta il segno %s" % [str(tile["id"]), str(tag)])
		var prose: String = str(region.get("description", ""))
		if prose != "":
			assert_false(printed.contains(prose),
				"%s stampa ancora il racconto" % str(tile["id"]))
	assert_eq(tessere, 10, "le tessere Regione")


## **Nessuna faccia stampa piu' il racconto** (D-344), su nessun mazzo. La prova
## prende il campo d'autore di ogni pezzo — `rules_text`, `description` — e
## chiede che non arrivi sulla faccia. E' l'unica forma che regge: un elenco di
## frasi vietate invecchia, un campo del dato no.
func test_no_face_prints_its_prose() -> void:
	var loaded: RefCounted = data()
	var sets: Dictionary = {
		"asset": [loaded.assets, "rules_text"],
		"echo": [loaded.echo_cards, "description"],
		"tension": [loaded.tensions, "description"],
		"destiny": [loaded.destinies, "description"],
		"entity": [loaded.entities, "description"],
		"region": [loaded.regions, "description"],
	}
	var guardate: int = 0
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		var deck: String = str(card.get("deck", ""))
		if not sets.has(deck):
			continue
		var pair: Array = sets[deck]
		var source: Dictionary = pair[0]
		if not source.has(str(card["id"])):
			continue
		var prose: String = str((source[str(card["id"])] as Dictionary).get(str(pair[1]), ""))
		if prose == "":
			continue
		guardate += 1
		var whole: String = " ".join(PackedStringArray(card.get("notes", []) as Array)) \
			+ " " + " ".join(PackedStringArray(card.get("body", []) as Array))
		assert_false(whole.contains(prose),
			"%s/%s stampa ancora il racconto" % [deck, str(card["id"])])
	assert_true(guardate > 150, "guardate %d facce con un testo d'autore" % guardate)


## **Ogni riga meccanica porta la sua intestazione** (D-345).
##
## Il committente ha chiesto lo scheletro di tutte le carte, e ricavarlo dalle
## facce vere ha trovato **quattro mazzi con righe senza etichetta**: 180 righe
## sulle carte Domanda, 64 sulle Casate, 27 sulle Asset, 20 sulle tessere. Una
## riga senza intestazione e' una riga che al tavolo si legge per ultima — e
## quando si legge non si sa cos'e'.
##
## La prova non guarda un elenco di intestazioni buone, che invecchierebbe:
## chiede che **ogni riga cominci con parole tutte maiuscole**, o con il numero
## di un'Azione, o col punto di una casella. E' la forma, non il vocabolario.
## **Su una faccia non si stampa un nome interno** (D-363).
##
## Il difetto era su 19 facce di Eco su 48: `$region_with:granary` finiva sulla
## carta come «region with:granary», e tredici segni ci finivano col proprio
## identificativo — «Nel mondo: amnesty granted» — quando il gettone sul tavolo
## porta scritto «l\'amnistia e\' stata concessa».
##
## Nessuno se n\'era accorto perche\' la faccia si **genera** (D-344), e una
## faccia generata la si guarda una volta e poi ci si fida. Questa prova e\' il
## motivo per cui fidarsi: cerca il dollaro, i due selettori a segni, e ogni
## identificativo di segno detto com\'e\' scritto nel dato.
func test_no_face_prints_an_internal_name() -> void:
	var loaded: RefCounted = data()
	var grezzi: Array = []
	for tag_id in loaded.tags:
		var detto: String = str(tag_id).replace("_", " ").replace(":", " ")
		if detto.split(" ").size() > 1:
			grezzi.append(detto)
	for face in CardFace.every(loaded):
		var card: Dictionary = face as Dictionary
		var whole: String = " ".join(PackedStringArray(card.get("notes", []) as Array))
		whole += " " + " ".join(PackedStringArray(card.get("body", []) as Array))
		assert_false(whole.contains("$"),
			"%s stampa un selettore col dollaro: %s" % [str(card["id"]), whole])
		for perso in ["region with:", "entity with:"]:
			assert_false(whole.contains(perso),
				"%s stampa il selettore «%s»" % [str(card["id"]), perso])
		for grezzo in grezzi:
			assert_false(whole.contains(grezzo),
				"%s dice un segno col suo identificativo: «%s»" % [str(card["id"]), grezzo])


func test_every_mechanical_line_has_a_headword() -> void:
	var mute: Array = []
	var guardate: int = 0
	for face in CardFace.every(data()):
		var card: Dictionary = face as Dictionary
		for note in card.get("notes", []) as Array:
			var line: String = str(note)
			if line == "":
				continue
			guardate += 1
			if line.begins_with("①") or line.begins_with("②") or line.begins_with("· "):
				continue
			var first: String = line.split(" ")[0]
			var shouted: bool = first.length() >= 2 and first == first.to_upper()
			if not shouted:
				mute.append("%s/%s: «%s»" % [
					str(card["deck"]), str(card["id"]), line.substr(0, 40),
				])
	assert_true(guardate > 400, "guardate %d righe" % guardate)
	assert_eq(mute.size(), 0, "righe senza intestazione: %s" % " | ".join(
		PackedStringArray(mute.slice(0, 3))
	))
