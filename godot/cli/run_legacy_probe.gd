extends SceneTree
## Cosa resta scritto alla fine di un anno, e quanta varieta' c'e' (issue #25, Fase 1).
##
##   godot --headless --path godot --script res://cli/run_legacy_probe.gd -- \
##       --runs=100 --seed=7000
##
## La Chronicle II va generata dalle conseguenze della I. Prima di scrivere il
## generatore, questa sonda misura la sua materia prima: **i fatti globali, le
## cicatrici, il controllo, i rapporti e i livelli con cui un anno si chiude**,
## e - il numero che decide tutto - quanti *mondi diversi* producono cento semi.
## Se gli input sono piatti, il generatore produrra' anni fotocopia, ed e' il
## difetto da conoscere prima di costruirci sopra, non dopo.
##
## Stessi semi e stesso tavolo misto di run_playtest, cosi' i numeri si
## confrontano riga per riga.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


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

	print("SONDA DELLA SUCCESSIONE - %d partite, tavolo misto, semi da %d" % [runs, first_seed])

	# Tutto per saga: un generatore che funziona per una sola non funziona.
	var per_saga: Dictionary = {}

	for index in range(runs):
		var chronicle_id: String = "CHR_00"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		session.setup(chronicle_id, seats, seed_value)
		var table: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		var report: Dictionary = await session.run(table)

		var saga: Dictionary = per_saga.get(chronicle_id, {
			"runs": 0, "tags": {}, "scar_tags": {}, "scar_count": 0,
			"control": {}, "relations": {}, "levels": {},
			"worlds": {}, "truths": 0,
		})
		saga["runs"] = int(saga["runs"]) + 1
		saga["truths"] = int(saga["truths"]) + (session.world["truth_log"] as Array).size()

		# I fatti globali: quello che una Chronicle II potrebbe leggere per
		# decidere le proprie domande.
		var tags: Array = (session.world["global_tags"] as Array).duplicate()
		tags = tags.filter(func(tag: Variant) -> bool: return not str(tag).begins_with("function:"))
		tags.sort()
		for tag in tags:
			saga["tags"][str(tag)] = int((saga["tags"] as Dictionary).get(str(tag), 0)) + 1

		for scar in session.world["scars"]:
			saga["scar_count"] = int(saga["scar_count"]) + 1
			var scar_tag: String = str(scar["tag"])
			saga["scar_tags"][scar_tag] = int((saga["scar_tags"] as Dictionary).get(scar_tag, 0)) + 1

		var control_print: Array = []
		for region_id in session.world["regions"]:
			var holder: Variant = session.world["regions"][region_id].get("control", null)
			if holder != null:
				var key: String = "%s -> %s" % [str(region_id), str(holder)]
				saga["control"][key] = int((saga["control"] as Dictionary).get(key, 0)) + 1
				control_print.append(key)

		for pair in session.world["relations"]:
			var relation: Dictionary = session.world["relations"][pair]
			if str(relation["level"]) == "NEUTRAL" and (relation["tags"] as Array).is_empty():
				continue
			var state: String = "%s %s%s" % [
				str(pair), str(relation["level"]),
				"" if (relation["tags"] as Array).is_empty() else " +" + ",".join(PackedStringArray(relation["tags"])),
			]
			saga["relations"][state] = int((saga["relations"] as Dictionary).get(state, 0)) + 1

		for entity_id in seats:
			var level: String = str(report["destiny_results"][str(entity_id)]["level"])
			var key: String = "%s/%s" % [str(entity_id), level]
			saga["levels"][key] = int((saga["levels"] as Dictionary).get(key, 0)) + 1

		# L'impronta del mondo: fatti globali + controllo + cicatrici. Due semi
		# con la stessa impronta consegnano al generatore lo stesso anno.
		control_print.sort()
		var scar_print: Array = []
		for scar in session.world["scars"]:
			scar_print.append(str(scar["tag"]))
		scar_print.sort()
		var fingerprint: String = "|".join(PackedStringArray(
			tags + control_print + scar_print
		))
		saga["worlds"][fingerprint] = int((saga["worlds"] as Dictionary).get(fingerprint, 0)) + 1

		per_saga[chronicle_id] = saga
		session.dispose()

	for chronicle_id in ["CHR_00"]:
		if per_saga.has(chronicle_id):
			_report(chronicle_id, per_saga[chronicle_id])
	quit(0)


func _report(chronicle_id: String, saga: Dictionary) -> void:
	var runs: int = int(saga["runs"])
	print("")
	print("== %s - %d anni conclusi ==" % [chronicle_id, runs])
	print("  Mondi distinti (fatti+controllo+cicatrici): %d su %d" % [
		(saga["worlds"] as Dictionary).size(), runs
	])
	print("  Cicatrici totali: %d   Verita' scritte: %d" % [
		int(saga["scar_count"]), int(saga["truths"])
	])

	print("")
	print("  I fatti globali con cui l'anno si chiude (su %d):" % runs)
	_sorted_counts(saga["tags"], runs)

	print("")
	print("  Le cicatrici sulla mappa (sopra il 100%% = piu' d'una per anno):")
	_sorted_counts(saga["scar_tags"], runs)

	print("")
	print("  Il controllo a fine anno:")
	_sorted_counts(saga["control"], runs)

	print("")
	print("  I rapporti non neutri a fine anno:")
	_sorted_counts(saga["relations"], runs)

	print("")
	print("  I livelli, seggio per seggio:")
	_sorted_counts(saga["levels"], runs)


func _sorted_counts(counts: Dictionary, runs: int) -> void:
	var keys: Array = counts.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool:
		if int(counts[a]) == int(counts[b]):
			return str(a) < str(b)
		return int(counts[a]) > int(counts[b])
	)
	for key in keys:
		print("    %-52s %4d  (%d%%)" % [
			str(key), int(counts[key]), int(counts[key]) * 100 / maxi(runs, 1)
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
