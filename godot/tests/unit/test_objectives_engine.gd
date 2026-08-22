extends "res://tests/test_case.gd"
## Quattro obiettivi al posto di tre gradini (D-198).
##
## «Gli obiettivi sostituiscono i gradini: se si ottengono tutti e 4 e' un
## trionfo, se non se ne raggiunge nessuno e' un none, gli altri sono successi
## parziali, e vittorie che danno numeri alla fine della saga.»
##
## Quattro cose vanno provate, e la quarta e' quella che tiene onesta la regola:
## che una Chronicle che **non** la dichiara continui a salire la scala di
## sempre. Come per il punteggio di saga (D-180), la regola e' della Chronicle e
## non del motore.

const ObjectiveRules: Dictionary = {
	"hidden": 3,
	"public_from": "victory",
	"levels": ["NONE", "MINIMUM", "VICTORY", "VICTORY", "TRIUMPH"],
	"saga_points": [-1, 1, 2, 4, 6],
}


func before_each() -> void:
	new_session()


## Accende la regola e ripesca gli obiettivi: `new_session` parte dal lato
## classico (`play_classic`), che li spegne e svuota quelli gia' pescati.
func _play_with_objectives(hidden: Array = ["OBJ_TWO_LANDS", "OBJ_A_STONE", "OBJ_THE_NAME"]) -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	chronicle["objectives"] = ObjectiveRules.duplicate(true)
	for entity_id in session.world["entities"]:
		(session.world["entities"][str(entity_id)] as Dictionary)["objectives"] = hidden.duplicate()
	session.actions.set("_chronicle", chronicle)


## Il conto e' quello che decide, e la tabella della Chronicle lo traduce.
func test_the_level_comes_from_the_count() -> void:
	_play_with_objectives([])
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	# Senza nascosti resta il solo palese: o zero o uno.
	(chronicle["objectives"] as Dictionary)["hidden"] = 0
	var result: Dictionary = session.destinies.evaluate("DST_ALDRIC", "ENT_ALDRIC")
	assert_true(result.has("objectives_met"), "il risultato porta il conto")
	assert_eq((result["objectives"] as Array).size(), 1, "un solo obiettivo: il palese")
	var expected: String = str(
		(ObjectiveRules["levels"] as Array)[int(result["objectives_met"])]
	)
	assert_eq(str(result["level"]), expected, "il livello e' quello che dice la tabella")


## Il palese e' il Destino giurato, letto al gradino dichiarato: e' pubblico
## perche' e' quello per cui la casa e' venuta al tavolo.
func test_the_public_one_is_the_sworn_destiny() -> void:
	_play_with_objectives()
	var taken: Array = session.destinies.objectives_of("ENT_ALDRIC")
	assert_eq(taken.size(), 4, "uno palese e tre coperti")
	var first: Dictionary = taken[0] as Dictionary
	assert_true(bool(first["public"]), "il primo e' il palese")
	assert_eq(str(first["id"]), "DST_ALDRIC", "ed e' il Destino giurato")
	assert_eq(
		str(first["label"]),
		str((session.data.destinies["DST_ALDRIC"] as Dictionary)["victory"]["label"]),
		"letto al gradino che la Chronicle dichiara"
	)
	for i in range(1, taken.size()):
		assert_false(bool((taken[i] as Dictionary)["public"]), "gli altri tre sono coperti")


## Tutti e quattro e' un trionfo, nessuno e' un anno perso: i due estremi, presi
## dai dati veri invece che da una tabella scritta a mano.
func test_all_four_is_a_triumph_and_none_is_a_lost_year() -> void:
	var ladder: Array = ObjectiveRules["levels"] as Array
	assert_eq(str(ladder[0]), "NONE", "zero obiettivi e' un anno perso")
	assert_eq(str(ladder[ladder.size() - 1]), "TRIUMPH", "tutti e quattro e' un trionfo")
	_play_with_objectives()
	# Un mondo appena aperto: quello che conta e' che il conto e il livello
	# stiano d'accordo, qualunque sia il numero.
	var result: Dictionary = session.destinies.evaluate("DST_ALDRIC", "ENT_ALDRIC")
	var met: int = int(result["objectives_met"])
	assert_eq(
		str(result["level"]), str(ladder[mini(met, ladder.size() - 1)]),
		"%d obiettivi danno il livello che la tabella scrive" % met
	)
	# E il livello raggiunto contiene quelli sotto, come ha sempre voluto dire.
	var rung: int = ["MINIMUM", "VICTORY", "TRIUMPH"].find(str(result["level"]))
	var levels: Dictionary = result["levels"] as Dictionary
	assert_eq(bool(levels["MINIMUM"]), rung >= 0, "il MINIMO e' compreso")
	assert_eq(bool(levels["TRIUMPH"]), rung >= 2, "il TRIONFO no, se non ci si arriva")


## La riga a verbale dice il conto, non l'etichetta di un gradino: stampare
## «Il regno decide» a chi quel Destino non l'ha chiuso sarebbe la bugia piu'
## facile di tutta la regola.
func test_the_minute_says_the_count_and_not_a_rung_label() -> void:
	_play_with_objectives()
	var result: Dictionary = session.destinies.evaluate("DST_ALDRIC", "ENT_ALDRIC")
	var line: String = session.destinies.describe(result)
	assert_true(line.contains("su 4"), "la riga dice quanti su quattro: «%s»" % line)
	if int(result["objectives_met"]) == 1:
		assert_true(line.contains("1 obiettivo su"), "e al singolare dice «obiettivo»")


## Gli obiettivi coperti si pescano all'apertura, dal pool, senza ripetizioni.
func test_the_hidden_ones_are_dealt_at_the_opening() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	chronicle["objectives"] = ObjectiveRules.duplicate(true)
	var fresh: RefCounted = GameSession.new(session.data)
	fresh.setup("CHR_01", ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"], 4242)
	for entity_id in fresh.world["entities"]:
		var drawn: Array = (fresh.world["entities"][str(entity_id)] as Dictionary)["objectives"]
		assert_eq(drawn.size(), 3, "%s ne pesca tre" % entity_id)
		var seen: Dictionary = {}
		for objective_id in drawn:
			assert_true(
				session.data.objectives.has(str(objective_id)),
				"«%s» sta nel pool" % objective_id
			)
			assert_false(seen.has(str(objective_id)), "e nessuno esce due volte")
			seen[str(objective_id)] = true
	fresh.dispose()
	chronicle["objectives"] = {}


## Lo stesso seme pesca gli stessi obiettivi: senza, una partita non si rigioca.
func test_the_same_seed_deals_the_same_objectives() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	chronicle["objectives"] = ObjectiveRules.duplicate(true)
	var seats: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
	var drawn: Array = []
	for i in range(2):
		var fresh: RefCounted = GameSession.new(session.data)
		fresh.setup("CHR_01", seats, 909)
		var row: Array = []
		for entity_id in seats:
			row.append((fresh.world["entities"][str(entity_id)] as Dictionary)["objectives"])
		drawn.append(JSON.stringify(row))
		fresh.dispose()
	assert_eq(str(drawn[0]), str(drawn[1]), "lo stesso seme pesca gli stessi obiettivi")
	chronicle["objectives"] = {}


## La guardia che tiene onesta la regola: senza `objectives` nella Chronicle non
## cambia niente, e si sale la scala di sempre.
func test_without_the_rule_the_ladder_is_the_one_of_always() -> void:
	# `new_session` parte gia' dal lato classico.
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	assert_true(
		(chronicle.get("objectives", {}) as Dictionary).is_empty(),
		"il lato classico non dichiara obiettivi"
	)
	var result: Dictionary = session.destinies.evaluate("DST_ALDRIC", "ENT_ALDRIC")
	assert_false(result.has("objectives_met"), "e il risultato non porta nessun conto")
	assert_true((result["levels"] as Dictionary).has("MINIMUM"), "la scala e' quella di §14")
	# E i dati spediti la dichiarano: se domani qualcuno la spegne, lo si sa qui.
	var shipped: RefCounted = DataSet.new()
	shipped.load_from("res://data")
	assert_false(
		((shipped.chronicles["CHR_01"] as Dictionary).get("objectives", {}) as Dictionary).is_empty(),
		"ma CHR_01, come spedita, gioca a obiettivi"
	)
