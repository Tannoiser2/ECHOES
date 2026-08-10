extends "res://tests/test_case.gd"
## §18.3: deterministic Drift, plus the veiled-Tension and threshold rules.

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


## §11.2: the drift bag is the Chronicle's fixed distribution, shuffled once
## with the seeded RNG. Same seed, same track - every time.
func test_drift_track_is_deterministic_for_a_seed() -> void:
	var first: Array = (session.world["drift_track"] as Array).duplicate()
	session.dispose()
	new_session()
	assert_eq(session.world["drift_track"], first, "stesso seed, stessa traccia di Drift")

	session.dispose()
	new_session(999)
	assert_ne(session.world["drift_track"], first, "un seed diverso da una traccia diversa")


## The bag holds exactly what the Chronicle declares: 5 x FAMINE, 4 x AWAKENING.
func test_drift_track_matches_the_declared_distribution() -> void:
	var counts: Dictionary = {}
	for tension_id in session.world["drift_track"]:
		counts[tension_id] = int(counts.get(tension_id, 0)) + 1
	assert_eq(counts.get("TEN_FAMINE", 0), 5, "5 voci per la Carestia")
	assert_eq(counts.get("TEN_AWAKENING", 0), 4, "4 voci per il Risveglio")
	assert_eq(
		(session.world["drift_track"] as Array).size(),
		9,
		"9 voci in tutto: un round di Chronicle ciascuna"
	)


## Each Drift is an Effect with a system source, and it consumes exactly one
## entry from the track.
func test_drift_consumes_the_track_in_order() -> void:
	var track: Array = (session.world["drift_track"] as Array).duplicate()
	for index in range(track.size()):
		var before: int = int(session.world["tensions"][track[index]]["current_value"])
		var applied: String = session.tensions.apply_drift()
		assert_eq(applied, str(track[index]), "il Drift %d segue la traccia" % index)
		assert_eq(
			int(session.world["tensions"][applied]["current_value"]),
			before + 1,
			"il Drift alza di 1"
		)
		assert_eq(int(session.world["drift_index"]), index + 1, "il cursore avanza di uno")

	var last: String = session.tensions.apply_drift()
	assert_eq(last, "", "esaurita la traccia, il Drift non fa nulla")


func test_drift_is_recorded_as_a_system_effect() -> void:
	session.tensions.apply_drift()
	var log: Array = session.world["effect_log"]
	var last: Dictionary = log[log.size() - 1]
	assert_eq(str(last["type"]), "ADJUST_TENSION", "il Drift e un ADJUST_TENSION")
	assert_eq(str(last["source"]["kind"]), "system", "sorgente di tipo system")
	assert_eq(str(last["source"]["id"]), "DRIFT", "sorgente DRIFT")


## §11.3: omens fire once, from the data, and never leak the number.
func test_omens_fire_once_and_come_from_the_data() -> void:
	var source: Dictionary = Effect.source("system", "TEST", "", 1, 1, 0)
	session.world["tensions"]["TEN_AWAKENING"]["current_value"] = 3
	var lines_before: int = session.log.lines.size()
	session.tensions.fire_omens(source)
	var fired: Array = session.world["tensions"]["TEN_AWAKENING"]["fired_omens"]
	assert_eq(fired, [3], "il presagio a 3 e scattato")
	assert_true(session.log.lines.size() > lines_before, "il presagio ha parlato in pubblico")

	var expected_message: String = str(
		data().tensions["TEN_AWAKENING"]["omen_thresholds"][0]["message"]
	)
	var found: bool = false
	for line in session.log.lines:
		if str(line).contains(expected_message):
			found = true
	assert_true(found, "il testo del presagio viene dai dati, non dal codice")

	var lines_after: int = session.log.lines.size()
	session.tensions.fire_omens(source)
	assert_eq(session.log.lines.size(), lines_after, "un presagio non si ripete")


func test_public_status_hides_a_veiled_value() -> void:
	var status: String = session.tensions.public_status("TEN_AWAKENING")
	assert_true(status.contains("velata"), "una Tensione velata non mostra il numero: '%s'" % status)
	assert_false(status.contains("2"), "il valore non compare nel log pubblico")

	session.applier.apply(
		Effect.make(
			"SET_TENSION_VISIBILITY",
			"tension",
			"TEN_AWAKENING",
			{"visibility": "OPEN"},
			Effect.source("developer", "TEST", "", 1, 1, 0)
		)
	)
	assert_true(
		session.tensions.public_status("TEN_AWAKENING").contains("/7"),
		"una volta aperta, il valore e pubblico"
	)


## Only an Entity that has scouted a veiled Tension may read its value (§10, §11.1).
func test_veiled_value_is_private_until_scouted() -> void:
	assert_eq(
		session.service.visible_tension_value("TEN_AWAKENING", "ENT_ALDRIC"),
		-1,
		"chi non ha indagato non vede il numero"
	)
	session.actions.execute(
		"ENT_LYRA", {"template": "SCHEME", "params": {"mode": "TENSION", "tension_id": "TEN_AWAKENING"}}
	)
	assert_eq(
		session.service.visible_tension_value("TEN_AWAKENING", "ENT_LYRA"),
		2,
		"chi ha indagato legge il valore"
	)
	assert_eq(
		session.service.visible_tension_value("TEN_AWAKENING", "ENT_ALDRIC"),
		-1,
		"e resta privato per gli altri"
	)


## §7: Tensions at threshold are ranked by value, then by Chronicle order.
func test_threshold_ranking() -> void:
	assert_true(session.tensions.tensions_at_threshold().is_empty(), "all'inizio nessuna e in soglia")
	session.world["tensions"]["TEN_FAMINE"]["current_value"] = 6
	session.world["tensions"]["TEN_AWAKENING"]["current_value"] = 9
	var ready: Array = session.tensions.tensions_at_threshold()
	assert_eq(ready, ["TEN_AWAKENING", "TEN_FAMINE"], "il valore piu alto ha la precedenza")

	session.world["tensions"]["TEN_AWAKENING"]["current_value"] = 7
	session.world["tensions"]["TEN_FAMINE"]["current_value"] = 7
	assert_eq(
		session.tensions.tensions_at_threshold(),
		["TEN_FAMINE", "TEN_AWAKENING"],
		"a parita vince l'ordine di definizione della Chronicle"
	)
