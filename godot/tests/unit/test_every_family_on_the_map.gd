extends "res://tests/test_case.gd"
## **La rosa offre tutte e sei le famiglie** (D-313, rifatta da D-510).
##
## Ogni tessera e' fonte di due famiglie, e una famiglia fuori mappa non si puo'
## andare a prendere: quelle otto carte le pesca solo chi e' a terra, alla
## cieca.
##
## Fino a D-509 era un **rimedio a valle**: si pescavano sei tessere su dieci —
## e quarantacinque mappe su duecentodieci lasciavano fuori una famiglia — poi
## una regola di stesura scambiava la tessera piu' inutile con una che portava
## la mancante. Con la rosa le caselle sono sette e fisse, le rose possibili
## sono **otto**, e la copertura e' diventata una **guardia a monte**:
## `validate_physical` le conta tutte prima che la scatola esca.
##
## Qui si prova l'altra meta', quella che il cancello dei dati non puo' vedere:
## che il **motore** stenda davvero una di quelle otto, e che ce le sappia
## stendere tutte.

const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const FAMILIES: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]
const SLOTS: Array = ["C", "P1", "P2", "P3", "P4", "P5", "P6"]


## Le famiglie che una tessera offre. **Mai vuote**: una fonte che torna vuota
## renderebbe `_missing` una prova che dice sempre «manca tutto», e una che dice
## sempre «non manca niente» a seconda del verso. Qui si va rossi subito.
func _sources(region_id: String) -> Array:
	var region: Variant = data().regions.get(region_id)
	assert_true(region != null, "la tessera %s sta nella scatola" % region_id)
	var out: Array = (region as Dictionary).get("asset_sources", []) as Array
	assert_true(out.size() > 0, "e dice da quali famiglie e' fonte: %s" % region_id)
	return out


func _missing(map: Array) -> Array:
	var out: Array = []
	for family in FAMILIES:
		var found: bool = false
		for region_id in map:
			if _sources(str(region_id)).has(str(family)):
				found = true
				break
		if not found:
			out.append(str(family))
	return out


## **Quante rose ci sono davvero, e il motore le stende tutte.**
##
## Il conto non si ricopia: si ricava dal dato, moltiplicando le candidate di
## ogni casella. Cosi' il giorno che una tessera nuova entra in scatola questa
## prova pretende di vederla uscire, invece di restare ferma a otto.
func test_the_engine_lays_every_rose_there_is() -> void:
	var per_slot: Dictionary = {}
	var ids: Array = []
	for region_id in data().regions:
		ids.append(str(region_id))
		var slot: String = str((data().regions[region_id] as Dictionary).get("map_slot", ""))
		assert_true(SLOTS.has(slot), "%s ha una casella della rosa: «%s»" % [str(region_id), slot])
		per_slot[slot] = int(per_slot.get(slot, 0)) + 1
	ids.sort()
	assert_eq(per_slot.size(), SLOTS.size(), "tutte e sette le caselle hanno una candidata")
	var quante: int = 1
	for slot in SLOTS:
		quante *= int(per_slot[str(slot)])

	# **Il dado se lo fa questa prova.** `session` qui e' nulla, e in GDScript
	# leggere una proprieta' su nulla **interrompe la funzione senza errore**:
	# la prova direbbe «verde» a meta' strada. E' costato un giro.
	var viste: Dictionary = {}
	for i in range(400):
		var rng: RefCounted = RngService.new(4200 + i)
		var drawn: Array = WorldStateFactory.resolve_map(
			{"region_pool": {"candidates": ids, "count": SLOTS.size()}},
			rng, data()
		)
		assert_eq(drawn.size(), SLOTS.size(), "sette tessere, una per casella")
		var seen: Dictionary = {}
		for region_id in drawn:
			assert_false(seen.has(str(region_id)), "nessuna tessera due volte")
			seen[str(region_id)] = true
		assert_eq(_missing(drawn), [], "nessuna rosa lascia fuori una famiglia: %s" % str(drawn))
		var sorted_map: Array = drawn.duplicate()
		sorted_map.sort()
		viste["/".join(PackedStringArray(sorted_map))] = true
	assert_eq(viste.size(), quante,
		"il motore stende tutte e %d le rose che la scatola sa fare (ne ha stese %d)"
		% [quante, viste.size()])


## **E la partita vera la usa davvero.**
##
## La prova qui sopra chiama `resolve_map` a mano: proverebbe verde anche se
## `GameSession` si fosse dimenticata di passargli il set di dati — e allora al
## tavolo la rosa non ci sarebbe. Questa apre CHR_00, che e' l'unica Chronicle
## a pescare la mappa, e guarda le tessere uscite.
func test_a_real_setup_never_leaves_a_family_out() -> void:
	var monche: int = 0
	var mappe: Dictionary = {}
	for i in range(60):
		var seed_value: int = 7000 + i
		var opened: RefCounted = GameSession.new(data())
		var seats: Array = GameSession.seats_for(data(), "CHR_00", seed_value)
		assert_true(opened.setup("CHR_00", seats, seed_value),
			"CHR_00 si apre al seme %d" % seed_value)
		var map: Array = (opened.world["regions"] as Dictionary).keys()
		assert_eq(map.size(), SLOTS.size(), "sette tessere sul tavolo al seme %d" % seed_value)
		if not _missing(map).is_empty():
			monche += 1
		map.sort()
		mappe["/".join(PackedStringArray(map))] = true
		opened.dispose()
	assert_eq(monche, 0, "nessuna partita vera comincia con una famiglia fuori mappa")
	assert_true(mappe.size() >= 2, "e sessanta semi non danno sempre la stessa rosa (%d)" % mappe.size())
