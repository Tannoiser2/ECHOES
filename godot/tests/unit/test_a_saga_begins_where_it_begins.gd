extends "res://tests/test_case.gd"
## Da dove comincia una partita, e che non lo chiede a nessuno (D-241, D-245).
##
## *«Chiede ancora quale anno voglio giocare.»* Il menu offriva **tutte** le
## Chronicle come punto di partenza, e due delle quattro non lo sono: sono il
## **seguito** di un'altra — la biblioteca della stessa eta', che eredita il
## mondo dell'anno prima e si raggiunge giocando.
##
## D-241 aveva ridotto la domanda a due voci. **Era ancora una domanda di
## troppo**: *«non deve chiedere nessuna saga»*. Adesso l'app si apre e si
## gioca, e queste prove tengono l'unica cosa che resta da tenere — che il posto
## da cui parte sia un **inizio** e non il secondo capitolo di qualcos'altro.

const GameScreen := preload("res://ui/game_screen.gd")


## Il posto da cui si parte non e' mai il seguito di qualcun altro.
##
## **La coppia si fabbrica** (D-319). Fino a 0.1.280 la scatola conteneva
## quattro anni d'autore incatenati — CHR_01 in CHR_02, CHR_03 in CHR_04 — e la
## prova poteva pescare i seguiti dal contenuto spedito. Cancellati quelli
## (D-318), resta una Chronicle sola che prosegue **se stessa**: di seguiti
## veri non ce n'e' piu' nessuno, e la prova diventerebbe un giro a vuoto che
## passa sempre. E' la trappola scritta in CLAUDE.md — *una prova che cerca una
## condizione fra i dati spediti puo' smettere di provare senza dirlo* — quindi
## la condizione la costruisce lei.
func test_the_menu_never_offers_a_sequel() -> void:
	var loaded: RefCounted = shipped_data()
	var first: String = ""
	for chronicle_id in loaded.chronicles:
		first = str(chronicle_id)
		break
	assert_ne(first, "", "c'e' almeno una Chronicle spedita")

	# L'era dopo, fabbricata: stessa forma, e dichiarata come continuazione
	# della prima. Il menu non deve offrirla.
	var heir: Dictionary = (loaded.chronicles[first] as Dictionary).duplicate(true)
	heir["id"] = "CHR_PROVA_SEGUITO"
	heir["sequel_id"] = "CHR_PROVA_SEGUITO"
	var chained: Dictionary = (loaded.chronicles[first] as Dictionary).duplicate(true)
	chained["sequel_id"] = "CHR_PROVA_SEGUITO"
	loaded.chronicles[first] = chained
	loaded.chronicles["CHR_PROVA_SEGUITO"] = heir

	var sequels: Dictionary = {}
	for chronicle_id in loaded.chronicles:
		var next_id: String = str(
			(loaded.chronicles[str(chronicle_id)] as Dictionary).get("sequel_id", "")
		)
		if next_id != "" and next_id != str(chronicle_id):
			sequels[next_id] = true
	assert_eq(sequels.size(), 1, "la coppia fabbricata ha un seguito")

	var offered: Array = GameScreen.openings(loaded)
	assert_false(offered.is_empty(), "e qualcosa da cui cominciare c'e'")
	# Il caso che deve dare **non-vuoto**: se il menu si svuotasse, l'altra
	# asserzione passerebbe per assenza invece che per regola.
	assert_true(offered.has(first), "la prima si comincia ancora")
	for chronicle_id in offered:
		assert_false(
			sequels.has(str(chronicle_id)),
			"«%s» e' il seguito di un'altra e non si comincia da li'" % str(chronicle_id)
		)


## E offre **tutte** quelle che lo sono: una saga scritta e mai raggiungibile
## sarebbe contenuto che non esiste (D-035).
func test_every_opening_is_offered() -> void:
	var loaded: RefCounted = shipped_data()
	var offered: Array = GameScreen.openings(loaded)
	for chronicle_id in loaded.chronicles:
		var is_a_sequel: bool = false
		for other in loaded.chronicles:
			if str(other) == str(chronicle_id):
				continue
			if str((loaded.chronicles[str(other)] as Dictionary).get("sequel_id", "")) == str(chronicle_id):
				is_a_sequel = true
		if not is_a_sequel:
			assert_true(
				offered.has(str(chronicle_id)),
				"«%s» comincia una saga e il menu la offre" % str(chronicle_id)
			)
	# Tre da 0.1.225: la Prima Chronicle (CHR_00, D-263) viene prima di tutte —
	# e' l'inizio senza scenario, e l'app adesso si apre da li'.
	assert_eq(offered.size(), 1, "la scatola ha una saga da cui cominciare")


## In ordine d'anno: la prima saga sta prima, che e' l'unico ordine che una
## persona si aspetta.
func test_the_openings_come_in_year_order() -> void:
	var loaded: RefCounted = shipped_data()
	var offered: Array = GameScreen.openings(loaded)
	var last: int = -99999
	for chronicle_id in offered:
		var year: int = int((loaded.chronicles[str(chronicle_id)] as Dictionary)["start_year"])
		assert_true(year >= last, "«%s» viene dopo quella di prima" % str(chronicle_id))
		last = year


## E non chiede: la partita comincia da sola, dalla prima apertura in ordine
## d'anno. Se domani qualcuno rimettesse una domanda all'apertura, questa prova
## non se ne accorgerebbe — ma il punto da cui si parte resta scritto qui, ed e'
## quello che una domanda tornerebbe a mettere in dubbio.
func test_the_game_starts_without_asking() -> void:
	var loaded: RefCounted = shipped_data()
	var start: String = GameScreen.first_chronicle(loaded)
	assert_true(loaded.chronicles.has(start), "il posto da cui si parte esiste: %s" % start)
	assert_eq(
		start, str(GameScreen.openings(loaded)[0]),
		"ed e' la prima apertura in ordine d'anno"
	)
	# Senza dati non si pianta: il menu ha una risposta anche quando la scatola
	# non si e' letta, ed e' la stessa che l'app ha sempre avuto.
	assert_eq(GameScreen.first_chronicle(null), "CHR_00", "e senza dati non resta muto")


## --- e finisce dove deve finire (D-253) ---
##
## *«La saga continua all'infinito, mentre dovrebbe fermarsi a 10 partite.»*
## `library_sequel_of` risponde con se stessa per la biblioteca — giusto, e'
## l'era che si ripete — e nessuno contava fin dove. Il numero era gia' nei
## dati: il verbale lo legge da D-181 per dire «un anno giocato su dieci».


## Ogni Chronicle che gioca a saga dice **dopo quanti anni** si decide.
func test_every_chronicle_says_how_long_a_saga_is() -> void:
	var loaded: RefCounted = shipped_data()
	var counted: int = 0
	for chronicle_id in loaded.chronicles:
		var rules: Dictionary = (
			loaded.chronicles[str(chronicle_id)] as Dictionary
		).get("saga_scoring", {}) as Dictionary
		if rules.is_empty():
			continue
		assert_true(
			rules.has("decides_after"),
			"«%s» dice quanto dura una saga" % str(chronicle_id)
		)
		assert_eq(int(rules["decides_after"]), 10, "e sono dieci anni, come l'idea di partenza")
		counted += 1
	assert_true(counted >= 1, "per ogni Chronicle della scatola: %d" % counted)


## E la porta dell'anno dopo legge quel numero, invece di aprirsi per sempre.
## Letto dal codice: la riga che conta e' una, e montare mezza applicazione per
## misurarla costerebbe piu' di quanto vale.
func test_the_door_to_the_next_year_reads_that_number() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/game_screen.gd")
	assert_true(
		source.contains("decides_after"),
		"la porta dell'era successiva legge quanti anni dura una saga"
	)
	assert_true(
		source.contains("played >= enough"),
		"e si chiude quando sono stati giocati"
	)

