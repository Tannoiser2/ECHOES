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


## The whole point: a Chronicle assembled from the library plays to the end.
func test_a_library_chronicle_plays_to_the_end() -> void:
	var session_two: RefCounted = GameSession.new(data())
	assert_true(session_two.setup("CHR_02", LIBRARY_SEATS, 7777), "CHR_02 si prepara")
	assert_eq((session_two.world["tensions"] as Dictionary).size(), 4, "quattro domande pescate")
	var report: Dictionary = await session_two.run(PolicyDecider.new(session_two.log))
	assert_eq(int(report["illegal_actions"]), 0, "nessuna scelta illegale")
	assert_true(int(session_two.world["confluence_count"]) > 0, "almeno una Confluence si apre")
	session_two.dispose()
