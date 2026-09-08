extends "res://tests/test_case.gd"
## Una domanda caduta lascia il segno che quella domanda lascia
## ([D-323](DECISIONS.md#d-323), [ISSUES 95](ISSUES.md)).
##
## Fino a 0.1.285 il pool `failure` della scheda del Consiglio non lo leggeva
## nessuno: un Consiglio che falliva lasciava al mondo soltanto
## `question_unresolved`, e undici Conseguenze scritte — proprio quelle che
## sporcano il mondo — non uscivano mai. Adesso ne scatta **una**, e non e' la
## stessa per tutti: la fame che nessuno risolve svuota il posto, una terra che
## nessuno assegna resta contesa, l'Antico che nessuno chiude diventa una voce
## che corre, un conto che nessuno salda chiude la strada.
##
## Le prove sono tre, e la terza e' quella che tiene le altre oneste: **una
## prova che cerca una condizione fra i dati puo' smettere di provare senza
## dirlo** se quella condizione sparisce. Qui la condizione e' «esiste almeno un
## Consiglio caduto», e se non c'e' la prova lo dice invece di passare a vuoto.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
const SEMI: Array = [9100, 9137, 9174, 9211, 9248, 9285]


## Ogni scheda di Consiglio dice **una riga sola** sotto «se cade», e quella
## riga nomina una Conseguenza che esiste. Una scheda con il pool vuoto e' un
## Consiglio che puo' cadere senza che il mondo se ne accorga; una che ne nomina
## due e' una scelta che al tavolo nessuno fa.
func test_every_council_sheet_says_what_happens_if_it_falls() -> void:
	var checked: int = 0
	for template_id in data().confluence_templates:
		var pools: Dictionary = (
			data().confluence_templates[template_id]["consequence_pools"] as Dictionary
		)
		var when_it_falls: Array = pools.get("failure", []) as Array
		assert_eq(
			when_it_falls.size(), 1,
			"%s: una riga sola sotto «se cade», non %d" % [template_id, when_it_falls.size()]
		)
		assert_true(
			data().consequences.has(str(when_it_falls[0])),
			"%s: «se cade» nomina %s, che nella scatola non c'e'" % [
				template_id, str(when_it_falls[0])
			]
		)
		checked += 1
	assert_true(checked > 0, "la prova ha guardato almeno una scheda")


## E in partita: ogni Consiglio caduto porta con se' la riga della sua scheda —
## non una generica e non nessuna — **e quello che le sue due domande lasciano
## se il tavolo le respinge** ([D-475](DECISIONS.md#d-475)).
##
## La seconda meta' e' nuova, e la prova la chiedeva gia' senza saperlo: prima
## di D-475 asseriva **solo** il sacchetto, e il giorno in cui le sedici
## Conseguenze sono tornate questa riga e' andata rossa per prima. Adesso
## controlla tutt'e due le cose, in ordine: prima la riga del sacchetto, poi i
## rifiuti delle due domande.
func test_a_fallen_council_lands_the_consequence_of_its_own_sheet() -> void:
	var fallen: int = 0
	var with_a_refusal: int = 0
	for seed_value in SEMI:
		if session != null:
			session.dispose()
		session = GameSession.new(data())
		session.setup("CHR_TEST", SEATS, int(seed_value))
		await session.run(_decider())
		for entry in session.chronicle.confluence_results:
			var result: Dictionary = entry as Dictionary
			if str(result["outcome"]) != ConfluenceResolution.FAILURE:
				continue
			fallen += 1
			var sheet: Dictionary = data().confluence_template_for(str(result["tension_id"]))
			var expected: Array = (
				(sheet.get("consequence_pools", {}) as Dictionary).get("failure", []) as Array
			).duplicate()
			# Le due domande della carta sono state respinte tutt'e due: cio'
			# che ognuna lascia si aggiunge, senza doppioni.
			#
			# **L'ordine e' quello del tavolo, non quello della stampa** (D-486):
			# il motore le mette nell'ordine delle due parti — A e poi B — e
			# quale domanda finisce da che parte lo decide il Consiglio, non la
			# carta. Fino a 0.1.455 le due coincidevano per caso, e questa riga
			# e' andata rossa il giorno in cui il Calore che attraversa l'Atto
			# ha cambiato quale domanda si apre per prima. Si confrontano gli
			# insiemi: quello che conta e' che ci sia tutto, una volta sola.
			var refusals: int = 0
			for question in (sheet.get("questions", []) as Array):
				for consequence_id in ((question as Dictionary).get("refused", []) as Array):
					refusals += 1
					if not expected.has(consequence_id):
						expected.append(consequence_id)
			if refusals > 0:
				with_a_refusal += 1
			var landed: Array = (result["consequence_ids"] as Array).duplicate()
			landed.sort()
			expected.sort()
			assert_eq(
				landed, expected,
				"la domanda %s e' caduta: doveva lasciare %s" % [
					str(result["tension_id"]), str(expected)
				]
			)
	# **Le due righe che tengono onesta la prova.** Se un giorno nessuno di
	# questi semi fa cadere piu' niente, o se nessuna delle carte che cadono
	# porta un rifiuto scritto, questa prova smetterebbe di provare in silenzio
	# — la seconda meta' passerebbe senza aver mai guardato una Conseguenza
	# rimessa in strada da D-475.
	assert_true(fallen > 0, "su %d semi non e' caduta nemmeno una domanda: la prova non prova niente" % SEMI.size())
	# Su questi semi cade poco, e quel poco puo' capitare su una carta che non
	# scrive nessun rifiuto: `with_a_refusal` si legge, non si pretende. La
	# meta' nuova la prova il caso **fabbricato** qui sotto, che e' la regola di
	# casa — una condizione cercata fra i dati puo' smettere di esserci.
	assert_true(with_a_refusal >= 0, "il conto delle cadute con un rifiuto si legge")


## **E il rifiuto arriva davvero al mondo** (D-475), su un caso **fabbricato**:
## si apre il Consiglio della Carestia col mucchio alto e non si impegna
## niente, cosi' nessuna delle due domande lo scavalca e cadono tutt'e due.
##
## Fabbricato e non cercato, per la ragione che questo file dice in testa: la
## prova sopra gira sei semi e su quei sei cade **una** domanda sola, su una
## carta che non scrive nessun rifiuto. Lasciare li' la meta' nuova voleva dire
## una prova verde che non guarda niente — che in questo progetto e' successo
## cinque volte.
func test_a_refused_question_lands_what_it_says_it_leaves() -> void:
	new_session()
	var tension_id: String = "TEN_FAMINE"
	var sheet: Dictionary = data().confluence_template_for(tension_id)
	var written: Array = []
	for question in (sheet.get("questions", []) as Array):
		for consequence_id in ((question as Dictionary).get("refused", []) as Array):
			if not written.has(consequence_id):
				written.append(consequence_id)
	assert_false(
		written.is_empty(),
		"la Carestia scrive cosa resta se le sue domande sono respinte"
	)

	# **Nessuno impegna niente**: le due parti restano a zero, nessuna supera
	# l'altra, e il voto e' FAILURE per costruzione (D-467). Non serve gonfiare
	# il mucchio — a parita' non passa nessuna delle due, ed e' la condizione
	# che si vuole.
	var theme_id: String = str(data().tensions[tension_id].get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = 0
	var context: Dictionary = session.confluence.open(tension_id, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio della Carestia si apre")

	var result: Dictionary = session.confluence.resolve()
	assert_false(result.is_empty(), "e si risolve: %s" % session.confluence.last_error)
	assert_eq(
		str(result.get("outcome", "")), ConfluenceResolution.FAILURE,
		"senza un impegno non passa nessuna delle due"
	)
	for consequence_id in written:
		assert_true(
			(result["consequence_ids"] as Array).has(consequence_id),
			"la domanda respinta lascia %s" % str(consequence_id)
		)


## E il segno arriva **al mondo**, non solo nel verbale: una Conseguenza
## elencata che non posa nessun Effect sarebbe una riga stampata e basta.
func test_the_mark_reaches_the_world_and_not_only_the_minute() -> void:
	var landed: int = 0
	for seed_value in SEMI:
		if session != null:
			session.dispose()
		session = GameSession.new(data())
		session.setup("CHR_TEST", SEATS, int(seed_value))
		await session.run(_decider())
		for entry in session.chronicle.confluence_results:
			var result: Dictionary = entry as Dictionary
			if str(result["outcome"]) != ConfluenceResolution.FAILURE:
				continue
			if (result["consequence_ids"] as Array).is_empty():
				continue
			assert_true(
				(result["effect_ids"] as Array).size() > 0,
				"la domanda %s e' caduta e non ha posato niente sul mondo"
					% str(result["tension_id"])
			)
			landed += 1
	assert_true(landed > 0, "nessun Consiglio caduto misurato: la prova non prova niente")


func _decider() -> RefCounted:
	return load("res://scripts/seat/policy_decider.gd").new(session.log)
