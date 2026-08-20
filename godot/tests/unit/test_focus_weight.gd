extends "res://tests/test_case.gd"
## Il peso della terra al Consiglio (D-154).
##
## Il meccanismo c'e' ed e' provato qui; **nelle Chronicle e' spento**, perche'
## acceso ha misurato 1 seggio su 8 bloccato al tavolo misto e il vincolo di
## casa e' 0 su 8. Per questo i test si costruiscono una `focus_weight`
## sintetica invece di leggere quella dei dati: quello che si tiene fermo e' il
## meccanismo, non la scelta di accenderlo.

const Effect := preload("res://scripts/core/effect.gd")

const TENSION: String = "TEN_FAMINE"
const RULES: Dictionary = {
	"control": 1,
	"majority": 1,
	"max": 2,
	"commits_at_least": 1,
	"includes_proponent": true,
	"sides": ["SUPPORT", "OPPOSE"],
}


func before_each() -> void:
	new_session()


func after_each() -> void:
	# `_chronicle` e' un riferimento dentro al DataSet condiviso fra i test: la
	# regola sintetica va tolta, o il prossimo test la troverebbe accesa.
	var chronicle: Dictionary = data().chronicles[str(session.world["chronicle_id"])]
	(chronicle["confluence_rules"] as Dictionary).erase("focus_weight")


func _turn_on(overrides: Dictionary = {}) -> void:
	var rules: Dictionary = RULES.duplicate(true)
	for key in overrides:
		rules[str(key)] = overrides[key]
	var chronicle: Dictionary = data().chronicles[str(session.world["chronicle_id"])]
	(chronicle["confluence_rules"] as Dictionary)["focus_weight"] = rules


func _open() -> String:
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	return "" if context.is_empty() else str(context.get("focus_region", ""))


## Impegna una carta qualsiasi per quel seggio: il peso non conta finche' non
## c'e' niente sul tavolo, e i test che misurano il peso devono superarlo.
func _commit(seat: String) -> void:
	session.confluence.current["commits"][seat] = ["AST_FORCE_LEVY"]


func _hand_region_to(seat: String, region_id: String) -> void:
	session.applier.apply(Effect.make(
		"SET_CONTROL", "region", region_id, {"entity_id": seat}, {"kind": "TEST", "id": "control"}
	))


func _stand(seat: String, region_id: String, tokens: int) -> void:
	for _i in range(tokens):
		session.applier.apply(Effect.make(
			"ADD_PRESENCE", "entity", seat, {"region_id": region_id},
			{"kind": "TEST", "id": "stand"}
		))


func _clear_region(region_id: String) -> void:
	for entity_id in session.world["turn_order"]:
		var seat: String = str(entity_id)
		for _i in range(session.service.presence_count(seat, region_id)):
			session.applier.apply(Effect.make(
				"REMOVE_PRESENCE", "entity", seat, {"region_id": region_id},
				{"kind": "TEST", "id": "clear"}
			))


## Spento nei dati, il Consiglio e' quello di sempre: e' il comportamento fino
## a 0.1.118, ed e' quello che gira oggi.
func test_off_by_default_the_ground_weighs_nothing() -> void:
	var region_id: String = _open()
	assert_ne(region_id, "", "la Confluence si apre e dichiara la Regione a fuoco")
	var seat: String = str(session.confluence.current["proponent"])
	_commit(seat)
	_hand_region_to(seat, region_id)
	assert_eq(
		int(session.confluence._focus_weight(seat, "SUPPORT")["delta"]),
		0,
		"senza focus_weight nei dati la terra non pesa"
	)


## Il titolo che si sente al tavolo: chi la Regione a fuoco la tiene.
func test_the_title_weighs_for_who_holds_the_focus_region() -> void:
	var region_id: String = _open()
	_turn_on()
	var seat: String = str(session.confluence.current["proponent"])
	_commit(seat)
	_clear_region(region_id)
	_hand_region_to(seat, region_id)
	assert_eq(
		int(session.confluence._focus_weight(seat, "SUPPORT")["delta"]),
		1,
		"chi la tiene parla piu' forte di uno che ne discute da fuori"
	)


## La maggioranza e' *stretta*: a parita' non la prende nessuno, perche' una
## maggioranza contesa non e' una maggioranza.
func test_the_majority_is_strict() -> void:
	var region_id: String = _open()
	_turn_on()
	var seats: Array = (session.world["turn_order"] as Array).duplicate()
	var mine: String = str(seats[0])
	var rival: String = str(seats[1])
	_commit(mine)
	_commit(rival)
	_clear_region(region_id)

	_stand(mine, region_id, 1)
	_stand(rival, region_id, 1)
	assert_eq(
		int(session.confluence._focus_weight(mine, "SUPPORT")["delta"]),
		0,
		"a parita' di pedine la maggioranza non e' di nessuno"
	)

	_stand(mine, region_id, 1)
	assert_eq(
		int(session.confluence._focus_weight(mine, "SUPPORT")["delta"]),
		1,
		"una pedina in piu' e la maggioranza c'e'"
	)
	assert_eq(
		int(session.confluence._focus_weight(rival, "SUPPORT")["delta"]),
		0,
		"e l'altro non la prende"
	)


## Tenerla *e* starci dentro si somma, fino al tetto: e' `lapse_without_presence`
## detto dentro l'anno invece che fra un anno e l'altro.
func test_title_and_majority_stack_up_to_the_cap() -> void:
	var region_id: String = _open()
	_turn_on()
	var seat: String = str((session.world["turn_order"] as Array)[0])
	_commit(seat)
	_clear_region(region_id)
	_hand_region_to(seat, region_id)
	_stand(seat, region_id, 2)
	assert_eq(
		int(session.confluence._focus_weight(seat, "SUPPORT")["delta"]),
		2,
		"la tiene e ci sta in forze: due"
	)
	_turn_on({"max": 1})
	assert_eq(
		int(session.confluence._focus_weight(seat, "SUPPORT")["delta"]),
		1,
		"e il tetto e' un tetto"
	)


## Stare in un posto e' neutro rispetto al lato: «e' terra mia e dico di no»
## pesa quanto «e' terra mia e dico di si'» - se i dati lo dichiarano.
func test_the_side_is_what_the_data_declares() -> void:
	var region_id: String = _open()
	_turn_on()
	var seat: String = str((session.world["turn_order"] as Array)[0])
	_commit(seat)
	_clear_region(region_id)
	_hand_region_to(seat, region_id)
	assert_eq(
		int(session.confluence._focus_weight(seat, "OPPOSE")["delta"]),
		1,
		"con OPPOSE fra i lati, opporsi da padroni di casa pesa"
	)
	_turn_on({"sides": ["SUPPORT"]})
	assert_eq(
		int(session.confluence._focus_weight(seat, "OPPOSE")["delta"]),
		0,
		"e senza, no"
	)


## Il proponente e' gia' pagato dalla terra: e' *per* la presenza nel dominio
## che sta li' a proporre. La misura dice che dargli anche il peso lo paga due
## volte - FAIL 164 e un seggio bloccato.
func test_the_proponent_can_be_left_out() -> void:
	var region_id: String = _open()
	_turn_on({"includes_proponent": false})
	var seat: String = str(session.confluence.current["proponent"])
	_commit(seat)
	_clear_region(region_id)
	_hand_region_to(seat, region_id)
	assert_eq(
		int(session.confluence._focus_weight(seat, "SUPPORT")["delta"]),
		0,
		"escluso, il proponente non prende il peso della propria terra"
	)
	_turn_on({"includes_proponent": true})
	assert_eq(
		int(session.confluence._focus_weight(seat, "SUPPORT")["delta"]),
		1,
		"incluso, si'"
	)


## Un peso dal nulla sarebbe un voto gratis: senza carte sul tavolo, niente.
func test_no_cards_no_weight() -> void:
	var region_id: String = _open()
	_turn_on()
	var seat: String = str((session.world["turn_order"] as Array)[0])
	_clear_region(region_id)
	_hand_region_to(seat, region_id)
	_stand(seat, region_id, 2)
	assert_eq(
		int(session.confluence._focus_weight(seat, "SUPPORT")["delta"]),
		0,
		"chi non impegna niente non parla piu' forte"
	)
