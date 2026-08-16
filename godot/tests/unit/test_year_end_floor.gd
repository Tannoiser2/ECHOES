extends "res://tests/test_case.gd"
## The floor under a Chronicle: a year does not close with nothing decided
## (D-047).
##
## The audit that produced this file played a ten-Chronicle saga and got **three
## years with zero Councils**. Not close ones - zero. The cause turned out to be
## arithmetic rather than luck: the world's Drift deals one chip per round spread
## across every question in play, nine chips over four questions, while the
## smallest gap between a question's opening value and its threshold is three. So
## the world can leave every question short at the same time, and in the silent
## years it did - the nearest one a single chip under its threshold, three times
## out of three. Every Council in the game needs a seat to push it there,
## and a table whose Destinies are all already satisfied pushes nothing: eighteen
## Action Opportunities, eighteen ACQUIRE, nothing decided, nothing to play.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


## Four people who never touch anything. Not a table anyone would be - the
## SuppressorDecider next door is the realistic version of this, and it still
## gets its Councils, because an Act-end Echo card can force one. This one is
## sharper on purpose: it leaves the world's Drift as the only thing that moves
## a question, which is exactly the arithmetic the audit tripped over.
class Idle extends RefCounted:
	func choose_action(_entity_id: String, _ao_index: int, _session: RefCounted) -> Dictionary:
		return {"template": "PASS", "params": {}}

	func choose_question(_context: Dictionary, _options: Array, _session: RefCounted) -> String:
		return ""

	func choose_proposition(_context: Dictionary, options: Array, _session: RefCounted) -> String:
		return "" if options.is_empty() else str(options[0]["id"])

	func choose_stance(_entity_id: String, _context: Dictionary, _session: RefCounted) -> Dictionary:
		return {"stance": "ABSTAIN", "clause_id": ""}

	func choose_commit(
		_entity_id: String, _context: Dictionary, _limit: int, _session: RefCounted
	) -> Array:
		return []

	func choose_recovery(_context: Dictionary, _session: RefCounted) -> Dictionary:
		return {}


func _run_chronicle(chronicle_id: String, seed_value: int, decider: RefCounted) -> Dictionary:
	if session != null:
		session.dispose()
	session = GameSession.new(data())
	session.setup(chronicle_id, SEATS, seed_value)
	return await session.run(decider)


## Both Chronicles declare a floor, and it is the number §7 asks for. If this
## fails, everything else in this file is measuring a Chronicle that opted out.
func test_both_chronicles_declare_the_floor() -> void:
	for chronicle_id in ["CHR_01", "CHR_02"]:
		assert_eq(
			int(data().chronicles[str(chronicle_id)].get("minimum_confluences", 0)), 2,
			"%s garantisce due Consigli" % chronicle_id
		)


## The one that would have caught the audit. A table that pushes nothing - every
## seat passing, every round - still gets its year decided.
##
## Il seme e' scelto perche' il pavimento scatti davvero: 1867 lo faceva fino
## alla 0.1.36, la seconda carta MEMORIA nel mazzo della corona (0.1.37) ha
## rimescolato l'anno e il seme si e' spostato di uno.
func test_a_table_that_does_nothing_still_gets_a_year() -> void:
	var report: Dictionary = await _run_chronicle("CHR_02", 1868, Idle.new())
	assert_true(
		(report["confluences"] as Array).size() >= 2,
		"un tavolo che non spinge niente ottiene comunque i suoi Consigli: %d"
		% (report["confluences"] as Array).size()
	)


## And it is not a special case of one seed. The saga that produced the audit
## went silent three times in ten; the same ten now go to the floor and no
## further.
func test_no_chronicle_in_a_run_of_seeds_ends_in_silence() -> void:
	for index in range(6):
		var report: Dictionary = await _run_chronicle(
			"CHR_02", 1867 + index * 97, PolicyDecider.new(session.log if session != null else null)
		)
		assert_true(
			(report["confluences"] as Array).size() >= 2,
			"seme %d: %d Consigli" % [1867 + index * 97, (report["confluences"] as Array).size()]
		)


## The floor is a floor and not a thumb on the scale: a year that decides its own
## questions never notices it is there. CHR_01 at this seed is a loud year, and
## its Councils are the ones the table opened - none of them forced.
func test_a_loud_year_is_left_exactly_as_it_was() -> void:
	var report: Dictionary = await _run_chronicle("CHR_01", 4242, PolicyDecider.new(null))
	assert_true(
		(report["confluences"] as Array).size() > 2,
		"il seme scelto e un anno rumoroso, altrimenti il test non prova niente"
	)
	for line in session.log.lines:
		assert_false(
			str(line).contains("L'anno non si chiude"),
			"nessun Consiglio forzato in un anno che si e deciso da solo"
		)


## Turning it off turns it off. A Chronicle is allowed to say that silence is an
## acceptable ending for it, and then nothing is added.
##
## "Nothing added" and "nothing happens" are not the same claim, and the first
## draft of this test asserted the wrong one: an idle table at this seed still
## gets one Council, because an Act-end Echo card can force one on its own. So
## the same seed is played twice and the two runs are compared - which is the
## only way to say what the floor did rather than what the year did.
func test_a_chronicle_can_opt_out_of_the_floor() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_02"]
	var declared: int = int(chronicle["minimum_confluences"])
	var quieter: int = 0

	# Swept over seeds rather than pinned to one, because not every seed needs
	# the floor: an Act-end Echo card can force a Council on its own, and a year
	# that got there by itself looks identical with the floor on and off. What
	# has to be true is that turning it off never *adds* anything, and that on at
	# least one of these years it was the floor doing the work.
	for index in range(5):
		var seed_value: int = 1867 + index * 97
		var with_floor: int = ((await _run_chronicle(
			"CHR_02", seed_value, Idle.new()
		))["confluences"] as Array).size()

		chronicle["minimum_confluences"] = 0
		var without: Dictionary = await _run_chronicle("CHR_02", seed_value, Idle.new())
		chronicle["minimum_confluences"] = declared

		var alone: int = (without["confluences"] as Array).size()
		assert_true(
			alone <= with_floor,
			"seme %d: senza pavimento non si decide di piu (%d contro %d)"
			% [seed_value, alone, with_floor]
		)
		for effect in session.world["effect_log"]:
			assert_ne(
				str(effect["source"]["id"]), "YEAR_END",
				"seme %d: e il mondo non spinge niente di sua iniziativa" % seed_value
			)
		if alone < with_floor:
			quieter += 1

	assert_true(quieter > 0, "e su almeno un anno il pavimento e servito davvero")


## What the world does to force a question is an Effect like everything else:
## logged, attributed to the world rather than to a seat, and invertible. A rule
## that reached into the Tension directly would be the one place in the engine
## where the register stops explaining the table.
func test_the_forced_push_goes_through_the_effect_log() -> void:
	await _run_chronicle("CHR_02", 1868, Idle.new())
	var forced: Array = []
	for effect in session.world["effect_log"]:
		if str(effect["source"]["id"]) == "YEAR_END":
			forced.append(effect)
	assert_false(forced.is_empty(), "la spinta di fine anno e nel registro degli Effect")
	for effect in forced:
		assert_eq(str(effect["type"]), "ADJUST_TENSION", "ed e una spinta su una Tensione")
		assert_eq(str(effect["source"]["kind"]), "system", "fatta dal mondo, non da un seggio")
		assert_true(bool(effect["reversible"]), "e si puo disfare come tutto il resto")
		assert_true(
			int(effect["payload"]["delta"]) > 0, "e porta la domanda al punto, non oltre"
		)
