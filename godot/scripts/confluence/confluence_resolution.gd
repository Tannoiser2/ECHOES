extends RefCounted
## Confluence resolution maths - Strategy "baseline_v0" (§12.3, appendix A5).
##
## Pure functions over plain data: no world access, no RNG, no side effects.
## Swapping this file for another Strategy changes the maths and nothing else.
##
##   M = S - O + W
##   M <= -1        Failure
##   0 <= M <= 1    Success with Cost
##   2 <= M <= 4    Success
##   M >= 5         Decisive Success

const STRATEGY_ID: String = "baseline_v0"

const FAILURE: String = "FAILURE"
const SUCCESS_WITH_COST: String = "SUCCESS_WITH_COST"
const SUCCESS: String = "SUCCESS"
const DECISIVE: String = "DECISIVE_SUCCESS"

## §12.2 F: 1d6 mapped to the World Factor.
const WORLD_FACTOR_TABLE: Array = [-2, -1, 0, 0, 1, 2]


static func world_factor(die: int) -> int:
	return int(WORLD_FACTOR_TABLE[clampi(die - 1, 0, WORLD_FACTOR_TABLE.size() - 1)])


## The value one committed Asset contributes.
##
## Full strength when its family is relevant for the Tension, 1 otherwise: this
## is the whole reason preparation matters (§9). confluence_modifier applies
## afterwards.
static func asset_value(asset: Dictionary, relevant_families: Array, front: String) -> int:
	var family: String = str(asset["family"])
	var value: int = int(asset["strength"]) if relevant_families.has(family) else 1
	var modifier: Dictionary = asset.get("confluence_modifier", {"kind": "NONE", "value": 0})
	match str(modifier.get("kind", "NONE")):
		"FLAT_BONUS":
			value += int(modifier["value"])
		"RELEVANT_BONUS":
			if relevant_families.has(family):
				value += int(modifier["value"])
		"OPPOSE_BONUS":
			if front == "OPPOSE":
				value += int(modifier["value"])
	return maxi(0, value)


static func front_total(asset_ids: Array, assets: Dictionary, relevant: Array, front: String) -> int:
	var total: int = 0
	for asset_id in asset_ids:
		var asset: Variant = assets.get(str(asset_id))
		if asset != null:
			total += asset_value(asset, relevant, front)
	return total


static func outcome_for(margin: int) -> String:
	if margin <= -1:
		return FAILURE
	if margin <= 1:
		return SUCCESS_WITH_COST
	if margin <= 4:
		return SUCCESS
	return DECISIVE


static func is_success(outcome: String) -> bool:
	return outcome != FAILURE


## Resolve one Confluence.
##
## `stances`: entity_id -> {stance, clause_id}
## `commits`: entity_id -> [asset_id, ...]
## Returns the full arithmetic so the UI and the log can show the working.
static func resolve(
	proponent_id: String,
	stances: Dictionary,
	commits: Dictionary,
	assets: Dictionary,
	relevant_families: Array,
	factor: int,
	condition_threshold: int
) -> Dictionary:
	var support_assets: Array = []
	var oppose_assets: Array = []
	var condition_assets: Array = []

	# The proponent always argues for their own proposition (§12.3).
	support_assets.append_array(commits.get(proponent_id, []))

	for entity_id in stances:
		if str(entity_id) == proponent_id:
			continue
		var committed: Array = commits.get(entity_id, [])
		match str(stances[entity_id].get("stance", "ABSTAIN")):
			"SUPPORT":
				support_assets.append_array(committed)
			"OPPOSE":
				oppose_assets.append_array(committed)
			"CONDITION":
				condition_assets.append_array(committed)
			_:
				pass

	var support_total: int = front_total(support_assets, assets, relevant_families, "SUPPORT")
	var oppose_total: int = front_total(oppose_assets, assets, relevant_families, "OPPOSE")
	# Condition commits sit outside the arithmetic; they only decide whether the
	# clause is qualified enough to attach itself to a successful outcome.
	var condition_total: int = front_total(
		condition_assets, assets, relevant_families, "CONDITION"
	)
	var margin: int = support_total - oppose_total + factor

	return {
		"strategy": STRATEGY_ID,
		"support_total": support_total,
		"oppose_total": oppose_total,
		"condition_total": condition_total,
		"condition_qualified": condition_total >= condition_threshold,
		"world_factor": factor,
		"margin": margin,
		"outcome": outcome_for(margin),
		"support_assets": support_assets,
		"oppose_assets": oppose_assets,
		"condition_assets": condition_assets,
	}
