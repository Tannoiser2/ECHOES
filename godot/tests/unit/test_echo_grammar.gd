extends "res://tests/test_case.gd"
## The Propp layer (§15, D-030): dramatic families shape the Act, narrative
## functions order the story.

const Effect := preload("res://scripts/core/effect.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SchemaDefs := preload("res://scripts/core/schema_defs.gd")


## Playing a card records the function it performed, so a later card can require
## it. Without this the function_id was a label the engine never read. Dalla
## 0.1.80 (ISSUES 23, D-118) la carta la cala una mano, come azione: la
## grammatica resta la stessa, cambia chi parla.
func test_playing_a_card_records_its_function() -> void:
	new_session()
	assert_false(
		str(session.world["global_tags"]).contains("function:"),
		"all'inizio nessuna funzione e stata svolta"
	)
	var card_id: String = "ECH_LACK"
	(session.world["entities"]["ENT_ALDRIC"]["echo_hand"] as Array).append(card_id)
	var before: int = session.service.hand_size("ENT_ALDRIC")
	var result: Dictionary = session.actions.execute(
		"ENT_ALDRIC", {"template": "PLAY_ECHO", "params": {"echo_card_id": card_id}}
	)
	assert_true(bool(result.get("ok", false)), "la carta si cala: %s" % str(result.get("error", "")))

	var recorded: Array = []
	for tag in session.world["global_tags"]:
		if str(tag).begins_with("function:"):
			recorded.append(str(tag))
	assert_eq(recorded.size(), 1, "una carta calata, una funzione registrata: %s" % str(recorded))
	assert_eq(
		recorded[0],
		"function:%s" % str(data().echo_cards[card_id]["function_id"]),
		"e la funzione registrata e quella della carta"
	)
	# La parola si paga (scelta del committente): una carta Asset e' uscita.
	assert_eq(session.service.hand_size("ENT_ALDRIC"), before - 1, "il prezzo e' una carta Asset")
	assert_false(
		(session.world["entities"]["ENT_ALDRIC"]["echo_hand"] as Array).has(card_id),
		"e la carta del Narratore non e' piu' in mano"
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
	# Six per family in the first saga, three in the second: a Chronicle only ever
	# sees the cards that could matter to its own questions (D-049), so the count
	# that means something is per saga, not in total.
	var by_saga: Dictionary = {}
	for card in data().echo_cards.values():
		var saga: String = "seconda" if _is_second_saga(card) else "prima"
		var per: Dictionary = by_saga.get(saga, {})
		per[str(card["dramatic_family"])] = int(per.get(str(card["dramatic_family"]), 0)) + 1
		by_saga[saga] = per
	for family in ["PRESSURE", "RUPTURE", "TURN", "RESOLUTION"]:
		assert_eq(
			int((by_saga["prima"] as Dictionary).get(family, 0)), 6,
			"prima saga: sei carte per la famiglia %s" % family
		)
		assert_eq(
			int((by_saga["seconda"] as Dictionary).get(family, 0)), 3,
			"seconda saga: tre carte per la famiglia %s" % family
		)


## A card belongs to the saga whose questions it names. The ones that name none -
## or name `$tension`, "the one we are talking about" - belong to both, and are
## counted with the first because that is where they were written.
func _is_second_saga(card: Dictionary) -> bool:
	const SECOND: Array = [
		"TEN_WATER", "TEN_DEBT", "TEN_RELIC", "TEN_CHARTER", "TEN_NAMELESS", "TEN_ASH",
	]
	for condition in card["eligibility"]:
		if SECOND.has(str((condition as Dictionary).get("tension_id", ""))):
			return true
	return false


## Two different cards must not ask for the same drawing (D-049).
##
## The second saga's twelve cards were generated with the key built from family
## and function - `echo.pressure.request` - which is exactly the key the first
## saga's Supplica already had. Nine of the twelve collided, and nothing noticed:
## the manifest lists whatever it is given. An art key is an order to somebody,
## and two cards sharing one is two cards that come back as the same picture.
func test_no_two_cards_ask_for_the_same_drawing() -> void:
	var seen: Dictionary = {}
	for card in data().echo_cards.values():
		var key: String = str(card["art_prompt_key"])
		assert_false(
			seen.has(key),
			"%s e %s chiedono lo stesso disegno: '%s'" % [str(seen.get(key, "")), str(card["id"]), key]
		)
		seen[key] = str(card["id"])


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
