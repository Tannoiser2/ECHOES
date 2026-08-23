extends "res://tests/test_case.gd"
## Prendere una carta e lasciarla sulla mappa (D-230).
##
## Il committente: *«la GUI deve prevedere movimenti drag & drop, non pulsanti
## che dicono cosa fare. Si seleziona una carta, si decide come usarla e si deve
## poter generare il suo effetto.»*
##
## Il trascinamento non e' provabile col mouse in una suite headless, ma **le
## tre decisioni che lo governano si', e sono quelle che possono sbagliare**:
## cosa viaggia col pezzo, dove puo' cadere, e cosa succede quando cade. Il
## resto e' Godot che sposta pixel.
##
## La regola sotto tutte e tre e' quella di D-039, e non cambia: **una carta si
## puo' trascinare esattamente dove la mossa e' gia' legale.** La mappa non
## decide niente di nuovo — accetta il pezzo sulle Regioni che `highlighted`
## dichiara raggiungibili, e quelle sono le scelte che le regole hanno gia'
## approvato. Il trascinamento e' un altro modo di dire la stessa cosa, non
## un'altra regola.

const AssetCard := preload("res://ui/asset_card.gd")
const MapView := preload("res://ui/map_view.gd")

const CARD: String = "AST_FORCE_LEVY"
const HERE: String = "REG_VALLE_VERDE"
const ELSEWHERE: String = "REG_EREDAN"


func before_each() -> void:
	new_session()


func _card(offers: Array) -> Node:
	var card: Node = AssetCard.new()
	card.render(session.data.assets[CARD], [], false, session.data)
	card.offers = offers
	return card


## Una carta senza scelte non si prende. E' l'altra faccia della Regione senza
## cerchio d'oro: quando non c'e' niente da decidere, il tavolo non si muove.
func test_a_card_with_nothing_to_offer_cannot_be_picked_up() -> void:
	var card: Node = _card([])
	assert_eq(card.call("_get_drag_data", Vector2.ZERO), null, "vuota, non si prende")
	card.free()


## E una carta che porta una scelta viaggia **con quella scelta dentro**: quale
## carta e', e dove puo' cadere. Senza, la mappa avrebbe un pezzo in mano e
## nessun modo di sapere cosa farne.
func test_a_card_carries_what_it_can_do() -> void:
	var card: Node = _card([{"region": HERE, "index": 3}])
	var carried: Variant = card.call("_get_drag_data", Vector2.ZERO)
	assert_true(carried is Dictionary, "il carico c'e'")
	var payload: Dictionary = carried as Dictionary
	assert_eq(str(payload.get("kind", "")), "asset", "e dice di essere una carta")
	assert_eq(str(payload.get("asset_id", "")), CARD, "e quale")
	assert_eq((payload.get("offers", []) as Array).size(), 1, "e cosa sa fare")
	card.free()


## La mappa accetta il pezzo **solo dove la mossa e' legale**, e per la carta
## che quella mossa la porta davvero.
func test_the_map_takes_a_card_only_where_the_move_is_legal() -> void:
	var map: Node = MapView.new()
	map.render(session, str(session.world["turn_order"][0]))
	map.set("highlighted", {HERE: 7})
	map.set("_points", {HERE: Vector2(100.0, 100.0), ELSEWHERE: Vector2(400.0, 100.0)})
	map.set("_radius", 40.0)

	var payload: Dictionary = {
		"kind": "asset", "asset_id": CARD, "offers": [{"region": HERE, "index": 7}],
	}
	assert_true(
		map.call("_can_drop_data", Vector2(100.0, 100.0), payload),
		"sulla Regione raggiungibile la carta cade"
	)
	assert_false(
		map.call("_can_drop_data", Vector2(400.0, 100.0), payload),
		"su una Regione che non e' fra le raggiungibili, no"
	)
	assert_false(
		map.call("_can_drop_data", Vector2(700.0, 700.0), payload),
		"e sul vuoto nemmeno"
	)
	map.free()


## Una carta che sa muovere non puo' cadere dove **nessuna sua mossa arriva**:
## la Regione e' raggiungibile, ma non da quella carta. Sono due filtri diversi
## e servono tutti e due — il primo lo mette lo schermo, il secondo la carta.
func test_a_card_cannot_land_where_it_has_no_move() -> void:
	var map: Node = MapView.new()
	map.render(session, str(session.world["turn_order"][0]))
	map.set("highlighted", {HERE: 7, ELSEWHERE: 9})
	map.set("_points", {HERE: Vector2(100.0, 100.0), ELSEWHERE: Vector2(400.0, 100.0)})
	map.set("_radius", 40.0)

	# La carta sa muovere solo verso HERE, anche se ELSEWHERE e' raggiungibile
	# con un'altra carta.
	var payload: Dictionary = {
		"kind": "asset", "asset_id": CARD, "offers": [{"region": HERE, "index": 7}],
	}
	assert_true(map.call("_can_drop_data", Vector2(100.0, 100.0), payload), "dove sa andare, si'")
	assert_false(
		map.call("_can_drop_data", Vector2(400.0, 100.0), payload),
		"dove non sa andare, no — anche se la Regione e' raggiungibile"
	)
	map.free()


## E quando cade, la mappa dice **quale scelta** e' stata fatta: l'indice che
## `ask()` sta aspettando, preso dalle offerte della carta e non indovinato.
func test_dropping_a_card_answers_the_question() -> void:
	var map: Node = MapView.new()
	map.render(session, str(session.world["turn_order"][0]))
	map.set("highlighted", {HERE: 7})
	map.set("_points", {HERE: Vector2(100.0, 100.0)})
	map.set("_radius", 40.0)

	var answered: Array = []
	map.connect("card_dropped", func(index: int) -> void: answered.append(index))
	map.call("_drop_data", Vector2(100.0, 100.0), {
		"kind": "asset", "asset_id": CARD, "offers": [{"region": HERE, "index": 7}],
	})
	assert_eq(answered, [7], "la caduta risponde con la scelta della carta")

	# E una caduta fuori bersaglio non risponde niente: meglio zitti che una
	# mossa che nessuno ha chiesto.
	map.call("_drop_data", Vector2(700.0, 700.0), {
		"kind": "asset", "asset_id": CARD, "offers": [{"region": HERE, "index": 7}],
	})
	assert_eq(answered, [7], "e una caduta fuori non risponde")
	map.free()


## Quello che viaggia non e' per forza una carta: la mappa non deve rompersi ne'
## accettare qualunque cosa le arrivi addosso.
func test_the_map_ignores_what_is_not_a_card() -> void:
	var map: Node = MapView.new()
	map.render(session, str(session.world["turn_order"][0]))
	map.set("highlighted", {HERE: 7})
	map.set("_points", {HERE: Vector2(100.0, 100.0)})
	map.set("_radius", 40.0)
	for junk in [null, "una stringa", 42, {"kind": "altro"}]:
		assert_false(
			map.call("_can_drop_data", Vector2(100.0, 100.0), junk),
			"«%s» non e' una carta e non cade" % str(junk)
		)
	map.free()


## --- i posti che non sono la mappa (D-231) -----------------------------------
##
## Le Regioni ce l'avevano; le domande e le case no, e finche' non ce l'hanno le
## carte che parlano a loro — INFLUENZARE, TRAMARE, FORGIARE — restano bottoni.

const DropSlot := preload("res://ui/drop_slot.gd")


func _slot(field: String, key: String) -> Node:
	var slot: Node = DropSlot.new()
	slot.field = field
	slot.key = key
	return slot


## Un posto accetta una carta solo se quella carta porta una scelta **per questo
## soggetto**. La domanda accanto non c'entra.
func test_a_slot_takes_only_what_speaks_to_it() -> void:
	var slot: Node = _slot("tension", "TEN_FAMINE")
	var mine: Dictionary = {
		"kind": "asset", "asset_id": CARD,
		"offers": [{"tension": "TEN_FAMINE", "index": 2}],
	}
	var other: Dictionary = {
		"kind": "asset", "asset_id": CARD,
		"offers": [{"tension": "TEN_ROADS", "index": 5}],
	}
	assert_true(slot.call("_can_drop_data", Vector2.ZERO, mine), "la sua domanda si'")
	assert_false(slot.call("_can_drop_data", Vector2.ZERO, other), "un'altra domanda no")
	assert_false(
		slot.call("_can_drop_data", Vector2.ZERO, {
			"kind": "asset", "asset_id": CARD, "offers": [{"region": HERE, "index": 1}],
		}),
		"e una scelta che parla di una Regione nemmeno"
	)
	slot.free()


## **Su un soggetto una carta puo' saper fare due cose opposte**, alzare e
## abbassare. La caduta non sceglie per il giocatore: restringe, e le manda
## tutte e due. Al tavolo e' cosi' — posi la carta sulla domanda, e *poi* dici
## se la alzi o la abbassi.
func test_a_slot_hands_back_every_choice_it_holds() -> void:
	var slot: Node = _slot("tension", "TEN_FAMINE")
	# Una lambda in GDScript cattura **per valore**: riassegnare il nome catturato
	# non esce dalla lambda. Si muta l'array, non lo si sostituisce — la prima
	# stesura riassegnava e leggeva sempre una lista vuota.
	var answered: Array = []
	slot.connect(
		"card_dropped",
		func(indices: Array) -> void: answered.append_array(indices)
	)
	slot.call("_drop_data", Vector2.ZERO, {
		"kind": "asset", "asset_id": CARD,
		"offers": [
			{"tension": "TEN_FAMINE", "index": 2},
			{"tension": "TEN_FAMINE", "index": 3},
			{"tension": "TEN_ROADS", "index": 9},
		],
	})
	assert_eq(answered, [2, 3], "le sue due, e non quella dell'altra domanda")
	slot.free()


## E un posto senza soggetto non prende niente: e' il caso di ogni sezione del
## pannello che non e' bersaglio di nessuna carta.
func test_a_slot_without_a_subject_takes_nothing() -> void:
	var slot: Node = _slot("", "")
	assert_false(
		slot.call("_can_drop_data", Vector2.ZERO, {
			"kind": "asset", "asset_id": CARD, "offers": [{"tension": "TEN_FAMINE", "index": 2}],
		}),
		"senza soggetto non e' un bersaglio"
	)
	slot.free()


## **E ogni scelta che parla di qualcosa di visibile deve avere il suo posto.**
##
## E' la prova che tiene insieme le due meta': il decisore dice di cosa parla
## una scelta (`subject`), il pannello apre un posto per ogni domanda e per ogni
## casa. Se domani nasce un verbo che parla a una domanda e nessuno apre il
## posto, la carta torna a essere un bottone **in silenzio** — ed e' il modo in
## cui questa mossa si disferebbe senza che nessuno se ne accorga.
func test_every_subject_a_card_speaks_to_has_a_place() -> void:
	var StatusPanel := preload("res://ui/status_panel.gd")
	var panel: Node = StatusPanel.new()
	var viewer: String = str(session.world["turn_order"][0])
	panel.render(session, viewer)

	var places: Dictionary = panel.get("slots")
	for tension_id in session.world["tensions"]:
		assert_true(
			places.has("tension:%s" % str(tension_id)),
			"la domanda %s ha un posto dove far cadere una carta" % str(tension_id)
		)
	for entity_id in session.world["turn_order"]:
		if str(entity_id) == viewer:
			continue
		assert_true(
			places.has("entity:%s" % str(entity_id)),
			"la casa %s ha un posto dove far cadere una carta" % str(entity_id)
		)
	panel.free()
