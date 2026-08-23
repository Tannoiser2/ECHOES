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
func test_the_menu_never_offers_a_sequel() -> void:
	var loaded: RefCounted = data()
	var sequels: Dictionary = {}
	for chronicle_id in loaded.chronicles:
		var next_id: String = str(
			(loaded.chronicles[str(chronicle_id)] as Dictionary).get("sequel_id", "")
		)
		if next_id != "" and next_id != str(chronicle_id):
			sequels[next_id] = true
	assert_true(sequels.size() >= 2, "la scatola ha dei seguiti: %d" % sequels.size())

	var offered: Array = GameScreen.openings(loaded)
	assert_false(offered.is_empty(), "e qualcosa da cui cominciare c'e'")
	for chronicle_id in offered:
		assert_false(
			sequels.has(str(chronicle_id)),
			"«%s» e' il seguito di un'altra e non si comincia da li'" % str(chronicle_id)
		)


## E offre **tutte** quelle che lo sono: una saga scritta e mai raggiungibile
## sarebbe contenuto che non esiste (D-035).
func test_every_opening_is_offered() -> void:
	var loaded: RefCounted = data()
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
	assert_eq(offered.size(), 2, "la scatola ha due saghe da cui cominciare")


## In ordine d'anno: la prima saga sta prima, che e' l'unico ordine che una
## persona si aspetta.
func test_the_openings_come_in_year_order() -> void:
	var loaded: RefCounted = data()
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
	var loaded: RefCounted = data()
	var start: String = GameScreen.first_chronicle(loaded)
	assert_true(loaded.chronicles.has(start), "il posto da cui si parte esiste: %s" % start)
	assert_eq(
		start, str(GameScreen.openings(loaded)[0]),
		"ed e' la prima apertura in ordine d'anno"
	)
	# Senza dati non si pianta: il menu ha una risposta anche quando la scatola
	# non si e' letta, ed e' la stessa che l'app ha sempre avuto.
	assert_eq(GameScreen.first_chronicle(null), "CHR_01", "e senza dati non resta muto")
