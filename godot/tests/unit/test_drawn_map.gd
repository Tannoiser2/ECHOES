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
		assert_eq(map.size(), 7, "sette tessere sul tavolo al seme %d (D-510)" % seed_value)
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


## **La rosa, e il confine che e' un varco** (D-510, parola del committente:
## *«la tessera NON si gira»*).
##
## La tessera non si gira piu': ogni Regione porta la sua casella (`map_slot`)
## e ci va dritta. Quindi qui non si prova piu' *dove* finisce una tessera —
## lo dice il dato — ma le tre cose che la rosa promette:
##
## 1. ogni adiacenza e' **un varco vero**: le due caselle si toccano nella
##    rosa, e il lato che combacia e' aperto su tutte e due;
## 2. **nessun varco e' perso**: due caselle vicine coi lati aperti **sono**
##    vicine;
## 3. il tocco e' simmetrico.
##
## La prova ricalcola la geometria **da sola**, da `map_slot` e da
## `region.edges`: una prova che usa la stessa funzione che sta provando non
## prova niente.
const LATI: Array = ["N", "NE", "SE", "S", "SO", "NO"]
const CASELLE: Array = ["C", "P1", "P2", "P3", "P4", "P5", "P6"]


func _petalo(casella: String) -> int:
	return -1 if casella == "C" else int(casella.substr(1)) - 1


## Il lato con cui `qui` guarda `la`, vuoto se le due caselle non si toccano.
func _lato_fra(qui: String, la: String) -> String:
	var a: int = _petalo(qui)
	var b: int = _petalo(la)
	if a < 0 and b < 0:
		return ""
	if a < 0:
		return str(LATI[b])
	if b < 0:
		return str(LATI[(a + 3) % 6])
	if (a + 1) % 6 == b:
		return str(LATI[(a + 2) % 6])
	if (b + 1) % 6 == a:
		return str(LATI[(a + 4) % 6])
	return ""


func _casella_di(region_id: String) -> String:
	return str((data().regions[region_id] as Dictionary).get("map_slot", ""))


func _varchi(region_id: String) -> Array:
	return (data().regions[region_id] as Dictionary).get("edges", []) as Array


func test_a_border_is_a_passage_open_on_both_sides() -> void:
	var opened: RefCounted = _open(7000)
	var posa: Dictionary = opened.world["map_positions"] as Dictionary
	var vicini: Dictionary = opened.world["adjacency"] as Dictionary
	assert_eq(posa.size(), CASELLE.size(), "le sette caselle della rosa sono tutte occupate")
	assert_false(opened.world.has("map_rotations"),
		"e nessuna tessera porta una rotazione: non si girano piu'")

	# Una casella, una tessera — e ogni tessera in quella che il dato le da'.
	var occupate: Dictionary = {}
	for tile in posa:
		var casella: String = _casella_di(str(tile))
		assert_true(CASELLE.has(casella), "%s sa dove va (%s)" % [str(tile), casella])
		assert_false(occupate.has(casella), "una casella, una tessera (%s)" % casella)
		occupate[casella] = str(tile)

	# **Il caso che deve dare non-zero**: se le adiacenze fossero zero, tutto
	# quello che segue passerebbe a vuoto.
	var archi: int = 0
	for here in vicini:
		archi += (vicini[here] as Array).size()
	assert_true(archi > 0, "la rosa ha almeno un confine")

	for qui in CASELLE:
		for la in CASELLE:
			if str(qui) == str(la) or not occupate.has(str(qui)) or not occupate.has(str(la)):
				continue
			var qui_id: String = str(occupate[str(qui)])
			var la_id: String = str(occupate[str(la)])
			var lato: String = _lato_fra(str(qui), str(la))
			var aperto: bool = lato != "" \
				and _varchi(qui_id).has(lato) \
				and _varchi(la_id).has(_lato_fra(str(la), str(qui)))
			assert_eq(
				(vicini[qui_id] as Array).has(la_id), aperto,
				"%s e %s: decide il varco, non l'accostamento" % [qui_id, la_id]
			)
			if aperto:
				assert_true((vicini[la_id] as Array).has(qui_id),
					"e il tocco e' simmetrico (%s-%s)" % [qui_id, la_id])
	opened.dispose()


## **Due petali stanno dietro una vicina** (D-510). `P3` e `P6` non guardano la
## capitale: ci si arriva **solo passando per** `P2` e per `P5`. E' quello che
## da' al mondo una geografia invece di una ruota — con sei raggi tutto sarebbe
## a due passi e la capitale sarebbe uno svincolo — ed e' anche quello che
## rende viva la casella CHIUDI LA STRADA, che su una ruota non puo' tagliare
## fuori niente. Senza questa prova i raggi tornerebbero senza che nessuno se
## ne accorga.
func test_two_petals_stand_behind_a_neighbour() -> void:
	for seed_value in range(7000, 7010):
		var opened: RefCounted = _open(seed_value)
		var vicini: Dictionary = opened.world["adjacency"] as Dictionary
		var capitale: String = ""
		for region_id in opened.world["regions"]:
			if _casella_di(str(region_id)) == "C":
				capitale = str(region_id)
		assert_ne(capitale, "", "la capitale sta al centro, al seme %d" % seed_value)
		var dietro: Array = []
		for region_id in opened.world["regions"]:
			if str(region_id) == capitale:
				continue
			if not (vicini[capitale] as Array).has(str(region_id)):
				dietro.append(str(region_id))
		assert_eq(dietro.size(), 2,
			"due petali non guardano la capitale, al seme %d: %s" % [seed_value, str(dietro)])
		# E ci si arriva lo stesso, passando per la vicina.
		for region_id in dietro:
			var passando: bool = false
			for n in (vicini[str(region_id)] as Array):
				if (vicini[capitale] as Array).has(str(n)):
					passando = true
			assert_true(passando,
				"a %s si arriva passando per una vicina (seme %d)" % [str(region_id), seed_value])
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
		assert_eq(tessere.size(), 7, "sette tessere sul tavolo, al seme %d" % seed_value)
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

	# **Il caso che conta si fabbrica, non si spera.** Le rose possibili sono
	# otto: un seme fissato a mano potrebbe pescare la stessa della prima era, e
	# allora la prova passerebbe verde senza aver provato niente. Si cerca un
	# seme che ne peschi un'altra, e se non c'e' si va rossi.
	var second: RefCounted = null
	var blind_map: Array = []
	for candidate in range(9100, 9160):
		var trying: RefCounted = GameSession.new(data())
		var trying_seats: Array = GameSession.seats_for(data(), "CHR_00", candidate)
		assert_true(trying.setup("CHR_00", trying_seats, candidate), "CHR_00 si apre al seme %d" % candidate)
		var map: Array = (trying.world["regions"] as Dictionary).keys()
		map.sort()
		var mine: Array = first_map.duplicate()
		mine.sort()
		if "/".join(PackedStringArray(map)) != "/".join(PackedStringArray(mine)):
			second = trying
			blind_map = map
			break
		trying.dispose()
	assert_true(second != null, "c'e' un seme che da solo pescherebbe un'altra rosa")
	assert_true(not blind_map.is_empty(), "e quella rosa non e' vuota")
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


## **Sul tavolo pescato il mazzetto e' una carta, gia' girata** (D-467,
## D-468). Fino a 0.1.436 valeva D-264: il mazzetto teneva tutte le Tensioni
## del Tema che la mappa reggeva, e ne girava una quando il Tema si scaldava,
## cosi' il tavolo non sapeva mai quante domande aveva. Ora ogni Tema ha la
## sua domanda pescata, scoperta dall'inizio, e sotto non c'e' altro. La regola
## vecchia resta solo per le Chronicle senza `per_theme`.
func test_the_drawn_decks_are_one_turned_card_per_theme() -> void:
	var opened: RefCounted = _open(7000)
	for theme_id in opened.world["theme_decks"]:
		assert_true(
			(opened.world["theme_decks"][theme_id] as Array).is_empty(),
			"sotto la carta girata di %s non c'e' altro" % str(theme_id)
		)
		var front: String = str(opened.tensions.theme_front(str(theme_id)))
		assert_ne(front, "", "%s ha la sua carta girata" % str(theme_id))
		assert_eq(
			str((data().tensions.get(front, {}) as Dictionary).get("theme", "")),
			str(theme_id), "«%s» e' la carta del suo Tema" % front
		)
		assert_true(
			(opened.world["tensions"] as Dictionary).has(front),
			"e la questione e' gia' in gioco: girare non apre niente di nuovo"
		)
	opened.dispose()


## **Girare un mazzetto vuoto non inventa una domanda.** Il fronte resta la
## carta pescata, e le questioni in gioco restano quelle.
func test_flipping_an_empty_deck_opens_nothing() -> void:
	var opened: RefCounted = _open(7000)
	var before: int = (opened.world["tensions"] as Dictionary).size()
	for theme_id in opened.world["theme_decks"]:
		var front: String = str(opened.tensions.theme_front(str(theme_id)))
		assert_eq(str(opened.tensions.flip_theme_front(str(theme_id))), "", "il mazzetto di %s non gira" % str(theme_id))
		assert_eq(str(opened.tensions.theme_front(str(theme_id))), front, "e il fronte resta la carta pescata")
	assert_eq((opened.world["tensions"] as Dictionary).size(), before, "le questioni in gioco sono le stesse")
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
