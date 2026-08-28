extends SceneTree
## Quali segni il mondo scrive davvero, e chi li guarda
##
##   godot --headless --path godot --script res://cli/run_world_marks_probe.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_00
##
## Le sonde di prima misuravano **i segni che i Destini nominano**: quanti erano
## gia' veri all'apertura, quante volte il mondo li scriveva. Questa guarda
## dall'altra parte: parte da **quello che il mondo scrive** e chiede se qualcuno
## se ne accorge.
##
## E' la domanda rimasta aperta da [D-323](../../docs/DECISIONS.md#d-323). Da
## quando una domanda caduta lascia il segno, il mondo si sporca sul serio — ma
## le memorie temute non si sono mosse di un decimo, e la ragione misurata e' che
## **i segni che un fallimento lascia non sono i segni che i Destini temono**.
## Prima di dire a chi far temere cosa, serve sapere **quali segni escono
## davvero**: un segno che compare due volte in cent'anni non e' un bersaglio,
## per quanto bene sia scritto.
##
## Tre colonne per ogni segno:
##
##   · **scritto** — quante volte il mondo lo posa, in tutte le partite;
##   · **temuto** — quante clausole `state_tag_absent` lo nominano;
##   · **voluto** — quante clausole `state_tag_present` lo nominano.
##
## Un segno **scritto spesso e guardato da nessuno** e' lavoro del motore che al
## tavolo non conta niente. Un segno **guardato e mai scritto** e' un punto
## regalato. Le due liste in fondo sono quelle da leggere.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")
	var out_path: String = str(options.get("out", ""))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# **Solo i segni che al tavolo si posano**: MEMORY (le memorie del mondo) e
	# STATE (le condizioni dei luoghi). Fuori restano FUNCTION, ENTITY e PLACE,
	# che sono contabilita' del motore — `knows_tension:`, `discovery:`,
	# `function:` — e nessuno si aspetta che un Destino li punti.
	var scored: Dictionary = {}
	for tag_id in data.tags:
		var category: String = str((data.tags[tag_id] as Dictionary).get("category", ""))
		if category == "MEMORY" or category == "STATE":
			scored[str(tag_id)] = true

	# Chi guarda cosa: si legge dalla scatola, non dalla partita.
	var feared: Dictionary = {}
	var wanted: Dictionary = {}
	for source in [data.destinies, data.objectives]:
		for item_id in (source as Dictionary):
			_read_clauses((source as Dictionary)[item_id], feared, wanted)

	var written: Dictionary = {}
	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(3)
			return
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		# I segni posati **dal setup** non li conta nessuno: quelli sono la
		# dotazione, non quello che la partita produce.
		var from_setup: int = (session.world["effect_log"] as Array).size()
		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return
		var log_entries: Array = session.world["effect_log"] as Array
		for index in range(from_setup, log_entries.size()):
			var e: Dictionary = (
				(log_entries[index] as Dictionary).get("effect", log_entries[index])
			) as Dictionary
			var kind: String = str(e.get("type", ""))
			if kind != "SET_REGION_TAG" and kind != "SET_GLOBAL_TAG" and kind != "SET_ENTITY_TAG":
				continue
			var what: String = str((e.get("payload", {}) as Dictionary).get("tag", ""))
			if what == "" or not scored.has(what):
				continue
			written[what] = int(written.get(what, 0)) + 1
		session.dispose()

	_report(runs, mixed, written, feared, wanted, scored, out_path)


## Ogni clausola di un Destino o di un Obiettivo che nomina un segno, coi due
## versi separati: chi lo teme e chi lo vuole.
func _read_clauses(item: Variant, feared: Dictionary, wanted: Dictionary) -> void:
	if item is Dictionary:
		var clause: Dictionary = item as Dictionary
		var kind: String = str(clause.get("type", ""))
		var tag: String = str(clause.get("tag", ""))
		if tag != "":
			if kind == "state_tag_absent":
				feared[tag] = int(feared.get(tag, 0)) + 1
			elif kind == "state_tag_present":
				wanted[tag] = int(wanted.get(tag, 0)) + 1
		for key in clause:
			_read_clauses(clause[key], feared, wanted)
	elif item is Array:
		for value in (item as Array):
			_read_clauses(value, feared, wanted)


func _report(
	runs: int, mixed: bool, written: Dictionary, feared: Dictionary,
	wanted: Dictionary, scored: Dictionary, out_path: String
) -> void:
	var lines: Array = []
	lines.append("# ECHOES — quali segni il mondo scrive, e chi li guarda")
	lines.append("")
	lines.append("<!-- FILE GENERATO — si rifa' con `tools/run_marks_survey.sh`. -->")
	lines.append("")
	lines.append(
		"Ogni segno che si posa sul tavolo — le memorie del mondo e le condizioni"
		+ " dei luoghi — con **quante volte la partita lo scrive** e **quante"
		+ " clausole lo guardano**. Fuori restano la contabilita' del motore"
		+ " (`knows_tension:`, `function:`, i posti): quelli nessuno si aspetta"
		+ " che un Destino li punti."
	)
	lines.append("")
	lines.append(
		"Le due liste in fondo sono quelle da leggere. Un segno **scritto spesso e"
		+ " guardato da nessuno** e' lavoro del motore che al tavolo non conta"
		+ " niente. Un segno **guardato e mai scritto** e' un punto regalato: la"
		+ " clausola che lo teme e' vera dall'apertura e nessuno la puo' rompere."
	)
	lines.append("")
	lines.append("Misura: `cli/run_world_marks_probe.gd`, %d partite, tavolo %s, semi da 7000."
		% [runs, "misto" if mixed else "uniforme"])
	lines.append("")

	var every: Dictionary = {}
	for tag in written:
		every[tag] = true
	for tag in feared:
		if scored.has(tag):
			every[tag] = true
	for tag in wanted:
		if scored.has(tag):
			every[tag] = true
	var names: Array = every.keys()
	names.sort()

	var mute: Array = []
	var absent: Array = []
	lines.append("## Segno per segno")
	lines.append("")
	lines.append("| segno | scritto | temuto | voluto | |")
	lines.append("|---|---|---|---|---|")
	for tag in names:
		var w: int = int(written.get(tag, 0))
		var f: int = int(feared.get(tag, 0))
		var v: int = int(wanted.get(tag, 0))
		var mark: String = ""
		if w >= maxi(1, runs / 10) and f == 0 and v == 0:
			mark = "nessuno lo guarda"
			mute.append([tag, w])
		elif w == 0 and (f > 0 or v > 0):
			mark = "**mai scritto**"
			absent.append([tag, f + v])
		lines.append("| `%s` | %d | %d | %d | %s |" % [str(tag), w, f, v, mark])
	lines.append("")

	mute.sort_custom(func(a: Array, b: Array) -> bool: return int(a[1]) > int(b[1]))
	absent.sort_custom(func(a: Array, b: Array) -> bool: return int(a[1]) > int(b[1]))

	lines.append("## Lavoro del motore che al tavolo non conta")
	lines.append("")
	lines.append("Scritti almeno %d volte, e nessuna clausola li nomina." % maxi(1, runs / 10))
	lines.append("")
	if mute.is_empty():
		lines.append("Nessuno: ogni segno che il mondo scrive spesso lo guarda qualcuno.")
	else:
		lines.append("| segno | scritto |")
		lines.append("|---|---|")
		for row in mute:
			lines.append("| `%s` | %d |" % [str(row[0]), int(row[1])])
	lines.append("")

	lines.append("## Punti regalati: guardati e mai scritti")
	lines.append("")
	lines.append("Una clausola che teme una cosa che non succede mai e' vera dall'apertura.")
	lines.append("")
	if absent.is_empty():
		lines.append("Nessuno.")
	else:
		lines.append("| segno | clausole |")
		lines.append("|---|---|")
		for row in absent:
			lines.append("| `%s` | %d |" % [str(row[0]), int(row[1])])
	lines.append("")

	var text: String = "\n".join(lines)
	if out_path == "":
		print(text)
	else:
		var handle: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
		if handle == null:
			printerr("non riesco a scrivere %s" % out_path)
			quit(3)
			return
		handle.store_string(text)
		handle.close()
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		var body: String = text.substr(2)
		var split: int = body.find("=")
		if split < 0:
			out[body] = true
		else:
			out[body.substr(0, split)] = body.substr(split + 1)
	return out
