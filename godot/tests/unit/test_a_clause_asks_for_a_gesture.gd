extends "res://tests/test_case.gd"
## **Il tempo del verbo** (D-386 — ISSUES 120, la cura chiesta dal committente).
##
## Tutte le diciotto forme del vocabolario guardavano **come sta il tavolo**.
## `did_this_year` guarda **cos'e' successo**: legge il verbale dell'anno — il
## registro degli Effetti, che ricomincia a ogni Chronicle — e cerca un gesto
## firmato dalla casa.
##
## **La trappola di casa**: una prova che chiede «hai alzato una Pietra?» a un
## verbale vuoto risponde no e passa sempre, anche col conto rotto. Quindi ogni
## caso qui sotto fabbrica la riga di verbale che **deve** far dire si', e poi
## prova la riga che deve far dire no.

const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")
const SchemaDefs := preload("res://scripts/core/schema_defs.gd")

var _seat: String = ""
var _conditions: RefCounted


func before_each() -> void:
	new_session()
	for entity_id in session.world["turn_order"]:
		_seat = str(entity_id)
		break
	_conditions = ConditionEvaluator.new(session.world, session.data)


## Una riga di verbale come la scrive il motore: firmata, non annullata.
func _entry(effect_type: String, target: Dictionary, payload: Dictionary,
		actor: String, kind: String = "action", inverse: Dictionary = {}) -> Dictionary:
	return {
		"effect_id": "EFF_TEST", "type": effect_type, "target": target,
		"payload": payload, "reversible": true, "inverse_payload": inverse,
		"source": {"kind": kind, "id": "PROVA", "actor": actor,
			"act": 1, "round": 1, "sequence": 1},
	}


func _clause(gesture: String, extra: Dictionary = {}) -> Dictionary:
	var out: Dictionary = {
		"type": "did_this_year", "entity_id": _seat, "gesture": gesture, "min": 1,
	}
	for key in extra:
		out[key] = extra[key]
	return out


func _write(entry: Dictionary) -> void:
	(session.world["effect_log"] as Array).append(entry)


## Il caso che deve dare vero.
func test_a_stone_you_raised_this_year_counts() -> void:
	assert_false(_conditions.holds(_clause("RAISE_STONE")), "il verbale si apre vuoto")
	_write(_entry("BUILD_STRUCTURE", {"kind": "region", "id": "REG_X"},
		{"structure_type": "STR_KEEP", "grade": 1}, _seat))
	assert_true(_conditions.holds(_clause("RAISE_STONE")), "e adesso la Pietra c'e'")


## E la stessa Pietra alzata da un altro non la conta a te.
func test_someone_elses_stone_does_not_count() -> void:
	var other: String = ""
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != _seat:
			other = str(entity_id)
			break
	assert_false(other.is_empty(), "al tavolo siede piu' di una casa")
	_write(_entry("BUILD_STRUCTURE", {"kind": "region", "id": "REG_X"},
		{"structure_type": "STR_KEEP", "grade": 1}, other))
	assert_false(_conditions.holds(_clause("RAISE_STONE")), "l'ha alzata un altro")


## **Quello che fa il calendario non e' un gesto**: il sistema firma col nome
## di una casa quando il mondo agisce su di lei, e quella riga non paga.
func test_the_calendar_is_not_a_gesture() -> void:
	_write(_entry("BUILD_STRUCTURE", {"kind": "region", "id": "REG_X"},
		{"structure_type": "STR_KEEP", "grade": 1}, _seat, "system"))
	assert_false(_conditions.holds(_clause("RAISE_STONE")), "l'ha alzata l'anno, non lei")
	_write(_entry("BUILD_STRUCTURE", {"kind": "region", "id": "REG_Y"},
		{"structure_type": "STR_KEEP", "grade": 1}, _seat, "confluence"))
	assert_true(
		_conditions.holds(_clause("RAISE_STONE")),
		"ma la proposta che ha portato lei si'"
	)


## Un Effetto che non ha cambiato niente non e' un gesto.
func test_an_effect_that_changed_nothing_is_not_a_gesture() -> void:
	_write(_entry("SET_CONTROL", {"kind": "region", "id": "REG_X"},
		{"entity_id": _seat}, _seat, "action", {"entity_id": _seat, "noop": true}))
	assert_false(_conditions.holds(_clause("TAKE_GROUND")), "il trono non si e' mosso")


## Solo verso l'alto: scendere di un gradino non e' stringere.
func test_a_bond_only_counts_upward() -> void:
	var other: String = ""
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != _seat:
			other = str(entity_id)
			break
	var key: String = "%s|%s" % [_seat, other] if _seat < other else "%s|%s" % [other, _seat]
	_write(_entry("SET_RELATION", {"kind": "relation", "id": key},
		{"level": "HOSTILE"}, _seat, "action", {"level": "NEUTRAL"}))
	assert_false(_conditions.holds(_clause("TIGHTEN_BOND")), "scendere non e' stringere")
	_write(_entry("SET_RELATION", {"kind": "relation", "id": key},
		{"level": "ALLY"}, _seat, "action", {"level": "NEUTRAL"}))
	assert_true(_conditions.holds(_clause("TIGHTEN_BOND")), "salire si'")


## Una Pietra puo' chiedere **quale** Pietra, come fa `structure_count`.
func test_a_gesture_can_name_the_family() -> void:
	var opera: String = ""
	var altra: String = ""
	for type_id in (session.data.structure_types as Dictionary):
		var family: String = str(
			(session.data.structure_types[str(type_id)] as Dictionary).get("family", "")
		)
		if family == "OPERA" and opera == "":
			opera = str(type_id)
		elif family != "OPERA" and altra == "":
			altra = str(type_id)
	assert_false(opera.is_empty(), "nel parco c'e' almeno un'opera")
	assert_false(altra.is_empty(), "e almeno una Pietra che opera non e'")
	var clause: Dictionary = _clause("RAISE_STONE", {"structure_family": "OPERA"})
	_write(_entry("BUILD_STRUCTURE", {"kind": "region", "id": "REG_X"},
		{"structure_type": altra, "grade": 1}, _seat))
	assert_false(_conditions.holds(clause), "quella non e' un'opera")
	_write(_entry("BUILD_STRUCTURE", {"kind": "region", "id": "REG_Y"},
		{"structure_type": opera, "grade": 1}, _seat))
	assert_true(_conditions.holds(clause), "questa si'")


## Il vocabolario dei gesti e' chiuso, e le due liste devono essere la stessa:
## quella dello schema, e quella che il valutatore sa riconoscere. Una prova
## che le confronta senza fabbricare il caso passerebbe a lista vuota.
func test_every_gesture_in_the_schema_can_be_recognised() -> void:
	assert_false((SchemaDefs.GESTURES as Array).is_empty(), "la lista non e' vuota")
	var righe: Dictionary = {
		"RAISE_STONE": _entry("BUILD_STRUCTURE", {"kind": "region", "id": "REG_X"},
			{"structure_type": "STR_KEEP", "grade": 1}, _seat),
		"TAKE_GROUND": _entry("SET_CONTROL", {"kind": "region", "id": "REG_X"},
			{"entity_id": _seat}, _seat, "action", {"entity_id": null}),
		"SPREAD": _entry("ADD_PRESENCE", {"kind": "entity", "id": _seat},
			{"region_id": "REG_X"}, _seat),
		"TIGHTEN_BOND": _entry("SET_RELATION", {"kind": "relation", "id": "%s|ZZZ" % _seat},
			{"level": "ALLY"}, _seat, "action", {"level": "NEUTRAL"}),
	}
	for gesture in SchemaDefs.GESTURES:
		assert_true(
			righe.has(str(gesture)),
			"il gesto «%s» ha una riga di verbale che lo accende" % str(gesture)
		)
		(session.world["effect_log"] as Array).clear()
		_write(righe[str(gesture)] as Dictionary)
		assert_true(
			_conditions.holds(_clause(str(gesture))),
			"e il valutatore lo riconosce: %s" % str(gesture)
		)


## E gli obiettivi che il committente ha voluto riscrivere chiedono davvero un
## gesto: una prova che li conta senza sapere quali sono passerebbe a zero.
func test_the_six_objectives_ask_for_a_gesture() -> void:
	var voluti: Array = [
		"OBJ_A_STONE", "OBJ_A_WORK", "OBJ_MOST_STONE",
		"OBJ_THE_LONGEST_REACH", "OBJ_THE_WIDEST_SPREAD", "OBJ_BOUND_HOUSE",
	]
	for objective_id in voluti:
		var objective: Variant = (session.data.objectives as Dictionary).get(str(objective_id))
		assert_true(objective != null, "%s esiste" % str(objective_id))
		var chiede: bool = false
		for clause in ((objective as Dictionary)["conditions"] as Array):
			if str((clause as Dictionary).get("type", "")) == "did_this_year":
				chiede = true
		assert_true(chiede, "%s chiede un gesto" % str(objective_id))
