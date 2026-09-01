extends SceneTree
## **Chi scrive nel mondo: la carta o la frase d'autore?** (taglio 2, ISSUES 80)
##
##   godot --headless --path godot --script res://cli/run_who_writes_probe.gd -- \
##       --runs=40 --seed=7000 --chronicle=CHR_00
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
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

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
	# **La differenza che ISSUES 88 chiede**: una Tensione che il tavolo non ha
	# mai girato tiene la sua domanda nel mazzetto coperto, e non e' un difetto —
	# e' rigiocabilita'. Una che il tavolo **ha girato** e la cui domanda non si
	# apre mai e' il difetto vecchio di D-035 con un vestito nuovo. Si distinguono
	# guardando il mazzetto prima e dopo: quello che manca alla fine e' stato
	# girato.
	var flipped: Dictionary = {}
	var hosted: Dictionary = {}
	var reshuffled: int = 0

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito al seme %d: %s" % [seed_value, session.last_error])
			quit(3)
			return
		# Il mazzetto com'e' stato distribuito, prima che qualcuno lo tocchi.
		var dealt: Dictionary = {}
		for theme_id in (session.world.get("theme_decks", {}) as Dictionary):
			dealt[str(theme_id)] = ((session.world["theme_decks"][str(theme_id)]) as Array).duplicate()
		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		councils += int(session.world["confluence_count"])
		for theme_id in dealt:
			var before: Array = dealt[str(theme_id)] as Array
			var after: Array = (session.world.get("theme_decks", {}) as Dictionary).get(str(theme_id), []) as Array
			for tension_id in before:
				if not after.has(tension_id):
					flipped[str(tension_id)] = true
			# Se alla fine nel mazzetto c'e' una carta che all'inizio non
			# c'era, i mazzetti sono stati rimontati e questo conto non vale:
			# meglio dirlo che dare un numero falso.
			for tension_id in after:
				if not before.has(tension_id):
					reshuffled += 1
		for result in (report.get("confluences", []) as Array):
			var record: Dictionary = result as Dictionary
			questions_asked[str(record.get("question_id", ""))] = true
			propositions_voted[str(record.get("proposition_id", ""))] = true
			hosted[str(record.get("tension_id", ""))] = true
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

	# **Il denominatore sono le carte, non i template** (0.1.273).
	#
	# Fino a 0.1.272 contava le domande e le proposte dei dodici template: 23 e
	# 49. Da D-310 la Domanda e la Proposta stanno **sulla carta**, e con
	# sessanta carte il conto vero e' un altro — la misura diceva "36 su 49"
	# mentre il tavolo ne aveva scritte 185. **Decima volta in questo progetto
	# che una misura ferma era la sonda.**
	var written_questions: Dictionary = {}
	var written_propositions: Dictionary = {}
	var proposition_question: Dictionary = {}
	for tension_id in data.tensions:
		var template: Dictionary = data.confluence_template_for(str(tension_id))
		if template.is_empty():
			continue
		for question in (template.get("questions", []) as Array):
			written_questions[str((question as Dictionary)["id"])] = str(tension_id)
		for proposition in (template.get("propositions", []) as Array):
			written_propositions[str((proposition as Dictionary)["id"])] = str(tension_id)
			# Una proposta si vota **dentro** la sua domanda: se la domanda non
			# e' mai stata posta, la proposta non e' stata scartata — non e'
			# proprio arrivata sul tavolo. Senza questo passaggio il conto
			# chiamerebbe difetto l'aritmetica del Consiglio.
			proposition_question[str((proposition as Dictionary)["id"])] = str(
				(proposition as Dictionary).get("question_id", "")
			)

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
	print("")
	print("  == E DOVE FINISCE QUELLO CHE NON VEDE == (ISSUES 88)")
	print("")
	print("    Tensioni girate            %d su %d scritte" % [flipped.size(), data.tensions.size()])
	print("    Tensioni arrivate a un Consiglio  %d" % hosted.size())
	var never_debated_tensions: Array = []
	for tension_id in data.tensions:
		if not hosted.has(str(tension_id)):
			never_debated_tensions.append(str(tension_id))
	never_debated_tensions.sort()
	if not never_debated_tensions.is_empty():
		print("      mai in discussione: %s" % ", ".join(never_debated_tensions))
	if reshuffled > 0:
		print("    ATTENZIONE: i mazzetti sono stati rimontati %d volte, il conto sotto non vale" % reshuffled)
	_split("domande", written_questions, questions_asked, flipped, hosted, {}, {})
	_split(
		"proposte", written_propositions, propositions_voted, flipped, hosted,
		proposition_question, questions_asked
	)
	print("")
	print("    La prima riga e' rigiocabilita': carte che il mazzetto non ha girato.")
	print("    La seconda e' aritmetica: %d Consigli in %d anni, e ognuno apre" % [councils, runs])
	print("      una domanda sola — il mazzetto gira piu' di quanto il tavolo discuta.")
	print("    **La terza e' il difetto di D-035**: la Tensione e' arrivata al")
	print("      Consiglio, e quella voce non e' stata scelta lo stesso.")
	quit(0)


## Quello che non si e' visto, diviso in tre. La prima e' rigiocabilita', la
## seconda e' l'aritmetica dei Consigli, e **solo la terza e' un difetto**.
static func _split(
	what: String, written: Dictionary, used: Dictionary,
	flipped: Dictionary, hosted: Dictionary,
	via: Dictionary, via_used: Dictionary
) -> void:
	var never_drawn: int = 0
	var never_debated: int = 0
	var debated_never_chosen: int = 0
	var used_unseen: int = 0
	var silent: Array = []
	for id in written:
		var owner: String = str(written[str(id)])
		var seen: bool = flipped.has(owner) or hosted.has(owner)
		if used.has(str(id)):
			if not seen:
				used_unseen += 1
			continue
		# La porta stretta: per una proposta la domanda dev'essere stata posta.
		var debated: bool = hosted.has(owner)
		if debated and not via.is_empty():
			debated = via_used.has(str(via.get(str(id), "")))
		if debated:
			debated_never_chosen += 1
			silent.append(str(id))
		elif seen:
			never_debated += 1
		else:
			never_drawn += 1
	var total: int = maxi(1, written.size())
	print("")
	print("    %s: %d scritte, %d usate" % [what, written.size(), used.size()])
	print("      1. mai pescate                    %4d  (%.0f%%)" % [
		never_drawn, 100.0 * float(never_drawn) / float(total)
	])
	print("      2. pescate, mai in discussione    %4d  (%.0f%%)" % [
		never_debated, 100.0 * float(never_debated) / float(total)
	])
	print("      3. in discussione, mai scelte     %4d  (%.0f%%)" % [
		debated_never_chosen, 100.0 * float(debated_never_chosen) / float(total)
	])
	if used_unseen > 0:
		print("      usate senza essere girate %d  (una Tensione dell'apertura)" % used_unseen)
	# **Il numero da solo non si puo' lavorare**: per togliere una voce muta
	# bisogna sapere quale. Il difetto vero e' un elenco, non una percentuale.
	if not silent.is_empty():
		silent.sort()
		print("      le mute:")
		for id in silent:
			print("        %s" % str(id))


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
