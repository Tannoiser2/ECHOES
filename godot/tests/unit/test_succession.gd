extends "res://tests/test_case.gd"
## What crosses the gap between two Chronicles (D-045).
##
## The audit that produced this file played ten Chronicles and got *"la corona
## fu divisa in due"* six times, because the engine added one year and sat the
## same king back down. Everything here is a guard on the three things that
## carry - position, relations, Destiny - and on the one thing that must not:
## the person.

const Succession := preload("res://scripts/chronicle/succession.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
# GameSession arriva da test_case.gd: ridichiararlo qui e un errore di parsing.
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _chronicle(id: String) -> Dictionary:
	return data().chronicles[id]


## A written year says one year; a library Chronicle draws a span, and draws the
## same one from the same seed.
func test_the_jump_is_declared_by_the_chronicle() -> void:
	assert_eq(
		Succession.years_between(_chronicle("CHR_01"), RngService.new(1)), 1,
		"la Chronicle scritta a mano e l'anno dopo"
	)
	var first: int = Succession.years_between(_chronicle("CHR_02"), RngService.new(4242))
	var again: int = Succession.years_between(_chronicle("CHR_02"), RngService.new(4242))
	assert_eq(first, again, "stesso seme, stesso salto")
	assert_true(first >= 20 and first <= 200, "e sta nell'intervallo dichiarato: %d" % first)


## A person does not cross two centuries. A people and a thing under a mountain
## do, and keep their name while doing it.
func test_only_mortals_are_replaced_and_only_after_a_lifetime() -> void:
	var previous: Dictionary = {"entities": {}}
	var long_jump: Dictionary = Succession.plan(
		previous, {}, _chronicle("CHR_02"), data(), 120
	)
	assert_eq(str(long_jump["ENT_ALDRIC"]["name"]), "Re Serane", "il trono passa")
	assert_true(bool(long_jump["ENT_ALDRIC"]["changed"]), "ed e dichiarato un passaggio")
	assert_eq(int(long_jump["ENT_ALDRIC"]["generation"]), 1, "prima generazione dopo la fondatrice")
	assert_eq(str(long_jump["ENT_NAHR"]["name"]), "Popolo Nahr", "un popolo non si eredita")
	assert_eq(str(long_jump["ENT_VAERAX"]["name"]), "Vaerax", "e il tempo non tocca Vaerax")

	var short_jump: Dictionary = Succession.plan(
		previous, {}, _chronicle("CHR_02"), data(), 3
	)
	assert_eq(
		str(short_jump["ENT_ALDRIC"]["name"]), "Re Aldric",
		"tre anni dopo al trono c'e ancora la stessa persona"
	)


## A saga has no agreed number of generations, so a hand-written list of names
## is a list that runs out - and the first audit of this feature wore four names
## out at the sixth jump, seating a second "Re Serane" four centuries after the
## first. Thirty generations, thirty names (D-046).
func test_a_house_never_runs_out_of_names() -> void:
	for entity_id in ["ENT_ALDRIC", "ENT_LYRA"]:
		var definition: Dictionary = data().entities[str(entity_id)]
		var successors: Array = definition.get("successors", [])
		var seen: Dictionary = {}
		for generation in range(1, 31):
			var name: String = (
				str(successors[generation - 1]["name"]) if generation <= successors.size()
				else Succession.compose_name(definition, generation - successors.size())
			)
			assert_true(name != "", "%s, generazione %d ha un nome" % [entity_id, generation])
			assert_false(
				seen.has(name),
				"%s: '%s' si ripete alla generazione %d" % [entity_id, name, generation]
			)
			seen[name] = true

		# And it is a pure function of the generation: the same house asked twice
		# for the same generation gives the same person, which is what keeps a
		# saga replayable from its seed.
		assert_eq(
			Succession.compose_name(definition, 9), Succession.compose_name(definition, 9),
			"%s: stessa generazione, stesso nome" % entity_id
		)


## The one that stops a saga from being a rerun: you try again for what you
## missed, and you want something else once you have it.
func test_a_seat_keeps_the_destiny_it_failed_and_drops_the_one_it_won() -> void:
	var previous: Dictionary = {"entities": {}}
	var failed: Dictionary = Succession.plan(
		previous, {"ENT_ALDRIC": {"level": "MINIMUM"}}, _chronicle("CHR_02"), data(), 1
	)
	assert_eq(
		str(failed["ENT_ALDRIC"]["destiny_id"]), "DST_ALDRIC",
		"chi ha solo tenuto il minimo riprova con lo stesso Destino"
	)
	assert_false(bool(failed["ENT_ALDRIC"]["wants_new"]), "e non e un Destino nuovo")

	for level in ["VICTORY", "TRIUMPH"]:
		var won: Dictionary = Succession.plan(
			previous, {"ENT_ALDRIC": {"level": str(level)}}, _chronicle("CHR_02"), data(), 1
		)
		assert_eq(
			str(won["ENT_ALDRIC"]["destiny_id"]), "DST_ALDRIC_RECORD",
			"chi ha ottenuto (%s) vuole la cosa dopo" % level
		)
		assert_true(bool(won["ENT_ALDRIC"]["wants_new"]), "ed e segnato come nuovo")


## D-081: l'iniquita' del tempo. Chi otteneva cambiava ambizione e chi falliva
## riprovava la stessa per mille anni. Il Destino e' della persona: l'erede che
## si siede dopo tre ere a mani vuote giura su altro; chi non cambia persona -
## la stessa vita, un popolo, la cosa sotto la montagna - non si stanca.
func test_an_heir_does_not_swear_on_a_failed_ambition() -> void:
	# `barren` e' il contatore alla fine dell'era precedente: con 2 gia'
	# segnate, l'era appena chiusa a mani vuote e' la terza che l'erede vede.
	var worn: Dictionary = {"entities": {
		"ENT_ALDRIC": {"name": "Re Aldric", "destiny_id": "DST_ALDRIC", "generation": 0, "barren": 2},
		"ENT_VAERAX": {"name": "Vaerax", "destiny_id": "DST_VAERAX", "generation": 0, "barren": 9},
	}}
	var heirs: Dictionary = Succession.plan(worn, {}, _chronicle("CHR_02"), data(), 120)
	assert_eq(
		str(heirs["ENT_ALDRIC"]["destiny_id"]), "DST_ALDRIC_RECORD",
		"l'erede dopo tre ere a mani vuote vuole un'altra cosa"
	)
	assert_true(bool(heirs["ENT_ALDRIC"]["weary"]), "ed e' dichiarata stanchezza, non premio")
	assert_false(bool(heirs["ENT_ALDRIC"]["wants_new"]), "perche' nessuno ha ottenuto niente")
	assert_eq(int(heirs["ENT_ALDRIC"]["barren"]), 0, "e la nuova ambizione parte senza conti aperti")
	assert_eq(
		str(heirs["ENT_VAERAX"]["destiny_id"]), "DST_VAERAX",
		"quello che non cambia persona non si stanca mai"
	)

	# La stessa persona non abbandona la propria ambizione, per quante ere
	# abbia perso: il salto breve non cambia la generazione e non cambia niente.
	var same_life: Dictionary = Succession.plan(worn, {}, _chronicle("CHR_02"), data(), 3)
	assert_eq(
		str(same_life["ENT_ALDRIC"]["destiny_id"]), "DST_ALDRIC",
		"la stessa persona riprova finche' vive"
	)

	# E due delusioni sono sfortuna, non una tradizione: non bastano (0.1.36,
	# soglia a tre per scelta del committente).
	var twice: Dictionary = {"entities": {
		"ENT_ALDRIC": {"name": "Re Aldric", "destiny_id": "DST_ALDRIC", "generation": 0, "barren": 1},
	}}
	assert_eq(
		str(Succession.plan(twice, {}, _chronicle("CHR_02"), data(), 120)["ENT_ALDRIC"]["destiny_id"]),
		"DST_ALDRIC",
		"un erede che ha visto due ere fallite ci riprova ancora"
	)


## Il contatore delle ere a mani vuote: sale quando non si ottiene, si azzera
## quando si ottiene (la rotazione da premio riparte pulita).
func test_barren_eras_are_counted_and_reset_by_achievement() -> void:
	var previous: Dictionary = {"entities": {
		"ENT_ALDRIC": {"name": "Re Aldric", "destiny_id": "DST_ALDRIC", "generation": 0, "barren": 1},
	}}
	var failed: Dictionary = Succession.plan(
		previous, {"ENT_ALDRIC": {"level": "MINIMUM"}}, _chronicle("CHR_02"), data(), 3
	)
	assert_eq(int(failed["ENT_ALDRIC"]["barren"]), 2, "un'altra era a mani vuote si conta")
	var won: Dictionary = Succession.plan(
		previous, {"ENT_ALDRIC": {"level": "VICTORY"}}, _chronicle("CHR_02"), data(), 3
	)
	assert_eq(int(won["ENT_ALDRIC"]["barren"]), 0, "ottenere chiude i conti")
	assert_true(bool(won["ENT_ALDRIC"]["wants_new"]), "e la rotazione resta quella da premio")


## Time softens what people felt about each other; it does not reconcile them,
## and it does not invent hatred where there was none.
func test_a_long_jump_moves_every_relation_one_step_towards_neutral() -> void:
	assert_eq(Succession.decayed("ENEMY"), "HOSTILE", "un odio diventa un rancore")
	assert_eq(Succession.decayed("HOSTILE"), "NEUTRAL", "e un rancore si dimentica")
	assert_eq(Succession.decayed("BOUND"), "ALLY", "un patto diventa una cortesia")
	assert_eq(Succession.decayed("ALLY"), "NEUTRAL", "e una cortesia finisce")
	assert_eq(Succession.decayed("NEUTRAL"), "NEUTRAL", "il nulla resta nulla")
	assert_false(Succession.decays_after(10), "dieci anni non cambiano niente")
	assert_true(Succession.decays_after(120), "un secolo si")


## End to end: two Chronicles chained. The year moves by the declared span, the
## people change, and every id the world wrote about still means something -
## which is the whole reason the seat and the person are different things.
func test_a_chained_chronicle_keeps_the_world_and_changes_the_table() -> void:
	new_session(4242, false)
	var first: Dictionary = await session.run(PolicyDecider.new(session.log))
	var before_world: Dictionary = session.world.duplicate(true)
	var before_year: int = int(session.world["year"])
	var held: Dictionary = {}
	for region_id in session.world["regions"]:
		held[str(region_id)] = session.world["regions"][str(region_id)].get("control", null)

	var second: RefCounted = GameSession.new(data())
	second.setup("CHR_02", SEATS, 4242)
	second.inherit_from(before_world, first["destiny_results"])

	assert_eq(
		int(second.world["year"]) - before_year, second.years_passed(),
		"l'anno avanza esattamente del salto dichiarato"
	)
	assert_true(second.years_passed() >= 20, "e con CHR_02 e un salto lungo")
	assert_ne(
		second.service.name_of("ENT_ALDRIC"), "Re Aldric",
		"al trono non c'e piu la stessa persona"
	)
	assert_eq(second.service.name_of("ENT_VAERAX"), "Vaerax", "sotto la montagna si")

	await second.run(PolicyDecider.new(second.log))
	# The map survived the century: whatever was held at the end of the first
	# Chronicle is still attributed to a seat that exists.
	for region_id in second.world["regions"]:
		var control: Variant = second.world["regions"][str(region_id)].get("control", null)
		if control != null:
			assert_true(
				second.world["entities"].has(str(control)),
				"%s e controllata da un seggio che esiste ancora" % str(region_id)
			)
	second.dispose()


## D-075: la memoria che sbiadisce. Su un salto lungo resta un fatto solo
## quello che e' murato o scritto; il resto diventa leggenda, e una leggenda
## attraversa ogni salto successivo. Su un salto breve si ricorda tutto.
func test_time_turns_unwritten_facts_into_legends() -> void:
	var previous: Dictionary = {
		"global_tags": ["mine_sealed", "order_restored", "legend:oath_broken", "function:REQUEST"],
		"regions": {}, "relations": {}, "entities": {},
	}
	var effects: Array = preload("res://scripts/world/world_state_factory.gd").inheritance_effects(
		previous, _chronicle("CHR_02"), data(), 120
	)
	var carried: Array = []
	for effect in effects:
		if str(effect["type"]) == "SET_GLOBAL_TAG":
			carried.append(str(effect["payload"]["tag"]))
	assert_true(carried.has("mine_sealed"), "quello che e' murato resta un fatto")
	assert_false(carried.has("order_restored"), "una consuetudine non attraversa un secolo")
	assert_true(carried.has("legend:order_restored"), "ma non sparisce: diventa leggenda")
	assert_true(carried.has("legend:oath_broken"), "e una leggenda gia' nata attraversa il salto")
	assert_false(carried.has("legend:legend:oath_broken"), "senza diventare leggenda di se stessa")
	for tag in carried:
		assert_false(str(tag).begins_with("legend:function:"), "la grammatica non lascia leggende")

	# Un salto breve ricorda tutto com'era.
	var soon: Array = preload("res://scripts/world/world_state_factory.gd").inheritance_effects(
		previous, _chronicle("CHR_02"), data(), 20
	)
	var kept: Array = []
	for effect in soon:
		if str(effect["type"]) == "SET_GLOBAL_TAG":
			kept.append(str(effect["payload"]["tag"]))
	assert_true(kept.has("order_restored"), "vent'anni dopo, l'ordine ristabilito e' ancora un fatto")


## D-078: il criterio di D-075 vale anche per la mappa. Una *condizione* e'
## stato sociale e su un salto lungo sbiadisce; cio' che e' murato o scritto -
## strutture, insediamenti - e la cicatrice, che e' la memoria visibile della
## mappa, restano.
func test_time_lets_conditions_fade_but_keeps_what_is_built() -> void:
	var previous: Dictionary = {
		"global_tags": [],
		"relations": {},
		"entities": {},
		"regions": {
			"REG_TERRE_NAHR": {
				"control": null,
				"tags": ["condition:mourning", "structure:canal", "settlement:march"],
			},
		},
	}
	var effects: Array = preload("res://scripts/world/world_state_factory.gd").inheritance_effects(
		previous, _chronicle("CHR_02"), data(), 120
	)
	var carried: Array = []
	for effect in effects:
		if str(effect["type"]) == "SET_REGION_TAG":
			carried.append(str(effect["payload"]["tag"]))
	assert_false(carried.has("condition:mourning"), "un lutto non e' in corso otto secoli dopo")
	assert_true(carried.has("structure:canal"), "il canale scavato resta")
	assert_true(carried.has("settlement:march"), "e l'insediamento pure")

	var soon: Array = preload("res://scripts/world/world_state_factory.gd").inheritance_effects(
		previous, _chronicle("CHR_02"), data(), 20
	)
	var kept: Array = []
	for effect in soon:
		if str(effect["type"]) == "SET_REGION_TAG":
			kept.append(str(effect["payload"]["tag"]))
	assert_true(kept.has("condition:mourning"), "vent'anni dopo il lutto si ricorda ancora")
