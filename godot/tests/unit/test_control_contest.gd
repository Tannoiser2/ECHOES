extends "res://tests/test_case.gd"
## La contesa del controllo (D-158), §7.2 della seduta sulla terra.
##
## Il padrone di una Regione non e' piu' **scritto** da una Conseguenza: e'
## **contato**. Chi somma di piu' fra il valore delle proprie strutture e le
## proprie pedine la tiene, e il conto si rifa' a ogni fine round.
##
## «Se una entita' ha un castello (che magari vale 3) ma un'altra ha un esercito
## che occupa la regione (che vale 4) la regione viene controllata da chi ha di
## piu'» — le due monete sono diverse e si sommano nella stessa colonna.

const Effect := preload("res://scripts/core/effect.gd")

const KEEP: String = "STR_KEEP"
const HERE: String = "REG_MINIERE_ANTICHE"


func before_each() -> void:
	new_session()
	_clear(HERE)


func _source() -> Dictionary:
	return {"kind": "TEST", "id": "contest"}


## Svuotare vuol dire **svuotare**: le pedine e le pietre.
##
## Fino alla 0.1.185 questa funzione toglieva solo le pedine, e andava bene per
## un motivo che nessuno aveva scritto — sulle Miniere Antiche non apriva
## nessuno con una struttura. Il giorno in cui Lyra ha aperto con un Archivio
## (D-217) otto prove di questo file sono andate rosse contando **uno in piu'**,
## e avevano ragione: dichiaravano di partire da una Regione vuota e partivano
## da una Regione con dentro qualcosa. E' la lezione di D-184 un'altra volta —
## una prova deve azzerare quello che il setup ha gia' distribuito, non solo la
## meta' che si ricorda.
func _clear(region_id: String) -> void:
	for entity_id in session.world["turn_order"]:
		var seat: String = str(entity_id)
		for _i in range(session.service.presence_count(seat, region_id)):
			session.applier.apply(Effect.make(
				"REMOVE_PRESENCE", "entity", seat, {"region_id": region_id}, _source()
			))
	var standing: Array = (
		(session.world["regions"][region_id] as Dictionary).get("structures", []) as Array
	).duplicate(true)
	for structure in standing:
		session.applier.apply(Effect.make(
			"RAZE_STRUCTURE", "region", region_id,
			{"structure_type": str((structure as Dictionary)["structure_type"])}, _source()
		))


func _stand(seat: String, region_id: String, tokens: int) -> void:
	for _i in range(tokens):
		session.applier.apply(Effect.make(
			"ADD_PRESENCE", "entity", seat, {"region_id": region_id}, _source()
		))


func _build(seat: String, region_id: String, grade: int) -> void:
	session.applier.apply(Effect.make(
		"BUILD_STRUCTURE", "region", region_id,
		{"structure_type": KEEP, "grade": grade, "owner": seat}, _source()
	))


## Le pedine e le pietre si sommano nella stessa colonna.
func test_stones_and_pawns_add_up() -> void:
	_stand("ENT_LYRA", HERE, 2)
	assert_eq(session.service.control_strength("ENT_LYRA", HERE), 2, "due pedine, due")
	_build("ENT_LYRA", HERE, 2)
	assert_eq(
		session.service.control_strength("ENT_LYRA", HERE), 5, "piu' un castello (3): cinque"
	)


## L'esempio del committente: castello 3 contro esercito 4, vince l'esercito.
func test_the_castle_loses_to_the_bigger_army() -> void:
	_build("ENT_LYRA", HERE, 2)
	_stand("ENT_VAERAX", HERE, 4)
	assert_eq(session.service.control_strength("ENT_LYRA", HERE), 3, "il castello vale 3")
	assert_eq(session.service.control_strength("ENT_VAERAX", HERE), 4, "l'esercito vale 4")
	assert_eq(
		str(session.service.strongest_in(HERE)["entity_id"]), "ENT_VAERAX", "vince chi ha di piu'"
	)


## A parita' non cambia niente: per togliere una Regione bisogna **superare**
## chi la tiene, non pareggiarlo.
func test_a_tie_changes_nothing() -> void:
	session.applier.apply(Effect.make(
		"SET_CONTROL", "region", HERE, {"entity_id": "ENT_LYRA"}, _source()
	))
	_stand("ENT_LYRA", HERE, 2)
	_stand("ENT_VAERAX", HERE, 2)
	assert_true(bool(session.service.strongest_in(HERE)["tied"]), "e' un pareggio")
	assert_eq(
		str(session.service.rightful_holder(HERE)), "ENT_LYRA", "chi ce l'ha se la tiene"
	)


## Una Regione dove non c'e' nessuno non e' di nessuno.
func test_an_empty_region_answers_to_nobody() -> void:
	assert_eq(session.service.rightful_holder(HERE), null, "senza nessuno dentro, nessun padrone")


## Il valore di una struttura conta solo per il suo padrone.
func test_a_structure_counts_only_for_its_holder() -> void:
	_build("ENT_LYRA", HERE, 3)
	assert_eq(session.service.control_strength("ENT_LYRA", HERE), 5, "la reggia vale 5")
	assert_eq(session.service.control_strength("ENT_VAERAX", HERE), 0, "e non vale per gli altri")


## Il peso della pedina lo dichiara la Chronicle: a zero contano solo le pietre.
func test_the_pawn_weight_comes_from_the_data() -> void:
	var chronicle: Dictionary = data().chronicles[str(session.world["chronicle_id"])]
	var rules: Dictionary = (chronicle["control_rules"] as Dictionary)["contested"]
	var before: int = int(rules.get("presence_weight", 1))
	_stand("ENT_LYRA", HERE, 3)
	assert_eq(session.service.control_strength("ENT_LYRA", HERE), 3 * before, "tre pedine")
	rules["presence_weight"] = 0
	assert_eq(session.service.control_strength("ENT_LYRA", HERE), 0, "a peso zero, le pedine no")
	rules["presence_weight"] = before


## Spenta nei dati, la contesa non esiste e il padrone resta quello scritto.
func test_off_the_written_holder_stands() -> void:
	var chronicle: Dictionary = data().chronicles[str(session.world["chronicle_id"])]
	var rules: Dictionary = (chronicle["control_rules"] as Dictionary)["contested"]
	assert_true(session.service.contest_is_on(), "qui e' accesa")
	(chronicle["control_rules"] as Dictionary).erase("contested")
	assert_false(session.service.contest_is_on(), "e spenta si spegne")
	(chronicle["control_rules"] as Dictionary)["contested"] = rules
