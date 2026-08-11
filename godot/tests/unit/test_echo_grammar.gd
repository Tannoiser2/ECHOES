extends "res://tests/test_case.gd"
## The Propp layer (§15, D-030): dramatic families shape the Act, narrative
## functions order the story.

const Effect := preload("res://scripts/core/effect.gd")
const PolicyDecider := preload("res://cli/policy_decider.gd")


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
		session.run(PolicyDecider.new(session.log))
		var arc: Array = []
		for card_id in session.world["echo_deck"]["drawn"]:
			arc.append(str(data().echo_cards[str(card_id)]["dramatic_family"]))
		arcs[str(arc)] = true
		# Act 1 is pure PRESSURE in Chronicle I: the first Act sets a question
		# up, it does not break it.
		assert_eq(str(arc[0]), "PRESSURE", "l'Atto 1 apre sempre in tensione")
		session.dispose()
	assert_true(arcs.size() > 1, "seed diversi devono dare archi diversi: %d" % arcs.size())
