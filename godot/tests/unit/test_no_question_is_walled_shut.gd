extends "res://tests/test_case.gd"
## **Nessuna domanda e' murata** (ISSUES 56, D-414, portata al Consiglio a due
## domande in [D-474](../../docs/DECISIONS.md#d-474)).
##
## Una porta murata e' peggio di una domanda impopolare: la seconda il tavolo
## la vede e la scarta, la prima **non sale nemmeno sulla scheda**. In 200 anni
## di saga, `CNS_CROWN_REUNITED` e `CNS_DRAGON_SLAIN` — la corona che si
## ricompone e il drago che muore, due dei nomi grossi del catalogo — erano
## escluse **14 volte su 14 e 5 su 5**: la loro clausola d'idoneita' chiedeva
## una cosa che al momento giusto non c'era mai.
##
## Fino alla 0.1.443 quelle clausole stavano sulle **proposte**, uscite dai dati
## con D-474. La regola non e' uscita con loro: le carte hanno due domande, e
## una delle due puo' aprirsi solo quando la questione e' abbastanza calda
## (`tension_limit`). Se quel gradino sta **sopra la soglia**, la domanda non
## si apre mai: il Consiglio si tiene quando la questione arriva a soglia, e
## una domanda che ne chiede di piu' e' una porta murata identica a quelle.
##
## E la lezione dei due errori di allora vale ancora:
##
##   1. la prima riparazione era scritta nel template condiviso, e **le Domande
##      vengono dalla carta Tensione**: il numero non si e' mosso di un
##      centesimo, ed era il foglio sbagliato;
##   2. la seconda chiave era puntata su una Regione mentre il segno stava
##      sull'entita': una porta murata mentre se ne smurava un'altra.
##
## Nona e decima volta che in questo progetto un numero fermo era chi guardava.


func before_each() -> void:
	new_session()


## Ogni gradino d'idoneita' di ogni domanda **spedita** sta a portata della sua
## questione. Uno che chiede l'impossibile non e' una regola severa: e'
## contenuto che il tavolo non vedra' mai.
func test_every_shipped_question_can_be_asked() -> void:
	var walled: Array = []
	var checked: int = 0
	var gates: int = 0
	for tension_id in shipped_data().tensions:
		var about: Dictionary = shipped_data().tensions[tension_id] as Dictionary
		var council: Dictionary = about.get("council", {}) as Dictionary
		for entry in (council.get("questions", []) as Array):
			var question: Dictionary = entry as Dictionary
			checked += 1
			for clause in _gates_of(question.get("eligibility", []) as Array):
				gates += 1
				var named: String = str((clause as Dictionary).get("tension_id", ""))
				var asked: int = int((clause as Dictionary).get("min", 0))
				var reach: int = int(
					(shipped_data().tensions.get(named, about) as Dictionary).get("threshold", 0)
				)
				if asked > reach:
					walled.append("%s chiede %d e %s arriva a %d" % [
						str(question["id"]), asked, named, reach
					])
	# Due zeri sarebbero due prove cieche: se non si e' guardata nessuna domanda,
	# o nessun gradino, non si e' misurato niente.
	assert_true(checked > 100, "si sono guardate le domande della scatola: %d" % checked)
	assert_true(gates > 0, "e almeno una porta un gradino da scavalcare: %d" % gates)
	assert_true(
		walled.is_empty(),
		"nessuna domanda chiede piu' calore di quanto la sua questione ne prenda: %s"
		% ", ".join(PackedStringArray(walled.slice(0, mini(5, walled.size()))))
	)


## **E il gradino si apre davvero.** La prova sopra guarda i dati; questa guarda
## il motore: si scalda la questione fino al gradino e si chiede al Consiglio se
## quella domanda e' sulla scheda.
##
## Senza questa meta' la prima sarebbe una prova sui dati che si assolve da sola:
## un numero «a portata» puo' comunque essere letto nel posto sbagliato, ed e'
## esattamente l'errore che questa voce ha fatto due volte.
func test_a_gated_question_opens_when_the_question_burns() -> void:
	var found: Dictionary = _first_gated()
	assert_false(found.is_empty(), "una domanda col gradino sta nella scatola")
	var question: Dictionary = found["question"] as Dictionary
	var clause: Dictionary = found["gate"] as Dictionary
	var named: String = str(clause.get("tension_id", ""))
	var step: int = int(clause.get("min", 0))
	assert_true(
		session.world["tensions"].has(named),
		"e la sua questione e' in gioco: %s" % named
	)

	var context: Dictionary = {"proponent": str(session.world["turn_order"][0])}
	session.world["tensions"][named]["current_value"] = maxi(step - 1, 0)
	assert_false(
		session.confluence.conditions.all_hold(question["eligibility"], context),
		"«%s» e' chiusa finche' %s non arriva a %d" % [str(question["id"]), named, step]
	)

	# Il calore si posa a mano: qui si misura **la serratura**, non il modo in
	# cui il mondo ci arriva.
	session.world["tensions"][named]["current_value"] = step
	assert_true(
		session.confluence.conditions.all_hold(question["eligibility"], context),
		"e a %d si apre" % step
	)


## La prima domanda spedita che porta un gradino, con la sua questione in gioco:
## la serratura si prova su una che il tavolo di prova ha davvero.
func _first_gated() -> Dictionary:
	var ids: Array = shipped_data().tensions.keys()
	ids.sort()
	for tension_id in ids:
		if not session.world["tensions"].has(str(tension_id)):
			continue
		var council: Dictionary = (
			shipped_data().tensions[str(tension_id)] as Dictionary
		).get("council", {}) as Dictionary
		for entry in (council.get("questions", []) as Array):
			var gates: Array = _gates_of((entry as Dictionary).get("eligibility", []) as Array)
			for clause in gates:
				if session.world["tensions"].has(str((clause as Dictionary).get("tension_id", ""))):
					return {"question": entry, "gate": clause}
	return {}


## I gradini che una lista d'idoneita' pretende, scendendo dentro `any_of`.
##
## **Dentro un `any_of` basta una porta**: pretendere che si aprano tutte
## direbbe il contrario di quello che la clausola dice, quindi li' i gradini non
## si contano — e' la stessa cura che la prova vecchia aveva imparato a mettere.
func _gates_of(eligibility: Array) -> Array:
	var out: Array = []
	for clause in eligibility:
		var kind: String = str((clause as Dictionary).get("type", ""))
		if kind == "tension_limit" and (clause as Dictionary).has("min"):
			out.append(clause)
	return out
