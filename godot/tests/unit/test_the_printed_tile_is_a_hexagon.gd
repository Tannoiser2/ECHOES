extends "res://tests/test_case.gd"
## **La tessera si stampa esagonale** (D-516).
##
## D-279 aveva fatto la cella quadrata — 80x80 — e il commento diceva *«quadrata
## come chiede il MASTER PROMPT 3»*. Quel MASTER PROMPT l'ha riscritto D-510: la
## tessera e' un **esagono a lato piatto**, e lo schermo lo disegna cosi' da
## D-512. Il foglio di stampa era rimasto indietro, e chi stampava ritagliava un
## quadrato per un posto che sul tavolo e' un esagono.
##
## Qui si prova la **geometria del foglio**, che e' quella che si puo' sbagliare
## in silenzio: il disegno lo guarda una persona, questi sono numeri.

const PrintSheet := preload("res://scripts/core/print_sheet.gd")
const CardFace := preload("res://scripts/core/card_face.gd")

const SQRT3: float = 1.7320508


func _vicino(actual: float, expected: float, tolleranza: float, message: String) -> void:
	assert_true(
		absf(actual - expected) <= tolleranza,
		"%s (era %.3f, atteso %.3f)" % [message, actual, expected]
	)


## **La cella e' la scatola dell'esagono, non un quadrato.**
func test_the_cell_is_the_box_of_a_flat_top_hexagon() -> void:
	var cell: Vector2 = PrintSheet.cell_size("TILE")
	_vicino(cell.x, 80.0, 0.01, "larga 80 mm, punta a punta")
	_vicino(cell.y, cell.x * SQRT3 * 0.5, 0.02, "e alta quanto un esagono largo cosi'")
	assert_true(cell.y < cell.x, "quindi piu' bassa che larga: non e' un quadrato")

	var points: PackedVector2Array = PrintSheet.hex_points(0.0, 0.0, cell)
	assert_eq(points.size(), 6, "sei vertici")
	# Lato piatto sopra e sotto, punte a sinistra e a destra: se fosse girato di
	# trenta gradi i varchi non combacerebbero piu' con quelli stampati.
	var wide: float = 0.0
	var tall: float = 0.0
	var centre: Vector2 = Vector2(cell.x * 0.5, cell.y * 0.5)
	for p in points:
		wide = maxf(wide, absf(p.x - centre.x))
		tall = maxf(tall, absf(p.y - centre.y))
	_vicino(wide, cell.x * 0.5, 0.01, "le punte stanno ai lati")
	_vicino(tall, cell.y * 0.5, 0.01, "sopra e sotto c'e' un lato piatto")
	# Due vertici alla stessa altezza in cima: e' il lato piatto.
	var in_cima: int = 0
	for p in points:
		if absf(p.y - (centre.y - cell.y * 0.5)) < 0.01:
			in_cima += 1
	assert_eq(in_cima, 2, "il lato di sopra e' piatto, non una punta")


## **Sopra e sotto la tessera si stringe**, e il foglio lo sa.
func test_the_tile_narrows_toward_the_flat_sides() -> void:
	var r: float = 40.0
	_vicino(PrintSheet.hex_half_width(0.0, r), r, 0.01, "a meta' altezza e' larga tutta")
	assert_true(
		PrintSheet.hex_half_width(r * SQRT3 * 0.5, r) < r * 0.55,
		"e sul lato di sopra e' larga circa un lato"
	)
	# Il caso che deve dare non-zero: senza, una formula che torna sempre zero
	# passerebbe la riga qui sopra.
	assert_true(PrintSheet.hex_half_width(r * 0.5, r) > r * 0.6, "a meta' strada e' ancora larga")


## **Quello che si stampa sta dentro la sagoma.**
##
## E' la prova che conta: fuori dall'esagono c'e' carta che si butta, e una riga
## stampata li' e' una riga che il giocatore non leggera' mai. Si guarda ogni
## tessera vera, non una finta.
func test_nothing_printed_falls_outside_the_die_cut() -> void:
	var cell: Vector2 = PrintSheet.cell_size("TILE")
	var r: float = cell.x * 0.5
	var centre: Vector2 = Vector2(cell.x * 0.5, cell.y * 0.5)
	var viste: int = 0
	for face in CardFace.deck_of("region", data()):
		var drawn: Dictionary = PrintSheet.layout(face as Dictionary, cell)
		assert_true(bool(drawn.get("hex", false)), "la tessera si impagina da esagono")
		assert_false(bool(drawn["overflow"]), "%s: il testo ci sta" % str((face as Dictionary)["id"]))
		for line in drawn["lines"]:
			var item: Dictionary = line
			var half: float = PrintSheet.hex_half_width(float(item["y"]) - centre.y, r)
			assert_true(
				float(item["x"]) >= centre.x - half - 0.01,
				"%s: la riga «%s» comincia dentro il cartone"
				% [str((face as Dictionary)["id"]), str(item["text"])]
			)
			viste += 1
	assert_true(viste > 0, "e qualche riga si e' guardata davvero")


## **Il foglio cambia forma, e ci sta piu' roba.**
func test_the_sheet_fits_more_tiles_now() -> void:
	assert_eq(PrintSheet.columns("TILE"), 2, "due colonne su A4")
	assert_eq(PrintSheet.per_page("TILE"), 8, "e otto tessere per foglio invece di sei")
	var cell: Vector2 = PrintSheet.cell_size("TILE")
	assert_true(cell.y * 4.0 <= 297.0, "quattro righe stanno nell'altezza di un A4")
	assert_true(cell.x * 2.0 <= 210.0, "e due colonne nella larghezza")
