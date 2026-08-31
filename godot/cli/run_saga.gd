extends SceneTree
## Play a whole saga - K Chronicles in sequence, each inheriting the last - and
## write down what happened, year by year.
##
##   godot --headless --path godot --script res://cli/run_saga.gd -- \
##       --chronicles=10 --seed=812 --out=out/saga
##
## The world probe counts; this one *narrates*. Per Chronicle it records the
## questions the year was about, every Confluence with its outcome and the Truth
## it left, the Echo card the world played at each Act end, what changed hands,
## and where the map was scarred. One log file per Chronicle plus a digest, so
## the record of a saga can be read rather than tallied.
##
## Deterministic: same seed, same saga, down to the sentences.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")



## Chi siede al tavolo lo pesca il seme (D-213). Una saga tiene **lo stesso
## tavolo** dal primo anno all'ultimo: sono le stesse case che invecchiano, e
## ripescarle a ogni Chronicle vorrebbe dire raccontare dieci storie diverse
## invece di una lunga.
func _seats(data: RefCounted, chronicle_id: String, seed_value: int) -> Array:
	return GameSession.seats_for(data, chronicle_id, seed_value)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var chronicles: int = int(options.get("chronicles", 10))
	var first_seed: int = int(options.get("seed", 812))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var out_dir: String = str(options.get("out", ""))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# The first year can be the written one; everything after it is library
	# content, which is where the centuries and the successors come from (D-045).
	var later_id: String = str(options.get("then", chronicle_id))
	var previous: Dictionary = {}
	var previous_results: Dictionary = {}
	var saga: Array = []
	var SEATS: Array = _seats(data, chronicle_id, first_seed)

	for index in range(chronicles):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id if index == 0 else later_id, SEATS, first_seed + index * 97)
		session.inherit_from(previous, previous_results)

		# What the world played at each Act end, in order.
		var cards: Array = []
		var before_cards: int = 0
		session.chronicle.phase_changed.connect(
			func(_act: int, _round: int, phase: String) -> void:
				if phase != "ACT_ECHO":
					return
				before_cards = (session.world["echo_played"] as Array).size()
		)

		# Captured on the first phase that is not SETUP, because inheritance is
		# applied *inside* run(): reading it here would compare this year against
		# the factory default and report a handover that never happened.
		var control_before: Dictionary = {}
		session.chronicle.phase_changed.connect(
			func(_a: int, _r: int, phase: String) -> void:
				if phase == "SETUP" or not control_before.is_empty():
					return
				for region_id in session.world["regions"]:
					control_before[str(region_id)] = session.world["regions"][str(region_id)].get("control", null)
		)
		# Inherited Scars are re-applied during setup, which happens inside run().
		# Counting before the run would report the whole map's history as this
		# year's damage - so they are identified, not counted.
		var scars_before: Dictionary = {}
		for scar in previous.get("scars", []):
			scars_before[str(scar["scar_id"])] = true
		var truths_before: int = (session.world["truth_log"] as Array).size()

		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		var world: Dictionary = session.world

		for card_id in world["echo_played"]:
			var card: Dictionary = data.echo_cards[str(card_id)]
			cards.append({
				"title": str(card["title"]),
				"family": str(card["dramatic_family"]),
				"function": str(card["function_id"]),
			})

		var confluences: Array = []
		for result in report["confluences"]:
			confluences.append({
				"tension": str(data.tensions[str(result["tension_id"])]["title"]),
				"outcome": str(result["outcome"]),
				"proponent": session.service.name_of(str(result["proponent"])),
				"support": int(result["support_total"]),
				"oppose": int(result["oppose_total"]),
				"margin": int(result["margin"]),
			})

		var changed: Array = []
		for region_id in world["regions"]:
			var now: Variant = world["regions"][str(region_id)].get("control", null)
			if str(now) == str(control_before.get(str(region_id))):
				continue
			changed.append({
				"region": str(data.regions[str(region_id)]["name"]),
				"from": "nessuno" if control_before.get(str(region_id)) == null else str(data.entities[str(control_before[str(region_id)])]["name"]),
				"to": "nessuno" if now == null else session.service.name_of(str(now)),
			})

		var new_truths: Array = []
		for i in range(truths_before, (world["truth_log"] as Array).size()):
			new_truths.append(str(world["truth_log"][i]["text"]))
		var new_scars: Array = []
		for scar in world["scars"]:
			if scars_before.has(str(scar["scar_id"])):
				continue
			new_scars.append({
				"region": str(data.regions[str(scar["region_id"])]["name"]),
				"text": str(scar["description"]),
			})

		var tensions: Array = []
		for tension_id in world["tensions"]:
			tensions.append({
				"title": str(data.tensions[str(tension_id)]["title"]),
				"final": session.tensions.value(str(tension_id)),
				"threshold": int(data.tensions[str(tension_id)]["threshold"]),
			})

		var destinies: Array = []
		for entity_id in SEATS:
			var entry: Dictionary = report["destiny_results"][str(entity_id)]
			destinies.append({
				"name": session.service.name_of(str(entity_id)),
				"level": str(entry["level"]),
				"text": str(entry.get("label", "")),
			})

		# Who sat down this year, and who they replaced.
		var seats: Array = []
		for entity_id in SEATS:
			var handover: Dictionary = (session.handover() as Dictionary).get(str(entity_id), {})
			seats.append({
				"name": session.service.name_of(str(entity_id)),
				"generation": session.service.generation_of(str(entity_id)),
				"changed": bool(handover.get("changed", false)),
				"wants_new": bool(handover.get("wants_new", false)),
				"note": str(handover.get("note", "")),
				"destiny": str(data.destinies[session.service.destiny_of(str(entity_id))]["title"]),
			})

		saga.append({
			"chronicle": index + 1,
			"year": int(world["year"]),
			"years_passed": session.years_passed(),
			"verbale": WorldStateFactory.opening_lines(world.get("opening_record", []), data),
			"verbale_mappa": WorldStateFactory.map_lines(world.get("map_record", {}), data, world),
			"seats": seats,
			"tensions": tensions,
			"confluences": confluences,
			"cards": cards,
			"control_changes": changed,
			"truths": new_truths,
			"scars": new_scars,
			"destinies": destinies,
			"standing": _standing(world),
			"played": int(world.get("chronicles_played", index + 1)),
			"decides_after": int(
				(data.chronicles[chronicle_id if index == 0 else later_id].get(
					"saga_scoring", {}
				) as Dictionary).get("decides_after", 10)
			),
			"map": _map_state(world, data),
		})

		if out_dir != "":
			var path: String = "%s/chronicle_%02d.log" % [out_dir, index + 1]
			DirAccess.make_dir_recursive_absolute(out_dir)
			var handle: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			if handle != null:
				handle.store_string("\n".join(PackedStringArray(session.log.lines)))
				handle.close()

		previous = world.duplicate(true)
		previous_results = (report["destiny_results"] as Dictionary).duplicate(true)
		session.dispose()

	_print_saga(saga)
	if out_dir != "":
		DirAccess.make_dir_recursive_absolute(out_dir)
		var handle: FileAccess = FileAccess.open("%s/saga.json" % out_dir, FileAccess.WRITE)
		if handle != null:
			handle.store_string(JSON.stringify(saga, "  "))
			handle.close()
			print("")
			print("Scritto: %s/saga.json e un log per Chronicle." % out_dir)
	quit(0)


## La classifica della campagna (D-180), se la Chronicle la tiene. Ordinata, e
## col nome corrente del seggio: in una saga lunga chi siede cambia, il conto no.
func _standing(world: Dictionary) -> Array:
	var rows: Array = []
	for entity_id in world["turn_order"]:
		var seat: Dictionary = (world["entities"] as Dictionary)[str(entity_id)] as Dictionary
		if not seat.has("saga_score"):
			continue
		rows.append([int(seat["saga_score"]), str(seat["name"])])
	rows.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
	return rows


func _map_state(world: Dictionary, data: RefCounted) -> Array:
	var out: Array = []
	var ids: Array = (world["regions"] as Dictionary).keys()
	ids.sort()
	for region_id in ids:
		var region: Dictionary = world["regions"][str(region_id)]
		var marks: Array = []
		for tag in region["tags"]:
			for prefix in ["condition:", "structure:", "settlement:", "scar:"]:
				if str(tag).begins_with(prefix):
					marks.append(str(tag))
					break
		marks.sort()
		out.append({
			"region": str(data.regions[str(region_id)]["name"]),
			"control": "nessuno" if region.get("control", null) == null else str(
				(world["entities"] as Dictionary).get(str(region["control"]), {}).get(
					"name", data.entities[str(region["control"])]["name"]
				)
			),
			"marks": marks,
		})
	return out


func _print_saga(saga: Array) -> void:
	for year in saga:
		print("")
		print("=========================================================")
		print("CHRONICLE %d - anno %d" % [int(year["chronicle"]), int(year["year"])])
		print("=========================================================")

		# Il salto, e chi lo ha attraversato. E la meta della storia che il
		# registro non racconta: il mondo resta, le persone no (D-045).
		var passed: int = int(year.get("years_passed", 0))
		if passed > 0:
			print("Sono passati %d anni." % passed)
		var changed: Array = []
		for seat in year.get("seats", []):
			if bool((seat as Dictionary).get("changed", false)):
				changed.append("%s (%s)" % [
					str((seat as Dictionary)["name"]), str((seat as Dictionary)["note"]),
				])
		if not changed.is_empty():
			print("Al tavolo adesso siedono: %s" % "; ".join(PackedStringArray(changed)))
		var wants: Array = []
		for seat in year.get("seats", []):
			wants.append("%s vuole %s%s" % [
				str((seat as Dictionary)["name"]), str((seat as Dictionary)["destiny"]),
				" (nuovo: aveva gia ottenuto il precedente)"
				if bool((seat as Dictionary).get("wants_new", false)) else "",
			])
		if passed > 0:
			print("Cosa vogliono: %s" % " · ".join(PackedStringArray(wants)))

		var questions: Array = []
		for tension in year["tensions"]:
			questions.append("%s (%d/%d)" % [
				str(tension["title"]), int(tension["final"]), int(tension["threshold"])
			])
		print("Le domande dell'anno: %s" % ", ".join(PackedStringArray(questions)))

		# Il verbale d'apertura (D-089): perche' queste domande e non altre.
		if not (year.get("verbale", []) as Array).is_empty():
			print("Perche' queste:")
			for line in year["verbale"]:
				print("  - %s" % str(line))

		# E la meta' della mappa (D-090): come si piazza l'era nuova.
		if not (year.get("verbale_mappa", []) as Array).is_empty():
			print("La mappa che si eredita:")
			for line in year["verbale_mappa"]:
				print("  - %s" % str(line))

		if not (year["confluences"] as Array).is_empty():
			print("")
			print("I consigli:")
			for confluence in year["confluences"]:
				print("  - %s, proposta da %s: %s (S%d O%d M%d)" % [
					str(confluence["tension"]), str(confluence["proponent"]),
					str(confluence["outcome"]), int(confluence["support"]),
					int(confluence["oppose"]), int(confluence["margin"]),
				])

		if not (year["cards"] as Array).is_empty():
			var played: Array = []
			for card in year["cards"]:
				played.append("%s [%s]" % [str(card["title"]), str(card["function"])])
			print("Il mondo gioca: %s" % " -> ".join(PackedStringArray(played)))

		if not (year["control_changes"] as Array).is_empty():
			print("")
			print("Cambia mano:")
			for change in year["control_changes"]:
				print("  - %s: da %s a %s" % [
					str(change["region"]), str(change["from"]), str(change["to"])
				])

		if not (year["scars"] as Array).is_empty():
			print("")
			print("Resta sulla mappa:")
			for scar in year["scars"]:
				print("  - %s: %s" % [str(scar["region"]), str(scar["text"])])

		if not (year["truths"] as Array).is_empty():
			print("")
			print("Nel registro:")
			for truth in year["truths"]:
				print("  - %s" % str(truth))

		print("")
		var levels: Array = []
		for destiny in year["destinies"]:
			levels.append("%s %s" % [str(destiny["name"]), str(destiny["level"])])
		print("Destini: %s" % " | ".join(PackedStringArray(levels)))
		if not (year["standing"] as Array).is_empty():
			var board: Array = []
			for row in year["standing"]:
				board.append("%s %d" % [str((row as Array)[1]), int((row as Array)[0])])
			var needed: int = int(year["decides_after"])
			var played: int = int(year["played"])
			var verdict: String = ""
			if needed > 0 and played < needed:
				verdict = "  (non ancora decisa: %d su %d)" % [played, needed]
			elif needed > 0:
				verdict = "  <- la campagna si decide"
			print("La saga:  %s%s" % [" | ".join(PackedStringArray(board)), verdict])

	print("")
	print("=========================================================")
	print("LA MAPPA ALLA FINE")
	print("=========================================================")
	for region in (saga[saga.size() - 1]["map"] as Array):
		print("  %-24s %-14s %s" % [
			str(region["region"]), str(region["control"]),
			", ".join(PackedStringArray(region["marks"])),
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
