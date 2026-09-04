extends "res://tests/test_case.gd"
## §18.3: the resolver table - explicit S, O, W for all four outcomes.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")


## M = S + C - O + W, with the §12.3 bands. Each row states the maths in the open
## so a Strategy swap that changes a boundary fails here and not in a playtest.
func test_outcome_table() -> void:
	var rows: Array = [
		# support, oppose, world factor, margin, outcome
		[0, 0, -2, -2, ConfluenceResolution.FAILURE],
		[3, 4, 0, -1, ConfluenceResolution.FAILURE],
		[1, 5, 2, -2, ConfluenceResolution.FAILURE],
		[2, 2, 0, 0, ConfluenceResolution.SUCCESS_WITH_COST],
		[4, 3, 0, 1, ConfluenceResolution.SUCCESS_WITH_COST],
		[3, 4, 2, 1, ConfluenceResolution.SUCCESS_WITH_COST],
		[4, 2, 0, 2, ConfluenceResolution.SUCCESS],
		[6, 2, 0, 4, ConfluenceResolution.SUCCESS],
		[5, 3, 2, 4, ConfluenceResolution.SUCCESS],
		[7, 2, 0, 5, ConfluenceResolution.DECISIVE],
		[9, 0, 2, 11, ConfluenceResolution.DECISIVE],
		[6, 0, -1, 5, ConfluenceResolution.DECISIVE],
	]
	for row in rows:
		var margin: int = int(row[0]) - int(row[1]) + int(row[2])
		assert_eq(margin, int(row[3]), "M per S=%d O=%d W=%d" % [row[0], row[1], row[2]])
		assert_eq(
			ConfluenceResolution.outcome_for(margin),
			str(row[4]),
			"esito per M=%d" % margin
		)


## The four band boundaries, stated one by one.
func test_outcome_boundaries() -> void:
	assert_eq(ConfluenceResolution.outcome_for(-1), ConfluenceResolution.FAILURE, "M=-1 e Failure")
	assert_eq(ConfluenceResolution.outcome_for(0), ConfluenceResolution.SUCCESS_WITH_COST, "M=0")
	assert_eq(ConfluenceResolution.outcome_for(1), ConfluenceResolution.SUCCESS_WITH_COST, "M=1")
	assert_eq(ConfluenceResolution.outcome_for(2), ConfluenceResolution.SUCCESS, "M=2")
	assert_eq(ConfluenceResolution.outcome_for(4), ConfluenceResolution.SUCCESS, "M=4")
	assert_eq(ConfluenceResolution.outcome_for(5), ConfluenceResolution.DECISIVE, "M=5")


## §12.2 F: 1d6 -> -2, -1, 0, 0, +1, +2.
func test_world_factor_table() -> void:
	var expected: Array = [-2, -1, 0, 0, 1, 2]
	for die in range(1, 7):
		assert_eq(ConfluenceResolution.world_factor(die), int(expected[die - 1]), "1d6 = %d" % die)


## §12.3: full strength only when the family is relevant, otherwise 1.
func test_asset_value_relevance() -> void:
	var strong: Dictionary = {
		"family": "WEALTH", "strength": 2, "confluence_modifier": {"kind": "NONE", "value": 0}
	}
	assert_eq(
		ConfluenceResolution.asset_value(strong, ["WEALTH", "PEOPLE"], "SUPPORT"),
		2,
		"famiglia rilevante: forza piena"
	)
	assert_eq(
		ConfluenceResolution.asset_value(strong, ["KNOWLEDGE"], "SUPPORT"),
		1,
		"famiglia non rilevante: vale 1"
	)


func test_asset_value_modifiers() -> void:
	var relevant_bonus: Dictionary = {
		"family": "AUTHORITY",
		"strength": 2,
		"confluence_modifier": {"kind": "RELEVANT_BONUS", "value": 1},
	}
	assert_eq(
		ConfluenceResolution.asset_value(relevant_bonus, ["AUTHORITY"], "SUPPORT"),
		3,
		"RELEVANT_BONUS si applica sulla famiglia rilevante"
	)
	assert_eq(
		ConfluenceResolution.asset_value(relevant_bonus, ["WEALTH"], "SUPPORT"),
		1,
		"RELEVANT_BONUS non si applica fuori dalla famiglia rilevante"
	)

	var oppose_bonus: Dictionary = {
		"family": "PEOPLE",
		"strength": 2,
		"confluence_modifier": {"kind": "OPPOSE_BONUS", "value": 1},
	}
	assert_eq(
		ConfluenceResolution.asset_value(oppose_bonus, ["PEOPLE"], "OPPOSE"),
		3,
		"OPPOSE_BONUS vale sul fronte contrario"
	)
	assert_eq(
		ConfluenceResolution.asset_value(oppose_bonus, ["PEOPLE"], "SUPPORT"),
		2,
		"OPPOSE_BONUS non vale sul fronte a favore"
	)


## §12.3 (D-055): a Condition that is paid for argues *for* the proposition - its
## commits join S - and one that is not paid for argues for nothing.
func test_abstain_commits_are_ignored() -> void:
	var assets: Dictionary = {
		"AST_WEALTH_GRAIN": {
			"family": "WEALTH", "strength": 1, "confluence_modifier": {"kind": "NONE", "value": 0}
		},
	}
	var result: Dictionary = ConfluenceResolution.resolve(
		"ENT_A",
		{"ENT_B": {"stance": "ABSTAIN"}},
		{"ENT_A": ["AST_WEALTH_GRAIN"], "ENT_B": ["AST_WEALTH_GRAIN"]},
		assets,
		["WEALTH"],
		0
	)
	assert_eq(result["support_total"], 1, "chi si astiene non contribuisce")
	assert_eq(result["oppose_total"], 0, "chi si astiene non contribuisce")


