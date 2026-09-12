extends "res://tests/test_case.gd"
## **Una casa che si siede trova sempre la sua terra** (D-513).
##
## Una tessera puo' nascere con una casa sopra: e' la sua terra, ed e' il gettone
## che sta gia' sul cartone quando la scatola si apre. La pescata puo' cambiarne
## l'eta' — Eredan o Eredan delle Sei Porte, la stessa citta' in due secoli — ma
## non deve poterla portare via.
##
## Prima di D-513 la portava via, e non se ne lamentava niente: **Vaerax restava
## senza montagna una volta su tre, i Nahr senza pascoli una su quattro**. Il
## verso opposto il motore lo sapeva gia' fare — una tessera che esce con sopra
## una casa che non gioca nasce libera (`world_state_factory.gd`) — ma su una
## casa seduta senza terra non aveva niente da dire, e una partita cominciava
## con un giocatore da nessuna parte.
##
## La regola che lo impedisce e' di **disegno**, non di motore: la sede e' una
## **casella intera**, cioe' tutte le candidate di quel posto portano la stessa
## casa. `validate_physical` la sorveglia dal lato dei dati; qui si prova che il
## tavolo vero, stesso dal motore, la mantenga.

const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const SLOTS: Array = ["C", "P1", "P2", "P3", "P4", "P5", "P6"]


## Chi tiene cosa, **letto dai dati** e non ricopiato: il giorno che una casa
## nuova prende una terra, queste prove se ne accorgono da sole.
func _lands_by_house() -> Dictionary:
	var out: Dictionary = {}
	for region_id in data().regions:
		var who: Variant = (data().regions[str(region_id)] as Dictionary).get("control", null)
		if who != null:
			if not out.has(str(who)):
				out[str(who)] = []
			(out[str(who)] as Array).append(str(region_id))
	for house in out:
		(out[house] as Array).sort()
	return out


func _all_region_ids() -> Array:
	var ids: Array = []
	for region_id in data().regions:
		ids.append(str(region_id))
	ids.sort()
	return ids


func _holder(region_id: String) -> String:
	var who: Variant = (data().regions[region_id] as Dictionary).get("control", null)
	return "" if who == null else str(who)


## **Il caso che deve dare non-zero.**
##
## Senza questo, la prova qui sotto direbbe verde anche se `resolve_map` avesse
## smesso di pescare, o se il conto delle case fosse sempre vuoto. Qui si
## **fabbrica** il difetto che D-513 ha chiuso: si toglie la casa a una sola
## candidata della sua casella — nel conto, non nei dati — e si pretende che la
## pescata la lasci senza terra almeno una volta.
##
## E' anche la misura di quanto costava: la casella di Vaerax ha tre candidate,
## quindi una su tre.
func test_a_split_slot_would_leave_a_house_landless() -> void:
	var lands: Dictionary = _lands_by_house()
	assert_true(lands.size() > 0, "qualche casa nasce con una terra sua")

	# La casa con piu' terre: e' quella su cui il difetto si vede meglio, e si
	# sceglie dal dato invece di scriverne il nome qui.
	var chosen: String = ""
	for house in lands:
		if chosen == "" or (lands[house] as Array).size() > (lands[chosen] as Array).size():
			chosen = str(house)
	var mine: Array = lands[chosen] as Array
	assert_true(mine.size() >= 2, "e la sua casella ha piu' di una candidata: %s" % chosen)
	var wounded: String = str(mine[0])

	var ids: Array = _all_region_ids()
	var landless: int = 0
	for i in range(300):
		var drawn: Array = WorldStateFactory.resolve_map(
			{"region_pool": {"candidates": ids, "count": SLOTS.size()}},
			RngService.new(9100 + i), data()
		)
		assert_eq(drawn.size(), SLOTS.size(), "sette tessere, una per casella")
		var found: bool = false
		for region_id in drawn:
			if _holder(str(region_id)) == chosen and str(region_id) != wounded:
				found = true
				break
		if not found:
			landless += 1
	assert_true(
		landless > 0,
		(
			"togliendo la casa a una sola candidata (%s), la pescata lascerebbe %s senza terra: "
			+ "e' successo %d volte su 300 — se qui uscisse zero sarebbe cieca la prova"
		) % [wounded, chosen, landless]
	)


## **E coi dati veri non succede mai.** Lo stesso conto, senza la ferita.
func test_every_house_finds_its_land_on_every_rose() -> void:
	var lands: Dictionary = _lands_by_house()
	var ids: Array = _all_region_ids()
	var seen: Dictionary = {}
	for i in range(300):
		var drawn: Array = WorldStateFactory.resolve_map(
			{"region_pool": {"candidates": ids, "count": SLOTS.size()}},
			RngService.new(9100 + i), data()
		)
		for house in lands:
			var found: bool = false
			for region_id in drawn:
				if _holder(str(region_id)) == str(house):
					found = true
					break
			assert_true(found, "%s trova la sua terra sulla rosa %s" % [str(house), str(drawn)])
			seen[str(house)] = true
	assert_eq(seen.size(), lands.size(), "e tutte le case con una terra sono state guardate")


## **La partita vera, fino al gettone sul cartone.**
##
## Le due prove qui sopra chiamano `resolve_map` a mano. Questa apre CHR_00 —
## l'unica Chronicle che pesca mappa e tavolo — e guarda il mondo steso: ogni
## casa che si e' **seduta** e che ha una terra scritta dev'essere segnata su
## una tessera del tavolo. Cosi' si prende anche il caso in cui il motore
## azzerasse il controllo per un'altra ragione.
func test_a_real_setup_seats_no_house_without_its_land() -> void:
	var lands: Dictionary = _lands_by_house()
	var landless: int = 0
	var checked: int = 0
	var with_land: Dictionary = {}
	for i in range(60):
		var seed_value: int = 7000 + i
		var opened: RefCounted = GameSession.new(data())
		var seats: Array = GameSession.seats_for(data(), "CHR_00", seed_value)
		assert_true(opened.setup("CHR_00", seats, seed_value),
			"CHR_00 si apre al seme %d" % seed_value)
		var held: Dictionary = {}
		for region_id in opened.world["regions"]:
			var who: Variant = (opened.world["regions"][str(region_id)] as Dictionary).get(
				"control", null
			)
			if who != null:
				held[str(who)] = true
		for entity_id in seats:
			if lands.has(str(entity_id)):
				checked += 1
				with_land[str(entity_id)] = true
				if not held.has(str(entity_id)):
					landless += 1
		opened.dispose()
	assert_true(checked > 0, "in sessanta partite qualche casa con una terra si e' seduta")
	assert_eq(landless, 0, "e nessuna si e' seduta senza trovarla")
	assert_eq(with_land.size(), lands.size(),
		"e in sessanta partite si sono viste tutte e %d le case con una terra" % lands.size())
