extends "res://tests/test_case.gd"
## Il telaio delle azioni sulle carte (ISSUES 47), provato a vuoto.
##
## «Togliamo tutte le azioni e le mettiamo sulle carte. Ogni carta ha una azione
## di gioco, un valore per il consiglio, e effetti specifici della carta.»
##
## Il valore e gli effetti c'erano gia'. Qui si prova l'azione, e si prova col
## pattern di D-104 e D-116: **prima il gancio con dati sintetici, poi il
## contenuto vero**. Da 0.1.156 le quarantotto carte portano la loro azione
## davvero (D-188); i test che vogliono un caso preciso continuano a scriversi
## la propria `card_action` e a rimetterla com'era.

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
	# Da 0.1.156 nessuna carta e' muta, quindi una muta va costruita: si toglie
	# l'azione a una carta in mano e si rimette dopo.
	var card: Dictionary = session.data.assets[str(hand[0])] as Dictionary
	var spoken: Variant = card.get("card_action")
	card.erase("card_action")
	var refusal: String = session.actions.check(
		SEAT, "PLAY_CARD", {"asset_id": str(hand[0])}
	)
	if spoken != null:
		card["card_action"] = spoken
	assert_ne(refusal, "", "una carta muta non porta nessuna azione")
	assert_true(
		refusal.contains("nessuna azione"), "e il motivo lo dice: «%s»" % refusal
	)


## Fase 4 di ISSUES 47: **tutte e quarantotto** parlano. Finche' una tace, il
## gioco a sole carte ha un buco - una famiglia che pesca quella carta si
## ritrova con un'Occasione che non puo' spendere.
func test_every_card_carries_an_action() -> void:
	var mute: Array = []
	var kinds: Dictionary = {}
	for asset_id in session.data.assets:
		var card: Dictionary = session.data.assets[str(asset_id)] as Dictionary
		var action: Dictionary = card.get("card_action", {}) as Dictionary
		if action.is_empty():
			mute.append(str(asset_id))
			continue
		var kind: String = str(action["kind"])
		kinds[kind] = int(kinds.get(kind, 0)) + 1
	assert_eq(mute.size(), 0, "nessuna carta muta (mute: %s)" % [mute])
	# E nessuna delle cinque azioni che restano puo' mancare dal mazzo: una
	# azione che nessuna carta porta e' un'azione che nessuno puo' piu' fare.
	for kind in ["MOVE", "INFLUENCE", "FORGE", "SCHEME", "CLAIM"]:
		assert_true(
			int(kinds.get(kind, 0)) > 0, "qualche carta sa dire %s" % kind
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
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	# `new_session()` nasce sul lato classico (vedi `play_classic()`), cosi' le
	# prove delle azioni restano leggibili.
	assert_false(
		bool(chronicle.get("actions_from_cards", false)),
		"la sessione di prova nasce sul §10 di sempre"
	)
	assert_eq(
		session.actions.check(SEAT, "ACQUIRE", {"family": "WEALTH"}), "",
		"e ACQUISIRE si prende con un'Opportunita"
	)

	chronicle["actions_from_cards"] = true
	var resolver: RefCounted = session.actions
	resolver.set("_chronicle", chronicle)
	# Il divieto vive in `execute()`, non in `check()` (D-188): `check()` deve
	# continuare a rispondere «sarebbe legale?», perche' e' la domanda che una
	# sedia si fa prima di sapere con quale carta lo dira'.
	assert_eq(
		resolver.check(SEAT, "ACQUIRE", {"family": "WEALTH"}), "",
		"acceso, l'azione resta *legale in se*: e' la domanda del cervello"
	)
	var refused: Dictionary = resolver.execute(
		SEAT, {"template": "ACQUIRE", "params": {"family": "WEALTH"}}
	)
	assert_false(bool(refused["ok"]), "ma prenderla con un'Opportunita non si puo piu")
	assert_true(
		str(refused["error"]).contains("con le carte"),
		"e il motivo lo dice: «%s»" % str(refused["error"])
	)
	# Le carte del Narratore restano: sono un mazzo a parte, non la mano.
	assert_eq(
		resolver.check(SEAT, "PLAY_ECHO", {}).contains("con le carte"), false,
		"le carte del Narratore non passano di qui"
	)
	chronicle.erase("actions_from_cards")


## E i dati spediti stanno **dall'altra parte**: CHR_01 gioca con le carte come
## unica moneta, e il rubinetto le da'. Le due meta' vanno accese insieme
## (D-184, D-185): una sola delle due non regge, e questo test lo dice prima che
## lo dica una partita.
func test_the_shipped_chronicle_plays_with_cards() -> void:
	# Si rilegge il dato **dal disco**: la DataSet della suite l'ha gia' riportata
	# al lato classico, e chiederlo a lei sarebbe chiedere alla prova stessa.
	var shipped: RefCounted = DataSet.new()
	assert_true(shipped.load_from("res://data"), "i dati spediti si caricano")
	var chronicle: Dictionary = shipped.chronicles["CHR_00"] as Dictionary
	assert_true(
		bool(chronicle.get("actions_from_cards", false)),
		"CHR_01 gioca con le carte"
	)
	assert_false(
		(chronicle.get("hand_refill", {}) as Dictionary).is_empty(),
		"e il rubinetto e acceso insieme, o la mano si svuota e nessuno agisce piu"
	)
