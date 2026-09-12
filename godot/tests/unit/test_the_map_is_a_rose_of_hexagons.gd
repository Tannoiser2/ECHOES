extends "res://tests/test_case.gd"
## **La mappa sullo schermo e' una rosa di esagoni** (D-512).
##
## D-279 aveva fatto la tessera quadrata, e allora era giusto: la mappa era un
## 3x2 di cartoni quadrati. Da D-510 il cartone e' esagonale davvero, e lo
## schermo deve dire quello che dice il tavolo.
##
## Qui si prova la **geometria**, non il disegno: sono le tre funzioni che
## decidono dove cade una tessera, quanto e' larga a una certa altezza, e —
## quella che conta di piu' — **dove il dito prende e dove no**. Il disegno lo
## guarda una persona; questi sono i numeri che si possono sbagliare in
## silenzio.

const MapView := preload("res://ui/map_view.gd")

## La casa ha `assert_true`, `assert_false`, `assert_eq` e `assert_ne`, e basta.
## Per i decimali serve una tolleranza, e si scrive qui invece di ripetere
## `absf(a - b) < t` in dodici posti.
func _vicino(actual: float, expected: float, tolleranza: float, message: String) -> void:
	assert_true(
		absf(actual - expected) <= tolleranza,
		"%s (era %.3f, atteso %.3f)" % [message, actual, expected]
	)



## **Il dito non prende i sei angoli che la fustella toglie.**
##
## E' il difetto che il quadrato aveva per costruzione: `|dx| <= R and |dy| <= R`
## prende tutto il riquadro, angoli compresi, e su un esagono quegli angoli sono
## **fuori dal cartone** — un tocco che cade li' accendeva una tessera su cui la
## pedina non si puo' posare. Con la sagoma vera non succede.
func test_the_finger_does_not_take_the_corners_the_die_cut_removes() -> void:
	var r: float = 60.0
	var centre: Vector2 = Vector2(200.0, 200.0)
	var shape: PackedVector2Array = MapView._hex_points(centre, r)
	assert_eq(shape.size(), 6, "l'esagono ha sei vertici")

	assert_true(
		Geometry2D.is_point_in_polygon(centre, shape),
		"il centro della tessera e' dentro"
	)
	# I quattro angoli del riquadro che contiene l'esagono: tutti fuori.
	for corner in [Vector2(-1.0, -1.0), Vector2(1.0, -1.0), Vector2(1.0, 1.0), Vector2(-1.0, 1.0)]:
		var at: Vector2 = centre + corner * r * 0.98
		assert_false(
			Geometry2D.is_point_in_polygon(at, shape),
			"l'angolo %s del riquadro sta fuori dal cartone" % str(corner)
		)
	# E il **caso che deve dare dentro**: senza questo la prova passerebbe
	# anche con un poligono vuoto, che non contiene niente.
	for verso in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		assert_true(
			Geometry2D.is_point_in_polygon(centre + verso * r * 0.5, shape),
			"a meta' strada verso %s si e' ancora sulla tessera" % str(verso)
		)


## **Lato piatto sopra e sotto, punte a sinistra e a destra.** E' l'orientamento
## che i dati chiamano per nome: cosi' i sei lati sono `N NE SE S SO NO` in
## senso orario dall'alto, e il petalo a nord sta **davvero** sopra il centro.
## Girato di trenta gradi sarebbe un'altra mappa, coi varchi che non combaciano
## piu' con quelli stampati.
func test_the_hexagon_lies_flat_on_top() -> void:
	var r: float = 60.0
	var shape: PackedVector2Array = MapView._hex_points(Vector2.ZERO, r)
	var wide: float = 0.0
	var tall: float = 0.0
	for p in shape:
		wide = maxf(wide, absf(p.x))
		tall = maxf(tall, absf(p.y))
	_vicino(wide, r, 0.01, "larga due raggi: le punte stanno ai lati")
	_vicino(tall, r * 0.8660254, 0.01, "alta meno: sopra e sotto c'e' un lato piatto")
	# Sopra e sotto la tessera si stringe, ed e' il motivo per cui i segnalini
	# non si mettono alla larghezza del centro.
	_vicino(MapView._hex_half_width(0.0, r), r, 0.01, "al centro e' larga tutta")
	assert_true(
		MapView._hex_half_width(r * 0.7, r) < r * 0.65,
		"vicino al bordo alto si e' stretta parecchio"
	)


## **I sei petali cadono intorno alla capitale, uno per lato.**
##
## La posa viene dal mondo — `map_positions`, [colonna, riga] — e qui si legge
## come coordinata d'esagono. La casella del centro e' (1,1); il petalo a nord
## e' (1,0) e dev'essere **sopra** di lei, non di fianco.
func test_the_six_petals_fall_around_the_capital() -> void:
	var r: float = 60.0
	var passo: float = 1.7320508 * r
	var centro: Vector2 = MapView._hex_offset(1, 1, r)
	var caselle: Dictionary = {
		"P1": Vector2i(1, 0), "P2": Vector2i(2, 1), "P3": Vector2i(2, 2),
		"P4": Vector2i(1, 2), "P5": Vector2i(0, 2), "P6": Vector2i(0, 1),
	}
	var visti: Dictionary = {}
	for slot in caselle:
		var spot: Vector2i = caselle[slot] as Vector2i
		var dove: Vector2 = MapView._hex_offset(spot.x, spot.y, r) - centro
		_vicino(dove.length(), passo, 0.5,
			"%s tocca la capitale: un passo d'incastro" % str(slot))
		var key: String = "%d,%d" % [roundi(dove.x), roundi(dove.y)]
		assert_false(visti.has(key), "%s non cade dove cade un altro petalo" % str(slot))
		visti[key] = true
	# Il nord e' sopra, il sud e' sotto: se la rosa fosse girata questa cade.
	var nord: Vector2 = MapView._hex_offset(1, 0, r) - centro
	_vicino(nord.x, 0.0, 0.5, "il petalo a nord sta sulla stessa colonna")
	assert_true(nord.y < 0.0, "e sopra la capitale")
	var sud: Vector2 = MapView._hex_offset(1, 2, r) - centro
	assert_true(sud.y > 0.0, "e quello a sud sotto")
