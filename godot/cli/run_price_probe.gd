extends SceneTree
## La sonda della pedina del prezzo (PZ-5 Fase A, D-267).
##
##   godot --headless --path godot --script res://cli/run_price_probe.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_01
##
## La forma del dibattito voluta dal committente: il proponente sceglie le
## opportunita', **gli avversari scelgono i malus**. Questa sonda dice se la
## scelta esiste davvero al tavolo - quante pedine si posano, quante volte il
## prezzo scattato e' quello del fronte avverso e non quello del mondo, e
## quante volte il tavolo tace e il silenzio paga. Una regola mai esercitata
## e' contenuto che esiste nei dati e non esiste al tavolo (lezione di D-035).

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var councils: int = 0
	var pedine: int = 0
	var chosen_costs: int = 0
	var chosen_vents: int = 0
	var silences: int = 0
	var unfinished: int = 0

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito al seme %d: %s" % [seed_value, session.last_error])
			quit(3)
			return
		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		if report.is_empty():
			unfinished += 1
		councils += int(session.world["confluence_count"])
		for line in session.log.lines:
			var text: String = str(line)
			if text.contains("La pedina del prezzo -"):
				pedine += 1
			elif text.contains("Il costo e' quello della pedina"):
				chosen_costs += 1
			elif text.contains("Lo sfogo e' quello della pedina"):
				chosen_vents += 1
			elif text.contains("Il tavolo tace: il silenzio avvantaggia"):
				silences += 1
		session.dispose()

	print("")
	print("== LA PEDINA DEL PREZZO - %d anni di %s, semi da %d ==" % [runs, chronicle_id, first_seed])
	print("")
	print("  Consigli                 %d" % councils)
	print("  Pedine posate            %d  (%.0f%% dei Consigli)" % [
		pedine, 100.0 * float(pedine) / float(maxi(1, councils))
	])
	print("  Il prezzo l'ha deciso il fronte avverso:")
	print("    costi (passa pagando)  %d" % chosen_costs)
	print("    sfoghi (proposta caduta) %d" % chosen_vents)
	print("  Il tavolo ha taciuto     %d volte" % silences)
	if unfinished > 0:
		print("  Partite non concluse: %d su %d" % [unfinished, runs])
	quit(1 if unfinished > 0 else 0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
