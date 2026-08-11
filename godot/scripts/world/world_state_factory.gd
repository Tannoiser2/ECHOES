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
		"influence_used_by_tension": {},
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

	for tension_id in resolve_tensions(chronicle, rng):
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


## Which Tensions this Chronicle actually runs.
##
## `tensions` written out is the authored form. `tension_pool` is the library
## form: the Chronicle names what it *could* be about and the seeded RNG deals
## the year. That is what lets Chronicle N+1 exist without anyone writing it -
## the questions are library content, and the Chronicle is the hand (D-028).
##
## Deterministic by construction: the draw uses the same seeded RNG as the decks
## and the drift bag, so the same seed always deals the same year.
static func resolve_tensions(chronicle: Dictionary, rng: RefCounted) -> Array:
	if not chronicle.has("tension_pool"):
		return (chronicle["tensions"] as Array).duplicate()

	var pool: Dictionary = chronicle["tension_pool"]
	var drawn: Array = (pool.get("always", []) as Array).duplicate()
	var candidates: Array = []
	for tension_id in pool["candidates"]:
		if not drawn.has(str(tension_id)):
			candidates.append(str(tension_id))
	candidates.sort()
	for tension_id in rng.shuffle(candidates):
		if drawn.size() >= int(pool["count"]):
			break
		drawn.append(str(tension_id))
	return drawn


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
	if chronicle.has("drift_distribution"):
		for entry in chronicle["drift_distribution"]:
			for _i in range(int(entry["count"])):
				bag.append(str(entry["tension_id"]))
	else:
		# Library form: one chip per round, dealt round-robin over whatever was
		# drawn, so every question in play gets pushed by the world at least once.
		var ids: Array = (world["tensions"] as Dictionary).keys()
		ids.sort()
		var rounds: int = int(chronicle["acts"]) * int(chronicle["rounds_per_act"])
		for i in range(rounds):
			bag.append(str(ids[i % ids.size()]))
	world["drift_track"] = rng.shuffle(bag)
	world["drift_index"] = 0


## Tag prefixes a Chronicle hands to the next one. Everything else - hands,
## decks, presence, Tension values, Claims - is dealt fresh: a new Chronicle is
## a new year, not a saved game.
const INHERITED_TAG_PREFIXES: Array = ["condition:", "structure:", "settlement:", "scar:"]


## What Chronicle N leaves to Chronicle N+1, expressed as Effects so the carry
## over goes through the same applier, the same log and the same inverse as
## everything else (§6.3). A full propagation engine is 0.3; this is the part
## of it a measurement needs - the map remembers, the people remember, the
## question resets.
static func inheritance_effects(previous: Dictionary, chronicle: Dictionary, data: RefCounted) -> Array:
	var effects: Array = []
	var source: Dictionary = Effect.source("system", "INHERITANCE", "", 0, 0, 0)
	if previous.is_empty():
		return effects

	var lapse: bool = bool(
		(chronicle.get("control_rules", {}) as Dictionary).get("lapse_without_presence", false)
	)

	for region_id in chronicle["regions"]:
		var before: Variant = (previous["regions"] as Dictionary).get(str(region_id))
		if before == null:
			continue
		var base: Dictionary = data.regions[str(region_id)]
		var control: Variant = before.get("control", null)
		# D-027: you cannot govern where you are not. A Region held at the end of
		# a Chronicle with nobody standing in it reverts before the next one
		# opens - which is how a dynasty that spread too thin loses the edges
		# first, without anyone having to take them.
		if lapse and control != null and not _had_presence(previous, str(control), str(region_id)):
			control = null
		if str(control if control != null else "") != str(base.get("control", "") if base.get("control", null) != null else ""):
			effects.append(
				Effect.make("SET_CONTROL", "region", str(region_id), {"entity_id": control}, source)
			)
		for tag in before.get("tags", []):
			if (base["tags"] as Array).has(str(tag)):
				continue
			for prefix in INHERITED_TAG_PREFIXES:
				if str(tag).begins_with(prefix):
					effects.append(
						Effect.make("SET_REGION_TAG", "region", str(region_id), {"tag": str(tag)}, source)
					)
					break

	for key in previous.get("relations", {}):
		var relation: Dictionary = previous["relations"][key]
		effects.append(
			Effect.make(
				"SET_RELATION",
				"relation",
				str(key),
				{"level": str(relation["level"]), "tags": (relation["tags"] as Array).duplicate()},
				source
			)
		)

	for tag in previous.get("global_tags", []):
		if (chronicle.get("global_tags", []) as Array).has(str(tag)):
			continue
		effects.append(Effect.make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": str(tag)}, source))

	# Scars are the visible half of the world's memory: they stay on the map.
	for scar in previous.get("scars", []):
		effects.append(
			Effect.make("ADD_SCAR", "region", str(scar["region_id"]), (scar as Dictionary).duplicate(true), source)
		)

	return effects


static func _had_presence(previous: Dictionary, entity_id: String, region_id: String) -> bool:
	var entity: Variant = (previous.get("entities", {}) as Dictionary).get(entity_id)
	if entity == null:
		return false
	return (entity.get("presence", []) as Array).has(region_id)


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
