extends "res://tests/test_case.gd"
## La pagina delle regole non può parlare di una regola che i dati non hanno.
##
## §5ter dice che **nessuna misura copre quello che una persona vede**, e questo
## è il buco per cui il cancello resta verde mentre il testo mente: il cancello
## gioca solo con `PolicyDecider`, che la pagina d'aiuto non la apre mai. È
## successo davvero. D-214 ha tolto `table_gate` dai dati; la sezione dei
## Consigli era appesa a quella chiave, il ramo giusto ha smesso di prendersi, e
## per tre commit la pagina ha detto a un giocatore che le domande salgono da
## sole e che un numero apre un Consiglio. Cento semi verdi, 0/8 sedie bloccate,
## e intanto la prosa raccontava il gioco di due versioni prima.
##
## Il rimedio non è rileggere il testo ogni tanto: è **misurarlo**. Questa suite
## rende la pagina sui dati **spediti**, per ogni Chronicle nella scatola, e la
## confronta con una tabella di clausole. Ogni clausola lega una dichiarazione
## alle parole che le appartengono, e la lega **nei due sensi**:
##
##   · se la regola è dichiarata, le sue parole devono esserci;
##   · se non lo è, le sue parole non possono esserci — e devono esserci quelle
##     del gioco di prima.
##
## Il secondo senso non si prova a parole: si prova **togliendo la
## dichiarazione** e ridisegnando la pagina. Così ogni clausola è provata da
## tutti e due i lati a ogni esecuzione, e nessuno dei due si atrofizza.
##
## È l'idioma del progetto applicato alla prosa: **una dichiarazione vuota vuol
## dire assenza**, quindi la pagina non deve parlare di quello che non è
## dichiarato. Una regola che sparisce dai dati porta via con sé la sua frase, e
## una regola che arriva nei dati non può restare senza.

const HelpPanel := preload("res://ui/help_panel.gd")
const GameScreen := preload("res://ui/game_screen.gd")

## Una dichiarazione, e le parole che le appartengono.
##
##   `path`  — dove sta scritta nella Chronicle (`chiave` o `chiave.sottochiave`)
##   `says`  — frasi che la pagina scrive **solo** quando la regola c'è
##   `else`  — frasi del gioco di prima, che valgono **solo** quando non c'è
##
## Le due liste sono esclusive per costruzione: è così che la pagina non può
## contraddirsi da sola, che è esattamente quello che faceva — «ogni cosa che
## fai scalda il mondo» tre paragrafi sopra «salgono da sole ogni round».
const CLAUSES: Array = [
	{
		"path": "entity_pool",
		"why": "il tavolo si pesca a inizio saga (D-213)",
		"says": ["si pescano a inizio saga"],
		"else": ["sedute allo stesso tavolo: "],
	},
	{
		"path": "tension_pool",
		"why": "le domande si pescano dalla biblioteca (D-207)",
		"says": ["LE DOMANDE POSSIBILI"],
		"else": ["LE DOMANDE DI QUEST'ANNO"],
	},
	{
		"path": "confluence_rules.at_end_of_act",
		"why": "il Consiglio si tiene a fine Atto, non a una soglia (D-214)",
		"says": ["IL CONSIGLIO SI TIENE ALLA FINE DI OGNI ATTO", "mucchio più alto"],
		"else": ["arriva alla sua soglia si apre", "— soglia "],
	},
	{
		"path": "tension_tokens.replaces_drift",
		"why": "le domande le scaldano i giocatori, non l'orologio (D-192)",
		"says": ["Non è il tempo a scaldarle: siete voi"],
		"else": ["il tempo le scalda per conto suo"],
	},
	{
		"path": "tension_tokens.covered",
		"why": "i mucchi sono coperti: si vede quanti, non quanto pesano",
		"says": ["I MUCCHI SONO COPERTI"],
		"else": [],
	},
	{
		"path": "hand_refill",
		"why": "le carte le dà la mappa, non ACQUISIRE (D-184)",
		"says": ["Le carte te le dà la mappa"],
		"else": ["Le carte si pescano con ACQUISIRE"],
	},
	{
		"path": "hand_refill.per_control",
		"why": "tenere una Regione paga una carta (D-220)",
		"says": ["per ogni Regione che controlli"],
		"else": [],
	},
	{
		"path": "claim_rules.same_round_when_ready",
		"why": "una domanda matura si prende in un colpo (D-191)",
		"says": ["il Consiglio lo apri tu"],
		"else": [],
	},
	{
		"path": "presence_tokens",
		"why": "le pedine hanno un tetto, e vale anche per il mondo (D-223)",
		"says": ["è il tetto[/b], non una dotazione"],
		"else": [],
	},
	{
		"path": "objectives",
		"why": "si contano gli obiettivi, non si sale una scala (D-198)",
		"says": ["NON SI SALE UNA SCALA"],
		"else": ["Destino[/b] a tre gradini"],
	},
]


## Ogni Chronicle spedita, letta com'è: niente `new_session()`, che spegne mezza
## economia per far girare le prove unitarie. Qui si misura **quello che una
## persona apre**, e una persona apre i dati della scatola.
func test_every_shipped_chronicle_reads_true() -> void:
	for chronicle_id in _chronicles():
		var page: String = _page(chronicle_id)
		assert_true(page.length() > 500, "%s: la pagina si disegna" % chronicle_id)
		for clause in CLAUSES:
			_check(chronicle_id, page, clause as Dictionary, _declares(chronicle_id, str(clause["path"])))


## E l'altro lato di ogni clausola, tolta la dichiarazione dalla Chronicle.
##
## Senza questo, metà tabella non verrebbe mai provata: i dati spediti
## dichiarano quasi tutto, quindi il ramo «la regola non c'è» resterebbe prosa
## non misurata — cioè il posto esatto dove il difetto si era annidato.
func test_taking_a_rule_away_takes_its_words_away() -> void:
	for clause in CLAUSES:
		var path: String = str((clause as Dictionary)["path"])
		if not _declares("CHR_TEST", path):
			continue
		var chronicle: Dictionary = data().chronicles["CHR_TEST"] as Dictionary
		var undo: Dictionary = _erase(chronicle, path)
		var page: String = _page("CHR_TEST")
		_restore(chronicle, undo)
		_check("CHR_01 senza %s" % path, page, clause as Dictionary, false)


## E i numeri che la pagina stampa sono quelli dichiarati, non quelli ricordati.
##
## È lo stesso difetto in un'altra forma: un numero battuto a macchina resta
## scritto anche quando il dato cambia, e chi legge aspetta una cosa che non
## succede più.
func test_the_numbers_on_the_page_are_the_numbers_in_the_data() -> void:
	for chronicle_id in _chronicles():
		var chronicle: Dictionary = data().chronicles[chronicle_id] as Dictionary
		var page: String = _page(chronicle_id)
		var acts: int = int(chronicle["acts"])
		var rounds: int = int(chronicle["rounds_per_act"])
		var opportunities: int = int(chronicle["action_opportunities_per_round"])
		assert_true(
			page.contains("%d Atti da %d round" % [acts, rounds]),
			"%s: la forma dell'anno è quella scritta" % chronicle_id
		)
		assert_true(
			page.contains("%d in tutto" % (acts * rounds * opportunities)),
			"%s: e il conto delle azioni si fa, non si ricorda" % chronicle_id
		)
		assert_true(
			page.contains("%d Regioni" % data().regions.size()),
			"%s: le Regioni sono quelle che ci sono" % chronicle_id
		)
		assert_true(
			page.contains("%d token presenza" % int(chronicle["presence_tokens"])),
			"%s: e le pedine sono quelle dichiarate" % chronicle_id
		)
		var pool: Dictionary = chronicle.get("tension_pool", {}) as Dictionary
		if not pool.is_empty():
			assert_true(
				page.contains("ne pesca %d" % int(pool["count"])),
				"%s: e la pagina dice quante domande si pescano davvero" % chronicle_id
			)
		var seats: Dictionary = chronicle.get("entity_pool", {}) as Dictionary
		if not seats.is_empty():
			assert_true(
				page.contains("fra %d case" % (seats["candidates"] as Array).size()),
				"%s: e fra quante case si pesca il tavolo" % chronicle_id
			)


## E nessuna Chronicle finisce senza che il tavolo abbia deciso: col Consiglio di
## chiusura il minimo garantito è **il numero degli Atti**, e la pagina lo dice.
func test_the_page_promises_the_councils_the_year_guarantees() -> void:
	for chronicle_id in _chronicles():
		var chronicle: Dictionary = data().chronicles[chronicle_id] as Dictionary
		if not bool((chronicle.get("confluence_rules", {}) as Dictionary).get("at_end_of_act", false)):
			continue
		assert_true(
			_page(chronicle_id).contains("almeno %d Consigli" % int(chronicle["acts"])),
			"%s: il minimo promesso è quello che il regolamento garantisce" % chronicle_id
		)


# --- attrezzi --------------------------------------------------------------

func _check(where: String, page: String, clause: Dictionary, declared: bool) -> void:
	for phrase in clause["says"]:
		if declared:
			assert_true(
				page.contains(str(phrase)),
				"%s: %s è dichiarata, la pagina deve dire «%s»"
				% [where, str(clause["why"]), str(phrase)]
			)
		else:
			assert_false(
				page.contains(str(phrase)),
				"%s: %s non è dichiarata, la pagina non può dire «%s»"
				% [where, str(clause["why"]), str(phrase)]
			)
	for phrase in clause["else"]:
		if declared:
			assert_false(
				page.contains(str(phrase)),
				"%s: %s è dichiarata, e «%s» è la regola di prima"
				% [where, str(clause["why"]), str(phrase)]
			)
		else:
			assert_true(
				page.contains(str(phrase)),
				"%s: senza %s la pagina torna a dire «%s»"
				% [where, str(clause["why"]), str(phrase)]
			)


func _chronicles() -> Array:
	var out: Array = []
	for chronicle_id in data().chronicles:
		out.append(str(chronicle_id))
	out.sort()
	return out


## La pagina è un nodo, non un oggetto contato: si costruisce, le si chiede il
## testo e la si libera a mano — `_ready()` qui non gira mai.
func _page(chronicle_id: String) -> String:
	var panel: Node = HelpPanel.new()
	var lines: Array = panel.call("_lines", data(), chronicle_id)
	panel.free()
	var text: String = "\n".join(PackedStringArray(lines))
	# **E la pagina deve arrivare in fondo.** In GDScript una chiave mancante non
	# alza niente che una prova possa prendere: interrompe la funzione, scrive
	# nel log e restituisce quello che aveva. Senza questa riga una clausola che
	# faccia crollare il disegno passerebbe verde — la pagina finirebbe a meta' e
	# le frasi vietate mancherebbero *perche' non e' stata scritta nessuna
	# frase*. E' successo la prima volta che questa suite ha tolto
	# `presence_tokens`.
	assert_true(
		text.contains("LA MAPPA"),
		"%s: la pagina arriva in fondo (si e' fermata a %d caratteri)"
		% [chronicle_id, text.length()]
	)
	return text


## Dichiarata vuol dire **scritta e non vuota**: un dizionario vuoto, una lista
## vuota, uno zero e un `false` sono assenza, qui come in tutto il progetto.
func _declares(chronicle_id: String, path: String) -> bool:
	var value: Variant = data().chronicles[chronicle_id]
	for part in path.split("."):
		if typeof(value) != TYPE_DICTIONARY or not (value as Dictionary).has(str(part)):
			return false
		value = (value as Dictionary)[str(part)]
	match typeof(value):
		TYPE_NIL: return false
		TYPE_BOOL: return bool(value)
		TYPE_INT: return int(value) != 0
		TYPE_FLOAT: return float(value) != 0.0
		TYPE_STRING: return str(value) != ""
		TYPE_DICTIONARY: return not (value as Dictionary).is_empty()
		TYPE_ARRAY: return not (value as Array).is_empty()
	return true


## Toglie una dichiarazione dalla Chronicle e restituisce di che rimetterla. Per
## una chiave annidata rimpiazza il ramo con una copia, così quello vero torna
## intatto: una prova che lascia i dati diversi da come li ha trovati misura la
## prova dopo, non il codice.
func _erase(chronicle: Dictionary, path: String) -> Dictionary:
	var parts: PackedStringArray = path.split(".")
	var key: String = str(parts[0])
	var before: Variant = chronicle.get(key)
	if parts.size() == 1:
		chronicle.erase(key)
	else:
		var copy: Dictionary = (before as Dictionary).duplicate(true)
		copy.erase(str(parts[1]))
		chronicle[key] = copy
	return {"key": key, "before": before, "had": chronicle.has(key) or before != null}


func _restore(chronicle: Dictionary, undo: Dictionary) -> void:
	if undo["before"] == null:
		chronicle.erase(str(undo["key"]))
	else:
		chronicle[str(undo["key"])] = undo["before"]


## E la riga che un giocatore legge **piu' spesso di ogni altra**: quella sopra
## le scelte, che dice cosa sta per succedere.
##
## Diceva «ha raggiunto la soglia: il Consiglio si apre» — falso a ogni round di
## ogni partita spedita da D-214 in poi, perche' col Consiglio di chiusura la
## soglia non apre piu' niente. Stessa bugia della pagina delle regole, stesso
## motivo: `game_screen.gd` non era misurato da nessuna parte, e il cancello non
## legge quello che c'e' scritto sullo schermo.
func test_the_line_the_player_reads_every_round_never_promises_a_threshold() -> void:
	new_session()
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	var rules: Dictionary = (chronicle.get("confluence_rules", {}) as Dictionary).duplicate(true)
	rules["at_end_of_act"] = true
	chronicle["confluence_rules"] = rules

	var line: String = _context()
	assert_false(
		line.contains("raggiunto la soglia"),
		"col Consiglio di chiusura nessuna soglia apre un Consiglio: «%s»" % line
	)
	assert_false(
		line.contains("passo dalla soglia"),
		"e nessuna spinta lo anticipa: «%s»" % line
	)
	assert_false(
		line.contains("vicina a scoppiare"),
		"e nessuna domanda scoppia: «%s»" % line
	)
	assert_true(
		line.contains("Consiglio"),
		"ma la riga dice comunque quando il tavolo si siede: «%s»" % line
	)


## E senza la regola torna la riga di sempre: la soglia c'e' di nuovo, e la
## pagina come lo schermo la nominano.
func test_without_the_closing_council_the_line_counts_the_steps_again() -> void:
	new_session()
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	var rules: Dictionary = (chronicle.get("confluence_rules", {}) as Dictionary).duplicate(true)
	rules.erase("at_end_of_act")
	chronicle["confluence_rules"] = rules

	var line: String = _context()
	assert_true(
		line.contains("soglia") or line.contains("scoppiare"),
		"senza il Consiglio di chiusura si contano di nuovo i passi: «%s»" % line
	)


## Lo schermo e' un nodo grosso, e `_ready()` qui non gira: si costruisce, gli si
## mette in mano la sessione e gli si chiede quella riga sola.
func _context() -> String:
	var screen: Node = GameScreen.new()
	screen.set("_session", session)
	screen.set("_viewer", str(session.world["turn_order"][0]))
	var line: String = str(screen.call("_context_line"))
	screen.free()
	return line
