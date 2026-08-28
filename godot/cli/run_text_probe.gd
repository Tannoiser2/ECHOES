extends SceneTree
## Text probe: play N Chronicles and print every distinct narrative sentence the
## engine actually produced, with the world state that produced it.
##
##   godot --headless --path godot --script res://cli/run_text_probe.gd -- \
##       --runs=40 --seed=2000 --chronicle=CHR_00
##
## This exists to answer one question that cannot be answered by reading the
## data: do authored sentences with $slots in them still read like a person
## wrote them, once the engine has filled the slots from a world nobody planned?
##
## It reads the Truth register, which is the permanent record - if a sentence is
## going to embarrass anyone, it will be one of these.
##
## The distinct-sentence count across runs was never the whole question. A
## sentence that appears once per Chronicle in forty Chronicles is variety; the
## same sentence three times in *one* register is a Chronicle that repeats
## itself to the table that played it. So the probe also counts, per single
## Chronicle, how often a Truth is written twice or more.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 2000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var seats: Array = SEATS
	if data.chronicles.has(chronicle_id):
		# Il tavolo del primo seme, tenuto per tutte le partite (D-213).
		seats = GameSession.seats_for(data, chronicle_id, first_seed)

	var truths: Dictionary = {}
	var questions: Dictionary = {}
	var propositions: Dictionary = {}
	var focus_regions: Dictionary = {}
	# Quante Chronicle hanno scritto almeno una Truth due volte, e la peggiore.
	var repeating: int = 0
	var repeated_lines: int = 0
	var worst: int = 0
	var worst_text: String = ""

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, first_seed + i):
			printerr("setup fallito: %s" % session.last_error)
			quit(4)
			return
		session.confluence.step_changed.connect(
			func(step: String, context: Dictionary) -> void:
				_collect(session, context, step, questions, propositions, focus_regions)
		)
		await session.run(PolicyDecider.new(session.log))
		var here: Dictionary = {}
		for truth in session.world["truth_log"]:
			var text: String = str(truth["text"])
			truths[text] = int(truths.get(text, 0)) + 1
			# Senza «Anno, Atto» davanti e senza i numeri in coda: chi rilegge il
			# registro vede la frase, non la terna. Due righe che differiscono solo
			# per (S O M) sono, per chi legge, la stessa riga scritta due volte.
			var sentence: String = _sentence(text)
			here[sentence] = int(here.get(sentence, 0)) + 1
		var repeated_here: bool = false
		for text in here:
			var times: int = int(here[text])
			if times < 2:
				continue
			repeated_here = true
			repeated_lines += times - 1
			if times > worst:
				worst = times
				worst_text = str(text)
		if repeated_here:
			repeating += 1
		session.dispose()

	print("")
	print(
		(
			"== SONDA DI TESTO - %s, %d Chronicle, seed %d-%d =="
			% [chronicle_id, runs, first_seed, first_seed + runs - 1]
		)
	)

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

	# La misura che conta per chi sta al tavolo: non quante frasi diverse esistono
	# in quaranta partite, ma quante volte una partita ripete se stessa.
	print("")
	print("RIPETIZIONI dentro la stessa Chronicle")
	print("  Chronicle con almeno una Truth ripetuta: %d su %d" % [repeating, runs])
	print("  Righe di registro duplicate: %d su %d" % [repeated_lines, total])
	if worst_text != "":
		print("  Peggiore: %d volte - %s" % [worst, worst_text])
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


## La frase dentro una riga di Truth: senza «Anno 1640, Atto 3: » davanti e senza
## « (S4 O0 M5).» in coda.
func _sentence(text: String) -> String:
	var out: String = text
	var colon: int = out.find(": ")
	if colon >= 0 and out.begins_with("Anno "):
		out = out.substr(colon + 2)
	var open_paren: int = out.rfind(" (S")
	if open_paren >= 0:
		out = out.substr(0, open_paren)
	return out.strip_edges()


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
