extends "res://tests/test_case.gd"
## Il sacchetto dei gettoni (ISSUES 49, D-192).
##
## «Ogni carta o azione fa pescare uno o più segnalini coperti che danno un
## valore a una tensione.»
##
## Il sacchetto esiste da sempre — è la Deriva (D-047) — e questa regola cambia
## **chi pesca**: non il mondo a orologio, ma i giocatori agendo.

const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


func _chronicle() -> Dictionary:
	return session.data.chronicles["CHR_TEST"] as Dictionary


func _heat() -> int:
	var total: int = 0
	for tension_id in session.world["tensions"]:
		total += int(session.world["tensions"][str(tension_id)]["current_value"])
	return total


## Spento — ed è così che nascono le sessioni di prova — un'azione non scalda
## niente da sé.
func test_without_the_rule_an_action_heats_nothing() -> void:
	assert_true(
		(_chronicle().get("tension_tokens", {}) as Dictionary).is_empty(),
		"la sessione di prova nasce col calore a orologio"
	)
	var before: int = _heat()
	session.actions.execute(SEAT, {"template": "PASS", "params": {}})
	assert_eq(_heat(), before, "e PASS non e nemmeno un'azione")


## Acceso, ogni azione riuscita posa un gettone: **una sola unità**, su una
## domanda scelta dal sacchetto.
func test_a_successful_action_lays_one_token() -> void:
	_chronicle()["tension_tokens"] = {"per_action": 1}
	session.actions.set("_chronicle", _chronicle())
	var before: int = _heat()
	var result: Dictionary = session.actions.execute(
		SEAT, {"template": "ACQUIRE", "params": {"family": "AUTHORITY"}}
	)
	assert_true(bool(result["ok"]), "l'azione riesce: %s" % str(result.get("error", "")))
	assert_eq(_heat(), before + 1, "un'azione, un gettone")
	_chronicle()["tension_tokens"] = {}


## E un'azione **rifiutata** non scalda niente: il mondo reagisce a ciò che si
## fa, non a ciò che si prova a fare.
func test_a_refused_action_lays_nothing() -> void:
	_chronicle()["tension_tokens"] = {"per_action": 1}
	session.actions.set("_chronicle", _chronicle())
	var before: int = _heat()
	var result: Dictionary = session.actions.execute(
		SEAT, {"template": "MOVE", "params": {"region_id": "REG_MINIERE_ANTICHE"}}
	)
	assert_false(bool(result["ok"]), "la Regione non e adiacente")
	assert_eq(_heat(), before, "un'azione rifiutata non scalda niente")
	_chronicle()["tension_tokens"] = {}


## Il gettone porta una **firma sua**, non quella dell'azione. Riusandola, un
## gettone si contava come un INFLUENZARE e il tetto di §10 saltava.
func test_the_token_is_signed_by_the_world_not_by_the_hand() -> void:
	_chronicle()["tension_tokens"] = {"per_action": 1}
	session.actions.set("_chronicle", _chronicle())
	session.actions.execute(SEAT, {"template": "ACQUIRE", "params": {"family": "AUTHORITY"}})
	var signed: bool = false
	for entry in (session.world["effect_log"] as Array):
		var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
		if str(effect.get("type", "")) != "ADJUST_TENSION":
			continue
		var source: Dictionary = effect.get("source", {}) as Dictionary
		if str(source.get("id", "")) == "TENSION_TOKEN":
			signed = true
			assert_eq(str(source.get("kind", "")), "system", "il calore e del mondo")
	assert_true(signed, "il gettone si firma da se")
	_chronicle()["tension_tokens"] = {}


## Il ritocco della soglia vive con la regola, non sulla Tensione: la stessa
## domanda gioca anche dove il sacchetto e' spento, e li' una soglia alzata non
## si raggiungerebbe mai.
func test_the_threshold_bonus_lives_with_the_rule() -> void:
	var written: int = int(session.data.tensions["TEN_FAMINE"]["threshold"])
	assert_eq(session.tensions.threshold("TEN_FAMINE"), written, "spento, la soglia e quella scritta")
	_chronicle()["tension_tokens"] = {"per_action": 1, "threshold_bonus": 1}
	assert_eq(
		session.tensions.threshold("TEN_FAMINE"), written + 1,
		"acceso, la soglia si alza di uno"
	)
	# E chi decide deve leggere lo stesso numero di chi apre il Consiglio.
	assert_eq(
		session.service.tension_threshold("TEN_FAMINE"),
		session.tensions.threshold("TEN_FAMINE"),
		"il seggio e il Consiglio leggono la stessa soglia"
	)
	_chronicle()["tension_tokens"] = {}
