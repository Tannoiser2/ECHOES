extends RefCounted
## Builds the opening WorldState for a Chronicle (§13, §22).
##
## Structural state (which entities, regions, tensions and decks exist) is
## constructed directly: that *is* the initial state, not a mutation of it.
## Everything that a player could later change - presence tokens, opening hands -
## is applied as setup Effects with source kind "system", so the effect_log
## explains the whole table from EFF_000001 onwards. See DECISIONS D-003.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")

const DEFAULT_DECK_COPIES: int = 3


static func build(chronicle: Dictionary, data: RefCounted, rng: RefCounted, seats: Array) -> Dictionary:
	var world: Dictionary = {
		"world_id": str(chronicle["world_id"]),
		"year": int(chronicle["start_year"]),
		"chronicle_id": str(chronicle["id"]),
		"act": 0,
		"round": 0,
		"phase": "SETUP",
		"entities": {},
		"regions": {},
		"tensions": {},
		"relations": {},
		"global_tags": (chronicle.get("global_tags", []) as Array).duplicate(),
		"claims": [],
		"echo_log": [],
		"truth_log": [],
		"scars": [],
		"effect_log": [],
		"rng_seed": rng.get_seed(),
		"rng_state": 0,
		"decks": {},
		"echo_deck": {"draw": [], "drawn": []},
		"drift_track": [],
		"drift_index": 0,
		"confluence_queue": [],
		"forced_confluence": null,
		"confluence_count": 0,
		"effect_sequence": 0,
		"turn_order": seats.duplicate(),
		"influence_used": {},
	}

	for entity_id in chronicle["entities"]:
		var definition: Dictionary = data.entities[entity_id]
		world["entities"][entity_id] = {
			"id": entity_id,
			"presence": [],
			"hand": [],
			"tags": (definition["tags"] as Array).duplicate(),
			"active": bool(definition["active"]),
			"ao_remaining": 0,
		}

	for region_id in chronicle["regions"]:
		var definition: Dictionary = data.regions[region_id]
		world["regions"][region_id] = {
			"id": region_id,
			"control": definition.get("control", null),
			"tags": (definition["tags"] as Array).duplicate(),
		}

	for tension_id in chronicle["tensions"]:
		var definition: Dictionary = data.tensions[tension_id]
		world["tensions"][tension_id] = {
			"id": tension_id,
			"current_value": int(definition["current_value"]),
			"visibility": str(definition["visibility"]),
			"fired_omens": [],
			"resolved_count": 0,
		}

	_build_relations(world, chronicle, data)
	_build_asset_decks(world, chronicle, data, rng)
	_build_echo_deck(world, data, rng)
	_build_drift_track(world, chronicle, rng)
	return world


## Every unordered pair of Entities starts at NEUTRAL so SET_RELATION always has
## a record to overwrite (and therefore always has an exact inverse).
static func _build_relations(world: Dictionary, chronicle: Dictionary, data: RefCounted) -> void:
	var ids: Array = (chronicle["entities"] as Array).duplicate()
	ids.sort()
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			world["relations"][Ids.relation_key(str(ids[i]), str(ids[j]))] = {
				"level": "NEUTRAL",
				"tags": [],
			}

	for entity_id in ids:
		for relation in data.entities[entity_id]["relations"]:
			var other: String = str(relation["with"])
			if not world["entities"].has(other):
				continue
			var record: Dictionary = world["relations"][Ids.relation_key(str(entity_id), other)]
			record["level"] = str(relation["level"])
			for tag in relation.get("tags", []):
				if not record["tags"].has(tag):
					record["tags"].append(tag)

	for relation in chronicle.get("starting_relations", []):
		var key: String = Ids.relation_key(str(relation["a"]), str(relation["b"]))
		if not world["relations"].has(key):
			continue
		world["relations"][key]["level"] = str(relation["level"])
		for tag in relation.get("tags", []):
			if not world["relations"][key]["tags"].has(tag):
				world["relations"][key]["tags"].append(tag)


## One draw pile per family (§9). Starting-hand cards are taken out of the pile
## before the shuffle so the total number of copies in play stays honest.
static func _build_asset_decks(
	world: Dictionary, chronicle: Dictionary, data: RefCounted, rng: RefCounted
) -> void:
	var dealt: Dictionary = {}
	for entity_id in chronicle["entities"]:
		for asset_id in data.entities[entity_id]["starting_assets"]:
			dealt[asset_id] = int(dealt.get(asset_id, 0)) + 1

	var families: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]
	for family in families:
		var pile: Array = []
		for asset in data.assets_of_family(family):
			var copies: int = int(asset.get("deck_copies", DEFAULT_DECK_COPIES))
			var already_dealt: int = int(dealt.get(str(asset["id"]), 0))
			for _i in range(maxi(0, copies - already_dealt)):
				pile.append(str(asset["id"]))
		world["decks"][family] = {"draw": rng.shuffle(pile), "discard": []}


## A single shuffled Echo deck; the Act pools (§15) filter it by dramatic family
## at draw time, so "the top of the Act deck" is well defined and reproducible.
static func _build_echo_deck(world: Dictionary, data: RefCounted, rng: RefCounted) -> void:
	var ids: Array = []
	for card in data.echo_cards.values():
		ids.append(str(card["id"]))
	ids.sort()
	world["echo_deck"] = {"draw": rng.shuffle(ids), "drawn": []}


## The drift bag (§11.2): a fixed distribution shuffled once with the seeded RNG.
static func _build_drift_track(world: Dictionary, chronicle: Dictionary, rng: RefCounted) -> void:
	var bag: Array = []
	for entry in chronicle["drift_distribution"]:
		for _i in range(int(entry["count"])):
			bag.append(str(entry["tension_id"]))
	world["drift_track"] = rng.shuffle(bag)
	world["drift_index"] = 0


## Setup Effects: presence tokens and opening hands (§13).
static func setup_effects(chronicle: Dictionary, data: RefCounted) -> Array:
	var effects: Array = []
	var source: Dictionary = Effect.source("system", "SETUP", "", 0, 0, 0)
	for entity_id in chronicle["entities"]:
		var definition: Dictionary = data.entities[entity_id]
		for region_id in definition["presence"]:
			effects.append(
				Effect.make("ADD_PRESENCE", "entity", entity_id, {"region_id": region_id}, source)
			)
		for asset_id in definition["starting_assets"]:
			effects.append(
				Effect.make(
					"GRANT_ASSET",
					"entity",
					entity_id,
					{"asset_id": asset_id, "source": "VOID"},
					source
				)
			)
	return effects
