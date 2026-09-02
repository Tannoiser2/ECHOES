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


## **E il cervello, oggi, non la indica.** Questa e' la meta' che la sonda non
## riusciva a vedere, ed e' scritta come **misura**, non come promessa: dice
## dov'e' il difetto, cosi' che nessuno lo cerchi di nuovo dove non e'.
##
## Due tentativi di far scegliere al cervello la domanda migliore hanno lasciato
## la sonda delle caselle **identica al centesimo** — 700 offerte, 22 comprate,
## tutt'e due le volte — e il secondo ha anche rotto una prova dei legami. Il
## motore la pedina la sa portare (prova qui sopra); a non usarla e' chi compra.
##
## Se un giorno questa prova diventa rossa, e' perche' qualcuno ha insegnato al
## cervello a indicare: allora si cambia il verso dell'asserzione e si rimisura
## `run_boxes_probe`. E' il criterio che resta aperto sulla voce.
func test_today_the_brain_does_not_name_one() -> void:
	var seat: String = str(session.world["turn_order"][0])
	var brain: RefCounted = PolicyDecider.new(session.log)
	var menu: Array = [
		{"id": "V_TEST_COOL", "verb": "COOL_QUESTION", "text": "Abbassa la domanda"},
	]
	var chosen: Array = brain.choose_benefits(seat, {}, menu, session)
	assert_false(chosen.is_empty(), "il cervello compra la casella offerta")

	var named: int = 0
	for entry in chosen:
		if entry is Dictionary and str((entry as Dictionary).get("question", "")) != "":
			named += 1
	assert_eq(
		named, 0,
		"e oggi non ne nomina nessuna: la pedina esce come un id secco. %s" % str(chosen)
	)
