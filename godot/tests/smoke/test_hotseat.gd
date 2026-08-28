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


## A seat that writes down what it was asked and answers whatever it was told
## to. It is the whole of what an `io` is, which is the point: the terminal and
## the browser screen are the same two methods.
class RecordingIo extends RefCounted:
	var labels: Array = []
	var subjects: Array = []
	var answer: int = -1

	func say(_text: String) -> void:
		pass

	func choose(_prompt: String, p_labels: Array, p_subjects: Array = []) -> int:
		labels = p_labels
		subjects = p_subjects
		return answer


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


## The map is pressable because the decider says which choice is about which
## Region (D-039). If that stops lining up, the browser lights up one Region and
## sends a presence to another - a bug no headless run would ever show, so it is
## asserted here rather than looked at.
func test_a_move_carries_the_region_it_is_about() -> void:
	new_session(4242, false)
	var decider: RefCounted = SeatDecider.new(SEATS, null)
	var io := RecordingIo.new()
	io.answer = -1  # "you decide": the point is what was offered, not what came back
	decider.io = io

	var options: Array = decider._action_options("ENT_ALDRIC", session)
	await decider.choose_action("ENT_ALDRIC", 0, session)

	assert_eq(io.subjects.size(), io.labels.size(), "un soggetto per ogni voce offerta")
	var moves: int = 0
	for i in range(options.size()):
		var subject: Dictionary = io.subjects[i]
		var named: String = str(subject.get("region", ""))
		if str(options[i]["template"]) == "MOVE":
			moves += 1
			assert_eq(
				named, str(options[i]["params"]["region_id"]),
				"il luogo dichiarato e quello dove la mossa mette la presenza"
			)
			assert_true(session.world["regions"].has(named), "ed e una Regione che esiste")
		else:
			assert_eq(named, "", "solo una mossa ha un posto sulla mappa")
	assert_true(moves > 0, "in partenza qualche Regione deve essere raggiungibile")
	assert_eq(
		str((io.subjects[io.subjects.size() - 1] as Dictionary).get("region", "")), "",
		"e 'Passa' non e un posto"
	)


## And pressing it does what it says: the index the map reports is the index of
## that move, not of the one next to it.
func test_pressing_a_region_is_choosing_that_move() -> void:
	new_session(4242, false)
	var decider: RefCounted = SeatDecider.new(SEATS, null)
	var io := RecordingIo.new()
	decider.io = io

	var options: Array = decider._action_options("ENT_ALDRIC", session)
	var chosen: int = -1
	for i in range(options.size()):
		if str(options[i]["template"]) == "MOVE":
			chosen = i
	assert_true(chosen >= 0, "ci deve essere almeno una mossa da scegliere")

	io.answer = chosen
	var request: Dictionary = await decider.choose_action("ENT_ALDRIC", 0, session)
	assert_eq(str(request["template"]), "MOVE", "quello che torna e una mossa")
	assert_eq(
		str(request["params"]["region_id"]), str(options[chosen]["params"]["region_id"]),
		"verso la Regione che era stata premuta"
	)
	assert_eq(
		session.actions.check("ENT_ALDRIC", "MOVE", request["params"]), "",
		"e le regole la accettano"
	)


## §12.3's recovery is the last decision the rules give a player, and it was the
## only one nobody was ever asked (D-042). It is asked before the roll - "what
## would you save if this falls" - and only when there is something to save.
func test_the_seat_that_opposed_chooses_what_it_keeps() -> void:
	new_session(4242, false)
	var decider: RefCounted = SeatDecider.new(["ENT_NAHR"], null)
	var io := RecordingIo.new()
	io.answer = 1
	decider.io = io

	var context: Dictionary = {
		"stances": {"ENT_NAHR": {"stance": "OPPOSE"}},
		"commits": {"ENT_NAHR": ["AST_BONDS_OATH", "AST_KNOWLEDGE_PROOF"]},
	}
	var recovery: Dictionary = await decider.choose_recovery(context, session)
	assert_eq(io.labels.size(), 2, "le due carte recuperabili sono state offerte")
	assert_eq(
		str(recovery.get("ENT_NAHR", "")), "AST_KNOWLEDGE_PROOF",
		"e torna quella scelta, non la piu forte"
	)


## A card whose own rule says it never comes back is not offered: a choice the
## resolver is about to ignore is worse than no choice.
func test_a_card_that_never_comes_back_is_not_offered() -> void:
	new_session(4242, false)
	var decider: RefCounted = SeatDecider.new(["ENT_NAHR"], null)
	var io := RecordingIo.new()
	decider.io = io

	var context: Dictionary = {
		"stances": {"ENT_NAHR": {"stance": "OPPOSE"}},
		# La Banda Armata e ALWAYS_DISCARD: resta una sola carta recuperabile,
		# e una sola carta non e una scelta.
		"commits": {"ENT_NAHR": ["AST_FORCE_WARBAND", "AST_BONDS_OATH"]},
	}
	var recovery: Dictionary = await decider.choose_recovery(context, session)
	assert_true(io.labels.is_empty(), "senza alternative non si chiede niente")
	assert_true(recovery.is_empty(), "e la scelta resta al motore")


## And a seat that did not oppose has no recovery to name at all.
func test_a_seat_that_did_not_oppose_is_not_asked() -> void:
	new_session(4242, false)
	var decider: RefCounted = SeatDecider.new(["ENT_NAHR"], null)
	var io := RecordingIo.new()
	decider.io = io

	var context: Dictionary = {
		"stances": {"ENT_NAHR": {"stance": "SUPPORT"}},
		"commits": {"ENT_NAHR": ["AST_BONDS_OATH", "AST_KNOWLEDGE_PROOF"]},
	}
	var recovery: Dictionary = await decider.choose_recovery(context, session)
	assert_true(io.labels.is_empty(), "chi ha sostenuto non recupera niente")
	assert_true(recovery.is_empty(), "e non compare nella mappa dei recuperi")


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


## D-194: **quando le carte sono l'unica moneta, il menu offre le carte.**
##
## E' la stessa promessa del test qui sopra — «mai offrire cio' che le regole
## rifiutano» — ma quel test non poteva accorgersi della sua rottura: chiede
## `can_execute`, cioe' `check()`, e D-188 ha spostato il divieto delle sei
## azioni dirette in `execute()`. Il menu proponeva «Acquisisci una carta
## AUTORITA'» e il resolver la rifiutava un istante dopo. Questo lo prova dal
## lato giusto: sotto l'economia delle carte **nessuna voce del menu porta un
## template diretto**.
func test_with_cards_the_menu_offers_cards_and_not_the_six_actions() -> void:
	var decider: RefCounted = SeatDecider.new(SEATS, null)
	new_session(4242)
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	chronicle["actions_from_cards"] = true
	session.actions.set("_chronicle", chronicle)

	var direct: Array = ["ACQUIRE", "MOVE", "INFLUENCE", "FORGE", "SCHEME", "CLAIM"]
	var seen: Dictionary = {}
	for entity_id in SEATS:
		for option in decider._action_options(str(entity_id), session):
			var template: String = str(option["template"])
			seen[template] = int(seen.get(template, 0)) + 1
			assert_false(
				direct.has(template),
				"il menu offre a %s un %s diretto, che execute() rifiutera'"
				% [str(entity_id), template]
			)
			# E resta vero che cio' che si offre si puo' fare.
			var outcome: Dictionary = session.actions.execute(
				str(entity_id), {"template": template, "params": option["params"]}
			)
			assert_true(
				bool(outcome["ok"]),
				"il menu offre a %s qualcosa che le regole rifiutano: %s"
				% [str(entity_id), str(outcome.get("error", ""))]
			)
			break  # una voce per seggio: eseguirle tutte cambierebbe il mondo
	assert_true(
		int(seen.get("PLAY_CARD", 0)) > 0,
		"col gioco a carte il menu propone carte da calare: %s" % str(seen)
	)
	chronicle.erase("actions_from_cards")
