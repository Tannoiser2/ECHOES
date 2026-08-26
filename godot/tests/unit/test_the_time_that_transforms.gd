extends "res://tests/test_case.gd"
## **La seconda porta: il tempo, e quello che non tieni piu'** (D-290).
##
## Parola del committente: *«un re deve controllare due citta' e sopravvivere se
## passa poco tempo, ma se passano secoli due citta' non sono sufficienti per
## tenere il regno e questo si trasforma in una repubblica»*.
##
## Il motore faceva due domande - c'e' il segno? la linea e' finita? - e mai la
## terza: **da quanto**. Queste prove tengono le due meta' della soglia, e
## soprattutto che servano **tutte e due**: il tempo da solo non trasforma
## nessuno, e nemmeno la perdita da sola.

const Succession := preload("res://scripts/chronicle/succession.gd")

## Quello che Aldric ha dichiarato di voler lasciare nel mondo (D-288): la
## soglia legge questo, non un elenco suo.
const ALDRIC_WANTS: Array = ["succession_by_law", "crowned"]


func _chronicle(id: String) -> Dictionary:
	return data().chronicles[id]


## Un mondo di prima in cui Aldric siede da `anni` con addosso questi segni.
func _world(years_so_far: int, held: Array) -> Dictionary:
	return {
		"entities": {"ENT_ALDRIC": {
			"name": "Re Aldric", "generation": 0, "incarnation": 0,
			"life_years": years_so_far, "active": true, "tags": held.duplicate(),
		}},
		"regions": {},
		"global_tags": [],
	}


func test_two_cities_are_enough_for_a_decade() -> void:
	# Dieci anni: la soglia non c'entra, e al trono ci sta ancora lui.
	var plan: Dictionary = Succession.plan(
		_world(0, []), {}, _chronicle("CHR_02"), data(), 10
	)
	var seat: Dictionary = plan["ENT_ALDRIC"] as Dictionary
	assert_false(bool(seat["transformed"]), "dieci anni non trasformano niente")
	assert_eq(str(seat["name"]), "Re Aldric", "e al trono c'e' ancora lui")
	assert_eq(int(seat["life_years"]), 10, "il contatore della pelle cammina")


func test_but_not_for_three_centuries() -> void:
	# Due secoli senza niente di quello che la casa voleva lasciare: il Regno
	# non e' piu' un regno.
	var plan: Dictionary = Succession.plan(
		_world(100, []), {}, _chronicle("CHR_02"), data(), 100
	)
	var seat: Dictionary = plan["ENT_ALDRIC"] as Dictionary
	assert_true(bool(seat["transformed"]), "la casa cambia pelle")
	assert_eq(str(seat["name"]), "La Repubblica della Valle", "e sappiamo in cosa")
	assert_eq(str(seat["entry_kind"]), "AFTER_YEARS", "dalla porta del tempo")
	assert_eq(str(seat["transformed_from"]), "Re Aldric", "e il verbale sa da cosa")
	assert_eq(int(seat["life_years"]), 0, "la pelle nuova ha zero anni")


## **Il tempo da solo non trasforma nessuno.** Se il mondo porta ancora quello
## che la casa voleva lasciare, il Regno resta un Regno anche dopo due secoli:
## si cambia il re, non la cosa.
func test_time_alone_transforms_nobody() -> void:
	var plan: Dictionary = Succession.plan(
		_world(100, ALDRIC_WANTS), {}, _chronicle("CHR_02"), data(), 100
	)
	var seat: Dictionary = plan["ENT_ALDRIC"] as Dictionary
	assert_false(bool(seat["transformed"]), "chi tiene quello che voleva resta se stesso")
	assert_true(bool(seat["changed"]), "ma il tempo passa lo stesso: si siede un erede")
	assert_eq(int(seat["life_years"]), 200, "e il contatore continua a correre")


## **E la perdita da sola nemmeno.** Trent'anni senza niente in mano fanno
## sedere un erede, non una repubblica: una casa non cambia natura in una
## generazione.
func test_losing_alone_transforms_nobody() -> void:
	var plan: Dictionary = Succession.plan(
		_world(0, []), {}, _chronicle("CHR_02"), data(), 30
	)
	var seat: Dictionary = plan["ENT_ALDRIC"] as Dictionary
	assert_false(bool(seat["transformed"]), "trent'anni non bastano")
	assert_eq(str(seat["name"]), "Re Serane", "si siede l'erede")


## Uno solo dei due segni non basta: la porta chiede `holds_at_least`, e il
## numero e' scritto sulla vita, non nel codice.
func test_the_threshold_is_a_number_the_life_declares() -> void:
	var door: Dictionary = {}
	for life in (data().entities["ENT_ALDRIC"] as Dictionary)["incarnations"]:
		if str((life as Dictionary)["id"]) == "INC_ALDRIC_02":
			door = (life as Dictionary).get("also_enters", {}) as Dictionary
	assert_false(door.is_empty(), "la Repubblica dichiara la sua porta")
	var one: Dictionary = Succession.plan(
		_world(200, [ALDRIC_WANTS[0]]), {}, _chronicle("CHR_02"), data(), 10
	)
	assert_true(
		bool((one["ENT_ALDRIC"] as Dictionary)["transformed"]),
		"con un segno solo, sotto i %d chiesti, la casa cade" % int(door["holds_at_least"])
	)
	var two: Dictionary = Succession.plan(
		_world(200, ALDRIC_WANTS), {}, _chronicle("CHR_02"), data(), 10
	)
	assert_false(
		bool((two["ENT_ALDRIC"] as Dictionary)["transformed"]),
		"con due, no"
	)


## **Il contatore viaggia col seggio**, o la soglia non arriverebbe mai: e' un
## passaggio di setup come `barren`, non un Effetto.
func test_the_clock_travels_with_the_seat() -> void:
	new_session()
	var previous: Dictionary = _world(140, [])
	previous["year"] = 300
	var next: RefCounted = GameSession.new(data())
	next.setup("CHR_02", ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"], 99)
	next.inherit_from(previous, {})
	var seat: Dictionary = next.world["entities"]["ENT_ALDRIC"] as Dictionary
	assert_true(seat.has("life_years"), "il seggio porta il contatore")
	assert_eq(
		str(seat["name"]), "La Repubblica della Valle",
		"e la soglia scatta sul mondo vero, non solo nel piano"
	)
	assert_eq(int(seat["life_years"]), 0, "con la pelle nuova a zero anni")
	next.dispose()
