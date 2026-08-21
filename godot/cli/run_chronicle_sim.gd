extends SceneTree
## Headless Chronicle harness (§18.1).
##
##   godot --headless --path godot --script res://cli/run_chronicle_sim.gd -- \
##       --plan=res://data/chronicle_01/sim_plans/plan_a.json \
##       --out=out/plan_a.save.json
##
## Reads a sim plan, plays the whole Chronicle, prints a readable log and writes
## the final save. Exit code 0 means the run finished with every scripted choice
## legal and every `expected` assertion satisfied.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SaveSerializer := preload("res://scripts/core/save_serializer.gd")
const ScriptedDecider := preload("res://cli/scripted_decider.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const EXIT_OK: int = 0
const EXIT_USAGE: int = 2
const EXIT_DATA: int = 3
const EXIT_PLAN: int = 4
const EXIT_ASSERT: int = 5


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	if options.has("help") or not options.has("plan"):
		_usage()
		quit(EXIT_USAGE if not options.has("help") else EXIT_OK)
		return

	var data: RefCounted = DataSet.new()
	if not data.load_from(str(options.get("data", "res://data"))):
		printerr("Validazione dati fallita:")
		for error in data.errors:
			printerr("  %s" % error)
		quit(EXIT_DATA)
		return

	var plan: Dictionary = _load_plan(str(options["plan"]))
	if plan.is_empty():
		quit(EXIT_PLAN)
		return

	GameSession.apply_plan_overrides(data, plan)
	var session: RefCounted = GameSession.new(data)
	var seed_value: int = int(options.get("seed", plan["seed"]))
	if not session.setup(str(plan["chronicle_id"]), plan["seats"], seed_value):
		printerr("Setup fallito: %s" % session.last_error)
		quit(EXIT_PLAN)
		return

	if not bool(options.get("quiet", false)):
		session.log.echo_to_stdout = true
	print("ECHOES - sim '%s' (%s), seed %d" % [str(plan["id"]), str(plan["title"]), seed_value])

	# --policy replaces the plan's scripted choices with players that actually
	# pursue their own Destiny. The plan still supplies the Chronicle and the
	# seed; everything else is decided at the table.
	var decider: RefCounted = null
	if bool(options.get("policy", false)):
		decider = PolicyDecider.new(session.log)
		print("Giocatori: policy (ognuno persegue il proprio Destiny)")
	else:
		decider = ScriptedDecider.new(plan, session.log)
	var report: Dictionary = await session.run(decider)
	session.sync_rng_state()

	var failures: PackedStringArray = PackedStringArray()
	if not bool(options.get("policy", false)):
		failures = _check_expectations(plan, report, session)
	_print_summary(plan, report, session, failures)

	if options.has("out"):
		var out_path: String = _resolve_path(str(options["out"]))
		if SaveSerializer.write(session.to_save(str(plan["id"])), out_path):
			print("Save finale: %s" % out_path)
	if options.has("log"):
		_write_text(_resolve_path(str(options["log"])), session.log.text())

	var exit_code: int = EXIT_OK
	if int(report["illegal_actions"]) > 0 and not bool(options.get("lenient", false)):
		printerr("%d scelte scriptate illegali: il piano non e coerente." % int(report["illegal_actions"]))
		exit_code = EXIT_PLAN
	elif not failures.is_empty():
		exit_code = EXIT_ASSERT
	session.dispose()
	quit(exit_code)


func _usage() -> void:
	print(
		"""ECHOES - run_chronicle_sim

  --plan=<res:// or path>   sim plan to play (required)
  --out=<path>              write the final save here
  --log=<path>              write the public log here
  --data=<res://data>       data root
  --policy                  ignore the plan's choices; let the Destiny-driven
                            players decide instead (a livelier game than a
                            scripted regression fixture)
  --seed=<int>              override the plan's seed
  --quiet                   do not echo the log to stdout
  --lenient                 do not fail on illegal scripted choices
  --help"""
	)


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


func _load_plan(path: String) -> Dictionary:
	var resolved: String = _resolve_path(path)
	if not FileAccess.file_exists(resolved):
		printerr("Piano non trovato: %s" % resolved)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(resolved))
	if typeof(parsed) != TYPE_DICTIONARY:
		printerr("Piano illeggibile: %s" % resolved)
		return {}
	var document: Dictionary = parsed
	if str(document.get("schema_id", "")) != "sim_plan" or (document.get("items", []) as Array).is_empty():
		printerr("'%s' non e un documento sim_plan" % resolved)
		return {}
	return document["items"][0]


## `expected` in the plan is what makes the three sample runs a regression test
## and not just three logs (§18.3).
func _check_expectations(plan: Dictionary, report: Dictionary, session: RefCounted) -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var expected: Dictionary = plan.get("expected", {})
	if expected.is_empty():
		return failures

	if expected.has("confluence_count"):
		var actual: int = int(session.world["confluence_count"])
		if actual != int(expected["confluence_count"]):
			failures.append(
				"Confluence attese %d, ottenute %d" % [int(expected["confluence_count"]), actual]
			)
	if expected.has("outcomes"):
		var outcomes: Array = []
		for result in report["confluences"]:
			outcomes.append(str(result["outcome"]))
		if outcomes != Array(expected["outcomes"]):
			failures.append("Esiti attesi %s, ottenuti %s" % [expected["outcomes"], outcomes])
	if expected.has("min_echoes") and int(report["echoes"]) < int(expected["min_echoes"]):
		failures.append("Echo attesi >= %d, ottenuti %d" % [int(expected["min_echoes"]), int(report["echoes"])])
	if expected.has("min_truths") and int(report["truths"]) < int(expected["min_truths"]):
		failures.append("Truth attesi >= %d, ottenuti %d" % [int(expected["min_truths"]), int(report["truths"])])
	return failures


func _print_summary(
	plan: Dictionary, report: Dictionary, session: RefCounted, failures: PackedStringArray
) -> void:
	print("")
	print("== RIEPILOGO %s ==" % str(plan["id"]))
	print("  Confluence: %d" % int(session.world["confluence_count"]))
	for result in report["confluences"]:
		print(
			"    %s  %s  S%d O%d W%+d M%d%s"
			% [
				str(result["confluence_id"]),
				str(result["outcome"]),
				int(result["support_total"]),
				int(result["oppose_total"]),
				int(result["world_factor"]),
				int(result["margin"]),
				"  (Echo)" if bool(result["echo_created"]) else "",
			]
		)
	print("  Echo: %d   Truth: %d" % [int(report["echoes"]), int(report["truths"])])
	for entity_id in session.world["turn_order"]:
		var result: Variant = report["destiny_results"].get(str(entity_id))
		if result != null:
			print("    %s" % session.destinies.describe(result))
	print("  Effect applicati: %d" % (session.world["effect_log"] as Array).size())
	print("  RNG: seed %d, estrazioni %d" % [int(session.world["rng_seed"]), int(session.world["rng_state"])])
	if int(report["illegal_actions"]) > 0:
		print("  Scelte illegali: %d" % int(report["illegal_actions"]))
	for failure in failures:
		printerr("  ASSERZIONE FALLITA: %s" % failure)


func _resolve_path(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://") or path.begins_with("/"):
		return path
	return ProjectSettings.globalize_path("res://").path_join("..").path_join(path).simplify_path()


func _write_text(path: String, text: String) -> void:
	var directory: String = path.get_base_dir()
	if directory != "" and not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("Impossibile scrivere '%s'" % path)
		return
	file.store_string(text)
	file.close()
	print("Log: %s" % path)
