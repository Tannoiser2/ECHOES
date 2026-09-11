extends "res://tests/test_case.gd"
## **Il ponte fra quello che vuoi e quello che peschi** (ISSUES 136, punto 5).
##
## Il mazzetto personale (D-499) si compone sulle **famiglie che la presenza
## raggiunge**: la mappa decide da quali mazzi peschi. I tre obiettivi che l'anno
## ti da' non entravano nel conto, e sei su 19 chiedono un **gesto fatto
## quest'anno** piu' tre carte di una famiglia — misurato: **94 coppie
## casa-obiettivo su 904 che chiedono qualcosa** restavano senza una carta per
## provarci.
##
## Le due prove che contano sono **fabbricate**: si da' a una casa un obiettivo
## che chiede proprio la famiglia che la sua mappa non le lascia pescare. Cercare
## quel caso fra i dati spediti vorrebbe dire misurare la pesca, e il giorno in
## cui la pesca cambia la prova smetterebbe di provare in silenzio.

const Bridge := preload("res://scripts/world/objective_bridge.gd")
const Factory := preload("res://scripts/world/world_state_factory.gd")

var _mine: RefCounted


func _table() -> RefCounted:
	if _mine != null:
		return _mine
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(_mine.setup("CHR_00", seats, 4242), "e l'anno si apre")
	return _mine


func after_each() -> void:
	super.after_each()
	if _mine != null:
		_mine.dispose()
		_mine = null


func _pile(live: RefCounted, entity_id: String) -> Array:
	return (
		(live.world["personal_decks"] as Dictionary)[entity_id] as Dictionary
	)["draw"] as Array


## **La tabella dei gesti e' completa.** Il giorno in cui qualcuno aggiunge un
## gesto allo schema senza dire quale faccia lo serve, l'obiettivo che lo chiede
## diventa decorazione e nessuno se ne accorge. Questa prova se ne accorge.
func test_every_gesture_has_a_face_that_serves_it() -> void:
	assert_eq(
		Bridge.self_test(), [],
		"ogni gesto di `did_this_year` ha la faccia che lo sa fare"
	)


## Cosa un obiettivo chiede alle carte, letto dai dati spediti.
func test_an_objective_says_what_it_asks_of_the_deck() -> void:
	var live: RefCounted = _table()
	var stone: Dictionary = live.data.objectives["OBJ_A_STONE"] as Dictionary
	var asks: Dictionary = Bridge.asks_of_deck(stone)
	assert_true(
		(asks["verbs"] as Array).has("ACQUIRE"),
		"«una pietra alzata quest'anno» chiede una carta che sappia ACQUISIRE"
	)
	var written: Dictionary = live.data.objectives["OBJ_WRITTEN_THINGS"] as Dictionary
	assert_eq(
		int((Bridge.asks_of_deck(written)["families"] as Dictionary).get("KNOWLEDGE", 0)), 2,
		"«le cose scritte» chiede due carte Sapere"
	)
	# E la maggior parte degli obiettivi non chiede niente alle carte: guardano
	# il mondo, ed e' giusto cosi' — un obiettivo non e' una lista della spesa.
	var quiet: Dictionary = live.data.objectives["OBJ_QUIET_WORLD"] as Dictionary
	var nothing: Dictionary = Bridge.asks_of_deck(quiet)
	assert_true(
		(nothing["verbs"] as Array).is_empty() and (nothing["families"] as Dictionary).is_empty(),
		"«un mondo quieto» non chiede carte"
	)


## **Una faccia che pesca non alza una Pietra.** E' la stessa riga che il
## cervello salta (D-412): contarla direbbe che il mazzetto sa costruire quando
## non sa.
func test_an_acquire_that_only_draws_does_not_raise_a_stone() -> void:
	var live: RefCounted = _table()
	var builders: int = 0
	var drawers: int = 0
	for asset_id in live.data.assets:
		var asset: Dictionary = live.data.assets[str(asset_id)] as Dictionary
		var has_acquire: bool = false
		for face in ((asset.get("physical", {}) as Dictionary).get("actions", []) as Array):
			if str((face as Dictionary).get("template", "")) == "ACQUIRE":
				has_acquire = true
				if str((face as Dictionary).get("builds", "")) == "":
					drawers += 1
		if has_acquire and Bridge.face_serves(asset, "ACQUIRE"):
			builders += 1
	assert_eq(builders, 12, "dodici carte sanno alzare una Pietra")
	assert_eq(drawers, 0, "e nei dati spediti non c'e' una faccia ACQUISIRE che pesca")


## **La prova fabbricata**: un mazzetto che non ha nemmeno una carta Sapere, e
## l'obiettivo che ne chiede due. Il mucchio lo costruisce la prova — chiamare
## due volte la composizione vera rifarebbe le carte d'identita' e conterebbe
## copie che la scatola non ha (provato: `AST_PEOPLE_MOBILIZATION` 3 su 2), che
## e' un difetto della prova e non della regola.
func test_a_deck_that_cannot_reach_a_family_gets_the_card_anyway() -> void:
	var live: RefCounted = _table()
	# **Il seggio si prende dal tavolo, non a nome**: si siedono quattro case su
	# otto, e nominarne una che non si e' seduta interrompe la prova **in
	# silenzio** — GDScript non alza niente che si possa prendere, e il giro
	# diceva «verde» su una funzione che si era fermata alla terza riga.
	var seat: String = str((live.world["turn_order"] as Array)[0])
	var entity: Dictionary = (live.world["entities"] as Dictionary)[seat] as Dictionary
	entity["objectives"] = ["OBJ_WRITTEN_THINGS"]
	var pile: Array = _made_of(live, ["WEALTH", "AUTHORITY", "FORCE"], 18)
	assert_eq(pile.size(), 18, "il mucchio fabbricato ha diciotto carte")
	# **E si fabbrica anche chi presta.** A montaggio finito il mazzo Sapere e'
	# **vuoto** — 0 carte, contro le 22 del Popolo: le case che lo raggiungono se
	# lo sono preso tutto — quindi una prova che si fidasse degli avanzi
	# proverebbe gli avanzi. Nel giro vero lo scambio avviene *mentre* i mazzetti
	# si compongono, e le carte ci sono: lo dice la sonda, 0 obiettivi scoperti
	# su 800 seggi.
	_lend(live, "KNOWLEDGE", 2)
	assert_eq(
		Bridge.cards_of_family(pile, live.data, "KNOWLEDGE"), 0,
		"e nessuna carta Sapere, che e' il caso che serve"
	)
	Factory._deck_listens_to_its_objectives(pile, seat, live.world, live.data, 2)
	assert_eq(pile.size(), 18, "il mazzetto resta di diciotto: si scambia, non si aggiunge")
	assert_true(
		Bridge.cards_of_family(pile, live.data, "KNOWLEDGE") >= 2,
		"e le due carte Sapere ci sono, anche se la mappa non gliele dava"
	)
	assert_eq(
		Bridge.missing_in(pile, live.data.objectives["OBJ_WRITTEN_THINGS"], live.data), [],
		"quindi l'obiettivo non e' piu' scoperto"
	)


## E lo stesso per un **gesto**: l'obiettivo chiede una Pietra alzata
## quest'anno, e nel mazzetto ci deve essere una carta che la alza.
func test_a_deck_gets_a_card_that_can_do_the_asked_gesture() -> void:
	var live: RefCounted = _table()
	var seat: String = str((live.world["turn_order"] as Array)[1])
	var entity: Dictionary = (live.world["entities"] as Dictionary)[seat] as Dictionary
	entity["objectives"] = ["OBJ_A_STONE"]
	var pile: Array = _without(live, "ACQUIRE", 18)
	_lend_one_that_serves(live, "ACQUIRE")
	assert_true(
		Bridge.cards_serving(pile, live.data, "ACQUIRE").is_empty(),
		"il mucchio fabbricato non sa alzare nessuna Pietra"
	)
	Factory._deck_listens_to_its_objectives(pile, seat, live.world, live.data, 2)
	assert_false(
		Bridge.cards_serving(pile, live.data, "ACQUIRE").is_empty(),
		"e dopo c'e' una carta che sa alzarla"
	)


## **E sul tavolo spedito nessun obiettivo resta scoperto.** Questa guarda il
## montaggio vero, senza rifare niente: e' la riga che dice che la regola gira
## dove serve e non solo quando la chiama una prova.
func test_the_shipped_table_leaves_no_objective_uncovered() -> void:
	var live: RefCounted = _table()
	var holes: Array = []
	for entity_id in (live.world["turn_order"] as Array):
		var seat: String = str(entity_id)
		var pile: Array = _pile(live, seat)
		assert_eq(pile.size(), 18, "%s ha un mazzetto di diciotto" % seat)
		for objective_id in (
			((live.world["entities"] as Dictionary)[seat] as Dictionary).get("objectives", [])
			as Array
		):
			var missing: Array = Bridge.missing_in(
				pile, live.data.objectives[str(objective_id)], live.data
			)
			if not missing.is_empty():
				holes.append("%s con %s: %s" % [seat, str(objective_id), str(missing)])
	assert_eq(holes, [], "nessuna casa si siede con un obiettivo che non puo' provare")


## **E la scatola non si gonfia**: la carta che entra viene dai mazzi comuni e
## quella che esce ci torna, quindi nessuna carta esiste in piu' copie di quante
## la scatola ne ha. E' il modo in cui un rimedio del genere si rompe, e la
## sonda lo ricontrolla su duecento montaggi.
func test_the_box_does_not_grow() -> void:
	var live: RefCounted = _table()
	var seen: Dictionary = {}
	for entity_id in (live.world["personal_decks"] as Dictionary):
		for asset_id in _pile(live, str(entity_id)):
			seen[str(asset_id)] = int(seen.get(str(asset_id), 0)) + 1
	for family in (live.world["decks"] as Dictionary):
		var deck: Dictionary = (live.world["decks"] as Dictionary)[str(family)]
		for asset_id in ((deck["draw"] as Array) + (deck.get("discard", []) as Array)):
			seen[str(asset_id)] = int(seen.get(str(asset_id), 0)) + 1
	var over: Array = []
	for asset_id in seen:
		var copies: int = int(
			(live.data.assets[str(asset_id)] as Dictionary).get("deck_copies", 1)
		)
		if int(seen[asset_id]) > copies:
			over.append("%s: %d copie su %d" % [str(asset_id), int(seen[asset_id]), copies])
	assert_eq(over, [], "nessuna carta esiste piu' volte di quante ne ha la scatola")


## Un mucchio fabbricato di carte di quelle famiglie, in ordine di id.
func _made_of(live: RefCounted, families: Array, how_many: int) -> Array:
	var ids: Array = live.data.assets.keys()
	ids.sort()
	var out: Array = []
	for asset_id in ids:
		if out.size() >= how_many:
			break
		if families.has(str((live.data.assets[str(asset_id)] as Dictionary)["family"])):
			out.append(str(asset_id))
	return out


## E un mucchio in cui nessuna carta sa fare quel verbo.
func _without(live: RefCounted, verb: String, how_many: int) -> Array:
	var ids: Array = live.data.assets.keys()
	ids.sort()
	var out: Array = []
	for asset_id in ids:
		if out.size() >= how_many:
			break
		if not Bridge.face_serves(live.data.assets[str(asset_id)] as Dictionary, verb):
			out.append(str(asset_id))
	return out


## Sposta nel mazzo comune di quella famiglia `how_many` carte prese dai
## mazzetti degli altri: e' il prestito che al montaggio vero c'e' e a prova
## finita no — e **si sposta, non si fabbrica**, cosi' la scatola resta quella.
func _lend(live: RefCounted, family: String, how_many: int) -> void:
	var draw: Array = (
		(live.world["decks"] as Dictionary)[family] as Dictionary
	)["draw"] as Array
	for entity_id in (live.world["personal_decks"] as Dictionary):
		var other: Array = _pile(live, str(entity_id))
		for i in range(other.size() - 1, -1, -1):
			if draw.size() >= how_many:
				return
			if str((live.data.assets[str(other[i])] as Dictionary)["family"]) != family:
				continue
			draw.append(str(other[i]))
			other.remove_at(i)


func _lend_one_that_serves(live: RefCounted, verb: String) -> void:
	var ids: Array = live.data.assets.keys()
	ids.sort()
	for asset_id in ids:
		var asset: Dictionary = live.data.assets[str(asset_id)] as Dictionary
		if not Bridge.face_serves(asset, verb):
			continue
		var family: String = str(asset["family"])
		var draw: Array = (
			(live.world["decks"] as Dictionary)[family] as Dictionary
		)["draw"] as Array
		if not draw.has(str(asset_id)):
			draw.append(str(asset_id))
		return
