extends SceneTree
## Il libro mastro delle domande (ISSUES 51)
##
##   godot --headless --path godot --script res://cli/run_question_ledger.gd -- \
##       --runs=60 --seed=7000 --chronicle=CHR_00
##
## [D-207](DECISIONS.md#d-207) ha lasciato aperta una domanda che il test delle
## soglie non sapeva porre: **quante volte una domanda arriva davvero al
## Consiglio?** Sei candidate su dodici non ci arrivano con la sola Deriva piu' i
## Ripple, e quel conto era aritmetica su carta - non diceva niente su cosa
## succede in partita, dove il calore lo pescano i giocatori
## ([D-192](DECISIONS.md#d-192)) e la Deriva non e' nemmeno in gioco.
##
## Stessa forma del libro mastro degli obiettivi: per ogni domanda, **quante
## volte e' stata pescata** e **quante volte ha aperto un Consiglio**. Il
## rapporto fra le due e' l'unica cifra che dice se una domanda e' quieta di
## proposito o morta per taratura.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 60))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return


	# domanda -> {"dealt", "councils", "years_with_a_council", "reached", "end_gap"}
	var ledger: Dictionary = {}
	var councils_total: int = 0
	# Lo scarto fra il mucchio piu' alto e il piu' basso, a fine di ogni Atto:
	# e' il criterio di chiusura della fase 3 di ISSUES 49, e si ricostruisce dal
	# registro degli Effetti — l'unica fonte che sa **quando** ogni punto e'
	# sceso (§6.3).
	var spread: Array = [0.0, 0.0, 0.0]
	var spread_seen: Array = [0, 0, 0]

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
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

		var here: Dictionary = {}
		for tension_id in session.world["tensions"]:
			var id: String = str(tension_id)
			if not ledger.has(id):
				ledger[id] = {
					"dealt": 0, "councils": 0, "years": 0, "gap": 0.0,
				}
			ledger[id]["dealt"] = int(ledger[id]["dealt"]) + 1
			# Quanto le e' mancato per arrivare a soglia, a fine anno.
			var value: int = session.tensions.value(id)
			var threshold: int = int(data.tensions[id]["threshold"])
			ledger[id]["gap"] = float(ledger[id]["gap"]) + float(value - threshold)
			here[id] = 0

		for entry in (report["confluences"] as Array):
			var id: String = str((entry as Dictionary).get("tension_id", ""))
			if not ledger.has(id):
				continue
			ledger[id]["councils"] = int(ledger[id]["councils"]) + 1
			councils_total += 1
			here[id] = int(here.get(id, 0)) + 1
		for id in here:
			if int(here[str(id)]) > 0:
				ledger[str(id)]["years"] = int(ledger[str(id)]["years"]) + 1

		var acts: int = int(data.chronicles[chronicle_id]["acts"])
		for act in range(1, mini(acts, 3) + 1):
			var values: Dictionary = {}
			for tension_id in session.world["tensions"]:
				values[str(tension_id)] = int(data.tensions[str(tension_id)]["current_value"])
			for entry in (session.world["effect_log"] as Array):
				var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
				if str(effect.get("type", "")) != "ADJUST_TENSION":
					continue
				if int((effect.get("source", {}) as Dictionary).get("act", 0)) > act:
					continue
				var target: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
				if not values.has(target):
					continue
				values[target] = int(values[target]) + int(
					(effect.get("payload", {}) as Dictionary).get("delta", 0)
				)
			var highest: int = -(1 << 30)
			var lowest: int = 1 << 30
			for key in values:
				highest = maxi(highest, int(values[str(key)]))
				lowest = mini(lowest, int(values[str(key)]))
			spread[act - 1] = float(spread[act - 1]) + float(highest - lowest)
			spread_seen[act - 1] = int(spread_seen[act - 1]) + 1
		session.dispose()

	print("")
	print("== IL LIBRO MASTRO DELLE DOMANDE - %d partite, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme"
	])
	print("  Consigli in tutto: %d — %.2f l'anno" % [
		councils_total, float(councils_total) / float(runs)
	])
	print("")
	print("  %-22s %8s %9s %9s %9s" % [
		"domanda", "pescata", "Consigli", "anni con", "scarto"
	])
	var ids: Array = ledger.keys()
	ids.sort_custom(func(a: String, b: String) -> bool:
		return _rate(ledger[a]) < _rate(ledger[b])
	)
	for tension_id in ids:
		var cell: Dictionary = ledger[str(tension_id)]
		var dealt: int = int(cell["dealt"])
		print("  %-22s %8d %9d %8.1f%% %+9.2f  %s" % [
			str(data.tensions[str(tension_id)]["title"]),
			dealt, int(cell["councils"]), 100.0 * _rate(cell),
			float(cell["gap"]) / float(maxi(1, dealt)),
			"MUTA" if int(cell["councils"]) == 0 else "",
		])
	print("")
	print("  Scarto fra il mucchio piu' alto e il piu' basso, a fine Atto:")
	for act in range(3):
		if int(spread_seen[act]) == 0:
			continue
		print("    atto %d   %.2f" % [
			act + 1, float(spread[act]) / float(spread_seen[act])
		])
	print("")
	print("  «anni con» = quante volte, sulle partite in cui era in gioco, ha")
	print("  aperto almeno un Consiglio. «scarto» = quanto le e' mancato per")
	print("  arrivare a soglia a fine anno, in media (negativo = sotto).")
	quit(0)


static func _rate(cell: Dictionary) -> float:
	var dealt: int = int(cell["dealt"])
	return 0.0 if dealt == 0 else float(int(cell["years"])) / float(dealt)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
