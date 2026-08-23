extends "res://tests/test_case.gd"
## Da quale saga si comincia (D-241).
##
## *«Chiede ancora quale anno voglio giocare.»* Il menu offriva **tutte** le
## Chronicle della scatola come punto di partenza, e due delle quattro non lo
## sono: sono il **seguito** di un'altra — la biblioteca della stessa eta', che
## eredita il mondo dell'anno prima e si raggiunge giocando. Cominciare da li'
## vuol dire aprire il secondo capitolo senza il primo.
##
## Una saga si comincia, e poi gli anni vengono da soli: a fine Chronicle il
## gioco offre gia' l'era successiva ([D-095](DECISIONS.md#d-095)).

const GameScreen := preload("res://ui/game_screen.gd")


## Il menu non offre mai il seguito di qualcun altro.
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
