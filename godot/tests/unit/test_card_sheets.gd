extends "res://tests/test_case.gd"
## **La scheda di ogni tipo di carta, e il dato per generarle** (D-445).
##
## Il committente vuole una scheda per tipo con cui generare le carte in
## automatico, grafica e testo. Queste prove tengono il patto: ogni faccia che
## si stampa e' nel dato, col suo prompt composto; le voci scritte a mano sono
## quelle che le facce stampano, nei due versi; e la guardia morde.

const ArtBible := preload("res://scripts/core/art_bible.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const CardSheets := preload("res://scripts/core/card_sheets.gd")

var _box: RefCounted = null
var _bible: RefCounted = null


## **I dati della scatola, non quelli condivisi** (regola di casa): una prova
## che misura la scatola si costruisce il suo set.
func _shipped() -> RefCounted:
	if _box == null:
		_box = DataSet.new()
		assert_true(_box.load_from("res://data"), "i dati spediti si caricano")
	return _box


func _art() -> RefCounted:
	if _bible == null:
		_bible = ArtBible.new()
		assert_true(_bible.read("res://../docs/ART_BIBLE.md"), "la ART_BIBLE si legge")
	return _bible


## **Ogni faccia e' nel dato, e ogni tipo ha la sua scheda.**
func test_every_face_is_in_the_data_of_its_deck() -> void:
	var loaded: RefCounted = _shipped()
	for deck in CardFace.DECKS + CardFace.TILES:
		var sheet: Dictionary = CardSheets.deck_of(str(deck), loaded, _art())
		var faces: Array = CardFace.deck_of(str(deck), loaded)
		assert_eq((sheet["carte"] as Array).size(), faces.size(), "%s: una scheda per faccia" % str(deck))
		assert_ne(str(sheet["cos_e"]), "", "%s: la scheda dice cos'e'" % str(deck))
		assert_ne(str(sheet["immagine"]), "", "%s: e che immagine porta" % str(deck))
		for i in range(faces.size()):
			var card: Dictionary = (sheet["carte"] as Array)[i]
			var face: Dictionary = faces[i]
			assert_eq(str(card["id"]), str(face["id"]), "stessa carta, stesso ordine")
			assert_ne(str(card["titolo"]), "", "%s ha un titolo" % str(card["id"]))
			assert_eq(str(card["pie"]), str(face["footer"]), "e il suo pie'")


## **Le righe meccaniche escono voce per voce**, e la voce e' quella stampata.
func test_the_rows_carry_their_headword() -> void:
	var loaded: RefCounted = _shipped()
	var asset: Dictionary = CardSheets.deck_of("asset", loaded, _art())
	var first: Dictionary = (asset["carte"] as Array)[0]
	var voci: Array = []
	for row in first["righe"] as Array:
		voci.append(str((row as Dictionary)["voce"]))
		assert_ne(str((row as Dictionary)["testo"]), "", "ogni riga ha un testo")
	assert_true(voci.has("DOVE"), "la carta Asset porta DOVE: %s" % str(voci))
	assert_true(voci.has("①") and voci.has("②"), "e le due Azioni numerate")
	assert_true(voci.has("SEMPRE"), "e la Risonanza")
	# Il testo non ripete la voce.
	for row in first["righe"] as Array:
		var testo: String = str((row as Dictionary)["testo"])
		assert_false(testo.begins_with("DOVE") or testo.begins_with("SEMPRE"), "la voce e' tolta dal testo: %s" % testo)


## **Il prompt e' composto e pronto**, con la scena dentro, per ogni carta che
## ha un'illustrazione — e assente, non vuoto, per quelle che non ce l'hanno.
func test_every_illustrated_card_carries_its_composed_prompt() -> void:
	var loaded: RefCounted = _shipped()
	var with_art: int = 0
	var without: int = 0
	for deck in CardFace.DECKS + CardFace.TILES:
		var sheet: Dictionary = CardSheets.deck_of(str(deck), loaded, _art())
		for card_v in sheet["carte"] as Array:
			var card: Dictionary = card_v
			if card["arte"] == null:
				without += 1
				continue
			with_art += 1
			var arte: Dictionary = card["arte"]
			assert_ne(str(arte["chiave"]), "", "%s: la chiave" % str(card["id"]))
			assert_ne(str(arte["prompt"]), "", "%s: il prompt composto" % str(card["id"]))
			assert_true(
				str(arte["prompt"]).contains(str(card["titolo"])),
				"%s: il prompt nomina la carta" % str(card["id"])
			)
			assert_ne(str(arte["scena"]), "", "%s: e porta la scena" % str(card["id"]))
	assert_true(with_art > 100, "piu' di cento carte illustrate: %d" % with_art)
	assert_true(without > 50, "e piu' di cinquanta tutte testo (Domande, schede): %d" % without)


## **Gli Obiettivi hanno una faccia, e stanno dietro il paravento** (D-445).
func test_the_objectives_are_cards_now() -> void:
	var loaded: RefCounted = _shipped()
	var sheet: Dictionary = CardSheets.deck_of("objective", loaded, _art())
	assert_eq(int(sheet["facce"]), loaded.objectives.size(), "una carta per Obiettivo")
	assert_ne(str(sheet["prompt_generale"]), "", "e il tipo ha il suo prompt generale")
	for card_v in sheet["carte"] as Array:
		var card: Dictionary = card_v
		assert_true(bool(card["segreta"]), "%s e' coperta" % str(card["id"]))
		assert_false((card["corpo"] as Array).is_empty(), "%s dice la promessa in una riga" % str(card["id"]))


## **La guardia delle voci morde nei due versi**, su un difetto fabbricato.
func test_the_guard_bites_on_a_planted_defect() -> void:
	var loaded: RefCounted = _shipped()
	assert_eq(CardSheets.complaints(loaded), [], "le schede spedite sono allineate alle facce")
	var planted: Dictionary = CardSheets.TYPES.duplicate(true)
	# Una voce promessa che nessuna faccia stampa.
	((planted["asset"] as Dictionary)["voci"] as Array).append("MAI STAMPATA")
	# E una voce stampata che la scheda tace.
	((planted["region"] as Dictionary)["voci"] as Array).erase("VARCHI")
	var found: Array = CardSheets.complaints(loaded, planted)
	assert_eq(found.size(), 2, "due difetti, due lamentele: %s" % str(found))
	assert_true(str(found[0]).contains("VARCHI") or str(found[1]).contains("VARCHI"), "la voce taciuta")
	assert_true(str(found[0]).contains("MAI STAMPATA") or str(found[1]).contains("MAI STAMPATA"), "e quella inventata")


## **Deterministico**: due giri, lo stesso documento e lo stesso JSON.
func test_the_sheets_are_the_same_every_time() -> void:
	var loaded: RefCounted = _shipped()
	assert_eq(
		CardSheets.document(loaded, _art(), "schede"), CardSheets.document(loaded, _art(), "schede"),
		"il documento non cambia fra due giri"
	)
	assert_eq(
		CardSheets.deck_json("tension", loaded, _art()), CardSheets.deck_json("tension", loaded, _art()),
		"e nemmeno il JSON"
	)
	var parsed: Variant = JSON.parse_string(CardSheets.deck_json("tension", loaded, _art()))
	assert_true(parsed is Dictionary, "e il JSON si rilegge")
