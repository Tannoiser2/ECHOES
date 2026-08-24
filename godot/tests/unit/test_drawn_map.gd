extends "res://tests/test_case.gd"
## La mappa a tessere (D-263, Fase C della direzione del committente).
##
## «Per iniziare la prima Chronicle non ci sono scenari»: CHR_00 pesca le
## tessere della mappa, pesca le case, e fa solo le domande che la mappa sa
## reggere. E la mappa e' **della saga**: la seconda era gioca sulle stesse
## tessere, qualunque seme la apra.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func _open(seed_value: int) -> RefCounted:
	var opened: RefCounted = GameSession.new(data())
	var seats: Array = GameSession.seats_for(data(), "CHR_00", seed_value)
	assert_true(opened.setup("CHR_00", seats, seed_value),
		"CHR_00 si apre al seme %d: %s" % [seed_value, str(opened.last_error)])
	return opened


## **La mappa si pesca, e ogni saga ha la sua.** Due semi diversi devono poter
## dare due mappe diverse: si provano i primi dieci e se ne pretendono almeno
## due — un sacchetto che desse sempre le stesse quattro tessere non sarebbe
## una pesca.
func test_the_tiles_are_drawn_and_vary() -> void:
	var maps: Dictionary = {}
	for seed_value in range(7000, 7010):
		var opened: RefCounted = _open(seed_value)
		var map: Array = (opened.world["regions"] as Dictionary).keys()
		assert_eq(map.size(), 6, "sei tessere sul tavolo al seme %d (D-265)" % seed_value)
		map.sort()
		maps["/".join(PackedStringArray(map))] = true
		opened.dispose()
	assert_true(maps.size() >= 2, "dieci semi danno almeno due mappe (%d)" % maps.size())


## **L'anno fa solo le domande che la mappa sa reggere.** Ogni Tensione in
## gioco ha il suo dominio su una tessera uscita, e i suoi segni di fuoco (se
## ne dichiara) esistono sulla mappa.
func test_the_questions_fit_the_map() -> void:
	for seed_value in range(7000, 7005):
		var opened: RefCounted = _open(seed_value)
		var on_map: Dictionary = {}
		for region_id in opened.world["regions"]:
			for tag in (opened.world["regions"][str(region_id)]["tags"] as Array):
				on_map[str(tag)] = true
		for tension_id in opened.world["tensions"]:
			var definition: Dictionary = data().tensions[str(tension_id)]
			assert_true(
				on_map.has("domain:%s" % str(definition["domain"])),
				"«%s» ha il suo dominio sulla mappa del seme %d" % [str(tension_id), seed_value]
			)
			var focus: Array = definition.get("focus_region_tags", []) as Array
			if not focus.is_empty():
				var found: bool = false
				for tag in focus:
					if on_map.has(str(tag)):
						found = true
				assert_true(found, "«%s» trova i suoi segni di fuoco sulla mappa" % [str(tension_id)])
		opened.dispose()


## **La forma del mondo tiene: nessuna tessera isolata.** Le tessere pescate
## si posano accostate — dal primo posto si arriva a tutti gli altri.
func test_the_drawn_map_is_connected() -> void:
	for seed_value in range(7000, 7010):
		var opened: RefCounted = _open(seed_value)
		var map: Array = (opened.world["regions"] as Dictionary).keys()
		var reached: Dictionary = {}
		var frontier: Array = [str(map[0])]
		reached[str(map[0])] = true
		while not frontier.is_empty():
			var here: String = str(frontier.pop_back())
			for neighbour in (opened.world["adjacency"].get(here, []) as Array):
				if not reached.has(str(neighbour)):
					reached[str(neighbour)] = true
					frontier.append(str(neighbour))
		assert_eq(reached.size(), map.size(),
			"dal primo posto si arriva ovunque, al seme %d" % seed_value)
		opened.dispose()


## **Ogni casa seduta comincia sul tavolo, non nella scatola.** Le pedine di
## partenza cadono solo su tessere uscite, e nessuna casa resta senza niente.
func test_every_seated_house_stands_on_the_table() -> void:
	var opened: RefCounted = _open(7000)
	for effect in opened.factory_setup_effects():
		opened.applier.apply(effect)
	for entity_id in opened.world["turn_order"]:
		var standing: Array = opened.service.regions_with_presence(str(entity_id))
		assert_true(standing.size() > 0, "%s si e' accampata da qualche parte" % [str(entity_id)])
		for region_id in standing:
			assert_true(
				(opened.world["regions"] as Dictionary).has(str(region_id)),
				"la pedina di %s sta su una tessera uscita" % [str(entity_id)]
			)
	opened.dispose()


## **La mappa e' della saga.** La seconda era, aperta con un seme diverso,
## eredita e gioca sulle tessere della prima — e le sue domande reggono su
## quelle.
func test_the_saga_keeps_its_map() -> void:
	var first: RefCounted = _open(7000)
	var first_map: Array = (first.world["regions"] as Dictionary).keys()

	var second: RefCounted = GameSession.new(data())
	var seats: Array = GameSession.seats_for(data(), "CHR_00", 9100)
	assert_true(second.setup("CHR_00", seats, 9100), "la seconda era si apre")
	var blind_map: Array = (second.world["regions"] as Dictionary).keys()
	assert_ne("/".join(PackedStringArray(blind_map)), "/".join(PackedStringArray(first_map)),
		"il seme 9100 da solo avrebbe pescato un'altra mappa (il caso che conta)")
	second.inherit_from(first.world)
	var kept: Array = (second.world["regions"] as Dictionary).keys()
	assert_eq("/".join(PackedStringArray(kept)), "/".join(PackedStringArray(first_map)),
		"l'era ereditata gioca sulle tessere della saga")
	for tension_id in second.world["tensions"]:
		var definition: Dictionary = data().tensions[str(tension_id)]
		var on_map: Dictionary = {}
		for region_id in second.world["regions"]:
			for tag in (second.world["regions"][str(region_id)]["tags"] as Array):
				on_map[str(tag)] = true
		assert_true(
			on_map.has("domain:%s" % str(definition["domain"])),
			"anche le domande dell'era nuova reggono sulla mappa della saga"
		)
	first.dispose()
	second.dispose()


## **Sul tavolo pescato il mazzetto e' pieno** (D-264): dentro ci sono tutte
## le Tensioni del Tema che la mappa regge, non solo le aperte — e ognuna sta
## nel mazzetto del suo Tema.
func test_the_drawn_decks_hold_every_question_the_map_bears() -> void:
	var opened: RefCounted = _open(7000)
	var in_decks: int = 0
	for theme_id in opened.world["theme_decks"]:
		for tension_id in (opened.world["theme_decks"][theme_id] as Array):
			in_decks += 1
			assert_eq(
				str((data().tensions[str(tension_id)] as Dictionary).get("theme", "")),
				str(theme_id), "«%s» sta nel mazzetto del suo Tema" % [str(tension_id)]
			)
	assert_true(
		in_decks > (opened.world["tensions"] as Dictionary).size(),
		"il mazzetto tiene piu' carte delle questioni aperte (%d > %d)"
		% [in_decks, (opened.world["tensions"] as Dictionary).size()]
	)
	opened.dispose()


## **Girare apre la questione.** La carta del mazzetto che non era in gioco
## entra con la forma del setup, e da li' il Consiglio la puo' dibattere.
func test_flipping_a_new_card_opens_its_question() -> void:
	var opened: RefCounted = _open(7000)
	var fresh: String = ""
	var theme: String = ""
	for theme_id in opened.world["theme_decks"]:
		for tension_id in (opened.world["theme_decks"][theme_id] as Array):
			if not (opened.world["tensions"] as Dictionary).has(str(tension_id)):
				fresh = str(tension_id)
				theme = str(theme_id)
				break
		if fresh != "":
			break
	assert_ne(fresh, "", "nel mazzetto c'e' una questione non ancora aperta")
	while str(opened.tensions.theme_front(theme)) != fresh:
		assert_ne(str(opened.tensions.flip_theme_front(theme)), "", "il mazzetto gira")
	assert_true(
		(opened.world["tensions"] as Dictionary).has(fresh),
		"la questione girata e' entrata in gioco"
	)
	assert_eq(
		int(opened.world["tensions"][fresh]["current_value"]),
		int((data().tensions[fresh] as Dictionary)["current_value"]),
		"col valore d'apertura scritto sul dato"
	)
	opened.dispose()


## **Nessuna tessera governata da un assente, al primo giro.** Col tavolo
## pescato il padrone scritto sulla tessera puo' non sedersi: la tessera
## comincia di nessuno.
func test_no_tile_is_ruled_by_an_absent_house() -> void:
	for seed_value in range(7000, 7005):
		var opened: RefCounted = _open(seed_value)
		for region_id in opened.world["regions"]:
			var control: Variant = opened.world["regions"][str(region_id)].get("control", null)
			if control == null:
				continue
			assert_true(
				(opened.world["entities"] as Dictionary).has(str(control)),
				"il padrone di %s siede al tavolo (seme %d)" % [str(region_id), seed_value]
			)
		opened.dispose()
