extends "res://tests/test_case.gd"
## D-108 (ISSUES 19, Fase 2): quando la linea dei successori si esaurisce, il
## seggio non ricicla nomi - cambia vita. Il priorato diventa i Frati, la
## dinastia una repubblica; la natura nuova (COLLECTIVE) smette di morire, e
## il verbale racconta il passaggio.

const Succession := preload("res://scripts/chronicle/succession.gd")

const LONG_JUMP: int = 60


func before_each() -> void:
	new_session()


func _plan_for(entity_id: String, before_state: Dictionary) -> Dictionary:
	var chronicle: Dictionary = {"entities": [entity_id]}
	var previous: Dictionary = {"entities": {entity_id: before_state}}
	return Succession.plan(previous, {}, chronicle, session.data, LONG_JUMP)[entity_id]


func test_the_line_still_runs_through_the_written_heirs() -> void:
	var seat: Dictionary = _plan_for("ENT_VETRO", {"name": "Priore Anselmo", "generation": 0})
	assert_eq(str(seat["name"]), "Priora Ilaria", "il primo salto siede l'erede scritta")
	assert_false(bool(seat["transformed"]), "la linea non è esaurita: nessuna mutazione")
	assert_eq(int(seat["incarnation"]), 0, "ancora la prima vita")


func test_when_the_line_ends_the_next_life_takes_the_seat() -> void:
	# Quattro priori scritti: alla quinta successione il priorato è finito.
	var seat: Dictionary = _plan_for("ENT_VETRO", {"name": "Priore Malco", "generation": 4})
	assert_true(bool(seat["transformed"]), "la linea esaurita muta il seggio")
	assert_eq(str(seat["name"]), "I Frati del Vetro", "al seggio siede la vita nuova")
	assert_eq(str(seat["transformed_from"]), "Priore Anselmo", "il verbale sa da dove viene")
	assert_eq(int(seat["incarnation"]), 1, "la seconda vita è al tavolo")
	assert_eq(int(seat["generation"]), 0, "la generazione riparte con la vita nuova")


func test_the_new_life_stops_dying() -> void:
	# I Frati sono COLLECTIVE: un altro salto lungo non cambia più il nome.
	var seat: Dictionary = _plan_for(
		"ENT_VETRO", {"name": "I Frati del Vetro", "generation": 0, "incarnation": 1}
	)
	assert_false(bool(seat["changed"]), "una vita collettiva attraversa i secoli intatta")
	assert_eq(str(seat["name"]), "I Frati del Vetro", "il nome resta")


func test_every_mortal_seat_has_a_second_life() -> void:
	var mortals: int = 0
	for entity_id in session.data.entities:
		var definition: Dictionary = session.data.entities[entity_id]
		if str(definition.get("persistence", "")) != "MORTAL":
			continue
		mortals += 1
		var incarnations: Array = definition.get("incarnations", [])
		assert_true(
			incarnations.size() >= 2,
			"%s ha una seconda vita scritta (D-108)" % entity_id
		)
		var second: Dictionary = incarnations[1]
		assert_eq(str(second["entry"]), "LINE_EXHAUSTED", "la vita nuova entra a linea esaurita")
		assert_true(str(second["name"]) != str(definition["name"]), "la vita nuova ha un altro nome")
	assert_eq(mortals, 5, "cinque seggi mortali fra le due Cronache")


func test_the_active_view_swaps_the_authored_fields() -> void:
	var definition: Dictionary = session.data.entities["ENT_ALDRIC"]
	var republic: Dictionary = Succession.active_view(definition, 1)
	assert_eq(str(republic["name"]), "La Repubblica della Valle", "il nome della vita nuova")
	assert_eq(str(republic["persistence"]), "COLLECTIVE", "la natura della vita nuova")
	assert_false(republic.has("successors"), "la linea vecchia non si eredita")
	assert_false(republic.has("name_grammar"), "nemmeno la grammatica dei nomi")
	assert_eq(str(republic["id"]), "ENT_ALDRIC", "il seggio resta il seggio")
