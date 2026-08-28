extends SceneTree
## Crisis probe: do crises always break in the end, or can a table hold them shut?
##
##   godot --headless --path godot --script res://cli/run_crisis_probe.gd -- \
##       --runs=40 --seed=5000
##
## Two tables play the same Chronicles.
##
## `policy` is four people pursuing their own Destiny - the ordinary measurement.
## `suppress` is four people doing nothing but pushing every Tension down for
## nine rounds. The second is nobody's idea of a game; it is the stress test.
## If the suppressors can keep a Chronicle silent, then a real table can too, and
## "the crisis always breaks eventually" is not true.
##
## Reported per Tension: how often it reached its threshold at all, the highest
## value it got to, and how much of the world's own pressure was cancelled.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SuppressorDecider := preload("res://cli/suppressor_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 5000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	print("")
	print("== LE CRISI SCOPPIANO SEMPRE? - %d Chronicle, %s ==" % [runs, chronicle_id])
	_measure(data, runs, first_seed, chronicle_id, "policy")
	_measure(data, runs, first_seed, chronicle_id, "suppress")
	quit(0)


func _measure(data: RefCounted, runs: int, first_seed: int, chronicle_id: String, mode: String) -> void:
	var fired: Dictionary = {}          # tension -> Chronicles where it opened a Confluence
	var peak: Dictionary = {}           # tension -> highest value ever seen
	var ended_at: Dictionary = {}       # tension -> summed final value
	var appearances: Dictionary = {}    # tension -> Chronicles it was drawn into
	var confluences: int = 0
	var silent_chronicles: int = 0
	# A Dictionary, not two ints: a GDScript lambda captures a local by *value*,
	# so counters incremented inside the signal handler would never come back out.
	var tally: Dictionary = {"down": 0, "up": 0}

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, SEATS, first_seed + i)

		# Watch the peak: the final value hides a Tension that was pushed to the
		# brink and shoved back down, which is exactly the case in question.
		var seen_peak: Dictionary = {}
		session.applier.effect_applied.connect(
			func(effect: Dictionary) -> void:
				if str(effect["type"]) != "ADJUST_TENSION":
					return
				var id: String = str(effect["target"]["id"])
				if not session.world["tensions"].has(id):
					return
				var value: int = session.tensions.value(id)
				seen_peak[id] = maxi(int(seen_peak.get(id, 0)), value)
				var delta: int = int(effect["payload"].get("delta", 0))
				var kind: String = str(effect["source"].get("kind", ""))
				if delta < 0 and kind == "action":
					tally["down"] = int(tally["down"]) + 1
				elif delta > 0 and kind != "action":
					tally["up"] = int(tally["up"]) + 1
		)

		var decider: Object = (
			SuppressorDecider.new() if mode == "suppress" else PolicyDecider.new(session.log)
		)
		var report: Dictionary = await session.run(decider)

		var opened: Dictionary = {}
		for result in report["confluences"]:
			opened[str(result["tension_id"])] = true
		confluences += int(session.world["confluence_count"])
		if int(session.world["confluence_count"]) == 0:
			silent_chronicles += 1

		for tension_id in session.world["tensions"]:
			var id: String = str(tension_id)
			appearances[id] = int(appearances.get(id, 0)) + 1
			if opened.has(id):
				fired[id] = int(fired.get(id, 0)) + 1
			peak[id] = maxi(int(peak.get(id, 0)), int(seen_peak.get(id, 0)))
			ended_at[id] = int(ended_at.get(id, 0)) + session.tensions.value(id)
		session.dispose()

	print("")
	print("--- tavolo: %s ---" % ("quattro Destiny" if mode == "policy" else "SOLO SOPPRESSIONE"))
	print("  Confluence totali        %d (%.2f per Chronicle)" % [
		confluences, float(confluences) / float(maxi(1, runs))
	])
	print("  Chronicle senza nessuna  %d/%d" % [silent_chronicles, runs])
	print("  spinte in giu dai giocatori %d - spinte in su dal mondo %d" % [
		int(tally["down"]), int(tally["up"])
	])
	print("")
	print("  %-22s %-10s %-8s %-8s %s" % ["Tensione", "e scoppiata", "picco", "soglia", "valore finale medio"])
	var ids: Array = appearances.keys()
	ids.sort()
	for tension_id in ids:
		var seen: int = int(appearances[tension_id])
		print("  %-22s %-10s %-8d %-8d %.1f" % [
			str(data.tensions[str(tension_id)]["title"]),
			"%d/%d" % [int(fired.get(tension_id, 0)), seen],
			int(peak.get(tension_id, 0)),
			int(data.tensions[str(tension_id)]["threshold"]),
			float(int(ended_at.get(tension_id, 0))) / float(maxi(1, seen)),
		])


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
