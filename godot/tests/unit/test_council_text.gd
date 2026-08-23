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
