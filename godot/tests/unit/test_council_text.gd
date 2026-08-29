extends "res://tests/test_case.gd"
## Un Consiglio, in parole che una persona legge (D-232).
##
## Le domande, le proposte e le clausole vivono nei dati scritte con dei buchi —
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
func test_no_sentence_still_carries_a_slot() -> void:
	var loaded: RefCounted = data()
	var checked: int = 0
	for template_id in loaded.confluence_templates:
		var template: Dictionary = loaded.confluence_templates[str(template_id)] as Dictionary
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
			checked += 1
		for clause in CouncilText.clauses(template, loaded):
			assert_false(
				str((clause as Dictionary)["text"]).contains("$"),
				"e nemmeno le clausole: %s" % str((clause as Dictionary)["text"])
			)
	assert_true(checked >= 40, "e vale per ogni proposta della scatola: %d" % checked)


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
## dal giocatore.
func test_no_label_speaks_to_the_developer() -> void:
	var loaded: RefCounted = data()
	for template_id in loaded.confluence_templates:
		var template: Dictionary = loaded.confluence_templates[str(template_id)] as Dictionary
		for entry in template.get("propositions", []):
			for condition in (entry as Dictionary).get("eligibility", []):
				var label: String = str((condition as Dictionary).get("label", ""))
				assert_false(
					label.contains("(D-") or label.contains("ISSUES"),
					"«%s» nomina un verbale a chi sta giocando: %s"
					% [str((entry as Dictionary)["id"]), label]
				)


## E una proposta dice **cosa lascia al mondo se passa**: e' la meta' che un
## giocatore deve vedere prima di votare, e che sullo schermo di oggi non c'e'.
func test_a_proposition_says_what_it_leaves_behind() -> void:
	var loaded: RefCounted = data()
	var template: Dictionary = loaded.confluence_templates["CNF_AWAKENING_01"] as Dictionary
	var said: Dictionary = CouncilText.proposition(template, "P_EXPLOIT", loaded)
	assert_ne(str(said.get("text", "")), "", "la proposta si legge")
	assert_true(
		(said["consequences"] as Array).size() >= 1,
		"e dice cosa lascia al mondo se passa"
	)
	var first: Dictionary = (said["consequences"] as Array)[0] as Dictionary
	assert_ne(str(first["leaves"]), "", "con parole, non con tipi: %s" % str(first["leaves"]))


## --- e quello che arriva a chi sta scegliendo (D-233) -----------------------

const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ConfluenceBoard := preload("res://ui/confluence_board.gd")


## **La decisione centrale del gioco si prendeva al buio.**
##
## Chi propone sceglie fra tre o quattro frasi d'autore. Cosa scrivevano sul
## mondo — una torre, una cicatrice, una Regione che cambia padrone — stava in
## `success_consequences`, cioe' in un file che chi gioca non apre. Le frasi sono
## belle e si somigliano; quello che lasciano dietro no.
##
## Adesso l'etichetta porta la seconda riga, e questa prova la tiene per **ogni**
## proposta della scatola: o dice cosa resta, o dichiara che non resta niente.
## Il silenzio non e' una terza possibilita': si legge come «non lo so».
func test_a_proposition_offered_says_what_it_leaves() -> void:
	var loaded: RefCounted = data()
	var said_nothing: int = 0
	var checked: int = 0
	for template_id in loaded.confluence_templates:
		var template: Dictionary = loaded.confluence_templates[str(template_id)] as Dictionary
		for entry in template.get("propositions", []):
			var said: Dictionary = CouncilText.proposition(
				template, str((entry as Dictionary)["id"]), loaded
			)
			var label: String = SeatDecider._proposition_label(said, str((entry as Dictionary)["text"]))
			var parts: PackedStringArray = label.split("\n", false)
			assert_true(
				parts.size() >= 2,
				"«%s» arriva a chi sceglie senza dire cosa lascia" % str((entry as Dictionary)["id"])
			)
			var small: String = str(parts[1])
			assert_true(
				small.begins_with("Se passa: ") or small == "Non lascia segni sul mondo.",
				"e lo dice in un modo solo: %s" % small
			)
			assert_false(small.contains("$"), "senza buchi: %s" % small)
			assert_false(small.contains("_"), "e senza id: %s" % small)
			if small != "Non lascia segni sul mondo.":
				assert_true(small.length() > 12, "e con qualcosa dentro: %s" % small)
			else:
				said_nothing += 1
			checked += 1
	assert_true(checked >= 40, "per ogni proposta della scatola: %d" % checked)
	# Un numero scritto vale piu' di un numero nascosto: se domani meta' delle
	# proposte non lascia piu' niente, questo non e' un dettaglio d'interfaccia.
	assert_true(
		said_nothing <= checked / 4,
		"e la maggioranza lascia davvero qualcosa: %d su %d non lasciano niente" % [
			said_nothing, checked,
		]
	)


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
## Le due prove sopra guardano la funzione che scrive la riga e il pezzo di
## schermo che la disegna. Restava scoperto il tratto in mezzo — che
## `SeatDecider` la chiami davvero — e un tratto scoperto in mezzo e' come non
## averlo fatto: e' il buco di [D-224](DECISIONS.md#d-224) ripetuto.
func test_the_seat_is_offered_what_it_leaves() -> void:
	new_session()
	var seat: String = str(session.world["turn_order"][0])
	var template_id: String = ""
	for candidate in session.data.confluence_templates:
		template_id = str(candidate)
		break
	var template: Dictionary = session.data.confluence_templates[template_id] as Dictionary

	var io := ScriptedIo.new()
	var decider: RefCounted = SeatDecider.new([seat], null)
	decider.io = io
	var chosen: String = await decider.choose_proposition(
		{"template_id": template_id, "proponent": seat, "tension_id": str(template["tension_id"])},
		template["propositions"],
		session
	)
	assert_eq(chosen, str((template["propositions"][0] as Dictionary)["id"]), "la scelta torna intera")
	assert_eq(io.asks.size(), 1, "e chi siede e' stato interrogato una volta")
	for label in (io.asks[0] as Array):
		var parts: PackedStringArray = str(label).split("\n", false)
		assert_true(parts.size() >= 2, "ogni proposta offerta porta la sua seconda riga: %s" % str(label))
		assert_true(
			str(parts[1]).begins_with("Se passa: ")
			or str(parts[1]) == "Non lascia segni sul mondo.",
			"che dice cosa resta al mondo: %s" % str(parts[1])
		)



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
