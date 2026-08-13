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
	# Vaerax opens on Minimum, and that is the fix of D-051. He used to open on
	# *Victory*: his second rung was "the Crystal has not been exploited" and "the
	# Miniere have not been emptied", two clauses that are true before a token is
	# placed and that hold in 37 Chronicles out of 40. A watcher who has already
	# won by sitting down is a watcher with nothing to play, which is the same
	# defect D-048 found in the scholars' seat one milestone earlier.
	var result: Dictionary = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "MINIMUM", "in partenza ha solo il Minimo")
	assert_true(bool(result["levels"]["MINIMUM"]), "condizioni Minimum soddisfatte")
	assert_false(bool(result["levels"]["VICTORY"]), "le gallerie non sono ancora sigillate")

	# The seal is the Victory, and it is a thing he has to obtain in a Council.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "mine_sealed"})
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "VICTORY", "sigillate le gallerie, e il Cristallo non e uscito")

	# And the stake still costs him it: exploiting the Crystal is the one thing
	# his Destiny is against, whatever else is true.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "crystal_exploited"})
	assert_eq(
		str(session.destinies.evaluate("DST_VAERAX")["level"]), "MINIMUM",
		"Cristallo sfruttato: resta solo il Minimum"
	)
	_apply("REMOVE_GLOBAL_TAG", "world", "WORLD", {"tag": "crystal_exploited"})

	# The Awakening pushed back down and the road that would carry anyone up
	# there cut: Triumph. The road is the O-12 clause - his Destiny is that the
	# sleep stays safe, and a safe sleep is one nobody can easily reach.
	_apply("ADJUST_TENSION", "tension", "TEN_AWAKENING", {"delta": -1})
	_apply("SET_REGION_TAG", "region", "REG_STRADA_MERCANTI", {"tag": "condition:cut_off"})
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "TRIUMPH", "Risveglio sotto 4 e strada interrotta: Triumph")

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
	# the Valley: that is the Victory. The Triumph now also asks that the crown
	# be divided (O-12) - a people can only stop somewhere while the throne is
	# busy with itself - so settling alone no longer reaches it.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "nahr_settled"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "VICTORY", "insediamento riconosciuto: Victory")
	assert_false(bool(result["levels"]["TRIUMPH"]), "ma la corona e ancora una sola")

	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "crown_divided"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "TRIUMPH", "corona spezzata e Valle aperta: Triumph")

	# Sealing the Valley denies the Triumph without touching the Victory.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "valley_sealed"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "VICTORY", "la Valle chiusa blocca il Triumph")
	assert_false(bool(result["levels"]["TRIUMPH"]), "condizione di Triumph fallita")

	# And losing the Valley presence takes the Victory away as well.
	_apply("REMOVE_PRESENCE", "entity", "ENT_NAHR", {"region_id": "REG_VALLE_VERDE"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "MINIMUM", "senza presenza nella Valle si torna al Minimum")


## Discoveries are counted from the 'discovery:' tags an Entity has earned - and
## what they are worth (D-048).
##
## This test used to end at "one Discovery and presence in the Mines: Victory",
## and it passed, and that was the bug. A Discovery costs **one action** - SCHEME
## on a veiled Tension - and the Mines are where Lyra is standing when the
## Chronicle is dealt. So the scholars' Victory was two SCHEMEs, and a probe over
## forty Chronicles found her whole ladder - Minimum, Victory *and* Triumph -
## closed by **Act I round two, forty times out of forty**. She then spent the
## remaining seventeen Action Opportunities drawing cards she had no use for.
##
## Knowing something is the Minimum now. The Victory is the other half of the
## title - *poter tornare a guardare* - and it has to be obtained from a Council.
func test_discovery_count_drives_lyra() -> void:
	var result: Dictionary = session.destinies.evaluate("DST_LYRA")
	assert_eq(str(result["level"]), "NONE", "senza Scoperte Lyra non raggiunge nemmeno il Minimum")

	session.actions.execute(
		"ENT_LYRA", {"template": "SCHEME", "params": {"mode": "TENSION", "tension_id": "TEN_AWAKENING"}}
	)
	result = session.destinies.evaluate("DST_LYRA")
	assert_eq(
		str(result["level"]), "MINIMUM",
		"sapere qualcosa e il Minimo: una SCHEME non e una Vittoria"
	)

	# Two Discoveries are still two actions, and still do not buy the rung above.
	_apply("SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "discovery:crystal"})
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "MINIMUM",
		"e nemmeno due"
	)

	# The escort is the Victory: somebody had to swear it, in a Council.
	_apply("SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "escort_sworn"})
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "TRIUMPH",
		"con la scorta giurata la scala si apre fino in fondo"
	)

	# And the Triumph on top of it is a stake, not a purchase: put a guard on the
	# study and it goes, without anything she did being undone.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "study_supervised"})
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "VICTORY",
		"una guardia allo studio costa il Trionfo e lascia la Vittoria"
	)


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
