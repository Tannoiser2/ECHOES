extends "res://tests/test_case.gd"
## D-108 (ISSUES 19, Fase 2): quando la linea dei successori si esaurisce, il
## seggio non ricicla nomi - cambia vita. Il priorato diventa i Frati, la
## dinastia una repubblica; la natura nuova (COLLECTIVE) smette di morire, e
## il verbale racconta il passaggio.

const Succession := preload("res://scripts/chronicle/succession.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")
const CardFace := preload("res://scripts/core/card_face.gd")

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
	assert_eq(int(seat["incarnation"]), 2, "la vita di ripiego siede (l'Inquisizione aspetta il suo segno)")
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


func test_a_dynasty_is_not_cut_short_by_a_sign() -> void:
	# 0.1.72: per i MORTAL il segno sceglie la vita solo a linea esaurita -
	# il grano requisito non interrompe la dinastia a metà.
	var mid_line: Dictionary = _plan_for(
		"ENT_ALDRIC", {"name": "Re Aldric", "generation": 1},
		{"global_tags": ["grain_requisitioned"]}
	)
	assert_false(bool(mid_line["transformed"]), "la dinastia continua coi suoi eredi")
	var at_end: Dictionary = _plan_for(
		"ENT_ALDRIC", {"name": "Re Aldric IV", "generation": 4},
		{"global_tags": ["grain_requisitioned"]}
	)
	assert_eq(str(at_end["name"]), "La Reggenza del Granaio", "a linea esaurita sceglie il segno")
	var plain_end: Dictionary = _plan_for(
		"ENT_ALDRIC", {"name": "Re Aldric IV", "generation": 4}
	)
	assert_eq(str(plain_end["name"]), "La Repubblica della Valle", "senza segno, il ripiego")


func test_the_republic_can_become_a_crown_again() -> void:
	# Il cerchio: dalla Repubblica (COLLECTIVE) si torna corona per evento,
	# e la Corona Restaurata è di nuovo mortale coi suoi eredi.
	var definition: Dictionary = session.data.entities["ENT_ALDRIC"]
	var republic_at: int = -1
	for index in range(definition["incarnations"].size()):
		if str(definition["incarnations"][index]["id"]) == "INC_ALDRIC_02":
			republic_at = index
	var restored: Dictionary = _plan_for(
		"ENT_ALDRIC",
		{"name": "La Repubblica della Valle", "generation": 0, "incarnation": republic_at},
		{"global_tags": ["heir_named"]}
	)
	assert_eq(str(restored["name"]), "La Corona Restaurata", "un nome torna a valere")
	var view: Dictionary = Succession.active_view(definition, int(restored["incarnation"]))
	assert_eq(str(view["persistence"]), "MORTAL", "la corona restaurata muore di nuovo")


func test_every_life_has_its_own_tarot() -> void:
	# D-111: il mazzo Casata porta una carta per ogni vita oltre la prima -
	# nome e volto propri, il seggio nel sottotitolo.
	var deck: Array = CardFace.deck_of("entity", session.data)
	var expected: int = session.data.entities.size()
	var by_id: Dictionary = {}
	for face in deck:
		by_id[str(face["id"])] = face
	for entity_id in session.data.entities:
		expected += maxi(0, (session.data.entities[entity_id].get("incarnations", []) as Array).size() - 1)
	assert_eq(deck.size(), expected, "una carta per seggio più una per ogni vita nuova")
	var friars: Dictionary = by_id.get("INC_VETRO_02", {})
	assert_false(friars.is_empty(), "i Frati del Vetro hanno la loro carta")
	assert_eq(str(friars["title"]), "I Frati del Vetro", "col loro nome")
	assert_eq(str(friars["art_prompt_key"]), "entity.vetro_friars", "e il loro prompt d'arte")
	assert_eq(str(friars["shape"]), "TAROT", "stessa taglia della casata")


func test_the_active_view_swaps_the_authored_fields() -> void:
	var definition: Dictionary = session.data.entities["ENT_ALDRIC"]
	var republic: Dictionary = Succession.active_view(definition, 2)
	assert_eq(str(republic["name"]), "La Repubblica della Valle", "il nome della vita nuova")
	assert_eq(str(republic["persistence"]), "COLLECTIVE", "la natura della vita nuova")
	assert_false(republic.has("successors"), "la linea vecchia non si eredita")
	assert_false(republic.has("name_grammar"), "nemmeno la grammatica dei nomi")
	assert_eq(str(republic["id"]), "ENT_ALDRIC", "il seggio resta il seggio")


## I Forni Riaccesi (D-129): quando la linea dei Fuochi si esaurisce, il segno
## sceglie la vita - la miniera ferita accende l'industria, il sigillo la sbarra
## (e allora siedono le Custodi), senza ferita le Custodi come sempre. Una
## dinastia MORTAL non si interrompe a meta' (D-109): il segno decide al
## momento giusto, non prima.
func test_the_reopened_mine_lights_the_furnaces_unless_sealed() -> void:
	var wounded: Dictionary = _plan_for(
		"ENT_CENERE", {"name": "Arla dei Fuochi", "generation": 4},
		{"regions": {"REG_MINIERE_ANTICHE": {"tags": ["scar:open_wound"]}}}
	)
	assert_true(bool(wounded["transformed"]), "la linea esaurita muta il seggio")
	assert_eq(str(wounded["name"]), "I Forni Riaccesi", "l'industria si accende")
	assert_eq(int(wounded["incarnation"]), 1, "la vita chiamata dal segno")

	var sealed: Dictionary = _plan_for(
		"ENT_CENERE", {"name": "Arla dei Fuochi", "generation": 4},
		{"regions": {"REG_MINIERE_ANTICHE": {"tags": ["scar:open_wound", "structure:sealed"]}}}
	)
	assert_eq(str(sealed["name"]), "Le Custodi della Cenere", "il sigillo sbarra i forni")
	assert_eq(int(sealed["incarnation"]), 2, "e siede la vita di ripiego")

	var quiet: Dictionary = _plan_for("ENT_CENERE", {"name": "Arla dei Fuochi", "generation": 4})
	assert_eq(str(quiet["name"]), "Le Custodi della Cenere", "senza ferita niente forni")

	var midline: Dictionary = _plan_for(
		"ENT_CENERE", {"name": "Kessa dei Fuochi", "generation": 0},
		{"regions": {"REG_MINIERE_ANTICHE": {"tags": ["scar:open_wound"]}}}
	)
	assert_false(bool(midline["transformed"]), "la dinastia non si interrompe a meta'")


## La Diaspora di Nahr (D-130): due sradicamenti in un anno tolgono il centro,
## e il popolo che il tavolo ha cacciato smette di poter essere chiuso fuori.
func test_the_twice_uprooted_people_becomes_the_diaspora() -> void:
	var scattered: Dictionary = _plan_for(
		"ENT_NAHR", {"name": "Popolo Nahr", "generation": 0, "tags": ["twice_uprooted"]}
	)
	assert_true(bool(scattered["transformed"]), "senza centro, il popolo si disperde")
	assert_eq(str(scattered["name"]), "La Diaspora di Nahr", "la vita nuova ha il suo nome")
	assert_eq(int(scattered["incarnation"]), 2, "la terza vita del seggio")

	var settled: Dictionary = _plan_for(
		"ENT_NAHR", {"name": "Popolo Nahr", "generation": 0, "tags": ["twice_uprooted"]},
		{"global_tags": ["nahr_settled"]}
	)
	assert_eq(str(settled["name"]), "Il Regno di Nahr", "l'ordine d'autore: chi si e' seduto siede")

	var quiet: Dictionary = _plan_for("ENT_NAHR", {"name": "Popolo Nahr", "generation": 0})
	assert_false(bool(quiet["transformed"]), "senza sradicamenti il popolo resta popolo")


## L'Egemonia di Eredan (D-131): quando la Valle si svuota e Eredan resta
## piena, il coro diventa una voce. Il segno qualificato `tag@REG` chiede lo
## sgombero su QUELLA Regione: uno sgombero qualsiasi non fa un'egemonia,
## e con Eredan svuotata a sua volta non resta nessuno che comandi.
func test_the_last_full_city_becomes_the_hegemony() -> void:
	var alone: Dictionary = _plan_for(
		"ENT_LIBERE", {"name": "Le Città Libere", "generation": 0},
		{"regions": {"REG_VALLE_VERDE": {"tags": ["scar:emptied"]}}}
	)
	assert_true(bool(alone["transformed"]), "la Valle svuotata lascia una voce sola")
	assert_eq(str(alone["name"]), "L'Egemonia di Eredan", "e quella voce comanda")
	assert_eq(int(alone["incarnation"]), 2, "la terza vita del seggio")

	var ruins: Dictionary = _plan_for(
		"ENT_LIBERE", {"name": "Le Città Libere", "generation": 0},
		{"regions": {
			"REG_VALLE_VERDE": {"tags": ["scar:emptied"]},
			"REG_EREDAN": {"tags": ["scar:emptied"]},
		}}
	)
	assert_false(bool(ruins["transformed"]), "con Eredan svuotata non c'e' egemonia")

	var elsewhere: Dictionary = _plan_for(
		"ENT_LIBERE", {"name": "Le Città Libere", "generation": 0},
		{"regions": {"REG_TERRE_NAHR": {"tags": ["scar:emptied"]}}}
	)
	assert_false(bool(elsewhere["transformed"]), "uno sgombero qualsiasi non fa un'egemonia")


## La Leggenda della Montagna (D-133): quando il mondo dimentica, il drago
## diventa la storia che si racconta di lui - e la storia giura su ambizioni
## sue. L'ordine d'autore protegge il corpo: finche' il Cristallo e' un fatto
## vivo, siede il Ridestato, non il racconto.
func test_the_forgotten_mountain_seats_the_legend() -> void:
	var told: Dictionary = _plan_for(
		"ENT_VAERAX", {"name": "Vaerax", "generation": 0},
		{"global_tags": ["mountain_forgotten"]}
	)
	assert_true(bool(told["transformed"]), "la dimenticanza compiuta muta il seggio")
	assert_eq(str(told["name"]), "La Leggenda della Montagna", "e siede il racconto")
	assert_eq(int(told["incarnation"]), 3, "la quarta vita del seggio")
	assert_eq(
		str(told["destiny_id"]), "DST_VAERAX_LEGEND",
		"la vita giura su ambizioni sue"
	)

	var faded: Dictionary = _plan_for(
		"ENT_VAERAX", {"name": "Vaerax Ridestato", "generation": 0, "incarnation": 1},
		{"global_tags": ["mountain_forgotten", "legend:crystal_exploited"]}
	)
	assert_eq(
		str(faded["name"]), "La Leggenda della Montagna",
		"anche il drago richiuso, nei secoli, torna racconto"
	)

	var awake: Dictionary = _plan_for(
		"ENT_VAERAX", {"name": "Vaerax", "generation": 0},
		{"global_tags": ["mountain_forgotten", "crystal_exploited"]}
	)
	assert_eq(
		str(awake["name"]), "Vaerax Ridestato",
		"col Cristallo fuori siede il corpo, non la storia (ordine d'autore)"
	)

	var still_awake: Dictionary = _plan_for(
		"ENT_VAERAX", {"name": "Vaerax Ridestato", "generation": 0, "incarnation": 1},
		{"global_tags": ["mountain_forgotten", "crystal_exploited"]}
	)
	assert_false(
		bool(still_awake["transformed"]),
		"il fatto vivo del Cristallo sbarra la leggenda"
	)


## D-133: il seggio senza corpo. La vita che dichiara `presence: []` non
## piazza pedine al setup - e le altre case piazzano le loro come sempre.
func test_the_bodiless_life_places_no_tokens() -> void:
	var factory: GDScript = preload("res://scripts/world/world_state_factory.gd")
	session.world["entities"]["ENT_VAERAX"]["incarnation"] = 3
	var placed: Dictionary = {}
	for effect in factory.setup_effects(
		session.data.chronicles["CHR_01"], session.data, session.world
	):
		if str(effect["type"]) == "ADD_PRESENCE":
			var seat: String = str(effect["target"]["id"])
			placed[seat] = int(placed.get(seat, 0)) + 1
	assert_false(placed.has("ENT_VAERAX"), "la Leggenda non sta in nessun posto")
	assert_true(int(placed.get("ENT_ALDRIC", 0)) > 0, "le case col corpo si piazzano come sempre")
