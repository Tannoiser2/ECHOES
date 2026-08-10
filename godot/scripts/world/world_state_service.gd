extends RefCounted
## Read-only queries over the WorldState (§5).
##
## Nothing here mutates. Anything that would change the world builds an Effect
## and hands it to EffectApplier instead.

const Ids := preload("res://scripts/core/ids.gd")

const RELATION_ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]

var world: Dictionary
var data: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted) -> void:
	world = p_world
	data = p_data


# --- presence and regions --------------------------------------------------

func presence_count(entity_id: String, region_id: String) -> int:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return 0
	var count: int = 0
	for held in entity["presence"]:
		if str(held) == region_id:
			count += 1
	return count


func tokens_placed(entity_id: String) -> int:
	var entity: Variant = world["entities"].get(entity_id)
	return 0 if entity == null else (entity["presence"] as Array).size()


func regions_with_presence(entity_id: String) -> Array:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return []
	var unique: Array = []
	for region_id in entity["presence"]:
		if not unique.has(region_id):
			unique.append(region_id)
	unique.sort()
	return unique


func region_has_tag(region_id: String, tag: String) -> bool:
	var region: Variant = world["regions"].get(region_id)
	return region != null and (region["tags"] as Array).has(tag)


func regions_of_domain(domain: String) -> Array:
	var tag: String = Ids.domain_tag(domain)
	var out: Array = []
	for region_id in world["regions"]:
		if region_has_tag(str(region_id), tag):
			out.append(str(region_id))
	out.sort()
	return out


## INFLUENCE requires presence in a Region carrying the Tension's domain (§10).
func has_presence_in_domain(entity_id: String, domain: String) -> bool:
	for region_id in regions_of_domain(domain):
		if presence_count(entity_id, region_id) > 0:
			return true
	return false


func presence_in_domain(entity_id: String, domain: String) -> int:
	var total: int = 0
	for region_id in regions_of_domain(domain):
		total += presence_count(entity_id, region_id)
	return total


## MOVE legality (§10): the destination must border a Region you already hold,
## or be one of your Chronicle starting Regions.
func can_move_to(entity_id: String, region_id: String) -> bool:
	if not world["regions"].has(region_id):
		return false
	var definition: Variant = data.entities.get(entity_id)
	if definition != null and (definition["presence"] as Array).has(region_id):
		return true
	for held in regions_with_presence(entity_id):
		var neighbours: Array = data.regions[held]["adjacency"]
		if neighbours.has(region_id):
			return true
	return false


func region_free_slots(region_id: String) -> int:
	var slots: int = int(data.regions[region_id]["presence_slots"])
	var used: int = 0
	for entity_id in world["entities"]:
		used += presence_count(str(entity_id), region_id)
	return slots - used


func control_count(entity_id: String) -> int:
	var count: int = 0
	for region_id in world["regions"]:
		if str(world["regions"][region_id].get("control", "")) == entity_id:
			count += 1
	return count


# --- assets ----------------------------------------------------------------

func hand(entity_id: String) -> Array:
	var entity: Variant = world["entities"].get(entity_id)
	return [] if entity == null else (entity["hand"] as Array).duplicate()


func hand_size(entity_id: String) -> int:
	return hand(entity_id).size()


func count_family_in_hand(entity_id: String, family: String) -> int:
	var count: int = 0
	for asset_id in hand(entity_id):
		if Ids.asset_family(str(asset_id)) == family:
			count += 1
	return count


func first_asset_of_family(entity_id: String, family: String) -> String:
	for asset_id in hand(entity_id):
		if Ids.asset_family(str(asset_id)) == family:
			return str(asset_id)
	return ""


func first_asset_of_families(entity_id: String, families: Array) -> String:
	for family in families:
		var found: String = first_asset_of_family(entity_id, str(family))
		if found != "":
			return found
	return ""


## Assets in hand ranked by what they are worth in this Tension, strongest
## first. Used by the CLI default policy and by Developer Mode previews.
func ranked_hand_for_tension(entity_id: String, tension_id: String) -> Array:
	var relevant: Array = data.tensions[tension_id]["relevant_asset_families"]
	var ranked: Array = hand(entity_id)
	ranked.sort_custom(func(a: Variant, b: Variant) -> bool:
		var score_a: int = _commit_score(str(a), relevant)
		var score_b: int = _commit_score(str(b), relevant)
		if score_a == score_b:
			return str(a) < str(b)
		return score_a > score_b
	)
	return ranked


func _commit_score(asset_id: String, relevant: Array) -> int:
	var asset: Variant = data.assets.get(asset_id)
	if asset == null:
		return 0
	if relevant.has(str(asset["family"])):
		return int(asset["strength"]) * 2
	return 1


# --- tensions --------------------------------------------------------------

func tension_value(tension_id: String) -> int:
	return int(world["tensions"][tension_id]["current_value"])


func tension_visibility(tension_id: String) -> String:
	return str(world["tensions"][tension_id]["visibility"])


func is_tension_open(tension_id: String) -> bool:
	return tension_visibility(tension_id) == "OPEN"


## What `viewer_id` is allowed to know. Returns -1 when the value is hidden from
## them: a veiled Tension only shows its number to Entities that have scouted it
## with SCHEME (§10, §11.1).
func visible_tension_value(tension_id: String, viewer_id: String) -> int:
	if is_tension_open(tension_id):
		return tension_value(tension_id)
	if knows_tension(viewer_id, tension_id):
		return tension_value(tension_id)
	return -1


func knows_tension(entity_id: String, tension_id: String) -> bool:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return false
	return (entity["tags"] as Array).has(Ids.knows_tension_tag(tension_id))


func tension_domain(tension_id: String) -> String:
	return str(data.tensions[tension_id]["domain"])


func relevant_families(tension_id: String) -> Array:
	return data.tensions[tension_id]["relevant_asset_families"]


# --- relations -------------------------------------------------------------

func relation_level(a: String, b: String) -> String:
	var record: Variant = world["relations"].get(Ids.relation_key(a, b))
	return "NEUTRAL" if record == null else str(record["level"])


func relation_rank(a: String, b: String) -> int:
	return RELATION_ORDER.find(relation_level(a, b))


func relation_tags(a: String, b: String) -> Array:
	var record: Variant = world["relations"].get(Ids.relation_key(a, b))
	return [] if record == null else (record["tags"] as Array).duplicate()


static func shift_relation(level: String, steps: int) -> String:
	var index: int = RELATION_ORDER.find(level)
	if index < 0:
		index = RELATION_ORDER.find("NEUTRAL")
	return str(RELATION_ORDER[clampi(index + steps, 0, RELATION_ORDER.size() - 1)])


# --- claims ----------------------------------------------------------------

func claims_of(entity_id: String) -> Array:
	var out: Array = []
	for claim in world["claims"]:
		if str(claim["entity_id"]) == entity_id:
			out.append(claim)
	return out


func claim_for_domain(entity_id: String, domain: String) -> Dictionary:
	for claim in claims_of(entity_id):
		if str(claim["domain"]) == domain:
			return claim
	return {}


# --- turn order ------------------------------------------------------------

func active_entities() -> Array:
	var out: Array = []
	for entity_id in world["turn_order"]:
		if bool(world["entities"][entity_id]["active"]):
			out.append(str(entity_id))
	return out


## §12.2 C: proponent is whoever forced the Claim; otherwise most presence in the
## Tension's Regions, tie-broken by relevant Assets in hand, then turn order.
func determine_proponent(tension_id: String) -> String:
	var domain: String = tension_domain(tension_id)
	var families: Array = relevant_families(tension_id)
	var best: String = ""
	var best_presence: int = -1
	var best_assets: int = -1
	var best_order: int = 999
	for entity_id in active_entities():
		var presence: int = presence_in_domain(str(entity_id), domain)
		var assets: int = 0
		for family in families:
			assets += count_family_in_hand(str(entity_id), str(family))
		var order: int = (world["turn_order"] as Array).find(entity_id)
		var better: bool = false
		if presence > best_presence:
			better = true
		elif presence == best_presence:
			if assets > best_assets:
				better = true
			elif assets == best_assets and order < best_order:
				better = true
		if better:
			best = str(entity_id)
			best_presence = presence
			best_assets = assets
			best_order = order
	return best


## §12.2 D: stances are declared starting from the player to the proponent's left.
func stance_order(proponent_id: String) -> Array:
	var order: Array = active_entities()
	var start: int = order.find(proponent_id)
	if start < 0:
		return order
	var out: Array = []
	for offset in range(1, order.size()):
		out.append(order[(start + offset) % order.size()])
	return out
