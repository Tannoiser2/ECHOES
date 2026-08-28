extends SceneTree
## Why a Chronicle never opens a Council.
##
##   godot --headless --path godot --script res://cli/run_silence_probe.gd -- \
##       --chronicles=10 --seed=1867 --then=CHR_00
##
## A ten-Chronicle saga produced three years with **zero** Councils, while the
## same Chronicle measured on its own, over forty seeds, never produced fewer
## than one. A year with no Council is not a quiet year: it is a year in which
## nobody played. So this probe does not count outcomes - it counts *pushes*.
##
## Per Chronicle it prints, for every question in play: where it started, how
## many chips the world's drift gave it, how many pushes the table gave it, and
## where it ended relative to its threshold. Then, for every seat: the Destiny it
## carries, the level it is playing for, and which Tensions its Destiny actually
## asks it to push. The two halves together say whether a silent year is the
## world's fault or the table's.
##
## Use `--standalone` to run the same Chronicles without chaining them, which is
## the comparison that matters: same content, no inheritance.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


## The policy, with a notebook. A seat that wants a push and never makes one is
## a rule standing in the way; a seat that never asks for one has nothing to
## play for. From outside the two look identical, so the probe records what was
## *asked for* and lets the resolver's refusals show up in the log.
class Recorder extends RefCounted:
	var inner: RefCounted
	var asked: Dictionary = {}

	func _init(p_inner: RefCounted) -> void:
		inner = p_inner

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		var request: Dictionary = inner.choose_action(entity_id, ao_index, session)
		var key: String = str(request.get("template", "?"))
		if key == "INFLUENCE":
			key = "INFLUENCE%s" % ("+" if int(request["params"].get("delta", 0)) > 0 else "-")
		var per: Dictionary = asked.get(entity_id, {})
		per[key] = int(per.get(key, 0)) + 1
		asked[entity_id] = per
		return request

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return inner.choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		return inner.choose_proposition(context, options, session)

	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		return inner.choose_stance(entity_id, context, session)

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		return inner.choose_commit(entity_id, context, limit, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return inner.choose_recovery(context, session)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var chronicles: int = int(options.get("chronicles", 10))
	var first_seed: int = int(options.get("seed", 1867))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var later_id: String = str(options.get("then", chronicle_id))
	var chained: bool = not options.has("standalone")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	print("%s, %d Chronicle, seme %d" % [
		"Saga incatenata" if chained else "Chronicle isolate", chronicles, first_seed
	])

	var previous: Dictionary = {}
	var previous_results: Dictionary = {}
	var silent: int = 0

	for index in range(chronicles):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id if index == 0 else later_id, SEATS, first_seed + index * 97)
		if chained:
			session.inherit_from(previous, previous_results)

		# Where every question started, before a single round is played. Read
		# after inherit_from because that is the state the year opens with.
		var opening: Dictionary = {}
		for tension_id in session.world["tensions"]:
			opening[str(tension_id)] = session.tensions.value(str(tension_id))

		# Who wanted to push what, sampled at the first round: the goals move as
		# conditions come true, and the opening reading is the one that decides
		# whether anybody ever starts.
		var goals: Dictionary = {}
		var policy: RefCounted = PolicyDecider.new(session.log)
		var decider: RefCounted = Recorder.new(policy)
		session.chronicle.phase_changed.connect(
			func(_act: int, _round: int, phase: String) -> void:
				if phase == "SETUP" or not goals.is_empty():
					return
				for entity_id in SEATS:
					goals[str(entity_id)] = policy._tension_goals(str(entity_id), session)
		)

		# Every push on a Tension, attributed to whoever made it. `drift` is the
		# world, `action` is a seat spending an Action Opportunity on INFLUENCE,
		# `confluence` is a Consequence - which only exists once a Council has
		# already opened, so it can never be the reason one did.
		var pushes: Dictionary = {}
		session.effect_applied.connect(
			func(effect: Dictionary) -> void:
				if str(effect["type"]) != "ADJUST_TENSION":
					return
				var id: String = str(effect["target"]["id"])
				var kind: String = str(effect["source"]["kind"])
				if not pushes.has(id):
					pushes[id] = {"system": 0, "action": 0, "confluence": 0}
				pushes[id][kind] = int(pushes[id].get(kind, 0)) + int(effect["payload"]["delta"])
		)

		var report: Dictionary = await session.run(decider)
		var councils: int = (report["confluences"] as Array).size()
		if councils == 0:
			silent += 1

		print("")
		print("--- Chronicle %d (anno %d, +%d anni) - %d consigli%s" % [
			index + 1, int(session.world["year"]), session.years_passed(), councils,
			"  <<< MUTA" if councils == 0 else "",
		])
		print("    %-18s %5s %6s %7s %7s %7s" % [
			"domanda", "parte", "mondo", "tavolo", "finisce", "soglia"
		])
		for tension_id in session.world["tensions"]:
			var id: String = str(tension_id)
			var moved: Dictionary = pushes.get(id, {})
			print("    %-18s %5d %6d %7d %7d %7d" % [
				str(data.tensions[id]["title"]),
				int(opening[id]),
				int(moved.get("system", 0)),
				int(moved.get("action", 0)),
				session.tensions.value(id),
				int(data.tensions[id]["threshold"]),
			])

		for entity_id in SEATS:
			var wants: Array = []
			for tension_id in (goals.get(str(entity_id), {}) as Dictionary):
				wants.append("%s%s" % [
					"+" if int(goals[str(entity_id)][tension_id]) > 0 else "-",
					str(data.tensions[str(tension_id)]["title"]),
				])
			var spent: Array = []
			var notebook: Dictionary = (decider.asked as Dictionary).get(str(entity_id), {})
			for key in _sorted(notebook.keys()):
				spent.append("%s x%d" % [str(key), int(notebook[key])])
			print("    %-16s %-34s vuole: %-40s fa: %s" % [
				session.service.name_of(str(entity_id)),
				str(data.destinies[session.service.destiny_of(str(entity_id))]["title"]),
				"niente" if wants.is_empty() else ", ".join(PackedStringArray(wants)),
				", ".join(PackedStringArray(spent)),
			])

		previous = session.world.duplicate(true)
		previous_results = (report["destiny_results"] as Dictionary).duplicate(true)
		session.dispose()

	print("")
	print("Chronicle senza nessun consiglio: %d su %d." % [silent, chronicles])
	quit(0)


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		text = text.substr(2)
		var split: int = text.find("=")
		if split < 0:
			options[text] = true
		else:
			options[text.substr(0, split)] = text.substr(split + 1)
	return options
