extends SceneTree
## Sonda delle scelte: cosa il tavolo poteva dire, e cosa ha detto.
##
##   godot --headless --path godot --script res://cli/run_choice_probe.gd -- \
##       --runs=40 --seed=2000 --chronicle=CHR_03 --tavolo=misto
##
## Il progetto ha gia' trovato tre volte lo stesso problema guardando un numero
## che nessuno guardava, e la forma e' sempre la stessa: **contenuto scritto,
## legale, e che non succede mai** ([D-035](../docs/DECISIONS.md#d-035)). La
## sonda di testo dice quali frasi il motore ha prodotto; questa dice quali non
## ha prodotto, e - la parte che serve per decidere cosa fare - **perche'**.
##
## Tre modi diversi per cui una proposta non arriva ai voti, e vogliono tre
## rimedi diversi:
##
##   - **la sua domanda non viene mai posta**: e' un problema di domande, e si
##     cura sulla domanda (e' quello che ha curato D-061);
##   - **la domanda si pone ma la proposta non e' mai eleggibile**: la clausola
##     di eligibility non si avvera nei mondi che il gioco produce davvero, e va
##     riscritta o tolta;
##   - **e' eleggibile e non viene mai scelta**: la policy la giudica sempre
##     peggiore. O e' scritta male, o e' scritta per un tavolo di persone che
##     hanno ragioni che un ottimizzatore non ha - e allora la si misura con
##     `run_playtest.gd`, non qui.
##
## La sonda non decide quale dei tre sia: li separa, che e' quello che serve per
## non tirare a indovinare.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 2000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	# `--tavolo=misto` mette ai seggi i quattro caratteri di D-051 invece di
	# quattro ottimizzatori identici. Serve a separare le due risposte possibili
	# a «questa proposta non la sceglie nessuno»: contenuto debole, oppure una
	# policy sola che valuta sempre allo stesso modo.
	var mixed: bool = str(options.get("tavolo", "uniforme")) == "misto"

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return
	if not data.chronicles.has(chronicle_id):
		printerr("nessuna Chronicle '%s'" % chronicle_id)
		quit(4)
		return

	var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
	var asked: Dictionary = {}     # question_id -> volte posta
	var open_questions: Dictionary = {}  # question_id -> volte sul tavolo
	var offered: Dictionary = {}   # proposition_id -> volte disponibile
	var chosen: Dictionary = {}    # proposition_id -> volte messa ai voti

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, first_seed + i):
			printerr("setup fallito: %s" % session.last_error)
			quit(5)
			return
		session.confluence.step_changed.connect(
			func(step: String, context: Dictionary) -> void:
				_collect(session, step, context, asked, open_questions, offered, chosen)
		)
		var table: RefCounted = PolicyDecider.new(session.log)
		if mixed:
			table = Characters.deal(seats, RngService.new(first_seed + i), session.log)
		await session.run(table)
		session.dispose()

	print("")
	print(
		(
			"== SONDA DELLE SCELTE - %s, tavolo %s, %d Chronicle, seed %d-%d =="
			% [
				chronicle_id,
				"misto" if mixed else "uniforme",
				runs,
				first_seed,
				first_seed + runs - 1,
			]
		)
	)
	_report(data, chronicle_id, asked, open_questions, offered, chosen)
	quit(0)


func _collect(
	session: RefCounted,
	step: String,
	context: Dictionary,
	asked: Dictionary,
	open_questions: Dictionary,
	offered: Dictionary,
	chosen: Dictionary
) -> void:
	if step != "PROPOSITION":
		return
	# La domanda si conta **qui** e non all'apertura: `open()` sceglie un default
	# e poi il proponente puo' cambiarlo (§12.2 B). Contata all'apertura, questa
	# sonda ha detto per un giro che una domanda non veniva mai posta mentre le
	# sue proposte venivano votate quindici volte.
	var question_id: String = str(context["question_id"])
	asked[question_id] = int(asked.get(question_id, 0)) + 1
	# E quali domande erano sul tavolo in quel momento, non solo quella scelta:
	# senza questo, «mai posta» non distingue una domanda che il mondo non apre
	# mai da una che il proponente scarta sempre.
	for question in session.confluence.available_questions():
		var id: String = str((question as Dictionary)["id"])
		open_questions[id] = int(open_questions.get(id, 0)) + 1
	# Le proposte disponibili si leggono **qui** e non dai dati: `eligibility` si
	# valuta contro il mondo di questo momento, ed e' esattamente la differenza
	# fra «scritta» e «offerta» che questa sonda esiste per misurare.
	for proposition in session.confluence.available_propositions():
		var id: String = str((proposition as Dictionary)["id"])
		offered[id] = int(offered.get(id, 0)) + 1
	var picked: String = str(context.get("proposition_id", ""))
	if picked != "":
		chosen[picked] = int(chosen.get(picked, 0)) + 1


func _report(
	data: RefCounted,
	chronicle_id: String,
	asked: Dictionary,
	open_questions: Dictionary,
	offered: Dictionary,
	chosen: Dictionary
) -> void:
	var never_asked: Array = []
	var never_offered: Array = []
	var never_chosen: Array = []
	var written: int = 0

	for template_id in (data.chronicles[chronicle_id]["confluence_templates"] as Array):
		if not data.confluence_templates.has(str(template_id)):
			continue
		var template: Dictionary = data.confluence_templates[str(template_id)]
		print("")
		print("%s — %s" % [str(template["id"]), str(template["title"])])
		for question in template["questions"]:
			var question_id: String = str((question as Dictionary)["id"])
			var times: int = int(asked.get(question_id, 0))
			var open_times: int = int(open_questions.get(question_id, 0))
			var why: String = ""
			if times == 0:
				why = "  <- mai aperta dal mondo" if open_times == 0 else "  <- aperta e mai scelta"
			print("  [%3dx su %3d aperte] %-26s%s" % [times, open_times, question_id, why])
			for proposition in template["propositions"]:
				var item: Dictionary = proposition
				if str(item["question_id"]) != question_id:
					continue
				written += 1
				var up: int = int(offered.get(str(item["id"]), 0))
				var picked: int = int(chosen.get(str(item["id"]), 0))
				var note: String = ""
				if times == 0:
					note = (
						"  <- la sua domanda non si pone mai"
						if open_times > 0
						else "  <- la sua domanda non si apre mai"
					)
					never_asked.append(str(item["id"]))
				elif up == 0:
					note = "  <- mai eleggibile"
					never_offered.append(str(item["id"]))
				elif picked == 0:
					note = "  <- offerta e mai scelta"
					never_chosen.append(str(item["id"]))
				print(
					"        offerta %3d  scelta %3d   %-28s%s"
					% [up, picked, str(item["id"]), note]
				)

	print("")
	print("== PERCHE' NON SUCCEDE ==")
	print("  proposte scritte: %d" % written)
	_list("la domanda non si pone mai", never_asked)
	_list("mai eleggibile", never_offered)
	_list("offerta e mai scelta", never_chosen)
	var dead: int = never_asked.size() + never_offered.size() + never_chosen.size()
	print("")
	print("  mai ai voti: %d su %d" % [dead, written])


func _list(title: String, ids: Array) -> void:
	print("")
	print("  %s — %d" % [title, ids.size()])
	for id in ids:
		print("    %s" % str(id))


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
