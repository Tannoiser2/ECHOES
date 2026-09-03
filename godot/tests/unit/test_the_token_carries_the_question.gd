extends "res://tests/test_case.gd"
## **La pedina porta con se\' il nome della domanda** (ISSUES 106, D-416).
##
## Parola del committente sulla casella che muove una domanda: *«la sceglie chi
## propone»* — non quella stampata sull\'autore, ma quella che il proponente
## indica col dito fra i segnalini che stanno tutti sul tavolo.
##
## Questa prova esiste perche\' la misura non si muoveva. Dopo la catena scritta
## e dopo il punteggio corretto, la sonda delle caselle diceva **700 offerte, 22
## comprate** tutt\'e due le volte, identico al centesimo. Un numero fermo dopo
## due modifiche diverse non e\' un rimedio debole: e\' qualcuno che guarda
## altrove, e in questo progetto e\' successo undici volte prima di questa.
##
## Quindi qui non si misura *quanto* la casella diventa attraente — quello lo
## dice la sonda — si prova **che il pezzo funzioni**: che una pedina posata su
## una domanda nominata arrivi al motore, muova quella e non un\'altra, e si
## legga a verbale.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")


func before_each() -> void:
	new_session()


## **Il motore accetta la pedina con la domanda, e muove quella.**
func test_a_named_question_is_the_one_that_moves() -> void:
	var ids: Array = (session.world["tensions"] as Dictionary).keys()
	assert_true(ids.size() >= 2, "ci sono almeno due domande in tavola")
	var elsewhere: String = ""
	for tension_id in ids:
		elsewhere = str(tension_id)
		break

	var voice: Dictionary = {
		"id": "V_TEST_COOL", "verb": "COOL_QUESTION", "text": "Abbassa la domanda",
	}
	var context: Dictionary = {"tension": str(ids[ids.size() - 1])}
	assert_ne(
		elsewhere, str(context["tension"]),
		"la domanda indicata e\' un\'altra da quella in discussione"
	)

	# Senza indicazione: muove quella di cui si sta discutendo.
	var here: String = CouncilEconomy.question_of(voice, context, session.world)
	assert_eq(here, str(context["tension"]), "di suo muove la domanda in discussione")

	# Con l\'indicazione: muove quella.
	var named: Dictionary = voice.duplicate()
	named["dove"] = "QUESTION"
	named["question"] = elsewhere
	assert_eq(
		CouncilEconomy.question_of(named, context, session.world), elsewhere,
		"e con la domanda indicata muove quella"
	)


## **E il cervello la indica, quando gli conviene** (D-438). Fino alla 0.1.407
## questa prova asseriva il contrario — *«oggi non ne nomina nessuna»* — come
## misura dello stato, non come promessa. Adesso il cervello pesa la casella su
## ogni segnalino in tavola e posa la pedina sul migliore: qui la domanda
## migliore e' costruita apposta — una sola e' alta, e non e' quella di cui si
## discute — e la pedina deve uscire col suo nome.
func test_the_brain_names_the_question_that_serves_it() -> void:
	var seat: String = str(session.world["turn_order"][0])
	var ids: Array = (session.world["tensions"] as Dictionary).keys()
	ids.sort()
	assert_true(ids.size() >= 2, "ci sono almeno due domande in tavola")
	# Tutte a terra tranne una, alta: abbassare quella vale 2, le altre 0.
	for tension_id in ids:
		(session.world["tensions"][tension_id] as Dictionary)["current_value"] = 0
	var alta: String = str(ids[ids.size() - 1])
	(session.world["tensions"][alta] as Dictionary)["current_value"] = 5
	var brain: RefCounted = PolicyDecider.new(session.log)
	var menu: Array = [
		{"id": "V_TEST_COOL", "verb": "COOL_QUESTION", "text": "Abbassa la domanda"},
	]
	var chosen: Array = brain.choose_benefits(seat, {}, menu, session)
	assert_false(chosen.is_empty(), "il cervello compra la casella offerta")
	var first: Variant = chosen[0]
	assert_true(first is Dictionary, "la pedina porta il nome della domanda: %s" % str(chosen))
	if first is Dictionary:
		assert_eq(
			str((first as Dictionary).get("question", "")), alta,
			"ed e' la domanda alta, non quella in discussione"
		)


## **E a parita' non indica niente.** Con tutte le domande uguali la pedina
## esce come un id secco: il nome si dice solo quando il dito ha scelto davvero.
func test_with_nothing_to_gain_the_token_stays_bare() -> void:
	var seat: String = str(session.world["turn_order"][0])
	for tension_id in (session.world["tensions"] as Dictionary):
		(session.world["tensions"][tension_id] as Dictionary)["current_value"] = 0
	var brain: RefCounted = PolicyDecider.new(session.log)
	var menu: Array = [
		{"id": "V_TEST_COOL", "verb": "COOL_QUESTION", "text": "Abbassa la domanda"},
	]
	var chosen: Array = brain.choose_benefits(seat, {}, menu, session)
	assert_false(chosen.is_empty(), "il cervello compra la casella offerta")
	assert_true(chosen[0] is String, "e la pedina e' un id secco: %s" % str(chosen))
