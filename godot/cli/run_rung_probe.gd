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
	var control_hist: Dictionary = {}  # Regioni tenute a fine anno -> quanti seggi
	var per_seat: Dictionary = {}   # casa -> [Regioni all'inizio, somma a fine anno, partite]
	var granted: Dictionary = {}  # Chronicle -> quante volte una casella e' passata di mano
	var cleared: Dictionary = {}  # Chronicle -> quante volte una casella e' rimasta a nessuno
	var owned_regions: int = 0    # caselle con un padrone, sommate su tutte le partite
	var total_regions: int = 0    # caselle esistite, sommate su tutte le partite
	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
		session.setup(chronicle_id, seats, seed_value)
		var decider: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		# Quante Regioni ha in mano ogni casa *prima* che si giochi: e' il termine
		# di paragone che manca a una clausola scritta come «almeno due».
		for entity_id in seats:
			var row: Array = per_seat.get(str(entity_id), [0, 0, 0]) as Array
			row[0] = int(row[0]) + int(session.service.control_count(str(entity_id)))
			per_seat[str(entity_id)] = row
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
			# Quante Regioni tiene davvero, a fine anno. La clausola chiede due:
			# la domanda e' se due sia raro o se sia fuori dal mondo.
			var held: int = int(session.service.control_count(str(entity_id)))
			control_hist[held] = int(control_hist.get(held, 0)) + 1
			var seat_row: Array = per_seat.get(str(entity_id), [0, 0, 0]) as Array
			seat_row[1] = int(seat_row[1]) + held
			seat_row[2] = int(seat_row[2]) + 1
			per_seat[str(entity_id)] = seat_row
		# Il controllo non si prende con un'azione: passa solo per una Consequence,
		# cioe' per un Consiglio che si chiude. Contare i SET_CONTROL applicati
		# dice se la strettoia e' l'offerta o l'approvazione.
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(effect.get("type", "")) != "SET_CONTROL":
				continue
			var to: Variant = (effect.get("payload", {}) as Dictionary).get("entity_id", null)
			if to == null or str(to) == "":
				cleared[chronicle_id] = int(cleared.get(chronicle_id, 0)) + 1
			else:
				granted[chronicle_id] = int(granted.get(chronicle_id, 0)) + 1
		for region_id in (session.world["regions"] as Dictionary):
			total_regions += 1
			var owner: Variant = (session.world["regions"] as Dictionary)[region_id].get("control", null)
			if owner != null and str(owner) != "":
				owned_regions += 1
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

	# La mappa a fine anno: quante Regioni tiene un seggio, e quante ne restano
	# senza padrone. Una clausola che chiede due Regioni si legge solo qui.
	print("")
	print("  Regioni tenute a fine anno (per seggio):")
	var seats_seen: int = 0
	for held in control_hist:
		seats_seen += int(control_hist[held])
	var keys: Array = control_hist.keys()
	keys.sort()
	for held in keys:
		var count: int = int(control_hist[held])
		print("    %d Regioni: %3d seggi  (%.0f%%)" % [
			int(held), count, 100.0 * float(count) / maxf(1.0, float(seats_seen))
		])
	print("  Caselle con un padrone: %d su %d  (%.0f%%)" % [
		owned_regions, total_regions,
		100.0 * float(owned_regions) / maxf(1.0, float(total_regions))
	])
	print("  Da dove parte e dove arriva ogni casa (media delle Regioni tenute):")
	var houses: Array = per_seat.keys()
	houses.sort()
	for entity_id in houses:
		var row: Array = per_seat[entity_id] as Array
		var games: float = maxf(1.0, float(row[2]))
		print("    %-12s inizio %.2f  ->  fine %.2f" % [
			str(entity_id), float(row[0]) / games, float(row[1]) / games
		])
	print("  Caselle passate di mano in gioco (solo via Consequence):")
	for chronicle_id in ["CHR_01", "CHR_03"]:
		print("    %s: %d prese, %d lasciate a nessuno" % [
			chronicle_id, int(granted.get(chronicle_id, 0)), int(cleared.get(chronicle_id, 0))
		])

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
