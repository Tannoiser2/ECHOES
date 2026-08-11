extends RefCounted
## Turns a sim plan (schema/sim_plan.schema.json) into the decisions the
## ChronicleController asks for (§18.1).
##
## Anything the plan does not spell out falls back to a small deterministic
## policy, so a plan can stay short and still play a full Chronicle. The policy
## is intentionally simple and readable - it is a test fixture, not an AI.

const Ids := preload("res://scripts/core/ids.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")

var plan: Dictionary
var log: RefCounted

var _turn_cursor: int = 0
var _confluence_index: int = 0
## Confluence id -> the directive that steers it, resolved once.
var _resolved: Dictionary = {}


func _init(p_plan: Dictionary, p_log: RefCounted) -> void:
	plan = p_plan
	log = p_log


# --- ordinary actions ------------------------------------------------------

func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
	var world: Dictionary = session.world
	var act: int = int(world["act"])
	var round_number: int = int(world["round"])
	for i in range(_turn_cursor, (plan["turns"] as Array).size()):
		var turn: Dictionary = plan["turns"][i]
		if int(turn["act"]) != act or int(turn["round"]) != round_number:
			continue
		if str(turn["actor"]) != entity_id:
			continue
		if turn.get("_used", false):
			continue
		turn["_used"] = true
		while _turn_cursor < (plan["turns"] as Array).size() and plan["turns"][_turn_cursor].get("_used", false):
			_turn_cursor += 1
		return {"template": str(turn["template"]), "params": turn.get("params", {})}
	return _fallback_action(entity_id, session)


## The filler policy, tried in order until something is legal:
##   1. ACQUIRE from a family this Entity can source and whose deck has cards
##   2. MOVE towards a Region it does not hold yet
##   3. PASS
##
## It deliberately never uses INFLUENCE, CLAIM or FORGE. Four players spending
## eight AO per round can cancel the +1 Drift outright, so a filler that steered
## the Tensions would flatten every plan into "nothing ever reaches threshold" -
## which is exactly what the first run of plan A did. Steering the story is the
## scripted turns' job; the filler only occupies the AO nobody scripted.
func _fallback_action(entity_id: String, session: RefCounted) -> Dictionary:
	if plan.has("fallback_action"):
		return {
			"template": str(plan["fallback_action"]["template"]),
			"params": plan["fallback_action"].get("params", {}),
		}

	var hand_limit: int = int(session.chronicle_def()["hand_limit"])
	if session.service.hand_size(entity_id) < hand_limit:
		var family: String = _drawable_family(entity_id, session)
		if family != "":
			return {"template": "ACQUIRE", "params": {"family": family}}

	var destination: String = _move_target(entity_id, session)
	if destination != "":
		return {"template": "MOVE", "params": {"region_id": destination}}

	return {"template": "PASS", "params": {}}


## A family this Entity has a source Region for and that still has cards to give,
## falling back to any non-empty deck.
func _drawable_family(entity_id: String, session: RefCounted) -> String:
	var candidates: Array = []
	for region_id in session.service.regions_with_presence(entity_id):
		for family in session.data.regions[region_id]["asset_sources"]:
			if not candidates.has(str(family)):
				candidates.append(str(family))
	for family in session.world["decks"]:
		if not candidates.has(str(family)):
			candidates.append(str(family))
	for family in candidates:
		var deck: Dictionary = session.world["decks"][family]
		if not (deck["draw"] as Array).is_empty() or not (deck["discard"] as Array).is_empty():
			return str(family)
	return ""


## Only ever *places* a token, never relocates one. Relocating would make the
## filler shuttle a single token between two Regions forever, which is legal but
## says nothing about the rules under test.
func _move_target(entity_id: String, session: RefCounted) -> String:
	if session.service.tokens_placed(entity_id) >= int(session.chronicle_def()["presence_tokens"]):
		return ""
	var held: Array = session.service.regions_with_presence(entity_id)
	var candidates: Array = session.world["regions"].keys()
	candidates.sort()
	for region_id in candidates:
		if held.has(str(region_id)):
			continue
		if not session.service.can_move_to(entity_id, str(region_id)):
			continue
		if session.service.region_free_slots(str(region_id)) <= 0:
			continue
		return str(region_id)
	return ""


# --- Confluence ------------------------------------------------------------

func choose_question(context: Dictionary, options: Array, _session: RefCounted) -> String:
	var wanted: String = str(_directive(context).get("question_id", ""))
	for option in options:
		if str(option["id"]) == wanted:
			return wanted
	return ""


func choose_proposition(context: Dictionary, options: Array, _session: RefCounted) -> String:
	var directive: Dictionary = _directive(context)
	var wanted: String = str(directive.get("proposition_id", ""))
	for option in options:
		if str(option["id"]) == wanted:
			return wanted
	return str(options[0]["id"])


func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
	var directive: Dictionary = _directive(context)
	var stances: Dictionary = directive.get("stances", {})
	if stances.has(entity_id):
		return {
			"stance": str(stances[entity_id]["stance"]),
			"clause_id": str(stances[entity_id].get("clause_id", "")),
		}
	# Default: you back your friends and block your enemies. Everyone else
	# waits to see how it lands.
	var rank: int = session.service.relation_rank(entity_id, str(context["proponent"]))
	var neutral: int = WorldStateService.RELATION_ORDER.find("NEUTRAL")
	if rank > neutral:
		return {"stance": "SUPPORT", "clause_id": ""}
	if rank < neutral:
		return {"stance": "OPPOSE", "clause_id": ""}
	return {"stance": "ABSTAIN", "clause_id": ""}


func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
	var directive: Dictionary = _directive(context)
	var commits: Dictionary = directive.get("commits", {})
	if commits.has(entity_id):
		return _legal_subset(entity_id, commits[entity_id], limit, session)

	# Default: the proponent argues with two of their best cards for this
	# Tension, everyone else with one. Plans override this to force an outcome.
	var wanted: int = 2 if entity_id == str(context["proponent"]) else 1
	wanted = mini(wanted, limit)
	var ranked: Array = session.service.ranked_hand_for_tension(entity_id, str(context["tension_id"]))
	return ranked.slice(0, wanted)


## Keep only cards actually in hand, honouring duplicates, so a stale plan
## degrades to a smaller commit instead of being rejected outright.
func _legal_subset(entity_id: String, wanted: Array, limit: int, session: RefCounted) -> Array:
	var available: Array = session.service.hand(entity_id)
	var out: Array = []
	for asset_id in wanted:
		if out.size() >= limit:
			break
		var index: int = available.find(str(asset_id))
		if index >= 0:
			available.remove_at(index)
			out.append(str(asset_id))
		elif not session.data.assets.has(str(asset_id)):
			# Absent from hand is a stale plan and degrades quietly; an id that
			# is not an Asset at all is a typo, and silence would hide it.
			log.bullet("PIANO SOSPETTO - '%s' non e un Asset esistente." % str(asset_id))
	return out


func choose_recovery(context: Dictionary, _session: RefCounted) -> Dictionary:
	return _directive(context).get("failure_recovery", {})


## Which directive steers this Confluence.
func _directive(context: Dictionary) -> Dictionary:
	# Resolved once per Confluence and cached: the controller asks for the same
	# directive a dozen times (question, proposition, one stance per seat, one
	# commit per seat), and consuming it on the first call would hand the second
	# call the *next* directive.
	var confluence_id: String = str(context.get("confluence_id", ""))
	if _resolved.has(confluence_id):
		return _resolved[confluence_id]

	var directive: Dictionary = _match_directive(context)
	_resolved[confluence_id] = directive
	return directive


## By Tension first: "when the grain council happens, do this" survives new
## content changing which question comes to a head first. Addressing by running
## index does not, which is how this was found. Several directives may name the
## same Tension; they are consumed in the order they are written.
func _match_directive(context: Dictionary) -> Dictionary:
	var tension_id: String = str(context.get("tension_id", ""))
	for entry in plan.get("confluences", []):
		if not entry.has("tension_id") or str(entry["tension_id"]) != tension_id:
			continue
		if entry.get("_used", false):
			continue
		entry["_used"] = true
		return entry
	# Index addressing is the legacy form and only applies to directives that do
	# not name a Tension: otherwise a directive written for the grain council
	# would steer whatever question happened to come to a head first.
	var index: int = int(context.get("index", 0))
	for entry in plan.get("confluences", []):
		if entry.has("tension_id"):
			continue
		if entry.has("index") and int(entry["index"]) == index and not entry.get("_used", false):
			entry["_used"] = true
			return entry
	return {}
