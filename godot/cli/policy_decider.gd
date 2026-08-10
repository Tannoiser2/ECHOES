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
## Deterministic: it never draws from the RNG, so a seed still fixes the run.

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
	var destiny: Variant = session.data.destinies.get(str(definition["destiny_id"]))
	return {} if destiny == null else destiny


## The conditions that actually matter right now: those of the lowest level this
## Entity has not yet reached. A player sitting on Minimum plays for Victory, not
## for a Triumph clause they cannot get to - and that changes what they do to the
## Tensions.
func _live_conditions(entity_id: String, session: RefCounted) -> Array:
	var destiny: Dictionary = _destiny(entity_id, session)
	if destiny.is_empty():
		return []
	for level in ["minimum", "victory", "triumph"]:
		var conditions: Array = destiny[level]["conditions"]
		if not session.destinies.conditions.all_hold(conditions, {}):
			return conditions
	# Everything already holds: defend the whole ladder.
	return _conditions(entity_id, session)


## Tension goals: tension_id -> desired direction (-1 wants it low, +1 high).
##
## Two sources, and they are what makes the table fight:
##   - a `tension_limit` with a max says "keep this one down";
##   - a condition that can only be satisfied by a Confluence Consequence says
##     "I need that Confluence to actually happen", which means pushing the
##     Tension that opens it *up* to its threshold.
func _tension_goals(entity_id: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = {}
	var live: Array = _live_conditions(entity_id, session)

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
		if offers and session.world["tensions"].has(str(template["tension_id"])):
			out.append(str(template["tension_id"]))
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

func choose_question(_context: Dictionary, _options: Array, _session: RefCounted) -> String:
	return ""


## Pick the proposition whose world changes serve this Destiny best.
func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	var best: String = str(options[0]["id"])
	var best_score: int = -999
	for option in options:
		var score: int = _score_proposition(option, proponent, proponent, session)
		if score > best_score:
			best_score = score
			best = str(option["id"])
	return best


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
	var score: int = 0
	for consequence_id in proposition["success_consequences"]:
		var consequence: Variant = session.data.consequences.get(str(consequence_id))
		if consequence == null:
			continue
		for effect in consequence["effects"]:
			score += _score_effect(effect, entity_id, proponent_id, goals, session)
	return score


func _score_effect(
	effect: Dictionary,
	entity_id: String,
	proponent_id: String,
	goals: Dictionary,
	session: RefCounted
) -> int:
	var payload: Dictionary = effect.get("payload", {})
	var effect_type: String = str(effect["type"])
	var target_id: String = str(effect["target"]["id"])
	var score: int = 0

	# A tag your Destiny wants present, or wants gone.
	var tag: String = str(payload.get("tag", ""))
	if tag != "" and goals.has(tag):
		var sets_it: bool = effect_type.begins_with("SET_")
		score += int(goals[tag]) * (1 if sets_it else -1) * 2

	# Being pushed out of - or planted in - a Region your Destiny names.
	if effect_type == "REMOVE_PRESENCE" and target_id == entity_id:
		if _needs_presence(entity_id, str(payload.get("region_id", "")), session):
			score -= 3
	if effect_type == "ADD_PRESENCE" and target_id == entity_id:
		if _needs_presence(entity_id, str(payload.get("region_id", "")), session):
			score += 3

	# Control changing hands, for whoever counts Regions.
	if effect_type == "SET_CONTROL" and _counts_control(entity_id, session):
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
