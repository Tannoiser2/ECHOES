extends "res://tests/test_case.gd"
## La pagina delle regole, dentro il gioco (D-041, D-194).
##
## In cima a `help_panel.gd` c'e' scritto da sempre: *«una pagina di regole che
## puo' sfasarsi dalle regole e' peggio di niente»*. Per tre versioni quella
## pagina ha promesso un ACQUISIRE che non esisteva piu' e un TRAMARE che leggeva
## il numero invece della soglia — perche' quell'elenco era battuto a macchina
## mentre il resto della pagina si scriveva dai dati.
##
## Questi test guardano la pagina **dai due lati dell'interruttore**: e' la sola
## cosa che tenga la prosa attaccata alle regole.

const HelpPanel := preload("res://ui/help_panel.gd")


func before_each() -> void:
	new_session()


func _page(rules: Dictionary) -> String:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	var before: Dictionary = {}
	for key in rules:
		before[key] = chronicle.get(str(key))
		chronicle[str(key)] = rules[key]
	# La pagina e' un nodo, non un oggetto contato: si costruisce, le si chiede
	# il testo e la si libera a mano — `_ready()` qui non gira mai.
	var panel: Node = HelpPanel.new()
	var lines: Array = panel.call("_lines", session.data, "CHR_01")
	panel.free()
	for key in before:
		if before[key] == null:
			chronicle.erase(str(key))
		else:
			chronicle[str(key)] = before[key]
	return "\n".join(PackedStringArray(lines))


## Col §10 di sempre la pagina descrive le sei azioni, ACQUISIRE compreso.
func test_the_classic_page_still_teaches_the_six_actions() -> void:
	var page: String = _page({"actions_from_cards": false})
	assert_true(page.contains("SEI COSE"), "il titolo parla di sei azioni")
	assert_true(page.contains("Acquisire"), "e ACQUISIRE c'e")


## Col gioco a carte **non deve promettere ACQUISIRE**, che il resolver rifiuta.
## E' la bugia che il committente ha visto sull'app.
func test_with_cards_the_page_never_promises_acquire() -> void:
	var page: String = _page({
		"actions_from_cards": true,
		"hand_refill": {"per_token": 2, "hand_cap": 7},
	})
	assert_false(page.contains("Acquisire"), "col gioco a carte ACQUISIRE non si offre")
	assert_true(page.contains("CARTA CALATA"), "il titolo dice come si agisce adesso")
	assert_true(
		page.contains("non votera piu"),
		"e spiega la spesa, che e il cuore del gioco nuovo"
	)
	assert_true(page.contains("la mappa"), "e dice che le carte le da la mappa")


## E il velo: cosa TRAMARE fa vedere dipende da cosa il velo copre (D-187).
func test_the_page_says_what_scouting_actually_reveals() -> void:
	var covered: String = _page({"veiled_tensions": "HIDES_THRESHOLD"})
	assert_true(
		covered.contains("a quanto esplode"),
		"col velo sulla soglia, TRAMARE legge la soglia"
	)
	var classic: String = _page({"veiled_tensions": "HIDES_ALL"})
	assert_true(
		classic.contains("leggi il numero"),
		"col velo sul numero, TRAMARE legge il numero"
	)


## E la presa di parola in un colpo, quando la Chronicle la concede (D-191).
func test_the_page_says_when_the_word_is_taken_in_one_move() -> void:
	var page: String = _page({
		"claim_rules": {"same_round_when_ready": true, "ready_at": 3}
	})
	assert_true(
		page.contains("apri tu il Consiglio, adesso"),
		"la pagina spiega che una domanda matura si prende in un colpo"
	)
