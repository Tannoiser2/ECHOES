extends SceneTree
## La sonda del tavolo pescato (D-263).
##
##   godot --headless --path godot --script res://cli/run_map_probe.gd -- \
##       --runs=100 --seed=7000
##
## La Prima Chronicle (CHR_00) non ha uno scenario: pesca le tessere, pesca le
## case, e fa solo le domande che la mappa sa reggere. Questa sonda dice se la
## pesca e' una pesca — quante mappe diverse escono, quanti tavoli diversi,
## quante domande diverse — e se l'anno pescato **decide** quanto uno scritto:
## i Consigli, e le partite arrivate in fondo. Non decide niente: conta.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var maps: Dictionary = {}
	var tables: Dictionary = {}
	var questions: Dictionary = {}
	var councils: Array = []
	var unfinished: int = 0

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito al seme %d: %s" % [seed_value, session.last_error])
			quit(3)
			return
		var map: Array = (session.world["regions"] as Dictionary).keys()
		map.sort()
		maps["/".join(PackedStringArray(map))] = int(maps.get("/".join(PackedStringArray(map)), 0)) + 1
		var table: Array = seats.duplicate()
		table.sort()
		tables["/".join(PackedStringArray(table))] = true
		var asked: Array = (session.world["tensions"] as Dictionary).keys()
		asked.sort()
		questions["/".join(PackedStringArray(asked))] = true

		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		if report.is_empty():
			unfinished += 1
		else:
			councils.append(int(session.world["confluence_count"]))
		session.dispose()

	councils.sort()
	print("")
	print("== IL TAVOLO PESCATO - %d anni di %s, semi da %d ==" % [runs, chronicle_id, first_seed])
	print("")
	print("  Mappe diverse:    %d  (le piu' battute: %s)" % [maps.size(), _top(maps)])
	print("  Tavoli diversi:   %d" % tables.size())
	print("  Anni diversi (per domande): %d" % questions.size())
	if councils.is_empty():
		print("  Nessuna partita conclusa.")
	else:
		var total: int = 0
		for count in councils:
			total += int(count)
		print("  Consigli   media %.2f   mediana %d   da %d a %d" % [
			float(total) / float(councils.size()),
			int(councils[councils.size() / 2]), int(councils[0]), int(councils.back()),
		])
	print("  Partite non concluse: %d su %d" % [unfinished, runs])
	quit(1 if unfinished > 0 else 0)


func _top(counted: Dictionary) -> String:
	var best: String = ""
	var most: int = 0
	for key in counted:
		if int(counted[key]) > most:
			most = int(counted[key])
			best = str(key)
	return "%s x%d" % [best.replace("REG_", ""), most]


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
