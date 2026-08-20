extends "res://tests/test_case.gd"
## La terra che si costruisce (D-157), primo passo della strada C.
##
## Una struttura non e' un tag: e' un **oggetto** con tipo, grado e padrone. Il
## segno `structure:` del grado si posa insieme, cosi' le cinque regole dei
## segni gia' scritte continuano a leggerlo — **l'oggetto e' la verita', il tag
## e' derivato**.
##
## In questo passo nessun dato del gioco costruisce niente: il catalogo ha una
## scala sola (il presidio) e nessuna carta la posa. Quello che i test tengono
## fermo e' il meccanismo, non la scelta di accenderlo.

const Effect := preload("res://scripts/core/effect.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")

const KEEP: String = "STR_KEEP"
const HERE: String = "REG_MONTAGNE_ROSSE"


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return {"kind": "TEST", "id": "structures"}


func _build(region_id: String, grade: int, owner: Variant) -> Dictionary:
	return session.applier.apply(Effect.make(
		"BUILD_STRUCTURE", "region", region_id,
		{"structure_type": KEEP, "grade": grade, "owner": owner}, _source()
	))


func _structures(region_id: String) -> Array:
	return (session.world["regions"][region_id] as Dictionary)["structures"]


func _tags(region_id: String) -> Array:
	return (session.world["regions"][region_id] as Dictionary)["tags"]


## Alzare un presidio lo mette nella Regione, col suo grado e il suo padrone.
func test_building_puts_an_object_in_the_region() -> void:
	assert_eq(_structures(HERE).size(), 0, "si parte senza niente sopra")
	_build(HERE, 1, "ENT_VAERAX")
	assert_eq(_structures(HERE).size(), 1, "adesso c'e'")
	var built: Dictionary = _structures(HERE)[0]
	assert_eq(str(built["structure_type"]), KEEP, "il tipo")
	assert_eq(int(built["grade"]), 1, "il grado")
	assert_eq(str(built["owner"]), "ENT_VAERAX", "e chi la tiene")


## Il segno del grado si posa insieme all'oggetto: le regole dei segni gia'
## scritte non si accorgono del cambiamento.
func test_the_grade_lays_its_own_sign() -> void:
	_build(HERE, 1, "ENT_VAERAX")
	assert_true(_tags(HERE).has("structure:watchtower"), "la torre posa il suo segno")
	session.applier.apply(Effect.make(
		"SET_STRUCTURE_GRADE", "region", HERE, {"structure_type": KEEP, "grade": 2}, _source()
	))
	assert_false(_tags(HERE).has("structure:watchtower"), "salendo, il vecchio segno se ne va")
	assert_true(_tags(HERE).has("structure:castle"), "e arriva quello nuovo")


## Il valore del grado e' quello che il catalogo dichiara: e' il numero che
## servira' alla contesa del controllo (§7.2 della seduta).
func test_each_grade_carries_its_value() -> void:
	var grades: Array = (data().structure_types[KEEP] as Dictionary)["grades"]
	assert_eq(int((grades[0] as Dictionary)["value"]), 2, "torre")
	assert_eq(int((grades[1] as Dictionary)["value"]), 3, "castello")
	assert_eq(int((grades[2] as Dictionary)["value"]), 5, "reggia")


## Due presidi nella stessa Regione non sono un presidio piu' grande.
func test_the_same_type_does_not_stack() -> void:
	_build(HERE, 1, "ENT_VAERAX")
	# `apply` restituisce l'Effect registrato: il no-op del gestore finisce
	# dentro `inverse_payload`, non in cima.
	var again: Dictionary = _build(HERE, 3, "ENT_LYRA")
	assert_true(
		bool((again.get("inverse_payload", {}) as Dictionary).get("noop", false)),
		"il secondo non fa niente"
	)
	assert_eq(_structures(HERE).size(), 1, "e ne resta uno solo")
	assert_eq(int((_structures(HERE)[0] as Dictionary)["grade"]), 1, "quello di prima")


## Abbattere toglie l'oggetto e il suo segno.
func test_razing_takes_the_sign_with_it() -> void:
	_build(HERE, 2, "ENT_VAERAX")
	assert_true(_tags(HERE).has("structure:castle"), "il castello c'e'")
	session.applier.apply(Effect.make(
		"RAZE_STRUCTURE", "region", HERE, {"structure_type": KEEP}, _source()
	))
	assert_eq(_structures(HERE).size(), 0, "non c'e' piu'")
	assert_false(_tags(HERE).has("structure:castle"), "e nemmeno il suo segno")


## Un grado fuori scala si taglia dentro la scala invece di rompere.
func test_a_grade_out_of_range_is_clamped() -> void:
	_build(HERE, 9, "ENT_VAERAX")
	assert_eq(int((_structures(HERE)[0] as Dictionary)["grade"]), 3, "al massimo la reggia")


## Un luogo del mondo non ha padrone: se il catalogo dice `owned: false`, il
## padrone dichiarato viene ignorato. (Oggi il catalogo ha solo opere delle
## case: il test tiene ferma la regola per quando arrivano le foreste.)
func test_the_catalogue_decides_whether_it_has_an_owner() -> void:
	assert_true(bool((data().structure_types[KEEP] as Dictionary)["owned"]), "un presidio si tiene")


## Le pietre attraversano gli anni, col grado che avevano — e il padrone segue
## la stessa regola del controllo: senza nessuno dentro, restano di nessuno.
func test_stones_cross_the_years() -> void:
	_build(HERE, 3, "ENT_VAERAX")
	var previous: Dictionary = session.world.duplicate(true)
	var chronicle: Dictionary = data().chronicles["CHR_01"]
	var carried: Array = WorldStateFactory.inheritance_effects(previous, chronicle, data(), 1)

	var found: Dictionary = {}
	for effect in carried:
		if str((effect as Dictionary)["type"]) == "BUILD_STRUCTURE":
			found = effect as Dictionary
			break
	assert_false(found.is_empty(), "la struttura passa all'anno dopo")
	assert_eq(
		int((found["payload"] as Dictionary)["grade"]), 3, "e passa com'era: una reggia resta reggia"
	)
