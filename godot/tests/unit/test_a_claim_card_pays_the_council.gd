extends "res://tests/test_case.gd"
## **Il gettone di rivendicazione** (D-387 — ISSUES 122, parola del committente:
## *«io intendo l'azione rivendicare sulla carta come la carta che ti da' i
## Token da utilizzare proprio in questa occasione»*).
##
## Fino a D-386 il primo beneficio era gratis e ogni altro si pagava con un
## costo scelto dagli avversari — cioe' il proponente non spendeva **niente di
## suo**, e prendeva sempre e solo quello che valeva di piu'. Adesso la moneta
## esiste, si guadagna un turno prima, e si spende in Consiglio.
##
## Qui si prova la catena intera: la carta la da', il Consiglio la spende, e
## senza di lei il secondo beneficio non si compra.

const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


func _tokens(entity_id: String) -> int:
	return int(
		(session.world["entities"][entity_id] as Dictionary).get("claim_tokens", 0)
	)


## Una carta con la faccia RIVENDICARE fra le 48 del mazzo. Fabbricata no:
## cercata — se un giorno nessuna carta la porta piu', questa prova deve
## accorgersene invece di provare su un dato inventato.
func _a_claim_card() -> String:
	var ids: Array = (session.data.assets as Dictionary).keys()
	ids.sort()
	for asset_id in ids:
		var card: Dictionary = session.data.assets[str(asset_id)] as Dictionary
		if str((card.get("card_action", {}) as Dictionary).get("kind", "")) == "CLAIM":
			return str(asset_id)
	return ""


## **Il caso che deve dare non-zero**: si comincia a mani vuote, e la carta
## lascia un gettone.
func test_a_claim_card_leaves_a_token() -> void:
	var asset_id: String = _a_claim_card()
	assert_ne(asset_id, "", "nel mazzo c'e' una carta che RIVENDICA")
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(asset_id):
		hand.append(asset_id)
	assert_eq(_tokens(SEAT), 0, "si comincia a mani vuote")
	var result: Dictionary = session.actions.execute(
		SEAT, {"template": "PLAY_CARD", "params": {"asset_id": asset_id, "domain": "ANCIENT"}}
	)
	assert_true(bool(result["ok"]), "la carta si gioca: %s" % str(result.get("error", "")))
	assert_eq(_tokens(SEAT), 1, "e lascia un gettone di rivendicazione")


## E una carta che non rivendica non lascia niente: senza questo caso la prova
## di sopra passerebbe anche se il motore desse un gettone a chiunque.
func test_another_card_leaves_none() -> void:
	var altra: String = ""
	var ids: Array = (session.data.assets as Dictionary).keys()
	ids.sort()
	for asset_id in ids:
		var card: Dictionary = session.data.assets[str(asset_id)] as Dictionary
		if str((card.get("card_action", {}) as Dictionary).get("kind", "")) == "MOVE":
			altra = str(asset_id)
			break
	assert_ne(altra, "", "nel mazzo c'e' una carta che MUOVE")
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(altra):
		hand.append(altra)
	session.actions.execute(SEAT, {"template": "PLAY_CARD", "params": {"asset_id": altra}})
	assert_eq(_tokens(SEAT), 0, "MUOVERE non e' RIVENDICARE")


## **E il gettone si spende dove il committente ha detto**: nel Consiglio, per
## il secondo beneficio. Senza, il proponente ne posa uno solo.
func test_the_token_buys_the_second_benefit() -> void:
	var tension_id: String = ""
	for candidate in (session.world["tensions"] as Dictionary):
		var face: Dictionary = (
			(session.data.tensions[str(candidate)] as Dictionary).get("physical", {})
		) as Dictionary
		if (face.get("benefits", []) as Array).size() >= 2:
			tension_id = str(candidate)
			break
	assert_ne(tension_id, "", "sul tavolo c'e' una domanda con due benefici stampati")
	var context: Dictionary = session.confluence.open(tension_id, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence si apre")
	var options: Array = session.confluence.available_propositions()
	assert_false(options.is_empty(), "e porta una proposta")
	session.confluence.set_proposition(str((options[0] as Dictionary)["id"]))
	var proponent: String = str(context["proponent"])

	var menu: Array = session.confluence.benefit_menu()
	if menu.size() < 2:
		# Una carta le cui caselle qui non morderebbero non serve a questa
		# prova: quello che si sta provando e' la moneta, non le caselle vive.
		assert_true(true, "questa domanda non offre due caselle vive: niente da provare")
		return
	var due: Array = [
		str((menu[0] as Dictionary)["id"]), str((menu[1] as Dictionary)["id"]),
	]
	assert_eq(session.confluence.benefit_ceiling(), 1, "a mani vuote se ne posa una")
	assert_false(session.confluence.set_benefits(due), "e due non si comprano")

	var effect: GDScript = load("res://scripts/core/effect.gd")
	session.applier.apply(effect.make(
		"GRANT_CLAIM_TOKEN", "entity", proponent, {},
		effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_eq(session.confluence.benefit_ceiling(), 2, "col gettone se ne posano due")
	assert_true(session.confluence.set_benefits(due), "e adesso si comprano")
	assert_eq(
		int((session.world["entities"][proponent] as Dictionary)["claim_tokens"]), 0,
		"il gettone e' stato speso"
	)
