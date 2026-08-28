extends SceneTree
## I tre coperti: dell'anno o della saga? (ISSUES 58)
##
##   godot --headless --path godot --script res://cli/run_objectives_probe.gd -- \
##       --sagas=20 --chronicles=10 --seed=812
##
## L'idea di partenza dice **«tre segreti che si pescano all'inizio della
## saga»**; `_deal_objectives` gira nel setup di ogni Chronicle e li ripesca ogni
## anno. La voce chiede di misurare prima di decidere, e nomina il rischio con
## precisione: *un obiettivo pescato a inizio saga puo' risultare **impossibile**
## nel mondo che la Chronicle 4 ha prodotto.*
##
## Questa sonda gioca le stesse saghe **due volte** — coi coperti dell'anno e
## coi coperti della saga — e conta la stessa cosa dai due lati. La regola sta
## nei dati (`objectives.drawn`), quindi il confronto e' fra due dichiarazioni,
## non fra due versioni del codice: si accende e si spegne senza ricompilare
## niente.
##
## Le tre domande:
##
## 1. **Quanti obiettivi diversi vede un seggio in una saga?** Ripescandoli ogni
##    anno sono tanti e brevi; una volta sola sono tre e lunghi.
## 2. **Di quei tre, quanti si avverano all'anno 5 e all'anno 10?** E' la
##    domanda della voce, ed e' il costo: un obiettivo che non si puo' piu'
##    prendere e' un giocatore che gioca senza scopo.
## 3. **Quanti non si avverano mai in tutta la saga?** Uno che non esce mai in
##    dieci anni e' spento, qualunque sia la ragione.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var sagas: int = int(options.get("sagas", 20))
	var chronicles: int = int(options.get("chronicles", 10))
	var first_seed: int = int(options.get("seed", 812))
	var first_id: String = str(options.get("chronicle", "CHR_00"))
	var later_id: String = str(options.get("then", "CHR_02"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	print("")
	print("== I TRE COPERTI: DELL'ANNO O DELLA SAGA? - %d saghe da %d (%s poi %s) ==" % [
		sagas, chronicles, first_id, later_id,
	])

	for mode in ["per_chronicle", "per_saga"]:
		for chronicle_id in [first_id, later_id]:
			var rules: Dictionary = (
				data.chronicles[chronicle_id] as Dictionary
			).get("objectives", {}) as Dictionary
			rules["drawn"] = str(mode)
		await _play(data, sagas, chronicles, first_seed, first_id, later_id, str(mode))
	quit(0)


func _play(
	data: RefCounted, sagas: int, chronicles: int, first_seed: int,
	first_id: String, later_id: String, mode: String
) -> void:
	var distinct: Array = []          # obiettivi diversi visti da un seggio in una saga
	var met_by_year: Dictionary = {}  # anno -> [avverati, contati]
	var never: int = 0                # dei coperti d'apertura, mai avverati in tutta la saga
	var opening: int = 0
	# **Quanti seggi sono ancora quelli dell'apertura.** Se una saga cambia
	# roster ogni era, «obiettivi della saga» promette piu' di quanto puo'
	# mantenere: chi si siede al quinto anno non ha una saga alle spalle.
	var seats_from_the_start: int = 0
	var seats_seen: int = 0
	var levels: Dictionary = {}

	for saga_index in range(sagas):
		var seed_base: int = first_seed + saga_index * 1009
		var previous: Dictionary = {}
		var previous_results: Dictionary = {}
		var seen: Dictionary = {}      # seggio -> {obiettivo: true}
		var first_three: Dictionary = {}  # seggio -> [obiettivi d'apertura]
		var ever_met: Dictionary = {}  # seggio -> {obiettivo: true}

		for index in range(chronicles):
			var chronicle_id: String = first_id if index == 0 else later_id
			var seed_value: int = seed_base + index * 97
			var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
			var session: RefCounted = GameSession.new(data)
			if not session.setup(chronicle_id, seats, seed_value):
				printerr("setup fallito: %s" % session.last_error)
				quit(3)
				return
			if previous.is_empty():
				for effect in session.factory_setup_effects():
					session.applier.apply(effect)
			else:
				session.inherit_from(previous, previous_results)

			for entity_id in session.world["entities"]:
				var who: String = str(entity_id)
				var mine: Dictionary = seen.get(who, {})
				for objective_id in (
					session.world["entities"][who] as Dictionary
				).get("objectives", []):
					mine[str(objective_id)] = true
				seen[who] = mine
				if index == 0:
					first_three[who] = (
						(session.world["entities"][who] as Dictionary).get("objectives", []) as Array
					).duplicate()

			var report: Dictionary = await session.run(
				Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
			)
			if report.is_empty():
				printerr("partita non conclusa al seme %d" % seed_value)
				quit(3)
				return

			var year: int = index + 1
			if index > 0:
				for entity_id in session.world["entities"]:
					seats_seen += 1
					if first_three.has(str(entity_id)):
						seats_from_the_start += 1
			var cell: Array = met_by_year.get(str(year), [0, 0])
			for entity_id in report["destiny_results"]:
				var result: Dictionary = report["destiny_results"][entity_id] as Dictionary
				var level: String = str(result.get("level", "NONE"))
				levels[level] = int(levels.get(level, 0)) + 1
				var mine2: Dictionary = ever_met.get(str(entity_id), {})
				for entry in result.get("objectives", []):
					var record: Dictionary = entry as Dictionary
					if bool(record["public"]):
						continue
					# Solo i tre d'apertura: sono quelli di cui la voce chiede
					# se si spengono. Ripescandoli ogni anno, i coperti del
					# quinto anno non sono i tre d'apertura e non c'entrano.
					if not (first_three.get(str(entity_id), []) as Array).has(str(record["id"])):
						continue
					cell[1] = int(cell[1]) + 1
					if bool(record["met"]):
						cell[0] = int(cell[0]) + 1
						mine2[str(record["id"])] = true
				ever_met[str(entity_id)] = mine2
			met_by_year[str(year)] = cell

			previous = session.world
			previous_results = report["destiny_results"]

		for who in seen:
			distinct.append((seen[who] as Dictionary).size())
		for who in first_three:
			for objective_id in (first_three[who] as Array):
				opening += 1
				if not (ever_met.get(str(who), {}) as Dictionary).has(str(objective_id)):
					never += 1

	var average: float = 0.0
	for count in distinct:
		average += float(count)
	average /= float(maxi(1, distinct.size()))

	print("")
	print("  --- coperti %s ---" % mode)
	print("  Obiettivi coperti diversi visti da un seggio in una saga: %.1f" % average)
	print("  Dei tre d'apertura, quanti si avverano:")
	var years: Array = met_by_year.keys()
	years.sort_custom(func(a: Variant, b: Variant) -> bool: return int(a) < int(b))
	for year in years:
		var cell: Array = met_by_year[str(year)]
		if int(cell[1]) == 0:
			continue
		print("    anno %2s: %5.1f%%  (%d su %d)" % [
			str(year), 100.0 * float(int(cell[0])) / float(int(cell[1])),
			int(cell[0]), int(cell[1]),
		])
	print("  Coperti d'apertura mai avverati in tutta la saga: %d su %d (%.0f%%)" % [
		never, opening, 100.0 * float(never) / float(maxi(1, opening)),
	])
	print("  Seggi che dopo l'apertura sono ancora quelli dell'apertura: %d su %d (%.0f%%)" % [
		seats_from_the_start, seats_seen,
		100.0 * float(seats_from_the_start) / float(maxi(1, seats_seen)),
	])
	var order: Array = ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]
	var line: Array = []
	var total: int = 0
	for level in order:
		total += int(levels.get(level, 0))
	for level in order:
		line.append("%s %d%%" % [
			str(level), int(round(100.0 * float(int(levels.get(level, 0))) / float(maxi(1, total)))),
		])
	print("  I livelli a fine anno: %s" % "  ".join(PackedStringArray(line)))


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not str(argument).begins_with("--"):
			continue
		var pair: PackedStringArray = str(argument).substr(2).split("=", true, 1)
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
