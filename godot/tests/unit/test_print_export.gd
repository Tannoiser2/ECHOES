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
		var destiny_id: String = str(data().entities[str(item["id"])]["destiny_id"])
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
	var prompt: String = bible.prompt_for(face, "Leva Contadina", "FORCE")
	assert_true(prompt.contains("Leva Contadina"), "il soggetto e dentro il prompt")
	assert_true(prompt.contains("rosso ossido"), "e l'accento e quello della sua famiglia")
	assert_false(prompt.contains("{"), "non resta nessun segnaposto da sostituire")


## Le chiavi in uso che nessun MASTER PROMPT copre. Non e' un fallimento: e' un
## conto aperto, e il test lo tiene fermo al numero che sappiamo (le otto Casate,
## per cui la ART_BIBLE ha tre prompt e nessun ritratto).
func test_the_keys_without_a_prompt_are_the_ones_we_know_about() -> void:
	var bible: RefCounted = ArtBible.new()
	var missing: Array = bible.keys_without_prompt(data())
	assert_eq(missing.size(), data().entities.size(), "una per Casata, e nessun'altra")
	for key in missing:
		assert_true(str(key).begins_with("entity."), "%s e una Casata" % str(key))
