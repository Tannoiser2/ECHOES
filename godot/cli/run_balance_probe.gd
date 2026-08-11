extends SceneTree
## Balance probe: play N Chronicles with the policy decider and report the shape
## of the results (§7's expectation of 3-4 Confluence per Chronicle).
##
##   godot --headless --path godot --script res://cli/run_balance_probe.gd -- \
##       --runs=40 --seed=1000
##
## This is the measuring instrument for the balance pass. The scripted plans in
## data/chronicle_01/sim_plans answer "do the rules do what the plan says"; this
## answers "what happens when four people all play their own Destiny", which is
## the only question a balance number can come from.
##
## Fully deterministic: run it twice with the same --seed and --runs and you get
## the same table.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://cli/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 1000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var verbose: bool = bool(options.get("verbose", false))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Sweep the balance knobs without editing the data: --influence-cap=1
	# --presence-directions=UP tries a candidate rule set for this run only.
	var chronicle: Dictionary = data.chronicles[chronicle_id]
	if options.has("influence-cap") or options.has("presence-directions") or options.has("tension-cap"):
		var rules: Dictionary = (chronicle.get("influence_rules", {}) as Dictionary).duplicate(true)
		if options.has("influence-cap"):
			rules["max_per_entity_per_round"] = int(options["influence-cap"])
		if options.has("tension-cap"):
			rules["max_per_tension_per_round"] = int(options["tension-cap"])
		if options.has("presence-directions"):
			rules["presence_directions"] = Array(str(options["presence-directions"]).split(","))
		chronicle["influence_rules"] = rules
	print("influence_rules: %s" % JSON.stringify(chronicle.get("influence_rules", {})))

	var confluences: Array = []
	var outcomes: Dictionary = {}
	var levels: Dictionary = {}
	var echoes: int = 0
	var illegal: int = 0
	var influence_actions: int = 0
	var tension_finals: Dictionary = {}
	var rows: Array = []

	for i in range(runs):
		var seed_value: int = first_seed + i
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, SEATS, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(4)
			return
		var report: Dictionary = session.run(PolicyDecider.new(session.log))

		var count: int = int(session.world["confluence_count"])
		confluences.append(count)
		echoes += int(report["echoes"])
		illegal += int(report["illegal_actions"])
		for result in report["confluences"]:
			var outcome: String = str(result["outcome"])
			outcomes[outcome] = int(outcomes.get(outcome, 0)) + 1
		for entity_id in SEATS:
			var level: String = str(report["destiny_results"][entity_id]["level"])
			var key: String = "%s/%s" % [entity_id, level]
			levels[key] = int(levels.get(key, 0)) + 1
		for tension_id in session.world["tensions"]:
			var id: String = str(tension_id)
			tension_finals[id] = int(tension_finals.get(id, 0)) + session.tensions.value(id)
		for effect in session.world["effect_log"]:
			if str(effect["source"].get("id", "")) == "ACT_INFLUENCE":
				influence_actions += 1

		rows.append({"seed": seed_value, "confluences": count, "echoes": int(report["echoes"])})
		if verbose:
			print("seed %d -> %d Confluence, %d Echo" % [seed_value, count, int(report["echoes"])])
		session.dispose()

	_report(runs, confluences, outcomes, levels, echoes, illegal, influence_actions, tension_finals, data, chronicle_id)
	quit(0)


func _report(
	runs: int,
	confluences: Array,
	outcomes: Dictionary,
	levels: Dictionary,
	echoes: int,
	illegal: int,
	influence_actions: int,
	tension_finals: Dictionary,
	data: RefCounted,
	chronicle_id: String
) -> void:
	var sorted_counts: Array = confluences.duplicate()
	sorted_counts.sort()
	var total: int = 0
	for value in confluences:
		total += int(value)

	print("")
	print("== SONDA DI BILANCIAMENTO - %d Chronicle, %s ==" % [runs, chronicle_id])
	print("")
	print("Confluence per Chronicle")
	print("  media    %.2f" % (float(total) / float(maxi(1, runs))))
	print("  mediana  %d" % int(sorted_counts[sorted_counts.size() / 2]))
	print("  min/max  %d / %d" % [int(sorted_counts[0]), int(sorted_counts[sorted_counts.size() - 1])])

	var histogram: Dictionary = {}
	for value in confluences:
		histogram[int(value)] = int(histogram.get(int(value), 0)) + 1
	var keys: Array = histogram.keys()
	keys.sort()
	for key in keys:
		var count: int = int(histogram[key])
		print("    %d: %s (%d)" % [int(key), "#".repeat(count), count])

	# D-026 widens §7's 3-4 to 4-5 for a 4-Tension Chronicle, and still says to
	# report rather than silently adjust outside 2-7.
	var in_band: int = 0
	var below_floor: int = 0
	var above_ceiling: int = 0
	for value in confluences:
		if int(value) >= 4 and int(value) <= 5:
			in_band += 1
		if int(value) < 2:
			below_floor += 1
		if int(value) > 7:
			above_ceiling += 1
	print("")
	print("Atteso con 4 Tensioni (D-026): 4-5 per Chronicle, mai sotto 2 o sopra 7")
	print("  nella banda 4-5   %d/%d (%.0f%%)" % [in_band, runs, 100.0 * in_band / maxi(1, runs)])
	print("  sotto il minimo   %d/%d" % [below_floor, runs])
	print("  sopra il massimo  %d/%d" % [above_ceiling, runs])

	print("")
	print("Esiti delle Confluence")
	for outcome in ["FAILURE", "SUCCESS_WITH_COST", "SUCCESS", "DECISIVE_SUCCESS"]:
		print("  %-18s %d" % [outcome, int(outcomes.get(outcome, 0))])
	print("  Echo registrati    %d (%.2f per Chronicle)" % [echoes, float(echoes) / float(maxi(1, runs))])

	print("")
	print("Valore finale medio delle Tensioni")
	var tension_ids: Array = tension_finals.keys()
	tension_ids.sort()
	for tension_id in tension_ids:
		print(
			"  %-14s %.1f (soglia %d)"
			% [
				str(data.tensions[str(tension_id)]["title"]),
				float(int(tension_finals[tension_id])) / float(maxi(1, runs)),
				int(data.tensions[str(tension_id)]["threshold"]),
			]
		)

	print("")
	print("Livelli Destiny raggiunti")
	for entity_id in SEATS:
		var parts: Array = []
		for level in ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]:
			var value: int = int(levels.get("%s/%s" % [entity_id, level], 0))
			if value > 0:
				parts.append("%s %d" % [level, value])
		print("  %-12s %s" % [str(data.entities[entity_id]["name"]), ", ".join(PackedStringArray(parts))])

	print("")
	print("Azioni INFLUENCE totali: %d (%.1f per Chronicle)" % [
		influence_actions, float(influence_actions) / float(maxi(1, runs))
	])
	if illegal > 0:
		print("Azioni rifiutate: %d - la policy ha proposto qualcosa di illegale" % illegal)


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
