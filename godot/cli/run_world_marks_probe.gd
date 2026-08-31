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
## tavolo non conta niente.
##
## E un segno **mai scritto** vale due difetti **opposti**, a seconda del verso
## della clausola che lo nomina — per due versioni questa sonda li ha messi nella
## stessa lista, sotto il titolo sbagliato per meta' di loro:
##
##   · lo **teme** (`state_tag_absent`): la clausola e' vera dall'apertura e
##     nessuno la puo' rompere. **Un punto regalato.**
##   · lo **vuole** (`state_tag_present`): la clausola e' falsa dall'apertura e
##     nessuno la puo' avverare. **Una porta murata**, e chi la legge sulla sua
##     carta Destino non ha modo di saperlo.
##
## Percio' le liste in fondo sono tre, e ognuna dice **di chi e' il passo** che
## ci sta appeso: un `mine_sealed` mai scritto non e' un numero, e' la VITTORIA
## di Vaerax che non si prende.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

## I passi di un Destino, con la parola che il giocatore legge sul tarocco.
const STEPS := {"minimum": "SOGLIA", "victory": "VITTORIA", "triumph": "TRIONFO"}


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

	# Chi guarda cosa: si legge dalla scatola, non dalla partita. E si tiene
	# **chi** guarda, non solo quanti: il passo di un Destino e' quello che un
	# giocatore legge sulla sua carta.
	var feared: Dictionary = {}
	var wanted: Dictionary = {}
	var who_fears: Dictionary = {}
	var who_wants: Dictionary = {}
	for source in [data.destinies, data.objectives]:
		for item_id in (source as Dictionary):
			var item: Dictionary = (source as Dictionary)[item_id] as Dictionary
			var owner: String = str(item.get("id", item_id))
			for step in STEPS:
				if item.has(step):
					_read_clauses(
						item[step], feared, wanted, who_fears, who_wants,
						"%s · %s" % [owner, str(STEPS[step])]
					)
			# Gli Obiettivi non hanno passi: le loro clausole stanno di fianco.
			for key in item:
				if STEPS.has(key):
					continue
				_read_clauses(item[key], feared, wanted, who_fears, who_wants, owner)

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

	# Chi legge il segno, oltre alle clausole di punteggio: dal dizionario, che
	# il validatore tiene allineato ai dati (ISSUES 102, terza riparazione).
	var readers: Dictionary = {}
	for tag_id in data.tags:
		var chi: Array = ((data.tags[tag_id] as Dictionary).get("read_by", []) as Array)
		if not chi.is_empty():
			readers[str(tag_id)] = chi

	_report(runs, mixed, written, feared, wanted, who_fears, who_wants, scored,
		readers, out_path)


## Ogni clausola di un Destino o di un Obiettivo che nomina un segno, coi due
## versi separati: chi lo teme e chi lo vuole, e **di chi e' il passo**.
func _read_clauses(
	item: Variant, feared: Dictionary, wanted: Dictionary,
	who_fears: Dictionary, who_wants: Dictionary, owner: String
) -> void:
	if item is Dictionary:
		var clause: Dictionary = item as Dictionary
		var kind: String = str(clause.get("type", ""))
		var tag: String = str(clause.get("tag", ""))
		if tag != "":
			if kind == "state_tag_absent":
				feared[tag] = int(feared.get(tag, 0)) + 1
				_note_owner(who_fears, tag, owner)
			elif kind == "state_tag_present":
				wanted[tag] = int(wanted.get(tag, 0)) + 1
				_note_owner(who_wants, tag, owner)
		for key in clause:
			_read_clauses(clause[key], feared, wanted, who_fears, who_wants, owner)
	elif item is Array:
		for value in (item as Array):
			_read_clauses(value, feared, wanted, who_fears, who_wants, owner)


func _note_owner(where: Dictionary, tag: String, owner: String) -> void:
	if not where.has(tag):
		where[tag] = []
	var seen: Array = where[tag] as Array
	if not seen.has(owner):
		seen.append(owner)


## Le tre letture di un segno, separate. **Pura**, perche' e' l'unica parte
## della sonda che una prova puo' interrogare senza giocare cento partite: e per
## due versioni e' stata sbagliata senza che niente diventasse rosso.
##
##   · `mute`     — scritto spesso, e nessuna clausola lo nomina;
##   · `regalati` — mai scritto, e qualcuno lo **teme**: clausola sempre vera;
##   · `murate`   — mai scritto, e qualcuno lo **vuole**: clausola mai vera.
##
## Un segno puo' stare in due liste insieme, ed e' giusto: `mine_sealed` regala
## un punto a Lyra e mura la VITTORIA di Vaerax con la stessa assenza.
## `readers` e' l'altra meta' di ISSUES 102: **una clausola non e' un lettore.**
## Le colonne «temuto» e «voluto» contano solo i passi di Destini e Obiettivi;
## una regola del segno, la faccia di una carta, un Consiglio o una Tensione che
## guardano quel segno non comparivano da nessuna parte, e il documento
## dichiarava muto un segno che mordeva. Qui la lista arriva dal `read_by` del
## dizionario, che **il controllo 4 di validate_physical tiene onesto** nei due
## versi: una mano dichiarata e mai vista e' rossa, e una mano vista e non
## dichiarata pure. Fidarsi di quella lista costa zero cecita' nuove; riscrivere
## qui un secondo censimento le costava tutte.
static func letture(written: Dictionary, feared: Dictionary, wanted: Dictionary,
	soglia_muti: int, readers: Dictionary = {}) -> Dictionary:
	var mute: Array = []
	var regalati: Array = []
	var murate: Array = []
	var every: Dictionary = {}
	for tag in written:
		every[tag] = true
	for tag in feared:
		every[tag] = true
	for tag in wanted:
		every[tag] = true
	var names: Array = every.keys()
	names.sort()
	for tag in names:
		var w: int = int(written.get(tag, 0))
		var f: int = int(feared.get(tag, 0))
		var v: int = int(wanted.get(tag, 0))
		var chi_legge: Array = (readers.get(tag, []) as Array)
		if w >= soglia_muti and f == 0 and v == 0 and chi_legge.is_empty():
			mute.append([tag, w])
		if w == 0 and f > 0:
			regalati.append([tag, f])
		if w == 0 and v > 0:
			murate.append([tag, v])
	var by_count: Callable = func(a: Array, b: Array) -> bool: return int(a[1]) > int(b[1])
	mute.sort_custom(by_count)
	regalati.sort_custom(by_count)
	murate.sort_custom(by_count)
	return {"mute": mute, "regalati": regalati, "murate": murate}


func _report(
	runs: int, mixed: bool, written: Dictionary, feared: Dictionary,
	wanted: Dictionary, who_fears: Dictionary, who_wants: Dictionary,
	scored: Dictionary, readers: Dictionary, out_path: String
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
		"Le tre liste in fondo sono quelle da leggere. Un segno **scritto spesso e"
		+ " guardato da nessuno** e' lavoro del motore che al tavolo non conta"
		+ " niente — ma **una clausola non e' un lettore**: le colonne «temuto» e"
		+ " «voluto» contano solo i passi di Destini e Obiettivi, e la colonna"
		+ " «chi altro lo legge» dice le altre mani che quel segno lo"
		+ " interrogano. Un segno con zero clausole e una regola che lo legge non"
		+ " e' muto: e' solo fuori dal punteggio (ISSUES 102)."
		+ " Un segno **mai scritto** vale invece due difetti opposti, e"
		+ " vanno letti separati: chi lo **teme** ha una clausola vera"
		+ " dall'apertura — un punto regalato; chi lo **vuole** ha una clausola"
		+ " che non si puo' avverare — una porta murata."
	)
	lines.append("")
	lines.append("Misura: `cli/run_world_marks_probe.gd`, %d partite, tavolo %s, semi da 7000."
		% [runs, "misto" if mixed else "uniforme"])
	lines.append("")

	# Le clausole guardano anche segni che non si posano sul tavolo: quelli
	# restano fuori dalla tabella, come dice l'intestazione.
	var visti_feared: Dictionary = {}
	for tag in feared:
		if scored.has(tag):
			visti_feared[tag] = feared[tag]
	var visti_wanted: Dictionary = {}
	for tag in wanted:
		if scored.has(tag):
			visti_wanted[tag] = wanted[tag]
	var soglia_muti: int = maxi(1, runs / 10)
	var letto: Dictionary = letture(written, visti_feared, visti_wanted, soglia_muti, readers)

	var every: Dictionary = {}
	for tag in written:
		every[tag] = true
	for tag in visti_feared:
		every[tag] = true
	for tag in visti_wanted:
		every[tag] = true
	var names: Array = every.keys()
	names.sort()

	lines.append("## Segno per segno")
	lines.append("")
	lines.append("| segno | scritto | temuto | voluto | chi altro lo legge | |")
	lines.append("|---|---|---|---|---|---|")
	for tag in names:
		var w: int = int(written.get(tag, 0))
		var f: int = int(visti_feared.get(tag, 0))
		var v: int = int(visti_wanted.get(tag, 0))
		var chi: Array = (readers.get(tag, []) as Array)
		var chi_testo: String = "—"
		if not chi.is_empty():
			var pezzi: Array = []
			for mano in chi:
				pezzi.append("`%s`" % str(mano))
			chi_testo = ", ".join(PackedStringArray(pezzi))
		var mark: String = ""
		if w >= soglia_muti and f == 0 and v == 0 and chi.is_empty():
			mark = "nessuno lo guarda"
		elif w == 0 and (f > 0 or v > 0):
			mark = "**mai scritto**"
		lines.append("| `%s` | %d | %d | %d | %s | %s |"
			% [str(tag), w, f, v, chi_testo, mark])
	lines.append("")

	lines.append("## Lavoro del motore che al tavolo non conta")
	lines.append("")
	lines.append("Scritti almeno %d volte, e nessuna clausola li nomina." % soglia_muti)
	lines.append("")
	var mute: Array = letto["mute"] as Array
	if mute.is_empty():
		lines.append("Nessuno: ogni segno che il mondo scrive spesso lo guarda qualcuno.")
	else:
		lines.append("| segno | scritto |")
		lines.append("|---|---|")
		for row in mute:
			lines.append("| `%s` | %d |" % [str(row[0]), int(row[1])])
	lines.append("")

	lines.append("## Punti regalati: temuti e mai scritti")
	lines.append("")
	lines.append(
		"La clausola che teme una cosa che non succede mai e' vera dall'apertura,"
		+ " e nessuno la puo' rompere: il passo si porta un pezzo gia' fatto."
	)
	lines.append("")
	_lista(lines, letto["regalati"] as Array, who_fears, "Nessuno.")

	lines.append("## Porte murate: voluti e mai scritti")
	lines.append("")
	lines.append(
		"Il difetto opposto, e piu' grave: la clausola vuole una cosa che non"
		+ " succede mai, quindi resta falsa per tutta la partita. Chi legge quel"
		+ " passo sul suo tarocco sta guardando un traguardo che non si prende."
	)
	lines.append("")
	_lista(
		lines, letto["murate"] as Array, who_wants,
		"Nessuna: tutto quello che un passo chiede, il mondo lo scrive almeno una volta."
	)

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


## Una lista in fondo, col passo che ci sta appeso: senza il nome del passo il
## documento dice un numero, e un numero non si va a correggere.
func _lista(lines: Array, rows: Array, owners: Dictionary, se_vuota: String) -> void:
	if rows.is_empty():
		lines.append(se_vuota)
		lines.append("")
		return
	lines.append("| segno | clausole | dove |")
	lines.append("|---|---|---|")
	for row in rows:
		var tag: String = str(row[0])
		var chi: Array = (owners.get(tag, []) as Array).duplicate()
		chi.sort()
		lines.append("| `%s` | %d | %s |" % [tag, int(row[1]), ", ".join(chi)])
	lines.append("")


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
