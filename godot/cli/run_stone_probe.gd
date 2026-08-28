extends SceneTree
## La vita delle pietre (ISSUES 39, strada C)
##
##   godot --headless --path godot --script res://cli/run_stone_probe.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_00
##
## «74 costruite, zero abbattute» era il numero che ha aperto la strada C, e da
## allora nessuno l'ha rimisurato. La domanda e' se la mappa ha una **vita** —
## si alza, sale di grado, cade — o se puo' soltanto riempirsi.
##
## E c'e' una seconda domanda che ISSUES 52 ha reso urgente: **una casa puo'
## decidere di costruire?** Le pietre entrano in tre modi — l'apertura, una
## carta impegnata al Consiglio, una Conseguenza — e solo il secondo e' una
## scelta di chi gioca. Se quel numero e' vicino a zero, ogni obiettivo che
## chiede una struttura e' deciso dal setup, non dall'anno.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var built: Dictionary = {}     # sorgente -> quante
	var razed: int = 0
	var risen: int = 0
	var fallen: int = 0
	var moved: int = 0
	var ruined: int = 0
	var standing: int = 0
	var owned_at_end: Dictionary = {}   # seggio -> quante sue in piedi
	var seats_seen: Dictionary = {}
	var grade_two: int = 0

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

		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var source: Dictionary = effect.get("source", {}) as Dictionary
			var kind: String = str(source.get("kind", ""))
			var id: String = str(source.get("id", ""))
			match str(effect.get("type", "")):
				"BUILD_STRUCTURE":
					var where: String = "l'apertura"
					if id != "SETUP":
						where = "una carta impegnata" if kind == "entity" else "il Consiglio o un'Eco"
					built[where] = int(built.get(where, 0)) + 1
				"RAZE_STRUCTURE":
					# Una struttura di grado 1 che deve scendere non scende:
					# **va in rovina**, e la rovina passa da qui e non da
					# SET_STRUCTURE_GRADE. Contarle insieme diceva «zero scese»
					# su cento partite, che sembrava un motore spento.
					if id == "DESTINY_FALL":
						ruined += 1
					else:
						razed += 1
				"SET_STRUCTURE_GRADE":
					# Il motore scrive il **grado assoluto**, non uno scarto: la
					# prima versione di questa sonda leggeva `delta` e contava
					# zero salite su cento partite. Il numero era falso e
					# sembrava un difetto del gioco — e' la sonda che chiedeva
					# la cosa sbagliata. Chi ha alzato o abbassato lo dice la
					# firma dell'Effetto.
					if id == "DESTINY_RISE":
						risen += 1
					elif id == "DESTINY_FALL":
						fallen += 1
					else:
						moved += 1

		for region_id in session.world["regions"]:
			for structure in ((session.world["regions"][region_id] as Dictionary).get("structures", []) as Array):
				var record: Dictionary = structure as Dictionary
				standing += 1
				if int(record.get("grade", 1)) >= 2:
					grade_two += 1
				var holder: Variant = record.get("owner", null)
				if holder != null:
					owned_at_end[str(holder)] = int(owned_at_end.get(str(holder), 0)) + 1
		for entity_id in seats:
			seats_seen[str(entity_id)] = int(seats_seen.get(str(entity_id), 0)) + 1
		session.dispose()

	var total_built: int = 0
	for key in built:
		total_built += int(built[str(key)])

	print("")
	print("== LA VITA DELLE PIETRE - %d partite, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme"
	])
	print("")
	print("  Alzate in tutto: %d — %.2f a partita" % [total_built, float(total_built) / float(runs)])
	var sources: Array = built.keys()
	sources.sort()
	for key in sources:
		print("    %-28s %5d   %5.2f a partita" % [
			str(key), int(built[str(key)]), float(built[str(key)]) / float(runs)
		])
	print("")
	print("  Abbattute:            %5d   %5.2f a partita" % [razed, float(razed) / float(runs)])
	print("  Andate in rovina (chi non ha ottenuto niente): %5d   %5.2f a partita" % [
		ruined, float(ruined) / float(runs)
	])
	print("  Salite di grado:      %5d   %5.2f a partita" % [risen, float(risen) / float(runs)])
	print("  Scese di grado:       %5d   %5.2f a partita" % [fallen, float(fallen) / float(runs)])
	print("  Grado cambiato da un Consiglio o da un'Eco: %5d   %5.2f a partita" % [
		moved, float(moved) / float(runs)
	])
	print("  In piedi a fine anno: %5d   %5.2f a partita" % [standing, float(standing) / float(runs)])
	print("  — di cui grado 2+:    %5d   %5.2f a partita" % [
		grade_two, float(grade_two) / float(runs)
	])
	print("")
	print("  Pietre sue a fine anno, per casa (media sugli anni in cui sedeva):")
	var ids: Array = seats_seen.keys()
	ids.sort()
	for entity_id in ids:
		var years: int = int(seats_seen[str(entity_id)])
		print("    %-14s %5.2f   (%d anni al tavolo)" % [
			str(entity_id), float(int(owned_at_end.get(str(entity_id), 0))) / float(maxi(1, years)), years
		])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
