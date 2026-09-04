extends "res://tests/test_case.gd"
## **L'astensione ha un prezzo** (D-455, parola del committente): chi vince il
## dibattito con le carte in mano guadagna punti di campagna, chi non ne gioca
## ne perde. Due numeri nella Chronicle; a zero il Consiglio non tocca il
## punteggio. La prova fabbrica il Consiglio — un sostenitore con una carta,
## un oppositore con una carta, un astenuto — e legge i punti che il registro
## scrive, con le regole accese e spente.

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _rules(winners_gain: int, silent_lose: int) -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	var rules: Dictionary = chronicle.get("confluence_rules", {}) as Dictionary
	rules["debate_points"] = {"winners_gain": winners_gain, "silent_lose": silent_lose}
	chronicle["confluence_rules"] = rules
	session.confluence.set("_chronicle", chronicle)
	session.chronicle.set("_chronicle", chronicle)


func _grant(entity_id: String, asset_id: String) -> void:
	session.applier.apply(Effect.make(
		"GRANT_ASSET", "entity", entity_id, {"asset_id": asset_id, "source": "VOID"},
		Effect.source("test", "TEST", "", 1, 1, 0)
	))


func _score(entity_id: String) -> int:
	return int((session.world["entities"][entity_id] as Dictionary).get("saga_score", 0))


## Un Consiglio giocato per intero dal controllore della Chronicle, con un
## cervello che dice quello che la prova vuole: il proponente propone, il
## secondo sostiene con una carta, il terzo si oppone con una carta, il quarto
## si astiene.
class Scripted extends RefCounted:
	var proponent: String = ""
	var supporter: String = ""
	var opposer: String = ""
	var silent: String = ""

	func choose_question(context: Dictionary, options: Array, _s: RefCounted) -> String:
		return str(context.get("question_id", "")) if options.is_empty() else str(options[0]["id"])

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		# Il proponente lo decide il Consiglio: i ruoli degli altri tre si
		# assegnano qui, nell'ordine del tavolo.
		proponent = str(context["proponent"])
		var others: Array = []
		for seat in session.world["turn_order"]:
			if str(seat) != proponent:
				others.append(str(seat))
		supporter = others[0]
		opposer = others[1]
		silent = others[2]
		return str(options[0]["id"])

	func choose_stance(entity_id: String, _c: Dictionary, _s: RefCounted) -> Dictionary:
		if entity_id == supporter:
			return {"stance": "SUPPORT", "clause_id": ""}
		if entity_id == opposer:
			return {"stance": "OPPOSE", "clause_id": ""}
		return {"stance": "ABSTAIN", "clause_id": ""}

	func choose_commit(entity_id: String, _c: Dictionary, limit: int, session: RefCounted) -> Array:
		if limit <= 0:
			return []
		return (session.service.hand(entity_id) as Array).slice(0, 1)

	func choose_recovery(_c: Dictionary, _s: RefCounted) -> Dictionary:
		return {}


func _play_one_council(winners_gain: int, silent_lose: int) -> Dictionary:
	_rules(winners_gain, silent_lose)
	var seats: Array = session.world["turn_order"]
	var brain: Scripted = Scripted.new()
	for seat in seats:
		_grant(str(seat), "AST_WEALTH_GRAIN")
		_grant(str(seat), "AST_WEALTH_CARAVAN")
	var before: Dictionary = {}
	for seat in seats:
		before[str(seat)] = _score(str(seat))
	var result: Dictionary = await session.chronicle.run_confluence(
		"TEN_FAMINE", {"kind": "THRESHOLD"}, brain
	)
	assert_false(result.is_empty(), "il Consiglio si e' tenuto")
	var deltas: Dictionary = {}
	for seat in seats:
		deltas[str(seat)] = _score(str(seat)) - int(before[str(seat)])
	return {"result": result, "deltas": deltas, "brain": brain}


func test_with_the_rules_off_the_council_leaves_the_score_alone() -> void:
	var played: Dictionary = await _play_one_council(0, 0)
	for seat in played["deltas"]:
		assert_eq(int(played["deltas"][seat]), 0, "%s: niente punti senza regola" % str(seat))
	assert_true((played["result"]["debate_points"] as Dictionary).is_empty(), "e il registro non scrive niente")


func test_the_winning_front_with_cards_gains_and_the_silent_lose() -> void:
	var played: Dictionary = await _play_one_council(1, 1)
	var brain: Scripted = played["brain"]
	var deltas: Dictionary = played["deltas"]
	var won: bool = str(played["result"]["outcome"]) != "FAILURE"
	assert_eq(int(deltas[brain.silent]), -1, "chi non gioca carte perde un punto")
	if won:
		assert_eq(int(deltas[brain.proponent]), 1, "il proponente vince con le carte: +1")
		assert_eq(int(deltas[brain.supporter]), 1, "chi lo sostiene con una carta: +1")
		assert_eq(int(deltas[brain.opposer]), 0, "chi si e' opposto e ha perso: niente")
	else:
		assert_eq(int(deltas[brain.opposer]), 1, "chi si e' opposto e ha vinto: +1")
		assert_eq(int(deltas[brain.proponent]), 0, "il proponente battuto: niente")
	assert_eq(
		(played["result"]["debate_points"] as Dictionary).size(),
		3 if won else 2,
		"il registro scrive ogni punto mosso"
	)
	var said: bool = false
	for line in session.log.lines:
		if str(line).contains("Punti del dibattito"):
			said = true
	assert_true(said, "e il verbale lo dice al tavolo")
