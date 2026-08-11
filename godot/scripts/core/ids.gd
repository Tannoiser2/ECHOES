extends RefCounted
## Stable-id helpers (spec v0.2 §6).
##
## Prefixes: ENT_, REG_, AST_<FAMILY>_, ACT_, TEN_, ECH_, CNS_, DST_, CNF_,
## REL_, EFF_, CLM_, SCR_, TRU_.


static func effect_id(sequence: int) -> String:
	return "EFF_%06d" % sequence


static func claim_id(sequence: int) -> String:
	return "CLM_%04d" % sequence


static func scar_id(sequence: int) -> String:
	return "SCR_%04d" % sequence


static func echo_id(sequence: int) -> String:
	return "ECHO_%04d" % sequence


static func truth_id(sequence: int) -> String:
	return "TRU_%04d" % sequence


## Relation keys are the two entity ids joined by '|' in ascending order, so
## the pair (A,B) and (B,A) address the same record.
static func relation_key(a: String, b: String) -> String:
	if a <= b:
		return "%s|%s" % [a, b]
	return "%s|%s" % [b, a]


static func relation_pair(key: String) -> PackedStringArray:
	return key.split("|")


## Asset ids encode their family: AST_WEALTH_GRAIN -> WEALTH. Guaranteed by the
## pattern in schema/asset.schema.json.
static func asset_family(asset_id: String) -> String:
	var parts: PackedStringArray = asset_id.split("_")
	if parts.size() < 3:
		return ""
	return parts[1]


static func domain_tag(domain: String) -> String:
	return "domain:%s" % domain


static func knows_tension_tag(tension_id: String) -> String:
	return "knows_tension:%s" % tension_id
