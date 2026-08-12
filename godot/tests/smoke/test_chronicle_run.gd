extends "res://tests/test_case.gd"
## Smoke: a whole Chronicle, headless, from the shipped sim plans (§18.3).

const ScriptedDecider := preload("res://cli/scripted_decider.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SaveSerializer := preload("res://scripts/core/save_serializer.gd")
const EffectText := preload("res://scripts/core/effect_text.gd")
const EchoCardView := preload("res://ui/echo_card_view.gd")

const PLAN_DIR: String = "res://data/chronicle_01/sim_plans"


func _plan(file_name: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(PLAN_DIR.path_join(file_name))
	)
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("piano illeggibile: %s" % file_name)
		return {}
	return (parsed as Dictionary)["items"][0]


func _plan_files() -> Array:
	var files: Array = []
	var dir := DirAccess.open(PLAN_DIR)
	if dir == null:
		return files
	for name in dir.get_files():
		if name.ends_with(".json"):
			files.append(name)
	files.sort()
	return files


func _run(file_name: String) -> Dictionary:
	var plan: Dictionary = _plan(file_name)
	if plan.is_empty():
		return {}
	new_session(int(plan["seed"]), false)
	var report: Dictionary = await session.run(ScriptedDecider.new(plan, session.log))
	report["plan"] = plan
	return report


## Every shipped plan plays to the end with no illegal scripted choice.
func test_every_plan_runs_to_the_end() -> void:
	var files: Array = _plan_files()
	assert_true(files.size() >= 3, "almeno tre piani d'esempio (§18.1)")
	for file_name in files:
		var report: Dictionary = await _run(str(file_name))
		if report.is_empty():
			continue
		assert_eq(
			int(report["illegal_actions"]), 0, "%s: nessuna scelta scriptata illegale" % file_name
		)
		assert_eq(int(session.world["act"]), 3, "%s: arriva all'Atto 3" % file_name)
		assert_eq(str(session.world["phase"]), "CHRONICLE_END", "%s: chiude la Chronicle" % file_name)
		assert_eq(
			int(session.world["drift_index"]), 9, "%s: tutti e 9 i Drift applicati" % file_name
		)
		assert_eq(
			(report["destiny_results"] as Dictionary).size(), 4, "%s: 4 Destiny valutati" % file_name
		)


## Each plan asserts its own outcome in its `expected` block; here we check the
## harness honours it, and that the three plans really do end differently.
func test_plans_meet_their_expectations_and_differ() -> void:
	var signatures: Array = []
	for file_name in _plan_files():
		var report: Dictionary = await _run(str(file_name))
		if report.is_empty():
			continue
		var plan: Dictionary = report["plan"]
		var expected: Dictionary = plan.get("expected", {})
		var outcomes: Array = []
		for result in report["confluences"]:
			outcomes.append(str(result["outcome"]))

		if expected.has("confluence_count"):
			assert_eq(
				int(session.world["confluence_count"]),
				int(expected["confluence_count"]),
				"%s: numero di Confluence atteso" % file_name
			)
		if expected.has("outcomes"):
			assert_eq(outcomes, Array(expected["outcomes"]), "%s: esiti attesi" % file_name)
		if expected.has("min_echoes"):
			assert_true(
				int(report["echoes"]) >= int(expected["min_echoes"]),
				"%s: almeno %d Echo" % [file_name, int(expected["min_echoes"])]
			)

		var levels: Array = []
		for entity_id in session.world["turn_order"]:
			levels.append(str(report["destiny_results"][entity_id]["level"]))
		signatures.append("%s|%s" % ["/".join(PackedStringArray(outcomes)), "/".join(PackedStringArray(levels))])

	# §18.3: "esiti finali diversi tra loro".
	for i in range(signatures.size()):
		for j in range(i + 1, signatures.size()):
			assert_ne(signatures[i], signatures[j], "i piani %d e %d finiscono diversamente" % [i, j])


## §18.3: at least one sample run writes an Echo and a Truth on its own.
func test_at_least_one_plan_writes_history() -> void:
	var echoes: int = 0
	var truths: int = 0
	for file_name in _plan_files():
		var report: Dictionary = await _run(str(file_name))
		if report.is_empty():
			continue
		echoes += int(report["echoes"])
		truths += int(report["truths"])
		for echo in session.world["echo_log"]:
			assert_true(str(echo["summary"]).length() > 0, "ogni Echo ha un testo")
			assert_true((echo["effect_ids"] as Array).size() > 0, "ogni Echo cita gli Effect che lo hanno prodotto")
	assert_true(echoes >= 1, "almeno un Echo generato automaticamente")
	assert_true(truths >= 1, "almeno un Truth registrato")


## Every resolved Council reports the Consequences it applied, by id and in
## order. The board shows that list to the table as "cosa resta" (D-039), so it
## has to be the list the resolution actually used and not a plausible one:
## which pool applies depends on the outcome, and re-deriving it in the screen
## would be the resolution order written down twice.
func test_a_resolved_council_reports_what_it_applied() -> void:
	var seen: int = 0
	for file_name in _plan_files():
		var report: Dictionary = await _run(str(file_name))
		if report.is_empty():
			continue
		for result in report["confluences"]:
			var ids: Array = (result as Dictionary).get("consequence_ids", [])
			assert_true(ids.size() > 0, "un Consiglio risolto applica almeno una Conseguenza")
			for consequence_id in ids:
				assert_true(
					session.data.consequences.has(str(consequence_id)),
					"e ogni Conseguenza citata esiste: %s" % str(consequence_id)
				)
			seen += 1
	assert_true(seen > 0, "almeno un Consiglio deve essersi risolto")


## The Act-end Echo card announces itself, with the Effects it applied (D-044).
## Three times a Chronicle the story turns on a card; the screen shows it, and
## it can only show what the controller says out loud.
func test_the_act_echo_card_announces_itself_and_what_it_did() -> void:
	new_session(4242, false)
	var seen: Array = []
	session.chronicle.act_echo_drawn.connect(
		func(card: Dictionary, applied: Array) -> void:
			seen.append({"card": card, "applied": applied})
	)
	await session.run(PolicyDecider.new(session.log))

	assert_eq(seen.size(), 3, "una carta per Atto, tre in una Chronicle")
	for entry in seen:
		var card: Dictionary = entry["card"]
		assert_true(str(card["title"]) != "", "la carta ha un titolo")
		assert_true(
			EchoCardView.FAMILIES.has(str(card["dramatic_family"])),
			"e una famiglia drammatica che lo schermo sa disegnare: %s" % str(card["dramatic_family"])
		)
		assert_true(str(card["description"]) != "", "e un testo da leggere")
		assert_true(
			EchoCardView.FUNCTIONS.has(str(card["function_id"])),
			"e la funzione di Propp ha un nome in italiano: %s" % str(card["function_id"])
		)
		assert_true(
			(entry["applied"] as Array).size() > 0,
			"%s ha applicato almeno un Effect al mondo" % str(card["id"])
		)
		for effect in entry["applied"]:
			assert_true(
				EffectText.say(effect as Dictionary, data()) != "",
				"e ogni Effect si sa dire a voce: %s" % str((effect as Dictionary)["type"])
			)


## §18.3: same seed + same plan => byte-identical final save.
func test_same_seed_and_plan_give_an_identical_save() -> void:
	var file_name: String = str(_plan_files()[0])
	_run(file_name)
	var first: String = SaveSerializer.to_json(session.to_save("det"))
	_run(file_name)
	var second: String = SaveSerializer.to_json(session.to_save("det"))
	assert_eq(first, second, "%s: due esecuzioni producono lo stesso salvataggio" % file_name)


## A different seed has to change the run, or the seeding would be decorative.
func test_a_different_seed_changes_the_run() -> void:
	var plan: Dictionary = _plan(str(_plan_files()[0]))
	new_session(int(plan["seed"]), false)
	await session.run(ScriptedDecider.new(plan.duplicate(true), session.log))
	var first: String = SaveSerializer.to_json(session.to_save("det"))

	new_session(int(plan["seed"]) + 7, false)
	await session.run(ScriptedDecider.new(plan.duplicate(true), session.log))
	var second: String = SaveSerializer.to_json(session.to_save("det"))
	assert_ne(first, second, "un seed diverso produce una Chronicle diversa")


## The public log must never print a veiled Tension's number (§11.1, §19.2).
func test_the_public_log_keeps_veiled_values_private() -> void:
	var report: Dictionary = await _run(str(_plan_files()[0]))
	if report.is_empty():
		return
	var text: String = session.log.text()
	assert_false(text.contains("Il Risveglio: 2/7"), "il valore velato non compare nel log")
	assert_true(text.contains("velata"), "il log dice che e velata, e basta")
