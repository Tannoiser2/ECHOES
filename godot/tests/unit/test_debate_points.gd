extends "res://tests/test_case.gd"
## **L'astensione ha un prezzo** (D-455, parola del committente): chi vince il
## dibattito con le carte in mano guadagna punti di campagna, chi non ne gioca
## ne perde. Due numeri nella Chronicle; a zero il Consiglio non tocca il
## punteggio. Col Consiglio a due domande (D-467, D-472) il fronte che vince e'
## **la parte che vince**: A sostiene, B si oppone. La prova fabbrica il
## Consiglio con un decisore scritto — chi sta con A, chi con B, quante carte
## impegna ognuno — e forza chi vince col mucchio a zero; poi legge i punti
## che il registro scrive, con le regole accese e spente.

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


func after_each() -> void:
	# `_chronicle` e' la definizione condivisa del banco: la regola sintetica
	# si spegne, o la prova dopo la troverebbe accesa.
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	(chronicle.get("confluence_rules", {}) as Dictionary).erase("debate_points")
	super.after_each()


func _grant(entity_id: String, asset_id: String) -> void:
	session.applier.apply(Effect.make(
		"GRANT_ASSET", "entity", entity_id, {"asset_id": asset_id, "source": "VOID"},
		Effect.source("test", "TEST", "", 1, 1, 0)
	))


func _score(entity_id: String) -> int:
	return int((session.world["entities"][entity_id] as Dictionary).get("saga_score", 0))


## Il mucchio del voto e' il calore del Tema all'apertura: a zero vince chi
## ha una carta o una pedina in piu' dell'altra parte.
func _pile(tension_id: String, value: int) -> void:
	var theme_id: String = str((session.data.tensions[tension_id] as Dictionary).get("theme", ""))
	(session.world["theme_heat"] as Dictionary)[theme_id] = value


## Un Consiglio giocato per intero dal controllore della Chronicle, con un
## cervello che dice quello che la prova vuole. Il proponente lo decide il
## Consiglio; gli altri tre prendono i ruoli nell'ordine del tavolo: il
## secondo sta con A, il terzo prende la B, il quarto sta dove gli si dice
## e non gioca carte. Quante carte impegna ognuno lo dice la prova.
class Scripted extends RefCounted:
	var proponent: String = ""
	var supporter: String = ""
	var opposer: String = ""
	var silent: String = ""
	var silent_side: String = "A"
	var cards_for: Dictionary = {}

	func _cast(context: Dictionary, session: RefCounted) -> void:
		if proponent != "":
			return
		proponent = str(context["proponent"])
		var others: Array = []
		for seat in session.world["turn_order"]:
			if str(seat) != proponent:
				others.append(str(seat))
		supporter = others[0]
		opposer = others[1]
		silent = others[2]

	func choose_question(context: Dictionary, _options: Array, _s: RefCounted) -> String:
		return str(context.get("question_id", ""))

	func choose_box(_entity_id: String, context: Dictionary, menu: Array, _side: String, session: RefCounted) -> String:
		_cast(context, session)
		return "" if menu.is_empty() else str((menu[0] as Dictionary)["id"])

	func choose_side(entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted) -> Dictionary:
		_cast(context, session)
		var side: String = "B" if entity_id == opposer else ("A" if entity_id == supporter else silent_side)
		if (offer.get(side, []) as Array).is_empty():
			side = "A" if side == "B" else "B"
		var menu: Array = offer.get(side, []) as Array
		return {"side": side, "voice_id": "" if menu.is_empty() else str((menu[0] as Dictionary)["id"])}

	func choose_raise(_entity_id: String, _c: Dictionary, _menu: Array, _s: RefCounted) -> String:
		return ""

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		_cast(context, session)
		var wanted: int = mini(int(cards_for.get(entity_id, 0)), limit)
		return (session.service.hand(entity_id) as Array).slice(0, wanted)

	func choose_recovery(_c: Dictionary, _s: RefCounted) -> Dictionary:
		return {}


## Chi propone, chi sostiene e chi si oppone hanno una carta; il quarto sta
## con A senza carte. A vale due carte e tre pedine contro una carta e una
## pedina: vince la A.
func _a_wins(brain: Scripted) -> void:
	brain.silent_side = "A"
	brain.cards_for = {brain.proponent: 1, brain.supporter: 1, brain.opposer: 1}


## Solo chi si oppone gioca carte, due; il quarto sta con B senza carte. A
## vale due pedine, B due carte e due pedine: vince la B.
func _b_wins(brain: Scripted) -> void:
	brain.silent_side = "B"
	brain.cards_for = {brain.opposer: 2}


func _play_one_council(winners_gain: int, silent_lose: int, script: Callable) -> Dictionary:
	_rules(winners_gain, silent_lose)
	_pile("TEN_FAMINE", 0)
	var seats: Array = session.world["turn_order"]
	var brain: Scripted = Scripted.new()
	for seat in seats:
		_grant(str(seat), "AST_WEALTH_GRAIN")
		_grant(str(seat), "AST_WEALTH_CARAVAN")
	# I ruoli si assegnano appena il Consiglio dice chi propone: qui si
	# sbircia, e si richiude prima di giocare. Aprire scrive `last_proponent`,
	# e chi ha aperto si fa da parte al Consiglio dopo (D-051): la memoria
	# della sbirciata si cancella, o il giro vero avrebbe un altro proponente.
	var remembered: Dictionary = (session.world.get("last_proponent", {}) as Dictionary).duplicate(true)
	var peek: Dictionary = session.confluence.open("TEN_FAMINE", {"kind": "THRESHOLD"})
	assert_false(peek.is_empty(), "il Consiglio si apre")
	brain._cast(peek, session)
	session.confluence.current = {}
	session.world["last_proponent"] = remembered
	script.call(brain)
	var before: Dictionary = {}
	for seat in seats:
		before[str(seat)] = _score(str(seat))
	var result: Dictionary = await session.chronicle.run_confluence(
		"TEN_FAMINE", {"kind": "THRESHOLD", "entity_id": ""}, brain
	)
	assert_false(result.is_empty(), "il Consiglio si e' tenuto")
	assert_eq(str(result["proponent"]), brain.proponent, "propone chi la prova aveva sbirciato")
	var sides: Dictionary = result["sides"] as Dictionary
	assert_true(((sides["A"] as Dictionary)["seats"] as Array).has(brain.supporter), "chi sostiene sta con A")
	assert_true(((sides["B"] as Dictionary)["seats"] as Array).has(brain.opposer), "chi si oppone sta con B")
	assert_true(
		((sides[brain.silent_side] as Dictionary)["seats"] as Array).has(brain.silent),
		"e il silenzioso sta con %s" % brain.silent_side
	)
	var deltas: Dictionary = {}
	for seat in seats:
		deltas[str(seat)] = _score(str(seat)) - int(before[str(seat)])
	return {"result": result, "deltas": deltas, "brain": brain}


func _said_at_the_table() -> bool:
	for line in session.log.lines:
		if str(line).contains("Punti del dibattito"):
			return true
	return false


func test_with_the_rules_off_the_council_leaves_the_score_alone() -> void:
	var played: Dictionary = await _play_one_council(0, 0, _a_wins)
	assert_eq(str(played["result"]["winner"]), "A", "la prova fa vincere la A (%s)" % str(played["result"]["outcome"]))
	for seat in played["deltas"]:
		assert_eq(int(played["deltas"][seat]), 0, "%s: niente punti senza regola" % str(seat))
	assert_true((played["result"]["debate_points"] as Dictionary).is_empty(), "e il registro non scrive niente")
	assert_false(_said_at_the_table(), "e il verbale non ne parla")


## Vince la A: il proponente e chi lo sostiene, con una carta in mano,
## guadagnano; chi si e' opposto e ha perso non prende niente; chi non ha
## giocato carte perde.
func test_when_a_wins_its_front_with_cards_gains_and_the_silent_lose() -> void:
	var played: Dictionary = await _play_one_council(1, 1, _a_wins)
	var brain: Scripted = played["brain"]
	var deltas: Dictionary = played["deltas"]
	assert_eq(str(played["result"]["winner"]), "A", "vince la A (%s)" % str(played["result"]["outcome"]))
	assert_eq(int(deltas[brain.proponent]), 1, "il proponente vince con le carte: +1")
	assert_eq(int(deltas[brain.supporter]), 1, "chi lo sostiene con una carta: +1")
	assert_eq(int(deltas[brain.opposer]), 0, "chi si e' opposto e ha perso: niente")
	assert_eq(int(deltas[brain.silent]), -1, "chi non gioca carte perde un punto")
	assert_eq((played["result"]["debate_points"] as Dictionary).size(), 3, "il registro scrive ogni punto mosso")
	assert_true(_said_at_the_table(), "e il verbale lo dice al tavolo")


## Vince la B: chi l'ha presa con le carte guadagna; il proponente battuto
## non prende niente e, avendo proposto, non paga il silenzio; chi sta con
## una parte senza giocare carte paga, da qualunque parte stia.
func test_when_b_wins_the_opposer_gains_and_the_silent_lose() -> void:
	var played: Dictionary = await _play_one_council(1, 1, _b_wins)
	var brain: Scripted = played["brain"]
	var deltas: Dictionary = played["deltas"]
	assert_eq(str(played["result"]["winner"]), "B", "vince la B (%s)" % str(played["result"]["outcome"]))
	assert_eq(int(deltas[brain.opposer]), 1, "chi ha preso la B con le carte: +1")
	assert_eq(int(deltas[brain.proponent]), 0, "il proponente battuto: niente, e non paga il silenzio")
	assert_eq(int(deltas[brain.supporter]), -1, "chi stava con A senza carte: -1")
	assert_eq(int(deltas[brain.silent]), -1, "chi stava con B senza carte: -1")
	assert_eq((played["result"]["debate_points"] as Dictionary).size(), 3, "il registro scrive ogni punto mosso")
	assert_true(_said_at_the_table(), "e il verbale lo dice al tavolo")
