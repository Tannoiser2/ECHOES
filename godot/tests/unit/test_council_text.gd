extends "res://tests/test_case.gd"
## Un Consiglio, in parole che una persona legge (D-232).
##
## Le domande, le clausole e le Conseguenze vivono nei dati scritte con dei buchi —
## `$proponent`, `$region_focus`, `$rival` — che al tavolo li riempie la partita.
## Fuori dal tavolo non si possono riempire e non si devono: **si spiegano**.
##
## Queste prove tengono la stessa regola di D-224, D-228 e D-229, applicata al
## Consiglio: **niente di quello che arriva a una persona parla in tecnico.**
## Nessun `$` rimasto, nessun tipo di Effetto in maiuscolo, nessun id.

const CouncilText := preload("res://scripts/core/council_text.gd")
const AssetText := preload("res://scripts/core/asset_text.gd")


## Nessuna frase che una persona legge porta ancora un buco. Un `$rival` su una
## scheda stampata non e' un nome mancante: e' una riga che nessuno sa leggere.
##
## A due domande (D-467, D-472) quello che si legge sulla carta girata sono
## **le due domande** e quello che ognuna lascia se vince (`base`): si guarda
## quello. Le Proposte stampate (`propositions`) sono **un residuo**: nessun
## motore le legge piu', ma finche' stanno sulle carte le legge una persona,
## e il giro dopo le togliera' dai dati. Fino ad allora la riga vale anche
## per loro.
func test_no_sentence_still_carries_a_slot() -> void:
	var loaded: RefCounted = data()
	var questions: int = 0
	var propositions: int = 0
	for tension_id in loaded.tensions:
		var template: Dictionary = loaded.confluence_template_for(str(tension_id))
		for entry in template.get("questions", []):
			var question: Dictionary = entry as Dictionary
			var said: String = CouncilText.speak(str(question["text"]))
			assert_false(
				said.contains("$"),
				"«%s» porta ancora un buco: %s" % [str(question["id"]), said]
			)
			for need in CouncilText.needs_of(question.get("eligibility", []) as Array):
				assert_false(str(need).contains("$"), "e nemmeno le sue condizioni: %s" % str(need))
			for consequence_id in (question.get("base", []) as Array):
				var consequence: Variant = loaded.consequences.get(str(consequence_id))
				assert_true(consequence != null, "«%s» lascia una Conseguenza che esiste: %s" % [str(question["id"]), str(consequence_id)])
				if consequence == null:
					continue
				var leaves: String = CouncilText.consequence_note(consequence as Dictionary, loaded)
				assert_false(leaves.contains("$"), "e quello che lascia non porta buchi: %s" % leaves)
			questions += 1
		for entry in template.get("propositions", []):
			var said: Dictionary = CouncilText.proposition(
				template, str((entry as Dictionary)["id"]), loaded
			)
			for field in ["question", "text"]:
				assert_false(
					str(said[field]).contains("$"),
					"«%s» porta ancora un buco: %s" % [str((entry as Dictionary)["id"]), str(said[field])]
				)
			for need in said["needs"]:
				assert_false(str(need).contains("$"), "e nemmeno le sue condizioni")
			propositions += 1
	assert_true(questions >= 100, "e vale per ogni domanda della scatola: %d" % questions)
	assert_true(propositions >= 40, "e per ogni Proposta rimasta stampata: %d" % propositions)


## E nessuna Conseguenza racconta quello che lascia al mondo con un tipo di
## Effetto. **Cinque tipi su sedici erano scoperti** quando questo catalogo ha
## cominciato a leggerle: nessuna carta li usa, quindi non erano mai serviti.
func test_no_consequence_speaks_in_effect_types() -> void:
	var loaded: RefCounted = data()
	var checked: int = 0
	for consequence_id in loaded.consequences:
		var said: String = CouncilText.consequence_note(
			loaded.consequences[str(consequence_id)] as Dictionary, loaded
		)
		assert_false(
			said.contains("un effetto senza parole"),
			"«%s» lascia al mondo qualcosa che non sa dire: %s" % [str(consequence_id), said]
		)
		assert_false(said.contains("$"), "e non porta buchi: %s" % said)
		checked += 1
	assert_true(checked >= 40, "e vale per ogni Conseguenza: %d" % checked)


## E nessuna etichetta d'autore parla a me invece che a chi gioca. Ce n'era una
## che citava un verbale e una carta di Propp: scritta per lo sviluppatore, letta
## dal giocatore. Vale per le condizioni delle domande, e per quelle delle
## Proposte finche' restano stampate (residuo di D-280, da togliere).
func test_no_label_speaks_to_the_developer() -> void:
	var loaded: RefCounted = data()
	var labels: int = 0
	for tension_id in loaded.tensions:
		var template: Dictionary = loaded.confluence_template_for(str(tension_id))
		for list_name in ["questions", "propositions"]:
			for entry in template.get(list_name, []):
				for condition in (entry as Dictionary).get("eligibility", []):
					var label: String = str((condition as Dictionary).get("label", ""))
					if label == "":
						continue
					labels += 1
					assert_false(
						label.contains("(D-") or label.contains("ISSUES"),
						"«%s» nomina un verbale a chi sta giocando: %s"
						% [str((entry as Dictionary)["id"]), label]
					)
	assert_true(labels > 0, "nessuna condizione ha un'etichetta: la prova e' cieca")


## E una domanda dice **cosa lascia al mondo se vince** (D-469, D-472): e'
## il suo `base`, la meta' che un giocatore deve vedere prima di posare una
## pedina. La riga la scrive `consequence_note`, in parole e non in tipi.
func test_a_question_says_what_it_leaves_behind() -> void:
	var loaded: RefCounted = data()
	# La scheda fusa della carta, non il template crudo (D-462): le domande
	# stanno sulla carta, e il template porta solo quelle di ripiego.
	var template: Dictionary = loaded.confluence_template_for("TEN_AWAKENING")
	var seen: int = 0
	for entry in (template.get("questions", []) as Array):
		var question: Dictionary = entry as Dictionary
		assert_ne(CouncilText.speak(str(question["text"])), "", "la domanda si legge")
		var base: Array = question.get("base", []) as Array
		assert_true(base.size() >= 1, "«%s» dice cosa lascia al mondo se vince" % str(question["id"]))
		for consequence_id in base:
			var consequence: Dictionary = loaded.consequences[str(consequence_id)] as Dictionary
			var leaves: String = CouncilText.consequence_note(consequence, loaded)
			assert_ne(leaves, "", "con parole, non con tipi: %s" % str(consequence_id))
			assert_false(leaves.contains("$"), "e senza buchi: %s" % leaves)
		seen += 1
	assert_eq(seen, 2, "la carta ha due domande")


## --- e quello che arriva a chi sta scegliendo (D-233) -----------------------

const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ConfluenceBoard := preload("res://ui/confluence_board.gd")


## E la seconda riga si **vede** che e' lettera piccola.
##
## Una scelta del Consiglio e' disegnata come una carta: il titolo si legge da
## lontano, quello che costa quando la prendi in mano. Se domani qualcuno rimette
## tutto in un unico `Button.text`, la riga esiste ancora nei dati e sparisce
## dagli occhi — che e' esattamente il difetto che ISSUES 63 descrive.
func test_the_small_print_is_drawn_smaller() -> void:
	var board: Node = ConfluenceBoard.new()
	var card: Button = board._choice_card("Alziamo la torre\nSe passa: si alza una costruzione")
	var lines: Array = []
	for child in card.get_child(0).get_children():
		if child is Label:
			lines.append(child)
	assert_eq(lines.size(), 2, "due righe: quello che si dice e quello che resta")
	assert_eq(str((lines[0] as Label).text), "Alziamo la torre", "la prima e' la proposta")
	var big: int = (lines[0] as Label).get_theme_font_size("font_size")
	var small: int = (lines[1] as Label).get_theme_font_size("font_size")
	assert_true(small < big, "e la seconda e' piu' piccola: %d contro %d" % [small, big])
	assert_true(
		(lines[1] as Label).mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"e non ruba il clic al bottone che c'e' sotto"
	)
	card.free()
	board.free()


## Un io con le risposte in fila, che si ricorda cosa gli e' stato offerto.
class ScriptedIo extends RefCounted:
	var asks: Array = []

	func say(_text: String) -> void:
		pass

	func choose(_prompt: String, labels: Array, _subjects: Array = []) -> int:
		asks.append(labels.duplicate())
		return 0


## E il filo regge fino a chi sta seduto.
##
## Le prove sopra guardano la funzione che scrive la riga e il pezzo di
## schermo che la disegna. Restava scoperto il tratto in mezzo — che
## `SeatDecider` la chiami davvero — e un tratto scoperto in mezzo e' come non
## averlo fatto: e' il buco di [D-224](DECISIONS.md#d-224) ripetuto.
##
## A due domande (D-472) chi propone sceglie **la domanda**, non la proposta:
## quello che gli si offre sono le domande della carta, dette con i nomi
## veri della partita — niente buchi, niente id.
func test_the_seat_is_offered_the_questions_in_words() -> void:
	new_session()
	var context: Dictionary = session.confluence.open("TEN_FAMINE", {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio si apre")
	var seat: String = str(context["proponent"])
	var questions: Array = session.confluence.available_questions()
	assert_true(questions.size() >= 1, "la carta offre almeno una domanda")

	var io := ScriptedIo.new()
	var decider: RefCounted = SeatDecider.new([seat], null)
	decider.io = io
	var chosen: String = await decider.choose_question(context, questions, session)
	assert_eq(chosen, str((questions[0] as Dictionary)["id"]), "la scelta torna intera")
	assert_eq(io.asks.size(), 1, "e chi siede e' stato interrogato una volta")
	assert_eq((io.asks[0] as Array).size(), questions.size(), "con una riga per domanda")
	for label in (io.asks[0] as Array):
		assert_false(str(label).contains("$"), "ogni domanda offerta e' riempita: %s" % str(label))
		assert_false(str(label).begins_with("Q_"), "e non parla per id: %s" % str(label))
	session.confluence.current = {}



## **Una Cicatrice e' un segno in un posto, non una frase** (D-341).
##
## `consequence_note` chiudeva la riga con la `description` della Cicatrice —
## voce d'autore, *«Le piste dei carri incise nel terreno basso, e nessuno che
## le ripercorra»* — e taceva le due cose che al tavolo servono: **quale segno
## si posa e dove**. Sono tutti e due campi del dato, `tag` e `region_id`.
##
## La prova parte dai dati: prende ogni Conseguenza che lascia una Cicatrice e
## chiede che la riga dica il segno e il posto, e che la frase non ci sia.
func test_a_scar_is_a_sign_in_a_place() -> void:
	var loaded: RefCounted = data()
	var seen: int = 0
	for id in loaded.consequences:
		var consequence: Dictionary = loaded.consequences[str(id)]
		var scar: Dictionary = consequence.get("scar", {}) as Dictionary
		if scar.is_empty():
			continue
		seen += 1
		var line: String = CouncilText.consequence_note(consequence, loaded)
		var sign_word: String = AssetText.sign_word(str(scar["tag"]), loaded)
		assert_true(line.contains(sign_word),
			"%s: la Cicatrice non dice il suo segno (%s)" % [str(id), sign_word])
		assert_true(line.contains(AssetText.place_word(str(scar["region_id"]), loaded)),
			"%s: la Cicatrice non dice dove si posa" % str(id))
		var prose: String = str(scar.get("description", ""))
		if prose != "":
			assert_false(line.contains(prose),
				"%s: la Cicatrice stampa ancora la frase d'autore" % str(id))
	assert_true(seen > 0, "nessuna Conseguenza lascia una Cicatrice: la prova e cieca")
