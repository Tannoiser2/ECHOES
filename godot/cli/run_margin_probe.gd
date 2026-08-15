extends SceneTree
## Where the margin comes from (§12.3, appendix A5).
##
##   godot --headless --path godot --script res://cli/run_margin_probe.gd -- --runs=40
##
## `run_balance_probe.gd` counts *outcomes*: how many Failures, how many
## Decisive. This one counts the number underneath them - S, O, and the whole
## distribution of M - because an outcome table can move a long way while the
## average margin barely moves, and then the outcome table is not telling you
## what changed.
##
## That is exactly what happened when the Asset library went from 12 cards to 48
## (D-040): the mean margin moved by 0.14 and Decisive Success went from a third
## of all Councils to a half. The reason was visible only here - the 12-card set
## piled its mass on M=+4, one point below the Decisive band, and a wider library
## smoothed the distribution and pushed that pile over the line.
##
## Deterministic: same seeds, same table, every time.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const FIRST_SEED: int = 1000


func _initialize() -> void:
	var runs: int = 40
	# `--chronicle` come nella sonda delle posizioni (D-066): questa guardava
	# solo la prima saga, con i seggi cablati nel file.
	var chronicle_id: String = "CHR_01"
	# `--tavolo=misto` come nella sonda delle scelte: l'ottimizzatore da solo
	# quasi non si oppone, e un margine misurato senza opposizione dice poco.
	var mixed: bool = false
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--runs="):
			runs = int(str(argument).split("=")[1])
		elif str(argument).begins_with("--chronicle="):
			chronicle_id = str(argument).split("=")[1]
		elif str(argument) == "--tavolo=misto":
			mixed = true

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	if not data.chronicles.has(chronicle_id):
		printerr("nessuna Chronicle '%s'" % chronicle_id)
		quit(4)
		return
	var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()

	var councils: int = 0
	var support: int = 0
	var oppose: int = 0
	var unopposed: int = 0
	var margins: Dictionary = {}
	var supports: Dictionary = {}
	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, seats, FIRST_SEED + i)
		var table: RefCounted = PolicyDecider.new(session.log)
		if mixed:
			table = Characters.deal(seats, RngService.new(FIRST_SEED + i), session.log)
		var report: Dictionary = await session.run(table)
		for result in report["confluences"]:
			councils += 1
			support += int(result["support_total"])
			oppose += int(result["oppose_total"])
			if int(result["oppose_total"]) == 0:
				unopposed += 1
			_tally(margins, int(result["margin"]))
			_tally(supports, int(result["support_total"]))
		session.dispose()

	print("")
	print("== SONDA DEI MARGINI - %d Chronicle, %s, tavolo %s ==" % [runs, chronicle_id, "misto" if mixed else "uniforme"])
	print("")
	print("Consigli: %d" % councils)
	print("  S medio   %.2f" % (float(support) / maxf(councils, 1)))
	print("  O medio   %.2f" % (float(oppose) / maxf(councils, 1)))
	print("  S-O       %.2f" % (float(support - oppose) / maxf(councils, 1)))
	print("  senza nessuno che si oppone: %d (%d%%)" % [
		unopposed, unopposed * 100 / maxi(councils, 1),
	])
	# The bands of §12.3 are read off M, so the histogram is the balance: a pile
	# sitting on +4 and a pile sitting on +5 are the same average and two
	# different games.
	_histogram("Margine M (<=-1 Failure · 0-1 con Costo · 2-4 Successo · >=5 Decisivo)", margins)
	_histogram("Fronte Support S", supports)
	quit(0)


func _tally(into: Dictionary, value: int) -> void:
	into[value] = int(into.get(value, 0)) + 1


func _histogram(title: String, counts: Dictionary) -> void:
	print("")
	print("%s:" % title)
	var keys: Array = counts.keys()
	keys.sort()
	for key in keys:
		print("  %+3d  %s (%d)" % [int(key), "#".repeat(int(counts[key])), int(counts[key])])
