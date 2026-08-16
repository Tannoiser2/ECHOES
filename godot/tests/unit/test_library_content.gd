extends "res://tests/test_case.gd"
## Library-form content (D-028): a Council bound to a domain, and a Chronicle
## that draws its Tensions instead of listing them.
##
## This is what makes Chronicle N+1 possible without writing it, so it is worth
## a test that fails loudly rather than a probe nobody runs.

const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

## GameSession and DataSet come from test_case.gd; re-declaring them is a parse
## error, so the seats live here instead.
const LIBRARY_SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


## A Tension with no Council of its own is served by the Council of its domain.
func test_a_tension_without_a_council_borrows_its_domain_one() -> void:
	var loaded: RefCounted = data()
	var own: Dictionary = loaded.confluence_template_for("TEN_FAMINE")
	assert_eq(str(own["id"]), "CNF_FAMINE_01", "una Tensione con il proprio Consiglio lo tiene")

	var borrowed: Dictionary = loaded.confluence_template_for("TEN_PLAGUE")
	assert_false(borrowed.is_empty(), "TEN_PLAGUE deve trovare un Consiglio")
	assert_eq(
		str(borrowed.get("applies_to_domain", "")),
		"SURVIVAL",
		"e deve essere quello legato al dominio, non uno a caso"
	)
	assert_eq(
		str(loaded.tensions["TEN_PLAGUE"]["domain"]),
		str(borrowed["applies_to_domain"]),
		"il dominio combacia"
	)


## Every Tension in the library must find a Council, or a threshold hit would
## open a Confluence with nothing to ask.
func test_every_tension_in_the_library_finds_a_council() -> void:
	var loaded: RefCounted = data()
	for tension_id in loaded.tensions:
		assert_false(
			loaded.confluence_template_for(str(tension_id)).is_empty(),
			"%s non trova nessun Consiglio" % str(tension_id)
		)


## The draw is seeded: same seed, same year - which is what keeps a library
## Chronicle as reproducible as an authored one.
func test_the_tension_draw_is_deterministic_and_varies_by_seed() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_02"]
	var first: Array = WorldStateFactory.resolve_tensions(chronicle, RngService.new(4242))
	var again: Array = WorldStateFactory.resolve_tensions(chronicle, RngService.new(4242))
	assert_eq(first, again, "stesso seed, stessa mano di Tensioni")
	assert_eq(first.size(), int(chronicle["tension_pool"]["count"]), "ne pesca esattamente count")

	var seen: Dictionary = {}
	var distinct: Dictionary = {}
	for seed_value in range(4242, 4262):
		var drawn: Array = WorldStateFactory.resolve_tensions(chronicle, RngService.new(seed_value))
		# str(), not "%s" %: the format operator spreads an Array as its own
		# argument list, so every year would collapse to the same key.
		distinct[str(drawn)] = true
		for tension_id in drawn:
			seen[str(tension_id)] = true
	assert_true(distinct.size() > 1, "seed diversi devono dare anni diversi")
	assert_eq(
		seen.size(),
		(chronicle["tension_pool"]["candidates"] as Array).size(),
		"su venti anni ogni domanda della biblioteca deve uscire almeno una volta"
	)


## An authored Chronicle still behaves exactly as before.
func test_an_authored_chronicle_still_lists_its_own_tensions() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_01"]
	assert_eq(
		WorldStateFactory.resolve_tensions(chronicle, RngService.new(1)),
		chronicle["tensions"],
		"CHR_01 usa la lista scritta a mano, non una pescata"
	)


## Library content names Tensions a given Chronicle may not have drawn. A Ripple
## onto a question nobody is asking this year has to be a no-op, not a failure -
## otherwise half the library breaks the moment it is not all in play.
func test_an_effect_on_a_tension_not_in_play_is_a_noop() -> void:
	new_session()
	var absent: String = "TEN_PLAGUE"
	assert_false(session.world["tensions"].has(absent), "TEN_PLAGUE non e in CHR_01")
	var before: int = (session.world["effect_log"] as Array).size()
	var stored: Dictionary = session.applier.apply(
		load("res://scripts/core/effect.gd").make(
			"ADJUST_TENSION", "tension", absent, {"delta": 1},
			load("res://scripts/core/effect.gd").source("test", "TEST", "", 1, 1, 0)
		)
	)
	assert_false(stored.is_empty(), "l'Effect passa invece di fallire")
	assert_eq((session.world["effect_log"] as Array).size(), before + 1, "ed e comunque registrato")

	# An id that is not a Tension at all is still an error.
	# An id that is not a Tension at all is still an error. (The applier reports
	# it with push_error, so the runner prints a backtrace here on purpose.)
	assert_true(
		session.applier.apply(
			load("res://scripts/core/effect.gd").make(
				"ADJUST_TENSION", "tension", "TEN_DOES_NOT_EXIST", {"delta": 1},
				load("res://scripts/core/effect.gd").source("test", "TEST", "", 1, 1, 0)
			)
		).is_empty(),
		"un id che non esiste resta un errore"
	)


## D-079: la pesca che ascolta. Con un mondo ereditato che porta un segno
## dichiarato negli `echoes`, la candidata richiamata pesa il triplo; la pesca
## resta deterministica, e senza mondo di prima resta quella cieca di sempre.
func test_the_draw_listens_to_the_marks_of_the_era_before() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_02"]
	var marked: Dictionary = {
		"global_tags": ["mine_sealed"], "regions": {}, "relations": {}, "entities": {},
	}

	var first: Array = WorldStateFactory.resolve_tensions(chronicle, RngService.new(4242), marked)
	var again: Array = WorldStateFactory.resolve_tensions(chronicle, RngService.new(4242), marked)
	assert_eq(first, again, "stesso seed e stesso mondo, stessa mano")
	assert_eq(first.size(), int(chronicle["tension_pool"]["count"]), "e ne pesca sempre count")

	# Il peso si misura, non si presume: su cento semi, il Risveglio esce piu'
	# spesso quando la miniera murata e' sul tavolo che quando non c'e' niente.
	var with_mark: int = 0
	var without: int = 0
	for seed_value in range(5000, 5100):
		if WorldStateFactory.resolve_tensions(
			chronicle, RngService.new(seed_value), marked
		).has("TEN_AWAKENING"):
			with_mark += 1
		if WorldStateFactory.resolve_tensions(
			chronicle, RngService.new(seed_value)
		).has("TEN_AWAKENING"):
			without += 1
	assert_true(
		with_mark > without,
		"il segno pesa: Risveglio %d/100 col segno, %d/100 senza" % [with_mark, without]
	)

	# E la leggenda del fatto richiama quanto il fatto (D-075).
	var legend: Dictionary = {
		"global_tags": ["legend:mine_sealed"], "regions": {}, "relations": {}, "entities": {},
	}
	assert_eq(
		WorldStateFactory.resolve_tensions(chronicle, RngService.new(4242), legend),
		first,
		"stesso seed, il richiamo della leggenda e' il richiamo del fatto"
	)


## D-087: il conto rimasto aperto richiama la sua domanda. Una clausola
## `tension_limit` negata nell'era prima pesa nella pesca come un segno sul
## mondo (D-079) - e' la prima lettura strutturata delle evidence.
func test_an_open_account_calls_its_question_into_the_draw() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_02"]
	var bare: Dictionary = {
		"global_tags": [], "regions": {}, "relations": {}, "entities": {},
	}
	var owed: Dictionary = {
		"ENT_ALDRIC": {"level": "MINIMUM", "unmet": [
			{"type": "tension_limit", "tension_id": "TEN_PLAGUE", "max": 3},
		]},
	}
	var with_account: int = 0
	var without: int = 0
	for seed_value in range(6000, 6100):
		if WorldStateFactory.resolve_tensions(
			chronicle, RngService.new(seed_value), bare, owed
		).has("TEN_PLAGUE"):
			with_account += 1
		if WorldStateFactory.resolve_tensions(
			chronicle, RngService.new(seed_value), bare
		).has("TEN_PLAGUE"):
			without += 1
	assert_true(
		with_account > without,
		"il conto aperto pesa: Febbre %d/100 col conto, %d/100 senza" % [with_account, without]
	)
	# E a parita' di seme e di conti, la pesca resta la stessa.
	assert_eq(
		WorldStateFactory.resolve_tensions(chronicle, RngService.new(4242), bare, owed),
		WorldStateFactory.resolve_tensions(chronicle, RngService.new(4242), bare, owed),
		"stesso seme e stessi conti, stessa mano"
	)


## D-088 (Fase 2 del motore 0.3): la domanda lasciata calda torna calda.
## Il confine e' quello della memoria (D-075): un salto breve ricorda il
## calore, un salto lungo lo sbiadisce - e non si riparte mai gia' a soglia.
func test_a_question_left_hot_starts_warm_after_a_short_jump() -> void:
	var definition: Dictionary = data().tensions["TEN_FAMINE"]
	assert_eq(int(definition["current_value"]), 3, "il valore d'autore della Carestia e' 3")
	assert_eq(int(definition["threshold"]), 6, "e la sua soglia e' 6")

	var hot: Dictionary = {"tensions": {"TEN_FAMINE": {"current_value": 6}}}
	assert_eq(
		WorldStateFactory.inherited_tension_value("TEN_FAMINE", definition, hot, 20), 5,
		"lasciata a soglia, torna tiepida a soglia meno uno: mai bollente"
	)
	assert_eq(
		WorldStateFactory.inherited_tension_value("TEN_FAMINE", definition, hot, 120), 3,
		"su un secolo il calore sbiadisce: si riparte dal valore d'autore"
	)
	var quiet: Dictionary = {"tensions": {"TEN_FAMINE": {"current_value": 0}}}
	assert_eq(
		WorldStateFactory.inherited_tension_value("TEN_FAMINE", definition, quiet, 20), 0,
		"una questione chiusa bene riparte quieta, anche sotto il valore scritto"
	)
	var absent: Dictionary = {"tensions": {}}
	assert_eq(
		WorldStateFactory.inherited_tension_value("TEN_FAMINE", definition, absent, 20), 3,
		"una questione che l'era prima non aveva riparte dal valore d'autore"
	)


## D-089 (Fase 3 del motore 0.3): il verbale d'apertura. L'era nuova sa dire
## *perche'* ha in mano le sue domande - il segno che l'ha richiamata, il conto
## che qualcuno ha lasciato aperto, il calore con cui riparte - e la prosa
## nomina le cose per nome. Solo lettura: costruirlo due volte da' lo stesso
## verbale, e non consuma un solo tiro.
func test_the_opening_record_says_why_each_question_is_on_the_table() -> void:
	var loaded: RefCounted = data()
	var chronicle: Dictionary = loaded.chronicles["CHR_02"]
	var world: Dictionary = {"tensions": {
		"TEN_AWAKENING": {"current_value": 2},
		"TEN_PLAGUE": {"current_value": 4},
		"TEN_FAMINE": {"current_value": 3},
	}}
	var previous: Dictionary = {
		"global_tags": ["legend:mine_sealed"],
		"regions": {},
		"entities": {"ENT_ALDRIC": {"name": "Re Aldric II"}},
		"tensions": {},
	}
	var results: Dictionary = {
		"ENT_ALDRIC": {"level": "MINIMUM", "unmet": [
			{"type": "tension_limit", "tension_id": "TEN_PLAGUE", "max": 3},
		]},
	}

	var record: Array = WorldStateFactory.opening_record(
		world, chronicle, loaded, previous, results
	)
	assert_eq(record.size(), 3, "una voce per domanda in mano")
	assert_eq(
		record, WorldStateFactory.opening_record(world, chronicle, loaded, previous, results),
		"solo lettura: due costruzioni, lo stesso verbale"
	)

	var by_id: Dictionary = {}
	for entry in record:
		by_id[str((entry as Dictionary)["tension_id"])] = entry
	var awakening: Array = (by_id["TEN_AWAKENING"] as Dictionary)["called_by"]
	assert_eq(awakening.size(), 1, "il Risveglio e' richiamato da un segno solo")
	assert_eq(str((awakening[0] as Dictionary)["carried"]), "legend", "ed e' la leggenda della miniera")
	assert_eq(str((awakening[0] as Dictionary)["tag"]), "mine_sealed", "nominata per nome")
	var plague: Array = (by_id["TEN_PLAGUE"] as Dictionary)["called_by"]
	assert_eq(plague.size(), 1, "la Febbre e' richiamata dal conto aperto")
	assert_eq(str((plague[0] as Dictionary)["name"]), "Re Aldric II", "di chi l'ha lasciato: il nome dell'era prima")
	assert_true(
		((by_id["TEN_FAMINE"] as Dictionary)["called_by"] as Array).is_empty(),
		"la Carestia non e' richiamata da niente: biblioteca"
	)

	var lines: Array = WorldStateFactory.opening_lines(record, loaded)
	assert_eq(lines.size(), 3, "una riga di prosa per domanda")
	var text: String = "\n".join(PackedStringArray(lines))
	assert_true(text.contains("se ne racconta ancora la leggenda ('mine_sealed')"), "la leggenda si legge")
	assert_true(text.contains("Re Aldric II non l'ha mai chiusa"), "il conto aperto nomina chi l'ha lasciato")
	assert_true(text.contains("esce dalla biblioteca"), "e il caso resta il caso")
	assert_true(
		text.contains("Apre a 4, non al 2 d'autore"),
		"il calore ereditato (D-088) sta nel verbale con i suoi numeri"
	)

	# E un anno scritto non verbalizza: le sue domande non sono pescate.
	assert_true(
		WorldStateFactory.opening_record(
			world, loaded.chronicles["CHR_01"], loaded, previous, results
		).is_empty(),
		"CHR_01 non ha pool: niente verbale"
	)


## D-090: il verbale della mappa. Come si piazza la mappa dell'era nuova -
## derivato dagli stessi inheritance_effects che la piazzano, quindi non puo'
## mentire: chi c'era tiene, chi non c'era decade (D-027), le condizioni
## sbiadiscono su un secolo (D-078), i fatti non eterni diventano leggende
## (D-075) e la guerra si ricorda come rancore (D-045).
func test_the_map_record_says_how_the_new_era_is_placed() -> void:
	var loaded: RefCounted = data()
	var session_two: RefCounted = GameSession.new(loaded)
	assert_true(session_two.setup("CHR_02", LIBRARY_SEATS, 4242), "CHR_02 si prepara")
	var previous: Dictionary = {
		"year": 812,
		"global_tags": ["grain_requisitioned", "mine_sealed"],
		"regions": {
			"REG_EREDAN": {"id": "REG_EREDAN", "control": "ENT_ALDRIC", "tags": []},
			"REG_TERRE_NAHR": {
				"id": "REG_TERRE_NAHR", "control": "ENT_NAHR",
				"tags": ["condition:mourning"],
			},
		},
		"relations": {"ENT_ALDRIC|ENT_NAHR": {"level": "HOSTILE", "tags": []}},
		"entities": {
			"ENT_ALDRIC": {"id": "ENT_ALDRIC", "name": "Re Aldric", "presence": ["REG_EREDAN"]},
			"ENT_NAHR": {"id": "ENT_NAHR", "name": "Popolo Nahr", "presence": []},
		},
		"tensions": {},
	}

	var record: Dictionary = WorldStateFactory.map_record(
		session_two.world, loaded.chronicles["CHR_02"], loaded, previous, 120
	)
	var by_region: Dictionary = {}
	for entry in record["regions"]:
		by_region[str((entry as Dictionary)["region_id"])] = entry
	assert_eq(
		str((by_region["REG_EREDAN"] as Dictionary)["holder"]), "ENT_ALDRIC",
		"chi c'era tiene quello che teneva"
	)
	assert_eq(
		(by_region["REG_TERRE_NAHR"] as Dictionary)["holder"], null,
		"chi non c'era perde (D-027)"
	)
	assert_true(
		bool((by_region["REG_TERRE_NAHR"] as Dictionary)["lapsed"]),
		"e il verbale lo dice: decaduto, non mai avuto"
	)
	assert_true(
		((by_region["REG_TERRE_NAHR"] as Dictionary)["faded"] as Array).has("condition:mourning"),
		"un lutto non dura un secolo (D-078)"
	)
	assert_true(
		(record["legends_born"] as Array).has("grain_requisitioned"),
		"il fatto non eterno diventa leggenda su un salto lungo"
	)
	assert_false(
		(record["legends_born"] as Array).has("mine_sealed"),
		"il fatto eterno resta un fatto: nessuna leggenda"
	)
	assert_eq(int(record["relations_softened"]), 1, "la guerra si ricorda come rancore")

	var text: String = "\n".join(PackedStringArray(
		WorldStateFactory.map_lines(record, loaded, session_two.world)
	))
	assert_true(text.contains("chi la teneva non c'era"), "la decadenza si legge")
	assert_true(text.contains("'condition:mourning' e' sbiadito"), "lo sbiadimento si legge")
	assert_true(text.contains("'grain_requisitioned'"), "la leggenda nuova si legge")
	assert_true(text.contains("rancore"), "e l'ammorbidirsi dei rapporti pure")

	# Su un salto breve il tempo non ha ancora fatto niente: la condizione
	# resta in corso, nessuna leggenda nasce, i rapporti restano interi.
	# Solo la decadenza del controllo resta: e' questione di presenza, non di anni.
	var short_record: Dictionary = WorldStateFactory.map_record(
		session_two.world, loaded.chronicles["CHR_02"], loaded, previous, 20
	)
	for entry in short_record["regions"]:
		if str((entry as Dictionary)["region_id"]) == "REG_TERRE_NAHR":
			assert_true(((entry as Dictionary)["faded"] as Array).is_empty(), "a vent'anni il lutto e' ancora in corso")
			assert_true(((entry as Dictionary)["marks"] as Array).has("condition:mourning"), "e sta fra i segni della mappa")
			assert_true(bool((entry as Dictionary)["lapsed"]), "ma la Regione decade lo stesso: nessuno c'era")
	assert_true((short_record["legends_born"] as Array).is_empty(), "nessuna leggenda a vent'anni")
	assert_eq(int(short_record["relations_softened"]), 0, "e il rancore e' ancora guerra")
	session_two.dispose()


## E la ripesca di `inherit_from` rida' anche il sacchetto del Drift: ogni
## chip del sacchetto nomina una Tensione dell'anno ripescato, non di quello
## pescato alla cieca al setup.
func test_the_redeal_rebuilds_the_drift_bag_over_the_new_hand() -> void:
	var session_two: RefCounted = GameSession.new(data())
	assert_true(session_two.setup("CHR_02", LIBRARY_SEATS, 4242), "CHR_02 si prepara")
	var previous: Dictionary = {
		"year": 812,
		"global_tags": ["mine_sealed"], "regions": {}, "relations": {}, "entities": {},
	}
	session_two.inherit_from(previous)
	for tension_id in session_two.world["drift_track"]:
		assert_true(
			(session_two.world["tensions"] as Dictionary).has(str(tension_id)),
			"il chip %s appartiene all'anno ripescato" % str(tension_id)
		)
	session_two.dispose()


## D-095: la saga sa chi viene dopo. L'era successiva e' la biblioteca che
## siede lo stesso tavolo - il criterio con cui run_saga incatena le ere,
## adesso scritto nei dati una volta sola e usato anche dall'app.
func test_every_age_knows_which_library_continues_it() -> void:
	var loaded: RefCounted = data()
	assert_eq(loaded.library_sequel_of("CHR_01"), "CHR_02", "la prima eta' prosegue nella sua biblioteca")
	assert_eq(loaded.library_sequel_of("CHR_02"), "CHR_02", "una biblioteca prosegue se stessa")
	assert_eq(loaded.library_sequel_of("CHR_03"), "CHR_04", "la seconda eta' nella sua")
	assert_eq(loaded.library_sequel_of("CHR_04"), "CHR_04", "e anche lei prosegue se stessa")
	assert_eq(loaded.library_sequel_of("CHR_MAI_SCRITTA"), "", "un'eta' sconosciuta non ha seguito")


## The whole point: a Chronicle assembled from the library plays to the end.
func test_a_library_chronicle_plays_to_the_end() -> void:
	var session_two: RefCounted = GameSession.new(data())
	assert_true(session_two.setup("CHR_02", LIBRARY_SEATS, 7777), "CHR_02 si prepara")
	assert_eq((session_two.world["tensions"] as Dictionary).size(), 4, "quattro domande pescate")
	var report: Dictionary = await session_two.run(PolicyDecider.new(session_two.log))
	assert_eq(int(report["illegal_actions"]), 0, "nessuna scelta illegale")
	assert_true(int(session_two.world["confluence_count"]) > 0, "almeno una Confluence si apre")
	session_two.dispose()
