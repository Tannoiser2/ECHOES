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
## **La caduta si fabbrica, non si cerca** (D-489). Fino al 0.1.458 due di
## queste prove giravano sei semi e guardavano i Consigli caduti che
## capitavano; l'avviso che il file stesso si era scritto — *«una prova che
## cerca una condizione fra i dati puo' smettere di provare senza dirlo»* — e'
## suonato il giorno in cui le marche delle caselle sono diventate quelle della
## carta e su quei sei semi non e' caduto piu' niente. Adesso la caduta si
## costruisce, su tutte e quattro le carte del banco invece che su quelle che il
## caso faceva cadere: e' una prova piu' forte, non una riparazione.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")

## Le quattro carte del banco: la caduta si fabbrica su tutte e quattro.
const TENSIONI: Array = ["TEN_FAMINE", "TEN_AWAKENING", "TEN_SUCCESSION", "TEN_ROADS"]


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
	var checked: int = 0
	for tension_id in TENSIONI:
		var result: Dictionary = _make_it_fall(str(tension_id))
		assert_eq(
			str(result.get("outcome", "")), ConfluenceResolution.FAILURE,
			"%s: senza un impegno non passa nessuna delle due" % str(tension_id)
		)
		var sheet: Dictionary = data().confluence_template_for(str(tension_id))
		var expected: Array = (
			(sheet.get("consequence_pools", {}) as Dictionary).get("failure", []) as Array
		).duplicate()
		# Le due domande della carta sono state respinte tutt'e due: cio' che
		# ognuna lascia si aggiunge, senza doppioni.
		for question in (sheet.get("questions", []) as Array):
			for consequence_id in ((question as Dictionary).get("refused", []) as Array):
				if not expected.has(consequence_id):
					expected.append(consequence_id)
		var landed: Array = (result["consequence_ids"] as Array).duplicate()
		# **L'ordine e' quello del tavolo, non quello della stampa** (D-486): il
		# motore le mette nell'ordine delle due parti, e quale domanda finisce
		# da che parte lo decide il Consiglio. Si confrontano gli insiemi.
		landed.sort()
		expected.sort()
		assert_eq(
			landed, expected,
			"%s e' caduta: doveva lasciare %s" % [str(tension_id), str(expected)]
		)
		checked += 1
	assert_eq(checked, TENSIONI.size(), "tutte le carte del banco sono state fatte cadere")


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
	for tension_id in TENSIONI:
		var result: Dictionary = _make_it_fall(str(tension_id))
		assert_false(
			(result["consequence_ids"] as Array).is_empty(),
			"%s caduta lascia almeno una Conseguenza" % str(tension_id)
		)
		assert_true(
			(result["effect_ids"] as Array).size() > 0,
			"%s e' caduta e non ha posato niente sul mondo" % str(tension_id)
		)
		landed += 1
	assert_eq(landed, TENSIONI.size(), "ogni carta del banco ha posato il suo segno")


## **Si fabbrica la caduta, non si cerca** (regola di casa, e questo file la
## dichiarava gia' in testa). Fino al 0.1.458 queste due prove giravano sei semi
## e contavano i Consigli caduti che capitavano: il giorno in cui le marche
## delle caselle sono diventate quelle della carta (D-489) su quei sei semi non
## e' caduto piu' niente, e le due prove hanno detto *«non provo niente»* invece
## di passare a vuoto — che e' esattamente il lavoro che facevano.
##
## Adesso la caduta si costruisce: si apre il Consiglio e non impegna nessuno.
## Le due parti restano a zero, nessuna supera l'altra, e a parita' non passa
## nessuna delle due (D-467). E si fa su **tutte** le carte del banco, non su
## quelle che il caso faceva cadere.
func _make_it_fall(tension_id: String) -> Dictionary:
	new_session()
	var theme_id: String = str(data().tensions[tension_id].get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = 0
	var context: Dictionary = session.confluence.open(tension_id, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio di %s si apre" % tension_id)
	var result: Dictionary = session.confluence.resolve()
	assert_false(result.is_empty(), "e si risolve: %s" % session.confluence.last_error)
	return result


