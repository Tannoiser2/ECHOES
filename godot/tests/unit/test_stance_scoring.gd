extends "res://tests/test_case.gd"
## Cosa un seggio riesce a vedere di una proposta (D-066).
##
## La sonda delle posizioni aveva misurato la cosa peggiore che si potesse
## misurare: su 40 Chronicle **l'80% dei seggi valutava una proposta esattamente
## zero**. Non indifferenza scritta nel contenuto - indifferenza del codice, che
## di quello che la proposta faceva vedeva solo una parte.
##
## Due buchi, e questi test li tengono chiusi:
##
## 1. `SET_RELATION` non aveva nessun ramo. Letto 126 volte, pesato zero: chi
##    Forgia un rapporto - una delle sei azioni - lo faceva in una lingua che
##    nessuno leggeva.
## 2. Una clausola `min` su una Tensione era cieca a tutto quello che non le
##    passava sopra la soglia, mentre `max` aveva il suo ripiego dentro la banda.
##    Chi ha bisogno che una domanda resti calda non aveva niente da dire finche'
##    non gliela spegnevano del tutto.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Effect := preload("res://scripts/core/effect.gd")

const VAERAX: String = "ENT_VAERAX"
const LYRA: String = "ENT_LYRA"
const ALDRIC: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


func _policy() -> RefCounted:
	return PolicyDecider.new(session.log)


func _score(effect: Dictionary, entity_id: String, proponent_id: String = ALDRIC) -> int:
	return _policy()._score_effect(effect, entity_id, proponent_id, {}, session, {})


## Porta una Tensione al valore che serve al caso, con un Effect vero.
func _heat(tension_id: String, target: int) -> void:
	var current: int = int(session.world["tensions"][tension_id]["current_value"])
	if current == target:
		return
	session.applier.apply(
		Effect.make(
			"ADJUST_TENSION",
			"tension",
			tension_id,
			{"delta": target - current},
			{"kind": "TEST", "id": "heat"}
		)
	)


func _relation_effect(pair: String, payload: Dictionary) -> Dictionary:
	return {"type": "SET_RELATION", "target": {"kind": "relation", "id": pair}, "payload": payload}


func _tension_effect(tension_id: String, delta: int) -> Dictionary:
	return {
		"type": "ADJUST_TENSION",
		"target": {"kind": "tension", "id": tension_id},
		"payload": {"delta": delta},
	}


## Il Destino che nomina qualcuno: il Sonno Sorvegliato vuole Lyra almeno
## alleata. Un rapporto che scende sotto quella soglia deve costare.
func test_a_relation_that_breaks_a_clause_costs() -> void:
	session.world["entities"][VAERAX]["destiny_id"] = "DST_VAERAX_WATCHED"
	var pair: String = "%s|%s" % [VAERAX, LYRA]
	assert_true(
		_score(_relation_effect(pair, {"level": "ENEMY"}), VAERAX) < 0,
		"farsi nemica Lyra vale un no"
	)
	assert_true(
		_score(_relation_effect(pair, {"level": "ALLY"}), VAERAX) > 0,
		"e portarla dalla propria parte vale un si"
	)


## Un rapporto fra altri due non e' affar mio. Il tavolo ha quattro seggi e
## quasi meta' delle coppie non mi tocca: senza questo, ogni SET_RELATION
## avrebbe spostato il punteggio di tutti.
func test_a_relation_between_other_people_is_worth_nothing() -> void:
	session.world["entities"][VAERAX]["destiny_id"] = "DST_VAERAX_WATCHED"
	assert_eq(
		_score(_relation_effect("%s|%s" % [ALDRIC, LYRA], {"level": "ENEMY"}), VAERAX), 0,
		"il rapporto fra Aldric e Lyra non e una cosa sua"
	)


## Senza una clausola che nomini qualcuno, un rapporto **con me** che scende
## costa comunque un punto (D-456): un alleato in meno e' una mano in meno al
## Consiglio. Fino alla 0.1.424 valeva zero, e la sedia non leggeva la mappa.
func test_without_a_relation_clause_a_bond_with_me_still_weighs() -> void:
	assert_eq(
		_score(_relation_effect("%s|%s" % [VAERAX, LYRA], {"level": "ENEMY"}), VAERAX), -1,
		"un rapporto con me che scende costa un punto anche senza clausola"
	)
	assert_eq(
		_score(_relation_effect("%s|%s" % [VAERAX, LYRA], {"level": "ALLY"}), VAERAX), 1,
		"e uno che sale ne rende uno"
	)


## Il ramo che mancava. Vaerax vuole le Vie Interrotte da 3 in su - salire fin
## lassu non dev'essere facile per nessuno - e una spinta verso il basso che
## **non** scende sotto 3 deve comunque costargli qualcosa.
func test_a_floor_clause_sees_a_push_that_does_not_cross_it() -> void:
	# Le Vie Interrotte partono da 1: portate a 5, cosi' una spinta di un passo
	# resta dentro la banda invece di attraversare la soglia. E' proprio il caso
	# che prima non veniva letto.
	_heat("TEN_ROADS", 5)
	assert_eq(session.tensions.value("TEN_ROADS"), 5, "la domanda e alta e la soglia e 3")
	var inside: int = _score(_tension_effect("TEN_ROADS", -1), VAERAX)
	assert_true(inside < 0, "una spinta verso il basso dentro la banda vale un'obiezione")
	assert_true(
		_score(_tension_effect("TEN_ROADS", 1), VAERAX) > 0,
		"e una che allontana dalla soglia vale un si"
	)


## E i due versi restano opposti sulla stessa domanda: e' quello che rende un
## Consiglio una scena invece che un atto notarile. Lyra vuole la stessa
## Tensione **sotto** 4.
func test_the_same_push_reads_opposite_at_two_seats() -> void:
	_heat("TEN_ROADS", 4)
	var push: Dictionary = _tension_effect("TEN_ROADS", 1)
	var watcher: int = _score(push, VAERAX)
	var scholar: int = _score(push, LYRA)
	assert_ne(watcher, 0, "la spinta tocca chi vuole la strada difficile")
	assert_ne(scholar, 0, "e tocca chi la vuole aperta")
	assert_true(watcher > 0 and scholar < 0, "e li tocca in due versi opposti")

