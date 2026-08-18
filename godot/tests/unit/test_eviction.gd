extends "res://tests/test_case.gd"
## D-067: un Consiglio che ti caccia tiene la porta chiusa fino a fine atto.
##
## La sonda delle espulsioni ha misurato il perche di questa regola: senza,
## 12 espulsioni su 13 cadute su una Regione del Minimo venivano recuperate con
## una MOVE al round dopo, e NONE restava un livello teorico (1 su 400).

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return Effect.source("developer", "TEST", "", 1, 1, 0)


## La porta sbarrata vince anche sul diritto di rientrare in una Regione
## iniziale, che e esattamente il caso che rendeva il recupero gratis.
func test_the_evicted_tag_bars_the_way_back() -> void:
	assert_true(
		session.service.can_move_to("ENT_NAHR", "REG_TERRE_NAHR"),
		"senza tag, una Regione iniziale e sempre raggiungibile"
	)
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", "ENT_NAHR", {"tag": "evicted:REG_TERRE_NAHR"}, _source()
	))
	assert_false(
		session.service.can_move_to("ENT_NAHR", "REG_TERRE_NAHR"),
		"cacciato dalle Terre Nahr, non ci rientra finche l'atto non gira"
	)
	assert_true(
		session.service.can_move_to("ENT_NAHR", "REG_VALLE_VERDE"),
		"la porta chiusa e una sola: le altre Regioni restano raggiungibili"
	)


## La stagione gira e le porte si riaprono, con un Effect nel log come ogni
## altra mutazione del mondo.
func test_the_season_turning_lifts_the_bar() -> void:
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", "ENT_NAHR", {"tag": "evicted:REG_TERRE_NAHR"}, _source()
	))
	session.chronicle._lift_evictions(2)
	assert_true(
		session.service.can_move_to("ENT_NAHR", "REG_TERRE_NAHR"),
		"al giro d'atto la Regione torna raggiungibile"
	)
	var lifted: bool = false
	for effect in session.world["effect_log"]:
		if str(effect["type"]) != "REMOVE_ENTITY_TAG":
			continue
		if str(effect["source"].get("id", "")) != "SEASON_TURNS":
			continue
		if str(effect["payload"].get("tag", "")) == "evicted:REG_TERRE_NAHR":
			lifted = true
	assert_true(lifted, "il giro di stagione e nel log degli Effect, non un colpo di spugna")


## La risoluzione mette il tag solo a chi viene cacciato da qualcun altro, e
## solo se il colpo e andato a segno.
func test_the_bar_is_set_for_a_victim_and_not_for_a_cost() -> void:
	session.confluence.current = {"proponent": "ENT_ALDRIC"}

	# Un'espulsione vera: il bersaglio era li, e non era il proponente.
	var applied: Array = []
	var eviction: Dictionary = Effect.make(
		"REMOVE_PRESENCE", "entity", "ENT_NAHR", {"region_id": "REG_TERRE_NAHR"}, _source()
	)
	session.confluence._apply(applied, eviction)
	session.confluence._bar_return(applied, eviction, _source())
	assert_true(
		(session.world["entities"]["ENT_NAHR"]["tags"] as Array).has("evicted:REG_TERRE_NAHR"),
		"la vittima porta il tag della porta chiusa"
	)

	# Un costo autoinflitto: il proponente che parte non si sbarra la strada.
	var self_cost: Dictionary = Effect.make(
		"REMOVE_PRESENCE", "entity", "ENT_ALDRIC", {"region_id": "REG_EREDAN"}, _source()
	)
	session.confluence._apply(applied, self_cost)
	session.confluence._bar_return(applied, self_cost, _source())
	assert_false(
		(session.world["entities"]["ENT_ALDRIC"]["tags"] as Array).has("evicted:REG_EREDAN"),
		"un costo che ci si infligge da soli non chiude nessuna porta"
	)

	# Un optional andato a vuoto: nessuno da cacciare, nessuna porta chiusa.
	var missed: Dictionary = Effect.make(
		"REMOVE_PRESENCE", "entity", "ENT_LYRA",
		{"region_id": "REG_TERRE_NAHR", "optional": true}, _source()
	)
	session.confluence._apply(applied, missed)
	session.confluence._bar_return(applied, missed, _source())
	assert_false(
		(session.world["entities"]["ENT_LYRA"]["tags"] as Array).has("evicted:REG_TERRE_NAHR"),
		"l'optional a vuoto resta un no-op da cima a fondo"
	)


## D-130: il seggio ricorda gli sradicamenti. Il primo e' un fatto; il secondo
## nello stesso anno e' una natura - il segno che la successione legge per far
## nascere la Diaspora. I tag d'entita' non si ereditano: il conto riparte
## da solo a ogni Chronicle.
func test_two_evictions_in_a_year_leave_the_rootless_sign() -> void:
	session.confluence.current = {"proponent": "ENT_ALDRIC"}
	var applied: Array = []
	var first: Dictionary = Effect.make(
		"REMOVE_PRESENCE", "entity", "ENT_NAHR", {"region_id": "REG_TERRE_NAHR"}, _source()
	)
	session.confluence._apply(applied, first)
	session.confluence._bar_return(applied, first, _source())
	var tags: Array = session.world["entities"]["ENT_NAHR"]["tags"]
	assert_true(tags.has("uprooted"), "la prima cacciata si scrive addosso")
	assert_false(tags.has("twice_uprooted"), "una volta sola non e' ancora una natura")

	var second: Dictionary = Effect.make(
		"REMOVE_PRESENCE", "entity", "ENT_NAHR", {"region_id": "REG_VALLE_VERDE"}, _source()
	)
	session.confluence._apply(applied, second)
	session.confluence._bar_return(applied, second, _source())
	assert_true(
		(session.world["entities"]["ENT_NAHR"]["tags"] as Array).has("twice_uprooted"),
		"la seconda nello stesso anno e' la natura che la successione legge"
	)


## D-130: la Diaspora non ha piu' un centro - la porta sbarrata dal Consiglio
## non la tiene. Il rientro costa comunque la MOVE del round dopo.
func test_the_diaspora_walks_back_through_the_barred_door() -> void:
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", "ENT_NAHR", {"tag": "evicted:REG_TERRE_NAHR"}, _source()
	))
	assert_false(
		session.service.can_move_to("ENT_NAHR", "REG_TERRE_NAHR"),
		"da popolo, la cacciata tiene come sempre"
	)
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", "ENT_NAHR", {"tag": "life:INC_NAHR_DIASPORA"}, _source()
	))
	assert_true(
		session.service.can_move_to("ENT_NAHR", "REG_TERRE_NAHR"),
		"da Diaspora, nessuna porta la tiene"
	)
