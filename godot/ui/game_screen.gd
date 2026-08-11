extends Control
## The whole interface, for now: a transcript and a column of buttons.
##
## Milestone 0.1 replaces this with a map and a Confluence Board. What it will
## not replace is the seam: the screen never decides anything and never reads
## the rules. It shows what the log says and asks what the decider asks, so the
## game in the browser is the same game the terminal plays - the smoke tests
## prove it by running the same Chronicle through both.
##
## Built in code rather than in a .tscn so the layout lives next to the reasons
## for it, and so a scene file cannot drift from the script that drives it.
##
## This node *is* SeatDecider's `io`: it implements `say` and `choose`, and the
## decider knows nothing else about it. That is why the browser and the terminal
## cannot disagree about which actions are legal - they run the same decider,
## and only the two ends of the pipe differ (D-038).

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]

## Emitted by whichever button was pressed, carrying its index.
signal picked(index: int)

var _transcript: RichTextLabel
var _prompt: Label
var _buttons: VBoxContainer
var _scroll: ScrollContainer
var _session: RefCounted
var _busy: bool = false


func _ready() -> void:
	_build()
	_menu()


# --- layout -----------------------------------------------------------------

func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#12100e")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 24)
	add_child(margin)

	var columns := HSplitContainer.new()
	columns.split_offset = 640
	margin.add_child(columns)

	_transcript = RichTextLabel.new()
	_transcript.bbcode_enabled = true
	_transcript.scroll_following = true
	_transcript.selection_enabled = true
	_transcript.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_transcript.add_theme_font_size_override("normal_font_size", 15)
	_transcript.add_theme_color_override("default_color", Color("#d9d2c5"))
	columns.add_child(_transcript)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	columns.add_child(right)

	_prompt = Label.new()
	_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt.add_theme_font_size_override("font_size", 17)
	_prompt.add_theme_color_override("font_color", Color("#e8b563"))
	right.add_child(_prompt)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(_scroll)

	_buttons = VBoxContainer.new()
	_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buttons.add_theme_constant_override("separation", 6)
	_scroll.add_child(_buttons)


# --- the screen's whole API -------------------------------------------------

## One line into the transcript. Lines the engine writes arrive here too, so
## what a player reads and what the log records are the same string.
func say(text: String) -> void:
	if text.begins_with("=="):
		_transcript.append_text("\n[color=#e8b563][b]%s[/b][/color]\n" % text.strip_edges())
	else:
		_transcript.append_text("%s\n" % text)


## SeatDecider's `io.choose`. Adds the "you decide" button the terminal spells
## as a bare Enter, and reports it as -1, which is the contract for handing this
## single choice back to the policy.
func choose(prompt: String, labels: Array) -> int:
	var entries: Array = labels.duplicate()
	entries.append("Lascia decidere alla policy")
	var picked: int = await ask(prompt, entries)
	return -1 if picked >= labels.size() else picked


## Put the choices on screen and suspend until one is pressed.
func ask(prompt: String, labels: Array) -> int:
	_prompt.text = prompt
	_clear_buttons()
	for i in range(labels.size()):
		var button := Button.new()
		button.text = str(labels[i])
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var index: int = i
		button.pressed.connect(func() -> void: picked.emit(index))
		_buttons.add_child(button)
	var chosen: int = await picked
	_clear_buttons()
	_prompt.text = ""
	return chosen


func _clear_buttons() -> void:
	for child in _buttons.get_children():
		child.queue_free()
		_buttons.remove_child(child)


# --- starting a Chronicle ---------------------------------------------------

func _menu() -> void:
	say("[b]ECHOES[/b] — un boardgame narrativo-strategico a Chronicle.")
	say("")
	say("Ogni Chronicle e una storia completa nello stesso mondo. Quattro Entita di")
	say("scala diversa — un re, un popolo, una studiosa, qualcosa di molto antico —")
	say("preparano la propria posizione e poi si siedono a un Consiglio, dove una")
	say("domanda viene decisa e quello che si decide resta scritto.")
	say("")
	while true:
		var labels: Array = []
		for entity_id in SEATS:
			labels.append("Gioco %s" % _entity_name(str(entity_id)))
		labels.append("Guardo giocare le policy")
		var choice: int = await ask("Quale seggio prendi?", labels)
		var humans: Array = [] if choice >= SEATS.size() else [str(SEATS[choice])]
		await _play(humans)


func _entity_name(entity_id: String) -> String:
	if _session != null:
		return str(_session.data.entities[entity_id]["name"])
	# Before the first Chronicle there is no session; the names are static.
	return {
		"ENT_ALDRIC": "Re Aldric", "ENT_NAHR": "il Popolo Nahr",
		"ENT_LYRA": "Lyra", "ENT_VAERAX": "Vaerax",
	}.get(entity_id, entity_id)


func _play(humans: Array) -> void:
	if _busy:
		return
	_busy = true
	_transcript.clear()

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			say("[color=#c8553d]%s[/color]" % str(error))
		_busy = false
		return

	# A different world every time the page is opened, but still a *seeded* one:
	# the seed is shown so a Chronicle worth talking about can be played again.
	var seed_value: int = int(Time.get_unix_time_from_system()) % 100000
	_session = GameSession.new(data)
	_session.setup("CHR_01", SEATS, seed_value)

	var shown: Dictionary = {"lines": 0}
	_session.chronicle.phase_changed.connect(
		func(_a: int, _r: int, _p: String) -> void: _flush(shown)
	)

	say("[b]%s[/b] — anno %d, seme %d" % [
		str(data.chronicles["CHR_01"]["title"]), int(_session.world["year"]), seed_value,
	])
	say("")

	var seat: RefCounted = SeatDecider.new(humans, _session.log)
	seat.io = self
	var report: Dictionary = await _session.run(seat)
	_flush(shown)
	_ending(data, report)
	_session.dispose()
	_session = null
	_busy = false


func _flush(shown: Dictionary) -> void:
	var lines: Array = _session.log.lines
	while int(shown["lines"]) < lines.size():
		say(str(lines[int(shown["lines"])]))
		shown["lines"] = int(shown["lines"]) + 1


func _ending(data: RefCounted, report: Dictionary) -> void:
	say("")
	say("== COM'E FINITA ==")
	for entity_id in SEATS:
		var entry: Dictionary = report["destiny_results"][str(entity_id)]
		say("  %s — [b]%s[/b] %s" % [
			str(data.entities[str(entity_id)]["name"]),
			str(entry["level"]), str(entry.get("label", "")),
		])
