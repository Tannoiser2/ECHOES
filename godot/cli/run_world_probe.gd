extends SceneTree
## World probe: how far can the world actually move?
##
##   godot --headless --path godot --script res://cli/run_world_probe.gd -- \
##       --runs=40 --seed=3000 --campaign=10
##
## Two measurements, because they answer two different questions.
##
## `--runs` plays N independent Chronicles from the same starting world and
## counts how many *distinct* end states come out. That is the ceiling on
## variety inside one Chronicle: if 40 games end in 3 configurations, no amount
## of authored text will make them feel different.
##
## `--campaign` plays K Chronicles in sequence, each inheriting the last, and
## reports how far the world has travelled from where it started. That is the
## ceiling on a campaign - and the only honest answer to "after ten Chronicles,
## what has changed?".
##
## Deterministic: same flags, same table.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://cli/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 3000))
	var campaign: int = int(options.get("campaign", 10))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	if runs > 0:
		_single_chronicle_ceiling(data, runs, first_seed, chronicle_id)
	if campaign > 0:
		_campaign(data, campaign, first_seed, chronicle_id)
	quit(0)


# --- one Chronicle, many times ---------------------------------------------

func _single_chronicle_ceiling(data: RefCounted, runs: int, first_seed: int, chronicle_id: String) -> void:
	var control_maps: Dictionary = {}
	var tag_sets: Dictionary = {}
	var relation_maps: Dictionary = {}
	var full_states: Dictionary = {}
	var tags_seen: Dictionary = {}
	var scars: int = 0

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, SEATS, first_seed + i)
		session.run(PolicyDecider.new(session.log))
		var world: Dictionary = session.world

		var control: String = _control_signature(world)
		var tags: String = _tag_signature(world, tags_seen)
		var relations: String = _relation_signature(world)
		control_maps[control] = int(control_maps.get(control, 0)) + 1
		tag_sets[tags] = int(tag_sets.get(tags, 0)) + 1
		relation_maps[relations] = int(relation_maps.get(relations, 0)) + 1
		var full: String = "%s|%s|%s" % [control, tags, relations]
		full_states[full] = int(full_states.get(full, 0)) + 1
		scars += (world["scars"] as Array).size()
		session.dispose()

	print("")
	print("== QUANTO PUO MUOVERSI IL MONDO - %d Chronicle indipendenti (%s) ==" % [runs, chronicle_id])
	print("")
	print("Configurazioni finali distinte, su %d partite" % runs)
	print("  controllo delle Regioni   %d" % control_maps.size())
	print("  tag sulle Regioni         %d" % tag_sets.size())
	print("  relazioni fra Entita      %d" % relation_maps.size())
	print("  stato completo            %d" % full_states.size())
	print("  Scar lasciate             %.2f per Chronicle" % (float(scars) / float(maxi(1, runs))))
	print("")
	print("Tag di Regione mai visti in %d partite: quelli che il contenuto promette" % runs)
	print("  e non consegna, elencati sotto come 'MAI'.")
	_tag_coverage(data, tags_seen)


func _tag_coverage(data: RefCounted, seen: Dictionary) -> void:
	var declared: Dictionary = {}
	for consequence in data.consequences.values():
		for effect in consequence["effects"]:
			if str(effect["type"]) != "SET_REGION_TAG":
				continue
			var tag: String = str(effect.get("payload", {}).get("tag", ""))
			if tag != "":
				declared[tag] = str(consequence["id"])
	var keys: Array = declared.keys()
	keys.sort()
	for tag in keys:
		var count: int = int(seen.get(str(tag), 0))
		print("  %-28s %s   (%s)" % [str(tag), ("%dx" % count) if count > 0 else "MAI", str(declared[tag])])


# --- ten Chronicles in a row ------------------------------------------------

func _campaign(data: RefCounted, chronicles: int, first_seed: int, chronicle_id: String) -> void:
	print("")
	print("== CAMPAGNA - %d Chronicle di seguito (%s), ognuna eredita la precedente ==" % [chronicles, chronicle_id])
	print("")

	var previous: Dictionary = {}
	var start_control: String = ""
	var start_tags: Array = []
	var truths: int = 0
	var sentences: Dictionary = {}
	var focus_regions: Dictionary = {}
	var rows: Array = []

	for index in range(chronicles):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, SEATS, first_seed + index * 97)
		session.inherit_from(previous)
		session.confluence.step_changed.connect(
			func(step: String, context: Dictionary) -> void:
				if step != "QUESTION":
					return
				var tension_id: String = str(context["tension_id"])
				var region_id: String = session.confluence.narrative.focus_region(tension_id)
				var key: String = "%s / %s" % [
					str(data.tensions[tension_id]["title"]), str(data.regions[region_id]["name"])
				]
				focus_regions[key] = int(focus_regions.get(key, 0)) + 1
		)
		var report: Dictionary = session.run(PolicyDecider.new(session.log))
		var world: Dictionary = session.world

		if index == 0:
			start_control = _control_signature(world)
			start_tags = _region_tags(world)
		for truth in world["truth_log"]:
			sentences[str(truth["text"]).split(": ", true, 1)[-1]] = true

		var drawn: Array = (world["tensions"] as Dictionary).keys()
		drawn.sort()
		var short: Array = []
		for tension_id in drawn:
			short.append(str(tension_id).replace("TEN_", "").substr(0, 4))
		rows.append({
			"drawn": " ".join(PackedStringArray(short)),
			"year": int(world["year"]),
			"control": _control_pretty(world, data),
			"new_tags": _region_tags(world).size(),
			"scars": (world["scars"] as Array).size(),
			"truths": (world["truth_log"] as Array).size(),
			"confluences": int(world["confluence_count"]),
		})
		truths = (world["truth_log"] as Array).size()
		previous = world.duplicate(true)
		session.dispose()

	print("%-4s %-6s %-24s %-26s %-5s %-5s %s"
		% ["#", "anno", "Tensioni pescate", "controllo", "tag", "Scar", "Truth"])
	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		print("%-4d %-6d %-24s %-26s %-5d %-5d %d" % [
			i + 1, int(row["year"]), str(row["drawn"]), str(row["control"]),
			int(row["new_tags"]), int(row["scars"]), int(row["truths"]),
		])

	print("")
	print("Dopo %d Chronicle" % chronicles)
	print("  Truth accumulate           %d" % truths)
	print("  frasi distinte lette       %d" % sentences.size())
	print("  il controllo e cambiato    %s" % ("si" if _control_signature(previous) != start_control else "NO"))
	print("  tag sulla mappa            %d -> %d" % [start_tags.size(), _region_tags(previous).size()])

	print("")
	print("Regione a fuoco lungo la campagna")
	var keys: Array = focus_regions.keys()
	keys.sort()
	for key in keys:
		print("  %-44s %dx" % [str(key), int(focus_regions[key])])


# --- signatures -------------------------------------------------------------

func _control_signature(world: Dictionary) -> String:
	var keys: Array = (world["regions"] as Dictionary).keys()
	keys.sort()
	var parts: Array = []
	for region_id in keys:
		var control: Variant = world["regions"][region_id].get("control", null)
		parts.append("%s=%s" % [str(region_id), "-" if control == null else str(control)])
	return ",".join(PackedStringArray(parts))


func _control_pretty(world: Dictionary, data: RefCounted) -> String:
	var keys: Array = (world["regions"] as Dictionary).keys()
	keys.sort()
	var parts: Array = []
	for region_id in keys:
		var control: Variant = world["regions"][region_id].get("control", null)
		parts.append("-" if control == null else str(data.entities[str(control)]["name"]).substr(0, 3))
	return " ".join(PackedStringArray(parts))


## Only the tags a Chronicle can write; the authored ones are scenery.
func _region_tags(world: Dictionary) -> Array:
	var out: Array = []
	for region_id in world["regions"]:
		for tag in world["regions"][region_id]["tags"]:
			for prefix in ["condition:", "structure:", "settlement:", "scar:"]:
				if str(tag).begins_with(prefix):
					out.append("%s/%s" % [str(region_id), str(tag)])
					break
	out.sort()
	return out


func _tag_signature(world: Dictionary, seen: Dictionary) -> String:
	var tags: Array = _region_tags(world)
	for entry in tags:
		var tag: String = str(entry).split("/")[1]
		seen[tag] = int(seen.get(tag, 0)) + 1
	return ",".join(PackedStringArray(tags))


func _relation_signature(world: Dictionary) -> String:
	var keys: Array = (world["relations"] as Dictionary).keys()
	keys.sort()
	var parts: Array = []
	for key in keys:
		parts.append("%s=%s" % [str(key), str(world["relations"][key]["level"])])
	return ",".join(PackedStringArray(parts))


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
