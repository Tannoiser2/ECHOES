extends Control
## The board: a map, the year's questions, the seat's hand, and the choices it
## is being asked to make.
##
## The seam is the point and it has not moved: the screen never decides anything
## and never reads a rule. `MapView`, `StatusPanel` and `HandView` each take a
## session and a viewer and draw what that seat is entitled to see; the choices
## come from SeatDecider, the same one the terminal drives. Swapping the drawing
## for real art in 0.2 touches none of it.
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
const MapView := preload("res://ui/map_view.gd")
const StatusPanel := preload("res://ui/status_panel.gd")
const HandView := preload("res://ui/hand_view.gd")
const ConfluenceBoard := preload("res://ui/confluence_board.gd")
const HelpPanel := preload("res://ui/help_panel.gd")
const EchoCardView := preload("res://ui/echo_card_view.gd")

## Who is at the table is a property of the Chronicle, not of this screen
## (D-050). It used to be a constant here, which meant the browser could only
## ever seat the first saga's four houses - the second saga shipped complete and
## unreachable, on a map the same screen was already drawing.
var _seats: Array = []

## Emitted by whichever button was pressed, carrying its index.
signal picked(index: int)

var _transcript: RichTextLabel
var _prompt: Label
var _buttons: VBoxContainer
var _scroll: ScrollContainer
var _session: RefCounted
var _busy: bool = false

var _map: Control
var _board: VBoxContainer
## The last Council to close, kept until the player has looked at it. See
## `_beat()`: resolve() is atomic, so without this the roll and its consequences
## would never be drawn.
var _closed_council: Dictionary = {}
var _hint: Label
## What is about to happen, in one line, above the choices. See `_context_line`.
var _context: Label
## The rules page, and the data it reads itself from. Open at the start, one
## button away for the rest of the Chronicle.
var _help: PanelContainer
var _help_button: Button
var _help_data: RefCounted
## The seed of the last Chronicle played, so the menu can offer it back.
var _last_seed: int = -1
## The Act-end Echo card waiting to be looked at, and what it did.
var _echo: PanelContainer
var _pending_echo: Dictionary = {}
## The map and the Council share the middle of the screen: one is visible at a
## time, because they answer different questions and a player looking at a
## Council is not choosing where to walk.
var _centre: Control
var _status: VBoxContainer
var _hand: HBoxContainer
## The seat the board is drawn for, and the Tension under discussion if any.
var _viewer: String = ""
var _focus_tension: String = ""


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
		margin.add_theme_constant_override(side, 16)
	add_child(margin)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 12)
	margin.add_child(rows)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 16)
	rows.add_child(columns)

	# The transcript is still the record, and still the same strings the log
	# holds - but it is no longer the game. It sits where a rulebook sits.
	_transcript = RichTextLabel.new()
	_transcript.bbcode_enabled = true
	_transcript.scroll_following = true
	_transcript.selection_enabled = true
	_transcript.custom_minimum_size = Vector2(300, 0)
	_transcript.add_theme_font_size_override("normal_font_size", 12)
	_transcript.add_theme_color_override("default_color", Color("#8a8172"))
	columns.add_child(_transcript)

	_centre = Control.new()
	_centre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_centre.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_centre.size_flags_stretch_ratio = 2.2
	columns.add_child(_centre)

	_map = MapView.new()
	_map.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Pressing a Region *is* choosing an action, so the map answers the question
	# on screen. Which Regions may be pressed is set by whoever asked it.
	_map.region_clicked.connect(_on_region_clicked)
	_centre.add_child(_map)

	_board = ConfluenceBoard.new()
	_board.set_anchors_preset(Control.PRESET_FULL_RECT)
	_board.visible = false
	_centre.add_child(_board)

	# Same piece of screen as the map and the Council: a player reading the rules
	# is not looking at the board, and the board is where there is room to read.
	_help = HelpPanel.new()
	_help.set_anchors_preset(Control.PRESET_FULL_RECT)
	_centre.add_child(_help)

	_echo = EchoCardView.new()
	_echo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_echo.visible = false
	_centre.add_child(_echo)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(280, 0)
	right.add_theme_constant_override("separation", 12)
	columns.add_child(right)

	_status = StatusPanel.new()
	right.add_child(_status)

	_context = Label.new()
	_context.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_context.add_theme_font_size_override("font_size", 12)
	_context.add_theme_color_override("font_color", Color("#8a8172"))
	right.add_child(_context)

	_prompt = Label.new()
	_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt.add_theme_font_size_override("font_size", 15)
	_prompt.add_theme_color_override("font_color", Color("#e8b563"))
	right.add_child(_prompt)

	_hint = Label.new()
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.add_theme_font_size_override("font_size", 12)
	_hint.add_theme_color_override("font_color", Color("#8a8172"))
	right.add_child(_hint)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(_scroll)

	_buttons = VBoxContainer.new()
	_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buttons.add_theme_constant_override("separation", 5)
	_scroll.add_child(_buttons)

	# Outside `_buttons` on purpose: the choices are cleared after every question
	# and this must not go with them. It is the one control that is always there.
	_help_button = Button.new()
	_help_button.text = "Come si gioca"
	_help_button.toggle_mode = true
	_help_button.button_pressed = true
	_help_button.toggled.connect(_on_help_toggled)
	right.add_child(_help_button)

	_hand = HandView.new()
	_hand.custom_minimum_size = Vector2(0, 80)
	rows.add_child(_hand)

	_help.render(_load_help_data())


## Redraw the board from the world. Called after every phase and before every
## question, because a player choosing an action must be looking at the state
## the action will apply to - not the state of the last screenshot.
func _refresh() -> void:
	if _session == null:
		return
	var council_open: bool = _session.confluence.is_open()
	var busy: bool = _help.visible or _echo.visible
	_board.visible = council_open and not busy
	_map.visible = not council_open and not busy
	if council_open:
		_board.render(_session, _viewer)
	_map.render(_session, _viewer)
	_status.render(_session, _viewer)
	_hand.render(_session, _viewer, _focus_tension)
	_context.text = _context_line()


## The one line above the choices: what is about to happen, and why the choice
## on screen matters. A player who cannot see that a question is one push from
## its Council is choosing in the dark.
##
## It reads exactly what the seat is entitled to read - `visible_tension_value`
## returns -1 for a veiled question nobody has scouted - so it can say "there is
## something you cannot see" without ever saying what.
func _context_line() -> String:
	if _session == null:
		return ""
	if _session.confluence.is_open():
		var current: Dictionary = _session.confluence.current
		if current.is_empty():
			return ""
		var families: Array = _session.data.tensions[str(current["tension_id"])]["relevant_asset_families"]
		return "Consiglio aperto: qui valgono forza piena le carte %s." % ", ".join(
			PackedStringArray(families)
		).to_lower()

	var closest: String = ""
	var margin: int = 99
	var veiled: int = 0
	for tension_id in _session.world["tensions"]:
		var id: String = str(tension_id)
		var value: int = _session.service.visible_tension_value(id, _viewer)
		if value < 0:
			veiled += 1
			continue
		var left: int = _session.tensions.threshold(id) - value
		if left < margin:
			margin = left
			closest = id
	if closest == "":
		return "Le domande dell'anno sono tutte velate: TRAMA per leggerne una."

	var title: String = str(_session.data.tensions[closest]["title"])
	var tail: String = "" if veiled == 0 else "  (e %d che non puoi ancora leggere)" % veiled
	if margin <= 0:
		return "%s ha raggiunto la soglia: il Consiglio si apre.%s" % [title, tail]
	if margin == 1:
		return "%s e a un passo dalla soglia: un'altra spinta e si apre il Consiglio.%s" % [title, tail]
	return "La domanda piu vicina a scoppiare e %s, a %d passi.%s" % [title, margin, tail]


func _on_help_toggled(pressed: bool) -> void:
	_help.visible = pressed
	if pressed:
		_help.render(_load_help_data())
	if _session != null:
		_refresh()
	else:
		_map.visible = false
		_board.visible = false


## The rules page opens before any Chronicle exists, so it loads its own copy of
## the data. Cheap, and it keeps `_play` exactly as it was.
func _load_help_data() -> RefCounted:
	if _help_data == null:
		var loaded: RefCounted = DataSet.new()
		if loaded.load_from("res://data"):
			_help_data = loaded
	return _help_data


## The beat after a Council closes.
##
## `ConfluenceController.resolve()` runs F-K in one pass and clears itself, so
## nothing in the loop ever comes back to draw the result: the roll, the sum and
## the Consequences would flash past between two frames that never happen. The
## screen holds the snapshot and stops here on its own - no decider is asked
## anything, because there is nothing to decide (D-039).
func _beat() -> void:
	await _echo_beat()
	if _closed_council.is_empty():
		return
	var council: Dictionary = _closed_council
	_closed_council = {}
	_help_button.button_pressed = false
	_board.visible = true
	_map.visible = false
	_echo.visible = false
	_board.render_closed(_session, council)
	_status.render(_session, _viewer)
	_hand.render(_session, _viewer, "")
	await _board.ask("Il Consiglio ha deciso.", ["Avanti"])


## The same pause, for the card that ends an Act. It comes first when both are
## waiting, because that is the order they happened in: the card is drawn, and
## then it may force the Council that follows it (D-044).
func _echo_beat() -> void:
	if _pending_echo.is_empty() or _viewer == "":
		_pending_echo = {}
		return
	var drawn: Dictionary = _pending_echo
	_pending_echo = {}
	_help_button.button_pressed = false
	_echo.visible = true
	_board.visible = false
	_map.visible = false
	_echo.render(drawn["card"], drawn["applied"], _session.data)
	_status.render(_session, _viewer)
	await _echo.wait()
	_echo.visible = false


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
func choose(prompt: String, labels: Array, subjects: Array = []) -> int:
	var entries: Array = labels.duplicate()
	entries.append("Lascia decidere alla policy")
	var about: Array = subjects.duplicate()
	while about.size() < entries.size():
		about.append({})
	var picked: int = await ask(prompt, entries, about)
	return -1 if picked >= labels.size() else picked


## Put the choices on screen and suspend until one is pressed.
##
## Three places a choice can live, and the choice itself says which:
##  - inside an open Council, beside the question it answers;
##  - on the map, when `subjects[i]` names a Region: the whole point of drawing
##    a board is that you point at it, so "metti una presenza in X" is not a line
##    of text, it is X, lit up and pressable;
##  - otherwise in the side column, which is where the rest of a turn lives.
##
## The screen sorts them; it does not judge them. Every entry it is handed is
## already legal, and an entry it puts on the map is the same entry it would
## have put in the column (D-039).
func ask(prompt: String, labels: Array, subjects: Array = []) -> int:
	await _beat()
	_refresh()
	if _session != null and _session.confluence.is_open():
		return await _board.ask(prompt, labels)

	var on_map: Dictionary = {}
	for i in range(labels.size()):
		var subject: Dictionary = subjects[i] if i < subjects.size() else {}
		var region_id: String = str(subject.get("region", ""))
		if region_id != "":
			on_map[region_id] = i
	# Some of the choices are on the map, so the map has to be the thing on
	# screen: a rules page covering the answer is worse than no rules page.
	if not on_map.is_empty() and _help.visible:
		_help_button.button_pressed = false
	_map.highlighted = on_map
	_map.queue_redraw()

	_prompt.text = prompt
	_hint.text = "" if on_map.is_empty() else \
		"Le Regioni cerchiate d'oro sono raggiungibili: cliccane una per metterci una presenza."
	_clear_buttons()
	for i in range(labels.size()):
		var subject: Dictionary = subjects[i] if i < subjects.size() else {}
		if str(subject.get("region", "")) != "":
			continue
		var button := Button.new()
		button.text = str(labels[i])
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var index: int = i
		button.pressed.connect(func() -> void: picked.emit(index))
		_buttons.add_child(button)

	var chosen: int = await picked
	# Cleared before returning, so a stray click on the map between two questions
	# cannot answer the next one.
	_map.highlighted = {}
	_map.queue_redraw()
	_clear_buttons()
	_prompt.text = ""
	_hint.text = ""
	return chosen


func _on_region_clicked(region_id: String) -> void:
	if _map.highlighted.has(region_id):
		picked.emit(int(_map.highlighted[region_id]))


func _clear_buttons() -> void:
	for child in _buttons.get_children():
		child.queue_free()
		_buttons.remove_child(child)


# --- starting a Chronicle ---------------------------------------------------

func _menu() -> void:
	say("[b]ECHOES[/b] — un boardgame narrativo-strategico a Chronicle.")
	say("")
	say("Ogni Chronicle e una storia completa nello stesso mondo: quattro Entita di")
	say("scala diversa preparano la propria posizione e poi si siedono a un Consiglio,")
	say("dove una domanda viene decisa e quello che si decide resta scritto.")
	say("")
	# Who those four are depends on the year, and there is more than one age to
	# choose from: the map is the same six places, and the people on it are not.
	say("La mappa e sempre la stessa. Le persone che ci stanno sopra no: fra un'epoca")
	say("e l'altra cambiano le case, le domande e quello che ognuno vuole.")
	say("")
	# The year is chosen before the seat, and it has to be: who is at the table
	# is what the Chronicle says it is, and the two sagas seat nobody in common.
	while true:
		var chronicle_id: String = await _ask_chronicle()
		_seats = _seats_of(chronicle_id)
		# Redrawn here and not after the seat is picked: the rules page names the
		# people at the table and the year's questions, and it is on screen while
		# the seat is being chosen. A step later it was still describing the age
		# the player had just declined.
		_help.render(_load_help_data(), chronicle_id)
		var labels: Array = []
		for entity_id in _seats:
			labels.append("Gioco %s" % _entity_name(str(entity_id)))
		labels.append("Guardo giocare le policy")
		var choice: int = await ask("Quale seggio prendi?", labels)
		var humans: Array = [] if choice >= _seats.size() else [str(_seats[choice])]
		await _play(humans, chronicle_id, await _ask_seed())


func _seats_of(chronicle_id: String) -> Array:
	var data: RefCounted = _load_help_data()
	if data == null or not data.chronicles.has(chronicle_id):
		return []
	return (data.chronicles[chronicle_id]["entities"] as Array).duplicate()


## Which year. Every Chronicle in the data is offered, oldest first, because
## there is more than one saga now and the browser was showing one of them.
##
## A Chronicle that writes its questions out is always the same four; one that
## declares a `tension_pool` draws them from the library, so it is a different
## year every time (D-028). The opening year of a saga is the written one - that
## is the one to start from, and the list says so by putting the year on it.
func _ask_chronicle() -> String:
	var data: RefCounted = _load_help_data()
	if data == null:
		return "CHR_01"
	var ids: Array = (data.chronicles as Dictionary).keys()
	ids.sort_custom(func(a: Variant, b: Variant) -> bool:
		var year_a: int = int(data.chronicles[str(a)]["start_year"])
		var year_b: int = int(data.chronicles[str(b)]["start_year"])
		if year_a == year_b:
			return str(a) < str(b)
		return year_a < year_b
	)
	if ids.size() < 2:
		return "CHR_01" if ids.is_empty() else str(ids[0])

	var labels: Array = []
	for chronicle_id in ids:
		var chronicle: Dictionary = data.chronicles[str(chronicle_id)]
		labels.append("%s (anno %d) — %s" % [
			str(chronicle["title"]), int(chronicle["start_year"]),
			"quattro domande pescate dalla biblioteca" if chronicle.has("tension_pool")
			else "le quattro domande scritte a mano",
		])
	var choice: int = await ask("Quale anno giochi?", labels)
	return str(ids[clampi(choice, 0, ids.size() - 1)])


## The seed is the world. It is printed at the top of every Chronicle precisely
## so a year worth talking about can be played again - which it could not be,
## until there was somewhere to type it back in.
func _ask_seed() -> int:
	var random: int = int(Time.get_unix_time_from_system()) % 100000
	var labels: Array = ["Un mondo a caso"]
	if _last_seed >= 0:
		labels.append("Rigioca il seme %d" % _last_seed)
	labels.append("Scrivo io il seme")
	var choice: int = await ask("Che mondo?", labels)
	if choice == 0:
		return random
	if _last_seed >= 0 and choice == 1:
		return _last_seed
	return await _ask_number("Il seme:", random)


## A number, typed. Enter answers as well as the button, because a field with a
## button beside it that only the button ends is a field that feels broken.
func _ask_number(prompt: String, fallback: int) -> int:
	_prompt.text = prompt
	_clear_buttons()
	var field := LineEdit.new()
	field.placeholder_text = str(fallback)
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buttons.add_child(field)
	var button := Button.new()
	button.text = "Vai"
	button.pressed.connect(func() -> void: picked.emit(0))
	field.text_submitted.connect(func(_t: String) -> void: picked.emit(0))
	_buttons.add_child(button)
	field.grab_focus()

	await picked
	var typed: String = field.text.strip_edges()
	_clear_buttons()
	_prompt.text = ""
	return int(typed) if typed.is_valid_int() else fallback


## Before the first Chronicle there is no session, so the name comes from the
## data set the menu already loads for the rules page. It used to come from a
## table written here, which listed the first saga's four houses and nothing
## else (D-050).
func _entity_name(entity_id: String) -> String:
	if _session != null:
		return str(_session.data.entities[entity_id]["name"])
	var data: RefCounted = _load_help_data()
	if data == null or not data.entities.has(entity_id):
		return entity_id
	return str(data.entities[entity_id]["name"])


func _play(humans: Array, chronicle_id: String, seed_value: int) -> void:
	if _busy:
		return
	_busy = true
	_transcript.clear()

	# The Chronicle starts: the rules page gets out of the way and leaves the
	# middle to the map. One press brings it back.
	_help_button.button_pressed = false

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			say("[color=#c8553d]%s[/color]" % str(error))
		_busy = false
		return

	# The seed *is* the world: same seed, same year, down to the die. Kept so the
	# menu can offer it back after the Chronicle ends.
	_last_seed = seed_value
	_session = GameSession.new(data)
	_session.setup(chronicle_id, _seats, seed_value)

	var shown: Dictionary = {"lines": 0}
	_session.chronicle.phase_changed.connect(
		func(_a: int, _r: int, _p: String) -> void:
			_flush(shown)
			_refresh()
	)
	# Held, not shown: the card is drawn deep inside the Act and the screen has
	# nowhere to suspend there. It is looked at at the next question, like the
	# closed Council.
	_session.chronicle.act_echo_drawn.connect(
		func(card: Dictionary, applied: Array) -> void:
			_pending_echo = {"card": card.duplicate(true), "applied": applied.duplicate(true)}
	)

	say("[b]%s[/b] — anno %d, seme %d" % [
		str(data.chronicles[chronicle_id]["title"]), int(_session.world["year"]), seed_value,
	])
	say("")

	_viewer = "" if humans.is_empty() else str(humans[0])
	_focus_tension = ""
	# Which question the table is on: it decides what the hand is worth, and the
	# board has no other way to know - the decider never tells it anything.
	_session.confluence.step_changed.connect(
		func(step: String, context: Dictionary) -> void:
			_focus_tension = "" if step == "RESOLVED" else str(context["tension_id"])
			if step == "RESOLVED":
				# Copied, not referenced: resolve() empties the controller's
				# dictionary on the next line.
				_closed_council = context.duplicate(true)
	)
	_refresh()

	var seat: RefCounted = SeatDecider.new(humans, _session.log)
	seat.io = self
	var report: Dictionary = await _session.run(seat)
	_focus_tension = ""
	await _beat()
	_flush(shown)
	_map.highlighted = {}
	_refresh()
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
	for entity_id in _seats:
		var entry: Dictionary = report["destiny_results"][str(entity_id)]
		say("  %s — [b]%s[/b] %s" % [
			_session.service.name_of(str(entity_id)) if _session != null else str(data.entities[str(entity_id)]["name"]),
			str(entry["level"]), str(entry.get("label", "")),
		])
