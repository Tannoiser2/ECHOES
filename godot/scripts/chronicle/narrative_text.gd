extends RefCounted
## Fills the $slots an author left open in a narrative string (§A9).
##
## `ConsequenceCompiler` already does this for Effect specs, but it resolves to
## *ids*, because an Effect needs a target. A sentence needs a noun, so this is a
## second and deliberately separate table.
##
## Nothing here writes narrative. It only decides which name goes in a hole the
## data left open, and every name it can produce comes from the world state. An
## unresolved slot is left visible rather than silently blanked, so a typo in the
## data shows up in the log instead of producing a sentence with a gap in it.

var world: Dictionary
var data: RefCounted
var service: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted, p_service: RefCounted) -> void:
	world = p_world
	data = p_data
	service = p_service


## The slots a Confluence sentence may use, resolved against the world *now*.
func bindings_for(tension_id: String, proponent_id: String) -> Dictionary:
	var region_id: String = focus_region(tension_id)
	# Longest key first: `$the_region` has to be replaced before `$region`, or
	# the shorter slot eats its prefix and leaves "the_" stranded in the line.
	return {
		"the_region": _region_form(region_id, "definite"),
		"in_region": _region_form(region_id, "locative"),
		"of_region": _region_form(region_id, "genitive"),
		"region": _region_name(region_id),
		"controller": _controller_name(region_id),
		"proponent": _entity_name(proponent_id),
		"tension": _tension_name(tension_id),
		"rival": _rival_name(region_id, proponent_id),
	}


func fill(text: String, bindings: Dictionary) -> String:
	if not text.contains("$"):
		return text
	# Longest key first, always: `$region` is a prefix of `$the_region`, and
	# substituting it first would leave "the_" stranded in the middle of a line.
	var keys: Array = bindings.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool: return str(a).length() > str(b).length())
	var out: String = text
	for key in keys:
		out = out.replace("$%s" % key, str(bindings[key]))
	# A slot at the head of a sentence brings its own lower-case article with it
	# ("nella Valle Verde, a chi appartiene..."). The capital belongs to the
	# sentence, not to the noun, so it is restored here rather than authored in.
	if text.begins_with("$") and not out.is_empty():
		out = out.substr(0, 1).to_upper() + out.substr(1)
	return out


## Which Region this Tension is *about* right now.
##
## A Tension names the conditions it cares about in `focus_region_tags`, in
## order of preference: the first tag that any Region in its domain carries wins.
## That is what lets one authored question ("chi nutre $region quando i granai si
## svuotano") follow the famine around the map instead of naming the Valley for
## ever. Ties go to the Region with the most presence tokens on it - the place
## with the most people in it is the place the question is about - and then to
## the Chronicle's own Region order, so the result is deterministic.
func focus_region(tension_id: String) -> String:
	var domain: String = service.tension_domain(tension_id)
	var candidates: Array = []
	for region_id in world["regions"]:
		if service.region_has_tag(str(region_id), "domain:%s" % domain):
			candidates.append(str(region_id))
	if candidates.is_empty():
		return ""

	var preferred: Array = data.tensions[tension_id].get("focus_region_tags", [])
	var best: String = ""
	var best_rank: int = preferred.size() + 1
	var best_presence: int = -1
	for region_id in candidates:
		var rank: int = preferred.size()
		for i in range(preferred.size()):
			if service.region_has_tag(region_id, str(preferred[i])):
				rank = i
				break
		var presence: int = _total_presence(region_id)
		if rank < best_rank or (rank == best_rank and presence > best_presence):
			best = region_id
			best_rank = rank
			best_presence = presence
	return best


func _total_presence(region_id: String) -> int:
	var total: int = 0
	for entity_id in world["turn_order"]:
		total += service.presence_count(str(entity_id), region_id)
	return total


func _rival_name(region_id: String, proponent_id: String) -> String:
	return _entity_name(rival_id(region_id, proponent_id))


## Where the rival actually is: the first Region in Chronicle order they stand
## in, else one they hold, else the Region under discussion. A Consequence that
## wants to hurt *them* rather than the contested place needs somewhere to aim.
func seat_of(entity_id: String, fallback_region: String) -> String:
	for region_id in world["regions"]:
		if service.presence_count(entity_id, str(region_id)) > 0:
			return str(region_id)
	for region_id in world["regions"]:
		var control: Variant = world["regions"][str(region_id)].get("control", null)
		if control != null and str(control) == entity_id:
			return str(region_id)
	return fallback_region


## The Region the Chronicle calls its seat of power. Authored as a tag, so a
## Chronicle with a different capital needs no code change.
func capital_region() -> String:
	for region_id in world["regions"]:
		if service.region_has_tag(str(region_id), "capital"):
			return str(region_id)
	return ""


## The seat this question is being asked *against*: whoever has the most people
## standing in the Region, the proponent aside. Falls back to whoever holds the
## Region, then to turn order, so an Effect never comes out with a hole in it.
func rival_id(region_id: String, proponent_id: String) -> String:
	var best: String = ""
	var best_presence: int = 0
	for entity_id in world["turn_order"]:
		if str(entity_id) == proponent_id:
			continue
		var presence: int = service.presence_count(str(entity_id), region_id)
		if presence > best_presence:
			best = str(entity_id)
			best_presence = presence
	if best == "":
		var control: Variant = world["regions"].get(region_id, {}).get("control", null)
		if control != null and str(control) != proponent_id:
			best = str(control)
	if best == "":
		for entity_id in world["turn_order"]:
			if str(entity_id) != proponent_id:
				best = str(entity_id)
				break
	return best


func _region_name(region_id: String) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


## Italian needs more than a name in a hole: "la Valle Verde" but "Eredan",
## "nelle Terre Nahr" but "a Eredan". The forms are authored per Region; without
## them the bare name is still a legal sentence, just a clumsier one.
func _region_form(region_id: String, form: String) -> String:
	var region: Variant = data.regions.get(region_id)
	if region == null:
		return region_id
	var forms: Dictionary = region.get("name_forms", {})
	return str(forms.get(form, region["name"]))


## Nobody holding a Region is a fact worth saying out loud, not a blank.
func _controller_name(region_id: String) -> String:
	var control: Variant = world["regions"].get(region_id, {}).get("control", null)
	return "nessuno" if control == null else _entity_name(str(control))


func _entity_name(entity_id: String) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(entity["name"])


func _tension_name(tension_id: String) -> String:
	var tension: Variant = data.tensions.get(tension_id)
	return tension_id if tension == null else str(tension["title"])
