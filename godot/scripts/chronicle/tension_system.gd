extends RefCounted
## Drift, omens and threshold checks (§11).

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var log: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted, p_applier: RefCounted, p_log: RefCounted) -> void:
	world = p_world
	data = p_data
	applier = p_applier
	log = p_log


## §11.2: at the end of every round the world pushes one Tension up by 1,
## following the drift track shuffled at setup.
func apply_drift() -> String:
	var track: Array = world["drift_track"]
	var index: int = int(world["drift_index"])
	if index >= track.size():
		log.bullet("Drift: la traccia e esaurita, nessuna Tensione sale.")
		return ""
	var tension_id: String = str(track[index])
	world["drift_index"] = index + 1

	var source: Dictionary = Effect.source(
		"system", "DRIFT", "", int(world["act"]), int(world["round"]), index
	)
	applier.apply(
		Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": 1}, source)
	)
	log.bullet("Drift: %s sale di 1." % _public_name(tension_id))
	fire_omens(source)
	return tension_id


## Public narrative signals (§11.3). The message comes from the data; the code
## never invents one, and a veiled Tension never leaks its number here.
func fire_omens(source: Dictionary) -> void:
	for tension_id in world["tensions"]:
		var state: Dictionary = world["tensions"][tension_id]
		var definition: Dictionary = data.tensions[tension_id]
		for omen in definition["omen_thresholds"]:
			var at: int = int(omen["at"])
			if int(state["current_value"]) < at:
				continue
			if (state["fired_omens"] as Array).has(at):
				continue
			state["fired_omens"].append(at)
			log.bullet("Presagio - %s" % str(omen["message"]))
			if bool(omen.get("reveals_value", false)):
				var revealed: Dictionary = applier.apply(
					Effect.make(
						"SET_TENSION_VISIBILITY",
						"tension",
						str(tension_id),
						{"visibility": "OPEN"},
						source
					)
				)
				# ISSUES 22 (fase 4): il presagio parlava, la rivelazione no -
				# il numero arrivava sul tavolo in silenzio. Se ha davvero
				# svelato qualcosa (niente no-op), adesso lo dice.
				var said: String = EffectNarrator.narrate(revealed, data)
				if said != "":
					log.bullet(said)


## §7: at most one Confluence opens per round. Tensions at or over threshold are
## ranked by value, then by the Chronicle's definition order; the rest queue up.
func tensions_at_threshold() -> Array:
	var ready: Array = []
	for tension_id in world["tensions"]:
		var value: int = int(world["tensions"][tension_id]["current_value"])
		if value >= int(data.tensions[tension_id]["threshold"]):
			ready.append(str(tension_id))
	# Draw order for a library Chronicle, written order for an authored one:
	# world["tensions"] holds whichever applies (D-028).
	var order: Array = (world["tensions"] as Dictionary).keys()
	ready.sort_custom(func(a: String, b: String) -> bool:
		var value_a: int = int(world["tensions"][a]["current_value"])
		var value_b: int = int(world["tensions"][b]["current_value"])
		if value_a == value_b:
			return order.find(a) < order.find(b)
		return value_a > value_b
	)
	return ready


func value(tension_id: String) -> int:
	return int(world["tensions"][tension_id]["current_value"])


func threshold(tension_id: String) -> int:
	return int(data.tensions[tension_id]["threshold"])


func is_veiled(tension_id: String) -> bool:
	return str(world["tensions"][tension_id]["visibility"]) != "OPEN"


## What the public log is allowed to say about a Tension.
func public_status(tension_id: String) -> String:
	if is_veiled(tension_id):
		return "%s: velata" % _public_name(tension_id)
	return "%s: %d/%d" % [
		_public_name(tension_id), value(tension_id), threshold(tension_id)
	]


func _public_name(tension_id: String) -> String:
	return str(data.tensions[tension_id]["title"])
