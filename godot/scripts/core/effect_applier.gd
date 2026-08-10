extends RefCounted
## The single point of mutation for the WorldState (spec v0.2 §2.11, §6.3).
##
## No other system writes to the world dictionary. Systems build Effects, hand
## them here, and the applier records the exact inverse alongside each one so
## Developer Mode can walk the log backwards.
##
## Irreversibility: CREATE_ECHO and APPEND_TRUTH write history and cannot be
## undone. undo() refuses to step past one and tells the caller to restore the
## pre-Confluence snapshot instead.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")

signal effect_applied(effect: Dictionary)

var world: Dictionary
var last_error: String = ""


func _init(p_world: Dictionary) -> void:
	world = p_world


## Apply one Effect. Returns the stored Effect (with effect_id and inverse
## filled in) or an empty Dictionary on failure, with last_error set.
func apply(effect: Dictionary) -> Dictionary:
	last_error = ""
	var effect_type: String = str(effect.get("type", ""))
	if not Effect.is_known_type(effect_type):
		last_error = "unknown EffectType '%s'" % effect_type
		return {}

	var stored: Dictionary = effect.duplicate(true)
	var sequence: int = int(world.get("effect_sequence", 0)) + 1
	stored["effect_id"] = Ids.effect_id(sequence)

	var inverse: Variant = _mutate(
		effect_type, stored.get("target", {}), stored.get("payload", {})
	)
	if inverse == null:
		return {}

	stored["reversible"] = Effect.is_reversible(effect_type)
	if stored["reversible"]:
		stored["inverse_type"] = Effect.INVERSE_TYPE[effect_type]
		stored["inverse_payload"] = inverse
	else:
		stored.erase("inverse_type")
		stored.erase("inverse_payload")

	world["effect_sequence"] = sequence
	world["effect_log"].append(stored)
	effect_applied.emit(stored)
	return stored


## Apply a batch, stopping at the first failure. Returns the Effects applied.
func apply_many(effects: Array) -> Array:
	var applied: Array = []
	for effect in effects:
		var stored: Dictionary = apply(effect)
		if stored.is_empty():
			return applied
		applied.append(stored)
	return applied


## Walk the log backwards, reverting `count` Effects. Developer Mode only.
func undo_last(count: int = 1) -> bool:
	last_error = ""
	for _i in range(count):
		var log: Array = world["effect_log"]
		if log.is_empty():
			last_error = "effect_log is empty"
			return false
		var effect: Dictionary = log[log.size() - 1]
		if not bool(effect.get("reversible", false)):
			last_error = (
				"%s (%s) is irreversible; restore the pre-Confluence snapshot instead"
				% [effect.get("effect_id", "?"), effect.get("type", "?")]
			)
			return false
		var result: Variant = _mutate(
			str(effect["inverse_type"]), effect["target"], effect["inverse_payload"]
		)
		if result == null:
			return false
		log.pop_back()
		world["effect_sequence"] = int(world["effect_sequence"]) - 1
	return true


## Revert everything applied after `effect_id` (that Effect itself is kept).
func undo_after(effect_id: String) -> bool:
	var log: Array = world["effect_log"]
	var index: int = -1
	for i in range(log.size()):
		if str(log[i]["effect_id"]) == effect_id:
			index = i
			break
	if index < 0:
		last_error = "no Effect with id '%s'" % effect_id
		return false
	return undo_last(log.size() - index - 1)


# ---------------------------------------------------------------------------
# Mutation handlers. Each returns the payload that undoes it, or null on error.
# ---------------------------------------------------------------------------

func _mutate(effect_type: String, target: Dictionary, payload: Dictionary) -> Variant:
	# A no-op Effect (e.g. tagging something that was already tagged) inverts to
	# another no-op, so undo leaves the pre-existing state alone.
	if bool(payload.get("noop", false)):
		return {"noop": true}

	match effect_type:
		"ADJUST_TENSION":
			return _adjust_tension(target, payload)
		"SET_TENSION_VISIBILITY":
			return _set_tension_visibility(target, payload)
		"ADD_PRESENCE":
			return _add_presence(target, payload)
		"REMOVE_PRESENCE":
			return _remove_presence(target, payload)
		"SET_CONTROL":
			return _set_control(target, payload)
		"SET_REGION_TAG":
			return _set_tag(_region_tags(target), payload, "SET_REGION_TAG")
		"REMOVE_REGION_TAG":
			return _remove_tag(_region_tags(target), payload, "REMOVE_REGION_TAG")
		"SET_GLOBAL_TAG":
			return _set_tag(world["global_tags"], payload, "SET_GLOBAL_TAG")
		"REMOVE_GLOBAL_TAG":
			return _remove_tag(world["global_tags"], payload, "REMOVE_GLOBAL_TAG")
		"SET_ENTITY_TAG":
			return _set_tag(_entity_tags(target), payload, "SET_ENTITY_TAG")
		"REMOVE_ENTITY_TAG":
			return _remove_tag(_entity_tags(target), payload, "REMOVE_ENTITY_TAG")
		"SET_RELATION":
			return _set_relation(target, payload)
		"GRANT_ASSET":
			return _grant_asset(target, payload)
		"REMOVE_ASSET":
			return _remove_asset(target, payload)
		"TRANSFER_ASSET":
			return _transfer_asset(payload)
		"CREATE_CLAIM":
			return _create_claim(payload)
		"CONSUME_CLAIM":
			return _consume_claim(payload)
		"ADD_SCAR":
			return _add_scar(payload)
		"REMOVE_SCAR":
			return _remove_scar(payload)
		"SET_ENTITY_ACTIVE":
			return _set_entity_active(target, payload)
		"CREATE_ECHO":
			world["echo_log"].append(payload.duplicate(true))
			return {}
		"APPEND_TRUTH":
			world["truth_log"].append(payload.duplicate(true))
			return {}
	return _fail("no handler for EffectType '%s'" % effect_type)


func _adjust_tension(target: Dictionary, payload: Dictionary) -> Variant:
	var tension: Variant = world["tensions"].get(str(target.get("id", "")))
	if tension == null:
		return _fail("unknown tension '%s'" % target.get("id", ""))
	var before: int = int(tension["current_value"])
	# Tensions never go below zero; the inverse records the delta that was
	# actually applied so a clamped adjustment still round-trips exactly.
	var after: int = maxi(0, before + int(payload.get("delta", 0)))
	tension["current_value"] = after
	return {"delta": before - after}


func _set_tension_visibility(target: Dictionary, payload: Dictionary) -> Variant:
	var tension: Variant = world["tensions"].get(str(target.get("id", "")))
	if tension == null:
		return _fail("unknown tension '%s'" % target.get("id", ""))
	var visibility: String = str(payload.get("visibility", ""))
	if not ["OPEN", "VEILED", "SECRET"].has(visibility):
		return _fail("invalid visibility '%s'" % visibility)
	var before: String = str(tension["visibility"])
	tension["visibility"] = visibility
	return {"visibility": before}


func _add_presence(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var region_id: String = str(payload.get("region_id", ""))
	if not world["regions"].has(region_id):
		return _fail("unknown region '%s'" % region_id)
	entity["presence"].append(region_id)
	return {"region_id": region_id}


func _remove_presence(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var region_id: String = str(payload.get("region_id", ""))
	var index: int = entity["presence"].find(region_id)
	if index < 0:
		return _fail("'%s' has no presence token in '%s'" % [target.get("id"), region_id])
	entity["presence"].remove_at(index)
	return {"region_id": region_id}


func _set_control(target: Dictionary, payload: Dictionary) -> Variant:
	var region: Variant = world["regions"].get(str(target.get("id", "")))
	if region == null:
		return _fail("unknown region '%s'" % target.get("id", ""))
	var before: Variant = region["control"]
	var next: Variant = payload.get("entity_id", null)
	if next != null and not world["entities"].has(str(next)):
		return _fail("unknown entity '%s'" % next)
	region["control"] = next
	return {"entity_id": before}


func _set_relation(target: Dictionary, payload: Dictionary) -> Variant:
	var key: String = str(target.get("id", ""))
	var relation: Variant = world["relations"].get(key)
	if relation == null:
		return _fail("unknown relation '%s'" % key)
	var before: Dictionary = {
		"level": str(relation["level"]),
		"tags": (relation["tags"] as Array).duplicate(),
	}
	if payload.has("level"):
		var level: String = str(payload["level"])
		if not ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"].has(level):
			return _fail("invalid relation level '%s'" % level)
		relation["level"] = level
	if payload.has("tags"):
		relation["tags"] = (payload["tags"] as Array).duplicate()
	if payload.has("add_tag") and not relation["tags"].has(payload["add_tag"]):
		relation["tags"].append(payload["add_tag"])
	if payload.has("remove_tag"):
		var tag_index: int = relation["tags"].find(payload["remove_tag"])
		if tag_index >= 0:
			relation["tags"].remove_at(tag_index)
	return before


func _grant_asset(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var asset_id: String = str(payload.get("asset_id", ""))
	var family: String = Ids.asset_family(asset_id)
	var deck: Variant = world.get("decks", {}).get(family)
	var deck_before: Variant = null
	if deck != null:
		deck_before = {
			"draw": (deck["draw"] as Array).duplicate(),
			"discard": (deck["discard"] as Array).duplicate(),
		}

	var touched_deck: bool = false
	if payload.has("deck_restore"):
		if deck == null:
			return _fail("no deck for family '%s'" % family)
		deck["draw"] = (payload["deck_restore"]["draw"] as Array).duplicate()
		deck["discard"] = (payload["deck_restore"]["discard"] as Array).duplicate()
		touched_deck = true
	else:
		match str(payload.get("source", "VOID")):
			"DECK":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				# The reshuffle order is computed by the drawing system with the
				# seeded RNG and carried here, so the applier stays pure.
				if payload.has("reshuffle"):
					deck["draw"] = (payload["reshuffle"] as Array).duplicate()
					deck["discard"] = []
				if (deck["draw"] as Array).is_empty():
					return _fail("family deck '%s' is empty" % family)
				if str(deck["draw"][0]) != asset_id:
					return _fail(
						"deck '%s' top is '%s', expected '%s'"
						% [family, deck["draw"][0], asset_id]
					)
				(deck["draw"] as Array).pop_front()
				touched_deck = true
			"DISCARD":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				var discard_index: int = (deck["discard"] as Array).rfind(asset_id)
				if discard_index < 0:
					return _fail("'%s' is not in the '%s' discard" % [asset_id, family])
				(deck["discard"] as Array).remove_at(discard_index)
				touched_deck = true
			"VOID":
				pass
			var unknown:
				return _fail("invalid GRANT_ASSET source '%s'" % unknown)

	# hand_index is set when this GRANT is undoing a REMOVE: the card has to go
	# back where it was, or the round-trip would silently reorder the hand.
	if payload.has("hand_index"):
		(entity["hand"] as Array).insert(
			clampi(int(payload["hand_index"]), 0, (entity["hand"] as Array).size()), asset_id
		)
	else:
		entity["hand"].append(asset_id)
	var inverse: Dictionary = {"asset_id": asset_id, "destination": "VOID"}
	if touched_deck:
		inverse["deck_restore"] = deck_before
	return inverse


func _remove_asset(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var asset_id: String = str(payload.get("asset_id", ""))
	var hand_index: int = entity["hand"].find(asset_id)
	if hand_index < 0:
		return _fail("'%s' does not hold '%s'" % [target.get("id"), asset_id])
	entity["hand"].remove_at(hand_index)

	var family: String = Ids.asset_family(asset_id)
	var deck: Variant = world.get("decks", {}).get(family)
	var deck_before: Variant = null
	if deck != null:
		deck_before = {
			"draw": (deck["draw"] as Array).duplicate(),
			"discard": (deck["discard"] as Array).duplicate(),
		}

	var touched_deck: bool = false
	if payload.has("deck_restore"):
		if deck == null:
			return _fail("no deck for family '%s'" % family)
		deck["draw"] = (payload["deck_restore"]["draw"] as Array).duplicate()
		deck["discard"] = (payload["deck_restore"]["discard"] as Array).duplicate()
		touched_deck = true
	else:
		match str(payload.get("destination", "DISCARD")):
			"DISCARD":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				(deck["discard"] as Array).append(asset_id)
				touched_deck = true
			"DECK_TOP":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				(deck["draw"] as Array).push_front(asset_id)
				touched_deck = true
			"VOID":
				pass
			var unknown:
				return _fail("invalid REMOVE_ASSET destination '%s'" % unknown)

	var inverse: Dictionary = {"asset_id": asset_id, "source": "VOID", "hand_index": hand_index}
	if touched_deck:
		inverse["deck_restore"] = deck_before
	return inverse


func _transfer_asset(payload: Dictionary) -> Variant:
	var from_id: String = str(payload.get("from", ""))
	var to_id: String = str(payload.get("to", ""))
	var asset_id: String = str(payload.get("asset_id", ""))
	var giver: Variant = world["entities"].get(from_id)
	var taker: Variant = world["entities"].get(to_id)
	if giver == null or taker == null:
		return _fail("TRANSFER_ASSET between unknown entities '%s' -> '%s'" % [from_id, to_id])
	var index: int = giver["hand"].find(asset_id)
	if index < 0:
		return _fail("'%s' does not hold '%s'" % [from_id, asset_id])
	giver["hand"].remove_at(index)
	# Same reasoning as GRANT_ASSET: the reverse transfer has to put the card
	# back at the position it left, not at the end of the hand.
	if payload.has("hand_index"):
		(taker["hand"] as Array).insert(
			clampi(int(payload["hand_index"]), 0, (taker["hand"] as Array).size()), asset_id
		)
	else:
		taker["hand"].append(asset_id)
	return {"asset_id": asset_id, "from": to_id, "to": from_id, "hand_index": index}


func _create_claim(payload: Dictionary) -> Variant:
	var claim_id: String = str(payload.get("claim_id", ""))
	for claim in world["claims"]:
		if str(claim["claim_id"]) == claim_id:
			return _fail("claim '%s' already exists" % claim_id)
	world["claims"].append({
		"claim_id": claim_id,
		"entity_id": str(payload.get("entity_id", "")),
		"domain": str(payload.get("domain", "")),
		"act": int(payload.get("act", 0)),
		"round": int(payload.get("round", 0)),
	})
	return {"claim_id": claim_id}


func _consume_claim(payload: Dictionary) -> Variant:
	var claim_id: String = str(payload.get("claim_id", ""))
	var claims: Array = world["claims"]
	for i in range(claims.size()):
		if str(claims[i]["claim_id"]) == claim_id:
			var record: Dictionary = (claims[i] as Dictionary).duplicate(true)
			claims.remove_at(i)
			return record
	return _fail("no claim '%s'" % claim_id)


func _add_scar(payload: Dictionary) -> Variant:
	var region_id: String = str(payload.get("region_id", ""))
	var region: Variant = world["regions"].get(region_id)
	if region == null:
		return _fail("unknown region '%s'" % region_id)
	var record: Dictionary = {
		"scar_id": str(payload.get("scar_id", "")),
		"region_id": region_id,
		"tag": str(payload.get("tag", "")),
		"description": str(payload.get("description", "")),
	}
	if payload.has("echo_id"):
		record["echo_id"] = str(payload["echo_id"])
	world["scars"].append(record)
	# A Scar marks the map (§16). If the tag was already there for another
	# reason, undoing this Scar must not strip it.
	var tag_pre_existed: bool = region["tags"].has(record["tag"])
	if not tag_pre_existed:
		region["tags"].append(record["tag"])
	return {"scar_id": record["scar_id"], "keep_region_tag": tag_pre_existed}


func _remove_scar(payload: Dictionary) -> Variant:
	var scar_id: String = str(payload.get("scar_id", ""))
	var scars: Array = world["scars"]
	for i in range(scars.size()):
		if str(scars[i]["scar_id"]) == scar_id:
			var record: Dictionary = (scars[i] as Dictionary).duplicate(true)
			scars.remove_at(i)
			if not bool(payload.get("keep_region_tag", false)):
				var region: Variant = world["regions"].get(str(record["region_id"]))
				if region != null:
					var tag_index: int = region["tags"].find(str(record["tag"]))
					if tag_index >= 0:
						region["tags"].remove_at(tag_index)
			else:
				record["keep_region_tag"] = true
			return record
	return _fail("no scar '%s'" % scar_id)


func _set_entity_active(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var before: bool = bool(entity["active"])
	entity["active"] = bool(payload.get("active", true))
	return {"active": before}


# --- tag helpers -----------------------------------------------------------

func _set_tag(tags: Variant, payload: Dictionary, label: String) -> Variant:
	if tags == null:
		return _fail("%s: target not found" % label)
	var tag: String = str(payload.get("tag", ""))
	if tag == "":
		return _fail("%s: empty tag" % label)
	if (tags as Array).has(tag):
		return {"tag": tag, "noop": true}
	(tags as Array).append(tag)
	return {"tag": tag}


func _remove_tag(tags: Variant, payload: Dictionary, label: String) -> Variant:
	if tags == null:
		return _fail("%s: target not found" % label)
	var tag: String = str(payload.get("tag", ""))
	var index: int = (tags as Array).find(tag)
	if index < 0:
		return {"tag": tag, "noop": true}
	(tags as Array).remove_at(index)
	return {"tag": tag}


func _region_tags(target: Dictionary) -> Variant:
	var region: Variant = world["regions"].get(str(target.get("id", "")))
	if region == null:
		return null
	return region["tags"]


func _entity_tags(target: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return null
	return entity["tags"]


func _fail(message: String) -> Variant:
	last_error = message
	push_error("EffectApplier: %s" % message)
	return null
