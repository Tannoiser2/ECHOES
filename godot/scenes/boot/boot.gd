extends Node
## Boot / data validation scene (§19.3).
##
## Milestone 0.0 has no UI: this scene exists so the project opens cleanly, so
## `godot --headless` has something to run, and so the smoke tests have a scene
## to load. It reports the state of the data and stops.

@onready var _status: Label = $Margin/Rows/Status
@onready var _details: RichTextLabel = $Margin/Rows/Details


func _ready() -> void:
	var ok: bool = DataRegistry.is_valid
	var summary: String = _summary(ok)
	print(summary)
	if _status != null:
		_status.text = "ECHOES 0.0 - dati %s" % ("validi" if ok else "NON validi")
	if _details != null:
		_details.text = summary
	if DisplayServer.get_name() == "headless":
		# Nothing to show and nobody to show it to.
		get_tree().quit(0 if ok else 1)


func _summary(ok: bool) -> String:
	if not ok:
		return "Validazione dati fallita:\n%s" % DataRegistry.data.describe_errors()
	var data: RefCounted = DataRegistry.data
	return (
		"Dati validi (versione %s): %d Chronicle, %d Entita, %d Regioni, %d Asset, "
		+ "%d Tensioni, %d template Confluence, %d carte Echo, %d Conseguenze, %d Destiny."
	) % [
		data.data_version,
		data.chronicles.size(),
		data.entities.size(),
		data.regions.size(),
		data.assets.size(),
		data.tensions.size(),
		data.confluence_templates.size(),
		data.echo_cards.size(),
		data.consequences.size(),
		data.destinies.size(),
	]
