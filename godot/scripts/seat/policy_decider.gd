extends RefCounted
## A player that actually plays to win, for balance measurement.
##
## The ScriptedDecider replays authored plans and its filler deliberately never
## touches the Tensions. That is right for regression tests and useless for
## balance: it cannot tell us what happens when four people all pursue their own
## Destiny at once.
##
## This decider derives its goals straight from the Entity's Destiny conditions -
## no hand-written per-Entity AI - and plays them: it scouts what it needs to
## know, occupies the Regions its Destiny names, stocks the Assets that will be
## relevant, and steers the Tensions it cares about when they get close to the
## edge. In a Confluence it scores every proposition against its own Destiny and
## supports, opposes or abstains accordingly.
##
## Deterministic, but not RNG-free: it breaks a tie between equally useful
## propositions with the session RNG, because always taking the first option on
## the list left two thirds of the authored propositions unplayable. Same seed,
## same run.

const Ids := preload("res://scripts/core/ids.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")

## Stop stockpiling and start acting once the hand is this full.
const COMFORTABLE_HAND: int = 4
## A Tension this close to its threshold is worth spending an action on.
const DANGER_MARGIN: int = 2

var log: RefCounted


func _init(p_log: RefCounted = null) -> void:
	log = p_log


# --- goals -----------------------------------------------------------------

## Every condition in the Entity's Destiny, across all three levels.
func _conditions(entity_id: String, session: RefCounted) -> Array:
	var destiny: Dictionary = _destiny(entity_id, session)
	if destiny.is_empty():
		return []
	var out: Array = []
	for level in ["minimum", "victory", "triumph"]:
		out.append_array(destiny[level]["conditions"])
	return out


func _destiny(entity_id: String, session: RefCounted) -> Dictionary:
	var definition: Variant = session.data.entities.get(entity_id)
	if definition == null:
		return {}
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(entity_id))
	return {} if destiny == null else destiny


## The rungs of the ladder this Entity has not secured yet, lowest first.
##
## A player plays for the nearest thing they have not got - Minimum before
## Victory, Victory before Triumph - which is why this is a list in order and not
## a pile. Everything already held is dropped: there is nothing to play for in a
## clause that is already true.
func _open_levels(entity_id: String, session: RefCounted) -> Array:
	var destiny: Dictionary = _destiny(entity_id, session)
	if destiny.is_empty():
		return []
	var out: Array = []
	for level in ["minimum", "victory", "triumph"]:
		var conditions: Array = destiny[level]["conditions"]
		if not session.destinies.conditions.all_hold(conditions, {}):
			out.append(conditions)
	# Everything already holds: defend the whole ladder.
	return [_conditions(entity_id, session)] if out.is_empty() else out


## The conditions that actually matter right now (D-047).
##
## This used to be the lowest rung and nothing else, on the reasoning that a
## player sitting on Minimum plays for Victory rather than for a Triumph clause
## they cannot get to. It is right about the order and wrong about the stopping:
## a rung whose remaining clauses are all *negative* - "the mine is not sealed",
## "the road is still open" - asks nothing of anybody, and a seat focused on it
## stops playing. Lyra reached that rung in round two and spent the other eight
## rounds drawing cards she never used.
##
## So the rule is: play the nearest rung that gives you something to do, and if
## it gives you nothing, reach past it. `wants` is the test - it takes a rung and
## returns what that rung asks for.
func _nearest_demanding(entity_id: String, session: RefCounted, wants: Callable) -> Dictionary:
	var fallback: Dictionary = {}
	for conditions in _open_levels(entity_id, session):
		var asked: Dictionary = wants.call(conditions as Array)
		if not asked.is_empty():
			return asked
		if fallback.is_empty():
			fallback = asked
	return fallback


## Tension goals: tension_id -> desired direction (-1 wants it low, +1 high).
##
## Two sources, and they are what makes the table fight:
##   - a `tension_limit` with a max says "keep this one down";
##   - a condition that can only be satisfied by a Confluence Consequence says
##     "I need that Confluence to actually happen", which means pushing the
##     Tension that opens it *up* to its threshold.
func _tension_goals(entity_id: String, session: RefCounted) -> Dictionary:
	return _nearest_demanding(
		entity_id,
		session,
		func(live: Array) -> Dictionary: return _goals_of(entity_id, session, live)
	)


## What one rung of the ladder asks of the Tensions.
func _goals_of(entity_id: String, session: RefCounted, live: Array) -> Dictionary:
	var goals: Dictionary = {}
	for tension_id in _needed_confluences(entity_id, session, live):
		goals[str(tension_id)] = 1

	for condition in live:
		if str(condition.get("type", "")) != "tension_limit":
			continue
		var tension_id: String = str(condition.get("tension_id", ""))
		if not session.world["tensions"].has(tension_id):
			continue
		if session.destinies.conditions.holds(condition, {}):
			continue  # already satisfied, no need to spend an action on it
		if condition.has("max"):
			goals[tension_id] = -1
		elif condition.has("min"):
			goals[tension_id] = 1
	return goals


## Which Tensions this Entity needs to bring to a head, because the only thing
## that can satisfy one of its live conditions is a Consequence that lives behind
## a Confluence. Derived from the data, not hard-coded per Entity.
func _needed_confluences(entity_id: String, session: RefCounted, live: Array) -> Array:
	var wanted: Array = []
	for condition in live:
		if session.destinies.conditions.holds(condition, {}):
			continue
		for consequence_id in _consequences_satisfying(condition, entity_id, session):
			for tension_id in _tensions_offering(str(consequence_id), session):
				if not wanted.has(str(tension_id)):
					wanted.append(str(tension_id))
	wanted.sort()
	return wanted


## Consequences whose Effects would make `condition` true.
func _consequences_satisfying(condition: Dictionary, entity_id: String, session: RefCounted) -> Array:
	var kind: String = str(condition.get("type", ""))
	var out: Array = []
	for consequence in session.data.consequences.values():
		for effect in consequence["effects"]:
			var payload: Dictionary = effect.get("payload", {})
			var effect_type: String = str(effect["type"])
			match kind:
				"state_tag_present":
					if effect_type.begins_with("SET_") and str(payload.get("tag", "")) == str(condition.get("tag", "")):
						out.append(str(consequence["id"]))
				"control_count":
					# Control only ever changes hands through a Confluence, and
					# only in favour of the proponent.
					if effect_type == "SET_CONTROL" and str(payload.get("entity_id", "")) == "$proponent":
						out.append(str(consequence["id"]))
				"discovery_count":
					if effect_type == "SET_ENTITY_TAG" and str(payload.get("tag", "")).begins_with("discovery:"):
						out.append(str(consequence["id"]))
	return out


## Which Tensions can produce that Consequence, through a proposition of their
## own Confluence template.
func _tensions_offering(consequence_id: String, session: RefCounted) -> Array:
	var out: Array = []
	for template in session.data.confluence_templates.values():
		var offers: bool = false
		for proposition in template["propositions"]:
			if (proposition["success_consequences"] as Array).has(consequence_id):
				offers = true
		if not offers:
			continue
		# A Council bound to a whole domain serves every Tension of that domain
		# in play, not one named Tension (D-028).
		if template.has("tension_id"):
			if session.world["tensions"].has(str(template["tension_id"])):
				out.append(str(template["tension_id"]))
			continue
		for tension_id in session.world["tensions"]:
			if str(session.data.tensions[str(tension_id)]["domain"]) == str(template["applies_to_domain"]):
				if not out.has(str(tension_id)):
					out.append(str(tension_id))
	return out


## Global and entity tags this Destiny wants present (+1) or absent (-1).
func _tag_goals(entity_id: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = {}
	for condition in _conditions(entity_id, session):
		var kind: String = str(condition.get("type", ""))
		if kind == "state_tag_present":
			goals[str(condition.get("tag", ""))] = 1
		elif kind == "state_tag_absent":
			goals[str(condition.get("tag", ""))] = -1
	return goals


# --- ordinary actions ------------------------------------------------------

func choose_action(entity_id: String, _ao_index: int, session: RefCounted) -> Dictionary:
	var service: RefCounted = session.service

	# 1. Knowledge first: a veiled Tension you cannot see is one you cannot act
	#    on, and for some Destinies the Discovery is the goal itself.
	var scout: Dictionary = _scout(entity_id, session)
	if not scout.is_empty():
		return scout

	# 2. Stand where your Destiny says you must stand.
	var move: Dictionary = _claim_required_region(entity_id, session)
	if not move.is_empty():
		return move

	# 3. Steer a Tension that is about to decide something, in the direction
	#    your Destiny needs - but only once you have something to spend.
	if service.hand_size(entity_id) >= COMFORTABLE_HAND:
		var steer: Dictionary = _steer(entity_id, session)
		if not steer.is_empty():
			return steer

	# 4. Otherwise prepare: stock the family that will matter.
	var acquire: Dictionary = _acquire(entity_id, session)
	if not acquire.is_empty():
		return acquire

	var steer_anyway: Dictionary = _steer(entity_id, session)
	if not steer_anyway.is_empty():
		return steer_anyway
	return {"template": "PASS", "params": {}}


func _scout(entity_id: String, session: RefCounted) -> Dictionary:
	var wants_discovery: bool = false
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) == "discovery_count":
			wants_discovery = true
	for tension_id in _sorted(session.world["tensions"].keys()):
		if not session.tensions.is_veiled(str(tension_id)):
			continue
		if session.service.knows_tension(entity_id, str(tension_id)):
			continue
		# Scout it if the Destiny needs Discoveries, or if this is a Tension the
		# Entity has an opinion about and currently cannot touch.
		if wants_discovery or _tension_goals(entity_id, session).has(str(tension_id)):
			return {
				"template": "SCHEME",
				"params": {"mode": "TENSION", "tension_id": str(tension_id)},
			}
	return {}


func _claim_required_region(entity_id: String, session: RefCounted) -> Dictionary:
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) != "region_presence":
			continue
		if str(condition.get("entity_id", "")) != entity_id:
			continue
		var region_id: String = str(condition.get("region_id", ""))
		var needed: int = int(condition.get("min", 1))
		if session.service.presence_count(entity_id, region_id) >= needed:
			continue
		if not session.service.can_move_to(entity_id, region_id):
			continue
		if session.service.region_free_slots(region_id) <= 0:
			continue
		return {"template": "MOVE", "params": {"region_id": region_id}}
	return {}


## Push a Tension the Destiny cares about, when it is near enough to its
## threshold for the push to change what happens this round.
func _steer(entity_id: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = _tension_goals(entity_id, session)
	for tension_id in _sorted(goals.keys()):
		var id: String = str(tension_id)
		var direction: int = int(goals[id])
		var value: int = session.tensions.value(id)
		var threshold: int = session.tensions.threshold(id)
		if direction < 0 and value < threshold - DANGER_MARGIN:
			continue  # not urgent yet
		if direction > 0 and value >= threshold:
			continue  # already there
		if session.tensions.is_veiled(id) and not session.service.knows_tension(entity_id, id):
			continue
		if not _can_influence(entity_id, id, direction, session):
			continue
		return {
			"template": "INFLUENCE",
			"params": {"tension_id": id, "delta": direction},
		}
	return {}


func _can_influence(entity_id: String, tension_id: String, direction: int, session: RefCounted) -> bool:
	var request: Dictionary = {
		"tension_id": tension_id,
		"delta": direction,
	}
	return session.actions.can_execute(entity_id, "INFLUENCE", request)


## Stock the family that is relevant to whichever Tension is closest to going
## off, preferring a Region this Entity can draw double from.
func _acquire(entity_id: String, session: RefCounted) -> Dictionary:
	var wanted: Array = _relevant_families_by_urgency(entity_id, session)
	var sourced: Array = []
	for region_id in session.service.regions_with_presence(entity_id):
		for family in session.data.regions[region_id]["asset_sources"]:
			if not sourced.has(str(family)):
				sourced.append(str(family))

	for family in wanted:
		if sourced.has(str(family)) and _deck_has_cards(str(family), session):
			return {"template": "ACQUIRE", "params": {"family": str(family)}}
	for family in wanted:
		if _deck_has_cards(str(family), session):
			return {"template": "ACQUIRE", "params": {"family": str(family)}}
	for family in sourced:
		if _deck_has_cards(str(family), session):
			return {"template": "ACQUIRE", "params": {"family": str(family)}}
	return {}


func _relevant_families_by_urgency(entity_id: String, session: RefCounted) -> Array:
	var goals: Dictionary = _tension_goals(entity_id, session)
	var ranked: Array = _sorted(session.world["tensions"].keys())
	ranked.sort_custom(func(a: Variant, b: Variant) -> bool:
		var urgency_a: int = _urgency(str(a), entity_id, goals, session)
		var urgency_b: int = _urgency(str(b), entity_id, goals, session)
		if urgency_a == urgency_b:
			return str(a) < str(b)
		return urgency_a > urgency_b
	)
	var families: Array = []
	for tension_id in ranked:
		for family in session.service.relevant_families(str(tension_id)):
			if not families.has(str(family)):
				families.append(str(family))
	return families


func _urgency(tension_id: String, entity_id: String, goals: Dictionary, session: RefCounted) -> int:
	# A Tension you have an opinion about, and that is close to going off, is the
	# one worth holding cards for.
	var closeness: int = session.tensions.value(tension_id) - session.tensions.threshold(tension_id)
	if session.tensions.is_veiled(tension_id) and not session.service.knows_tension(entity_id, tension_id):
		closeness -= 4
	return closeness + (3 if goals.has(tension_id) else 0)


func _deck_has_cards(family: String, session: RefCounted) -> bool:
	var deck: Variant = session.world["decks"].get(family)
	if deck == null:
		return false
	return not (deck["draw"] as Array).is_empty() or not (deck["discard"] as Array).is_empty()


# --- Confluence ------------------------------------------------------------

## Pick the question that opens the door you actually want to walk through.
##
## This returned "" until D-035, which meant the policy declined to choose and
## `_select_question`'s default - the *last* eligible question - won every time.
## A Council only opens when its Tension is at threshold, and every second
## question is gated on a Tension at threshold, so the second question was always
## eligible and **the first question of every template was never asked once in
## forty Chronicles**. Its propositions could not be voted, and their Consequences
## could not fire: that is the whole of O-8.
##
## A question is worth what the best proposition behind it is worth. Ties break
## on the session RNG, for the same reason they do in `choose_proposition`.
func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	var best_score: int = -999
	var tied: Array = []
	for question in options:
		var score: int = _best_proposition_score(str(question["id"]), context, session)
		if score > best_score:
			best_score = score
			tied = [str(question["id"])]
		elif score == best_score:
			tied.append(str(question["id"]))
	if tied.is_empty():
		return ""
	if tied.size() == 1:
		return str(tied[0])
	return str(tied[session.rng.range_int(0, tied.size() - 1)])


## The best a proponent can do with a question: the highest-scoring proposition
## that is actually legal behind it. Eligibility is checked the same way the
## Council checks it, so the policy never picks a question it cannot use.
func _best_proposition_score(question_id: String, context: Dictionary, session: RefCounted) -> int:
	var template: Variant = session.data.confluence_templates.get(str(context["template_id"]))
	if template == null:
		return -999
	var proponent: String = str(context["proponent"])
	var bindings: Dictionary = session.confluence.effect_context()
	var best: int = -999
	for proposition in template["propositions"]:
		if str(proposition["question_id"]) != question_id:
			continue
		if not session.confluence.conditions.all_hold(proposition["eligibility"], bindings):
			continue
		best = maxi(best, _score_proposition(proposition, proponent, proponent, session))
	return best


## Pick the proposition whose world changes serve this Destiny best.
## Pick what serves your Destiny best - and when nothing does, do not always pick
## the first thing on the list.
##
## Most propositions score 0 against most Destinies, so taking `options[0]` on a
## tie meant twelve of the eighteen authored propositions were never chosen once
## in forty Chronicles, and their Consequences never fired. That is the measuring
## instrument being wrong, not the rules - the same lesson as D-021. The tie is
## broken with the session RNG, so it stays deterministic per seed.
func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	var best_score: int = -999
	var tied: Array = []
	for option in options:
		var score: int = _score_proposition(option, proponent, proponent, session)
		if score > best_score:
			best_score = score
			tied = [str(option["id"])]
		elif score == best_score:
			tied.append(str(option["id"]))
	if tied.size() == 1:
		return str(tied[0])
	return str(tied[session.rng.range_int(0, tied.size() - 1)])


## How much a proposition's consequences help (+) or hurt (-) `entity_id`.
##
## Reads the Consequence Effects against that Entity's own Destiny conditions:
## a tag it needs, a Region it must stand in, a Region it must control. This is
## what turns "the throne requisitions the grain" into "and it clears my people
## out of the Valley, which is half my Victory" - and therefore into a fight.
func _score_proposition(
	proposition: Dictionary, entity_id: String, proponent_id: String, session: RefCounted
) -> int:
	var goals: Dictionary = _tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	var score: int = 0
	for consequence_id in proposition["success_consequences"]:
		var consequence: Variant = session.data.consequences.get(str(consequence_id))
		if consequence == null:
			continue
		for effect in consequence["effects"]:
			score += _score_effect(effect, entity_id, proponent_id, goals, session, bindings)
	return score


## Resolve an authored `$slot` to the id it will actually carry at K.
##
## The Council fixes its bindings at A, before a single stance is declared, so a
## decider voting at D can resolve $region_focus to exactly the Region the
## Consequence will hit. It uses the Council's own table rather than a copy, so
## the two cannot drift.
func _resolve(value: Variant, bindings: Dictionary, session: RefCounted) -> String:
	var text: String = str(value)
	if not text.begins_with("$"):
		return text
	var key: String = text.substr(1)
	if bindings.has(key):
		return str(bindings[key])
	# `$region_with:<tag>` names a kind of place; only the compiler can answer it.
	if bindings.is_empty():
		return text
	return str(session.confluence.compiler.substitute_string(text, bindings))


func _score_effect(
	effect: Dictionary,
	entity_id: String,
	proponent_id: String,
	goals: Dictionary,
	session: RefCounted,
	bindings: Dictionary
) -> int:
	var payload: Dictionary = effect.get("payload", {})
	var effect_type: String = str(effect["type"])
	var target_id: String = _resolve(effect["target"]["id"], bindings, session)
	var score: int = 0

	# A tag your Destiny wants present, or wants gone.
	var tag: String = str(payload.get("tag", ""))
	if tag != "" and goals.has(tag):
		var sets_it: bool = effect_type.begins_with("SET_")
		score += int(goals[tag]) * (1 if sets_it else -1) * 2

	# Being pushed out of - or planted in - a Region your Destiny names. The
	# target is always a $slot in the authored data ($rival, $proponent), so this
	# only ever fires once the slot is resolved.
	if effect_type == "REMOVE_PRESENCE" and target_id == entity_id:
		if _needs_presence(entity_id, _resolve(payload.get("region_id", ""), bindings, session), session):
			score -= 3
	if effect_type == "ADD_PRESENCE" and target_id == entity_id:
		if _needs_presence(entity_id, _resolve(payload.get("region_id", ""), bindings, session), session):
			score += 3

	# A Tension your Destiny puts a ceiling or a floor on. This is the commonest
	# Effect in the whole Consequence set and the commonest clause in the whole
	# Destiny set, and until D-034 the two never met: a proposition that shoved
	# the Famine up by two scored exactly zero against a Destiny whose Victory
	# says the Famine must stay under three.
	if effect_type == "ADJUST_TENSION":
		score += _score_tension_move(
			target_id, int(payload.get("delta", 0)), entity_id, session
		)

	# A Discovery, for a Destiny that counts Discoveries. They are granted to the
	# proponent; someone else learning something costs you nothing.
	if effect_type == "SET_ENTITY_TAG" and str(payload.get("tag", "")).begins_with("discovery:"):
		if target_id == entity_id and _wants_discoveries(entity_id, session):
			score += 2

	# Control changing hands, for whoever counts Regions.
	if effect_type == "SET_CONTROL" and _counts_control(entity_id, session):
		if not session.world["regions"].has(target_id):
			return score
		var new_owner: Variant = payload.get("entity_id", null)
		var holds_it_now: bool = (
			str(session.world["regions"][target_id].get("control", "")) == entity_id
		)
		if new_owner == null:
			if holds_it_now:
				score -= 3  # the title is being taken off you
		elif str(new_owner) == "$proponent":
			if entity_id == proponent_id:
				score += 2
			elif holds_it_now:
				score -= 3  # handed to someone else, out of your hands
	return score


## What a push on a Tension is worth to this Entity's `tension_limit` clauses.
##
## Breaking a clause that currently holds is worth blocking outright; merely
## moving in the wrong direction inside the band is worth a clause, not a no.
## Symmetrically for a move that repairs a limit already broken.
func _score_tension_move(
	tension_id: String, delta: int, entity_id: String, session: RefCounted
) -> int:
	if delta == 0 or not session.world["tensions"].has(tension_id):
		return 0
	var score: int = 0
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) != "tension_limit":
			continue
		if str(condition.get("tension_id", "")) != tension_id:
			continue
		var value: int = session.tensions.value(tension_id)
		var after: int = value + delta
		if condition.has("max"):
			var ceiling: int = int(condition["max"])
			if value <= ceiling and after > ceiling:
				score -= 2  # this is what breaks the clause
			elif value > ceiling and after <= ceiling:
				score += 2  # this is what repairs it
			elif delta > 0:
				score -= 1
			else:
				score += 1
		if condition.has("min"):
			var floor_value: int = int(condition["min"])
			if value >= floor_value and after < floor_value:
				score -= 2
			elif value < floor_value and after >= floor_value:
				score += 2
	return score


func _wants_discoveries(entity_id: String, session: RefCounted) -> bool:
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) == "discovery_count":
			return true
	return false


func _needs_presence(entity_id: String, region_id: String, session: RefCounted) -> bool:
	if region_id == "":
		return false
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) != "region_presence":
			continue
		if str(condition.get("entity_id", "")) != entity_id:
			continue
		if str(condition.get("region_id", "")) == region_id:
			return true
	return false


func _counts_control(entity_id: String, session: RefCounted) -> bool:
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) == "control_count":
			return true
	return false


## Support what helps you, block what hurts you, sit out what does neither.
func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
	var proposition: Dictionary = _current_proposition(context, session)
	if proposition.is_empty():
		return {"stance": "ABSTAIN", "clause_id": ""}
	var score: int = _score_proposition(proposition, entity_id, str(context["proponent"]), session)
	if score > 0:
		return {"stance": "SUPPORT", "clause_id": ""}
	# Something that really costs you is worth blocking. A clause is the answer
	# to a mild dislike, not to losing half your Destiny.
	if score <= -2:
		return {"stance": "OPPOSE", "clause_id": ""}
	if score < 0:
		var clause: String = _first_clause(context, session)
		if clause != "":
			return {"stance": "CONDITION", "clause_id": clause}
		return {"stance": "OPPOSE", "clause_id": ""}
	return {"stance": "ABSTAIN", "clause_id": ""}


func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
	if limit <= 0:
		return []
	var proposition: Dictionary = _current_proposition(context, session)
	var stake: int = 1
	if not proposition.is_empty():
		stake = absi(_score_proposition(proposition, entity_id, str(context["proponent"]), session))
	if entity_id == str(context["proponent"]):
		stake = maxi(stake, 2)
	var wanted: int = clampi(stake, 0, limit)
	if wanted <= 0:
		return []
	var ranked: Array = session.service.ranked_hand_for_tension(
		entity_id, str(context["tension_id"])
	)
	return ranked.slice(0, wanted)


func choose_recovery(_context: Dictionary, _session: RefCounted) -> Dictionary:
	return {}


func _current_proposition(context: Dictionary, session: RefCounted) -> Dictionary:
	var template: Variant = session.data.confluence_templates.get(str(context["template_id"]))
	if template == null:
		return {}
	for proposition in template["propositions"]:
		if str(proposition["id"]) == str(context.get("proposition_id", "")):
			return proposition
	return {}


func _first_clause(context: Dictionary, session: RefCounted) -> String:
	var template: Variant = session.data.confluence_templates.get(str(context["template_id"]))
	if template == null or (template["condition_clauses"] as Array).is_empty():
		return ""
	return str(template["condition_clauses"][0]["id"])


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out
