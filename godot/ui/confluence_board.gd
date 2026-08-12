extends VBoxContainer
## The Council, while it happens.
##
## The map answers "where are we"; this answers "what is being decided, by whom,
## and at what cost". It takes over the middle of the screen when a Council opens
## and gives it back when the Council closes.
##
## Same seam as everything else in `ui/`: it reads `session.confluence.current` -
## the same dictionary the log renders and the 0.0 terminal printed - and it
## decides nothing. Choices arrive as `ask(prompt, labels)`, already formatted by
## SeatDecider, and are drawn as cards. The board does not know whether it is
## showing propositions, stances or Assets, and it must not: that is what keeps
## the browser and the terminal offering the same options.

## Emitted by whichever card was pressed.
signal picked(index: int)

const STANCE_COLOURS: Dictionary = {
	"SUPPORT": "#6fa88a", "OPPOSE": "#c8553d",
	"CONDITION": "#e8b563", "ABSTAIN": "#5f584c",
}

var _header: Label
var _question: Label
var _proposition: Label
var _stances: VBoxContainer
var _outcome: Label
var _choices: HFlowContainer
var _prompt: Label


func _ready() -> void:
	add_theme_constant_override("separation", 10)
	_build()


func _build() -> void:
	_header = _label(15, "#e8b563")
	add_child(_header)

	_question = _label(19, "#efe7d8")
	add_child(_question)

	_proposition = _label(14, "#c9bfae")
	add_child(_proposition)

	var rule := ColorRect.new()
	rule.color = Color("#3a332a")
	rule.custom_minimum_size = Vector2(0, 1)
	add_child(rule)

	_stances = VBoxContainer.new()
	_stances.add_theme_constant_override("separation", 3)
	add_child(_stances)

	_outcome = _label(15, "#efe7d8")
	add_child(_outcome)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(spacer)

	_prompt = _label(14, "#e8b563")
	add_child(_prompt)

	_choices = HFlowContainer.new()
	_choices.add_theme_constant_override("h_separation", 8)
	_choices.add_theme_constant_override("v_separation", 8)
	add_child(_choices)


func _label(font_size: int, colour: String) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(colour))
	return label


# --- reading the Council ----------------------------------------------------

func render(session: RefCounted, _viewer_id: String) -> void:
	var council: RefCounted = session.confluence
	if not council.is_open():
		return
	var current: Dictionary = council.current
	var template: Dictionary = session.data.confluence_templates[str(current["template_id"])]

	_header.text = "%s — %s propone" % [
		str(session.data.tensions[str(current["tension_id"])]["title"]),
		str(session.data.entities[str(current["proponent"])]["name"]),
	]
	_question.text = council.say(_question_text(template, str(current["question_id"])))
	_proposition.text = ""
	for proposition in template["propositions"]:
		if str(proposition["id"]) == str(current.get("proposition_id", "")):
			_proposition.text = council.say(str(proposition["text"]))

	_render_stances(session, current)
	_render_outcome(current)


func _question_text(template: Dictionary, question_id: String) -> String:
	for question in template["questions"]:
		if str(question["id"]) == question_id:
			return str(question["text"])
	return ""


## Stances as they are declared, in the order the table declared them, with the
## commits beside them once E has revealed everything at once. Before the
## reveal the column is deliberately empty: what someone put down is not public
## until it is public.
func _render_stances(session: RefCounted, current: Dictionary) -> void:
	for child in _stances.get_children():
		child.queue_free()
		_stances.remove_child(child)

	var seats: Array = [str(current["proponent"])]
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(current["proponent"]):
			seats.append(str(entity_id))

	var commits: Dictionary = current.get("commits", {})
	for entity_id in seats:
		var is_proponent: bool = entity_id == str(current["proponent"])
		var record: Variant = (current.get("stances", {}) as Dictionary).get(entity_id)
		var stance: String = "PROPONENT" if is_proponent else (
			"" if record == null else str(record["stance"])
		)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_stances.add_child(row)

		var who := Label.new()
		who.text = str(session.data.entities[entity_id]["name"])
		who.custom_minimum_size = Vector2(120, 0)
		who.add_theme_font_size_override("font_size", 13)
		who.add_theme_color_override("font_color", Color("#c9bfae"))
		row.add_child(who)

		var said := Label.new()
		said.text = "…" if stance == "" else stance.to_lower()
		said.custom_minimum_size = Vector2(90, 0)
		said.add_theme_font_size_override("font_size", 13)
		said.add_theme_color_override(
			"font_color",
			Color("#e8b563") if is_proponent
			else Color(str(STANCE_COLOURS.get(stance, "#5f584c")))
		)
		row.add_child(said)

		var spent: Array = commits.get(entity_id, [])
		if not spent.is_empty():
			var cards := Label.new()
			var titles: Array = []
			for asset_id in spent:
				var asset: Variant = session.data.assets.get(str(asset_id))
				titles.append(str(asset_id) if asset == null else str(asset["title"]))
			cards.text = ", ".join(PackedStringArray(titles))
			cards.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cards.add_theme_font_size_override("font_size", 12)
			cards.add_theme_color_override("font_color", Color("#8a8172"))
			row.add_child(cards)


## The maths in the clear, once F has rolled. §12.2 G is the moment the game
## decides something, and a player should be able to check the arithmetic.
func _render_outcome(current: Dictionary) -> void:
	var die: int = int(current.get("die", 0))
	if die <= 0:
		_outcome.text = ""
		return
	var factor: int = int(current.get("world_factor", 0))
	_outcome.text = "Fattore Mondo: 1d6 = %d → %+d" % [die, factor]


# --- asking ------------------------------------------------------------------

## Draw the choices as cards and suspend until one is pressed. The board neither
## knows nor cares what they are.
func ask(prompt: String, labels: Array) -> int:
	_prompt.text = prompt
	for child in _choices.get_children():
		child.queue_free()
		_choices.remove_child(child)

	for i in range(labels.size()):
		var index: int = i
		var card := Button.new()
		card.text = str(labels[i])
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		# Wide enough for a proposition, narrow enough that three fit in a row.
		card.custom_minimum_size = Vector2(260, 62)
		card.add_theme_font_size_override("font_size", 13)
		card.pressed.connect(func() -> void: picked.emit(index))
		_choices.add_child(card)

	var chosen: int = await picked
	_prompt.text = ""
	for child in _choices.get_children():
		child.queue_free()
		_choices.remove_child(child)
	return chosen
