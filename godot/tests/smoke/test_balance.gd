extends "res://tests/test_case.gd"
## Balance regression (§7, docs/DECISIONS.md D-018 / D-021).
##
## The scripted plans check that the rules do what an author wrote down. This
## checks the thing an author cannot: what the Chronicle does when four players
## all pursue their own Destiny at once.
##
## §7 expects 3-4 Confluence per Chronicle and asks for a report if fewer than 2
## or more than 6 emerge. Before the D-021 cap this suite failed hard - the
## median was 0 - which is exactly why it exists.
##
## The band is 5-6 here, not §7's 3-4: that number was written for the two
## Tensions of §18.2 and a Chronicle now carries four. Declared deviation,
## recorded in DECISIONS D-026 and revised in D-036, not a quiet adjustment.
##
## Why it moved from 4-5 to 5-6: §7's 3-4 over the two Tensions of §18.2 is
## 1.5-2.0 Confluence *per Tension*. D-026's 4-5 over four Tensions is 1.0-1.25 -
## it was stricter than §7 ever asked for. Measured over four blocks of forty
## Chronicles the rate is now 1.3 per Tension, still below §7's own, with a
## median of 5 in three blocks and 6 in the fourth.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Effect := preload("res://scripts/core/effect.gd")
# GameSession comes from test_case.gd; re-declaring it is a parse error.

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
const RUNS: int = 24
const FIRST_SEED: int = 500

## §7's hard bounds: outside these the numbers need revisiting, not the data.
##
## The ceiling moved from 7 to 8 in 0.1.15, by the same arithmetic that moved the
## band in D-051 and for the same reason. §7 asks for 3-4 Confluence over the
## **two** Tensions of §18.2 - 1.5-2.0 per Tension - and a Chronicle now carries
## four, so §7's own rate is 6-8. Seven was another self-imposed tightening, and
## it started failing the moment the playtest fixes let two more seats play: a
## seat that starts playing makes the year louder, which is the fix working.
##
## The floor did not move, and it is the half of this that §7 really cares about
## - a Chronicle that decides nothing is the failure worth catching (D-047).
const FLOOR: int = 2
const CEILING: int = 8

## The band a 4-Tension Chronicle is expected to sit in (D-026, D-036, D-051).
##
## Moved to 6-7 in 0.1.14, and the arithmetic is the reason rather than the
## measurement: §7 asks for 3-4 Confluence over the **two** Tensions of §18.2,
## which is 1.5-2.0 *per Tension*. A Chronicle now carries four, so §7's own rate
## is 6-8. Every band this file has declared was tighter than that - D-026's 4-5
## is 1.0-1.25 per Tension, D-036's 5-6 is 1.25-1.5 - and both said so at the
## time. 6-7 is 1.5-1.75, and is the first one actually inside the number §7
## wrote down.
##
## What moved the median there was D-051: the watcher's Victory used to be two
## clauses that were true before the game started, so he sat on it; now it asks
## for the seal, so he plays for the Council that grants it. A seat that starts
## playing is supposed to make the year louder. The hard bounds below did not
## move, and they are what §7 actually forbids.
##
## Tornata a 5-6 con D-077: dei Consigli contati dalla banda 6-7 una parte era
## ridecisioni - la stessa domanda rimessa ai voti nello stesso anno, due eredi
## nominati nel 1827 della prima saga. Una domanda decisa resta decisa, quindi
## l'anno tiene solo i Consigli che decidono qualcosa di nuovo: la mediana
## misurata scende di uno ed e' un anno piu' corto ma piu' vero, 1.25-1.5 per
## Tensione. I limiti duri, come sempre, non si sono mossi.
##
## Tornata a 5-7 con D-169, **per la stessa ragione di D-051 e con la stessa
## meccanica**: la Vittoria di Lyra era una porta sola al 25%, quindi per tre
## anni su quattro lei non aveva obiettivi aperti e smetteva di proporre. Le
## partite quiete di prima erano in buona parte partite in cui era spettatrice —
## misurato, D-168: la coda bassa della distribuzione (3, 4, otto volte 5) si
## sposta intera su 6 e 7 non appena la sua Vittoria diventa raggiungibile, e
## nessuna forma della clausola cambia il prezzo. Un seggio che ricomincia a
## giocare fa l'anno piu' rumoroso; e' successo con Vaerax e succede con lei.
##
## La banda si allarga in alto e non in basso: 5-7 e' 1.25-1.75 per Tensione,
## ancora dentro il 6-8 che §7 scrive per quattro Tensioni, e il pavimento — la
## Chronicle che non decide niente — non si e' mosso di un passo.
const BAND_LOW: int = 5
const BAND_HIGH: int = 7


func _play(seed_value: int) -> Dictionary:
	new_session(seed_value, false)
	var report: Dictionary = await session.run(PolicyDecider.new(session.log))
	return report


## Every Chronicle a competent table plays must produce a Confluence count
## inside the band §7 declares acceptable.
func test_confluence_count_stays_inside_the_expected_band() -> void:
	var counts: Array = []
	var outside: int = 0
	for i in range(RUNS):
		_play(FIRST_SEED + i)
		var count: int = int(session.world["confluence_count"])
		counts.append(count)
		if count < FLOOR or count > CEILING:
			outside += 1

	counts.sort()
	var median: int = int(counts[counts.size() / 2])
	assert_true(
		median >= BAND_LOW and median <= BAND_HIGH,
		"la mediana attesa con 4 Tensioni e %d-%d, misurata %d su %d partite: %s"
		% [BAND_LOW, BAND_HIGH, median, RUNS, counts]
	)
	# §7 talks about what emerges across a playtest, not about forbidding a
	# single quiet Chronicle: a table that stays sleepy once in a while is a
	# result, a table that does it routinely is a broken game.
	assert_true(
		outside * 10 <= RUNS,
		"%d partite su %d fuori da %d-%d (limite: 10%%): %s" % [outside, RUNS, FLOOR, CEILING, counts]
	)


## A Chronicle where nobody ever wins anything, or where everyone always does,
## would satisfy the count and still be a broken game.
func test_destinies_are_contested() -> void:
	var levels: Dictionary = {}
	var echoes: int = 0
	for i in range(RUNS):
		var report: Dictionary = await _play(FIRST_SEED + i)
		echoes += int(report["echoes"])
		for entity_id in SEATS:
			var level: String = str(report["destiny_results"][str(entity_id)]["level"])
			levels[level] = int(levels.get(level, 0)) + 1

	assert_true(
		echoes * 2 >= RUNS,
		"almeno un Echo ogni due Chronicle, misurati %d su %d partite" % [echoes, RUNS]
	)
	assert_true(
		int(levels.get("TRIUMPH", 0)) > 0,
		"qualcuno deve poter arrivare al Triumph"
	)
	assert_true(
		int(levels.get("MINIMUM", 0)) > 0,
		"e qualcun altro deve restare indietro: senza conflitto il gioco non funziona"
	)
	assert_true(
		int(levels.get("TRIUMPH", 0)) < RUNS * SEATS.size(),
		"non tutti possono vincere tutto"
	)


## D-021: the per-round INFLUENCE allowance is actually enforced during a full
## Chronicle, not just in the isolated unit test.
func test_influence_cap_holds_over_a_whole_chronicle() -> void:
	var cap: int = int(
		data().chronicles["CHR_TEST"].get("influence_rules", {}).get("max_per_entity_per_round", 0)
	)
	assert_true(cap > 0, "la Chronicle I dichiara un cap su INFLUENCE")

	_play(FIRST_SEED)
	# Rebuild the per-round tallies from the effect log: act/round/actor are on
	# every Effect's source, so the log alone proves the rule held.
	var tally: Dictionary = {}
	for effect in session.world["effect_log"]:
		var source: Dictionary = effect["source"]
		if str(source.get("id", "")) != "ACT_INFLUENCE":
			continue
		if str(effect["type"]) != "ADJUST_TENSION":
			continue
		var key: String = "%d/%d/%s" % [
			int(source["act"]), int(source["round"]), str(source.get("actor", ""))
		]
		tally[key] = int(tally.get(key, 0)) + 1
	for key in tally:
		assert_true(
			int(tally[key]) <= cap,
			"%s ha usato INFLUENCE %d volte in un round, il limite e %d" % [key, int(tally[key]), cap]
		)
	assert_true(not tally.is_empty(), "la partita ha comunque usato INFLUENCE")


## The measuring instrument itself has to be reproducible, or none of the numbers
## above mean anything.
func test_the_probe_is_deterministic() -> void:
	var first: Dictionary = await _play(FIRST_SEED)
	var first_count: int = int(session.world["confluence_count"])
	var first_log: String = session.log.text()

	var second: Dictionary = await _play(FIRST_SEED)
	assert_eq(int(session.world["confluence_count"]), first_count, "stesso seed, stesso numero di Confluence")
	assert_eq(session.log.text(), first_log, "stesso seed, stessa partita riga per riga")
	assert_eq(int(second["echoes"]), int(first["echoes"]), "stesso seed, stessi Echo")


## The policy is a model of a competent player, so it must not be proposing
## illegal actions: if it does, the numbers above are measuring the wrong thing.
func test_the_policy_never_proposes_an_illegal_action() -> void:
	for i in range(RUNS):
		var report: Dictionary = await _play(FIRST_SEED + i)
		assert_eq(
			int(report["illegal_actions"]),
			0,
			"seed %d: la policy ha proposto %d azioni illegali" % [FIRST_SEED + i, int(report["illegal_actions"])]
		)


## D-029: pressure is displaced, not removed. Pushing a Tension down has to
## raise one of the questions it is linked to, or a table that only ever pushes
## down keeps the whole Chronicle silent - which is what O-9 measured.
func test_pushing_a_tension_down_raises_a_linked_one() -> void:
	new_session()
	# The weight lands on the *lowest* linked Tension in play, so suppression
	# spreads pressure instead of piling it in one place. Computed here the same
	# way the rule computes it, rather than assumed to be the first in the list.
	var target: String = ""
	var lowest: int = -1
	for tension_id in data().tensions["TEN_FAMINE"]["linked_tensions"]:
		var id: String = str(tension_id)
		if not session.world["tensions"].has(id):
			continue
		var value: int = session.tensions.value(id)
		if lowest < 0 or value < lowest:
			target = id
			lowest = value
	assert_ne(target, "", "la Carestia deve avere almeno un collegamento in gioco")

	var before: int = session.tensions.value(target)
	var outcome: Dictionary = session.actions.execute(
		"ENT_NAHR",
		{"template": "INFLUENCE", "params": {"tension_id": "TEN_FAMINE", "delta": -1, "via": "PRESENCE"}}
	)
	assert_true(outcome["ok"], "la spinta in giu e legale: %s" % str(outcome.get("error", "")))
	assert_true(
		session.tensions.value(target) > before,
		"spingere giu la Carestia deve alzare '%s'" % target
	)
	assert_eq(str(outcome["info"]["displaced_to"]), target, "e il risultato dice dove e finito il peso")


## Displacement is not a second INFLUENCE action: the cap counts actions, and
## anything reading the log has to be able to tell the two apart.
func test_displacement_is_not_a_second_influence_action() -> void:
	new_session()
	session.actions.execute(
		"ENT_NAHR",
		{"template": "INFLUENCE", "params": {"tension_id": "TEN_FAMINE", "delta": -1, "via": "PRESENCE"}}
	)
	var actions: int = 0
	var displaced: int = 0
	for effect in session.world["effect_log"]:
		var id: String = str(effect["source"].get("id", ""))
		if id == "ACT_INFLUENCE":
			actions += 1
		elif id == "ACT_INFLUENCE_DISPLACED":
			displaced += 1
	assert_eq(actions, 1, "una sola azione INFLUENCE nel log")
	assert_eq(displaced, 1, "e uno spostamento, distinguibile")
	assert_eq(
		int(session.world["influence_used"].get("ENT_NAHR", 0)),
		1,
		"lo spostamento non consuma una seconda INFLUENCE"
	)


## Raising a Tension is feeding the fire directly: nothing is displaced.
func test_pushing_up_displaces_nothing() -> void:
	new_session()
	var before: Dictionary = {}
	for tension_id in session.world["tensions"]:
		before[str(tension_id)] = session.tensions.value(str(tension_id))
	session.actions.execute(
		"ENT_ALDRIC",
		{"template": "INFLUENCE", "params": {"tension_id": "TEN_FAMINE", "delta": 1, "via": "PRESENCE"}}
	)
	for tension_id in session.world["tensions"]:
		var id: String = str(tension_id)
		if id == "TEN_FAMINE":
			continue
		assert_eq(
			session.tensions.value(id), int(before[id]), "%s non deve muoversi" % id
		)


## D-034: the policy has to be able to *see* the axes the Destinies name.
##
## Four axes were dead at once - `ADJUST_TENSION`, `SET_CONTROL`,
## `SET_ENTITY_TAG`, and presence - because `_score_effect` had no branch for
## them, and the table abstained on 96% of propositions as a result.
##
## Written as four constructed cases rather than a tally over a played
## Chronicle, and that is the point. The first version of this guard counted
## how often each Effect type moved the score during real games, and it failed
## the moment D-035 changed which propositions come forward - not because the
## policy had gone blind, but because the content had moved somewhere its
## clauses do not reach. A guard that cannot tell those two apart is worse than
## none: it cries wolf at a content change and would be silenced by tuning.
##
## So: build the case the Destiny describes, and assert the policy has an
## opinion about it.
func test_the_policy_scores_every_axis_the_destinies_name() -> void:
	new_session()
	var decider: RefCounted = PolicyDecider.new(null)

	# 1. A Tension somebody puts a ceiling on. Pushing it up has to cost them.
	var capped: Dictionary = _a_capped_tension_in_play()
	assert_true(
		not capped.is_empty(),
		"la Chronicle deve avere in gioco almeno una Tensione che un Destiny limita"
	)
	var tension_id: String = str(capped["tension_id"])
	var bindings: Dictionary = {
		"proponent": "ENT_ALDRIC",
		"tension": tension_id,
		"region_focus": "REG_VALLE_VERDE",
	}
	var goals: Dictionary = decider._tag_goals(str(capped["entity_id"]), session)
	assert_true(
		decider._score_effect(
			_effect("ADJUST_TENSION", "tension", "$tension", {"delta": 2}),
			str(capped["entity_id"]), "ENT_ALDRIC", goals, session, bindings
		) < 0,
		"alzare %s deve costare a chi ha giurato di tenerla bassa" % tension_id
	)

	# 2. A Discovery, for the Destiny that counts Discoveries.
	assert_true(
		decider._score_effect(
			_effect("SET_ENTITY_TAG", "entity", "$proponent", {"tag": "discovery:crystal"}),
			"ENT_LYRA", "ENT_LYRA", decider._tag_goals("ENT_LYRA", session), session,
			{"proponent": "ENT_LYRA", "tension": tension_id, "region_focus": "REG_MINIERE_ANTICHE"}
		) > 0,
		"una Scoperta deve valere qualcosa per chi le conta"
	)

	# 3. Control of a Region, for the Destiny that counts Regions - and the
	#    target is a $slot, which is exactly what used to make this score zero.
	assert_true(
		decider._score_effect(
			_effect("SET_CONTROL", "region", "$region_focus", {"entity_id": "$proponent"}),
			"ENT_ALDRIC", "ENT_ALDRIC", decider._tag_goals("ENT_ALDRIC", session), session,
			{"proponent": "ENT_ALDRIC", "tension": tension_id, "region_focus": "REG_VALLE_VERDE"}
		) > 0,
		"prendere una Regione deve valere qualcosa per chi le conta"
	)

	# 4. A global tag a Destiny wants gone.
	assert_true(
		decider._score_effect(
			_effect("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "crystal_exploited"}),
			"ENT_VAERAX", "ENT_ALDRIC", decider._tag_goals("ENT_VAERAX", session), session,
			bindings
		) < 0,
		"sfruttare il Cristallo deve costare a chi ha giurato di impedirlo"
	)


## A seat reaches past a rung that asks nothing of it (D-047).
##
## The policy used to play the lowest rung of its ladder it had not secured, and
## nothing else. That is right about the order and wrong about the stopping: a
## rung can be open and still ask nothing of the Tensions - "stand on the Red
## Mountains" is answered by walking there, not by bringing a question to a head -
## and a seat focused on it stopped playing entirely. It would not even reach for
## the Victory above, whose "hold a Region" only a Council can grant.
func test_a_seat_reaches_past_a_rung_that_asks_nothing() -> void:
	new_session()
	var source: Dictionary = Effect.source("system", "TEST", "", 0, 0, 0)
	# The watcher's ladder, and a watcher who is neither where it swore to stand
	# nor holding anything: the Minimum is open and asks nothing, the Victory is
	# open and needs a Council.
	session.world["entities"]["ENT_VAERAX"]["destiny_id"] = "DST_VAERAX_WATCHED"
	for region_id in session.service.regions_with_presence("ENT_VAERAX"):
		session.applier.apply(Effect.make(
			"REMOVE_PRESENCE", "entity", "ENT_VAERAX", {"region_id": str(region_id)}, source
		))
	session.applier.apply(Effect.make(
		"SET_CONTROL", "region", "REG_MONTAGNE_ROSSE", {"entity_id": null}, source
	))

	var destiny: Dictionary = data().destinies["DST_VAERAX_WATCHED"]
	assert_false(
		session.destinies.conditions.all_hold(destiny["minimum"]["conditions"], {}),
		"il Minimo e aperto"
	)
	assert_true(
		PolicyDecider.new(null)._goals_of(
			"ENT_VAERAX", session, destiny["minimum"]["conditions"]
		).is_empty(),
		"e non chiede niente alle Tensioni: si risponde camminando"
	)
	assert_false(
		session.destinies.conditions.all_hold(destiny["victory"]["conditions"], {}),
		"la Vittoria e aperta"
	)

	assert_false(
		PolicyDecider.new(null)._tension_goals("ENT_VAERAX", session).is_empty(),
		"chi ha un gradino piu in alto da prendere ha ancora qualcosa da spingere"
	)


## And the bindings a decider scores against must exist whenever a Council is
## open: an empty table silently sends every slot back unresolved.
func test_an_open_council_can_always_resolve_its_slots() -> void:
	var seen: Dictionary = {"councils": 0}
	for i in range(4):
		new_session(FIRST_SEED + i, false)
		session.confluence.step_changed.connect(
			func(step: String, _context: Dictionary) -> void:
				if step != "PROPOSITION":
					return
				seen["councils"] = int(seen["councils"]) + 1
				var bindings: Dictionary = session.confluence.effect_context()
				assert_true(not bindings.is_empty(), "un Consiglio aperto risolve i propri slot")
				for key in ["proponent", "tension", "region_focus", "rival", "capital"]:
					assert_true(
						str(bindings.get(key, "")) != "",
						"lo slot $%s deve risolversi in qualcosa" % key
					)
		)
		await session.run(PolicyDecider.new(session.log))
	assert_true(int(seen["councils"]) > 0, "almeno un Consiglio si e aperto")


func _effect(type: String, kind: String, target_id: String, payload: Dictionary) -> Dictionary:
	return {"type": type, "target": {"kind": kind, "id": target_id}, "payload": payload}


## A Tension that is both in play and named by some Destiny's `tension_limit`,
## with the Entity that swore to keep it down.
func _a_capped_tension_in_play() -> Dictionary:
	for destiny in data().destinies.values():
		for level in ["minimum", "victory", "triumph"]:
			for condition in destiny[level]["conditions"]:
				if str(condition.get("type", "")) != "tension_limit":
					continue
				if not condition.has("max"):
					continue
				var tension_id: String = str(condition.get("tension_id", ""))
				if session.world["tensions"].has(tension_id):
					return {"tension_id": tension_id, "entity_id": str(destiny["entity_id"])}
	return {}
