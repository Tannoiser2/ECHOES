extends Node
## Engine-to-presentation notification bus (§5).
##
## The core systems never reach into the UI. They emit here; scenes listen.
## In Milestone 0.0 nothing subscribes except the CLI harness and tests, which
## is the point: the rules run with no scene tree attached.

signal effect_applied(effect: Dictionary)
signal log_line(text: String)

signal chronicle_started(chronicle_id: String)
signal phase_changed(act: int, round: int, phase: String)
signal turn_started(entity_id: String, ao_remaining: int)
signal action_resolved(entity_id: String, template: String, effects: Array)

signal tension_changed(tension_id: String, value: int, visibility: String)
signal omen_fired(tension_id: String, message: String)

signal confluence_opened(context: Dictionary)
signal confluence_step(step: String, context: Dictionary)
signal confluence_resolved(result: Dictionary)

signal echo_created(echo: Dictionary)
signal truth_appended(truth: Dictionary)
signal chronicle_ended(destiny_results: Dictionary)


## Wire a running GameSession into this bus. Safe to call more than once.
func attach_session(session: Object) -> void:
	if session == null:
		return
	if session.has_signal("effect_applied") and not session.effect_applied.is_connected(_on_effect_applied):
		session.effect_applied.connect(_on_effect_applied)
	if session.has_signal("log_line") and not session.log_line.is_connected(_on_log_line):
		session.log_line.connect(_on_log_line)


func _on_effect_applied(effect: Dictionary) -> void:
	effect_applied.emit(effect)


func _on_log_line(text: String) -> void:
	log_line.emit(text)
