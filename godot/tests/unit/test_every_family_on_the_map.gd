extends "res://tests/test_case.gd"
## **La mappa offre tutte e sei le famiglie** (D-313).
##
## Ogni tessera e' fonte di due famiglie. Sei tessere su dieci fanno venti
## caselle per sei famiglie, e senza rimedio quarantacinque mappe su
## duecentodieci ne lasciavano fuori una. Una famiglia fuori mappa non si puo'
## andare a prendere: quelle otto carte le pesca solo chi e' a terra, alla
## cieca.
##
## Qui si prova la regola di stesura su **tutte** le mappe possibili, non su un
## campione: la sonda enumera le combinazioni e chiede al motore di rimediare.

const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")

const FAMILIES: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]


func _sources(region_id: String) -> Array:
	var region: Variant = session.data.regions.get(region_id)
	if region == null:
		return []
	return (region as Dictionary).get("asset_sources", []) as Array


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


## Tutte le combinazioni di `pick` fra `ids`, in ordine stabile.
func _combinations(ids: Array, pick: int) -> Array:
	if pick == 0:
		return [[]]
	if ids.size() < pick:
		return []
	var out: Array = []
	for i in range(ids.size() - pick + 1):
		var rest: Array = ids.slice(i + 1)
		for tail in _combinations(rest, pick - 1):
			var one: Array = [str(ids[i])]
			one.append_array(tail as Array)
			out.append(one)
	return out


func before_each() -> void:
	new_session()


## Il difetto, misurato: quante mappe **non rimediate** lasciano fuori una
## famiglia. Non e' zero, ed e' giusto che non lo sia: e' il numero che la
## regola di stesura deve chiudere.
func test_the_bare_draw_still_leaves_families_out() -> void:
	var ids: Array = []
	for region_id in session.data.regions:
		ids.append(str(region_id))
	ids.sort()
	assert_eq(ids.size(), 10, "il parco tessere ne ha dieci")
	var maps: Array = _combinations(ids, 6)
	assert_eq(maps.size(), 210, "sei tessere su dieci fanno duecentodieci mappe")
	var monche: int = 0
	for map in maps:
		if not _missing(map as Array).is_empty():
			monche += 1
	# Riequilibrate le fonti (Bosco dei Confini: Gente -> Autorita') il conto
	# scende da 45 a 30, che e' il minimo con due famiglie per tessera.
	assert_eq(monche, 30, "mappe monche prima della regola di stesura")


## E la regola le chiude tutte: **zero** mappe senza una famiglia.
func test_the_layout_rule_closes_every_map() -> void:
	var ids: Array = []
	for region_id in session.data.regions:
		ids.append(str(region_id))
	ids.sort()
	var monche: int = 0
	var toccate: int = 0
	for map in _combinations(ids, 6):
		var drawn: Array = (map as Array).duplicate()
		var spare: Array = []
		for region_id in ids:
			if not drawn.has(str(region_id)):
				spare.append(str(region_id))
		# Le sei gia' stese stanno in `always`, le altre quattro restano di
		# scorta: e' esattamente il gesto della regola al tavolo.
		var fixed: Array = WorldStateFactory.resolve_map(
			{"region_pool": {"candidates": ids, "count": 6, "always": drawn}},
			session.rng, session.data
		)
		if fixed != drawn:
			toccate += 1
		if not _missing(fixed).is_empty():
			monche += 1
	assert_eq(monche, 0, "dopo la regola di stesura nessuna mappa lascia fuori una famiglia")
	assert_true(toccate > 0, "e la regola ha toccato qualche mappa: %d" % toccate)


## La sostituzione non rompe la mappa: restano sei tessere, tutte diverse.
func test_the_repair_keeps_six_distinct_tiles() -> void:
	var ids: Array = []
	for region_id in session.data.regions:
		ids.append(str(region_id))
	ids.sort()
	for map in _combinations(ids, 6):
		var drawn: Array = (map as Array).duplicate()
		var fixed: Array = WorldStateFactory.resolve_map(
			{"region_pool": {"candidates": ids, "count": 6, "always": drawn}},
			session.rng, session.data
		)
		assert_eq(fixed.size(), 6, "sei tessere restano sei")
		var seen: Dictionary = {}
		for region_id in fixed:
			assert_false(seen.has(str(region_id)), "nessuna tessera due volte")
			seen[str(region_id)] = true


## **E la partita vera la usa davvero.**
##
## Le due prove qui sopra chiamano `resolve_map` a mano: proverebbero verde
## anche se `GameSession` si fosse dimenticata di passargli il set di dati — e
## allora al tavolo la regola non ci sarebbe. Questa apre CHR_00, che e'
## l'unica Chronicle a pescare la mappa, e guarda le tessere uscite.
func test_a_real_setup_never_leaves_a_family_out() -> void:
	var monche: int = 0
	var mappe: Dictionary = {}
	for i in range(60):
		var seed_value: int = 7000 + i
		var seats: Array = GameSession.seats_for(session.data, "CHR_00", seed_value)
		var other: RefCounted = GameSession.new(session.data)
		if not other.setup("CHR_00", seats, seed_value):
			other.dispose()
			continue
		var laid: Array = []
		for region_id in other.world["regions"]:
			laid.append(str(region_id))
		laid.sort()
		mappe[", ".join(PackedStringArray(laid))] = true
		assert_eq(laid.size(), 6, "sei tessere sul tavolo")
		if not _missing(laid).is_empty():
			monche += 1
		other.dispose()
	assert_eq(monche, 0, "nessuna partita di CHR_00 apre senza una famiglia")
	# E la sonda non e' cieca: sessanta semi hanno steso mappe diverse.
	assert_true(mappe.size() > 5, "mappe diverse viste: %d" % mappe.size())
