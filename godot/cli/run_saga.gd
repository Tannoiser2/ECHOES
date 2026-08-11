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
const PolicyDecider := preload("res://cli/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var chronicles: int = int(options.get("chronicles", 10))
	var first_seed: int = int(options.get("seed", 812))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var out_dir: String = str(options.get("out", ""))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var previous: Dictionary = {}
	var saga: Array = []

	for index in range(chronicles):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, SEATS, first_seed + index * 97)
		session.inherit_from(previous)

		# What the world played at each Act end, in order.
		var cards: Array = []
		var before_cards: int = 0
		session.chronicle.phase_changed.connect(
			func(_act: int, _round: int, phase: String) -> void:
				if phase != "ACT_ECHO":
					return
				before_cards = (session.world["echo_deck"]["drawn"] as Array).size()
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

		var report: Dictionary = session.run(PolicyDecider.new(session.log))
		var world: Dictionary = session.world

		for card_id in world["echo_deck"]["drawn"]:
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
				"proponent": str(data.entities[str(result["proponent"])]["name"]),
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
				"to": "nessuno" if now == null else str(data.entities[str(now)]["name"]),
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
				"name": str(data.entities[str(entity_id)]["name"]),
				"level": str(entry["level"]),
				"text": str(entry.get("label", "")),
			})

		saga.append({
			"chronicle": index + 1,
			"year": int(world["year"]),
			"tensions": tensions,
			"confluences": confluences,
			"cards": cards,
			"control_changes": changed,
			"truths": new_truths,
			"scars": new_scars,
			"destinies": destinies,
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
				data.entities[str(region["control"])]["name"]
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

		var questions: Array = []
		for tension in year["tensions"]:
			questions.append("%s (%d/%d)" % [
				str(tension["title"]), int(tension["final"]), int(tension["threshold"])
			])
		print("Le domande dell'anno: %s" % ", ".join(PackedStringArray(questions)))

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
