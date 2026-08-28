extends "res://tests/test_case.gd"
## **Dove cade il segno che la carta lascia** (D-284, passo 1bis del brief).
##
## D-283 ha fatto posare i segni stampati sulle Azioni. Ne restavano fuori
## **314 su 851**, quasi tutti condizioni di Regione in mosse che una Regione
## non la nominano: INFLUENZARE parla a una domanda, FORGIARE a una casa. Il
## segno non si scriveva altrove — sarebbe stato posare un segnalino dove al
## tavolo nessuno saprebbe metterlo — e quindi la carta diceva una cosa che non
## succedeva.
##
## Al tavolo la risposta e' gia' stampata: **il bersaglio si dice a segni**
## (D-274). Chi cala sceglie il posto fra i luoghi che la carta raggiunge, e
## quella scelta e' vera — posare una condizione a casa d'altri non e' come
## posarla a casa propria.

const SeatDecider := preload("res://scripts/seat/seat_decider.gd")

const SEAT: String = "ENT_ALDRIC"
const CARD: String = "AST_WEALTH_GRAIN"
## «Chiudere i granai», la seconda meta' della carta vera: lascia #razionato.
const MARK: String = "condition:rationed"


func before_each() -> void:
	new_session()


## La carta della scatola, in mano al seggio. Nessun attrezzo di scena: «Il
## Grano» stampa due INFLUENZARE — aprire i granai e chiuderli — e tutte e due
## lasciano un segno su un luogo, che e' il caso che questa decisione risolve.
func _armed() -> void:
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(CARD):
		hand.append(CARD)


func _a_question() -> String:
	for tension_id in session.world["tensions"]:
		return str(tension_id)
	return ""


## **Il segno cade dove chi cala lo posa**, fra i luoghi che la carta raggiunge.
func test_the_player_says_where_the_sign_falls() -> void:
	_armed()
	var places: Array = session.actions.places_for_card(CARD)
	assert_true(places.size() > 0, "la carta raggiunge qualche posto: %d" % places.size())
	var where: String = str(places[0])
	var outcome: Dictionary = session.actions.execute(SEAT, {
		"template": "PLAY_CARD",
		"params": {
			"asset_id": CARD, "face_action": 1, "tension_id": _a_question(),
			"mark_region_id": where,
		},
	})
	assert_true(bool(outcome["ok"]), "la mossa passa: %s" % str(outcome.get("error", "")))
	assert_true(
		((session.world["regions"][where] as Dictionary)["tags"] as Array).has(MARK),
		"e il segno e' su %s" % where
	)


## **E non dove la carta non arriva.** La stessa promessa del bersaglio a segni,
## detta sull'altro pezzo della faccia: se il luogo non porta i segni che la
## carta chiede, il segno non ci si posa — e il rifiuto lo dice a segni.
func test_a_sign_cannot_fall_where_the_card_does_not_reach() -> void:
	_armed()
	var places: Array = session.actions.places_for_card(CARD)
	var elsewhere: String = ""
	for region_id in session.world["regions"]:
		if not places.has(str(region_id)):
			elsewhere = str(region_id)
			break
	if elsewhere == "":
		return  # su questo tavolo la carta arriva ovunque: niente da provare
	var refusal: String = session.actions.check(SEAT, "PLAY_CARD", {
		"asset_id": CARD, "face_action": 1, "tension_id": _a_question(),
		"mark_region_id": elsewhere,
	})
	assert_ne(refusal, "", "il posto sbagliato si rifiuta")
	assert_true(
		refusal.contains("segni"), "e il rifiuto parla la lingua della faccia: «%s»" % refusal
	)


## **Si chiede un posto esattamente quando serve**, su tutte e 48 le carte: se
## la meta' non lascia segni di luogo, il motore non deve inventare una domanda
## che al tavolo non si fa; se li lascia, non deve tacerla.
func test_a_place_is_asked_for_exactly_when_it_is_needed() -> void:
	var checked: int = 0
	var asked: int = 0
	for asset_id in session.data.assets:
		var card: Dictionary = session.data.assets[str(asset_id)] as Dictionary
		var face: Dictionary = card.get("physical", {}) as Dictionary
		var aims_at_a_place: bool = str(
			(face.get("target", {}) as Dictionary).get("scope", "")
		) == "REGION"
		var printed: Array = face.get("actions", []) as Array
		for index in range(printed.size()):
			var action: Dictionary = printed[index] as Dictionary
			var leaves_a_place_sign: bool = false
			for field in ["puts_tag", "clears_tag"]:
				for tag in action.get(field, []):
					var known: Variant = session.data.tags.get(str(tag))
					if known == null:
						continue
					var scopes: Array = (known as Dictionary).get("scope", []) as Array
					if scopes.has("REGION") and not scopes.has("GLOBAL"):
						leaves_a_place_sign = true
			var places: Array = session.actions.places_for_face(str(asset_id), index)
			checked += 1
			if leaves_a_place_sign and aims_at_a_place:
				asked += 1
				assert_false(
					places.is_empty(),
					"«%s», meta' %d: lascia un segno di luogo e un posto lo chiede"
					% [str(asset_id), index]
				)
			else:
				assert_true(
					places.is_empty(),
					"«%s», meta' %d: nessun segno di luogo, nessun posto da chiedere"
					% [str(asset_id), index]
				)
	assert_true(checked >= 90, "provate tutte le facce della scatola: %d" % checked)
	assert_true(asked > 0, "e qualcuna un posto lo chiede davvero: %d" % asked)


## **E il menu offre i posti, uno per uno, nominandoli** — e ognuno si accende
## sulla mappa, perche' porta la sua Regione nel soggetto (D-230).
func test_the_menu_offers_each_place_and_lights_it_on_the_map() -> void:
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

	# La carta della scatola che parla a una domanda e lascia un segno su un
	# luogo: nessun attrezzo di scena.
	var seat: String = str(live.world["turn_order"][0])
	var hand: Array = live.world["entities"][seat]["hand"] as Array
	if not hand.has(CARD):
		hand.append(CARD)

	var decider: RefCounted = SeatDecider.new([seat], null)
	var placed: int = 0
	var lit: int = 0
	for option in decider._action_options(seat, live):
		var params: Dictionary = (option as Dictionary).get("params", {}) as Dictionary
		if str(params.get("asset_id", "")) != CARD:
			continue
		if str(params.get("mark_region_id", "")) == "":
			continue
		placed += 1
		var subject: Dictionary = (option as Dictionary).get("subject", {}) as Dictionary
		if str(subject.get("region", "")) != "":
			lit += 1
		assert_true(
			str((option as Dictionary)["label"]).contains(" · a "),
			"e la voce dice dove: «%s»" % str((option as Dictionary)["label"])
		)
	assert_true(placed > 0, "il menu offre dove posare il segno: %d voci" % placed)
	assert_eq(lit, placed, "e ognuna si accende sulla mappa")
	live.dispose()
