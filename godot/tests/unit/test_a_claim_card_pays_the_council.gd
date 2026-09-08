extends "res://tests/test_case.gd"
## **Il gettone di rivendicazione** (D-387 — ISSUES 122, parola del committente:
## *«io intendo l'azione rivendicare sulla carta come la carta che ti da' i
## Token da utilizzare proprio in questa occasione»*).
##
## La carta con la faccia RIVENDICARE lascia in mano un gettone, e una carta
## che non rivendica no: l'Effetto `GRANT_CLAIM_TOKEN` esiste ancora, e queste
## due prove lo sorvegliano. **Da D-472 il Consiglio non spende gettoni**: il
## giro di D-280 — il gettone che comprava il secondo beneficio, il prezzo
## scelto dagli avversari — e' uscito dal codice col Consiglio a due domande
## (D-467), dove le pedine si posano sulle caselle della propria parte e il
## prezzo si conta per parte al voto. La prova che spendeva il gettone in
## Consiglio e' tolta con verbale; a cosa serva il gettone adesso e' una voce
## aperta di D-472, non di questo file.

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
