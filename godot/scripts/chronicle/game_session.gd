extends RefCounted
## One running Chronicle: WorldState plus every system that acts on it (§5).
##
## Owns no scene, no node and no autoload. GameState holds one of these for the
## UI; the CLI harness and the tests build their own. That is the whole reason
## Milestone 0.0 can play a full Chronicle with `godot --headless`.

const RngService := preload("res://scripts/core/rng_service.gd")
const EffectApplier := preload("res://scripts/core/effect_applier.gd")
const GameLog := preload("res://scripts/core/game_log.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")
const TensionSystem := preload("res://scripts/chronicle/tension_system.gd")
const ActionResolver := preload("res://scripts/actions/action_resolver.gd")
const ConfluenceController := preload("res://scripts/confluence/confluence_controller.gd")
const ConsequenceCompiler := preload("res://scripts/chronicle/consequence_compiler.gd")
const DestinyEvaluator := preload("res://scripts/chronicle/destiny_evaluator.gd")
const ChronicleController := preload("res://scripts/chronicle/chronicle_controller.gd")
const SaveSerializer := preload("res://scripts/core/save_serializer.gd")

signal effect_applied(effect: Dictionary)
signal log_line(text: String)

var data: RefCounted
var world: Dictionary = {}
var rng: RefCounted
var log: RefCounted
var applier: RefCounted
var service: RefCounted
var tensions: RefCounted
var actions: RefCounted
var confluence: RefCounted
var compiler: RefCounted
var destinies: RefCounted
var chronicle: RefCounted

var assignments: Dictionary = {}
var destiny_results: Dictionary = {}
var snapshots: Array = []
var last_error: String = ""

var _chronicle_def: Dictionary = {}
var _inherited: Dictionary = {}


func _init(p_data: RefCounted) -> void:
	data = p_data


## Build a fresh Chronicle. `seats` is the seating order, seat 0 goes first.
func setup(chronicle_id: String, seats: Array, seed_value: int) -> bool:
	last_error = ""
	if not data.chronicles.has(chronicle_id):
		last_error = "Chronicle sconosciuta '%s'" % chronicle_id
		return false
	_chronicle_def = data.chronicles[chronicle_id]
	for entity_id in seats:
		if not (_chronicle_def["entities"] as Array).has(str(entity_id)):
			last_error = "'%s' non fa parte della Chronicle '%s'" % [entity_id, chronicle_id]
			return false

	rng = RngService.new(seed_value)
	log = GameLog.new()
	log.line_added.connect(func(text: String) -> void: log_line.emit(text))

	world = WorldStateFactory.build(_chronicle_def, data, rng, seats)
	for index in range(seats.size()):
		assignments[str(index)] = str(seats[index])
	_wire_systems()
	return true


## Rebuild a session around a loaded WorldState.
func restore(save: Dictionary) -> bool:
	last_error = ""
	var chronicle_id: String = str(save["chronicle_id"])
	if not data.chronicles.has(chronicle_id):
		last_error = "Chronicle sconosciuta '%s'" % chronicle_id
		return false
	_chronicle_def = data.chronicles[chronicle_id]
	world = (save["world_state"] as Dictionary).duplicate(true)
	assignments = (save["assignments"] as Dictionary).duplicate(true)
	destiny_results = (save.get("destiny_results", {}) as Dictionary).duplicate(true)

	rng = RngService.new(int(world["rng_seed"]))
	rng.reseed(int(world["rng_seed"]), int(world["rng_state"]))
	log = GameLog.new()
	log.line_added.connect(func(text: String) -> void: log_line.emit(text))
	_wire_systems()
	return true


func _wire_systems() -> void:
	applier = EffectApplier.new(world)
	applier.effect_applied.connect(func(effect: Dictionary) -> void: effect_applied.emit(effect))
	service = WorldStateService.new(world, data)
	compiler = ConsequenceCompiler.new(data)
	tensions = TensionSystem.new(world, data, applier, log)
	actions = ActionResolver.new(world, data, applier, rng, log, tensions)
	confluence = ConfluenceController.new(world, data, applier, rng, log, tensions)
	destinies = DestinyEvaluator.new(world, data)
	chronicle = ChronicleController.new(self)


func factory_setup_effects() -> Array:
	return WorldStateFactory.setup_effects(_chronicle_def, data)


## Continue a campaign: what the previous Chronicle left behind is applied on
## top of a fresh setup. Call before run(); the truth and echo registers are
## copied straight across because they are the world's memory, not its state.
func inherit_from(previous: Dictionary) -> void:
	_inherited = previous
	if previous.is_empty():
		return
	world["year"] = int(previous.get("year", world["year"])) + 1
	world["echo_log"] = (previous.get("echo_log", []) as Array).duplicate(true)
	world["truth_log"] = (previous.get("truth_log", []) as Array).duplicate(true)


func inheritance_effects() -> Array:
	return WorldStateFactory.inheritance_effects(_inherited, _chronicle_def, data)


func chronicle_def() -> Dictionary:
	return _chronicle_def


## Keep world_state.rng_state in step with the RNG before anything reads it.
func sync_rng_state() -> void:
	world["rng_state"] = rng.get_draws()


func to_save(label: String = "") -> Dictionary:
	sync_rng_state()
	return SaveSerializer.to_save(self, label)


## §6.3 / §22: automatic snapshot before every Confluence, so Developer Mode can
## rewind past an irreversible Echo.
func take_snapshot(label: String) -> Dictionary:
	var snapshot: Dictionary = to_save(label)
	snapshots.append(snapshot)
	return snapshot


func restore_snapshot(index: int = -1) -> bool:
	if snapshots.is_empty():
		last_error = "nessuno snapshot disponibile"
		return false
	var snapshot: Dictionary = snapshots[index if index >= 0 else snapshots.size() - 1]
	return restore(snapshot)


## Developer Mode undo (§6.3). Refuses to step past an irreversible Effect.
func undo(count: int = 1) -> bool:
	if not applier.undo_last(count):
		last_error = applier.last_error
		return false
	return true


func run(decider: Object) -> Dictionary:
	return chronicle.run(decider)


## Break the session <-> log/applier signal cycles so the objects can be freed.
## Call it when a session is discarded; RefCounted alone cannot collect a cycle.
func dispose() -> void:
	if log != null:
		for connection in log.line_added.get_connections():
			log.line_added.disconnect(connection["callable"])
	if applier != null:
		for connection in applier.effect_applied.get_connections():
			applier.effect_applied.disconnect(connection["callable"])
	snapshots.clear()
	chronicle = null
	confluence = null
	actions = null
	tensions = null
	destinies = null
	service = null
	compiler = null
	applier = null
