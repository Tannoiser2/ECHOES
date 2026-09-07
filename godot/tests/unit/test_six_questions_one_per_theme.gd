extends "res://tests/test_case.gd"
## **Sei Tensioni, una per Tema, sempre** (D-467, giro 1).
##
## Il committente: *«ci devono essere 6 tensioni, una per tema; altrimenti se
## ci sono 3 tensioni tutte di un tema quale viene scaldata?»*. Prima se ne
## pescavano quattro su sei Temi, e un gettone poteva cadere su un Tema senza
## niente da scaldare. Queste prove tengono la pesca — su un mazzo fabbricato,
## cosi' non smettono di provare quando i dati cambiano — e il tavolo vero.

const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


## Un mazzo fabbricato: nove candidate su tre Temi, tre per Tema.
func _pool() -> Dictionary:
	var candidates: Array = []
	for theme in ["THM_A", "THM_B", "THM_C"]:
		for n in range(3):
			candidates.append("TEN_%s_%d" % [theme.trim_prefix("THM_"), n])
	return {"tension_pool": {"candidates": candidates, "count": 3, "per_theme": true}}


func _themes() -> Dictionary:
	var out: Dictionary = {}
	for tension_id in (_pool()["tension_pool"]["candidates"] as Array):
		out[str(tension_id)] = "THM_%s" % str(tension_id).split("_")[1]
	return out


func test_one_question_per_theme_and_every_theme_served() -> void:
	var drawn: Array = WorldStateFactory.resolve_tensions(_pool(), RngService.new(7), {}, {}, _themes())
	assert_eq(drawn.size(), 3, "tre Temi, tre domande")
	var themes: Dictionary = _themes()
	var seen: Dictionary = {}
	for tension_id in drawn:
		seen[str(themes[str(tension_id)])] = true
	assert_eq(seen.size(), 3, "e nessun Tema resta senza: %s" % str(drawn))


func test_the_draw_is_seeded_and_varies_by_seed() -> void:
	var first: Array = WorldStateFactory.resolve_tensions(_pool(), RngService.new(7), {}, {}, _themes())
	var again: Array = WorldStateFactory.resolve_tensions(_pool(), RngService.new(7), {}, {}, _themes())
	assert_eq(first, again, "stesso seme, stessa mano")
	var distinct: Dictionary = {}
	for seed_value in range(1, 21):
		distinct[str(WorldStateFactory.resolve_tensions(_pool(), RngService.new(seed_value), {}, {}, _themes()))] = true
	assert_true(distinct.size() > 1, "semi diversi danno anni diversi")


## Senza la mappa dei Temi la pesca resta quella di sempre: `count` a caso.
## E' cosi' che le Chronicle di prova scritte a mano continuano a girare.
func test_without_themes_the_old_draw_holds() -> void:
	var drawn: Array = WorldStateFactory.resolve_tensions(_pool(), RngService.new(7))
	assert_eq(drawn.size(), 3, "ne pesca count")


## Un Tema senza candidate sul tavolo resta senza domanda, e lo si vede: la
## pesca non inventa una carta di un altro Tema per riempire il posto.
func test_a_theme_without_candidates_stays_empty() -> void:
	var pool: Dictionary = _pool()
	var kept: Array = []
	for tension_id in (pool["tension_pool"]["candidates"] as Array):
		if not str(tension_id).begins_with("TEN_C_"):
			kept.append(tension_id)
	(pool["tension_pool"] as Dictionary)["candidates"] = kept
	var drawn: Array = WorldStateFactory.resolve_tensions(pool, RngService.new(7), {}, {}, _themes())
	assert_eq(drawn.size(), 2, "due Temi serviti, il terzo no")


## `always` serve il suo Tema: quel Tema non pesca una seconda domanda.
func test_an_always_question_serves_its_theme() -> void:
	var pool: Dictionary = _pool()
	(pool["tension_pool"] as Dictionary)["always"] = ["TEN_B_2"]
	var drawn: Array = WorldStateFactory.resolve_tensions(pool, RngService.new(7), {}, {}, _themes())
	assert_eq(drawn.size(), 3, "tre domande in tutto")
	assert_true(drawn.has("TEN_B_2"), "quella dichiarata c'e'")
	var of_b: int = 0
	for tension_id in drawn:
		if str(tension_id).begins_with("TEN_B_"):
			of_b += 1
	assert_eq(of_b, 1, "e il suo Tema non ne pesca un'altra")


## Il tavolo vero: CHR_00 apre l'anno con una domanda per ognuno dei sei Temi,
## e ogni mazzetto e' quella carta, gia' girata. Una partita tutta sua, letta
## dai file: la Chronicle di prova gioca le domande scritte a mano.
func test_the_shipped_table_opens_with_six_questions_turned() -> void:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	var live: RefCounted = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 7000)
	assert_true(live.setup("CHR_00", seats, 7000), "e l'anno si apre")
	var themes: Dictionary = WorldStateFactory.themes_of(loaded)
	var seen: Dictionary = {}
	for tension_id in live.world["tensions"]:
		seen[str(themes[str(tension_id)])] = true
	assert_eq(live.world["tensions"].size(), loaded.themes.size(), "sei domande in gioco")
	assert_eq(seen.size(), loaded.themes.size(), "una per Tema")
	for theme_id in loaded.themes:
		assert_ne(live.tensions.theme_front(str(theme_id)), "", "il Tema %s ha la sua carta girata" % str(theme_id))
		assert_true(
			((live.world["theme_decks"] as Dictionary)[str(theme_id)] as Array).is_empty(),
			"e sotto non c'e' altro da girare"
		)
	live.dispose()
