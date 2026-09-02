extends "res://tests/test_case.gd"
## **Nessuna proposta e' murata** (ISSUES 56, D-414).
##
## Una porta murata e' peggio di una proposta impopolare: la seconda il tavolo
## la vede e la scarta, la prima **non sale nemmeno sulla scheda**. In 200 anni
## di saga, `CNS_CROWN_REUNITED` e `CNS_DRAGON_SLAIN` — la corona che si
## ricompone e il drago che muore, due dei nomi grossi del catalogo — erano
## escluse **14 volte su 14 e 5 su 5**: la loro clausola d'idoneita' chiedeva
## una cosa che al momento giusto non c'era mai.
##
## Aperte le porte, tutt'e due sono passate a «offerta 2 volte, presa zero»: non
## escono ancora, ma adesso **il tavolo le vede**, ed e' un difetto diverso con
## un rimedio diverso.
##
## Questa prova tiene aperto quello che e' stato aperto. Non chiede che una
## proposta venga scelta — quello lo decide chi gioca — chiede che **esista uno
## stato del mondo in cui puo' essere offerta**.
##
## E nasce da due errori miei, che valgono piu' della prova:
##
##   1. la prima riparazione l'avevo scritta in `confluence_templates.json`, e
##      **le Proposte vengono dalla carta Tensione** da D-378: il numero non si
##      e' mosso di un centesimo, ed era il foglio sbagliato;
##   2. la seconda chiave la puntava su una Regione, e **una Scoperta sta
##      sull'entita'**: avevo murato una porta mentre ne smuravo un'altra.
##
## Nona e decima volta che in questo progetto un numero fermo era chi guardava.

const SeatDecider := preload("res://scripts/seat/seat_decider.gd")

## Le due che erano murate, con la chiave che adesso le apre.
const DOORS: Array = [
	["P_ONE_CROWN", "GLOBAL", "heir_named"],
	["P_SLAY_THE_DRAGON", "ENTITY", "discovery:the_omen"],
]


func before_each() -> void:
	new_session()


## Ogni clausola d'idoneita' di ogni proposta **spedita** chiede qualcosa che
## qualcuno sa scrivere. Una che chiede l'impossibile non e' una regola severa:
## e' contenuto che il tavolo non vedra' mai.
func test_every_shipped_proposal_can_be_offered() -> void:
	var written: Dictionary = _who_writes_what()
	var walled: Array = []
	var checked: int = 0
	for tension_id in shipped_data().tensions:
		var council: Dictionary = (
			(shipped_data().tensions[tension_id] as Dictionary).get("council", {}) as Dictionary
		)
		for proposal in (council.get("propositions", []) as Array):
			var needed: Array = _tags_required((proposal as Dictionary).get("eligibility", []))
			checked += 1
			for tag in needed:
				if not written.has(str(tag)):
					walled.append("%s chiede «%s»" % [
						str((proposal as Dictionary)["id"]), str(tag)
					])
	# Uno zero qui sarebbe la prova cieca: se non si e' guardata nessuna
	# proposta, non si e' misurato niente.
	assert_true(checked > 50, "si sono guardate le proposte della scatola: %d" % checked)
	assert_true(
		walled.is_empty(),
		"nessuna proposta chiede un segno che nessuno scrive: %s" % ", ".join(
			PackedStringArray(walled.slice(0, mini(5, walled.size())))
		)
	)


## **E le due che erano murate si aprono davvero.** La prova sopra guarda i
## dati; questa guarda il motore: si mette il mondo nello stato che la chiave
## chiede, e si chiede al Consiglio se quella proposta e' sulla scheda.
##
## Senza questa meta' la prima sarebbe una prova sui dati che si assolve da sola:
## un segno «scritto da qualcuno» puo' comunque essere letto nel posto sbagliato,
## ed e' esattamente l'errore che questa voce ha fatto due volte.
func test_the_two_walled_doors_open() -> void:
	for door in DOORS:
		var proposal_id: String = str((door as Array)[0])
		var scope: String = str((door as Array)[1])
		var tag: String = str((door as Array)[2])
		var found: Dictionary = _proposal(proposal_id)
		assert_false(found.is_empty(), "«%s» sta ancora nella scatola" % proposal_id)

		var context: Dictionary = {"proponent": str(session.world["turn_order"][0])}
		assert_false(
			session.confluence.conditions.all_hold(found["eligibility"], context),
			"«%s» e' chiusa finche' la sua chiave non c'e'" % proposal_id
		)

		# La chiave si posa a mano: qui si misura **la serratura**, non il modo
		# in cui il mondo ci arriva.
		if scope == "GLOBAL":
			(session.world["global_tags"] as Array).append(tag)
		else:
			(session.world["entities"][str(context["proponent"])]["tags"] as Array).append(tag)

		assert_true(
			session.confluence.conditions.all_hold(found["eligibility"], context),
			"e con «%s» si apre" % tag
		)


func _proposal(proposal_id: String) -> Dictionary:
	for tension_id in shipped_data().tensions:
		var council: Dictionary = (
			(shipped_data().tensions[tension_id] as Dictionary).get("council", {}) as Dictionary
		)
		for proposal in (council.get("propositions", []) as Array):
			if str((proposal as Dictionary)["id"]) == proposal_id:
				return proposal as Dictionary
	return {}


## I segni che una lista d'idoneita' pretende, scendendo dentro `any_of`.
func _tags_required(eligibility: Array) -> Array:
	var out: Array = []
	for clause in eligibility:
		var kind: String = str((clause as Dictionary).get("type", ""))
		if kind == "any_of" or kind == "some_of":
			# **Dentro un `any_of` basta una porta**: se una sola si apre, la
			# proposta non e' murata, e pretendere che si aprano tutte
			# direbbe il contrario di quello che la clausola dice.
			var doors: Array = _tags_required((clause as Dictionary).get("conditions", []))
			if doors.is_empty():
				continue
			var known: Dictionary = _who_writes_what()
			var one_opens: bool = false
			for tag in doors:
				if known.has(str(tag)):
					one_opens = true
			if not one_opens:
				out.append_array(doors)
			continue
		if kind == "state_tag_present":
			var tag: String = str((clause as Dictionary).get("tag", ""))
			if tag != "":
				out.append(tag)
	return out


## Chi scrive ogni segno, secondo il dizionario. E' la stessa fonte che
## `validate_physical.py` sorveglia: un segno con una penna qualcuno lo posa.
func _who_writes_what() -> Dictionary:
	var out: Dictionary = {}
	for tag_id in shipped_data().tags:
		var entry: Dictionary = shipped_data().tags[tag_id] as Dictionary
		if not (entry.get("written_by", []) as Array).is_empty():
			out[str(tag_id)] = true
	return out
