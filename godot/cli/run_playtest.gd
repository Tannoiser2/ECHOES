extends SceneTree
## Cento partite a un tavolo misto, e cento allo stesso tavolo di prima.
##
##   godot --headless --path godot --script res://cli/run_playtest.gd -- \
##       --runs=100 --seed=7000
##
## La D-051 ha concluso che gli esiti si raggruppano - diversi seggi a 37-40 su
## 40 di un livello - **non** per come e scritto il contenuto ma perche a ogni
## seggio siede lo stesso ottimizzatore deterministico, e che serviva un tavolo
## di persone vere per dirlo. Questa e l'approssimazione piu vicina che si possa
## fare senza persone: quattro caratteri diversi, mescolati fra i seggi a ogni
## partita, contro il tavolo di quattro ottimizzatori identici.
##
## E' un esperimento con una previsione dichiarata prima di eseguirlo: se
## l'ipotesi regge, il tavolo misto deve rompere i 40/40. Se non li rompe, la
## D-051 aveva torto e il problema e nelle clausole.
##
## Le due meta girano sugli stessi semi, quindi la differenza e il tavolo e non
## la fortuna.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const LEVELS: Array = ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# **Cento anni pescati, non due scritti** (D-318).
	#
	# Fino a 0.1.279 il cancello girava meta' su CHR_01 e meta' su CHR_03, due
	# anni d'autore con quattro e cinque Tensioni fisse. D-317 ha misurato cosa
	# costava: **48 delle 60 carte Tensione non arrivavano mai al tavolo**, e
	# ogni numero di bilanciamento a verbale era stato preso su una partita che
	# nella scatola non c'e'.
	#
	# Adesso ogni seme e' un anno diverso di CHR_00: la mappa si pesca dal parco
	# tessere, le case dal loro parco, le questioni dalle sessanta. Cento semi
	# fanno cento tavoli, invece di due ripetuti cinquanta volte.
	var plan: Array = []
	for _i in range(runs):
		plan.append("CHR_00")

	# La leva si prova senza toccare i dati, come i cap su INFLUENCE:
	# `--oppose-recovery=0` fa costare il fronte contrario quanto la proposta.
	if options.has("oppose-recovery"):
		var recovers: bool = str(options["oppose-recovery"]) not in ["0", "false", "no"]
		for chronicle_id in ["CHR_00"]:
			var chronicle: Dictionary = data.chronicles[chronicle_id]
			var rules: Dictionary = (
				(chronicle.get("confluence_rules", {}) as Dictionary).duplicate(true)
			)
			rules["opposer_recovers_on_failure"] = recovers
			chronicle["confluence_rules"] = rules
		print("confluence_rules: opposer_recovers_on_failure = %s" % str(recovers))

	# La seconda leva della 0.2 (D-098): quanto sfoga una proposta affondata.
	# `--failure-delta=-1` toglie meta' della rendita del blocco, senza toccare
	# i dati - come sopra, e come i cap su INFLUENCE.
	if options.has("failure-delta"):
		var failure_delta: int = int(str(options["failure-delta"]))
		for chronicle_id in ["CHR_00"]:
			var chronicle: Dictionary = data.chronicles[chronicle_id]
			var rules: Dictionary = (
				(chronicle.get("confluence_rules", {}) as Dictionary).duplicate(true)
			)
			rules["failure_delta"] = failure_delta
			chronicle["confluence_rules"] = rules
		print("confluence_rules: failure_delta = %d" % failure_delta)

	print("PLAYTEST - %d anni pescati, semi da %d" % [runs, first_seed])
	var mixed: Dictionary = await _play(data, plan, first_seed, true)
	var same: Dictionary = await _play(data, plan, first_seed, false)

	_report("TAVOLO MISTO - quattro caratteri diversi", mixed, data)
	_report("TAVOLO UNIFORME - quattro ottimizzatori", same, data)
	_verdict(mixed, same)
	# E per i seggi che restano bloccati anche a tavolo misto, l'incrocio che dice
	# se e il contenuto o il giocatore.
	print("")
	print("== I SEGGI CHE NON SI SBLOCCANO ==")
	for entity_id in _stuck(mixed):
		_cross(mixed, str(entity_id), data)
	quit(0)


func _stuck(run: Dictionary) -> Array:
	var seat_ids: Array = []
	for key in run["levels"]:
		var entity_id: String = str(key).split("/")[0]
		if not seat_ids.has(entity_id):
			seat_ids.append(entity_id)
	seat_ids.sort()
	var out: Array = []
	for entity_id in seat_ids:
		var total: int = 0
		var best: int = 0
		for level in LEVELS:
			var value: int = int(run["levels"].get("%s/%s" % [entity_id, level], 0))
			total += value
			best = maxi(best, value)
		if total > 0 and float(best) / float(total) >= 0.9:
			out.append(entity_id)
	return out


func _play(data: RefCounted, plan: Array, first_seed: int, mixed: bool) -> Dictionary:
	var out: Dictionary = {
		"levels": {}, "councils": [], "outcomes": {}, "truths": {}, "truth_count": 0,
		"by_character": {}, "seat_by_character": {}, "illegal": 0,
	}
	for index in range(plan.size()):
		var chronicle_id: String = str(plan[index])
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		session.setup(chronicle_id, seats, seed_value)

		# Chi siede dove lo decide un RNG a parte, non quello della partita: il
		# mondo dev'essere lo stesso nelle due meta, altrimenti si sta misurando
		# il seme e non il tavolo.
		var table: RefCounted = null
		var decider: RefCounted = null
		if mixed:
			table = Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
			decider = table
		else:
			decider = PolicyDecider.new(session.log)

		var report: Dictionary = await session.run(decider)
		out["councils"].append((report["confluences"] as Array).size())
		out["illegal"] = int(out["illegal"]) + int(session.chronicle.illegal_actions)
		for result in report["confluences"]:
			var band: String = str(result["outcome"])
			out["outcomes"][band] = int(out["outcomes"].get(band, 0)) + 1
		for entity_id in seats:
			var level: String = str(report["destiny_results"][str(entity_id)]["level"])
			var key: String = "%s/%s" % [str(entity_id), level]
			out["levels"][key] = int(out["levels"].get(key, 0)) + 1
			if table != null:
				var character: String = str(table.names[str(entity_id)])
				var by: String = "%s/%s" % [character, level]
				out["by_character"][by] = int(out["by_character"].get(by, 0)) + 1
				var cross: String = "%s/%s/%s" % [str(entity_id), character, level]
				out["seat_by_character"][cross] = int(out["seat_by_character"].get(cross, 0)) + 1
		for entry in session.world["truth_log"]:
			out["truth_count"] = int(out["truth_count"]) + 1
			out["truths"][str(entry["text"])] = true
		session.dispose()
	return out


func _report(title: String, run: Dictionary, data: RefCounted) -> void:
	var councils: Array = (run["councils"] as Array).duplicate()
	councils.sort()
	var total: int = 0
	for value in councils:
		total += int(value)

	print("")
	print("== %s ==" % title)
	print("  Consigli   media %.2f   mediana %d   da %d a %d" % [
		float(total) / float(maxi(1, councils.size())),
		int(councils[councils.size() / 2]), int(councils[0]),
		int(councils[councils.size() - 1]),
	])
	var bands: Array = ["FAILURE", "SUCCESS_WITH_COST", "SUCCESS", "DECISIVE_SUCCESS"]
	var line: Array = []
	for band in bands:
		line.append("%s %d" % [str(band).substr(0, 4), int(run["outcomes"].get(band, 0))])
	print("  Esiti      %s" % "  ".join(PackedStringArray(line)))
	print("  Verita     %d scritte, %d diverse" % [
		int(run["truth_count"]), (run["truths"] as Dictionary).size()
	])
	if int(run["illegal"]) > 0:
		print("  Azioni rifiutate: %d" % int(run["illegal"]))

	print("")
	print("  %-22s %s" % ["seggio", "NONE / MINIMUM / VICTORY / TRIUMPH"])
	var seat_ids: Array = []
	for key in run["levels"]:
		var entity_id: String = str(key).split("/")[0]
		if not seat_ids.has(entity_id):
			seat_ids.append(entity_id)
	seat_ids.sort()
	for entity_id in seat_ids:
		var counts: Array = []
		for level in LEVELS:
			counts.append(int(run["levels"].get("%s/%s" % [entity_id, level], 0)))
		print("  %-22s %3d %3d %3d %3d   %s" % [
			str(data.entities[str(entity_id)]["name"]),
			counts[0], counts[1], counts[2], counts[3], _bar(counts),
		])

	if not (run["by_character"] as Dictionary).is_empty():
		print("")
		print("  %-22s %s" % ["carattere", "NONE / MINIMUM / VICTORY / TRIUMPH"])
		for character in Characters.NAMES:
			var counts: Array = []
			for level in LEVELS:
				counts.append(int(run["by_character"].get("%s/%s" % [character, level], 0)))
			print("  %-22s %3d %3d %3d %3d   %s" % [
				str(character), counts[0], counts[1], counts[2], counts[3], _bar(counts),
			])


func _bar(counts: Array) -> String:
	var marks: Array = [".", "-", "+", "#"]
	var out: String = ""
	for i in range(counts.size()):
		out += str(marks[i]).repeat(int(counts[i]) / 2)
	return out


## La domanda a cui l'esperimento risponde, in due righe.
##
## "Bloccato" vuol dire: quel seggio finisce sullo stesso livello in almeno il
## 90% delle partite. E' la forma che la D-051 ha visto quattro volte di fila e
## non e riuscita a togliere ritoccando le clausole.
func _verdict(mixed: Dictionary, same: Dictionary) -> void:
	print("")
	print("== LA DOMANDA ==")
	for label in ["uniforme", "misto"]:
		var run: Dictionary = same if label == "uniforme" else mixed
		var stuck: int = 0
		var seats: int = 0
		var seat_ids: Array = []
		for key in run["levels"]:
			var entity_id: String = str(key).split("/")[0]
			if not seat_ids.has(entity_id):
				seat_ids.append(entity_id)
		for entity_id in seat_ids:
			var counts: Array = []
			var total: int = 0
			for level in LEVELS:
				var value: int = int(run["levels"].get("%s/%s" % [entity_id, level], 0))
				counts.append(value)
				total += value
			seats += 1
			for value in counts:
				if total > 0 and float(value) / float(total) >= 0.9:
					stuck += 1
					break
		print("  tavolo %-10s seggi bloccati su un solo livello: %d su %d" % [
			label, stuck, seats
		])


## Per un seggio che finisce sempre allo stesso livello, la domanda decisiva:
## ci finisce anche quando lo gioca chi gioca meglio? Se si, non e il giocatore.
func _cross(run: Dictionary, entity_id: String, data: RefCounted) -> void:
	print("")
	print("  %s, per carattere:" % str(data.entities[entity_id]["name"]))
	for character in Characters.NAMES:
		var counts: Array = []
		for level in LEVELS:
			counts.append(int(run["seat_by_character"].get(
				"%s/%s/%s" % [entity_id, character, level], 0
			)))
		print("    %-12s %2d %2d %2d %2d" % [
			str(character), counts[0], counts[1], counts[2], counts[3]
		])


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		text = text.substr(2)
		var split: int = text.find("=")
		if split < 0:
			options[text] = true
		else:
			options[text.substr(0, split)] = text.substr(split + 1)
	return options
