extends "res://tests/test_case.gd"
## Smoke: **un anno intero, headless, dall'inizio alla fine** (§18.3).
##
## Fino a 0.1.281 questa prova girava i `sim_plans`: quattro playthrough
## **scritti a mano** della Carestia Rossa, mossa per mossa. Se ne sono andati
## con gli anni d'autore (D-318), e non si potevano ripuntare: una sequenza di
## mosse scritte per una mappa fissa non ha senso su una mappa che si pesca.
##
## Quello che i piani provavano invece vale ancora, ed e' quello che resta qui:
## un anno arriva in fondo, un Consiglio si risolve e dice cosa ha applicato,
## il mondo scrive Echi e Verita', e la carta d'Eco dell'Atto si annuncia. La
## differenza e' che adesso lo prova su **anni pescati**, cioe' sul gioco che
## sta nella scatola.
##
## E una cosa che i piani non potevano provare: **semi diversi finiscono
## diversi**. Con la mappa scritta a mano lo garantiva l'autore; con la mappa
## pescata e' una proprieta' del motore, e va guardata.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SEEDS: Array = [4242, 909, 7001]

var _years: Dictionary = {}


## Un anno intero, giocato una volta sola per seme e tenuto da parte: farlo
## girare in ogni prova costerebbe tre partite per prova invece di tre in tutto.
func _year(seed_value: int) -> RefCounted:
	if _years.has(seed_value):
		return _years[seed_value]
	var played: RefCounted = GameSession.new(data())
	var seats: Array = GameSession.seats_for(data(), "CHR_00", seed_value)
	if not played.setup("CHR_00", seats, seed_value):
		_fail("l'anno %d non si apre: %s" % [seed_value, played.last_error])
		return null
	for effect in played.factory_setup_effects():
		played.applier.apply(effect)
	var report: Dictionary = await played.run(PolicyDecider.new(played.log))
	if report.is_empty():
		_fail("l'anno %d non arriva in fondo" % seed_value)
		return null
	_years[seed_value] = played
	return played


func test_every_year_runs_to_the_end() -> void:
	for seed_value in SEEDS:
		var played: RefCounted = await _year(int(seed_value))
		if played == null:
			continue
		assert_eq(int(played.world["act"]), 3, "seme %d: arriva all'Atto 3" % [seed_value])
		assert_eq(
			str(played.world["phase"]), "CHRONICLE_END",
			"seme %d: chiude la Chronicle" % [seed_value]
		)


## Il mondo scrive da solo: Echi con un testo e gli Effect che li hanno
## prodotti, e Verita' a verbale.
func test_the_world_writes_its_own_history() -> void:
	var echoes: int = 0
	var truths: int = 0
	for seed_value in SEEDS:
		var played: RefCounted = await _year(int(seed_value))
		if played == null:
			continue
		for echo in (played.world["echo_log"] as Array):
			echoes += 1
			assert_true(str((echo as Dictionary)["summary"]).length() > 0, "ogni Echo ha un testo")
			assert_true(
				((echo as Dictionary)["effect_ids"] as Array).size() > 0,
				"ogni Echo cita gli Effect che lo hanno prodotto"
			)
		truths += (played.world["truth_log"] as Array).size()
	assert_true(echoes >= 1, "almeno un Echo generato automaticamente: %d" % [echoes])
	assert_true(truths >= 1, "almeno una Verita' registrata: %d" % [truths])


## Un Consiglio che si chiude dice **cosa ha applicato**, non solo che si e'
## chiuso: senza, il verbale promette una decisione e non la mostra.
func test_a_resolved_council_reports_what_it_applied() -> void:
	var seen: int = 0
	for seed_value in SEEDS:
		var played: RefCounted = await _year(int(seed_value))
		if played == null:
			continue
		for entry in played.log.lines:
			var line: String = str(entry)
			if not line.contains("Conseguenza"):
				continue
			seen += 1
			assert_true(line.length() > len("Conseguenza"), "la riga dice cosa ha applicato")
	assert_true(seen > 0, "almeno un Consiglio deve essersi risolto: %d" % [seen])


## **Semi diversi finiscono diversi.** Con la mappa scritta a mano lo garantiva
## l'autore; con la mappa pescata e' una proprieta' del motore. Se questa cade,
## la varieta' della scatola e' finta e nessun'altra prova se ne accorge.
func test_different_seeds_end_differently() -> void:
	var signatures: Array = []
	for seed_value in SEEDS:
		var played: RefCounted = await _year(int(seed_value))
		if played == null:
			continue
		var mark: String = ""
		var region_ids: Array = (played.world["regions"] as Dictionary).keys()
		region_ids.sort()
		for region_id in region_ids:
			mark += "%s:%s|" % [
				str(region_id),
				str((played.world["regions"][region_id] as Dictionary).get("control", "")),
			]
		signatures.append(mark)
	assert_true(signatures.size() >= 2, "servono due anni per confrontarli")
	for i in range(signatures.size()):
		for j in range(i + 1, signatures.size()):
			assert_ne(
				signatures[i], signatures[j],
				"gli anni %d e %d finiscono diversi" % [int(SEEDS[i]), int(SEEDS[j])]
			)
