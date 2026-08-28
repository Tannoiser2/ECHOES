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
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	var before: Dictionary = {}
	for key in rules:
		before[key] = chronicle.get(str(key))
		chronicle[str(key)] = rules[key]
	# La pagina e' un nodo, non un oggetto contato: si costruisce, le si chiede
	# il testo e la si libera a mano — `_ready()` qui non gira mai.
	var panel: Node = HelpPanel.new()
	var lines: Array = panel.call("_lines", session.data, "CHR_TEST")
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
	assert_true(
		page.contains("NON SI SCEGLIE UN'AZIONE"),
		"il titolo dice che le azioni non si scelgono piu"
	)
	assert_true(
		page.contains("la tua mano"),
		"e che al posto della lista c'e la mano"
	)
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
		page.contains("il Consiglio lo apri tu"),
		"la pagina spiega che una domanda matura si prende in un colpo"
	)


## E i mestieri delle famiglie si **contano dalle carte**: se domani una carta
## cambia mestiere, la pagina cambia con lei senza che nessuno la riscriva.
func test_the_page_counts_the_families_from_the_cards() -> void:
	var page: String = _page({"actions_from_cards": true})
	assert_true(page.contains("COSA SANNO FARE LE FAMIGLIE"), "c'e la tabella dei mestieri")
	# Il conto vero, letto dagli stessi dati che legge la pagina.
	var influencing: int = 0
	for asset_id in session.data.assets:
		var card: Dictionary = session.data.assets[str(asset_id)] as Dictionary
		var action: Dictionary = card.get("card_action", {}) as Dictionary
		if str(card["family"]) == "FORCE" and str(action.get("kind", "")) == "MOVE":
			influencing += 1
	assert_true(influencing > 0, "la FORZA sa muovere, e sono i dati a dirlo")
	assert_true(
		page.contains("%d muovere" % influencing),
		"e la pagina scrive quel numero, non uno battuto a macchina"
	)


## Con gli obiettivi accesi la pagina non puo' parlare di tre gradini (D-198).
##
## E questo test esiste per una ragione precisa: la prima stesura di quel
## paragrafo aveva un errore di precedenza fra `+` e `%` che mandava in errore
## la formattazione a ogni apertura della pagina — e la suite era **verde**,
## perche' nessuno leggeva quel testo. E' §5ter alla lettera: nessuna misura
## copre quello che una persona vede, se non si guarda quello che vede.
func test_with_objectives_the_page_counts_instead_of_climbing() -> void:
	var page: String = _page({
		"objectives": {
			"hidden": 3,
			"public_from": "victory",
			"levels": ["NONE", "MINIMUM", "VICTORY", "VICTORY", "TRIUMPH"],
		}
	})
	assert_true(
		page.contains("NON SI SALE UNA SCALA"),
		"il titolo dice che la scala non c'e piu"
	)
	assert_true(page.contains("palese"), "la pagina distingue il palese")
	assert_true(page.contains("coperti"), "e i coperti")
	assert_true(page.contains("3 [b]coperti[/b]"), "e dice quanti se ne pescano")
	assert_true(page.contains("Tutti e 4 e un trionfo"), "e cosa vuol dire prenderli tutti")
	assert_false(
		page.contains("Destino[/b] a tre gradini"),
		"e non promette piu la scala di prima"
	)


## Il numero degli obiettivi condivisi lo dice il pool, non una riga battuta a
## macchina: se domani ne scrivo quindici, la pagina lo dice da sola.
func test_the_page_counts_the_pool_from_the_data() -> void:
	var page: String = _page({
		"objectives": {
			"hidden": 3,
			"public_from": "victory",
			"levels": ["NONE", "MINIMUM", "VICTORY", "VICTORY", "TRIUMPH"],
		}
	})
	assert_true(
		page.contains("%d obiettivi condivisi" % session.data.objectives.size()),
		"la pagina conta il pool vero (%d)" % session.data.objectives.size()
	)


## E senza la regola, la pagina resta quella di sempre.
func test_without_objectives_the_page_still_teaches_the_ladder() -> void:
	var page: String = _page({"objectives": {}})
	assert_true(
		page.contains("Destino[/b] a tre gradini"),
		"senza obiettivi si sale ancora la scala"
	)
	assert_false(page.contains("NON SI SALE UNA SCALA"), "e non si parla di conti")


## Col cancello del tavolo la pagina non può promettere una soglia per domanda
## (D-203): quel numero non apre più niente, e farlo aspettare è la stessa
## bugia delle sei azioni promesse quando le azioni erano già le carte.
func test_with_the_table_gate_the_page_stops_promising_a_threshold() -> void:
	var page: String = _page({
		"tension_tokens": {"per_action": 1, "replaces_drift": true, "table_gate": 3}
	})
	assert_true(
		page.contains("NON C'È UNA SOGLIA PER DOMANDA"),
		"il titolo dice che la soglia per domanda non c'è"
	)
	assert_true(page.contains("3 gettoni"), "e dice quanti gettoni apre il Consiglio")
	assert_true(page.contains("mucchio più alto"), "e chi si dibatte")
	assert_false(page.contains("— soglia "), "e nessuna domanda porta più un numero da aspettare")
	# **Quale** presa di parola dipende da `claim_rules`, non dal cancello. Questa
	# riga chiedeva la presa immediata mentre la prova non la dichiarava, e
	# passava soltanto perche' la nota stava annidata dentro il cancello e usciva
	# comunque: la pagina prometteva a chiunque una regola di qualcun altro.
	assert_true(
		page.contains("Consiglio lo puoi chiamare anche tu"),
		"e dice che un Consiglio lo può aprire anche un giocatore"
	)
	assert_false(
		page.contains("rivendicazione matura"),
		"ma non la presa immediata, che questa Chronicle non dichiara"
	)


## E col Consiglio di chiusura (D-214) non c'e' nemmeno il cancello: il tavolo
## si siede a fine Atto, e il minimo di Consigli dell'anno smette di essere
## un'incognita.
func test_with_the_closing_council_the_page_promises_the_end_of_the_act() -> void:
	var page: String = _page({
		# Coi gettoni accesi si gioca a carte: il paragrafo su **chi** scalda le
		# domande sta di la' dall'interruttore, e chiederlo al lato classico
		# vorrebbe dire misurare un gioco che nessuno gioca.
		"actions_from_cards": true,
		"confluence_rules": {"at_end_of_act": true},
		"tension_tokens": {"per_action": 1, "replaces_drift": true},
	})
	assert_true(
		page.contains("IL CONSIGLIO SI TIENE ALLA FINE DI OGNI ATTO"),
		"il titolo dice quando il tavolo si siede"
	)
	assert_true(page.contains("almeno 3 Consigli"), "e quanti ne garantisce l'anno")
	assert_false(page.contains("— soglia "), "e nessuna domanda porta un numero da aspettare")
	assert_false(page.contains("gettoni[/b] si apre"), "e il cancello del tavolo non c'e piu")
	assert_true(
		page.contains("Non è il tempo a scaldarle: siete voi"),
		"e a scaldare le domande sono i giocatori"
	)
	assert_false(page.contains("Salgono da sole"), "quindi non salgono da sole")


## Senza il cancello la pagina resta quella di sempre, soglie comprese.
func test_without_the_table_gate_the_page_still_teaches_the_thresholds() -> void:
	var page: String = _page({"tension_tokens": {}})
	assert_true(page.contains("— soglia "), "senza cancello le soglie si leggono")
	assert_false(page.contains("NON C'È UNA SOGLIA PER DOMANDA"), "e non si parla di gettoni")
