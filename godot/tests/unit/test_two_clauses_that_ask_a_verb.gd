extends "res://tests/test_case.gd"
## Le due clausole nuove di [D-255](DECISIONS.md#d-255), provate una per una.
##
## Servono a dire una cosa che il vocabolario delle condizioni non sapeva dire:
## **«tieni alta una questione, non importa quale»** e **«allèati con qualcuno,
## non importa con chi»**. Senza quel «non importa quale» un obiettivo del mazzo
## comune non puo' nominare niente — la Chronicle pesca le sue Tensioni da un
## pool e le sue case da un altro — e il risultato misurato era che INFLUENZARE
## e FORGIARE non comparivano in **nessuna** clausola di nessun obiettivo.
##
## Un predicato scritto male non alza un errore: torna `false` per sempre, e un
## obiettivo che non si avvera mai assomiglia in tutto a un obiettivo difficile.
## Quindi si prova nei due versi: che dica di si' quando deve, e di no quando
## deve.

const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")
const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")


func before_each() -> void:
	new_session()


func _conditions() -> RefCounted:
	return ConditionEvaluator.new(session.world, data())


func _set_tension(tension_id: String, value: int) -> void:
	var now: int = session.tensions.value(tension_id)
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", tension_id, {"delta": value - now},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))


# --- tension_count ---------------------------------------------------------

## Le questioni alte si contano, e il conto e' quello vero.
func test_it_counts_the_questions_that_are_high() -> void:
	var ids: Array = []
	for tension_id in session.world["tensions"]:
		ids.append(str(tension_id))
	ids.sort()
	assert_true(ids.size() >= 3, "il tavolo ha almeno tre questioni")
	for tension_id in ids:
		_set_tension(str(tension_id), 0)

	var clause: Dictionary = {"type": "tension_count", "at_or_above": 4, "min": 2}
	assert_false(_conditions().holds(clause), "con tutte a zero, nessuna e' alta")

	_set_tension(str(ids[0]), 4)
	assert_false(_conditions().holds(clause), "una sola alta non basta")
	_set_tension(str(ids[1]), 5)
	assert_true(_conditions().holds(clause), "due alte bastano")
	_set_tension(str(ids[0]), 3)
	assert_false(_conditions().holds(clause), "scesa sotto la soglia, non conta piu'")


## E dall'altra parte della soglia, che e' il verso che il mondo percorre da
## solo: all'apertura sono tutte basse, ed e' la ragione per cui l'obiettivo
## spedito chiede il verso opposto.
func test_it_counts_the_questions_that_are_low() -> void:
	var ids: Array = []
	for tension_id in session.world["tensions"]:
		ids.append(str(tension_id))
	ids.sort()
	for tension_id in ids:
		_set_tension(str(tension_id), 9)
	var clause: Dictionary = {"type": "tension_count", "at_or_below": 2, "min": 1}
	assert_false(_conditions().holds(clause), "con tutte in alto, nessuna e' bassa")
	_set_tension(str(ids[0]), 1)
	assert_true(_conditions().holds(clause), "una tenuta giu' basta")


## `max` funziona come in ogni altro conteggio del vocabolario: «non piu' di».
func test_the_clause_can_ask_for_quiet_too() -> void:
	var ids: Array = []
	for tension_id in session.world["tensions"]:
		ids.append(str(tension_id))
	ids.sort()
	for tension_id in ids:
		_set_tension(str(tension_id), 0)
	var clause: Dictionary = {"type": "tension_count", "at_or_above": 4, "max": 0}
	assert_true(_conditions().holds(clause), "niente di alto: la quiete regge")
	_set_tension(str(ids[0]), 6)
	assert_false(_conditions().holds(clause), "una sola alta rompe la quiete")


# --- relation_state con $any -----------------------------------------------

## «Con qualcuno» e' vero appena uno risponde, e falso finche' non risponde
## nessuno.
func test_an_alliance_with_anyone_at_all() -> void:
	var clause: Dictionary = {
		"type": "relation_state", "entity_id": "$self", "other_entity_id": "$any",
		"level": "ALLY", "at_least": true,
	}
	var context: Dictionary = {"self": "ENT_ALDRIC"}
	var others: Array = []
	for entity_id in session.world["entities"]:
		if str(entity_id) != "ENT_ALDRIC":
			others.append(str(entity_id))
	others.sort()
	for other_id in others:
		session.applier.apply(Effect.make(
			"SET_RELATION", "relation", Ids.relation_key("ENT_ALDRIC", str(other_id)),
			{"level": "NEUTRAL"}, Effect.source("system", "TEST", "", 1, 1, 0)
		))
	assert_false(_conditions().holds(clause, context), "nessuno risponde: e' falsa")

	session.applier.apply(Effect.make(
		"SET_RELATION", "relation", Ids.relation_key("ENT_ALDRIC", str(others[0])),
		{"level": "ALLY"}, Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_true(_conditions().holds(clause, context), "uno solo basta")


## E che «almeno ALLY» voglia dire davvero almeno: chi e' legato conta.
func test_bound_counts_as_at_least_allied() -> void:
	var clause: Dictionary = {
		"type": "relation_state", "entity_id": "$self", "other_entity_id": "$any",
		"level": "ALLY", "at_least": true,
	}
	var others: Array = []
	for entity_id in session.world["entities"]:
		if str(entity_id) != "ENT_ALDRIC":
			others.append(str(entity_id))
	others.sort()
	for other_id in others:
		session.applier.apply(Effect.make(
			"SET_RELATION", "relation", Ids.relation_key("ENT_ALDRIC", str(other_id)),
			{"level": "HOSTILE"}, Effect.source("system", "TEST", "", 1, 1, 0)
		))
	assert_false(_conditions().holds(clause, {"self": "ENT_ALDRIC"}), "ostili: falsa")
	session.applier.apply(Effect.make(
		"SET_RELATION", "relation", Ids.relation_key("ENT_ALDRIC", str(others[0])),
		{"level": "BOUND"}, Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_true(
		_conditions().holds(clause, {"self": "ENT_ALDRIC"}),
		"legato e' piu' che alleato, quindi vale"
	)


## Una clausola che nomina l'altro **non** deve diventare «con chiunque»: se
## `$any` allargasse anche quelle, ogni Destino del gioco cambierebbe di
## significato in silenzio.
func test_naming_the_other_still_means_that_one() -> void:
	var others: Array = []
	for entity_id in session.world["entities"]:
		if str(entity_id) != "ENT_ALDRIC":
			others.append(str(entity_id))
	others.sort()
	assert_true(others.size() >= 2, "al tavolo c'e' piu' di un'altra casa")
	for other_id in others:
		session.applier.apply(Effect.make(
			"SET_RELATION", "relation", Ids.relation_key("ENT_ALDRIC", str(other_id)),
			{"level": "NEUTRAL"}, Effect.source("system", "TEST", "", 1, 1, 0)
		))
	session.applier.apply(Effect.make(
		"SET_RELATION", "relation", Ids.relation_key("ENT_ALDRIC", str(others[0])),
		{"level": "BOUND"}, Effect.source("system", "TEST", "", 1, 1, 0)
	))
	var named: Dictionary = {
		"type": "relation_state", "entity_id": "$self",
		"other_entity_id": str(others[1]), "level": "ALLY", "at_least": true,
	}
	assert_false(
		_conditions().holds(named, {"self": "ENT_ALDRIC"}),
		"l'alleanza con l'uno non vale per l'altro"
	)
