extends "res://tests/test_case.gd"
## Il telaio delle azioni sulle carte (ISSUES 47), provato a vuoto.
##
## «Togliamo tutte le azioni e le mettiamo sulle carte. Ogni carta ha una azione
## di gioco, un valore per il consiglio, e effetti specifici della carta.»
##
## Il valore e gli effetti c'erano gia'. Qui si prova l'azione, e si prova col
## pattern di D-104 e D-116: **prima il gancio con dati sintetici, poi il
## contenuto vero**. Nessuna carta del gioco porta ancora una `card_action`,
## quindi questi test se la scrivono da soli e la tolgono dopo.

const Effect := preload("res://scripts/core/effect.gd")

const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


## Mette una `card_action` su una carta vera, e la consegna in mano al seggio.
func _arm(asset_id: String, action: Dictionary) -> void:
	(session.data.assets[asset_id] as Dictionary)["card_action"] = action
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(asset_id):
		hand.append(asset_id)


func _disarm(asset_id: String) -> void:
	(session.data.assets[asset_id] as Dictionary).erase("card_action")


## Una carta senza azione non si gioca: e' solo un valore e un effetto di
## Consiglio, come in v0.2. E' la garanzia che il telaio a vuoto non cambi niente.
func test_a_card_without_an_action_cannot_be_played() -> void:
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	assert_true(hand.size() > 0, "il seggio ha delle carte")
	var refusal: String = session.actions.check(
		SEAT, "PLAY_CARD", {"asset_id": str(hand[0])}
	)
	assert_ne(refusal, "", "una carta muta non porta nessuna azione")
	assert_true(
		refusal.contains("nessuna azione"), "e il motivo lo dice: «%s»" % refusal
	)


## Il caso vero: la carta porta un'azione, giocarla la esegue **e consuma la
## carta**. E' la spesa che rende la mano una scelta invece di una scorta.
func test_playing_a_card_runs_its_action_and_spends_it() -> void:
	var asset_id: String = "AST_FORCE_LEVY"
	_arm(asset_id, {"kind": "ACQUIRE", "params": {"family": "BONDS"}})
	var before: int = (session.world["entities"][SEAT]["hand"] as Array).size()

	var result: Dictionary = session.actions.execute(
		SEAT, {"template": "PLAY_CARD", "params": {"asset_id": asset_id}}
	)
	assert_true(bool(result["ok"]), "la carta si gioca: %s" % str(result.get("error", "")))
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	assert_false(hand.has(asset_id), "la carta giocata non e piu in mano")
	# Ha pescato (ACQUIRE) e ha speso la carta: la mano resta com'era.
	assert_eq(hand.size(), before, "una carta spesa, una pescata")
	_disarm(asset_id)


## Una carta non puo' fare cio' che l'azione non permetterebbe: il telaio passa
## dallo stesso `check()`, quindi nessuna regola e' scritta due volte.
func test_a_card_cannot_do_what_the_action_forbids() -> void:
	var asset_id: String = "AST_FORCE_LEVY"
	# MUOVERE verso una Regione che non tocca nessuna delle sue: illegale
	# quando lo chiede il seggio, e illegale quando lo chiede la carta.
	var far_away: Dictionary = {"region_id": "REG_MINIERE_ANTICHE"}
	var direct: String = session.actions.check(SEAT, "MOVE", far_away)
	assert_ne(direct, "", "l'azione diretta la rifiuta")
	_arm(asset_id, {"kind": "MOVE", "params": far_away})
	var via_card: String = session.actions.check(SEAT, "PLAY_CARD", {"asset_id": asset_id})
	assert_ne(via_card, "", "e la carta non aggira il rifiuto")
	_disarm(asset_id)


## L'interruttore della Chronicle: acceso, le sei azioni di §10 non si prendono
## piu' con un'Opportunita' - la mano diventa l'unica moneta.
func test_the_switch_takes_the_six_actions_off_the_table() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	assert_false(
		bool(chronicle.get("actions_from_cards", false)),
		"di default il gioco e quello di sempre"
	)
	assert_eq(
		session.actions.check(SEAT, "ACQUIRE", {"family": "WEALTH"}), "",
		"e ACQUISIRE si prende con un'Opportunita"
	)

	chronicle["actions_from_cards"] = true
	var resolver: RefCounted = session.actions
	resolver.set("_chronicle", chronicle)
	var refused: String = resolver.check(SEAT, "ACQUIRE", {"family": "WEALTH"})
	assert_ne(refused, "", "acceso, l'azione diretta non c'e piu")
	assert_true(refused.contains("con le carte"), "e il motivo lo dice: «%s»" % refused)
	# Le carte del Narratore restano: sono un mazzo a parte, non la mano.
	assert_eq(
		resolver.check(SEAT, "PLAY_ECHO", {}).contains("con le carte"), false,
		"le carte del Narratore non passano di qui"
	)
	chronicle.erase("actions_from_cards")
