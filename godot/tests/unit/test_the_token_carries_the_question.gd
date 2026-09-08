extends "res://tests/test_case.gd"
## **La casella su una domanda agisce sulla domanda in discussione** (D-343,
## riletta da D-472).
##
## Questo file nasce con D-416 (ISSUES 106): la pedina posata su ABBASSA LA
## DOMANDA portava con se' il nome di un'altra domanda — *«la sceglie chi
## propone»* — e le prove guardavano che il nome arrivasse al motore e che il
## cervello lo scegliesse quando gli conviene. Quel pezzo e' uscito col giro
## di D-280 (D-472): nel Consiglio a due domande `place_box` prende **solo
## l'id della casella**, e la casella agisce sulla domanda che si sta
## discutendo. Le prove sul nome portato dalla pedina e sul cervello che lo
## sceglie non hanno un equivalente e sono tolte; resta quello che ha ancora
## un senso al tavolo — la pedina secca, e la domanda che muove e' questa.
##
## La prova esiste anche per una ragione di metodo: due volte la sonda delle
## caselle ha detto lo stesso numero dopo due modifiche diverse, e un numero
## fermo e' qualcuno che guarda altrove. Qui non si misura *quanto* la casella
## e' attraente — quello lo dice la sonda — si prova **che il pezzo funzioni**:
## una pedina posata con l'id secco arriva al motore, muove la domanda in
## discussione e non un'altra, e si legge a verbale.

const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")

const TENSION: String = "TEN_FAMINE"


func before_each() -> void:
	new_session()


## **Di suo, la casella muove la domanda in discussione.** La funzione pura
## che risolve la domanda di una voce resta, e senza indicazioni sulla carta
## risponde con quella che si discute.
func test_a_bare_box_names_the_question_in_discussion() -> void:
	var ids: Array = (session.world["tensions"] as Dictionary).keys()
	assert_true(ids.size() >= 2, "ci sono almeno due domande in tavola")
	var voice: Dictionary = {"id": "V_TEST_COOL", "verb": "COOL_QUESTION", "text": "Abbassa la domanda"}
	var context: Dictionary = {"tension": str(ids[ids.size() - 1])}
	assert_eq(
		CouncilEconomy.question_of(voice, context, session.world), str(context["tension"]),
		"di suo muove la domanda in discussione"
	)


## **E posata con l'id secco, muove quella e non un'altra.** La casella si
## fabbrica sulla Carestia, marcata per la domanda A; chi propone la posa con
## `place_box(seggio, id)`; mucchio a zero, una pedina contro nessuna, la A
## vince; e nel registro degli Effetti la sola domanda mossa di un passo in
## giu' dalla pedina e' la Carestia.
func test_a_box_placed_by_id_moves_the_question_in_discussion() -> void:
	var loaded: RefCounted = data()
	var theme_id: String = str((loaded.tensions[TENSION] as Dictionary).get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = 0
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Carestia apre il suo Consiglio")
	assert_eq(session.confluence.pile(), 0, "col mucchio a zero")
	var others: Array = []
	for tension_id in (session.world["tensions"] as Dictionary):
		if str(tension_id) != TENSION:
			others.append(str(tension_id))
	assert_true(others.size() >= 1, "e c'e' almeno un'altra domanda sul tavolo")

	var box_id: String = "B_COOL_Q_PROVA"
	var benefits: Array = (loaded.tensions[TENSION] as Dictionary)["physical"]["benefits"] as Array
	benefits.append({
		"id": box_id, "verb": "COOL_QUESTION", "text": "Abbassa la domanda.",
		"for": [session.confluence.side_question("A")],
	})
	# L'esito di base della domanda A abbassa la Carestia da solo: si zittisce,
	# cosi' il passo in giu' che si conta e' quello della pedina.
	var question_id: String = session.confluence.side_question("A")
	var said: Array = []
	for entry in (loaded.confluence_template_for(TENSION)["questions"] as Array):
		if str((entry as Dictionary)["id"]) == question_id:
			said = ((entry as Dictionary)["base"] as Array).duplicate()
			(entry as Dictionary)["base"] = []
	(session.world["tensions"][TENSION] as Dictionary)["current_value"] = 3
	for tension_id in others:
		(session.world["tensions"][tension_id] as Dictionary)["current_value"] = 3

	var proponent: String = str(context["proponent"])
	assert_true(session.confluence.place_box(proponent, box_id), "la pedina si posa con l'id secco")
	var before: int = (session.world["effect_log"] as Array).size()
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["winner"]), "A", "una pedina contro nessuna: vince la A")

	# Gli Effetti della pedina: ADJUST_TENSION di -1. Il passo del voto (H.1) e
	# il Ripple hanno altri delta, quindi il -1 e' solo della casella.
	var lowered: Array = []
	for i in range(before, (session.world["effect_log"] as Array).size()):
		var effect: Dictionary = (session.world["effect_log"] as Array)[i] as Dictionary
		if str(effect["type"]) != "ADJUST_TENSION":
			continue
		if int((effect["payload"] as Dictionary).get("delta", 0)) == -1:
			lowered.append(str((effect["target"] as Dictionary)["id"]))
	assert_eq(lowered, [TENSION], "e la sola domanda abbassata dalla pedina e' quella in discussione")
	var spoken: bool = false
	for line in session.log.lines:
		if str(line).contains("H. Beneficio: Abbassa la domanda."):
			spoken = true
	assert_true(spoken, "e il verbale legge la casella posata")

	# La DataSet e' condivisa: la casella fabbricata se ne va, e la base torna.
	benefits.pop_back()
	for entry in (loaded.confluence_template_for(TENSION)["questions"] as Array):
		if str((entry as Dictionary)["id"]) == question_id:
			(entry as Dictionary)["base"] = said
