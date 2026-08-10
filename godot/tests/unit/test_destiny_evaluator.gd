extends "res://tests/test_case.gd"
## §18.3: Destiny evaluated at all three levels.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")


func before_each() -> void:
	new_session()


func _apply(type: String, kind: String, id: String, payload: Dictionary) -> void:
	session.applier.apply(
		Effect.make(type, kind, id, payload, Effect.source("developer", "TEST", "", 3, 3, 0))
	)


## Vaerax walks the full ladder: Minimum, then Victory, then Triumph, and the
## level only rises while every lower level still holds.
func test_three_levels_for_vaerax() -> void:
	# Vaerax opens on Victory: nothing has been exploited yet, and that is
	# exactly what his Destiny asks for. Only the Triumph is still out of reach.
	var result: Dictionary = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "VICTORY", "in partenza nessuno ha toccato il Cristallo")
	assert_true(bool(result["levels"]["MINIMUM"]), "condizioni Minimum soddisfatte")
	assert_true(bool(result["levels"]["VICTORY"]), "nessuno ha ancora sfruttato il Cristallo")
	assert_false(bool(result["levels"]["TRIUMPH"]), "le Miniere non sono sigillate")

	# Losing the Victory conditions pulls him back down to Minimum.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "crystal_exploited"})
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "MINIMUM", "Cristallo sfruttato: resta solo il Minimum")
	_apply("REMOVE_GLOBAL_TAG", "world", "WORLD", {"tag": "crystal_exploited"})

	# The mine is sealed and the Awakening pushed back down: Triumph.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "mine_sealed"})
	_apply("ADJUST_TENSION", "tension", "TEN_AWAKENING", {"delta": -1})
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "TRIUMPH", "Miniere sigillate e Risveglio sotto 4: Triumph")

	# Losing the mountain drops him to nothing at all, whatever else is true.
	_apply("REMOVE_PRESENCE", "entity", "ENT_VAERAX", {"region_id": "REG_MONTAGNE_ROSSE"})
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "NONE", "senza Minimum non c'e livello, anche col Triumph vero")
	assert_true(bool(result["levels"]["TRIUMPH"]), "le condizioni di Triumph restano vere")
	assert_false(bool(result["levels"]["MINIMUM"]), "ma il Minimum e caduto")


func test_victory_needs_the_consequence_that_grants_it() -> void:
	var result: Dictionary = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "MINIMUM", "i Nahr partono da Minimum")
	assert_false(bool(result["levels"]["VICTORY"]), "l'insediamento non e ancora riconosciuto")

	# nahr_settled is written by CNS_NAHR_SETTLEMENT, and the Nahr already hold
	# the Valley; the Triumph conditions happen to hold too at this point.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "nahr_settled"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "TRIUMPH", "insediamento riconosciuto e Valle aperta: Triumph")

	# Sealing the Valley denies the Triumph without touching the Victory.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "valley_sealed"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "VICTORY", "la Valle chiusa blocca il Triumph")
	assert_false(bool(result["levels"]["TRIUMPH"]), "condizione di Triumph fallita")

	# And losing the Valley presence takes the Victory away as well.
	_apply("REMOVE_PRESENCE", "entity", "ENT_NAHR", {"region_id": "REG_VALLE_VERDE"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "MINIMUM", "senza presenza nella Valle si torna al Minimum")


## Discoveries are counted from the 'discovery:' tags an Entity has earned.
func test_discovery_count_drives_lyra() -> void:
	var result: Dictionary = session.destinies.evaluate("DST_LYRA")
	assert_eq(str(result["level"]), "NONE", "senza Scoperte Lyra non raggiunge nemmeno il Minimum")

	session.actions.execute(
		"ENT_LYRA", {"template": "SCHEME", "params": {"mode": "TENSION", "tension_id": "TEN_AWAKENING"}}
	)
	result = session.destinies.evaluate("DST_LYRA")
	assert_eq(str(result["level"]), "VICTORY", "una Scoperta e la presenza nelle Miniere: Victory")

	_apply("SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "discovery:crystal"})
	result = session.destinies.evaluate("DST_LYRA")
	assert_eq(str(result["level"]), "TRIUMPH", "due Scoperte e Risveglio sotto controllo: Triumph")


## Every seated Entity gets its own result; there is no shared score (§14).
func test_evaluate_all_covers_every_seat() -> void:
	var results: Dictionary = session.destinies.evaluate_all()
	assert_eq(results.size(), 4, "un risultato per ogni Entita al tavolo")
	for entity_id in session.world["turn_order"]:
		assert_true(results.has(str(entity_id)), "risultato presente per %s" % entity_id)
		assert_true(
			["NONE", "MINIMUM", "VICTORY", "TRIUMPH"].has(str(results[entity_id]["level"])),
			"livello valido per %s" % entity_id
		)


## §14: the result keeps *how* it was reached, for the Legacy propagation.
func test_evidence_records_conditions_and_echoes() -> void:
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "mine_sealed"})
	_apply(
		"CREATE_ECHO",
		"echo",
		"ECHO_0001",
		{
			"echo_id": "ECHO_0001",
			"title": "Prova",
			"summary": "Le Miniere furono sigillate.",
			"act": 3,
			"round": 3,
			"participants": ["ENT_VAERAX"],
			"effect_ids": [],
		}
	)
	var result: Dictionary = session.destinies.evaluate("DST_VAERAX")
	var evidence: String = "\n".join(PackedStringArray(result["evidence"]))
	assert_true(evidence.contains("MINIMUM"), "le condizioni di ogni livello sono elencate")
	assert_true(evidence.contains("TRIUMPH"), "compreso il Triumph")
	assert_true(evidence.contains("ECHO_0001"), "gli Echo a cui ha partecipato sono allegati")
	assert_true(evidence.contains("[x]"), "le condizioni soddisfatte sono marcate")
