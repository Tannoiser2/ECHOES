extends "res://tests/test_case.gd"
## The Propp layer (§15, D-030): dramatic families shape the Act, narrative
## functions order the story.

const Effect := preload("res://scripts/core/effect.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SchemaDefs := preload("res://scripts/core/schema_defs.gd")


## Drawing a card records the function it performed, so a later card can require
## it. Without this the function_id was a label the engine never read.
func test_drawing_a_card_records_its_function() -> void:
	new_session()
	assert_false(
		str(session.world["global_tags"]).contains("function:"),
		"all'inizio nessuna funzione e stata svolta"
	)
	session.chronicle.end_of_act(1, PolicyDecider.new(session.log))

	var recorded: Array = []
	for tag in session.world["global_tags"]:
		if str(tag).begins_with("function:"):
			recorded.append(str(tag))
	assert_eq(recorded.size(), 1, "una carta pescata, una funzione registrata: %s" % str(recorded))
	var drawn_id: String = str(session.world["echo_deck"]["drawn"][0])
	assert_eq(
		recorded[0],
		"function:%s" % str(data().echo_cards[drawn_id]["function_id"]),
		"e la funzione registrata e quella della carta"
	)


## Propp's order, expressed as data: a card that presupposes something is not
## eligible until that something has happened.
func test_a_card_that_presupposes_something_waits_for_it() -> void:
	new_session()
	var card: Dictionary = data().echo_cards["ECH_RECONCILIATION"]
	assert_false(card["eligibility"].is_empty(), "la riconciliazione ha una precondizione")

	var conditions: RefCounted = load("res://scripts/world/condition_evaluator.gd").new(
		session.world, data()
	)
	assert_false(
		conditions.all_hold(card["eligibility"], {}),
		"senza un tradimento non e ancora giocabile"
	)

	session.applier.apply(
		Effect.make(
			"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "function:BETRAYAL"},
			Effect.source("test", "TEST", "", 1, 1, 0)
		)
	)
	assert_true(
		conditions.all_hold(card["eligibility"], {}),
		"dopo un tradimento, si"
	)


## An Act whose whole pool is gated could draw nothing at all, and the arc would
## simply not close. Every family must keep at least one card that presupposes
## nothing - over-gating RESOLUTION is what made Act 3 stop resolving.
func test_every_dramatic_family_keeps_an_unconditional_card() -> void:
	var families: Dictionary = {}
	for card in data().echo_cards.values():
		var family: String = str(card["dramatic_family"])
		if (card["eligibility"] as Array).is_empty():
			families[family] = str(card["id"])
	for family in ["PRESSURE", "RUPTURE", "TURN", "RESOLUTION"]:
		assert_true(
			families.has(family),
			"la famiglia %s non ha nessuna carta sempre giocabile" % family
		)


## The Act pool is a weighted bag: repeating a family makes it likelier, and the
## draw stays seeded. Read as a strict preference it produced the same arc in
## every measured Chronicle, which is a shape without a story.
func test_the_act_pool_is_weighted_and_seeded() -> void:
	var arcs: Dictionary = {}
	for seed_value in range(9100, 9120):
		new_session(seed_value, true)
		await session.run(PolicyDecider.new(session.log))
		var arc: Array = []
		for card_id in session.world["echo_deck"]["drawn"]:
			arc.append(str(data().echo_cards[str(card_id)]["dramatic_family"]))
		arcs[str(arc)] = true
		# Act 1 is pure PRESSURE in Chronicle I: the first Act sets a question
		# up, it does not break it.
		assert_eq(str(arc[0]), "PRESSURE", "l'Atto 1 apre sempre in tensione")
		session.dispose()
	assert_true(arcs.size() > 1, "seed diversi devono dare archi diversi: %d" % arcs.size())


## The deck covers Propp's set exactly: every function the schema declares has a
## card, and the four dramatic families are balanced. Content that exists only in
## the enum is content that cannot happen.
func test_every_declared_function_has_a_card() -> void:
	var by_function: Dictionary = {}
	var by_family: Dictionary = {}
	for card in data().echo_cards.values():
		by_function[str(card["function_id"])] = str(card["id"])
		var family: String = str(card["dramatic_family"])
		by_family[family] = int(by_family.get(family, 0)) + 1

	for function_id in SchemaDefs.DEFS["echo_card"]["properties"]["function_id"]["enum"]:
		assert_true(
			by_function.has(str(function_id)),
			"la funzione '%s' e dichiarata nello schema ma nessuna carta la svolge" % function_id
		)
	for family in ["PRESSURE", "RUPTURE", "TURN", "RESOLUTION"]:
		assert_eq(int(by_family.get(family, 0)), 6, "sei carte per la famiglia %s" % family)


## `any_of` is what lets Propp's alternatives be written down: a Return follows a
## Separation *or* a Prohibition. Every other condition list in the data is an AND.
func test_any_of_holds_when_one_branch_does() -> void:
	new_session()
	var conditions: RefCounted = load("res://scripts/world/condition_evaluator.gd").new(
		session.world, data()
	)
	var condition: Dictionary = {
		"type": "any_of",
		"conditions": [
			{"type": "state_tag_present", "scope": "GLOBAL", "tag": "function:PROHIBITION"},
			{"type": "state_tag_present", "scope": "GLOBAL", "tag": "function:SEPARATION"},
		],
	}
	assert_false(conditions.holds(condition, {}), "nessuno dei due rami vale")

	session.applier.apply(
		Effect.make(
			"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "function:SEPARATION"},
			Effect.source("test", "TEST", "", 1, 1, 0)
		)
	)
	assert_true(conditions.holds(condition, {}), "basta che ne valga uno")
