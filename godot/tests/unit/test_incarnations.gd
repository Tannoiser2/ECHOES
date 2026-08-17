extends "res://tests/test_case.gd"
## D-108 (ISSUES 19, Fase 2): quando la linea dei successori si esaurisce, il
## seggio non ricicla nomi - cambia vita. Il priorato diventa i Frati, la
## dinastia una repubblica; la natura nuova (COLLECTIVE) smette di morire, e
## il verbale racconta il passaggio.

const Succession := preload("res://scripts/chronicle/succession.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

const LONG_JUMP: int = 60


func before_each() -> void:
	new_session()


func _plan_for(
	entity_id: String, before_state: Dictionary, world_extra: Dictionary = {}
) -> Dictionary:
	var chronicle: Dictionary = {"entities": [entity_id]}
	var previous: Dictionary = {"entities": {entity_id: before_state}}
	previous.merge(world_extra)
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
		var last: Dictionary = incarnations[incarnations.size() - 1]
		var fallback: bool = false
		for life in incarnations:
			if str(life.get("entry", "")) == "LINE_EXHAUSTED":
				fallback = true
		assert_true(
			fallback or str(last.get("entry", "")) == "ON_TAG",
			"il seggio mortale ha almeno una vita di ripiego o condizionata"
		)
		assert_true(str(last["name"]) != str(definition["name"]), "la vita nuova ha un altro nome")
	assert_eq(mortals, 5, "cinque seggi mortali fra le due Cronache")


func test_the_played_story_chooses_which_life_is_born() -> void:
	# D-109: la stessa morte, due nascite. Con la legge scritta sul mondo
	# nasce l'Accademia; senza, il Culto della Misura.
	var with_law: Dictionary = _plan_for(
		"ENT_LYRA", {"name": "Sela di Eredan", "generation": 4},
		{"global_tags": ["succession_by_law"]}
	)
	assert_eq(str(with_law["name"]), "L'Accademia delle Misure", "la legge scritta fa l'università")
	assert_eq(str(with_law["entry_kind"]), "ON_TAG", "l'ingresso è la storia giocata")
	var without: Dictionary = _plan_for("ENT_LYRA", {"name": "Sela di Eredan", "generation": 4})
	assert_eq(str(without["name"]), "Il Culto della Misura", "senza legge nasce la chiesa")


func test_a_people_that_settles_becomes_mortal() -> void:
	# D-109: il segno sceglie la vita senza aspettare una linea esaurita -
	# e trasformarsi può costare: il Regno guadagna eredi da consumare.
	var settled: Dictionary = _plan_for(
		"ENT_NAHR", {"name": "Popolo Nahr", "generation": 0},
		{"global_tags": ["nahr_settled"]}
	)
	assert_true(bool(settled["transformed"]), "il popolo insediato si trasforma")
	assert_eq(str(settled["name"]), "Il Regno di Nahr", "il popolo seduto è un regno")
	var kingdom_view: Dictionary = Succession.active_view(
		session.data.entities["ENT_NAHR"], int(settled["incarnation"])
	)
	assert_eq(str(kingdom_view["persistence"]), "MORTAL", "un regno ha re, e i re muoiono")
	var next_jump: Dictionary = _plan_for(
		"ENT_NAHR",
		{"name": "Il Regno di Nahr", "generation": 0,
			"incarnation": int(settled["incarnation"])}
	)
	assert_eq(str(next_jump["name"]), "Re Dhalan", "al salto dopo siede il primo re")


func test_a_dead_seat_rises_in_its_on_death_life() -> void:
	# D-109: il seggio sopravvive alla creatura. Vaerax morto, il Culto siede.
	var risen: Dictionary = _plan_for(
		"ENT_VAERAX", {"name": "Vaerax", "generation": 0, "active": false}
	)
	assert_true(bool(risen["transformed"]), "la morte apre la vita ON_DEATH")
	assert_true(bool(risen["revived"]), "il seggio torna al tavolo")
	assert_eq(str(risen["name"]), "Il Culto della Montagna", "la memoria si organizza")
	# E finché nessuno lo uccide, il drago dorme come sempre.
	var asleep: Dictionary = _plan_for("ENT_VAERAX", {"name": "Vaerax", "generation": 0})
	assert_false(bool(asleep["transformed"]), "senza morte niente culto")


func test_the_life_sign_powers_the_life() -> void:
	# D-109: la vita porta il segno life: e le tag_rules lo leggono - il
	# potere è della vita, non del seggio.
	var seat: Dictionary = session.world["entities"]["ENT_LYRA"]
	(seat["tags"] as Array).append("life:INC_LYRA_ACADEMY")
	var factor: Dictionary = TagRules.council_world_factor(
		session.data, session.world, "TEN_FAMINE", "ENT_LYRA"
	)
	assert_eq(int(factor["delta"]), 1, "l'Accademia fa testo quando propone")
	var other: Dictionary = TagRules.council_world_factor(
		session.data, session.world, "TEN_FAMINE", "ENT_ALDRIC"
	)
	assert_eq(int(other["delta"]), 0, "il potere non è di chi non vive quella vita")


func test_the_active_view_swaps_the_authored_fields() -> void:
	var definition: Dictionary = session.data.entities["ENT_ALDRIC"]
	var republic: Dictionary = Succession.active_view(definition, 1)
	assert_eq(str(republic["name"]), "La Repubblica della Valle", "il nome della vita nuova")
	assert_eq(str(republic["persistence"]), "COLLECTIVE", "la natura della vita nuova")
	assert_false(republic.has("successors"), "la linea vecchia non si eredita")
	assert_false(republic.has("name_grammar"), "nemmeno la grammatica dei nomi")
	assert_eq(str(republic["id"]), "ENT_ALDRIC", "il seggio resta il seggio")
