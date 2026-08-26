extends SceneTree
## **Chi scrive nel mondo: la carta o la frase d'autore?** (taglio 2, ISSUES 80)
##
##   godot --headless --path godot --script res://cli/run_who_writes_probe.gd -- \
##       --runs=40 --seed=7000 --chronicle=CHR_01
##
## Un Consiglio che passa lascia due cose sul mondo, da due grammatiche diverse:
##
## - le **Conseguenze della proposta** — `success_consequences` sulla frase
##   d'autore scelta dal proponente, la grammatica della specifica v0.2;
## - i **benefici e i costi della carta** — l'economia di D-280, quella che si
##   legge sulla Tensione girata.
##
## Il taglio 2 propone di cancellare la prima. Prima di cancellare si conta:
## quante volte parla l'una e quante l'altra, **e quanti Effetti scrive
## ognuna**. Se le Conseguenze scrivono la meta' del mondo, cancellarle e'
## svuotare il gioco; se ripetono quello che la carta fa gia', e' togliere un
## doppione. La differenza fra le due cose e' un numero, non un'opinione.
##
## Si conta anche **quanta di quella roba d'autore il tavolo vede davvero**:
## proposte diverse votate su proposte scritte, domande diverse poste su
## domande scritte. Contenuto che esiste nei dati e non esiste al tavolo e' la
## lezione di D-035.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

## Le testate dei blocchi che scrivono, e come chiamarle nel resoconto.
const BLOCKS: Dictionary = {
	"H. Conseguenza - ": "la frase d'autore",
	"H. Beneficio: ": "la carta: benefici",
	"H. Prezzo: ": "la carta: prezzi",
	"H. Il mondo non aspetta: ": "la carta: se cade",
	"H. Clausola qualificata: ": "la clausola",
	"H. La carta parla - ": "gli Asset impegnati",
}


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var spoke: Dictionary = {}    # blocco -> quante volte ha parlato
	var wrote: Dictionary = {}    # blocco -> quanti Effetti ha narrato
	var councils: int = 0
	var questions_asked: Dictionary = {}
	var propositions_voted: Dictionary = {}

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito al seme %d: %s" % [seed_value, session.last_error])
			quit(3)
			return
		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		councils += int(session.world["confluence_count"])
		for result in (report.get("confluences", []) as Array):
			var record: Dictionary = result as Dictionary
			questions_asked[str(record.get("question_id", ""))] = true
			propositions_voted[str(record.get("proposition_id", ""))] = true
		# Le righe narrate stanno **sotto** la testata del loro blocco: si
		# cammina il registro in ordine e si tiene a mente chi sta parlando.
		var speaking: String = ""
		for line in session.log.lines:
			# Il registro incolonna: «  - H. Beneficio: ...» per una voce, e
			# «  -   il mondo ricorda...» per un Effetto narrato sotto di lei.
			# **Senza togliere il trattino la sonda non vede niente**, e lo si
			# scopre solo perche' un conto a zero in questo progetto e' sempre
			# la sonda finche' non si prova il contrario.
			var text: String = str(line).strip_edges()
			if text.begins_with("- "):
				text = text.substr(2).strip_edges()
			var opened: String = ""
			for head in BLOCKS:
				if text.begins_with(str(head)):
					opened = str(head)
			if opened != "":
				speaking = opened
				spoke[opened] = int(spoke.get(opened, 0)) + 1
				continue
			# Una riga che comincia con la lettera di un passo chiude il blocco.
			if text.length() > 2 and text[1] == "." and text[0] in "ABCDEFGHIJK":
				speaking = ""
				continue
			if speaking != "" and text != "":
				wrote[speaking] = int(wrote.get(speaking, 0)) + 1
		session.dispose()

	var written_questions: Dictionary = {}
	var written_propositions: Dictionary = {}
	for template_id in data.confluence_templates:
		var template: Dictionary = data.confluence_templates[str(template_id)] as Dictionary
		for question in (template.get("questions", []) as Array):
			written_questions[str((question as Dictionary)["id"])] = true
		for proposition in (template.get("propositions", []) as Array):
			written_propositions[str((proposition as Dictionary)["id"])] = true

	print("")
	print("== CHI SCRIVE NEL MONDO - %d anni di %s, semi da %d ==" % [runs, chronicle_id, first_seed])
	print("")
	print("  Consigli  %d" % councils)
	print("")
	print("  %-24s %8s %10s" % ["chi parla", "volte", "Effetti"])
	for head in BLOCKS:
		print("  %-24s %8d %10d" % [
			str(BLOCKS[head]), int(spoke.get(str(head), 0)), int(wrote.get(str(head), 0))
		])
	var authored: int = int(wrote.get("H. Conseguenza - ", 0))
	var from_card: int = (
		int(wrote.get("H. Beneficio: ", 0))
		+ int(wrote.get("H. Prezzo: ", 0))
		+ int(wrote.get("H. Il mondo non aspetta: ", 0))
	)
	var total: int = maxi(1, authored + from_card)
	print("")
	print("  La frase d'autore scrive  %d  (%.0f%%)" % [
		authored, 100.0 * float(authored) / float(total)
	])
	print("  La carta scrive           %d  (%.0f%%)" % [
		from_card, 100.0 * float(from_card) / float(total)
	])
	print("")
	print("  Quanto contenuto d'autore il tavolo vede:")
	print("    domande poste     %d su %d scritte" % [
		questions_asked.size(), written_questions.size()
	])
	print("    proposte votate   %d su %d scritte" % [
		propositions_voted.size(), written_propositions.size()
	])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
