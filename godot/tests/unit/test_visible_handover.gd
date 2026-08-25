extends "res://tests/test_case.gd"
## Il tavolo si rimonta leggendo solo quello che c'e' sopra (PZ-6, D-269).
##
## La roadmap lo chiede cosi': *la Chronicle successiva nasce dai segni
## visibili, e si puo' rimontare il tavolo leggendo solo quello che c'e'
## sopra*. La prova e' letterale: si gioca un anno intero, si spoglia il mondo
## finale fino al **tavolo visibile** (`visible_table.gd` - la lista chiusa
## dei pezzi fisici), e si eredita due volte con lo stesso seme - una dal
## mondo intero, una dal solo visibile. Se i due mondi che nascono non sono
## identici, l'eredita' sta leggendo qualcosa che sul tavolo non c'e', e la
## procedura fisica (docs/PROCEDURA_FINE_CHRONICLE.md) mentirebbe.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const VisibleTable := preload("res://scripts/chronicle/visible_table.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


## Un anno intero di CHR_01 al seme dato: torna il mondo finale e i Destini
## letti a fine anno - le due cose che la procedura di fine Chronicle
## consegna all'era dopo.
func _played_year(seed_value: int) -> Dictionary:
	new_session(seed_value, false)
	var report: Dictionary = await session.run(PolicyDecider.new(session.log))
	assert_false(report.is_empty(), "l'anno al seme %d arriva in fondo" % seed_value)
	return {
		"world": session.world.duplicate(true),
		"results": report.get("destiny_results", {}),
	}


func _inherited(next_id: String, previous: Dictionary, results: Dictionary, seed_value: int) -> Dictionary:
	var next_session: RefCounted = GameSession.new(data())
	assert_true(
		next_session.setup(next_id, SEATS, seed_value),
		"il setup di %s riesce: %s" % [next_id, next_session.last_error]
	)
	next_session.inherit_from(previous, results)
	var born: Dictionary = next_session.world.duplicate(true)
	next_session.dispose()
	return born


## **La prova madre**: mondo intero e tavolo visibile generano la stessa era.
func test_the_next_chronicle_is_born_from_the_visible_table_alone() -> void:
	var year: Dictionary = await _played_year(4242)
	var full: Dictionary = _inherited("CHR_02", year["world"], year["results"], 4242)
	var bare: Dictionary = _inherited(
		"CHR_02", VisibleTable.read(year["world"]), year["results"], 4242
	)
	assert_eq(
		canonical(bare), canonical(full),
		"l'era nuova nasce dal solo tavolo visibile: niente stato nascosto nell'eredita'"
	)


## E non e' un caso del seme: altri due semi, stessa verita'.
func test_the_visible_table_is_enough_on_other_seeds() -> void:
	for seed_value in [9100, 5511]:
		var year: Dictionary = await _played_year(seed_value)
		var full: Dictionary = _inherited("CHR_02", year["world"], year["results"], seed_value)
		var bare: Dictionary = _inherited(
			"CHR_02", VisibleTable.read(year["world"]), year["results"], seed_value
		)
		assert_eq(
			canonical(bare), canonical(full),
			"seme %d: il tavolo visibile basta" % seed_value
		)


## E vale anche sul tavolo pescato: la saga di CHR_00 eredita se stessa - la
## mappa e' della saga (D-263) - e anche li' il tavolo visibile basta.
func test_the_drawn_table_inherits_from_the_visible_alone() -> void:
	var seed_value: int = 7007
	var seats: Array = GameSession.seats_for(data(), "CHR_00", seed_value)
	if session != null:
		session.dispose()
	session = GameSession.new(data())
	assert_true(session.setup("CHR_00", seats, seed_value), "il setup di CHR_00 riesce")
	var report: Dictionary = await session.run(PolicyDecider.new(session.log))
	assert_false(report.is_empty(), "l'anno pescato arriva in fondo")
	var world: Dictionary = session.world.duplicate(true)
	var results: Dictionary = report.get("destiny_results", {})

	var full: Dictionary = _inherit_chr00(seats, world, results, seed_value)
	var bare: Dictionary = _inherit_chr00(seats, VisibleTable.read(world), results, seed_value)
	assert_eq(
		canonical(bare), canonical(full),
		"anche la saga pescata rinasce dal solo tavolo visibile"
	)


func _inherit_chr00(seats: Array, previous: Dictionary, results: Dictionary, seed_value: int) -> Dictionary:
	var next_session: RefCounted = GameSession.new(data())
	assert_true(
		next_session.setup("CHR_00", seats, seed_value + 1),
		"il setup del sequel riesce: %s" % next_session.last_error
	)
	next_session.inherit_from(previous, results)
	var born: Dictionary = next_session.world.duplicate(true)
	next_session.dispose()
	return born


## Il tavolo visibile e' davvero piu' povero del mondo: la prova non deve
## poter passare per pigrizia. Se lo spoglio non toglie niente, non prova
## niente.
func test_the_visible_table_actually_strips_hidden_state() -> void:
	var year: Dictionary = await _played_year(4242)
	var world: Dictionary = year["world"] as Dictionary
	var bare: Dictionary = VisibleTable.read(world)
	for hidden in ["decks", "voted_together", "questions_asked", "effect_log", "rng_state"]:
		assert_false(bare.has(str(hidden)), "il tavolo visibile non porta '%s'" % str(hidden))
	assert_true(world.has("decks"), "il mondo intero i mazzi li aveva: lo spoglio ha tolto davvero")
	var seat: Dictionary = bare["entities"].values()[0] as Dictionary
	assert_false(seat.has("hand"), "le mani non passano: si ridanno all'era nuova")
