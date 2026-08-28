extends "res://tests/test_case.gd"
## **Le due Azioni stampate, tutte e due eseguibili** (D-283).
##
## Il passo 1 del brief del Punto Zero: *«rendere entrambe le azioni delle carte
## Asset realmente eseguibili dal motore e visibili nell'app»*.
##
## Fino a qui una carta si poteva calare **solo col verbo dichiarato** in
## `card_action.kind`: la seconda Azione stampata sulla faccia era inchiostro,
## anche quando portava gia' un verbo che il motore sa fare (37 carte su 48). E
## i segni che le Azioni posano — `puts_tag` e `clears_tag`, 71 occorrenze su 33
## segni diversi — non venivano eseguiti mai. Sono loro a rendere **diverse** le
## due meta' di una carta: 29 carte su 48 stampano lo stesso verbo due volte, e
## senza i segni le due meta' farebbero la stessa identica cosa.

const Effect := preload("res://scripts/core/effect.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")

const SEAT: String = "ENT_ALDRIC"
const CARD: String = "AST_FORCE_LEVY"
const MARK: String = "condition:contested"


func before_each() -> void:
	new_session()


## Mette in mano la carta e le stampa due Azioni: la stessa mossa, ma la seconda
## lascia un segno. E' la forma che hanno 29 carte della scatola.
func _two_faces() -> void:
	var card: Dictionary = session.data.assets[CARD] as Dictionary
	var face: Dictionary = card["physical"] as Dictionary
	face["actions"] = [
		{"label": "Chiamare la leva", "text": "...", "template": "MOVE"},
		{
			"label": "Tenerli a casa", "text": "...", "template": "MOVE",
			"puts_tag": [MARK],
		},
	]
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(CARD):
		hand.append(CARD)


## Dove quella carta, con quella meta', si puo' davvero calare adesso.
func _somewhere_legal(face_action: int) -> String:
	for region_id in session.world["regions"]:
		var params: Dictionary = {
			"asset_id": CARD, "face_action": face_action, "region_id": str(region_id),
		}
		if session.actions.check(SEAT, "PLAY_CARD", params) == "":
			return str(region_id)
	return ""


## **La seconda meta' e' una mossa sua, e lascia il suo segno.**
func test_the_second_printed_action_leaves_its_own_mark() -> void:
	_two_faces()
	var region_id: String = _somewhere_legal(1)
	assert_ne(region_id, "", "la seconda meta' si puo' calare da qualche parte")
	var before: Array = (
		(session.world["regions"][region_id] as Dictionary)["tags"] as Array
	).duplicate()
	assert_false(before.has(MARK), "e li' il segno non c'e' ancora")

	var outcome: Dictionary = session.actions.execute(SEAT, {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARD, "face_action": 1, "region_id": region_id},
	})
	assert_true(bool(outcome["ok"]), "la mossa passa: %s" % str(outcome.get("error", "")))
	var after: Array = (session.world["regions"][region_id] as Dictionary)["tags"] as Array
	assert_true(after.has(MARK), "e il segno stampato e' sul tavolo")


## **Il segno stampato si firma** (la regola di D-030, e la ragione per cui la
## sonda sa contarlo): la sorgente dice `face_action` e nomina la carta, cosi'
## chi rilegge distingue quello che ha scritto **l'Azione** da quello che ha
## scritto il verbo — TRAMARE lascia scoperte sue nello stesso momento.
func test_the_printed_sign_signs_itself() -> void:
	_two_faces()
	var region_id: String = _somewhere_legal(1)
	assert_ne(region_id, "", "la seconda meta' si puo' calare")
	session.actions.execute(SEAT, {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARD, "face_action": 1, "region_id": region_id},
	})
	var signed: int = 0
	for entry in (session.world["effect_log"] as Array):
		var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
		var source: Dictionary = effect.get("source", {}) as Dictionary
		if str(source.get("kind", "")) != "face_action":
			continue
		signed += 1
		assert_eq(str(source.get("id", "")), CARD, "e la firma nomina la carta")
		assert_eq(
			str((effect.get("payload", {}) as Dictionary).get("tag", "")), MARK,
			"e dice quale segno"
		)
	assert_eq(signed, 1, "un segno stampato, una firma")


## E si disfa: un segno posato e' un Effect come tutti gli altri, con il suo
## inverso. Senza, la faccia fisica sarebbe una mutazione fuori dal libro
## mastro — la cosa che questo progetto non si permette.
func test_the_printed_sign_can_be_undone() -> void:
	_two_faces()
	var region_id: String = _somewhere_legal(1)
	assert_ne(region_id, "", "la seconda meta' si puo' calare")
	session.actions.execute(SEAT, {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARD, "face_action": 1, "region_id": region_id},
	})
	var tags: Array = (session.world["regions"][region_id] as Dictionary)["tags"] as Array
	assert_true(tags.has(MARK), "il segno c'e'")
	var undone: int = 0
	while (
		(session.world["regions"][region_id] as Dictionary)["tags"] as Array
	).has(MARK) and undone < 40:
		assert_true(session.applier.undo_last(), "e si disfa un passo alla volta")
		undone += 1
	assert_false(
		((session.world["regions"][region_id] as Dictionary)["tags"] as Array).has(MARK),
		"finche' il tavolo torna com'era"
	)


## **Un segno che non trova il proprio soggetto non si posa altrove.** Un segno
## di Regione, in una mossa che non nomina nessuna Regione, non finisce sul
## mondo ne' su una casa: resta non scritto, e la sonda lo conta. Scriverlo dove
## capita sarebbe mettere sul tavolo un segnalino che nessuno saprebbe dove
## posare.
func test_a_sign_without_a_subject_is_not_written_somewhere_else() -> void:
	var card: Dictionary = session.data.assets["AST_PEOPLE_MOBILIZATION"] as Dictionary
	var face: Dictionary = card["physical"] as Dictionary
	var was: Variant = face.get("actions")
	face["actions"] = [
		{"label": "Prima", "text": "...", "template": "INFLUENCE"},
		{
			"label": "Seconda", "text": "...", "template": "INFLUENCE",
			"puts_tag": [MARK],
		},
	]
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has("AST_PEOPLE_MOBILIZATION"):
		hand.append("AST_PEOPLE_MOBILIZATION")
	var played: bool = false
	for tension_id in session.world["tensions"]:
		var params: Dictionary = {
			"asset_id": "AST_PEOPLE_MOBILIZATION", "face_action": 1,
			"tension_id": str(tension_id),
		}
		if session.actions.check(SEAT, "PLAY_CARD", params) != "":
			continue
		var outcome: Dictionary = session.actions.execute(
			SEAT, {"template": "PLAY_CARD", "params": params}
		)
		played = bool(outcome["ok"])
		break
	assert_true(played, "la carta si e' calata su una domanda")
	for region_id in session.world["regions"]:
		assert_false(
			((session.world["regions"][str(region_id)] as Dictionary)["tags"] as Array).has(MARK),
			"e nessuna Regione si e' presa il segno per sbaglio: %s" % str(region_id)
		)
	if was != null:
		face["actions"] = was


## **E la scatola, com'e' spedita, offre tutte e due le meta'.**
##
## Non e' una prova sul telaio: e' la promessa che il contenuto ne approfitti.
## Con una mano che porta una carta a due Azioni dello stesso verbo, il menu ne
## deve mostrare **due**, e coi nomi stampati sulla faccia.
func test_the_box_offers_both_halves_of_a_card() -> void:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	var live: RefCounted = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(live.setup("CHR_00", seats, 4242), "e l'anno si apre")
	for effect in live.factory_setup_effects():
		live.applier.apply(effect)
	live.world["act"] = 1
	live.world["round"] = 1
	live.world["phase"] = "ACTIONS"

	# Una carta che stampa due volte lo stesso verbo, messa in mano al seggio.
	var twin: String = ""
	for asset_id in loaded.assets:
		var printed: Array = (
			((loaded.assets[str(asset_id)] as Dictionary).get("physical", {}) as Dictionary)
			.get("actions", []) as Array
		)
		if printed.size() < 2:
			continue
		var first: String = str((printed[0] as Dictionary).get("template", ""))
		if first != "" and first == str((printed[1] as Dictionary).get("template", "")):
			twin = str(asset_id)
			break
	assert_ne(twin, "", "la scatola ha carte a due meta' dello stesso verbo")

	var seat: String = str(live.world["turn_order"][0])
	var hand: Array = live.world["entities"][seat]["hand"] as Array
	if not hand.has(twin):
		hand.append(twin)
	var decider: RefCounted = SeatDecider.new([seat], null)
	var labels: Array = []
	for option in decider._action_options(seat, live):
		labels.append(str(option["label"]))
	var printed_labels: Array = (
		((loaded.assets[twin] as Dictionary)["physical"] as Dictionary)["actions"] as Array
	)
	var said: String = " · ".join(PackedStringArray(labels))
	var seen: int = 0
	for entry in printed_labels:
		if said.contains(str((entry as Dictionary).get("label", ""))):
			seen += 1
	assert_eq(
		seen, 2,
		"il menu offre tutte e due le meta', coi nomi stampati sulla faccia: %s" % said
	)
	var title: String = str((loaded.assets[twin] as Dictionary)["title"])
	var voices: int = 0
	for label in labels:
		if str(label).contains(title):
			voices += 1
	assert_true(voices >= 2, "e sono due voci diverse della stessa carta: %d" % voices)
	live.dispose()
