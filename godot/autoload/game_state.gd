extends Node
## Runtime source of truth (§5).
##
## The autoload holds the current GameSession; the session owns the WorldState,
## the RNG and every system. Nothing else caches game data. Milestone 0.1 scenes
## will read through this node; Milestone 0.0 drives sessions directly from the
## CLI harness and the tests, which is why all the logic lives in GameSession
## rather than here.

const GameSession := preload("res://scripts/chronicle/game_session.gd")

signal session_started(chronicle_id: String)
signal session_ended()

var session: RefCounted = null


func has_session() -> bool:
	return session != null


func start_chronicle(chronicle_id: String, seats: Array, seed_value: int) -> RefCounted:
	if not DataRegistry.is_valid:
		push_error("GameState: cannot start a Chronicle, data validation failed")
		return null
	session = GameSession.new(DataRegistry.data)
	if not session.setup(chronicle_id, seats, seed_value):
		push_error("GameState: %s" % session.last_error)
		session = null
		return null
	EventBus.attach_session(session)
	session_started.emit(chronicle_id)
	return session


func end_session() -> void:
	session = null
	session_ended.emit()


func world() -> Dictionary:
	return session.world if session != null else {}
