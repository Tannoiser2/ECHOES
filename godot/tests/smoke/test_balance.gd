extends "res://tests/test_case.gd"
## Balance regression (§7, docs/DECISIONS.md D-018 / D-021).
##
## The scripted plans check that the rules do what an author wrote down. This
## checks the thing an author cannot: what the Chronicle does when four players
## all pursue their own Destiny at once.
##
## §7 expects 3-4 Confluence per Chronicle and asks for a report if fewer than 2
## or more than 6 emerge. Before the D-021 cap this suite failed hard - the
## median was 0 - which is exactly why it exists.

const PolicyDecider := preload("res://cli/policy_decider.gd")
# GameSession comes from test_case.gd; re-declaring it is a parse error.

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
const RUNS: int = 24
const FIRST_SEED: int = 500

## §7's hard bounds: outside these the numbers need revisiting, not the data.
const FLOOR: int = 2
const CEILING: int = 6


func _play(seed_value: int) -> Dictionary:
	new_session(seed_value, false)
	var report: Dictionary = session.run(PolicyDecider.new(session.log))
	return report


## Every Chronicle a competent table plays must produce a Confluence count
## inside the band §7 declares acceptable.
func test_confluence_count_stays_inside_the_expected_band() -> void:
	var counts: Array = []
	for i in range(RUNS):
		var seed_value: int = FIRST_SEED + i
		_play(seed_value)
		var count: int = int(session.world["confluence_count"])
		counts.append(count)
		assert_true(
			count >= FLOOR,
			"seed %d: solo %d Confluence, il §7 non scende sotto %d" % [seed_value, count, FLOOR]
		)
		assert_true(
			count <= CEILING,
			"seed %d: %d Confluence, il §7 non sale sopra %d" % [seed_value, count, CEILING]
		)

	counts.sort()
	var median: int = int(counts[counts.size() / 2])
	assert_true(
		median >= 3 and median <= 4,
		"la mediana attesa dal §7 e 3-4, misurata %d su %d partite" % [median, RUNS]
	)


## A Chronicle where nobody ever wins anything, or where everyone always does,
## would satisfy the count and still be a broken game.
func test_destinies_are_contested() -> void:
	var levels: Dictionary = {}
	var echoes: int = 0
	for i in range(RUNS):
		var report: Dictionary = _play(FIRST_SEED + i)
		echoes += int(report["echoes"])
		for entity_id in SEATS:
			var level: String = str(report["destiny_results"][str(entity_id)]["level"])
			levels[level] = int(levels.get(level, 0)) + 1

	assert_true(echoes >= RUNS, "in media almeno un Echo per Chronicle, misurati %d" % echoes)
	assert_true(
		int(levels.get("TRIUMPH", 0)) > 0,
		"qualcuno deve poter arrivare al Triumph"
	)
	assert_true(
		int(levels.get("MINIMUM", 0)) > 0,
		"e qualcun altro deve restare indietro: senza conflitto il gioco non funziona"
	)
	assert_true(
		int(levels.get("TRIUMPH", 0)) < RUNS * SEATS.size(),
		"non tutti possono vincere tutto"
	)


## D-021: the per-round INFLUENCE allowance is actually enforced during a full
## Chronicle, not just in the isolated unit test.
func test_influence_cap_holds_over_a_whole_chronicle() -> void:
	var cap: int = int(
		data().chronicles["CHR_01"].get("influence_rules", {}).get("max_per_entity_per_round", 0)
	)
	assert_true(cap > 0, "la Chronicle I dichiara un cap su INFLUENCE")

	_play(FIRST_SEED)
	# Rebuild the per-round tallies from the effect log: act/round/actor are on
	# every Effect's source, so the log alone proves the rule held.
	var tally: Dictionary = {}
	for effect in session.world["effect_log"]:
		var source: Dictionary = effect["source"]
		if str(source.get("id", "")) != "ACT_INFLUENCE":
			continue
		if str(effect["type"]) != "ADJUST_TENSION":
			continue
		var key: String = "%d/%d/%s" % [
			int(source["act"]), int(source["round"]), str(source.get("actor", ""))
		]
		tally[key] = int(tally.get(key, 0)) + 1
	for key in tally:
		assert_true(
			int(tally[key]) <= cap,
			"%s ha usato INFLUENCE %d volte in un round, il limite e %d" % [key, int(tally[key]), cap]
		)
	assert_true(not tally.is_empty(), "la partita ha comunque usato INFLUENCE")


## The measuring instrument itself has to be reproducible, or none of the numbers
## above mean anything.
func test_the_probe_is_deterministic() -> void:
	var first: Dictionary = _play(FIRST_SEED)
	var first_count: int = int(session.world["confluence_count"])
	var first_log: String = session.log.text()

	var second: Dictionary = _play(FIRST_SEED)
	assert_eq(int(session.world["confluence_count"]), first_count, "stesso seed, stesso numero di Confluence")
	assert_eq(session.log.text(), first_log, "stesso seed, stessa partita riga per riga")
	assert_eq(int(second["echoes"]), int(first["echoes"]), "stesso seed, stessi Echo")


## The policy is a model of a competent player, so it must not be proposing
## illegal actions: if it does, the numbers above are measuring the wrong thing.
func test_the_policy_never_proposes_an_illegal_action() -> void:
	for i in range(RUNS):
		var report: Dictionary = _play(FIRST_SEED + i)
		assert_eq(
			int(report["illegal_actions"]),
			0,
			"seed %d: la policy ha proposto %d azioni illegali" % [FIRST_SEED + i, int(report["illegal_actions"])]
		)
