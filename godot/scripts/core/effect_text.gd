extends RefCounted
## An Effect, said out loud.
##
## The log has always printed the *consequences* of an Effect - a Tension's new
## value, a Scar's description - because that is what a reader of the log wants.
## This says what the Effect itself did, in one line, for the places that show a
## thing and then have to explain it: the Act-end Echo card, and whatever comes
## after it (D-044).
##
## Unknown types report themselves by name rather than staying silent. A card
## that quietly did something is worse than a card that says `SET_ENTITY_TAG`.

## The `function:` tag every Echo card writes is bookkeeping - it is how a later
## card can require an earlier one (D-030) - and saying it out loud would tell a
## player about the deck's plumbing instead of about their world.
const HIDDEN_TAG_PREFIX: String = "function:"


static func say(effect: Dictionary, data: RefCounted) -> String:
	var target: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
	var payload: Dictionary = effect.get("payload", {})
	match str(effect.get("type", "")):
		"ADJUST_TENSION":
			var delta: int = int(payload.get("delta", 0))
			return "%s %s di %d" % [
				_tension(target, data), "sale" if delta >= 0 else "scende", absi(delta),
			]
		"SET_TENSION_VISIBILITY":
			return "%s adesso e %s" % [
				_tension(target, data),
				"aperta a tutti" if str(payload.get("visibility", "")) == "OPEN" else "velata",
			]
		"SET_REGION_TAG":
			return "%s: %s" % [_region(target, data), str(payload.get("tag", ""))]
		"REMOVE_REGION_TAG":
			return "%s non e piu %s" % [_region(target, data), str(payload.get("tag", ""))]
		"SET_GLOBAL_TAG":
			var tag: String = str(payload.get("tag", ""))
			return "" if tag.begins_with(HIDDEN_TAG_PREFIX) else "Nel mondo: %s" % tag
		"REMOVE_GLOBAL_TAG":
			return "Non vale piu: %s" % str(payload.get("tag", ""))
		"ADD_PRESENCE":
			return "%s mette una presenza in %s" % [
				_name(target, data), _region(str(payload.get("region_id", "")), data),
			]
		"REMOVE_PRESENCE":
			return "%s lascia %s" % [
				_name(target, data), _region(str(payload.get("region_id", "")), data),
			]
		"SET_CONTROL":
			var holder: Variant = payload.get("control", null)
			return "%s passa a %s" % [_region(target, data), _name(str(holder), data)] \
				if holder != null else "%s non e piu di nessuno" % _region(target, data)
		"SET_RELATION":
			return "Il rapporto %s diventa %s" % [
				target.replace("|", " / "), str(payload.get("level", "")).to_lower(),
			]
		"ADD_SCAR":
			return "Cicatrice in %s: %s" % [
				_region(str(payload.get("region_id", "")), data),
				str(payload.get("description", "")),
			]
		"GRANT_ASSET":
			return "%s riceve %s" % [
				_name(target, data), _asset(str(payload.get("asset_id", "")), data),
			]
		"REMOVE_ASSET":
			return "%s perde %s" % [
				_name(target, data), _asset(str(payload.get("asset_id", "")), data),
			]
		"TRANSFER_ASSET":
			return "%s passa a %s" % [
				_asset(str(payload.get("asset_id", "")), data),
				_name(str(payload.get("to", target)), data),
			]
	return str(effect.get("type", ""))


## Every line of a list of Effects, with the silent ones dropped.
static func lines(effects: Array, data: RefCounted) -> Array:
	var out: Array = []
	for effect in effects:
		var line: String = say(effect as Dictionary, data)
		if line != "":
			out.append(line)
	return out


static func _tension(tension_id: String, data: RefCounted) -> String:
	var tension: Variant = data.tensions.get(tension_id)
	return tension_id if tension == null else str(tension["title"])


static func _region(region_id: String, data: RefCounted) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


static func _name(entity_id: String, data: RefCounted) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(entity["name"])


static func _asset(asset_id: String, data: RefCounted) -> String:
	var asset: Variant = data.assets.get(asset_id)
	return asset_id if asset == null else str(asset["title"])
