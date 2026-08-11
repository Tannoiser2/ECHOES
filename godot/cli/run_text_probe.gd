extends SceneTree
## Text probe: play N Chronicles and print every distinct narrative sentence the
## engine actually produced, with the world state that produced it.
##
##   godot --headless --path godot --script res://cli/run_text_probe.gd -- \
##       --runs=40 --seed=2000
##
## This exists to answer one question that cannot be answered by reading the
## data: do authored sentences with $slots in them still read like a person
## wrote them, once the engine has filled the slots from a world nobody planned?
##
## It reads the Truth register, which is the permanent record - if a sentence is
## going to embarrass anyone, it will be one of these.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 2000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var truths: Dictionary = {}
	var questions: Dictionary = {}
	var propositions: Dictionary = {}
	var focus_regions: Dictionary = {}

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		if not session.setup("CHR_01", SEATS, first_seed + i):
			printerr("setup fallito: %s" % session.last_error)
			quit(4)
			return
		session.confluence.step_changed.connect(
			func(step: String, context: Dictionary) -> void:
				_collect(session, context, step, questions, propositions, focus_regions)
		)
		await session.run(PolicyDecider.new(session.log))
		for truth in session.world["truth_log"]:
			var text: String = str(truth["text"])
			truths[text] = int(truths.get(text, 0)) + 1
		session.dispose()

	print("")
	print("== SONDA DI TESTO - %d Chronicle, seed %d-%d ==" % [runs, first_seed, first_seed + runs - 1])

	_dump("DOMANDE poste al tavolo", questions)
	_dump("PROPOSTE messe ai voti", propositions)
	_dump("TRUTH - il registro permanente", truths)

	print("")
	print("Regione a fuoco, per Tensione")
	var keys: Array = focus_regions.keys()
	keys.sort()
	for key in keys:
		print("  %-46s %d volte" % [str(key), int(focus_regions[key])])

	var total: int = 0
	for text in truths:
		total += int(truths[text])
	print("")
	print("Frasi Truth distinte: %d su %d registrate" % [truths.size(), total])
	quit(0)


func _collect(
	session: RefCounted,
	context: Dictionary,
	step: String,
	questions: Dictionary,
	propositions: Dictionary,
	focus_regions: Dictionary
) -> void:
	var controller: RefCounted = session.confluence
	var template: Dictionary = session.data.confluence_templates[str(context["template_id"])]
	if step == "QUESTION":
		var tension_id: String = str(context["tension_id"])
		var region_id: String = controller.narrative.focus_region(tension_id)
		var key: String = "%s -> %s" % [
			str(session.data.tensions[tension_id]["title"]),
			str(session.data.regions[region_id]["name"]),
		]
		focus_regions[key] = int(focus_regions.get(key, 0)) + 1
		for question in template["questions"]:
			if str(question["id"]) == str(context["question_id"]):
				var text: String = controller.say(str(question["text"]))
				questions[text] = int(questions.get(text, 0)) + 1
	elif step == "PROPOSITION":
		for proposition in template["propositions"]:
			if str(proposition["id"]) == str(context["proposition_id"]):
				var text: String = controller.say(str(proposition["text"]))
				propositions[text] = int(propositions.get(text, 0)) + 1


func _dump(title: String, counts: Dictionary) -> void:
	print("")
	print("%s - %d distinte" % [title, counts.size()])
	var keys: Array = counts.keys()
	keys.sort()
	for key in keys:
		print("  [%2dx] %s" % [int(counts[key]), str(key)])


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
