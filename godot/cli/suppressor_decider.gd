extends RefCounted
## A table that only ever pushes down (§18.1, DECISIONS O-9).
##
## Not a player anyone would be: a stress test. Every Entity spends every Action
## Opportunity holding the loudest Tension it can legally touch below its
## threshold, scouting a veiled one first if that is what unlocks it. If four
## people playing like this can keep a Chronicle silent for nine rounds, then a
## real table can too, and the design has a hole in it.
##
## Inside a Confluence it behaves like the least interesting table possible:
## abstain, commit nothing. The question is whether a Confluence happens at all.

const WorldStateService := preload("res://scripts/world/world_state_service.gd")


func choose_action(entity_id: String, _ao_index: int, session: RefCounted) -> Dictionary:
	var target: String = _loudest_touchable(entity_id, session)
	if target != "":
		return {
			"template": "INFLUENCE",
			"params": {"tension_id": target, "delta": -1, "via": "PRESENCE"},
		}

	# Nothing pushable: buy the knowledge that makes a veiled Tension pushable.
	var veiled: String = _veiled_unknown(entity_id, session)
	if veiled != "":
		return {"template": "SCHEME", "params": {"mode": "TENSION", "tension_id": veiled}}

	# Otherwise stand somewhere that will let you push next round.
	var region: String = _useful_region(entity_id, session)
	if region != "":
		return {"template": "MOVE", "params": {"region_id": region}}
	return {"template": "PASS", "params": {}}


## The Tension closest to going off that this Entity may legally lower now.
func _loudest_touchable(entity_id: String, session: RefCounted) -> String:
	var best: String = ""
	var best_value: int = -1
	for tension_id in session.world["tensions"]:
		var id: String = str(tension_id)
		var request: Dictionary = {
			"template": "INFLUENCE",
			"params": {"tension_id": id, "delta": -1, "via": "PRESENCE"},
		}
		if session.actions.check(entity_id, "INFLUENCE", request["params"]) != "":
			continue
		var value: int = session.tensions.value(id)
		if value > best_value:
			best = id
			best_value = value
	return best


func _veiled_unknown(entity_id: String, session: RefCounted) -> String:
	for tension_id in session.world["tensions"]:
		var id: String = str(tension_id)
		if session.tensions.is_veiled(id) and not session.service.knows_tension(entity_id, id):
			return id
	return ""


## A Region in the domain of some Tension this Entity is not standing in yet:
## presence is what makes the free INFLUENCE legal.
func _useful_region(entity_id: String, session: RefCounted) -> String:
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


# --- inside a Confluence: as quiet as the rules allow ------------------------

func choose_question(_context: Dictionary, _options: Array, _session: RefCounted) -> String:
	return ""


func choose_proposition(_context: Dictionary, options: Array, _session: RefCounted) -> String:
	return str(options[0]["id"])


func choose_stance(_entity_id: String, _context: Dictionary, _session: RefCounted) -> Dictionary:
	return {"stance": "ABSTAIN", "clause_id": ""}


func choose_commit(_entity_id: String, _context: Dictionary, _limit: int, _session: RefCounted) -> Array:
	return []


func choose_recovery(_context: Dictionary, _session: RefCounted) -> Dictionary:
	return {}
