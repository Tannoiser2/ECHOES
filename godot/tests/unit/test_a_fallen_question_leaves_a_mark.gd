extends "res://tests/test_case.gd"
## Una domanda caduta lascia il segno che quella domanda lascia
## ([D-323](DECISIONS.md#d-323), [ISSUES 95](ISSUES.md)).
##
## Fino a 0.1.285 il pool `failure` della scheda del Consiglio non lo leggeva
## nessuno: un Consiglio che falliva lasciava al mondo soltanto
## `question_unresolved`, e undici Conseguenze scritte — proprio quelle che
## sporcano il mondo — non uscivano mai. Adesso ne scatta **una**, e non e' la
## stessa per tutti: la fame che nessuno risolve svuota il posto, una terra che
## nessuno assegna resta contesa, l'Antico che nessuno chiude diventa una voce
## che corre, un conto che nessuno salda chiude la strada.
##
## Le prove sono tre, e la terza e' quella che tiene le altre oneste: **una
## prova che cerca una condizione fra i dati puo' smettere di provare senza
## dirlo** se quella condizione sparisce. Qui la condizione e' «esiste almeno un
## Consiglio caduto», e se non c'e' la prova lo dice invece di passare a vuoto.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
const SEMI: Array = [9100, 9137, 9174, 9211, 9248, 9285]


## Ogni scheda di Consiglio dice **una riga sola** sotto «se cade», e quella
## riga nomina una Conseguenza che esiste. Una scheda con il pool vuoto e' un
## Consiglio che puo' cadere senza che il mondo se ne accorga; una che ne nomina
## due e' una scelta che al tavolo nessuno fa.
func test_every_council_sheet_says_what_happens_if_it_falls() -> void:
	var checked: int = 0
	for template_id in data().confluence_templates:
		var pools: Dictionary = (
			data().confluence_templates[template_id]["consequence_pools"] as Dictionary
		)
		var when_it_falls: Array = pools.get("failure", []) as Array
		assert_eq(
			when_it_falls.size(), 1,
			"%s: una riga sola sotto «se cade», non %d" % [template_id, when_it_falls.size()]
		)
		assert_true(
			data().consequences.has(str(when_it_falls[0])),
			"%s: «se cade» nomina %s, che nella scatola non c'e'" % [
				template_id, str(when_it_falls[0])
			]
		)
		checked += 1
	assert_true(checked > 0, "la prova ha guardato almeno una scheda")


## E in partita: ogni Consiglio caduto porta con se' la Conseguenza della sua
## scheda, non una generica e non nessuna.
func test_a_fallen_council_lands_the_consequence_of_its_own_sheet() -> void:
	var fallen: int = 0
	for seed_value in SEMI:
		if session != null:
			session.dispose()
		session = GameSession.new(data())
		session.setup("CHR_TEST", SEATS, int(seed_value))
		await session.run(_decider())
		for entry in session.chronicle.confluence_results:
			var result: Dictionary = entry as Dictionary
			if str(result["outcome"]) != ConfluenceResolution.FAILURE:
				continue
			fallen += 1
			var sheet: Dictionary = data().confluence_template_for(str(result["tension_id"]))
			var expected: Array = (
				(sheet.get("consequence_pools", {}) as Dictionary).get("failure", []) as Array
			)
			assert_eq(
				result["consequence_ids"], expected,
				"la domanda %s e' caduta: doveva lasciare %s" % [
					str(result["tension_id"]), str(expected)
				]
			)
	# **La riga che tiene onesta la prova.** Se un giorno nessuno di questi semi
	# fa cadere piu' niente, questa prova smetterebbe di provare in silenzio.
	assert_true(fallen > 0, "su %d semi non e' caduta nemmeno una domanda: la prova non prova niente" % SEMI.size())


## E il segno arriva **al mondo**, non solo nel verbale: una Conseguenza
## elencata che non posa nessun Effect sarebbe una riga stampata e basta.
func test_the_mark_reaches_the_world_and_not_only_the_minute() -> void:
	var landed: int = 0
	for seed_value in SEMI:
		if session != null:
			session.dispose()
		session = GameSession.new(data())
		session.setup("CHR_TEST", SEATS, int(seed_value))
		await session.run(_decider())
		for entry in session.chronicle.confluence_results:
			var result: Dictionary = entry as Dictionary
			if str(result["outcome"]) != ConfluenceResolution.FAILURE:
				continue
			if (result["consequence_ids"] as Array).is_empty():
				continue
			assert_true(
				(result["effect_ids"] as Array).size() > 0,
				"la domanda %s e' caduta e non ha posato niente sul mondo"
					% str(result["tension_id"])
			)
			landed += 1
	assert_true(landed > 0, "nessun Consiglio caduto misurato: la prova non prova niente")


func _decider() -> RefCounted:
	return load("res://scripts/seat/policy_decider.gd").new(session.log)
