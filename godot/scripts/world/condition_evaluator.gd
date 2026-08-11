extends RefCounted
## The reusable WorldState predicates of §14.
##
## Shared by DestinyEvaluator, Confluence question/proposition eligibility and
## Echo card eligibility, so "what counts as true" is defined exactly once.

const Ids := preload("res://scripts/core/ids.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")

const RELATION_ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]
## Tags that mean "these two gave each other their word".
const PROMISE_TAGS: Array = ["PROMISE", "PACT"]

var world: Dictionary
var data: RefCounted
var service: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted) -> void:
	world = p_world
	data = p_data
	service = WorldStateService.new(p_world, p_data)


## True only if every condition holds. An empty list is always true.
func all_hold(conditions: Array, context: Dictionary = {}) -> bool:
	for condition in conditions:
		if not holds(condition, context):
			return false
	return true


func holds(condition: Dictionary, context: Dictionary = {}) -> bool:
	var condition_type: String = str(condition.get("type", ""))
	var entity_id: String = _resolve(str(condition.get("entity_id", "")), context)
	match condition_type:
		"control_count":
			return _within(service.control_count(entity_id), condition)
		"state_tag_present":
			return _has_tag(condition, context)
		"state_tag_absent":
			return not _has_tag(condition, context)
		"asset_threshold":
			var count: int = 0
			if condition.has("family"):
				count = service.count_family_in_hand(entity_id, str(condition["family"]))
			else:
				count = service.hand_size(entity_id)
			return _within(count, condition)
		"entity_alive":
			var entity: Variant = world["entities"].get(entity_id)
			return entity != null and bool(entity["active"])
		"relation_state":
			return _relation_holds(condition, context)
		"tension_limit":
			# A domain-bound Council does not know which Tension it serves until
			# it opens, so its conditions say $tension (D-028).
			var tension_id: String = _resolve(str(condition.get("tension_id", "")), context)
			if not world["tensions"].has(tension_id):
				return false
			return _within(service.tension_value(tension_id), condition)
		"discovery_count":
			return _within(_discovery_count(entity_id), condition)
		"region_presence":
			var region_id: String = _resolve(str(condition.get("region_id", "")), context)
			return _within(service.presence_count(entity_id, region_id), condition)
		"promise_kept":
			return _promise_state(condition, context) == "KEPT"
		"promise_broken":
			return _promise_state(condition, context) == "BROKEN"
	push_warning("ConditionEvaluator: unknown condition type '%s'" % condition_type)
	return false


## Human-readable line for the Chronicle End screen and the Destiny evidence log.
func describe(condition: Dictionary, context: Dictionary = {}) -> String:
	var label: String = str(condition.get("label", condition.get("type", "?")))
	return "%s %s" % ["[x]" if holds(condition, context) else "[ ]", label]


func _within(value: int, condition: Dictionary) -> bool:
	if condition.has("min") and value < int(condition["min"]):
		return false
	if condition.has("max") and value > int(condition["max"]):
		return false
	# A bare condition with neither bound asks only "is there any at all".
	if not condition.has("min") and not condition.has("max"):
		return value > 0
	return true


func _has_tag(condition: Dictionary, context: Dictionary) -> bool:
	var tag: String = _resolve(str(condition.get("tag", "")), context)
	match str(condition.get("scope", "GLOBAL")):
		"GLOBAL":
			return (world["global_tags"] as Array).has(tag)
		"REGION":
			var region_id: String = _resolve(str(condition.get("region_id", "")), context)
			return service.region_has_tag(region_id, tag)
		"ENTITY":
			var entity_id: String = _resolve(str(condition.get("entity_id", "")), context)
			var entity: Variant = world["entities"].get(entity_id)
			return entity != null and (entity["tags"] as Array).has(tag)
	return false


func _relation_holds(condition: Dictionary, context: Dictionary) -> bool:
	var a: String = _resolve(str(condition.get("entity_id", "")), context)
	var b: String = _resolve(str(condition.get("other_entity_id", "")), context)
	var wanted: int = RELATION_ORDER.find(str(condition.get("level", "NEUTRAL")))
	var actual: int = RELATION_ORDER.find(service.relation_level(a, b))
	if bool(condition.get("at_least", true)):
		return actual >= wanted
	return actual == wanted


## A Discovery is anything the Entity has learned that the world can point at:
## a 'discovery:' tag, however it was earned (SCHEME on a veiled Tension, a
## Consequence, an Echo card).
func _discovery_count(entity_id: String) -> int:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return 0
	var count: int = 0
	for tag in entity["tags"]:
		if str(tag).begins_with("discovery:"):
			count += 1
	return count


## A promise is KEPT while the pair still carries a PROMISE/PACT tag and has not
## fallen to open hostility; it is BROKEN when the tag is gone or the relation
## has collapsed, or when a VENDETTA has been declared.
func _promise_state(condition: Dictionary, context: Dictionary) -> String:
	var a: String = _resolve(str(condition.get("entity_id", "")), context)
	var b: String = _resolve(str(condition.get("other_entity_id", "")), context)
	var tags: Array = service.relation_tags(a, b)
	var hostile: bool = service.relation_rank(a, b) < RELATION_ORDER.find("NEUTRAL")
	var promised: bool = false
	for tag in PROMISE_TAGS:
		if tags.has(tag):
			promised = true
	if tags.has("VENDETTA"):
		return "BROKEN"
	if promised:
		return "BROKEN" if hostile else "KEPT"
	return "NONE"


## Conditions may reference the running Confluence through $proponent, $tension
## and friends, the same way Consequence effect specs do.
func _resolve(value: String, context: Dictionary) -> String:
	if value.begins_with("$") and context.has(value.substr(1)):
		return str(context[value.substr(1)])
	return value
