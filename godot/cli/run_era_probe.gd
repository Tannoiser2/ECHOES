extends SceneTree
## La sonda delle ere: cosa fa il tempo a una saga, misurato (issue #25).
##
##   godot --headless --path godot --script res://cli/run_era_probe.gd -- \
##       --sagas=20 --chronicles=10 --seed=812 --then=CHR_02
##
## Una saga non e' una fila di primavere: fra un anno giocato e il prossimo
## possono passare venti anni o duecento (D-045), le persone diventano case,
## le case cambiano nome, e chi ha ottenuto il proprio Destino ne vuole un
## altro. run_saga racconta *una* saga; questa sonda ne gioca N e conta cosa
## il tempo fa davvero: quanti secoli copre una campagna, quante generazioni
## si siedono, quanti Destini ruotano, quante mani di domande diverse escono
## dalla biblioteca - e il numero che decide la prossima fase: **quanti fatti
## dell'anno uno arrivano all'ultimo anno, letterali e mai sbiaditi.** Un mondo
## che ricorda tutto per sempre non ha leggende: ha un archivio.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var sagas: int = int(options.get("sagas", 20))
	var chronicles: int = int(options.get("chronicles", 10))
	var first_seed: int = int(options.get("seed", 812))
	var first_id: String = str(options.get("chronicle", "CHR_01"))
	var later_id: String = str(options.get("then", "CHR_02"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var start_year: int = int(data.chronicles[first_id]["start_year"])
	print("SONDA DELLE ERE - %d saghe da %d Chronicle (%s poi %s), semi da %d" % [
		sagas, chronicles, first_id, later_id, first_seed
	])

	var spans: Array = []
	var jumps: Array = []
	var generations: int = 0
	var rotations: int = 0
	var names_seen: Dictionary = {}
	var hands: Dictionary = {}
	var survivors: Dictionary = {}
	var survivor_avg: Array = []
	var first_year_facts_avg: Array = []
	var truths_final: Array = []
	var legends_final: Array = []
	var facts_final: Array = []

	for saga_index in range(sagas):
		var seed_base: int = first_seed + saga_index * 1009
		var previous: Dictionary = {}
		var previous_results: Dictionary = {}
		var first_end_tags: Array = []
		var final_tags: Array = []
		var final_year: int = start_year

		for index in range(chronicles):
			var chronicle_id: String = first_id if index == 0 else later_id
			var session: RefCounted = GameSession.new(data)
			var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
			var seed_value: int = seed_base + index * 97
			session.setup(chronicle_id, seats, seed_value)
			session.inherit_from(previous, previous_results)
			if index > 0:
				jumps.append(session.years_passed())
				for entity_id in session.handover():
					var seat: Dictionary = session.handover()[entity_id]
					if bool(seat.get("changed", false)):
						generations += 1
						names_seen[str(seat["name"])] = true
					if bool(seat.get("wants_new", false)):
						rotations += 1
				var hand: Array = (session.world["tensions"] as Dictionary).keys()
				hand.sort()
				hands["|".join(PackedStringArray(hand))] = true

			var table: RefCounted = Characters.deal(
				seats, RngService.new(seed_value * 31 + 7), session.log
			)
			var report: Dictionary = await session.run(table)

			var tags: Array = (session.world["global_tags"] as Array).duplicate()
			tags = tags.filter(func(tag: Variant) -> bool: return not str(tag).begins_with("function:"))
			if index == 0:
				first_end_tags = tags.duplicate()
			final_tags = tags
			final_year = int(session.world["year"])
			if index == chronicles - 1:
				truths_final.append((session.world["truth_log"] as Array).size())
				legends_final.append(tags.filter(
					func(tag: Variant) -> bool: return str(tag).begins_with("legend:")
				).size())
				facts_final.append(tags.filter(
					func(tag: Variant) -> bool: return not str(tag).begins_with("legend:")
				).size())

			previous = session.world
			previous_results = report["destiny_results"]
			# Niente dispose: `previous` e' il mondo che il prossimo anno eredita.

		spans.append(final_year - start_year)
		var survived: int = 0
		for tag in final_tags:
			if first_end_tags.has(tag):
				survived += 1
				survivors[str(tag)] = int(survivors.get(str(tag), 0)) + 1
		survivor_avg.append(survived)
		first_year_facts_avg.append(first_end_tags.size())

	spans.sort()
	jumps.sort()
	print("")
	print("  Anni coperti da una saga di %d Chronicle: mediana %d, da %d a %d" % [
		chronicles, int(spans[spans.size() / 2]), int(spans[0]), int(spans[spans.size() - 1])
	])
	print("  Salto fra due anni giocati: mediana %d anni, da %d a %d" % [
		int(jumps[jumps.size() / 2]), int(jumps[0]), int(jumps[jumps.size() - 1])
	])
	print("  Generazioni nuove sedute al tavolo: %d (%.1f per saga), %d nomi distinti" % [
		generations, float(generations) / maxf(sagas, 1), names_seen.size()
	])
	print("  Destini cambiati perche' il precedente era ottenuto: %d (%.1f per saga)" % [
		rotations, float(rotations) / maxf(sagas, 1)
	])
	print("  Mani di domande diverse pescate dalla biblioteca: %d" % hands.size())
	print("  Verita' nel registro all'ultimo anno: %.0f in media" % _mean(truths_final))
	print("")
	print("  All'ultimo anno il mondo porta in media %.1f fatti correnti e %.1f leggende." % [
		_mean(facts_final), _mean(legends_final)
	])
	print("  Dei %.1f fatti globali con cui si chiude l'anno uno, %.1f arrivano" % [
		_mean(first_year_facts_avg), _mean(survivor_avg)
	])
	print("  LETTERALI all'ultimo anno, secoli dopo. I sopravvissuti piu' frequenti:")
	var keys: Array = survivors.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool:
		if int(survivors[a]) == int(survivors[b]):
			return str(a) < str(b)
		return int(survivors[a]) > int(survivors[b])
	)
	for key in keys.slice(0, 12):
		print("    %-36s %3d" % [str(key), int(survivors[key])])


	quit(0)


func _mean(values: Array) -> float:
	var total: float = 0.0
	for value in values:
		total += float(value)
	return total / maxf(values.size(), 1)


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
