extends RefCounted
## Builds the opening WorldState for a Chronicle (§13, §22).
##
## Structural state (which entities, regions, tensions and decks exist) is
## constructed directly: that *is* the initial state, not a mutation of it.
## Everything that a player could later change - presence tokens, opening hands -
## is applied as setup Effects with source kind "system", so the effect_log
## explains the whole table from EFF_000001 onwards. See DECISIONS D-003.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const Succession := preload("res://scripts/chronicle/succession.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const DEFAULT_DECK_COPIES: int = 3

## Le sei famiglie di carte, nell'ordine in cui si nominano al tavolo. Stanno
## qui perche' le legge anche la regola di stesura di D-313: una mappa deve
## offrirle tutte, e per saperlo bisogna sapere quali sono.
const ASSET_FAMILIES: Array = [
	"FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS",
]


static func build(chronicle: Dictionary, data: RefCounted, rng: RefCounted, seats: Array) -> Dictionary:
	var world: Dictionary = {
		"world_id": str(chronicle["world_id"]),
		"year": int(chronicle["start_year"]),
		# Quante Chronicle ha gia' giocato questa saga, questa compresa (D-181).
		# `year` non lo dice: fra due Chronicle possono passare duecento anni.
		"chronicles_played": 1,
		"chronicle_id": str(chronicle["id"]),
		"act": 0,
		"round": 0,
		"phase": "SETUP",
		"entities": {},
		"regions": {},
		"tensions": {},
		# Il Calore dei Temi (PZ-1, poi D-261): ogni Tema parte freddo. Stato
		# strutturale come `tensions`: i mazzetti esistono dal primo round, non
		# dalla prima Risonanza — un Tema mai scaldato si legge a zero, non
		# manca dal tavolo. `theme_heat` e' il valore (che si scopre a fine
		# Atto), `theme_tokens` i gettoni che il tavolo vede cadere,
		# `theme_decks` le Tensioni coperte del Tema, `theme_front` la carta
		# girata.
		"theme_heat": {},
		"theme_tokens": {},
		"theme_decks": {},
		"theme_front": {},
		"relations": {},
		"global_tags": (chronicle.get("global_tags", []) as Array).duplicate(),
		"claims": [],
		"echo_log": [],
		"truth_log": [],
		"scars": [],
		"effect_log": [],
		"rng_seed": rng.get_seed(),
		"rng_state": 0,
		"decks": {},
		"echo_deck": {"draw": [], "drawn": []},
		# Le carte Eco **calate**, scoperte sul tavolo (D-358). Non e' `drawn`:
		# quella e' la pila uscita dal mazzo, e comprende le carte che stanno
		# ancora in mano a qualcuno, e una carta in mano non e' successa.
		"echo_played": [],
		"echoes_played_in_act": 0,
		"drift_track": [],
		"drift_index": 0,
		"confluence_queue": [],
		"last_proponent": {},
		"questions_asked": {},
		"forced_confluence": null,
		"confluence_count": 0,
		# Il cancello del tavolo (D-203): quanti gettoni sono scesi da quando si e'
		# chiuso l'ultimo Consiglio. Contatore, come quello sopra, e come quello
		# fra le eccezioni dichiarate all'effect-sourcing.
		"tokens_in_bag": 0,
		"voted_together": {},
		"effect_sequence": 0,
		"turn_order": seats.duplicate(),
		"influence_used": {},
		"influence_used_by_tension": {},
		"opening_record": [],
		"map_record": {},
		"open_failures": [],
	}

	# Il dado dei Destini e' **a parte** (D-150), come quello che assegna i
	# caratteri ai seggi nel playtest (D-051): una pesca che attinge al caso
	# della partita sposta i mazzi, la deriva e le domande anche quando esce lo
	# stesso Destino — e infatti i tre piani di simulazione sono usciti diversi
	# il giorno in cui il pool si e' acceso, con i Destini identici. Accendere
	# il pool deve cambiare **cosa la gente vuole**, non che mondo trova.
	var destiny_rng: RefCounted = RngService.new(rng.get_seed() * 31 + 11)
	# E il dado degli obiettivi e' a parte dal dado dei Destini, per la stessa
	# ragione al piano di sotto: se pescasse dallo stesso, accendere gli
	# obiettivi cambierebbe **quale Destino** ogni casa giura, e i due
	# esperimenti non sarebbero piu' confrontabili.
	var objective_rng: RefCounted = RngService.new(rng.get_seed() * 37 + 17)
	for entity_id in chronicle["entities"]:
		var definition: Dictionary = data.entities[entity_id]
		world["entities"][entity_id] = {
			"id": entity_id,
			# The id is the seat - the house, the people, the thing under the
			# mountain. Who is sitting in it, and what they want, is state: both
			# can change between Chronicles while every Scar and relation the
			# world wrote keeps pointing at something that exists (D-045).
			"name": str(definition["name"]),
			"destiny_id": _deal_destiny(entity_id, definition, chronicle, destiny_rng),
			"generation": 0,
			# La vita del seggio al tavolo (D-108): si parte dalla prima, e la
			# successione la fa avanzare quando una linea si esaurisce.
			"incarnation": 0,
			"presence": [],
			"hand": [],
			"echo_hand": [],
			"tags": (definition["tags"] as Array).duplicate(),
			"active": bool(definition["active"]),
			"ao_remaining": 0,
			# Il punteggio della campagna (D-180). Resta a zero e non si legge
			# mai, se la Chronicle non dichiara `saga_scoring`: e' un contatore,
			# come `confluence_count`, ed e' fra le eccezioni dichiarate
			# all'effect-sourcing perche' non e' uno stato del mondo che qualcuno
			# possa disfare - e' il verbale di quello che e' gia' successo.
			"saga_score": 0,
			# Gli obiettivi **nascosti** pescati all'apertura (D-198). Il palese
			# non sta qui: e' il Destino giurato letto al gradino dichiarato,
			# quindi non c'e' una seconda verita' da tenere allineata. Resta
			# vuoto, e non lo legge nessuno, se la Chronicle non dichiara
			# `objectives`.
			"objectives": _deal_objectives(chronicle, data, objective_rng),
		}

	# Who holds what at the opening. The Region says what it says, and the
	# Chronicle overrides it: the map is shared between sagas - the same six
	# places centuries apart - so a starting owner written into the Region would
	# seat the first saga's houses at the second saga's table (D-049).
	_build_map(world, chronicle, data)

	for tension_id in resolve_tensions(filter_pool_for_map(chronicle, data, world), rng):
		var definition: Dictionary = data.tensions[tension_id]
		world["tensions"][tension_id] = {
			"id": tension_id,
			"current_value": int(definition["current_value"]),
			"visibility": str(definition["visibility"]),
			"fired_omens": [],
			"resolved_count": 0,
		}

	# Tutti e sei i Temi, sempre: la pista del Calore non dipende da quali
	# Tensioni la Chronicle ha pescato. Un Tema senza questioni quest'anno si
	# scalda lo stesso — e' il tavolo che dice dove il mondo sta guardando.
	for theme_id in data.themes:
		world["theme_heat"][str(theme_id)] = 0
		world["theme_tokens"][str(theme_id)] = 0

	deal_theme_decks(world, chronicle, data, rng)

	_build_relations(world, chronicle, data)
	_build_asset_decks(world, chronicle, data, rng)
	_build_echo_deck(world, chronicle, data, rng)
	_build_drift_track(world, chronicle, rng)
	return world


## Le Regioni sul tavolo, e la forma del mondo. Estratto da `build` perche' con
## la mappa pescata (D-263) un'era ereditata deve poterla **rimontare** sulle
## tessere della saga.
static func _build_map(world: Dictionary, chronicle: Dictionary, data: RefCounted) -> void:
	var held: Dictionary = {}
	for entry in chronicle.get("starting_control", []):
		held[str((entry as Dictionary)["region_id"])] = (entry as Dictionary).get("entity_id", null)

	(world["regions"] as Dictionary).clear()
	for region_id in chronicle["regions"]:
		var definition: Dictionary = data.regions[region_id]
		var control: Variant = (
			held[str(region_id)] if held.has(str(region_id)) else definition.get("control", null)
		)
		# Col tavolo pescato (D-263) il padrone scritto sulla tessera puo' non
		# sedersi: una Regione governata da un assente e' il difetto che
		# l'eredita' cura da D-213, e il primo anno non deve poterlo avere.
		if control != null and not (chronicle["entities"] as Array).has(str(control)):
			control = null
		world["regions"][region_id] = {
			"id": region_id,
			"control": control,
			"tags": (definition["tags"] as Array).duplicate(),
			# Cosa ci sta sopra (D-157): un tipo, un grado, e un padrone se e'
			# opera di una casa. Vuoto finche' qualcuno non costruisce.
			"structures": [],
		}

	# La **forma** del mondo (D-166). Fino a 0.1.132 le adiacenze si leggevano
	# dal dato della Regione ed erano l'unica cosa della mappa che non cambiava
	# mai. Adesso sono stato: un passo che frana toglie un arco, e da quel
	# momento due Regioni smettono di essere vicine.
	#
	# **Sul tavolo pescato la posa comanda** (D-275, parola del committente):
	# le tessere si posano in griglia nell'ordine di pesca — con sei, tre
	# colonne e due righe — e vicino e' chi si tocca di lato o di sopra.
	# L'adiacenza si legge guardando il tavolo, senza grafo scritto e senza
	# lati bloccati: ogni lato accostato e' un confine aperto (se un giorno
	# una tessera vorra' un lato chiuso, sara' un segno stampato, e sara'
	# un'altra decisione). Il grafo dichiarato resta agli anni scritti, dove
	# la mappa e' d'autore — e la vecchia cucitura delle isole (D-263) non
	# serve piu': una griglia e' connessa per costruzione.
	if not (chronicle.get("region_pool", {}) as Dictionary).is_empty():
		_lay_the_tiles(world, chronicle)
	else:
		world["adjacency"] = {}
		for region_id in chronicle["regions"]:
			var links: Array = []
			for neighbour in (data.regions[region_id]["adjacency"] as Array):
				# Solo i vicini che questa Chronicle porta davvero al tavolo.
				if (chronicle["regions"] as Array).has(str(neighbour)):
					links.append(str(neighbour))
			world["adjacency"][str(region_id)] = links


## La posa delle tessere pescate (D-275): griglia riga per riga nell'ordine
## di pesca, colonne = ceil(sqrt(N)) — per sei tessere, 3x2. La posizione
## resta nel mondo (`map_positions`, [colonna, riga]) perche' e' un fatto del
## tavolo: l'app la disegna, e la saga la eredita con l'ordine delle tessere.
static func _lay_the_tiles(world: Dictionary, chronicle: Dictionary) -> void:
	var order: Array = chronicle["regions"] as Array
	var columns: int = int(ceil(sqrt(float(order.size()))))
	var at: Dictionary = {}
	world["map_positions"] = {}
	for i in range(order.size()):
		var spot: Vector2i = Vector2i(i % columns, i / columns)
		at[str(order[i])] = spot
		world["map_positions"][str(order[i])] = [spot.x, spot.y]
	world["adjacency"] = {}
	for i in range(order.size()):
		var here: String = str(order[i])
		var links: Array = []
		for j in range(order.size()):
			if i == j:
				continue
			var step: Vector2i = (at[str(order[j])] as Vector2i) - (at[here] as Vector2i)
			if absi(step.x) + absi(step.y) == 1:
				links.append(str(order[j]))
		world["adjacency"][here] = links


## La pesca delle tessere (D-263): stessa forma di `resolve_seats`, candidate
## ordinate prima di mescolare, cosi' un riordino innocuo del dato non cambia
## ogni saga. Il dado lo passa il chiamante, **derivato dal seme** — la mappa
## non consuma il caso della partita.
##
## **E la mappa deve offrire tutte e sei le famiglie** (D-313). Ogni tessera e'
## fonte di due famiglie; sei tessere pescate su dieci fanno venti caselle per
## sei famiglie, e senza un rimedio **quarantacinque mappe su duecentodieci**
## ne lasciavano fuori una — ventotto volte l'Autorita', che usciva da due sole
## tessere. Una famiglia che non sta sulla mappa non si puo' andare a prendere:
## quelle otto carte le pesca solo chi e' a terra, alla cieca.
##
## Riequilibrare le fonti porta il conto da 45 a 30, ed e' il minimo teorico
## con due famiglie per tessera: servirebbero cinque tessere a famiglia — trenta
## caselle — e ce ne sono venti. Le ultime trenta mappe le chiude **una regola
## di stesura**, ed e' una regola che una persona sa eseguire:
##
## > Stese le sei tessere, se una famiglia non compare da nessuna parte, togli
## > la tessera piu' inutile — quella le cui due famiglie sono gia' offerte da
## > un'altra — e mettine una che porti la famiglia mancante.
##
## Deterministica come tutto il resto: le mancanti si guardano in ordine, e la
## sostituta e' la prima candidata rimasta che la offre.
static func resolve_map(chronicle: Dictionary, rng: RefCounted, data = null) -> Array:
	var pool: Dictionary = chronicle.get("region_pool", {}) as Dictionary
	if pool.is_empty():
		return (chronicle["regions"] as Array).duplicate()
	var drawn: Array = (pool.get("always", []) as Array).duplicate()
	var candidates: Array = []
	for region_id in pool["candidates"]:
		if not drawn.has(str(region_id)):
			candidates.append(str(region_id))
	candidates.sort()
	var spare: Array = []
	for region_id in rng.shuffle(candidates):
		if drawn.size() >= int(pool["count"]):
			spare.append(str(region_id))
			continue
		drawn.append(str(region_id))
	return _every_family_on_the_map(drawn, spare, data)


## Le famiglie che una tessera offre. Vuoto se la Regione non si conosce: il
## rimedio non inventa niente, si limita a non poter fare niente.
static func _sources_of(region_id: String, data) -> Array:
	if data == null:
		return []
	var region: Variant = data.regions.get(region_id)
	if region == null:
		return []
	return (region as Dictionary).get("asset_sources", []) as Array


## La regola di stesura di D-313, applicata. Senza `data` — o senza tessere di
## scorta — la mappa resta com'e': un rimedio che non puo' guardare le fonti
## non deve tirare a indovinare.
static func _every_family_on_the_map(drawn: Array, spare: Array, data) -> Array:
	if data == null or spare.is_empty():
		return drawn
	var out: Array = drawn.duplicate()
	var left: Array = spare.duplicate()
	for family in ASSET_FAMILIES:
		var offered: bool = false
		for region_id in out:
			if _sources_of(str(region_id), data).has(str(family)):
				offered = true
				break
		if offered:
			continue
		# Chi entra: la prima di scorta che porta la famiglia mancante.
		var comes_in: int = -1
		for i in range(left.size()):
			if _sources_of(str(left[i]), data).has(str(family)):
				comes_in = i
				break
		if comes_in < 0:
			continue
		# Chi esce: la tessera piu' inutile — quella le cui due famiglie sono
		# gia' offerte da un'altra. Si guarda dall'ultima pescata, cosi' le
		# tessere fisse di `always` escono per ultime.
		var goes_out: int = -1
		for i in range(out.size() - 1, -1, -1):
			var mine: Array = _sources_of(str(out[i]), data)
			if mine.is_empty():
				continue
			var redundant: bool = true
			for f in mine:
				var elsewhere: bool = false
				for j in range(out.size()):
					if j != i and _sources_of(str(out[j]), data).has(str(f)):
						elsewhere = true
						break
				if not elsewhere:
					redundant = false
					break
			if redundant:
				goes_out = i
				break
		if goes_out < 0:
			continue
		out[goes_out] = str(left[comes_in])
		left.remove_at(comes_in)
	return out


## Con la mappa pescata (D-263) l'anno fa solo le domande che la mappa sa
## reggere: una Tensione entra nel sacchetto se i suoi `focus_region_tags`
## esistono su una tessera uscita (o se non ne dichiara: le domande del mondo
## valgono ovunque) **e** se una tessera porta il suo dominio. Senza
## `region_pool` non filtra niente: le Chronicle scritte restano identiche.
static func filter_pool_for_map(chronicle: Dictionary, data: RefCounted, world: Dictionary) -> Dictionary:
	if (chronicle.get("region_pool", {}) as Dictionary).is_empty():
		return chronicle
	var pool: Dictionary = (chronicle.get("tension_pool", {}) as Dictionary)
	if pool.is_empty():
		return chronicle
	var on_map: Dictionary = {}
	for region_id in world.get("regions", {}):
		for tag in (world["regions"][str(region_id)].get("tags", []) as Array):
			on_map[str(tag)] = true
	var kept: Array = []
	for tension_id in (pool.get("candidates", []) as Array):
		var definition: Variant = data.tensions.get(str(tension_id))
		if definition == null:
			continue
		if _tension_fits_map(definition as Dictionary, on_map):
			kept.append(str(tension_id))
	var out: Dictionary = chronicle.duplicate(true)
	(out["tension_pool"] as Dictionary)["candidates"] = kept
	return out


static func _tension_fits_map(definition: Dictionary, on_map: Dictionary) -> bool:
	if not on_map.has("domain:%s" % str(definition.get("domain", ""))):
		return false
	var focus: Array = definition.get("focus_region_tags", []) as Array
	if focus.is_empty():
		return true
	for tag in focus:
		if on_map.has(str(tag)):
			return true
	return false


## Which Tensions this Chronicle actually runs.
##
## Che cosa vuole questa casa, quest'anno (D-150).
##
## I tre nascosti che ogni seggio si porta dietro senza dirlo (D-198).
##
## Si pescano dal pool condivisibile — dodici carte misurate una per una in
## D-197 — e **senza rimpiazzo dentro il singolo seggio**: nessuno gioca due
## volte lo stesso obiettivo. Fra seggi diversi il rimpiazzo c'e', ed e' voluto:
## due case che inseguono la stessa cosa e non lo sanno e' la partita che il
## committente ha chiesto.
##
## Il pool si pesca **da una lista ordinata** e poi mescolata col seme: un
## Dictionary in GDScript non promette l'ordine, e una pesca che dipende
## dall'ordine di caricamento dei file non e' riproducibile.
static func _deal_objectives(
	chronicle: Dictionary, data: RefCounted, rng: RefCounted
) -> Array:
	var rules: Dictionary = chronicle.get("objectives", {}) as Dictionary
	if rules.is_empty():
		return []
	var wanted: int = int(rules.get("hidden", 0))
	if wanted <= 0:
		return []
	var pool: Array = []
	for objective_id in data.objectives:
		pool.append(str(objective_id))
	pool.sort()
	var drawn: Array = rng.shuffle(pool)
	var out: Array = []
	for i in range(mini(wanted, drawn.size())):
		out.append(str(drawn[i]))
	return out


## Il `destiny_id` scritto sull'Entita' e' quello che ha sempre voluto: resta
## il suo, e senza pool non cambia niente. Ma una Chronicle puo' dichiarare un
## `destiny_pool` — per casa, una lista di Destini fra cui pescare — e allora
## l'anno decide cosa quella casa insegue *stavolta*.
##
## E' lo stesso meccanismo delle domande, applicato agli obiettivi, per la
## stessa ragione: quello che si ripete non sono le storie — la sonda della
## varieta' le da' a 0,8 di distanza (D-149) — ma cosa i giocatori vogliono, e
## il risultato e' che due Destini su tre finiscono al Minimo. Un obiettivo
## pescato rompe il Minimo come risposta giusta di default, e al tavolo toglie
## la cosa peggiore che ha oggi: alla terza partita tutti sanno cosa vuole
## l'altro.
##
## Ogni Destino del pool e' scritto **per la sua casa** — non si permuta niente
## fra le case (una clausola nomina Regioni, rivali e segni di
## quell'epoca, e la prosa e' scritta per chi la porta).
static func _deal_destiny(
	entity_id: String, definition: Dictionary, chronicle: Dictionary, rng: RefCounted
) -> String:
	# Il pool della Chronicle e' un **restringimento**: «quest'anno, fra questi».
	# Senza, si pesca da quello scritto sull'Entita', che e' dove la stessa lista
	# vive gia' per la successione (`succession.gd`). Prima di D-173 esisteva solo
	# il primo, e nessuna delle quattro Chronicle ne dichiarava uno: undici Destini
	# su venti non venivano mai giocati all'apertura, e i tre condivisibili della
	# voce 20 non erano mai stati letti da nessuna sonda (ISSUES 43).
	var pool: Array = (chronicle.get("destiny_pool", {}) as Dictionary).get(entity_id, [])
	if pool.is_empty():
		pool = definition.get("destiny_pool", []) as Array
	if pool.is_empty():
		return str(definition["destiny_id"])
	var candidates: Array = []
	for destiny_id in pool:
		candidates.append(str(destiny_id))
	candidates.sort()
	return str(rng.shuffle(candidates)[0])


## Chi si siede. `entities` scritto e' il tavolo d'autore; `entity_pool` e' la
## biblioteca, e sta alle case come `tension_pool` sta alle domande (D-213).
##
## La ragione e' la stessa che ha portato a `tension_pool`, un passo piu' in la':
## un tavolo scritto a mano non e' un tavolo, e' **un'era**. Due tavoli scritti
## a mano sono due ere chiuse, cioe' due giochi che non si incontrano mai. Con
## la biblioteca la Chronicle dice **chi puo' esserci** e l'RNG a seme
## apparecchia: ogni saga parte diversa, e case di secoli lontani possono
## trovarsi allo stesso tavolo.
##
## Vuoto o omesso, il tavolo e' quello scritto — **una dichiarazione vuota vuol
## dire assenza**, come ovunque nel progetto.
static func resolve_seats(chronicle: Dictionary, rng: RefCounted) -> Array:
	if (chronicle.get("entity_pool", {}) as Dictionary).is_empty():
		return (chronicle["entities"] as Array).duplicate()

	var pool: Dictionary = chronicle["entity_pool"]
	var drawn: Array = (pool.get("always", []) as Array).duplicate()
	var candidates: Array = []
	for entity_id in pool["candidates"]:
		if not drawn.has(str(entity_id)):
			candidates.append(str(entity_id))
	# Ordinate prima di mescolare: senza, l'ordine del file deciderebbe la
	# pesca, e un riordino innocuo del dato cambierebbe ogni saga.
	candidates.sort()
	for entity_id in rng.shuffle(candidates):
		if drawn.size() >= int(pool["count"]):
			break
		drawn.append(str(entity_id))
	return drawn


## `tensions` written out is the authored form. `tension_pool` is the library
## form: the Chronicle names what it *could* be about and the seeded RNG deals
## the year. That is what lets Chronicle N+1 exist without anyone writing it -
## the questions are library content, and the Chronicle is the hand (D-028).
##
## Deterministic by construction: the draw uses the same seeded RNG as the decks
## and the drift bag, so the same seed always deals the same year.
##
## Con un mondo ereditato la pesca **ascolta** (D-079): una candidata i cui
## `echoes` dichiarati sono sul tavolo - un fatto globale, la sua leggenda, o
## un tag di Regione - pesa il triplo. L'era dopo cresce da quella prima
## invece di essere pescata alla cieca; senza segni, o senza `previous`, la
## pesca resta quella uniforme di sempre.
static func resolve_tensions(
	chronicle: Dictionary, rng: RefCounted, previous: Dictionary = {},
	previous_results: Dictionary = {}
) -> Array:
	# Una biblioteca vuota **e'** l'assenza di biblioteca, come `hand_refill: {}`
	# e' l'assenza di ripescaggio: e' cosi' che un piano scriptato dichiara di
	# essere stato scritto per la mano scritta a mano (D-189).
	if (chronicle.get("tension_pool", {}) as Dictionary).is_empty():
		return (chronicle["tensions"] as Array).duplicate()

	var pool: Dictionary = chronicle["tension_pool"]
	var drawn: Array = (pool.get("always", []) as Array).duplicate()
	var candidates: Array = []
	for tension_id in pool["candidates"]:
		if not drawn.has(str(tension_id)):
			candidates.append(str(tension_id))
	candidates.sort()

	var echoes: Dictionary = pool.get("echoes", {})
	var accounts: Dictionary = _open_accounts(previous_results)
	if previous.is_empty() or (echoes.is_empty() and accounts.is_empty()):
		for tension_id in rng.shuffle(candidates):
			if drawn.size() >= int(pool["count"]):
				break
			drawn.append(str(tension_id))
		return drawn

	var weights: Dictionary = {}
	for tension_id in candidates:
		var called: bool = (
			_era_carries_any(previous, echoes.get(str(tension_id), []))
			or accounts.has(str(tension_id))
		)
		weights[str(tension_id)] = ECHO_WEIGHT if called else 1
	while drawn.size() < int(pool["count"]) and not candidates.is_empty():
		var total: int = 0
		for tension_id in candidates:
			total += int(weights[str(tension_id)])
		var roll: int = rng.range_int(1, total)
		for i in range(candidates.size()):
			roll -= int(weights[str(candidates[i])])
			if roll <= 0:
				drawn.append(str(candidates[i]))
				candidates.remove_at(i)
				break
	return drawn


## Il peso di una candidata richiamata da un segno (D-079). Tre a uno: un
## richiamo conta, ma non zittisce il caso - e' lo stesso rapporto con cui una
## mano di sei carte ne tiene due fuori.
const ECHO_WEIGHT: int = 3


## I conti rimasti aperti dell'era prima (D-087): le Tensioni nominate dalle
## clausole `tension_limit` che le case **non** hanno soddisfatto. Una casa che
## voleva la Carestia sotto il quattro e non l'ha avuta lascia la Carestia come
## conto aperto, e il conto richiama la sua domanda nella pesca dell'era dopo -
## con lo stesso peso di un segno sul mondo (D-079). Il conto chiama anche se
## la casa nel frattempo ha cambiato ambizione: la storia preme sull'era, non
## sull'erede.
##
## Il valore e' la lista (ordinata) dei seggi che hanno lasciato quel conto:
## alla pesca basta `has()`, ma il verbale d'apertura vuole dire *chi*.
static func _open_accounts(previous_results: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var entity_ids: Array = previous_results.keys()
	entity_ids.sort()
	for entity_id in entity_ids:
		for condition in (previous_results[str(entity_id)] as Dictionary).get("unmet", []):
			if str((condition as Dictionary).get("type", "")) != "tension_limit":
				continue
			var tension_id: String = str((condition as Dictionary).get("tension_id", ""))
			if tension_id == "" or tension_id.begins_with("$"):
				continue
			if not out.has(tension_id):
				out[tension_id] = []
			if not (out[tension_id] as Array).has(str(entity_id)):
				(out[tension_id] as Array).append(str(entity_id))
	return out


## Se il mondo ereditato porta uno dei segni: come fatto globale, come la sua
## leggenda (D-075: `legend:<fatto>`), o come tag su una Regione qualsiasi. I
## tag di Entita' non contano: le persone muoiono, i segni del mondo restano.
static func _era_carries_any(previous: Dictionary, tags: Array) -> bool:
	return not _carried_mark(previous, tags).is_empty()


## Quale segno, di preciso, il mondo ereditato porta - e come: fatto globale,
## leggenda del fatto (D-075), o tag su una Regione. Il primo che si trova
## vince, con lo stesso ordine di visita di sempre, cosi' la pesca resta
## bit-per-bit quella di prima e il verbale puo' nominare il segno.
static func _carried_mark(previous: Dictionary, tags: Array) -> Dictionary:
	var global_tags: Array = previous.get("global_tags", [])
	for tag in tags:
		if global_tags.has(str(tag)):
			return {"kind": "mark", "tag": str(tag), "carried": "fact"}
		if global_tags.has("legend:%s" % str(tag)):
			return {"kind": "mark", "tag": str(tag), "carried": "legend"}
		for region_id in previous.get("regions", {}):
			if ((previous["regions"][str(region_id)] as Dictionary).get("tags", []) as Array).has(str(tag)):
				return {
					"kind": "mark", "tag": str(tag),
					"carried": "region", "region_id": str(region_id),
				}
	return {}


## Il verbale d'apertura (D-089, Fase 3 del motore 0.3): per ogni domanda in
## mano, *perche'* e' in mano. Un segno sul mondo (D-079), un conto rimasto
## aperto (D-087), o niente - la biblioteca, il caso. E con che valore riparte
## (D-088). Solo lettura: non pesca, non tira, non tocca il mondo - e' il
## momento in cui la generazione diventa leggibile al tavolo.
static func opening_record(
	world: Dictionary, chronicle: Dictionary, data: RefCounted,
	previous: Dictionary, previous_results: Dictionary
) -> Array:
	var record: Array = []
	if previous.is_empty() or (chronicle.get("tension_pool", {}) as Dictionary).is_empty():
		return record
	var echoes: Dictionary = (chronicle["tension_pool"] as Dictionary).get("echoes", {})
	var accounts: Dictionary = _open_accounts(previous_results)
	for tension_id in world["tensions"]:
		var called_by: Array = []
		var mark: Dictionary = _carried_mark(previous, echoes.get(str(tension_id), []))
		if not mark.is_empty():
			called_by.append(mark)
		for entity_id in accounts.get(str(tension_id), []):
			called_by.append({
				"kind": "account",
				"entity_id": str(entity_id),
				"name": str((
					(previous.get("entities", {}) as Dictionary).get(str(entity_id), {}) as Dictionary
				).get("name", data.entities[str(entity_id)]["name"])),
			})
		record.append({
			"tension_id": str(tension_id),
			"start": int(world["tensions"][str(tension_id)]["current_value"]),
			"authored": int(data.tensions[str(tension_id)]["current_value"]),
			"called_by": called_by,
		})
	return record


## Il verbale della mappa (D-090): come si piazza la mappa dell'era nuova,
## e cosa il tempo le ha fatto. Derivato dagli stessi `inheritance_effects`
## che la piazzano davvero - una sola fonte di verita', quindi il verbale
## non puo' mentire sul tavolo - piu' i default di fabbrica per le Regioni
## che l'eredita' non tocca. Solo lettura, come il resto del verbale.
static func map_record(
	world: Dictionary, chronicle: Dictionary, data: RefCounted,
	previous: Dictionary, years: int
) -> Dictionary:
	if previous.is_empty():
		return {}
	var holders: Dictionary = {}
	var marks: Dictionary = {}
	for region_id in world["regions"]:
		holders[str(region_id)] = world["regions"][str(region_id)].get("control", null)
		marks[str(region_id)] = []
		for tag in world["regions"][str(region_id)]["tags"]:
			if _is_map_mark(str(tag)):
				(marks[str(region_id)] as Array).append(str(tag))

	var softened: int = 0
	var legends_born: Array = []
	for effect in inheritance_effects(previous, chronicle, data, years):
		var target: String = str(((effect as Dictionary)["target"] as Dictionary)["id"])
		var payload: Dictionary = (effect as Dictionary)["payload"]
		match str((effect as Dictionary)["type"]):
			"SET_CONTROL":
				holders[target] = payload.get("entity_id", null)
			"SET_REGION_TAG":
				if _is_map_mark(str(payload["tag"])) and not (marks[target] as Array).has(str(payload["tag"])):
					(marks[target] as Array).append(str(payload["tag"]))
			"ADD_SCAR":
				var scar_region: String = str(payload["region_id"])
				if marks.has(scar_region) and not (marks[scar_region] as Array).has(str(payload["tag"])):
					(marks[scar_region] as Array).append(str(payload["tag"]))
			"SET_RELATION":
				var before_level: String = str((
					(previous.get("relations", {}) as Dictionary).get(target, {}) as Dictionary
				).get("level", payload["level"]))
				if str(payload["level"]) != before_level:
					softened += 1
			"SET_GLOBAL_TAG":
				var tag: String = str(payload["tag"])
				if tag.begins_with("legend:") \
						and (previous.get("global_tags", []) as Array).has(tag.substr(7)):
					legends_born.append(tag.substr(7))

	var regions: Array = []
	var region_ids: Array = (world["regions"] as Dictionary).keys()
	region_ids.sort()
	for region_id in region_ids:
		var before: Dictionary = (previous.get("regions", {}) as Dictionary).get(str(region_id), {})
		var faded: Array = []
		for tag in before.get("tags", []):
			if str(tag).begins_with("condition:") and not (marks[str(region_id)] as Array).has(str(tag)):
				faded.append(str(tag))
		faded.sort()
		var mark_list: Array = (marks[str(region_id)] as Array).duplicate()
		mark_list.sort()
		regions.append({
			"region_id": str(region_id),
			"holder": holders[str(region_id)],
			"lapsed": before.get("control", null) != null and holders[str(region_id)] == null,
			"marks": mark_list,
			"faded": faded,
		})
	legends_born.sort()
	return {
		"regions": regions,
		"legends_born": legends_born,
		"relations_softened": softened,
	}


static func _is_map_mark(tag: String) -> bool:
	for prefix in INHERITED_TAG_PREFIXES:
		if tag.begins_with(prefix):
			return true
	return false


## La prosa della mappa, una riga per Regione piu' le code del tempo. I nomi
## dei padroni sono quelli dell'era nuova (il seggio continua, la persona no):
## si risolvono sul mondo gia' passato per la successione, con la scheda
## d'autore a fare da riserva.
static func map_lines(record: Dictionary, data: RefCounted, world: Dictionary = {}) -> Array:
	var lines: Array = []
	if record.is_empty():
		return lines
	for entry in record.get("regions", []):
		var region_name: String = str(data.regions[str((entry as Dictionary)["region_id"])]["name"])
		var holder: Variant = (entry as Dictionary)["holder"]
		var line: String
		if holder == null:
			if bool((entry as Dictionary)["lapsed"]):
				line = "%s a nessuno: chi la teneva non c'era." % region_name
			else:
				line = "%s a nessuno." % region_name
		else:
			var holder_name: String = str((
				(world.get("entities", {}) as Dictionary).get(str(holder), {}) as Dictionary
			).get("name", data.entities[str(holder)]["name"]))
			line = "%s a %s." % [region_name, holder_name]
		var mark_list: Array = (entry as Dictionary)["marks"]
		if not mark_list.is_empty():
			line += " Porta: %s." % ", ".join(PackedStringArray(mark_list.map(
				func(tag: Variant) -> String: return "'%s'" % str(tag)
			)))
		for tag in (entry as Dictionary)["faded"]:
			line += " '%s' e' sbiadito: non e' piu' in corso." % str(tag)
		lines.append(line)
	var legends: Array = record.get("legends_born", [])
	if not legends.is_empty():
		lines.append("Non piu' fatti, ma leggende: %s." % ", ".join(PackedStringArray(legends.map(
			func(fact: Variant) -> String: return "'%s'" % str(fact)
		))))
	var softened: int = int(record.get("relations_softened", 0))
	if softened > 0:
		lines.append(
			"%d rapporti fanno un passo verso l'indifferenza: la guerra si ricorda come rancore."
			% softened
		)
	return lines


## La prosa del verbale, una riga per domanda. Fuori dal record cosi' la
## leggono uguale il log del tavolo e il digest della saga.
static func opening_lines(record: Array, data: RefCounted) -> Array:
	var lines: Array = []
	for entry in record:
		var title: String = str(data.tensions[str((entry as Dictionary)["tension_id"])]["title"])
		var reasons: Array = []
		for reason in (entry as Dictionary)["called_by"]:
			match str((reason as Dictionary)["kind"]):
				"mark":
					# L'imperfetto e' onesto: la pesca legge il mondo com'era
					# alla chiusura, e il salto puo' aver sbiadito il segno
					# subito dopo - la mappa qui sotto dice come sta adesso.
					match str((reason as Dictionary)["carried"]):
						"fact":
							reasons.append("il mondo ne portava il segno ('%s')" % str(reason["tag"]))
						"legend":
							reasons.append("se ne racconta ancora la leggenda ('%s')" % str(reason["tag"]))
						"region":
							reasons.append("%s ne portava il segno ('%s')" % [
								str(data.regions[str(reason["region_id"])]["name"]), str(reason["tag"]),
							])
				"account":
					reasons.append("%s non l'ha mai chiusa" % str((reason as Dictionary)["name"]))
		var line: String
		if reasons.is_empty():
			line = "%s esce dalla biblioteca: il caso, non la memoria." % title
		else:
			line = "%s torna: %s." % [title, "; ".join(PackedStringArray(reasons))]
		var start: int = int((entry as Dictionary)["start"])
		var authored: int = int((entry as Dictionary)["authored"])
		if start > authored:
			line += " Apre a %d, non al %d d'autore: il calore si eredita." % [start, authored]
		elif start < authored:
			line += " Apre a %d, non al %d d'autore: anche la quiete si eredita." % [start, authored]
		lines.append(line)
	return lines


## Every unordered pair of Entities starts at NEUTRAL so SET_RELATION always has
## a record to overwrite (and therefore always has an exact inverse).
static func _build_relations(world: Dictionary, chronicle: Dictionary, data: RefCounted) -> void:
	var ids: Array = (chronicle["entities"] as Array).duplicate()
	ids.sort()
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			world["relations"][Ids.relation_key(str(ids[i]), str(ids[j]))] = {
				"level": "NEUTRAL",
				"tags": [],
			}

	for entity_id in ids:
		for relation in data.entities[entity_id]["relations"]:
			var other: String = str(relation["with"])
			if not world["entities"].has(other):
				continue
			var record: Dictionary = world["relations"][Ids.relation_key(str(entity_id), other)]
			record["level"] = str(relation["level"])
			for tag in relation.get("tags", []):
				if not record["tags"].has(tag):
					record["tags"].append(tag)

	for relation in chronicle.get("starting_relations", []):
		var key: String = Ids.relation_key(str(relation["a"]), str(relation["b"]))
		if not world["relations"].has(key):
			continue
		world["relations"][key]["level"] = str(relation["level"])
		for tag in relation.get("tags", []):
			if not world["relations"][key]["tags"].has(tag):
				world["relations"][key]["tags"].append(tag)


## One draw pile per family (§9). Starting-hand cards are taken out of the pile
## before the shuffle so the total number of copies in play stays honest.
static func _build_asset_decks(
	world: Dictionary, chronicle: Dictionary, data: RefCounted, rng: RefCounted
) -> void:
	var dealt: Dictionary = {}
	for entity_id in chronicle["entities"]:
		for asset_id in data.entities[entity_id]["starting_assets"]:
			dealt[asset_id] = int(dealt.get(asset_id, 0)) + 1

	for family in ASSET_FAMILIES:
		var pile: Array = []
		for asset in data.assets_of_family(family):
			var copies: int = int(asset.get("deck_copies", DEFAULT_DECK_COPIES))
			var already_dealt: int = int(dealt.get(str(asset["id"]), 0))
			for _i in range(maxi(0, copies - already_dealt)):
				pile.append(str(asset["id"]))
		world["decks"][family] = {"draw": rng.shuffle(pile), "discard": []}


## A single shuffled Echo deck; the Act pools (§15) filter it by dramatic family
## at draw time, so "the top of the Act deck" is well defined and reproducible.
##
## The deck is built from the cards that could matter *this year*. A card whose
## eligibility names a Tension the Chronicle is not asking about can never be
## legally drawn, and leaving it in the pile is not harmless: the deck is global
## to the whole game, so a second saga's content would reshuffle the first one's
## deck and change years nobody touched. Filtering here keeps a Chronicle's deck
## a function of that Chronicle.
static func _build_echo_deck(
	world: Dictionary, chronicle: Dictionary, data: RefCounted, rng: RefCounted
) -> void:
	# Un mazzo non porta famiglie che nessun atto pesca: le carte MEMORIA, per
	# esempio, stanno negli act_echo_pools delle sole Chronicle-biblioteca -
	# cioe' le ere che una memoria possono averla (D-076). Senza questo filtro
	# la composizione del mazzo di un anno scritto cambierebbe a ogni carta
	# aggiunta per le ere, e con lei il mescolamento e la partita.
	var families: Array = []
	for pool in chronicle.get("act_echo_pools", []):
		for family in pool.get("families", []):
			if not families.has(str(family)):
				families.append(str(family))
	var ids: Array = []
	for card in data.echo_cards.values():
		if not families.has(str(card["dramatic_family"])):
			continue
		if _asks_about_a_question_not_in_play(card, world):
			continue
		ids.append(str(card["id"]))
	ids.sort()
	world["echo_deck"] = {"draw": rng.shuffle(ids), "drawn": []}


static func _asks_about_a_question_not_in_play(card: Dictionary, world: Dictionary) -> bool:
	for condition in card.get("eligibility", []):
		if str((condition as Dictionary).get("type", "")) != "tension_limit":
			continue
		var tension_id: String = str((condition as Dictionary).get("tension_id", ""))
		# `$tension` is resolved against the Council being held and means "the one
		# we are talking about", which is in play by definition.
		if tension_id.begins_with("$"):
			continue
		if not (world["tensions"] as Dictionary).has(tension_id):
			return true
	return false


## La ripesca che ascolta (D-079). Al setup l'anno viene pescato alla cieca,
## perche' il mondo di prima non e' ancora noto; `inherit_from` lo conosce, e
## se il pool dichiara degli echi si ridanno le carte - Tensioni e sacchetto
## del Drift - pesate sui segni ereditati. Prima che si giochi: niente di
## quello che viene rifatto qui e' mai passato per un Effect (D-006).
static func redeal_tensions(
	world: Dictionary, chronicle: Dictionary, data: RefCounted, rng: RefCounted,
	previous: Dictionary, previous_results: Dictionary = {}, years: int = 1
) -> void:
	if previous.is_empty() or (chronicle.get("tension_pool", {}) as Dictionary).is_empty():
		return
	if (chronicle["tension_pool"] as Dictionary).get("echoes", {}).is_empty() \
			and _open_accounts(previous_results).is_empty():
		return
	(world["tensions"] as Dictionary).clear()
	for tension_id in resolve_tensions(filter_pool_for_map(chronicle, data, world), rng, previous, previous_results):
		var definition: Dictionary = data.tensions[tension_id]
		world["tensions"][tension_id] = {
			"id": tension_id,
			"current_value": inherited_tension_value(str(tension_id), definition, previous, years),
			"visibility": str(definition["visibility"]),
			"fired_omens": [],
			"resolved_count": 0,
		}
	_build_drift_track(world, chronicle, rng)
	# La pesca che ascolta ha cambiato le questioni dell'anno: i mazzetti dei
	# Temi vanno rimontati sulle nuove, o il tavolo girerebbe carte di domande
	# che quest'era non sta facendo. Trovato da test_library_balance: il
	# Consiglio si apriva su una Tensione che il mondo non aveva.
	deal_theme_decks(world, chronicle, data, rng)


## La mappa e' della saga (D-263): un'era ereditata che pesca le tessere
## rimonta il mondo su quelle della saga — Regioni, forma, questioni che la
## mappa regge, e i mazzetti sopra. Chiamata da `inherit_from` quando la mappa
## pescata da questo seme non e' quella che la saga ha gia' sul tavolo.
static func rebuild_drawn_map(
	world: Dictionary, chronicle: Dictionary, data: RefCounted, rng: RefCounted
) -> void:
	_build_map(world, chronicle, data)
	(world["tensions"] as Dictionary).clear()
	for tension_id in resolve_tensions(filter_pool_for_map(chronicle, data, world), rng):
		var definition: Dictionary = data.tensions[tension_id]
		world["tensions"][tension_id] = {
			"id": tension_id,
			"current_value": int(definition["current_value"]),
			"visibility": str(definition["visibility"]),
			"fired_omens": [],
			"resolved_count": 0,
		}
	_build_drift_track(world, chronicle, rng)
	deal_theme_decks(world, chronicle, data, rng)


## I mazzetti dei Temi (D-261, parola del committente): le Tensioni del Tema,
## mischiate e coperte. Il dado e' **derivato dal seme**, non quello della
## partita, per la lezione di D-150: un mazzetto che consumasse il caso
## condiviso sposterebbe mazzi, deriva e domande di tutto l'anno. Chiamata dal
## setup, e di nuovo dalla ripesca di D-079 quando un'era di libreria cambia
## le questioni dell'anno.
##
## **Sul tavolo pescato il mazzetto e' pieno** (D-264): dentro ci sono tutte
## le Tensioni del Tema che la mappa sa reggere, non solo quelle aperte
## all'inizio — «i mazzetti dei temi sono composti dalle tensioni», per
## intero. Girare una carta fara' entrare in gioco la sua questione (vedi
## `TensionSystem.flip_theme_front`). Sulle Chronicle scritte il mazzetto
## resta quello delle questioni in gioco: il loro anno e' un anno d'autore.
static func deal_theme_decks(
	world: Dictionary, chronicle: Dictionary, data: RefCounted, rng: RefCounted
) -> void:
	var full: bool = not (chronicle.get("region_pool", {}) as Dictionary).is_empty()
	var on_map: Dictionary = {}
	if full:
		for region_id in world.get("regions", {}):
			for tag in (world["regions"][str(region_id)].get("tags", []) as Array):
				on_map[str(tag)] = true
	var deck_rng: RefCounted = RngService.new(rng.get_seed() * 41 + 13)
	for theme_id in data.themes:
		var pile: Array = []
		if full:
			var ids: Array = data.tensions.keys()
			ids.sort()
			for tension_id in ids:
				var definition: Dictionary = data.tensions[str(tension_id)]
				if str(definition.get("theme", "")) != str(theme_id):
					continue
				if _tension_fits_map(definition, on_map):
					pile.append(str(tension_id))
		else:
			for tension_id in world["tensions"]:
				if str(data.tensions[str(tension_id)].get("theme", "")) == str(theme_id):
					pile.append(str(tension_id))
		world["theme_decks"][str(theme_id)] = deck_rng.shuffle(pile)
		world["theme_front"][str(theme_id)] = ""


## La domanda lasciata calda torna calda (D-088, Fase 2 del motore 0.3).
##
## Il valore di partenza di una Tensione ripescata segue il confine della
## memoria (D-075): su un salto **breve** la questione riparte da dove l'era
## prima l'ha lasciata - ma mai gia' a soglia: torna *tiepida*, non bollente,
## perche' l'era comincia prima del bollore, non dentro. Su un salto lungo il
## calore sbiadisce come tutto il resto, e si riparte dal valore d'autore.
## Una questione chiusa bene puo' ripartire anche piu' quieta di com'e'
## scritta: quiete e' un'eredita' quanto il fuoco.
static func inherited_tension_value(
	tension_id: String, definition: Dictionary, previous: Dictionary, years: int
) -> int:
	var authored: int = int(definition["current_value"])
	if Succession.decays_after(years):
		return authored
	var before: Variant = (previous.get("tensions", {}) as Dictionary).get(tension_id)
	if before == null:
		return authored
	var carried: int = int((before as Dictionary).get("current_value", authored))
	return clampi(carried, 0, int(definition["threshold"]) - 1)


## The drift bag (§11.2): a fixed distribution shuffled once with the seeded RNG.
static func _build_drift_track(world: Dictionary, chronicle: Dictionary, rng: RefCounted) -> void:
	var bag: Array = []
	if chronicle.has("drift_distribution"):
		for entry in chronicle["drift_distribution"]:
			for _i in range(int(entry["count"])):
				bag.append(str(entry["tension_id"]))
	else:
		# Library form: one chip per round, dealt round-robin over whatever was
		# drawn, so every question in play gets pushed by the world at least once.
		var ids: Array = (world["tensions"] as Dictionary).keys()
		ids.sort()
		var rounds: int = int(chronicle["acts"]) * int(chronicle["rounds_per_act"])
		for i in range(rounds):
			bag.append(str(ids[i % ids.size()]))
	world["drift_track"] = rng.shuffle(bag)
	world["drift_index"] = 0


## Tag prefixes a Chronicle hands to the next one. Everything else - hands,
## decks, presence, Tension values, Claims - is dealt fresh: a new Chronicle is
## a new year, not a saved game.
const INHERITED_TAG_PREFIXES: Array = ["condition:", "structure:", "settlement:", "scar:"]


## What Chronicle N leaves to Chronicle N+1, expressed as Effects so the carry
## over goes through the same applier, the same log and the same inverse as
## everything else (§6.3). A full propagation engine is 0.3; this is the part
## of it a measurement needs - the map remembers, the people remember, the
## question resets.
static func inheritance_effects(
	previous: Dictionary, chronicle: Dictionary, data: RefCounted, years: int = 1
) -> Array:
	var effects: Array = []
	var source: Dictionary = Effect.source("system", "INHERITANCE", "", 0, 0, 0)
	if previous.is_empty():
		return effects

	var lapse: bool = bool(
		(chronicle.get("control_rules", {}) as Dictionary).get("lapse_without_presence", false)
	)
	# Chi c'e' quest'anno (D-213). Col tavolo pescato la casa che teneva una
	# Regione, o che aveva costruito una pietra, puo' non sedersi piu': la sua
	# roba non passa a nessuno, resta della terra. Senza questo conto il mondo
	# nuovo direbbe che una casa assente governa - e la Confluence proverebbe a
	# cacciare qualcuno che non c'e'.
	var seated: Dictionary = {}
	for entity_id in chronicle["entities"]:
		seated[str(entity_id)] = true

	for region_id in chronicle["regions"]:
		var before: Variant = (previous["regions"] as Dictionary).get(str(region_id))
		if before == null:
			continue
		var base: Dictionary = data.regions[str(region_id)]
		var control: Variant = before.get("control", null)
		# D-027: you cannot govern where you are not. A Region held at the end of
		# a Chronicle with nobody standing in it reverts before the next one
		# opens - which is how a dynasty that spread too thin loses the edges
		# first, without anyone having to take them.
		if lapse and control != null and not _had_presence(previous, str(control), str(region_id)):
			control = null
		if control != null and not seated.has(str(control)):
			control = null
		if str(control if control != null else "") != str(base.get("control", "") if base.get("control", null) != null else ""):
			effects.append(
				Effect.make("SET_CONTROL", "region", str(region_id), {"entity_id": control}, source)
			)
		for tag in before.get("tags", []):
			if (base["tags"] as Array).has(str(tag)):
				continue
			# Il criterio di D-075 vale anche per la mappa: cio' che e' murato o
			# scritto resta (strutture, insediamenti, cicatrici), una *condizione*
			# e' stato sociale e su un salto lungo sbiadisce - un lutto dell'anno
			# 1002 non e' ancora in corso otto secoli dopo (D-078). La cicatrice,
			# che e' la memoria visibile della mappa, resta a raccontarlo.
			if str(tag).begins_with("condition:") and Succession.decays_after(years):
				continue
			for prefix in INHERITED_TAG_PREFIXES:
				if str(tag).begins_with(prefix):
					effects.append(
						Effect.make("SET_REGION_TAG", "region", str(region_id), {"tag": str(tag)}, source)
					)
					break

		# Le pietre attraversano gli anni (D-157). Una struttura non e' un segno
		# ma un oggetto — tipo, grado, padrone — e passa **com'era**: il
		# castello resta un castello, e la reggia resta una reggia finche'
		# qualcosa non la fa scendere. Il padrone segue la stessa regola del
		# controllo (`lapse_without_presence`): senza nessuno dentro, la casa
		# non la governa piu' e le pietre restano di nessuno.
		for structure in before.get("structures", []):
			var record: Dictionary = structure as Dictionary
			var holder: Variant = record.get("owner", null)
			if lapse and holder != null and not _had_presence(previous, str(holder), str(region_id)):
				holder = null
			if holder != null and not seated.has(str(holder)):
				holder = null
			# Prima si toglie quello che l'apertura ha seminato, poi si rialza
			# com'era: `starting_structures` descrive un anno che comincia da
			# zero, e un anno che eredita comincia da quello che c'era.
			# Senza questo, la torre di partenza copriva la reggia dell'anno
			# prima — `BUILD_STRUCTURE` su un tipo gia' presente e' un no-op.
			effects.append(
				Effect.make(
					"RAZE_STRUCTURE",
					"region",
					str(region_id),
					{"structure_type": str(record["structure_type"])},
					source
				)
			)
			effects.append(
				Effect.make(
					"BUILD_STRUCTURE",
					"region",
					str(region_id),
					{
						"structure_type": str(record["structure_type"]),
						"grade": int(record["grade"]),
						"owner": holder,
					},
					source
				)
			)

	# What people felt about each other outlives them - but not undimmed. Across
	# a long jump every relation moves one step towards NEUTRAL: a war is
	# remembered as a grudge, an alliance as a courtesy. The tags stay whatever
	# happens, because those are the things that were written down (D-045).
	var soften: bool = Succession.decays_after(years)
	# Solo fra chi e' ancora al tavolo (D-213). Finche' le case erano scritte a
	# mano l'anno dopo aveva sempre le stesse quattro e questa riga non serviva;
	# con le case pescate il mondo di prima puo' ricordare due case di cui una
	# oggi non gioca, e SET_RELATION non troverebbe il record da sovrascrivere -
	# cioe' un Effetto senza inverso, che e' la cosa che l'effect-sourcing non
	# ammette.
	for key in previous.get("relations", {}):
		var pair: PackedStringArray = str(key).split("|")
		if pair.size() != 2 or not seated.has(pair[0]) or not seated.has(pair[1]):
			continue
		var relation: Dictionary = previous["relations"][key]
		var level: String = str(relation["level"])
		effects.append(
			Effect.make(
				"SET_RELATION",
				"relation",
				str(key),
				{
					"level": Succession.decayed(level) if soften else level,
					"tags": (relation["tags"] as Array).duplicate(),
				},
				source
			)
		)

	# La memoria del mondo, e cosa il tempo le fa (D-075). Su un salto breve si
	# ricorda tutto com'era. Su un salto lungo resta un *fatto* solo quello che
	# e' murato o scritto - la Chronicle che arriva lo dichiara in
	# `enduring_facts` - e il resto non sparisce: diventa `legend:<fatto>`,
	# vero come la memoria e non come il mondo. Le leggende, una volta nate,
	# attraversano ogni salto successivo: la memoria della memoria non scade.
	# I segnaposto della grammatica narrativa (`function:`) sbiadiscono e basta.
	var fades: bool = Succession.decays_after(years)
	var enduring: Array = chronicle.get("enduring_facts", [])
	# I segni dei conti d'era (D-133) non passano dal giro normale: li riemette
	# il conto qui sotto se la sua condizione tiene, e se non tiene spariscono
	# senza diventare leggenda - un conteggio interrotto non e' una memoria.
	var tallied: Dictionary = {}
	for tally in chronicle.get("era_tallies", []):
		for sign in (tally as Dictionary)["chain"]:
			tallied[str(sign)] = true
	for tag in previous.get("global_tags", []):
		var fact: String = str(tag)
		if tallied.has(fact):
			continue
		if (chronicle.get("global_tags", []) as Array).has(fact):
			continue
		if fades and not enduring.has(fact) and not fact.begins_with("legend:"):
			# I `function:` non li scrive piu' nessuno (D-358): la grammatica di
			# Propp si legge dalle carte calate. Questa riga resta come guardia
			# per un salvataggio d'archivio che ne porti ancora uno — non deve
			# diventare la leggenda di una contabilita' che non esiste piu'.
			if fact.begins_with("function:"):
				continue
			effects.append(Effect.make(
				"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "legend:%s" % fact}, source
			))
			continue
		effects.append(Effect.make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": fact}, source))

	# Il conto delle ere (D-133): un'era chiusa con la condizione vera avanza
	# la catena di un segno; la condizione caduta azzera tutto. E' il tempo
	# che lavora - tre ere col sigillo intatto e la montagna diventa racconto.
	for tally in chronicle.get("era_tallies", []):
		var held: Dictionary = tally
		var facts: Array = previous.get("global_tags", [])
		if not facts.has(str(held["if_tag"])):
			continue
		if str(held.get("if_not_tag", "")) != "" and facts.has(str(held["if_not_tag"])):
			continue
		var chain: Array = held["chain"]
		var reached: int = -1
		for index in range(chain.size()):
			if facts.has(str(chain[index])):
				reached = index
		var next: int = mini(reached + 1, chain.size() - 1)
		for index in range(next + 1):
			effects.append(Effect.make(
				"SET_GLOBAL_TAG", "world", "WORLD", {"tag": str(chain[index])}, source
			))

	# Scars are the visible half of the world's memory: they stay on the map.
	for scar in previous.get("scars", []):
		effects.append(
			Effect.make("ADD_SCAR", "region", str(scar["region_id"]), (scar as Dictionary).duplicate(true), source)
		)

	return effects


static func _had_presence(previous: Dictionary, entity_id: String, region_id: String) -> bool:
	var entity: Variant = (previous.get("entities", {}) as Dictionary).get(entity_id)
	if entity == null:
		return false
	return (entity.get("presence", []) as Array).has(region_id)


## Setup Effects: presence tokens and opening hands (§13).
##
## `world` serve solo alla vita corrente (D-133): dopo una successione il
## seggio puo' portare un'incarnazione che dichiara una presenza sua - la
## Leggenda della Montagna parte senza pedine. Senza mondo (prima Chronicle,
## sonde) la vita e' la prima e la presenza e' quella del seggio.
static func setup_effects(chronicle: Dictionary, data: RefCounted, world: Dictionary = {}) -> Array:
	var effects: Array = []
	var source: Dictionary = Effect.source("system", "SETUP", "", 0, 0, 0)
	# La mappa dichiarata (D-212): un piano scriptato e' una storia scritta su
	# una mappa precisa, e la dichiara invece di ereditarla. Vale solo per la
	# prima vita del seggio - dopo una successione comanda l'incarnazione, che
	# la sua presenza se la porta (D-133).
	var declared: Dictionary = chronicle.get("starting_presence", {}) as Dictionary
	var displaced: int = 0
	for entity_id in chronicle["entities"]:
		var definition: Dictionary = data.entities[entity_id]
		var incarnation: int = int((
			(world.get("entities", {}) as Dictionary).get(str(entity_id), {}) as Dictionary
		).get("incarnation", 0))
		var active: Dictionary = Succession.active_view(definition, incarnation)
		var presence: Array = active["presence"] as Array
		if incarnation == 0 and declared.has(str(entity_id)):
			presence = declared[str(entity_id)] as Array
		# Con la mappa pescata (D-263) la casa puo' trovarsi i posti di
		# partenza rimasti nella scatola: le pedine cadono solo sulle tessere
		# uscite, e una casa rimasta senza niente **si accampa** — una pedina
		# sulla tessera che le tocca, a giro, cosi' due sfollate non si
		# ammucchiano sulla stessa.
		var map: Array = chronicle["regions"] as Array
		var settled: Array = []
		for region_id in presence:
			if map.has(str(region_id)):
				settled.append(str(region_id))
		if settled.is_empty() and not presence.is_empty():
			settled = [str(map[displaced % map.size()])]
			displaced += 1
		presence = settled
		for region_id in presence:
			effects.append(
				Effect.make("ADD_PRESENCE", "entity", entity_id, {"region_id": region_id}, source)
			)
		# La pietra della casa (D-213): sta sull'Entita' e non sulla Chronicle,
		# perche' con le case pescate una pietra intestata a chi non gioca
		# sarebbe la pietra di un assente. `at` indicizza la presenza di
		# partenza, quindi se la casa si sposta la sua pietra la segue.
		for entry in definition.get("starting_structures", []):
			var built: Dictionary = entry as Dictionary
			var at: int = int(built.get("at", 0))
			if at >= presence.size():
				continue
			effects.append(Effect.make(
				"BUILD_STRUCTURE", "region", str(presence[at]),
				{
					"structure_type": str(built["structure_type"]),
					"grade": int(built.get("grade", 1)),
					"owner": str(entity_id),
				},
				source
			))
		for asset_id in definition["starting_assets"]:
			effects.append(
				Effect.make(
					"GRANT_ASSET",
					"entity",
					entity_id,
					{"asset_id": asset_id, "source": "VOID"},
					source
				)
			)
	# Cosa c'e' gia' costruito quando l'anno si apre (D-159). Passa da un
	# BUILD_STRUCTURE come tutto il resto: stesso Effect, stesso inverso, e la
	# pietra entra nel conto del controllo dal primo round.
	for entry in chronicle.get("starting_structures", []):
		var built: Dictionary = entry as Dictionary
		# Con la mappa pescata (D-263) la pietra scritta su una tessera rimasta
		# nella scatola non si alza: la scatola la tiene.
		if not (chronicle["regions"] as Array).has(str(built["region_id"])):
			continue
		effects.append(Effect.make(
			"BUILD_STRUCTURE", "region", str(built["region_id"]),
			{
				"structure_type": str(built["structure_type"]),
				"grade": int(built.get("grade", 1)),
				"owner": built.get("owner", null),
			},
			source
		))

	return effects
