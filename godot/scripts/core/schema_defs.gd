# GENERATED FILE - DO NOT EDIT BY HAND.
#
# Produced by tools/gen_gd_schema.py from the JSON Schemas in /schema, which are
# the single source of truth for the data model (spec v0.2 §17). Edit the
# schemas and re-run the generator; CI fails if this file drifts.
extends RefCounted

## Bump when the generator's output format changes.
const GENERATOR_VERSION := "1"


## Schema definitions keyed by schema file stem.
const DEFS := {
	"action": {
		"kind": "collection",
		"required": [
			"id",
			"template",
			"title",
			"ao_cost",
			"description",
			"narrative_verbs",
			"params",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^ACT_[A-Z0-9_]+$",
			},
			"template": {
				"type": "String",
				"enum": [
					"ACQUIRE",
					"MOVE",
					"INFLUENCE",
					"FORGE",
					"SCHEME",
					"CLAIM",
				],
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"ao_cost": {
				"type": "int",
				"min": 1,
				"max": 2,
			},
			"description": {
				"type": "String",
				"min_length": 1,
			},
			"narrative_verbs": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"params": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"rules_text": {
				"type": "String",
			},
		},
	},
	"asset": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"family",
			"strength",
			"tags",
			"acquisition_rule",
			"confluence_modifier",
			"discard_or_retain_rule",
			"rarity",
			"art_prompt_key",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^AST_(FORCE|AUTHORITY|PEOPLE|KNOWLEDGE|WEALTH|BONDS)_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"family": {
				"type": "String",
				"enum": [
					"FORCE",
					"AUTHORITY",
					"PEOPLE",
					"KNOWLEDGE",
					"WEALTH",
					"BONDS",
				],
			},
			"strength": {
				"type": "int",
				"min": 1,
				"max": 3,
			},
			"tags": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"acquisition_rule": {
				"type": "String",
			},
			"confluence_modifier": {
				"type": "Dictionary",
			},
			"discard_or_retain_rule": {
				"type": "String",
				"enum": [
					"DISCARD",
					"RETAIN",
					"RETAIN_ON_SUCCESS",
					"ALWAYS_DISCARD",
				],
			},
			"rarity": {
				"type": "String",
				"enum": [
					"COMMON",
					"UNCOMMON",
					"RARE",
				],
			},
			"deck_copies": {
				"type": "int",
				"min": 1,
				"max": 12,
				"default": 3,
			},
			"art_prompt_key": {
				"type": "String",
				"min_length": 1,
			},
			"rules_text": {
				"type": "String",
			},
			"card_action": {
				"type": "Dictionary",
			},
			"on_commit_effects": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
		},
	},
	"chronicle": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"world_id",
			"start_year",
			"acts",
			"rounds_per_act",
			"action_opportunities_per_round",
			"hand_limit",
			"presence_tokens",
			"entities",
			"regions",
			"act_echo_pools",
			"confluence_templates",
			"opening_text",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^CHR_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"world_id": {
				"type": "String",
				"min_length": 1,
			},
			"start_year": {
				"type": "int",
			},
			"acts": {
				"type": "int",
				"min": 1,
			},
			"rounds_per_act": {
				"type": "int",
				"min": 1,
			},
			"action_opportunities_per_round": {
				"type": "int",
				"min": 1,
			},
			"hand_limit": {
				"type": "int",
				"min": 1,
			},
			"presence_tokens": {
				"type": "int",
				"min": 1,
			},
			"max_commit_assets": {
				"type": "int",
				"min": 1,
				"default": 3,
			},
			"max_condition_commit_assets": {
				"type": "int",
				"min": 1,
				"default": 2,
			},
			"condition_qualified_threshold": {
				"type": "int",
				"min": 1,
				"default": 2,
			},
			"minimum_confluences": {
				"type": "int",
				"min": 0,
				"default": 0,
			},
			"entities": {
				"type": "Array",
				"min_items": 2,
				"element": {
					"type": "String",
					"pattern": "^ENT_[A-Z0-9_]+$",
				},
			},
			"regions": {
				"type": "Array",
				"min_items": 2,
				"element": {
					"type": "String",
					"pattern": "^REG_[A-Z0-9_]+$",
				},
			},
			"tensions": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "String",
					"pattern": "^TEN_[A-Z0-9_]+$",
				},
			},
			"drift_distribution": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "Dictionary",
				},
			},
			"act_echo_pools": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "Dictionary",
				},
			},
			"confluence_templates": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "String",
					"pattern": "^CNF_[A-Z0-9_]+$",
				},
			},
			"starting_relations": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"starting_control": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"global_tags": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"opening_text": {
				"type": "String",
				"min_length": 1,
			},
			"influence_rules": {
				"type": "Dictionary",
			},
			"confluence_rules": {
				"type": "Dictionary",
			},
			"starting_structures": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"structure_rules": {
				"type": "Dictionary",
			},
			"tension_tokens": {
				"type": "Dictionary",
			},
			"claim_rules": {
				"type": "Dictionary",
			},
			"veiled_tensions": {
				"type": "String",
				"enum": [
					"HIDES_ALL",
					"HIDES_THRESHOLD",
				],
				"default": "HIDES_ALL",
			},
			"hand_refill": {
				"type": "Dictionary",
			},
			"actions_from_cards": {
				"type": "bool",
				"default": false,
			},
			"saga_scoring": {
				"type": "Dictionary",
			},
			"control_rules": {
				"type": "Dictionary",
			},
			"tension_pool": {
				"type": "Dictionary",
			},
			"enduring_facts": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"era_tallies": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"years_after_previous": {
				"type": "Variant",
			},
			"destiny_pool": {
				"type": "Dictionary",
			},
			"objectives": {
				"type": "Dictionary",
			},
			"sequel_id": {
				"type": "String",
				"pattern": "^CHR_[A-Z0-9_]+$",
			},
		},
	},
	"confluence_template": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"questions",
			"propositions",
			"condition_clauses",
			"consequence_pools",
			"ripple",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^CNF_[A-Z0-9_]+$",
			},
			"tension_id": {
				"type": "String",
				"pattern": "^TEN_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"description": {
				"type": "String",
			},
			"questions": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "Dictionary",
				},
			},
			"propositions": {
				"type": "Array",
				"min_items": 2,
				"element": {
					"type": "Dictionary",
				},
			},
			"condition_clauses": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "Dictionary",
				},
			},
			"consequence_pools": {
				"type": "Dictionary",
			},
			"ripple": {
				"type": "Dictionary",
			},
			"echo_title_template": {
				"type": "String",
			},
			"applies_to_domain": {
				"type": "String",
			},
		},
	},
	"consequence": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"category",
			"description",
			"effects",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^CNS_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"category": {
				"type": "String",
				"enum": [
					"CONTROL",
					"PRESENCE",
					"ALLIANCE",
					"HOSTILITY",
					"PACT",
					"DEBT",
					"WAR",
					"MIGRATION",
					"FAMINE",
					"PROSPERITY",
					"DEVASTATION",
					"CORRUPTION",
					"DISCOVERY",
					"SECRET",
					"INFLUENCE",
					"REVOLT",
					"FORTIFICATION",
					"SETTLEMENT",
					"EXPLOITATION",
					"THREAT",
				],
			},
			"description": {
				"type": "String",
				"min_length": 1,
			},
			"creates_scar": {
				"type": "bool",
				"default": false,
			},
			"scar": {
				"type": "Dictionary",
			},
			"effects": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "Dictionary",
				},
			},
		},
	},
	"destiny": {
		"kind": "collection",
		"required": [
			"id",
			"entity_id",
			"title",
			"description",
			"minimum",
			"victory",
			"triumph",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^DST_[A-Z0-9_]+$",
			},
			"entity_id": {
				"type": "String",
				"pattern": "^(ENT_[A-Z0-9_]+|\\$self)$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"description": {
				"type": "String",
				"min_length": 1,
			},
			"minimum": {
				"type": "Dictionary",
			},
			"victory": {
				"type": "Dictionary",
			},
			"triumph": {
				"type": "Dictionary",
			},
			"art_prompt_key": {
				"type": "String",
			},
		},
	},
	"echo_card": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"dramatic_family",
			"function_id",
			"description",
			"eligibility",
			"effect_hooks",
			"art_prompt_key",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^ECH_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"dramatic_family": {
				"type": "String",
				"enum": [
					"PRESSURE",
					"RUPTURE",
					"TURN",
					"RESOLUTION",
					"MEMORIA",
				],
			},
			"function_id": {
				"type": "String",
				"enum": [
					"LACK",
					"THREAT",
					"PROHIBITION",
					"REQUEST",
					"TEMPTATION",
					"OMEN",
					"VIOLATION",
					"BETRAYAL",
					"LOSS",
					"ATTACK",
					"SEPARATION",
					"USURPATION",
					"DISCOVERY",
					"REVELATION",
					"GIFT",
					"ENCOUNTER",
					"TRANSFORMATION",
					"RETURN",
					"SACRIFICE",
					"CONQUEST",
					"RECONCILIATION",
					"PUNISHMENT",
					"LIBERATION",
					"SUCCESSION",
				],
			},
			"description": {
				"type": "String",
				"min_length": 1,
			},
			"eligibility": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"effect_hooks": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"forces_confluence_on": {
				"type": "String",
				"nullable": true,
			},
			"art_prompt_key": {
				"type": "String",
				"min_length": 1,
			},
		},
	},
	"effect": {
		"kind": "runtime",
		"required": [
			"effect_id",
			"type",
			"target",
			"payload",
			"source",
			"reversible",
		],
		"additional_properties": false,
		"properties": {
			"effect_id": {
				"type": "String",
				"pattern": "^EFF_[0-9]{6}$",
			},
			"type": {
				"type": "String",
				"enum": [
					"ADJUST_TENSION",
					"SET_TENSION_VISIBILITY",
					"ADD_PRESENCE",
					"REMOVE_PRESENCE",
					"SET_CONTROL",
					"SET_REGION_TAG",
					"REMOVE_REGION_TAG",
					"SET_GLOBAL_TAG",
					"REMOVE_GLOBAL_TAG",
					"SET_RELATION",
					"GRANT_ASSET",
					"REMOVE_ASSET",
					"TRANSFER_ASSET",
					"CREATE_CLAIM",
					"CONSUME_CLAIM",
					"ADD_SCAR",
					"REMOVE_SCAR",
					"SET_ENTITY_TAG",
					"REMOVE_ENTITY_TAG",
					"SET_ENTITY_ACTIVE",
					"BUILD_STRUCTURE",
					"RAZE_STRUCTURE",
					"SET_STRUCTURE_GRADE",
					"CLOSE_PASSAGE",
					"OPEN_PASSAGE",
					"CREATE_ECHO",
					"APPEND_TRUTH",
				],
			},
			"target": {
				"type": "Dictionary",
			},
			"payload": {
				"type": "Dictionary",
			},
			"source": {
				"type": "Dictionary",
			},
			"reversible": {
				"type": "bool",
			},
			"inverse_type": {
				"type": "String",
				"enum": [
					"ADJUST_TENSION",
					"SET_TENSION_VISIBILITY",
					"ADD_PRESENCE",
					"REMOVE_PRESENCE",
					"SET_CONTROL",
					"SET_REGION_TAG",
					"REMOVE_REGION_TAG",
					"SET_GLOBAL_TAG",
					"REMOVE_GLOBAL_TAG",
					"SET_RELATION",
					"GRANT_ASSET",
					"REMOVE_ASSET",
					"TRANSFER_ASSET",
					"CREATE_CLAIM",
					"CONSUME_CLAIM",
					"ADD_SCAR",
					"REMOVE_SCAR",
					"SET_ENTITY_TAG",
					"REMOVE_ENTITY_TAG",
					"SET_ENTITY_ACTIVE",
					"BUILD_STRUCTURE",
					"RAZE_STRUCTURE",
					"SET_STRUCTURE_GRADE",
					"CLOSE_PASSAGE",
					"OPEN_PASSAGE",
					"CREATE_ECHO",
					"APPEND_TRUTH",
				],
			},
			"inverse_payload": {
				"type": "Dictionary",
			},
		},
	},
	"entity": {
		"kind": "collection",
		"required": [
			"id",
			"name",
			"archetype",
			"need",
			"description",
			"action_values",
			"starting_assets",
			"relations",
			"presence",
			"destiny_id",
			"private_information",
			"tags",
			"active",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^ENT_[A-Z0-9_]+$",
			},
			"name": {
				"type": "String",
				"min_length": 1,
			},
			"archetype": {
				"type": "String",
				"enum": [
					"INDIVIDUAL",
					"SOVEREIGN",
					"PEOPLE",
					"FACTION",
					"CREATURE",
					"CULT",
				],
			},
			"need": {
				"type": "String",
				"enum": [
					"POWER",
					"SURVIVAL",
					"FREEDOM",
					"KNOWLEDGE",
					"WEALTH",
					"REVENGE",
					"PROTECTION",
					"FAITH",
				],
			},
			"description": {
				"type": "String",
				"min_length": 1,
			},
			"action_values": {
				"type": "Dictionary",
			},
			"starting_assets": {
				"type": "Array",
				"element": {
					"type": "String",
					"pattern": "^AST_[A-Z0-9_]+$",
				},
			},
			"relations": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"presence": {
				"type": "Array",
				"max_items": 3,
				"element": {
					"type": "String",
					"pattern": "^REG_[A-Z0-9_]+$",
				},
			},
			"destiny_id": {
				"type": "String",
				"pattern": "^DST_[A-Z0-9_]+$",
			},
			"private_information": {
				"type": "String",
			},
			"tags": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"active": {
				"type": "bool",
			},
			"art_prompt_key": {
				"type": "String",
			},
			"persistence": {
				"type": "String",
				"enum": [
					"MORTAL",
					"COLLECTIVE",
					"ETERNAL",
				],
			},
			"successors": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"destiny_pool": {
				"type": "Array",
				"element": {
					"type": "String",
					"pattern": "^DST_[A-Z0-9_]+$",
				},
			},
			"name_grammar": {
				"type": "Dictionary",
			},
			"incarnations": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "Dictionary",
				},
			},
		},
	},
	"objective": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"description",
			"label",
			"conditions",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^OBJ_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"description": {
				"type": "String",
				"min_length": 1,
			},
			"label": {
				"type": "String",
				"min_length": 1,
			},
			"conditions": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "Dictionary",
				},
			},
			"art_prompt_key": {
				"type": "String",
			},
		},
	},
	"region": {
		"kind": "collection",
		"required": [
			"id",
			"name",
			"biome",
			"role",
			"adjacency",
			"asset_sources",
			"tags",
			"presence_slots",
			"art_prompt_key",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^REG_[A-Z0-9_]+$",
			},
			"name": {
				"type": "String",
				"min_length": 1,
			},
			"biome": {
				"type": "String",
				"enum": [
					"CITY",
					"VALLEY",
					"STEPPE",
					"MOUNTAIN",
					"UNDERGROUND",
					"ROAD",
					"FOREST",
					"COAST",
				],
			},
			"role": {
				"type": "String",
				"enum": [
					"PRIMARY",
					"SECONDARY",
				],
			},
			"adjacency": {
				"type": "Array",
				"element": {
					"type": "String",
					"pattern": "^REG_[A-Z0-9_]+$",
				},
			},
			"asset_sources": {
				"type": "Array",
				"element": {
					"type": "String",
					"enum": [
						"FORCE",
						"AUTHORITY",
						"PEOPLE",
						"KNOWLEDGE",
						"WEALTH",
						"BONDS",
					],
				},
			},
			"tags": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"presence_slots": {
				"type": "int",
				"min": 1,
				"max": 6,
			},
			"control": {
				"type": "String",
				"nullable": true,
			},
			"private_information": {
				"type": "String",
			},
			"description": {
				"type": "String",
			},
			"art_prompt_key": {
				"type": "String",
				"min_length": 1,
			},
			"name_forms": {
				"type": "Dictionary",
			},
			"map_position": {
				"type": "Dictionary",
			},
		},
	},
	"save": {
		"kind": "runtime",
		"required": [
			"save_version",
			"data_version",
			"chronicle_id",
			"world_state",
			"assignments",
		],
		"additional_properties": false,
		"properties": {
			"save_version": {
				"type": "String",
				"pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$",
			},
			"data_version": {
				"type": "String",
			},
			"chronicle_id": {
				"type": "String",
			},
			"world_state": {
				"type": "Dictionary",
			},
			"assignments": {
				"type": "Dictionary",
			},
			"pending_confluence": {
				"type": "Dictionary",
				"nullable": true,
			},
			"destiny_results": {
				"type": "Dictionary",
			},
			"confluence_results": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"label": {
				"type": "String",
			},
		},
	},
	"sim_plan": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"chronicle_id",
			"seed",
			"seats",
			"turns",
			"confluences",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^SIM_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"description": {
				"type": "String",
			},
			"chronicle_id": {
				"type": "String",
				"pattern": "^CHR_[A-Z0-9_]+$",
			},
			"seed": {
				"type": "int",
				"min": 0,
			},
			"seats": {
				"type": "Array",
				"min_items": 2,
				"max_items": 4,
				"element": {
					"type": "String",
					"pattern": "^ENT_[A-Z0-9_]+$",
				},
			},
			"chronicle_overrides": {
				"type": "Dictionary",
			},
			"fallback_action": {
				"type": "Dictionary",
			},
			"turns": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"confluences": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"expected": {
				"type": "Dictionary",
			},
		},
	},
	"structure_type": {
		"kind": "collection",
		"required": [
			"id",
			"name",
			"family",
			"owned",
			"grades",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^STR_[A-Z0-9_]+$",
			},
			"name": {
				"type": "String",
			},
			"description": {
				"type": "String",
			},
			"family": {
				"type": "String",
				"enum": [
					"PRESIDIO",
					"INSEDIAMENTO",
					"OPERA",
					"LUOGO",
					"CHIUSURA",
				],
			},
			"owned": {
				"type": "bool",
			},
			"biomes": {
				"type": "Array",
				"element": {
					"type": "String",
					"enum": [
						"CITY",
						"VALLEY",
						"STEPPE",
						"MOUNTAIN",
						"UNDERGROUND",
						"ROAD",
					],
				},
			},
			"grades": {
				"type": "Array",
				"min_items": 1,
				"max_items": 4,
				"element": {
					"type": "Dictionary",
				},
			},
			"ruin": {
				"type": "Dictionary",
			},
		},
	},
	"tag_rule": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"when",
			"kind",
			"active",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^TGR_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"when": {
				"type": "Dictionary",
			},
			"kind": {
				"type": "String",
				"enum": [
					"ACTION_MODIFIER",
					"COUNCIL_MODIFIER",
					"GATE",
					"RELATION_CAP",
					"ACTION_GATE",
					"DRAW_BIAS",
					"HAND_LIMIT",
					"GRANT_ON_SET",
					"RELATION_FLOOR",
					"STANCE_MODIFIER",
					"CONDITION_THRESHOLD",
					"ACTION_GRANT",
					"ACTION_RIPPLE",
					"ACTION_DISCOUNT",
				],
			},
			"template": {
				"type": "String",
				"enum": [
					"ACQUIRE",
					"MOVE",
					"INFLUENCE",
					"FORGE",
					"SCHEME",
					"CLAIM",
				],
			},
			"tension_id": {
				"type": "String",
				"pattern": "^TEN_[A-Z0-9_]+$",
			},
			"delta": {
				"type": "int",
				"min": -2,
				"max": 2,
			},
			"world_factor_delta": {
				"type": "int",
				"min": -2,
				"max": 2,
			},
			"movement": {
				"type": "String",
				"enum": [
					"BLOCK",
					"ALLOW",
					"PASS",
				],
			},
			"passes_eviction": {
				"type": "bool",
			},
			"max_level": {
				"type": "String",
				"enum": [
					"ENEMY",
					"HOSTILE",
					"NEUTRAL",
					"ALLY",
				],
			},
			"min_level": {
				"type": "String",
				"enum": [
					"HOSTILE",
					"NEUTRAL",
					"ALLY",
					"BOUND",
				],
			},
			"family": {
				"type": "String",
				"enum": [
					"FORCE",
					"AUTHORITY",
					"WEALTH",
					"KNOWLEDGE",
					"PEOPLE",
					"BONDS",
				],
			},
			"bias": {
				"type": "String",
				"enum": [
					"MALUS",
					"BONUS",
				],
			},
			"hand_limit_delta": {
				"type": "int",
				"min": -3,
				"max": 3,
			},
			"grant": {
				"type": "Dictionary",
			},
			"chronicle_id": {
				"type": "String",
				"pattern": "^CHR_[A-Z0-9_]+$",
			},
			"active": {
				"type": "bool",
			},
			"note": {
				"type": "String",
			},
			"when_also": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"stance": {
				"type": "String",
				"enum": [
					"SUPPORT",
					"OPPOSE",
				],
			},
			"stance_delta": {
				"type": "int",
				"min": -2,
				"max": 2,
			},
			"threshold_delta": {
				"type": "int",
				"min": -1,
				"max": 1,
			},
			"grants": {
				"type": "String",
				"enum": [
					"SCHEME_VEIL",
				],
			},
			"ripple_delta": {
				"type": "int",
				"min": -2,
				"max": 2,
			},
		},
	},
	"tension": {
		"kind": "collection",
		"required": [
			"id",
			"title",
			"domain",
			"current_value",
			"threshold",
			"visibility",
			"relevant_asset_families",
			"omen_thresholds",
			"possible_questions",
			"triggers",
			"decrease_rules",
			"linked_tensions",
		],
		"additional_properties": false,
		"properties": {
			"id": {
				"type": "String",
				"pattern": "^TEN_[A-Z0-9_]+$",
			},
			"title": {
				"type": "String",
				"min_length": 1,
			},
			"domain": {
				"type": "String",
				"enum": [
					"TERRITORY",
					"RESOURCE",
					"SURVIVAL",
					"KNOWLEDGE",
					"ANCIENT",
				],
			},
			"current_value": {
				"type": "int",
				"min": 0,
			},
			"threshold": {
				"type": "int",
				"min": 1,
			},
			"visibility": {
				"type": "String",
				"enum": [
					"OPEN",
					"VEILED",
					"SECRET",
				],
			},
			"relevant_asset_families": {
				"type": "Array",
				"min_items": 1,
				"element": {
					"type": "String",
					"enum": [
						"FORCE",
						"AUTHORITY",
						"PEOPLE",
						"KNOWLEDGE",
						"WEALTH",
						"BONDS",
					],
				},
			},
			"omen_thresholds": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"possible_questions": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"triggers": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"decrease_rules": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"linked_tensions": {
				"type": "Array",
				"element": {
					"type": "String",
					"pattern": "^TEN_[A-Z0-9_]+$",
				},
			},
			"confluence_template_id": {
				"type": "String",
				"pattern": "^CNF_[A-Z0-9_]+$",
			},
			"description": {
				"type": "String",
			},
			"focus_region_tags": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"opening_line": {
				"type": "String",
				"min_length": 1,
			},
		},
	},
	"world_state": {
		"kind": "runtime",
		"required": [
			"world_id",
			"year",
			"chronicle_id",
			"act",
			"round",
			"phase",
			"entities",
			"regions",
			"tensions",
			"relations",
			"global_tags",
			"claims",
			"echo_log",
			"truth_log",
			"scars",
			"effect_log",
			"rng_seed",
			"rng_state",
		],
		"additional_properties": false,
		"properties": {
			"world_id": {
				"type": "String",
			},
			"year": {
				"type": "int",
			},
			"chronicles_played": {
				"type": "int",
				"min": 1,
			},
			"chronicle_id": {
				"type": "String",
			},
			"act": {
				"type": "int",
				"min": 0,
			},
			"round": {
				"type": "int",
				"min": 0,
			},
			"phase": {
				"type": "String",
				"enum": [
					"SETUP",
					"ACTIONS",
					"DRIFT",
					"THRESHOLD_CHECK",
					"CONFLUENCE",
					"ACT_ECHO",
					"CHRONICLE_END",
				],
			},
			"entities": {
				"type": "Dictionary",
			},
			"regions": {
				"type": "Dictionary",
			},
			"tensions": {
				"type": "Dictionary",
			},
			"relations": {
				"type": "Dictionary",
			},
			"global_tags": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"claims": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"echo_log": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"truth_log": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"scars": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"effect_log": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"rng_seed": {
				"type": "int",
			},
			"rng_state": {
				"type": "int",
			},
			"decks": {
				"type": "Dictionary",
			},
			"echo_deck": {
				"type": "Dictionary",
			},
			"echoes_played_in_act": {
				"type": "int",
				"min": 0,
			},
			"drift_track": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"drift_index": {
				"type": "int",
				"min": 0,
			},
			"confluence_queue": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"last_proponent": {
				"type": "Dictionary",
			},
			"questions_asked": {
				"type": "Dictionary",
			},
			"forced_confluence": {
				"type": "Dictionary",
				"nullable": true,
			},
			"confluence_count": {
				"type": "int",
				"min": 0,
			},
			"voted_together": {
				"type": "Dictionary",
			},
			"effect_sequence": {
				"type": "int",
				"min": 0,
			},
			"turn_order": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"influence_used": {
				"type": "Dictionary",
			},
			"influence_used_by_tension": {
				"type": "Dictionary",
			},
			"opening_record": {
				"type": "Array",
				"element": {
					"type": "Dictionary",
				},
			},
			"map_record": {
				"type": "Dictionary",
			},
			"open_failures": {
				"type": "Array",
				"element": {
					"type": "String",
				},
			},
			"tokens_in_bag": {
				"type": "int",
				"min": 0,
			},
		},
	},
}

## schema_id values that appear as authored collections under res://data.
const COLLECTION_SCHEMA_IDS := [
	"action",
	"asset",
	"chronicle",
	"confluence_template",
	"consequence",
	"destiny",
	"echo_card",
	"entity",
	"objective",
	"region",
	"sim_plan",
	"structure_type",
	"tag_rule",
	"tension",
]

## Closed EffectType enum (spec v0.2 §6.3).
const EFFECT_TYPES := [
	"ADJUST_TENSION",
	"SET_TENSION_VISIBILITY",
	"ADD_PRESENCE",
	"REMOVE_PRESENCE",
	"SET_CONTROL",
	"SET_REGION_TAG",
	"REMOVE_REGION_TAG",
	"SET_GLOBAL_TAG",
	"REMOVE_GLOBAL_TAG",
	"SET_RELATION",
	"GRANT_ASSET",
	"REMOVE_ASSET",
	"TRANSFER_ASSET",
	"CREATE_CLAIM",
	"CONSUME_CLAIM",
	"ADD_SCAR",
	"REMOVE_SCAR",
	"SET_ENTITY_TAG",
	"REMOVE_ENTITY_TAG",
	"SET_ENTITY_ACTIVE",
	"BUILD_STRUCTURE",
	"RAZE_STRUCTURE",
	"SET_STRUCTURE_GRADE",
	"CLOSE_PASSAGE",
	"OPEN_PASSAGE",
	"CREATE_ECHO",
	"APPEND_TRUTH",
]

const EFFECT_TARGET_KINDS := [
	"tension",
	"entity",
	"region",
	"relation",
	"world",
	"claim",
	"scar",
	"echo",
	"truth",
]

const EFFECT_SOURCE_KINDS := [
	"action",
	"system",
	"confluence",
	"consequence",
	"echo_card",
	"developer",
]

const CONDITION_TYPES := [
	"control_count",
	"state_tag_present",
	"state_tag_absent",
	"asset_threshold",
	"entity_alive",
	"relation_state",
	"tension_limit",
	"discovery_count",
	"region_presence",
	"promise_kept",
	"promise_broken",
	"structure_count",
	"scar_count",
	"any_of",
	"some_of",
]

const ASSET_FAMILIES := [
	"FORCE",
	"AUTHORITY",
	"PEOPLE",
	"KNOWLEDGE",
	"WEALTH",
	"BONDS",
]

const RELATION_LEVELS := [
	"ENEMY",
	"HOSTILE",
	"NEUTRAL",
	"ALLY",
	"BOUND",
]

const PHASES := [
	"SETUP",
	"ACTIONS",
	"DRIFT",
	"THRESHOLD_CHECK",
	"CONFLUENCE",
	"ACT_ECHO",
	"CHRONICLE_END",
]

const ACTION_TEMPLATES := [
	"ACQUIRE",
	"MOVE",
	"INFLUENCE",
	"FORGE",
	"SCHEME",
	"CLAIM",
]

const CONSEQUENCE_CATEGORIES := [
	"CONTROL",
	"PRESENCE",
	"ALLIANCE",
	"HOSTILITY",
	"PACT",
	"DEBT",
	"WAR",
	"MIGRATION",
	"FAMINE",
	"PROSPERITY",
	"DEVASTATION",
	"CORRUPTION",
	"DISCOVERY",
	"SECRET",
	"INFLUENCE",
	"REVOLT",
	"FORTIFICATION",
	"SETTLEMENT",
	"EXPLOITATION",
	"THREAT",
]

const DRAMATIC_FAMILIES := [
	"PRESSURE",
	"RUPTURE",
	"TURN",
	"RESOLUTION",
	"MEMORIA",
]
