extends SceneTree
## I bot giocano meglio del caso? (D-147)
##
##   godot --headless --path godot --script res://cli/run_bot_probe.gd -- \
##       --runs=40 --seed=7000
##
## «Funzionano i bot?» e' una domanda che si puo' rispondere solo mettendoli
## contro qualcosa. Qui il metro e' **il caso**: un seggio giocato dalla policy
## contro tre che scelgono a sorte fra le mosse legali (`scripted_io.pick`, la
## stessa formula pura delle sonde del filo), e poi lo stesso mondo con le parti
## invertite — la policy sui tre, il caso su uno.
##
## Non si misurano i Consigli vinti ma i **Destini**: e' quello che un seggio
## sta cercando di fare, e l'unico modo di dire «gioca bene» senza inventarsi un
## punteggio. Il caso resta legale — passa dagli stessi controlli — quindi la
## differenza e' tutta nel giudizio, non nelle regole.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ScriptedIO := preload("res://scripts/net/scripted_io.gd")

const LEVELS: Array = ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Ogni partita si gioca due volte sullo stesso mondo: una col seggio di
	# turno alla policy, una allo stesso seggio lasciato al caso. Cosi' la
	# differenza e' il giocatore e non il seme, ed e' lo stesso disegno del
	# playtest (D-051).
	var scores: Dictionary = {"policy": [], "caso": []}
	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var studied: String = str(seats[index % seats.size()])
		for who in ["policy", "caso"]:
			var session: RefCounted = GameSession.new(data)
			session.setup(chronicle_id, seats, seed_value)
			var decider: RefCounted = null
			if who == "policy":
				decider = PolicyDecider.new(session.log)
			else:
				# Il seggio studiato tira a sorte, gli altri restano policy: cosi'
				# il confronto e' «questo seggio giocato bene» contro «questo
				# seggio giocato a caso», a parita' di tavolo.
				decider = SeatDecider.new([studied], session.log)
				decider.ios[studied] = ScriptedIO.new(seed_value + 17)
			var report: Dictionary = await session.run(decider)
			(scores[who] as Array).append(LEVELS.find(
				str((report["destiny_results"] as Dictionary)[studied]["level"])
			))
			session.dispose()
		print("  partita %d/%d (%s, seme %d, %s): policy %d, caso %d" % [
			index + 1, runs, chronicle_id, seed_value, studied,
			int((scores["policy"] as Array)[-1]), int((scores["caso"] as Array)[-1]),
		])

	print("")
	print("== I BOT CONTRO IL CASO - %d partite, semi da %d ==" % [runs, first_seed])
	var better: int = 0
	var worse: int = 0
	for i in range(runs):
		var a: int = int((scores["policy"] as Array)[i])
		var b: int = int((scores["caso"] as Array)[i])
		if a > b:
			better += 1
		elif a < b:
			worse += 1
	for who in ["policy", "caso"]:
		var tally: Dictionary = {}
		var total: int = 0
		for value in scores[who]:
			tally[LEVELS[int(value)]] = int(tally.get(LEVELS[int(value)], 0)) + 1
			total += int(value)
		var line: Array = []
		for level in LEVELS:
			line.append("%s %d" % [level, int(tally.get(level, 0))])
		print("  %-7s %s   (media %.2f)" % [
			who, "  ".join(PackedStringArray(line)), float(total) / float(runs)
		])
	print("  La policy fa meglio in %d partite su %d, peggio in %d, pari in %d." % [
		better, runs, worse, runs - better - worse
	])
	# Il «fatto quando»: un bot che non batte il caso non e' un avversario, e'
	# un generatore di mosse legali.
	if better > worse:
		print("  I BOT GIOCANO: il giudizio vale piu' del sorteggio.")
		quit(0)
		return
	printerr("  I BOT NON GIOCANO: contro il caso non guadagnano niente.")
	quit(1)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
