extends SceneTree
## Il libro mastro degli obiettivi (ISSUES 52)
##
##   godot --headless --path godot --script res://cli/run_objective_ledger.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_01
##
## `run_objective_probe` misurava il **preventivo**: quanto vale ogni
## obiettivo prima che il gioco lo giochi ([D-196](DECISIONS.md#d-196)). Questa
## sonda misura il **consuntivo**, e per un motivo preciso: il tasso medio di un
## obiettivo non dice niente su chi lo manca. «A_STONE si avvera il 79% delle
## volte» sta benissimo in una riga e nasconde che a una casa sola non riesce
## mai.
##
## Per ogni coppia **seggio × obiettivo** conta quante volte l'obiettivo e'
## stato pescato e quante e' stato preso. Le due domande di ISSUES 52 hanno
## bisogno di quella coppia:
##
##   · un seggio che manca **sempre le stesse carte** e' una taratura — o quelle
##     carte non parlano di lui, o il palese gli costa piu' che agli altri;
##   · un seggio che ne manca **ogni volta di diverse** non ha un problema di
##     obiettivi: ha un problema di posizione, e va cercato sulla mappa.
##
## Il palese (il Destino dell'entita') e' contato a parte, perche' e' l'unica
## carta che non si pesca: e' la casa.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()

	# seggio -> obiettivo -> {"dealt": n, "taken": n}
	var ledger: Dictionary = {}
	# seggio -> istogramma 0..4
	var counts: Dictionary = {}
	var names: Dictionary = {}

	for run in range(runs):
		var seed_value: int = first_seed + run
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(3)
			return
		var decider: RefCounted = (
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		var report: Dictionary = await session.run(decider)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return

		for entity_id in seats:
			var id: String = str(entity_id)
			names[id] = str((session.world["entities"][id] as Dictionary).get("name", id))
			if not ledger.has(id):
				ledger[id] = {}
				counts[id] = [0, 0, 0, 0, 0]
			var taken_now: int = 0
			for entry in session.destinies.objectives_of(id):
				var card: Dictionary = entry as Dictionary
				var key: String = ("PALESE %s" % str(card["title"])) if bool(card["public"]) \
					else str(card["title"])
				if not (ledger[id] as Dictionary).has(key):
					ledger[id][key] = {"dealt": 0, "taken": 0}
				ledger[id][key]["dealt"] = int(ledger[id][key]["dealt"]) + 1
				if bool(card["met"]):
					ledger[id][key]["taken"] = int(ledger[id][key]["taken"]) + 1
					taken_now += 1
			(counts[id] as Array)[clampi(taken_now, 0, 4)] += 1
		session.dispose()

	print("")
	print("== IL LIBRO MASTRO DEGLI OBIETTIVI - %d partite, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme"
	])
	var ids: Array = ledger.keys()
	ids.sort()
	for entity_id in ids:
		var id: String = str(entity_id)
		var histogram: Array = counts[id]
		print("")
		print("  %s — presi su quattro: 0:%d  1:%d  2:%d  3:%d  4:%d" % [
			str(names[id]),
			int(histogram[0]), int(histogram[1]), int(histogram[2]),
			int(histogram[3]), int(histogram[4]),
		])
		var rows: Array = (ledger[id] as Dictionary).keys()
		rows.sort_custom(func(a: String, b: String) -> bool:
			return _rate(ledger[id][a]) < _rate(ledger[id][b])
		)
		for key in rows:
			var cell: Dictionary = ledger[id][str(key)]
			print("      %-46s pescato %3d   preso %3d   %5.1f%%" % [
				str(key), int(cell["dealt"]), int(cell["taken"]), 100.0 * _rate(cell)
			])
	quit(0)


static func _rate(cell: Dictionary) -> float:
	var dealt: int = int(cell["dealt"])
	return 0.0 if dealt == 0 else float(int(cell["taken"])) / float(dealt)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
