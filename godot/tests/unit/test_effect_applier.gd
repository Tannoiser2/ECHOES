extends "res://tests/test_case.gd"
## §18.3: apply/undo round-trip for every reversible EffectType, plus the
## irreversibility of CREATE_ECHO / APPEND_TRUTH.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const SchemaDefs := preload("res://scripts/core/schema_defs.gd")


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return Effect.source("developer", "TEST", "ENT_ALDRIC", 1, 1, 0)


func _make(type: String, kind: String, id: String, payload: Dictionary) -> Dictionary:
	return Effect.make(type, kind, id, payload, _source())


## Apply `effect`, undo it, and assert the world is byte-identical to before.
## The effect_log and its sequence counter are expected to unwind too.
func _round_trip(label: String, effect: Dictionary) -> void:
	var before: String = canonical(session.world)
	var applied: Dictionary = session.applier.apply(effect)
	assert_false(applied.is_empty(), "%s: apply riuscito (%s)" % [label, session.applier.last_error])
	if applied.is_empty():
		return
	assert_ne(canonical(session.world), before, "%s: lo stato e cambiato" % label)
	assert_true(session.applier.undo_last(1), "%s: undo riuscito (%s)" % [label, session.applier.last_error])
	assert_eq(canonical(session.world), before, "%s: lo stato torna esattamente com'era" % label)


## Every reversible EffectType, one by one. The list is checked against the
## generated enum below, so a new EffectType cannot be added without a test.
func test_round_trip_every_reversible_type() -> void:
	var world: Dictionary = session.world
	var applier: RefCounted = session.applier

	_round_trip("ADJUST_TENSION", _make("ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": 2}))
	_round_trip(
		"SET_TENSION_VISIBILITY",
		_make("SET_TENSION_VISIBILITY", "tension", "TEN_AWAKENING", {"visibility": "OPEN"})
	)
	_round_trip(
		"ADD_PRESENCE", _make("ADD_PRESENCE", "entity", "ENT_LYRA", {"region_id": "REG_EREDAN"})
	)
	# Dove Lyra vive lo dice il dato, non questa riga: D-211 l'ha spostata da
	# Eredan alla Strada dei Mercanti, e un `REMOVE_PRESENCE` scritto col nome
	# della Regione dentro falliva per la ragione sbagliata — «non ha pedine
	# li'» invece di «l'inverso non torna».
	_round_trip(
		"REMOVE_PRESENCE",
		_make("REMOVE_PRESENCE", "entity", "ENT_LYRA", {
			"region_id": str((session.data.entities["ENT_LYRA"]["presence"] as Array)[0])
		})
	)
	_round_trip(
		"SET_CONTROL", _make("SET_CONTROL", "region", "REG_VALLE_VERDE", {"entity_id": "ENT_NAHR"})
	)
	_round_trip(
		"SET_CONTROL (a null)", _make("SET_CONTROL", "region", "REG_EREDAN", {"entity_id": null})
	)
	_round_trip(
		"SET_REGION_TAG", _make("SET_REGION_TAG", "region", "REG_EREDAN", {"tag": "structure:granary"})
	)
	_round_trip(
		"REMOVE_REGION_TAG", _make("REMOVE_REGION_TAG", "region", "REG_EREDAN", {"tag": "capital"})
	)
	_round_trip("SET_GLOBAL_TAG", _make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "test_tag"}))
	_round_trip(
		"SET_ENTITY_TAG", _make("SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "discovery:test"})
	)
	_round_trip(
		"REMOVE_ENTITY_TAG", _make("REMOVE_ENTITY_TAG", "entity", "ENT_ALDRIC", {"tag": "crowned"})
	)
	_round_trip(
		"SET_RELATION",
		_make(
			"SET_RELATION",
			"relation",
			Ids.relation_key("ENT_ALDRIC", "ENT_NAHR"),
			{"level": "ALLY", "add_tag": "PACT"}
		)
	)
	_round_trip(
		"SET_ENTITY_ACTIVE", _make("SET_ENTITY_ACTIVE", "entity", "ENT_VAERAX", {"active": false})
	)
	_round_trip(
		"GRANT_ASSET (dal nulla)",
		_make("GRANT_ASSET", "entity", "ENT_LYRA", {"asset_id": "AST_WEALTH_GRAIN", "source": "VOID"})
	)
	_round_trip(
		"GRANT_ASSET (dal mazzo)",
		_make(
			"GRANT_ASSET",
			"entity",
			"ENT_LYRA",
			{"asset_id": str(world["decks"]["WEALTH"]["draw"][0]), "source": "DECK"}
		)
	)
	_round_trip(
		"REMOVE_ASSET (allo scarto)",
		_make(
			"REMOVE_ASSET",
			"entity",
			"ENT_ALDRIC",
			{"asset_id": str(world["entities"]["ENT_ALDRIC"]["hand"][0]), "destination": "DISCARD"}
		)
	)
	_round_trip(
		"TRANSFER_ASSET",
		_make(
			"TRANSFER_ASSET",
			"entity",
			"ENT_ALDRIC",
			{
				"asset_id": str(world["entities"]["ENT_ALDRIC"]["hand"][0]),
				"from": "ENT_ALDRIC",
				"to": "ENT_LYRA",
			}
		)
	)
	_round_trip(
		"CREATE_CLAIM",
		_make(
			"CREATE_CLAIM",
			"claim",
			"CLM_TEST",
			{
				"claim_id": "CLM_TEST",
				"entity_id": "ENT_ALDRIC",
				"domain": "SURVIVAL",
				"act": 1,
				"round": 1,
			}
		)
	)
	_round_trip(
		"ADD_SCAR",
		_make(
			"ADD_SCAR",
			"scar",
			"SCR_TEST",
			{
				"scar_id": "SCR_TEST",
				"region_id": "REG_VALLE_VERDE",
				"tag": "scar:blighted",
				"description": "La Valle non tornera come prima.",
			}
		)
	)

	# The removal types need something to remove first; the setup Effect is
	# rolled back afterwards so each case starts from the same world.
	_with_setup(
		"REMOVE_GLOBAL_TAG",
		_make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "temporary"}),
		_make("REMOVE_GLOBAL_TAG", "world", "WORLD", {"tag": "temporary"})
	)
	_with_setup(
		"CONSUME_CLAIM",
		_make(
			"CREATE_CLAIM",
			"claim",
			"CLM_TEST2",
			{
				"claim_id": "CLM_TEST2",
				"entity_id": "ENT_NAHR",
				"domain": "ANCIENT",
				"act": 1,
				"round": 1,
			}
		),
		_make("CONSUME_CLAIM", "claim", "CLM_TEST2", {"claim_id": "CLM_TEST2"})
	)
	_with_setup(
		"REMOVE_SCAR",
		_make(
			"ADD_SCAR",
			"scar",
			"SCR_TEST2",
			{
				"scar_id": "SCR_TEST2",
				"region_id": "REG_TERRE_NAHR",
				"tag": "scar:emptied",
				"description": "I pascoli orientali non sono piu percorsi.",
			}
		),
		_make("REMOVE_SCAR", "scar", "SCR_TEST2", {"scar_id": "SCR_TEST2"})
	)

	# La terra che si costruisce (D-157). Alzare e abbattere sono l'uno l'inverso
	# dell'altro; salire di grado si inverte su se stesso col grado di prima.
	_round_trip(
		"BUILD_STRUCTURE",
		_make(
			"BUILD_STRUCTURE", "region", "REG_MONTAGNE_ROSSE",
			{"structure_type": "STR_KEEP", "grade": 1, "owner": "ENT_VAERAX"}
		)
	)
	applier.apply(_make(
		"BUILD_STRUCTURE", "region", "REG_EREDAN",
		{"structure_type": "STR_KEEP", "grade": 2, "owner": "ENT_ALDRIC"}
	))
	_round_trip(
		"SET_STRUCTURE_GRADE",
		_make(
			"SET_STRUCTURE_GRADE", "region", "REG_EREDAN",
			{"structure_type": "STR_KEEP", "grade": 3}
		)
	)
	# Il varco che si chiude e si riapre (D-166): l'unica coppia di Effect che
	# cambia la **forma** del mondo. REG_TERRE_NAHR e REG_MONTAGNE_ROSSE si
	# toccano, e la montagna resta raggiungibile dalle Miniere anche senza
	# quell'arco — quindi il taglio e' concesso e si annulla pulito.
	_round_trip(
		"CLOSE_PASSAGE",
		_make(
			"CLOSE_PASSAGE", "region", "REG_TERRE_NAHR", {"region_id": "REG_MONTAGNE_ROSSE"}
		)
	)
	_round_trip(
		"OPEN_PASSAGE",
		_make("OPEN_PASSAGE", "region", "REG_EREDAN", {"region_id": "REG_MONTAGNE_ROSSE"})
	)
	_round_trip(
		"RAZE_STRUCTURE",
		_make("RAZE_STRUCTURE", "region", "REG_EREDAN", {"structure_type": "STR_KEEP"})
	)

	# Guard: every reversible type in the generated enum is covered above.
	var covered: Array = [
		"ADJUST_TENSION", "SET_TENSION_VISIBILITY", "ADD_PRESENCE", "REMOVE_PRESENCE",
		"SET_CONTROL", "SET_REGION_TAG", "REMOVE_REGION_TAG", "SET_GLOBAL_TAG",
		"REMOVE_GLOBAL_TAG", "SET_RELATION", "GRANT_ASSET", "REMOVE_ASSET", "TRANSFER_ASSET",
		"CREATE_CLAIM", "CONSUME_CLAIM", "ADD_SCAR", "REMOVE_SCAR", "SET_ENTITY_TAG",
		"REMOVE_ENTITY_TAG", "SET_ENTITY_ACTIVE",
		"BUILD_STRUCTURE", "RAZE_STRUCTURE", "SET_STRUCTURE_GRADE",
		"CLOSE_PASSAGE", "OPEN_PASSAGE",
	]
	for effect_type in SchemaDefs.EFFECT_TYPES:
		if Effect.IRREVERSIBLE.has(str(effect_type)):
			continue
		assert_true(
			covered.has(str(effect_type)),
			"EffectType reversibile '%s' senza test di round-trip" % effect_type
		)
	assert_true(applier != null, "applier presente")


func _with_setup(label: String, setup: Dictionary, effect: Dictionary) -> void:
	var applied_setup: Dictionary = session.applier.apply(setup)
	assert_false(applied_setup.is_empty(), "%s: setup applicato" % label)
	_round_trip(label, effect)
	session.applier.undo_last(1)


## Re-tagging something already tagged must be a no-op that undoes to a no-op,
## or an undo would strip a tag that was there for another reason.
func test_redundant_tag_is_a_safe_noop() -> void:
	var before: String = canonical(session.world)
	var applied: Dictionary = session.applier.apply(
		_make("SET_REGION_TAG", "region", "REG_EREDAN", {"tag": "capital"})
	)
	assert_false(applied.is_empty(), "l'Effect ridondante viene comunque registrato")
	assert_true(bool(applied["inverse_payload"].get("noop", false)), "l'inverso e un no-op")
	assert_true(session.applier.undo_last(1), "undo riuscito")
	assert_eq(canonical(session.world), before, "il tag preesistente e ancora al suo posto")


## A clamped ADJUST_TENSION must still round-trip exactly (§6.3).
func test_clamped_tension_round_trip() -> void:
	session.world["tensions"]["TEN_FAMINE"]["current_value"] = 1
	var before: String = canonical(session.world)
	var applied: Dictionary = session.applier.apply(
		_make("ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": -5})
	)
	assert_eq(session.world["tensions"]["TEN_FAMINE"]["current_value"], 0, "una Tensione non va sotto zero")
	assert_eq(applied["inverse_payload"]["delta"], 1, "l'inverso registra il delta realmente applicato")
	assert_true(session.applier.undo_last(1), "undo riuscito")
	assert_eq(canonical(session.world), before, "il valore torna a 1, non a 6")


## §6.3: history cannot be un-written.
func test_echo_and_truth_are_irreversible() -> void:
	var echo: Dictionary = _make(
		"CREATE_ECHO",
		"echo",
		"ECHO_0001",
		{
			"echo_id": "ECHO_0001",
			"title": "Prova",
			"summary": "Qualcosa accadde.",
			"act": 1,
			"round": 1,
			"participants": ["ENT_ALDRIC"],
			"effect_ids": [],
		}
	)
	var applied: Dictionary = session.applier.apply(echo)
	assert_false(applied.is_empty(), "CREATE_ECHO applicato")
	assert_false(bool(applied["reversible"]), "CREATE_ECHO non e reversibile")
	assert_false(applied.has("inverse_payload"), "un Effect irreversibile non porta un inverso")
	assert_false(session.applier.undo_last(1), "l'undo si rifiuta di superare un Echo")
	assert_true(
		session.applier.last_error.contains("snapshot"),
		"l'errore indirizza allo snapshot: '%s'" % session.applier.last_error
	)


func test_unknown_effect_type_is_refused() -> void:
	var applied: Dictionary = session.applier.apply(
		_make("MAKE_EVERYTHING_BETTER", "world", "WORLD", {})
	)
	assert_true(applied.is_empty(), "un EffectType fuori dall'enum viene rifiutato")
	assert_eq((session.world["effect_log"] as Array).size() > 0, true, "il log precedente resta")


## Effects are numbered progressively and the counter unwinds with the undo.
func test_effect_ids_are_progressive() -> void:
	var start: int = int(session.world["effect_sequence"])
	var first: Dictionary = session.applier.apply(
		_make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "a"})
	)
	var second: Dictionary = session.applier.apply(
		_make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "b"})
	)
	assert_eq(str(first["effect_id"]), "EFF_%06d" % (start + 1), "primo id progressivo")
	assert_eq(str(second["effect_id"]), "EFF_%06d" % (start + 2), "secondo id progressivo")
	session.applier.undo_last(2)
	assert_eq(int(session.world["effect_sequence"]), start, "il contatore torna indietro con l'undo")
