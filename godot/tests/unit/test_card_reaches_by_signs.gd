extends "res://tests/test_case.gd"
## Il bersaglio a segni, eseguito dal motore (D-274 — ISSUES 69).
##
## La faccia fisica di una carta dice DOVE la carta arriva («Scegli un luogo
## con #granaio, #pascolo o #capitale...»), e fino a 0.1.235 il motore non la
## leggeva: la sim giocava un gioco diverso dal tavolo. Da qui MUOVERE — e
## TRAMARE su una Regione — rifiutano un luogo che non porta nessuno dei
## segni del bersaglio, o che porta un segno vietato. Contano i segni vivi:
## quelli stampati sulla tessera piu' quelli posati durante l'anno.

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _give(entity_id: String, asset_id: String) -> void:
	var hand: Array = (session.world["entities"][entity_id] as Dictionary)["hand"]
	if not hand.has(asset_id):
		hand.append(asset_id)


## **La carta non arriva dove i suoi segni non stanno.** La Leva Contadina
## nomina #granaio, #pascolo, #capitale e il dominio del #territorio: le
## Miniere Antiche non portano nessuno di questi segni, e il motore rifiuta —
## con la frase che spiega il perche', non con un errore muto.
func test_a_card_cannot_reach_a_place_without_its_signs() -> void:
	_give("ENT_VAERAX", "AST_FORCE_LEVY")
	var refusal: String = session.actions.check("ENT_VAERAX", "PLAY_CARD", {
		"asset_id": "AST_FORCE_LEVY", "region_id": "REG_MINIERE_ANTICHE",
	})
	assert_true(
		refusal.contains("il bersaglio si dice a segni"),
		"il rifiuto spiega il bersaglio a segni (era: «%s»)" % refusal
	)


## **E arriva dove stanno.** Le Terre Nahr portano il #pascolo e il dominio
## del #territorio: la stessa carta, dallo stesso seggio, passa.
func test_the_same_card_reaches_a_place_that_carries_them() -> void:
	_give("ENT_VAERAX", "AST_FORCE_LEVY")
	var refusal: String = session.actions.check("ENT_VAERAX", "PLAY_CARD", {
		"asset_id": "AST_FORCE_LEVY", "region_id": "REG_TERRE_NAHR",
	})
	assert_eq(refusal, "", "la carta arriva dove i suoi segni stanno")


## **I segni vivi contano quanto quelli stampati.** Un segno posato durante
## l'anno rende raggiungibile un luogo che da stampato non lo era — come al
## tavolo, dove la tessera si legge con sopra i suoi gettoni.
func test_a_sign_laid_during_the_year_opens_the_way() -> void:
	_give("ENT_VAERAX", "AST_FORCE_LEVY")
	session.applier.apply(Effect.make(
		"SET_REGION_TAG", "region", "REG_MINIERE_ANTICHE", {"tag": "granary"},
		Effect.source("test", "TEST", "", 1, 1, 0)
	))
	var refusal: String = session.actions.check("ENT_VAERAX", "PLAY_CARD", {
		"asset_id": "AST_FORCE_LEVY", "region_id": "REG_MINIERE_ANTICHE",
	})
	assert_eq(refusal, "", "il segno posato apre la strada")


## **Il segno vietato chiude la porta.** Una carta fabbricata (regola di
## casa) che vieta #conteso non entra dove il segno sta — e la carta a
## bersaglio libero resta libera.
func test_a_forbidden_sign_bars_the_door() -> void:
	data().assets["AST_PROVA_VIETATA"] = {
		"id": "AST_PROVA_VIETATA", "title": "La Prova Vietata",
		"family": "FORCE", "strength": 1, "deck_copies": 0,
		"discard_or_retain_rule": "DISCARD", "rarity": "COMMON",
		"card_action": {"kind": "MOVE"},
		"physical": {"target": {
			"scope": "REGION", "forbidden_tag": ["condition:contested"],
			"text": "Scegli un luogo che non sia #conteso.",
		}},
	}
	session.applier.apply(Effect.make(
		"SET_REGION_TAG", "region", "REG_TERRE_NAHR", {"tag": "condition:contested"},
		Effect.source("test", "TEST", "", 1, 1, 0)
	))
	var barred: String = session.actions._check_physical_target(
		"AST_PROVA_VIETATA", "MOVE", {"region_id": "REG_TERRE_NAHR"}
	)
	assert_true(
		barred.contains("un segno che la carta vieta"),
		"il segno vietato chiude la porta (era: «%s»)" % barred
	)
	var free_elsewhere: String = session.actions._check_physical_target(
		"AST_PROVA_VIETATA", "MOVE", {"region_id": "REG_EREDAN"}
	)
	assert_eq(free_elsewhere, "", "senza il segno vietato la carta a bersaglio libero va ovunque")
	data().assets.erase("AST_PROVA_VIETATA")


## **I verbi che non nominano una Regione non c'entrano.** Una faccia REGION
## su una carta giocata come FORGIARE non blocca niente: il controllo vale
## solo dove il verbo arriva a un luogo.
func test_other_verbs_are_untouched() -> void:
	assert_eq(
		session.actions._check_physical_target(
			"AST_FORCE_LEVY", "FORGE", {"region_id": "REG_MINIERE_ANTICHE"}
		),
		"",
		"una faccia REGION non lega i verbi che non nominano un luogo"
	)
