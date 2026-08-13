extends "res://tests/test_case.gd"
## Il posto dove sta l'arte vera (D-059).
##
## La convenzione e' il nome del file: la chiave con i punti al posto delle
## barre, sotto `res://art/`. Quello che questi test tengono fermo e' il
## comportamento che rende la convenzione utilizzabile - **un'immagine che manca
## non e' un errore**. Se lo fosse, il gioco non si potrebbe giocare finche' non
## sono arrivate tutte e novantasei le illustrazioni.

const ArtLibrary := preload("res://scripts/core/art_library.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")

## Una cartella di prova con dentro un PNG vero da 4x4: la radice vera del gioco
## e' quasi sempre vuota, e un test che passa perche' non c'e' niente non prova
## niente.
const FIXTURES: String = "res://tests/fixtures/art"


func before_each() -> void:
	ArtLibrary.forget()


func after_each() -> void:
	ArtLibrary.forget()
	super.after_each()


func test_the_key_is_the_path() -> void:
	assert_eq(
		ArtLibrary.path_for("asset.force.levy"), "res://art/asset/force/levy.png",
		"i punti diventano cartelle"
	)
	assert_eq(
		ArtLibrary.path_for("region.eredan", FIXTURES), "%s/region/eredan.png" % FIXTURES,
		"e la radice si puo spostare, che serve solo ai test"
	)


func test_an_image_that_exists_is_loaded() -> void:
	assert_true(ArtLibrary.has("region.prova", FIXTURES), "il file di prova c'e")
	var loaded: Image = ArtLibrary.image("region.prova", FIXTURES)
	assert_true(loaded != null, "e si legge come immagine")
	assert_eq(loaded.get_width(), 4, "quattro pixel di larghezza")
	assert_eq(loaded.get_height(), 4, "quattro di altezza")


## Il cuore della cosa: chi chiede un'immagine che non c'e' riceve `null` e
## disegna il segnaposto. Nessun errore, nessun buco, nessuna partita bloccata.
func test_an_image_that_is_missing_is_not_an_error() -> void:
	assert_false(ArtLibrary.has("region.nessuna", FIXTURES), "il file non c'e")
	assert_eq(ArtLibrary.image("region.nessuna", FIXTURES), null, "e l'immagine e nulla")
	assert_eq(ArtLibrary.texture("region.nessuna", FIXTURES), null, "e anche la texture")
	assert_eq(ArtLibrary.data_uri("region.nessuna", FIXTURES), "", "e il foglio non incorpora niente")
	assert_false(ArtLibrary.has("", FIXTURES), "una chiave vuota non e un file")


## Il `data:` URI e' quello che finisce dentro l'SVG, e deve restare uguale a
## ogni export: gli stessi byte, la stessa stringa.
func test_the_data_uri_is_stable_and_embeddable() -> void:
	var once: String = ArtLibrary.data_uri("region.prova", FIXTURES)
	assert_true(once.begins_with("data:image/png;base64,"), "e un PNG incorporato")
	assert_eq(once, ArtLibrary.data_uri("region.prova", FIXTURES), "due letture, la stessa stringa")
	assert_false(once.contains('"'), "e non contiene virgolette: sta dentro un attributo XML")


## Finche' non c'e' nessuna illustrazione, il foglio di stampa disegna quello che
## disegnava prima. E' la prova che la 0.1.21 non ha cambiato niente di visibile
## a chi non ha ancora consegnato un file.
func test_the_sheet_falls_back_to_what_it_drew_before() -> void:
	var faces: Array = CardFace.deck_of("region", data())
	var page: String = PrintSheet.page_svg(faces, "TILE", "prova", 1, 1)
	var painted: int = 0
	for face in faces:
		if ArtLibrary.has(str((face as Dictionary)["art_prompt_key"])):
			painted += 1
	if painted == 0:
		assert_false(page.contains("<image"), "nessuna immagine incorporata")
		assert_true(page.contains("<polygon"), "e il terreno generato c'e ancora")
	else:
		assert_true(page.contains("<image"), "le illustrazioni consegnate sono incorporate")
