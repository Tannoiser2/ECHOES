extends SceneTree
## Perche' non si supera il Minimo (D-151)
##
##   godot --headless --path godot --script res://cli/run_rung_probe.gd -- \
##       --runs=60 --seed=7000
##
## D-150 ha corretto una lettura: il Minimo di ogni Destino e' «esistere», cioe'
## una soglia di sopravvivenza e non un obiettivo, e il numero che conta e'
## **quanti la superano** — fermo al 30% su trenta Chronicle, col pool dei
## Destini acceso e spento allo stesso modo.
##
## Questa sonda non chiede *se* la Vittoria e' difficile: chiede **quale
## clausola** non si avvera. Il rapporto dei Destini porta gia' `unmet` — le
## condizioni rimaste in sospeso, una per una — quindi qui non si valuta
## niente: si contano. Una clausola che manca nel 95% delle partite non e' un
## obiettivo ambizioso, e' un obiettivo che nessuno ha mai visto da vicino.
##
## Tavolo misto (D-053): quattro ottimizzatori identici sono il caso in cui
## tutti falliscono le stesse clausole per la stessa ragione.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const LEVELS: Array = ["minimum", "victory", "triumph"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 60))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var missed: Dictionary = {}   # "livello|destino|etichetta" -> volte non soddisfatta
	var played: Dictionary = {}   # destino -> quante volte giocato
	var reached: Dictionary = {}  # livello raggiunto -> quante volte
	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
		session.setup(chronicle_id, seats, seed_value)
		var decider: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		var report: Dictionary = await session.run(decider)
		for entity_id in seats:
			var result: Dictionary = (report["destiny_results"] as Dictionary)[str(entity_id)]
			var destiny_id: String = str(result["destiny_id"])
			played[destiny_id] = int(played.get(destiny_id, 0)) + 1
			reached[str(result["level"])] = int(reached.get(str(result["level"]), 0)) + 1
			var destiny: Dictionary = data.destinies[destiny_id]
			for condition in result["unmet"]:
				var label: String = str((condition as Dictionary).get("label", "?"))
				var key: String = "%s|%s|%s" % [_level_of(destiny, label), destiny_id, label]
				missed[key] = int(missed.get(key, 0)) + 1
		session.dispose()
		if (index + 1) % 10 == 0:
			print("  %d/%d partite" % [index + 1, runs])

	print("")
	print("== I GRADINI - %d Chronicle a tavolo misto, semi da %d ==" % [runs, first_seed])
	var total: int = 0
	for level in reached:
		total += int(reached[level])
	for level in ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]:
		var count: int = int(reached.get(level, 0))
		print("  %-8s %3d  (%.0f%%)" % [level, count, 100.0 * float(count) / maxf(1.0, float(total))])
	var above: int = int(reached.get("VICTORY", 0)) + int(reached.get("TRIUMPH", 0))
	print("  Supera il Minimo: %.0f%%" % (100.0 * float(above) / maxf(1.0, float(total))))

	# Le clausole che nessuno vede mai, in ordine di quanto spesso mancano.
	for level in ["victory", "triumph"]:
		print("")
		print("  Clausole di %s mai soddisfatte (su quante volte quel Destino e' stato giocato):" % level.to_upper())
		var rows: Array = []
		for key in missed:
			if not str(key).begins_with(level + "|"):
				continue
			var parts: PackedStringArray = str(key).split("|")
			var destiny_id: String = str(parts[1])
			var times: int = int(played.get(destiny_id, 1))
			rows.append({
				"share": float(missed[key]) / maxf(1.0, float(times)),
				"line": "    %3.0f%%  %-22s %s" % [
					100.0 * float(missed[key]) / maxf(1.0, float(times)), destiny_id, str(parts[2])
				],
			})
		rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return float(a["share"]) > float(b["share"])
		)
		for row in rows:
			print(str(row["line"]))
	quit(0)


static func _level_of(destiny: Dictionary, label: String) -> String:
	for level in LEVELS:
		for condition in (destiny[level] as Dictionary)["conditions"]:
			if str((condition as Dictionary).get("label", "")) == label:
				return level
	return "?"


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
