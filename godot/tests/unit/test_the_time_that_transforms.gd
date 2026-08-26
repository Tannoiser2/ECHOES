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


## Un mondo di prima in cui Aldric siede da `anni` con addosso questi segni,
## e **tiene quello che la sua porta gli chiede di tenere**: due Regioni che
## contano e una torre in piedi (D-298). Le prove che vogliono vederlo cadere
## tolgono una gamba per volta, invece di partire da un mondo vuoto: un mondo
## vuoto farebbe cadere chiunque, e non proverebbe niente.
func _world(years_so_far: int, held: Array, regions: Variant = null) -> Dictionary:
	return {
		"entities": {"ENT_ALDRIC": {
			"name": "Re Aldric", "generation": 0, "incarnation": 0,
			"life_years": years_so_far, "active": true, "tags": held.duplicate(),
		}},
		"regions": _standing() if regions == null else regions,
		"global_tags": [],
	}


## Il regno in piedi: la capitale col suo presidio, e il granaio.
func _standing() -> Dictionary:
	return {
		"REG_EREDAN": {
			"control": "ENT_ALDRIC", "tags": ["capital"],
			"structures": [{"structure_type": "STR_KEEP", "grade": 1, "owner": "ENT_ALDRIC"}],
		},
		"REG_VALLE_VERDE": {
			"control": "ENT_ALDRIC", "tags": ["granary"], "structures": [],
		},
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
	# non e' piu' un regno. Le Regioni ci sono ancora — cade la sola gamba dei
	# desideri, e basta quella.
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
	var door: Dictionary = _door("ENT_ALDRIC", "INC_ALDRIC_02")
	assert_false(door.is_empty(), "la Repubblica dichiara la sua porta")
	var chiesti: int = 0
	for clause in (door["unless"] as Array):
		if str((clause as Dictionary)["type"]) == "holds_wanted":
			chiesti = int((clause as Dictionary)["min"])
	assert_true(chiesti >= 1, "e la porta dice quanti desideri devono reggere")
	var one: Dictionary = Succession.plan(
		_world(200, [ALDRIC_WANTS[0]]), {}, _chronicle("CHR_02"), data(), 10
	)
	assert_true(
		bool((one["ENT_ALDRIC"] as Dictionary)["transformed"]),
		"con un segno solo, sotto i %d chiesti, la casa cade" % chiesti
	)
	var two: Dictionary = Succession.plan(
		_world(200, ALDRIC_WANTS), {}, _chronicle("CHR_02"), data(), 10
	)
	assert_false(
		bool((two["ENT_ALDRIC"] as Dictionary)["transformed"]),
		"con due, no"
	)


## La porta di una vita, per id.
func _door(entity_id: String, life_id: String) -> Dictionary:
	for life in (data().entities[entity_id] as Dictionary)["incarnations"]:
		if str((life as Dictionary)["id"]) == life_id:
			return (life as Dictionary).get("also_enters", {}) as Dictionary
	return {}


## **E ogni gamba regge da sola** (D-298): il regno tiene i suoi desideri, ma
## perde le Regioni — e cade lo stesso. E' la meta' che mancava a D-290, dove
## una porta fatta di sole memorie non si apriva mai (ISSUES 81).
func test_losing_the_land_is_enough_even_holding_the_memories() -> void:
	var senza_terra: Dictionary = {
		"REG_EREDAN": {"control": "ENT_LYRA", "tags": ["capital"], "structures": []},
		"REG_VALLE_VERDE": {"control": "ENT_LYRA", "tags": ["granary"], "structures": []},
	}
	var plan: Dictionary = Succession.plan(
		_world(200, ALDRIC_WANTS, senza_terra), {}, _chronicle("CHR_02"), data(), 10
	)
	var seat: Dictionary = plan["ENT_ALDRIC"] as Dictionary
	assert_true(
		bool(seat["transformed"]),
		"tiene le sue memorie e non tiene piu' niente sulla mappa: diventa un'altra cosa"
	)
	assert_eq(str(seat["name"]), "La Repubblica della Valle", "e sappiamo in cosa")


## **E la Pietra e' una gamba come le altre.** Il regno tiene terra e desideri,
## ma la torre e' caduta: e' abbastanza.
func test_the_keep_is_a_leg_too() -> void:
	var senza_torre: Dictionary = _standing()
	(senza_torre["REG_EREDAN"] as Dictionary)["structures"] = []
	var plan: Dictionary = Succession.plan(
		_world(200, ALDRIC_WANTS, senza_torre), {}, _chronicle("CHR_02"), data(), 10
	)
	assert_true(
		bool((plan["ENT_ALDRIC"] as Dictionary)["transformed"]),
		"senza il posto da cui si dice di no, il trono e' una casa con una corona dentro"
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
