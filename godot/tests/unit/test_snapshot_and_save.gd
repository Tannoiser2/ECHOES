extends "res://tests/test_case.gd"
## §18.3: snapshot restore past a CREATE_ECHO, and save/load round-trip with
## deep equality.

const Effect := preload("res://scripts/core/effect.gd")
const SaveSerializer := preload("res://scripts/core/save_serializer.gd")


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return Effect.source("developer", "TEST", "ENT_ALDRIC", 1, 1, 0)


## §6.3: undo cannot step past an irreversible Effect, so the way back is the
## snapshot SaveManager takes before every Confluence.
func test_snapshot_restores_past_an_echo() -> void:
	session.take_snapshot("pre-confluence")
	var before: String = canonical(session.world)

	session.applier.apply(
		Effect.make("ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": 3}, _source())
	)
	session.applier.apply(
		Effect.make(
			"CREATE_ECHO",
			"echo",
			"ECHO_0001",
			{
				"echo_id": "ECHO_0001",
				"title": "Prova",
				"summary": "Il consiglio decise.",
				"act": 1,
				"round": 1,
				"participants": ["ENT_ALDRIC"],
				"effect_ids": [],
			},
			_source()
		)
	)
	session.applier.apply(
		Effect.make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "dopo_echo"}, _source())
	)

	assert_eq((session.world["echo_log"] as Array).size(), 1, "l'Echo e stato scritto")
	assert_false(session.applier.undo_last(3), "l'undo si ferma contro l'Echo")

	assert_true(session.restore_snapshot(), "ripristino dello snapshot")
	assert_eq(canonical(session.world), before, "lo stato torna esattamente al pre-Confluence")
	assert_eq((session.world["echo_log"] as Array).size(), 0, "l'Echo non e mai stato scritto")


## The undo *can* walk back over anything reversible written after the snapshot.
func test_undo_stops_exactly_at_the_irreversible_effect() -> void:
	session.applier.apply(
		Effect.make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "prima"}, _source())
	)
	session.applier.apply(
		Effect.make(
			"APPEND_TRUTH",
			"truth",
			"TRU_0001",
			{"truth_id": "TRU_0001", "text": "Accadde.", "act": 1, "round": 1},
			_source()
		)
	)
	session.applier.apply(
		Effect.make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "dopo"}, _source())
	)

	assert_true(session.applier.undo_last(1), "il primo passo indietro e lecito")
	assert_false((session.world["global_tags"] as Array).has("dopo"), "il tag successivo e sparito")
	assert_false(session.applier.undo_last(1), "il secondo passo colpisce il Truth")
	assert_eq((session.world["truth_log"] as Array).size(), 1, "il Truth e ancora li")
	assert_true((session.world["global_tags"] as Array).has("prima"), "il tag precedente e intatto")


## §18.3: save/load round-trip with deep equality.
func test_save_load_round_trip() -> void:
	session.applier.apply(
		Effect.make("ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": 2}, _source())
	)
	session.applier.apply(
		Effect.make("SET_REGION_TAG", "region", "REG_EREDAN", {"tag": "structure:granary"}, _source())
	)
	var save: Dictionary = session.to_save("test")
	var text: String = SaveSerializer.to_json(save)

	var reloaded: Variant = SaveSerializer._restore_ints(JSON.parse_string(text))
	assert_eq(canonical(reloaded), canonical(save), "il salvataggio sopravvive al giro per JSON")

	var restored: RefCounted = new_session()
	assert_true(restored.restore(reloaded), "la sessione si ricostruisce dal salvataggio")
	assert_eq(canonical(restored.world), canonical(save["world_state"]), "WorldState identico")
	assert_eq(
		SaveSerializer.to_json(restored.to_save("test")),
		text,
		"risalvare produce lo stesso identico testo"
	)


## A save written twice from the same state must be byte-identical: this is what
## makes the determinism criterion in §18.3 checkable with cmp.
func test_save_text_is_stable() -> void:
	var first: String = SaveSerializer.to_json(session.to_save("x"))
	var second: String = SaveSerializer.to_json(session.to_save("x"))
	assert_eq(first, second, "due serializzazioni della stessa sessione coincidono")
	assert_false(first.contains("\"timestamp\""), "nessun orario nel salvataggio")


## Restoring must put the RNG back on exactly the same value it was about to
## produce, or a reloaded Chronicle would diverge from the original.
func test_rng_position_survives_a_save() -> void:
	for _i in range(7):
		session.rng.roll_d6()
	var save: Dictionary = session.to_save("rng")
	# rng_state counts every draw since the seed, the setup shuffles included.
	var draws: int = int(save["world_state"]["rng_state"])
	assert_eq(draws, session.rng.get_draws(), "il salvataggio registra la posizione dell'RNG")
	var expected: int = session.rng.roll_d6()

	var restored: RefCounted = new_session()
	assert_true(restored.restore(save), "sessione ripristinata")
	assert_eq(restored.rng.get_draws(), draws, "il contatore di estrazioni e tornato al suo posto")
	assert_eq(restored.rng.roll_d6(), expected, "il prossimo tiro e lo stesso")


## La voce 12 (D-092): il salvataggio si porta via come file, e il nome dice
## quale mondo e' - stessa grammatica del log (lettere, numeri, trattini).
func test_the_downloaded_save_has_an_honest_name() -> void:
	assert_eq(
		SaveSerializer.download_name("CHR_TEST", 7042),
		"echoes-salvataggio-chr-test-7042.json",
		"chronicle e seme nel nome, in minuscolo coi trattini"
	)
	assert_eq(
		SaveSerializer.download_name("", -1),
		"echoes-salvataggio-sessione.json",
		"senza chronicle ne' seme resta un nome onesto"
	)
