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


## **La posa comanda, e il confine e' un varco** (D-275, riscritta da D-390 su
## parola del committente: *«se due lati hanno adiacenze in comune lo
## spostamento e' permesso»*).
##
## Le tessere non stanno piu' in griglia nell'ordine di pesca: si posano una
## alla volta accanto a una gia' posata, **girandole finche' il lato che si
## tocca porta un varco su tutte e due**. Quindi qui non si prova piu' *dove*
## finisce ogni tessera — quello lo decide la posa — ma le tre cose che la
## regola promette:
##
## 1. ogni adiacenza e' **un varco vero**: le due tessere si toccano di lato, e
##    i due lati che combaciano sono aperti tutti e due;
## 2. **nessun varco e' perso**: due tessere accostate coi lati aperti **sono**
##    vicine;
## 3. la diagonale non e' mai un tocco, e il tocco e' simmetrico.
##
## La prova ricalcola i varchi **da sola**, da `region.edges` e da
## `map_rotations`, invece di chiamare l'aiutante del motore: una prova che usa
## la stessa funzione che sta provando non prova niente.
const LATI: Array = ["N", "E", "S", "O"]


## I varchi di una tessera come stanno sul tavolo, girata di `turn`.
func _varchi(region_id: String, turn: int) -> Array:
	var printed: Array = (data().regions[region_id] as Dictionary).get("edges", []) as Array
	var out: Array = []
	for side in printed:
		out.append(str(LATI[(LATI.find(str(side)) + turn) % 4]))
	return out


func test_a_border_is_a_passage_open_on_both_sides() -> void:
	var opened: RefCounted = _open(7000)
	var posa: Dictionary = opened.world["map_positions"] as Dictionary
	var giri: Dictionary = opened.world["map_rotations"] as Dictionary
	var vicini: Dictionary = opened.world["adjacency"] as Dictionary
	assert_eq(posa.size(), 6, "le sei tessere pescate sono tutte sul tavolo")
	assert_eq(giri.size(), 6, "e ognuna sa di quanto e' stata girata")
	for tile in posa:
		assert_true(
			int(giri[str(tile)]) >= 0 and int(giri[str(tile)]) <= 3,
			"la rotazione e' un quarto di giro: %s" % str(giri[str(tile)])
		)
		assert_true(
			int((posa[str(tile)] as Array)[0]) >= 0
			and int((posa[str(tile)] as Array)[1]) >= 0,
			"e la posizione sta dentro il foglio: %s" % str(posa[str(tile)])
		)
	# Due caselle non possono ospitare la stessa tessera.
	var occupate: Dictionary = {}
	for tile in posa:
		var key: String = "%d,%d" % [
			int((posa[str(tile)] as Array)[0]), int((posa[str(tile)] as Array)[1])
		]
		assert_false(occupate.has(key), "una casella, una tessera (%s)" % key)
		occupate[key] = true

	# **Il caso che deve dare non-zero**: se le adiacenze fossero zero, tutto
	# quello che segue passerebbe a vuoto.
	var archi: int = 0
	for here in vicini:
		archi += (vicini[here] as Array).size()
	assert_true(archi > 0, "il tavolo ha almeno un confine")

	var passi: Dictionary = {"N": [0, -1], "E": [1, 0], "S": [0, 1], "O": [-1, 0]}
	# 1. Ogni adiacenza dichiarata e' un varco vero.
	for here in vicini:
		for there in (vicini[here] as Array):
			var qui: Array = posa[str(here)] as Array
			var la: Array = posa[str(there)] as Array
			var dx: int = int(la[0]) - int(qui[0])
			var dy: int = int(la[1]) - int(qui[1])
			assert_eq(absi(dx) + absi(dy), 1,
				"%s e %s si toccano di lato, non in diagonale" % [str(here), str(there)])
			var lato: String = ""
			for side in LATI:
				if int((passi[str(side)] as Array)[0]) == dx \
						and int((passi[str(side)] as Array)[1]) == dy:
					lato = str(side)
			assert_true(
				_varchi(str(here), int(giri[str(here)])).has(lato),
				"%s ha il varco sul lato che guarda %s" % [str(here), str(there)]
			)
			assert_true(
				_varchi(str(there), int(giri[str(there)])).has(
					str(LATI[(LATI.find(lato) + 2) % 4])
				),
				"e %s ce l'ha dall'altra parte" % str(there)
			)
			# 3. E il tocco e' simmetrico.
			assert_true(
				(vicini[str(there)] as Array).has(str(here)),
				"il tocco e' simmetrico (%s-%s)" % [str(here), str(there)]
			)

	# 2. E nessun varco e' perso: due tessere accostate coi lati aperti sono
	#    vicine per forza.
	for here in posa:
		for there in posa:
			if str(here) == str(there):
				continue
			var qui: Array = posa[str(here)] as Array
			var la: Array = posa[str(there)] as Array
			var dx: int = int(la[0]) - int(qui[0])
			var dy: int = int(la[1]) - int(qui[1])
			if absi(dx) + absi(dy) != 1:
				continue
			var lato: String = ""
			for side in LATI:
				if int((passi[str(side)] as Array)[0]) == dx \
						and int((passi[str(side)] as Array)[1]) == dy:
					lato = str(side)
			var aperto: bool = _varchi(str(here), int(giri[str(here)])).has(lato) \
				and _varchi(str(there), int(giri[str(there)])).has(
					str(LATI[(LATI.find(lato) + 2) % 4])
				)
			assert_eq(
				(vicini[str(here)] as Array).has(str(there)), aperto,
				"%s e %s: accostate, e il varco decide" % [str(here), str(there)]
			)
	opened.dispose()


## **E nessuna tessera resta isolata**, che e' la meta' della regola che il
## committente ha chiesto per nome. La posa la garantisce per costruzione — una
## tessera entra solo attaccandosi a una gia' posata attraverso un varco — ma
## una promessa per costruzione va provata lo stesso, e su piu' di un seme.
func test_the_map_is_one_piece() -> void:
	for seed_value in [7000, 7001, 7002, 7003, 7004, 7005, 7006, 7007, 7008, 7009]:
		var opened: RefCounted = _open(seed_value)
		var vicini: Dictionary = opened.world["adjacency"] as Dictionary
		var tessere: Array = (opened.world["regions"] as Dictionary).keys()
		assert_eq(tessere.size(), 6, "sei tessere sul tavolo, al seme %d" % seed_value)
		var visti: Dictionary = {}
		var coda: Array = [str(tessere[0])]
		while not coda.is_empty():
			var qui: String = str(coda.pop_back())
			if visti.has(qui):
				continue
			visti[qui] = true
			for n in (vicini.get(qui, []) as Array):
				coda.append(str(n))
		assert_eq(
			visti.size(), tessere.size(),
			"dal primo posto si arriva a tutte, al seme %d" % seed_value
		)
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
