extends SceneTree
## Il catalogo dei Consigli, in parole da tavolo (D-232).
##
##   godot --headless --path godot --script res://cli/run_council_catalogue.gd \
##       -- --out=../docs/CATALOGO_CONSIGLI.md
##
## ISSUES 62: le 10 domande, le 43 proposte, le 19 clausole e le 52 Conseguenze
## esistono **solo come database**. Zero fogli di stampa su 39 ne portano una, e
## sullo schermo la proposta si legge una riga alla volta mentre il Consiglio e'
## gia' aperto.
##
## Questo e' il pezzo che serve a **tutte e tre** le forme che il committente
## deve ancora scegliere — scheda per Tensione, libretto dei Consigli, o app come
## arbitro: il materiale tirato fuori dal database e scritto in italiano, coi
## buchi spiegati invece che riempiti. Che forma prendera' e' una decisione
## d'autore; che si legga non lo e'.
##
## Generato, come `BRIEF_ARTE.md`: si rifa' e non invecchia.

const DataSet := preload("res://scripts/core/data_set.gd")
const CouncilText := preload("res://scripts/core/council_text.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var lines: Array = [
		"# ECHOES — il catalogo dei Consigli",
		"",
		"<!-- FILE GENERATO — si rifa' con `tools/run_council_catalogue.sh`. -->",
		"",
		"Ogni Consiglio della scatola: la domanda che apre, le proposte fra cui",
		"sceglie chi propone, le clausole che gli altri possono attaccare, e **cosa",
		"resta al mondo** se una proposta passa.",
		"",
		"Le frasi d'autore hanno dei buchi — `$proponent`, `$region_focus` — che al",
		"tavolo li riempie la partita. Qui sono **spiegati** invece che riempiti: una",
		"scheda si legge prima di giocare, quando non c'e' ancora una Regione a cui",
		"riferirsi.",
		"",
	]

	var ids: Array = []
	for template_id in data.confluence_templates:
		ids.append(str(template_id))
	ids.sort()

	var propositions: int = 0
	var clauses: int = 0
	for template_id in ids:
		var template: Dictionary = data.confluence_templates[template_id] as Dictionary
		lines.append("---")
		lines.append("")
		lines.append("## %s" % str(template["title"]))
		lines.append("")
		var about: Variant = data.tensions.get(str(template.get("tension_id", "")))
		if about != null:
			lines.append("*Si apre su **%s**.*" % str((about as Dictionary)["title"]))
			lines.append("")
		lines.append(CouncilText.speak(str(template.get("description", ""))))
		lines.append("")

		for entry in template.get("propositions", []):
			var said: Dictionary = CouncilText.proposition(
				template, str((entry as Dictionary)["id"]), data
			)
			if said.is_empty():
				continue
			propositions += 1
			lines.append("### %s" % str(said["text"]))
			lines.append("")
			lines.append("> %s" % str(said["question"]))
			lines.append("")
			for need in said["needs"]:
				lines.append("- **Si puo' proporre solo se:** %s" % str(need))
			for leaf in said["consequences"]:
				var record: Dictionary = leaf as Dictionary
				lines.append("- **Se passa — %s:** %s" % [
					str(record["title"]), str(record["leaves"]),
				])
			if said["needs"].is_empty() and (said["consequences"] as Array).is_empty():
				lines.append("- *(nessuna condizione, e non lascia segni al mondo)*")
			lines.append("")

		var attachable: Array = CouncilText.clauses(template, data)
		if not attachable.is_empty():
			lines.append("**Le clausole che si possono attaccare:**")
			lines.append("")
			for clause in attachable:
				var record: Dictionary = clause as Dictionary
				clauses += 1
				lines.append("- %s" % str(record["text"]))
				if str(record["leaves"]) != "":
					lines.append("  - se qualificata: %s" % str(record["leaves"]))
			lines.append("")

	lines.append("---")
	lines.append("")
	lines.append("*%d Consigli, %d proposte, %d clausole.*" % [
		ids.size(), propositions, clauses,
	])
	lines.append("")

	var text: String = "\n".join(PackedStringArray(lines))
	var out: String = str(options.get("out", ""))
	if out == "":
		print(text)
		quit(0)
		return
	var handle: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	if handle == null:
		printerr("non riesco a scrivere %s" % out)
		quit(3)
		return
	handle.store_string(text)
	handle.close()
	print("scritto %s — %d Consigli, %d proposte, %d clausole" % [
		out, ids.size(), propositions, clauses,
	])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		var pair: PackedStringArray = text.substr(2).split("=")
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
