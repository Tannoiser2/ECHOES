extends "res://tests/test_case.gd"
## The seat a person plays (D-037, D-038).
##
## The keyboard cannot be tested, but everything around it can, and the parts
## that break silently are exactly the parts that are not the keyboard: the menu
## of legal actions, and what happens when nobody answers.
##
## The bug this suite exists for is already fixed and would have been invisible
## without it. `OS.read_string_from_stdin` returns the *same empty string* for a
## bare Enter and for end-of-input, so an earlier version latched itself off the
## first time a player accepted a default - and a player who accepted one default
## was locked out of their own game for the rest of the Chronicle. Nothing
## crashed; the game just quietly finished without them.
##
## SeatDecider is shared with the browser (D-038), so everything asserted here is
## asserted about the web build too.

const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


## With nobody at the keyboard every choice falls through to the policy, so a
## Chronicle played by four "humans" who answer nothing has to come out exactly
## like one played by four policies. That is what makes a piped script - and this
## test - a faithful way to drive the thing.
func test_a_table_that_answers_nothing_plays_like_the_policy() -> void:
	new_session(4242, false)
	# io left null: nobody is watching, so every choice defers to the policy.
	var by_hand: Dictionary = await session.run(SeatDecider.new(SEATS, session.log))
	var hand_log: String = session.log.text()
	var hand_world: String = JSON.stringify(session.world)

	new_session(4242, false)
	var by_policy: Dictionary = await session.run(PolicyDecider.new(session.log))

	assert_eq(
		int(by_hand["confluences"].size()), int(by_policy["confluences"].size()),
		"stesse Confluence"
	)
	assert_eq(session.log.text(), hand_log, "stessa partita, riga per riga")
	assert_eq(JSON.stringify(session.world), hand_world, "stesso mondo alla fine")


## Every entry the menu offers has to be an action the resolver will accept. A
## menu that lists something illegal is a player told to do something the rules
## then refuse - the worst kind of interface bug, because it reads as the game
## being broken rather than the menu being wrong.
func test_every_action_offered_is_one_the_rules_allow() -> void:
	var decider: RefCounted = SeatDecider.new(SEATS, null)
	var offered: Dictionary = {}

	for seed_value in [4242, 4243]:
		new_session(seed_value, false)
		await session.run(PolicyDecider.new(session.log))
		for entity_id in SEATS:
			for option in decider._action_options(str(entity_id), session):
				var template: String = str(option["template"])
				offered[template] = int(offered.get(template, 0)) + 1
				assert_true(
					session.actions.can_execute(str(entity_id), template, option["params"]),
					"il menu offre a %s un %s che le regole rifiutano: %s"
					% [str(entity_id), template, JSON.stringify(option["params"])]
				)
				assert_true(str(option["label"]) != "", "ogni voce ha un'etichetta")

	assert_true(offered.size() >= 3, "il menu deve coprire piu di un paio di template: %s" % str(offered))


## And it must not offer to scout something already in plain sight: an open
## Tension shows its number to everyone, so spending an Action Opportunity on it
## is a wasted turn the menu invited.
func test_the_menu_never_offers_to_scout_what_is_already_visible() -> void:
	var decider: RefCounted = SeatDecider.new(SEATS, null)
	new_session(4242, false)
	var checked: Dictionary = {"scouts": 0}
	for entity_id in SEATS:
		for option in decider._action_options(str(entity_id), session):
			if str(option["template"]) != "SCHEME":
				continue
			var tension_id: String = str(option["params"].get("tension_id", ""))
			if tension_id == "":
				continue
			checked["scouts"] = int(checked["scouts"]) + 1
			assert_true(
				session.tensions.is_veiled(tension_id),
				"il menu offre di scoprire %s, che e gia aperta" % tension_id
			)
			assert_false(
				session.service.knows_tension(str(entity_id), tension_id),
				"il menu offre di riscoprire %s a chi la conosce gia" % tension_id
			)
	assert_true(int(checked["scouts"]) > 0, "in partenza qualcosa deve essere velato")


## A seat nobody is playing is never asked anything, whatever the decider is
## told: one person at the table must not stop the other three from moving.
func test_a_seat_nobody_plays_is_left_to_the_policy() -> void:
	var decider: RefCounted = SeatDecider.new(["ENT_NAHR"], null)
	assert_true(decider._is_human("ENT_NAHR"), "il seggio scelto e umano")
	for entity_id in ["ENT_ALDRIC", "ENT_LYRA", "ENT_VAERAX"]:
		assert_false(decider._is_human(str(entity_id)), "%s resta alla policy" % entity_id)

	# And it plays them: an unattended seat still returns a legal action.
	new_session(4242, false)
	var request: Dictionary = decider.choose_action("ENT_ALDRIC", 0, session)
	assert_true(str(request["template"]) != "", "un seggio non presidiato agisce comunque")
	if str(request["template"]) != "PASS":
		assert_eq(
			session.actions.check("ENT_ALDRIC", str(request["template"]), request["params"]),
			"", "e l'azione che sceglie e legale"
		)
