extends SceneTree
## Il catalogo dei Consigli, in parole da tavolo (D-232).
##
##   godot --headless --path godot --script res://cli/run_council_catalogue.gd \
##       -- --out=../docs/CATALOGO_CONSIGLI.md
##
## ISSUES 62: le domande, le clausole e le Conseguenze esistono **solo come
## database**. Zero fogli di stampa su 39 ne portano una, e sullo schermo quello
## che il Consiglio chiedera' si legge una riga alla volta mentre il Consiglio
## e' gia' aperto.
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
		"Ogni Consiglio della scatola: le **due domande** che la carta mette in",
		"contrasto, quando ognuna si apre, le caselle che puo' sostenere, e **cosa",
		"resta al mondo** se il tavolo le risponde di si'.",
		"",
		"Le frasi d'autore hanno dei buchi — `$proponent`, `$region_focus` — che al",
		"tavolo li riempie la partita. Qui sono **spiegati** invece che riempiti: una",
		"scheda si legge prima di giocare, quando non c'e' ancora una Regione a cui",
		"riferirsi.",
		"",
	]

	# **Il catalogo cammina sulle carte, non sui template** (0.1.273).
	#
	# Fino a 0.1.272 iterava `confluence_templates`: dodici schede per sessanta
	# carte. Da D-310 la Domanda e la Proposta stanno **sulla carta**, e il
	# catalogo stampava ancora le generiche — otto carte del Potere riscritte, e
	# il documento non se ne accorgeva: zero delle proposte nuove, e le vecchie
	# ancora li'. **Nona volta in questo progetto che una misura ferma era la
	# sonda.**
	var ids: Array = []
	for tension_id in data.tensions:
		ids.append(str(tension_id))
	ids.sort()

	var questions: int = 0
	for tension_id in ids:
		var about: Dictionary = data.tensions[tension_id] as Dictionary
		var template: Dictionary = data.confluence_template_for(str(tension_id))
		if template.is_empty():
			continue
		lines.append("---")
		lines.append("")
		lines.append("## %s" % str(about["title"]))
		lines.append("")
		lines.append("*Il Consiglio che questa carta apre.*")
		lines.append("")
		lines.append(CouncilText.speak(str(about.get("description", ""))))
		lines.append("")

		# **Le due domande e le loro caselle** (D-467): la lettera, quando la
		# domanda si apre, l'esito di base, e quali caselle ognuna puo'
		# sostenere. E' l'unico blocco rimasto: fino alla 0.1.443 sotto ci
		# stavano anche le proposte, uscite dai dati con D-474.
		var council: Dictionary = about.get("council", {}) as Dictionary
		var physical: Dictionary = about.get("physical", {}) as Dictionary
		var index: int = 0
		for entry in council.get("questions", []) as Array:
			var question: Dictionary = entry as Dictionary
			var letter: String = char(65 + index)
			index += 1
			lines.append("### %s · %s" % [letter, CouncilText.speak(str(question.get("text", "")))])
			lines.append("")
			questions += 1
			for need in CouncilText.needs_of(question.get("eligibility", []) as Array):
				lines.append("- **Si apre solo se:** %s" % str(need))
			var wins: Array = []
			for consequence_id in (question.get("base", []) as Array):
				var consequence: Dictionary = data.consequences.get(str(consequence_id), {}) as Dictionary
				wins.append(str(consequence.get("title", consequence_id)))
			lines.append("- **Se vince, a prescindere dalle pedine:** %s" % (
				" · ".join(PackedStringArray(wins)) if not wins.is_empty() else "*(niente)*"
			))
			# **E cosa resta se il tavolo la respinge** (D-475): la riga esiste
			# solo dove la carta la scrive, e sono le venti domande su cui sono
			# tornate le sedici Conseguenze delle proposte contrarie.
			var falls: Array = []
			for consequence_id in (question.get("refused", []) as Array):
				var refused: Dictionary = data.consequences.get(str(consequence_id), {}) as Dictionary
				falls.append(str(refused.get("title", consequence_id)))
			if not falls.is_empty():
				lines.append("- **Se il tavolo la respinge:** %s" % " · ".join(PackedStringArray(falls)))
			for pair in [["benefits", "benefici"], ["costs", "costi"]]:
				var mine: Array = []
				for voice in (physical.get(str(pair[0]), []) as Array):
					if ((voice as Dictionary).get("for", []) as Array).has(str(question.get("id", ""))):
						mine.append(str((voice as Dictionary).get("text", "")))
				lines.append("- **%s che puo' sostenere (%d):** %s" % [
					str(pair[1]).capitalize(), mine.size(), " · ".join(PackedStringArray(mine)),
				])
			lines.append("")


	lines.append("---")
	lines.append("")
	lines.append("*%d carte, %d domande.*" % [ids.size(), questions])
	lines.append("")

	# **Il ponte per il disegno del flusso.**
	#
	# Quale Consiglio serve quale carta lo decide `_council_base_for`: quello
	# scritto per lei, altrimenti quello del suo dominio, e da li' vengono le
	# clausole e i sacchetti delle Conseguenze. Il grafo di `flusso.html` ha
	# bisogno di saperlo, e Python quella regola non la puo' leggere: la
	# ricopierebbe, ed e' la trappola gia' pagata cinque volte in questo
	# progetto.
	#
	# Quindi la scrive qui **chi la esegue**, una riga per carta, in un blocco
	# che il lettore non vede e che il cancello sorveglia come tutto il resto.
	# E' lo stesso ponte con cui `build_flow` legge i nomi delle caselle da
	# `MISURA_CASELLE.md` (D-368).
	lines.append("<!-- PONTE — quale Consiglio serve quale carta, letto chiamando")
	lines.append("     `DataSet.confluence_template_for`. Lo legge tools/build_flow.py. -->")
	lines.append("<!--")
	for tension_id in ids:
		var base: Dictionary = data.confluence_template_for(str(tension_id))
		if base.is_empty():
			continue
		lines.append("CONSIGLIO %s = %s" % [str(tension_id), str(base.get("id", ""))])
	lines.append("-->")
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
	print("scritto %s — %d carte, %d domande" % [out, ids.size(), questions])
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
