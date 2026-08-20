extends "res://tests/test_case.gd"
## Il Destino come una serie di condizioni, con una scelta dentro (D-167).
##
## «I destini li farei diversi, una serie di condizioni che se soddisfatte danno
## il grado di vittoria. E tra le condizioni ci puo' essere le cose piu'
## disparate includendo anche gli edifici e/o il controllo e/o le cicatrici.»
##
## Il vocabolario c'era da D-161 e nessun Destino lo usava. Quello che mancava
## era la **forma**: un livello non e' piu' una lista da soddisfare per intero,
## ma una spina - quello che quella casa voleva davvero - e una scelta fra
## strade, di cui ne servono alcune e non tutte.
##
## Tre cose si rompono in silenzio quando si sposta una clausola dentro una
## scelta, e sono i tre test qui sotto.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Effect := preload("res://scripts/core/effect.gd")

const VAERAX: String = "ENT_VAERAX"


func before_each() -> void:
	new_session()


func _apply(type: String, kind: String, id: String, payload: Dictionary) -> void:
	session.applier.apply(
		Effect.make(type, kind, id, payload, Effect.source("developer", "TEST", "", 3, 3, 0))
	)


## Porta una Tensione al valore che serve, con un Effect vero: i valori di
## partenza sono contenuto e cambiano, il caso di prova no.
func _heat(tension_id: String, target: int) -> void:
	var current: int = int(session.world["tensions"][tension_id]["current_value"])
	if current != target:
		_apply("ADJUST_TENSION", "tension", tension_id, {"delta": target - current})


func _choice(min_roads: int) -> Dictionary:
	return {
		"type": "some_of",
		"min": min_roads,
		"label": "almeno %d" % min_roads,
		"conditions": [
			{"type": "tension_limit", "tension_id": "TEN_ROADS", "min": 3, "label": "strade dure"},
			{"type": "tension_limit", "tension_id": "TEN_FAMINE", "min": 3, "label": "fame alta"},
			{"type": "control_count", "entity_id": VAERAX, "min": 3, "label": "tre Regioni"},
		],
	}


## Il conto: `min` strade su quante ce ne sono, e non una di meno.
func test_a_choice_holds_at_the_count_it_asks_for() -> void:
	_heat("TEN_ROADS", 3)
	_heat("TEN_FAMINE", 1)
	var judge: RefCounted = session.destinies.conditions
	assert_true(judge.holds(_choice(1)), "una strada aperta basta a una scelta da uno")
	assert_false(judge.holds(_choice(2)), "ma non a una che ne chiede due")
	_heat("TEN_FAMINE", 3)
	assert_true(judge.holds(_choice(2)), "aperta la seconda, la scelta da due tiene")
	assert_false(judge.holds(_choice(3)), "e la terza chiede tre Regioni, che non ha")


## La prova si legge. «Tre di queste cinque» non dice niente se non si vede
## quali sono le cinque e quali tre hai preso: e' lo stesso difetto che il
## committente ha trovato nelle carte, sul foglio che conta di piu'.
func test_the_evidence_opens_the_choice_road_by_road() -> void:
	_heat("TEN_ROADS", 3)
	_heat("TEN_FAMINE", 1)
	var lines: Array = session.destinies.conditions.describe_all(_choice(2))
	assert_eq(lines.size(), 4, "la riga della scelta piu' una per strada")
	assert_true(str(lines[0]).begins_with("[ ]"), "la scelta da due non tiene")
	assert_true(str(lines[1]).begins_with("  [x]"), "e la strada presa si vede, rientrata")
	assert_true(str(lines[2]).begins_with("  [ ]"), "come quella lasciata")


## **Il difetto che questa seduta ha quasi introdotto.** Un seggio legge il
## proprio Destino per sapere cosa vuole, e quella lettura guarda il *tipo*
## della clausola. Una clausola dentro una scelta ha per tipo `some_of`: se la
## lettura si ferma al primo livello, meta' delle ambizioni del tavolo
## spariscono senza che niente segnali l'errore — che e' esattamente D-066, in
## cui l'80% dei seggi valutava una proposta zero.
func test_a_seat_still_sees_what_it_wants_from_inside_a_choice() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	var wanted: Array = policy._conditions(VAERAX, session)
	var found: bool = false
	for condition in wanted:
		assert_ne(
			str((condition as Dictionary).get("type", "")), "some_of",
			"nessuna scelta resta chiusa nella lista degli obiettivi"
		)
		if (
			str((condition as Dictionary).get("type", "")) == "tension_limit"
			and str((condition as Dictionary).get("tension_id", "")) == "TEN_ROADS"
		):
			found = true
	assert_true(found, "la clausola sulle Vie Interrotte e' dentro la scelta del Trionfo, e si vede")

	# E si vede dove conta: una spinta su quella Tensione ha un prezzo.
	var push: Dictionary = {
		"type": "ADJUST_TENSION",
		"target": {"kind": "tension", "id": "TEN_ROADS"},
		"payload": {"delta": 1},
	}
	assert_ne(
		policy._score_effect(push, VAERAX, "ENT_ALDRIC", {}, session, {}), 0,
		"e vale un'opinione al tavolo, non zero"
	)


## E i conti rimasti aperti (D-087) devono dire **quali strade** sono cadute,
## non «tre di queste cinque». E' la meta' strutturata delle evidence, quella
## che l'era dopo eredita: una scelta opaca la renderebbe cieca proprio dove
## D-167 ha spostato meta' delle clausole.
func test_the_open_accounts_name_the_roads_that_fell() -> void:
	_heat("TEN_ROADS", 3)
	_heat("TEN_FAMINE", 1)
	var fallen: Array = session.destinies.conditions.open_roads(_choice(2))
	assert_eq(fallen.size(), 2, "due strade su tre non hanno retto")
	for road in fallen:
		assert_ne(
			str((road as Dictionary).get("label", "")), "strade dure",
			"e quella che ha retto non e' un conto aperto"
		)
	assert_true(
		session.destinies.conditions.open_roads(
			{"type": "control_count", "entity_id": VAERAX, "min": 9}
		).is_empty(),
		"una clausola semplice non ha strade da aprire"
	)
