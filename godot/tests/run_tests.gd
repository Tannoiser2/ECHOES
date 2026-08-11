extends SceneTree
## Test runner (§18.3, docs/TEST_PLAN.md).
##
##   godot --headless --path godot --script res://tests/run_tests.gd
##   godot --headless --path godot --script res://tests/run_tests.gd -- --filter=effect
##
## Discovers every res://tests/**/test_*.gd, runs each `test_*` method, and
## exits non-zero on the first suite with a failure.

const TEST_ROOTS: Array = ["res://tests/unit", "res://tests/smoke"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var filter: String = str(options.get("filter", ""))

	var paths: Array = []
	for root in TEST_ROOTS:
		paths.append_array(_collect(str(root)))
	paths.sort()

	var total: int = 0
	var assertions: int = 0
	var failures: PackedStringArray = PackedStringArray()
	var suites: int = 0

	for path in paths:
		if filter != "" and not str(path).contains(filter):
			continue
		suites += 1
		var name: String = str(path).get_file().trim_suffix(".gd")
		var script: Variant = load(str(path))
		# A suite that fails to parse must be reported as a failure, not left to
		# take the runner down with it: an uncaught error inside _initialize
		# never reaches quit(), and the process hangs forever.
		if script == null or not (script is GDScript) or not (script as GDScript).can_instantiate():
			print("FAIL  %-34s errore di compilazione" % name)
			failures.append("%s: lo script non compila (vedi gli errori sopra)" % path)
			continue
		var probe: Variant = (script as GDScript).new()
		if probe == null:
			print("FAIL  %-34s non istanziabile" % name)
			failures.append("%s: lo script non si istanzia" % path)
			continue

		var suite_failures: int = 0
		var suite_tests: int = 0

		for method in (probe as Object).get_method_list():
			if not str(method["name"]).begins_with("test_"):
				continue
			# A fresh instance per test: no state leaks between cases.
			var instance: RefCounted = script.new()
			instance.set_current_test("%s.%s" % [name, str(method["name"])])
			instance.before_each()
			instance.call(str(method["name"]))
			instance.after_each()
			suite_tests += 1
			total += 1
			assertions += int(instance.assertions)
			suite_failures += instance.failures.size()
			failures.append_array(instance.failures)

		print(
			"%s  %-34s %2d test%s"
			% ["FAIL" if suite_failures > 0 else "ok  ", name, suite_tests, "" if suite_tests == 1 else ""]
		)

	print("")
	if failures.is_empty():
		print("%d test in %d suite, %d asserzioni: tutto verde." % [total, suites, assertions])
		quit(0)
		return
	print("FALLIMENTI (%d):" % failures.size())
	for failure in failures:
		printerr("  %s" % failure)
	print("")
	print("%d test in %d suite, %d asserzioni, %d fallimenti." % [total, suites, assertions, failures.size()])
	quit(1)


func _collect(root: String) -> Array:
	var found: Array = []
	var dir := DirAccess.open(root)
	if dir == null:
		return found
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if not name.begins_with("."):
			var path: String = root.path_join(name)
			if dir.current_is_dir():
				found.append_array(_collect(path))
			elif name.begins_with("test_") and name.ends_with(".gd"):
				found.append(path)
		name = dir.get_next()
	dir.list_dir_end()
	return found


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
