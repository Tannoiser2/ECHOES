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

const CardArt := preload("res://ui/card_art.gd")

const STANCE_COLOURS: Dictionary = {
	"SUPPORT": "#6fa88a", "OPPOSE": "#c8553d",
	"CONDITION": "#e8b563", "ABSTAIN": "#5f584c",
}

## What the four outcomes are, in words. The engine's names are for the log; a
## table wants to know whether the thing passed.
const OUTCOMES: Dictionary = {
	"FAILURE": "Respinta",
	"SUCCESS_WITH_COST": "Passa, ma si paga",
	"SUCCESS": "Passa",
	"DECISIVE_SUCCESS": "Passa senza discussione",
}

var _card: TextureRect
var _header: Label
var _question: Label
var _proposition: Label
var _stances: VBoxContainer
var _consequences: VBoxContainer
var _consequences_title: Label
var _outcome: Label
var _choices: HFlowContainer
var _prompt: Label


func _ready() -> void:
	add_theme_constant_override("separation", 10)
	_build()


func _build() -> void:
	# La carta della domanda, posata al centro del tavolo (D-101): quando un
	# Consiglio si apre, fisicamente si prende la carta mini dalla traccia dei
	# valori e la si mette in mezzo. Qui fa lo stesso.
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 18)
	add_child(top)

	_card = TextureRect.new()
	_card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_card.custom_minimum_size = Vector2(44.0, 68.0) * 2.1
	_card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top.add_child(_card)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(column)

	_header = _label(15, "#e8b563")
	column.add_child(_header)

	_question = _label(19, "#efe7d8")
	column.add_child(_question)

	_proposition = _label(14, "#c9bfae")
	column.add_child(_proposition)

	var rule := ColorRect.new()
	rule.color = Color("#3a332a")
	rule.custom_minimum_size = Vector2(0, 1)
	add_child(rule)

	_stances = VBoxContainer.new()
	_stances.add_theme_constant_override("separation", 3)
	add_child(_stances)

	_consequences_title = _label(12, "#8a8172")
	add_child(_consequences_title)

	_consequences = VBoxContainer.new()
	_consequences.add_theme_constant_override("separation", 6)
	add_child(_consequences)

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
	if not session.confluence.is_open():
		return
	_paint_council(session, session.confluence.current)


## The same board, drawn from a Council that has already closed.
##
## `resolve()` is atomic and clears `current` at the end of it, so the one
## moment the whole game turns on - the roll, the sum, and what it wrote on the
## map - would otherwise never be on screen for a single frame. The screen keeps
## the snapshot it was handed at RESOLVED and draws it until the player has
## looked at it (D-039).
func render_closed(session: RefCounted, council: Dictionary) -> void:
	if council.is_empty():
		return
	_paint_council(session, council)


func _paint_council(session: RefCounted, council: Dictionary) -> void:
	var template: Dictionary = session.data.confluence_templates[str(council["template_id"])]
	_card.texture = CardArt.texture_for("tension", str(council["tension_id"]), session.data)
	_header.text = "%s — %s propone" % [
		str(session.data.tensions[str(council["tension_id"])]["title"]),
		session.service.name_of(str(council["proponent"])),
	]
	_question.text = _fill(session, council, _question_text(template, str(council["question_id"])))
	_proposition.text = ""
	for proposition in template["propositions"]:
		if str(proposition["id"]) == str(council.get("proposition_id", "")):
			_proposition.text = _fill(session, council, str(proposition["text"]))

	_render_stances(session, council)
	_render_consequences(session, council, template)
	_render_outcome(council)


## The narrative slots ($the_region, $rival...) filled from the bindings this
## Council resolved at step A. Taken from the snapshot rather than from the
## controller, because a closed Council has no bindings left to ask for.
func _fill(session: RefCounted, council: Dictionary, text: String) -> String:
	return session.confluence.narrative.fill(text, council.get("text_bindings", {}))


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
		who.text = session.service.name_of(entity_id)
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


## What the proposition on the table would write into the world, and - once it
## has been voted - what it actually wrote.
##
## This is the number-free half of the Council and the one that decides whether
## a stance is worth taking: "sostieni" and "opponiti" mean nothing until you can
## read what you are supporting. The list is authored data (title, description,
## and whether it leaves a Scar); the board picks none of it, it only knows which
## ids to look up - before the vote, the proposition's own; after it, the ones
## the resolution recorded.
func _render_consequences(
	session: RefCounted, council: Dictionary, template: Dictionary
) -> void:
	for child in _consequences.get_children():
		child.queue_free()
		_consequences.remove_child(child)

	var result: Variant = council.get("result", null)
	var ids: Array = []
	if result != null:
		ids = (result as Dictionary).get("consequence_ids", [])
		_consequences_title.text = "COSA RESTA"
	else:
		for proposition in template["propositions"]:
			if str(proposition["id"]) == str(council.get("proposition_id", "")):
				ids = proposition["success_consequences"]
		_consequences_title.text = "SE PASSA"
	if ids.is_empty():
		_consequences_title.text = ""
		return

	for consequence_id in ids:
		var consequence: Variant = session.data.consequences.get(str(consequence_id))
		if consequence == null:
			continue
		var scars: bool = bool(consequence.get("creates_scar", false))
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 1)
		_consequences.add_child(box)

		var title := _label(13, "#c8553d" if scars else "#c9bfae")
		# A Scar is the one mark that never comes off, so it says so where the
		# decision is taken rather than in the log afterwards.
		title.text = ("%s — lascia una Cicatrice" % str(consequence["title"])) if scars \
			else str(consequence["title"])
		box.add_child(title)

		var body := _label(11, "#8a8172")
		body.text = _fill(session, council, str(consequence["description"]))
		box.add_child(body)


## The maths in the clear, once F has rolled. §12.2 G is the moment the game
## decides something, and a player should be able to check the arithmetic.
func _render_outcome(council: Dictionary) -> void:
	var die: int = int(council.get("die", 0))
	if die <= 0:
		_outcome.text = ""
		return
	# "->" and not an arrow glyph: the fallback font a Web export ships has no
	# arrow, and a missing glyph draws as a tofu box in the middle of the one line
	# a player reads to check the arithmetic. Same reason as the destiny ladder.
	var lines: Array = ["Fattore Mondo: 1d6 = %d -> %+d" % [die, int(council.get("world_factor", 0))]]
	var result: Variant = council.get("result", null)
	if result != null:
		var outcome: String = str((result as Dictionary)["outcome"])
		# The Condition front only appears when somebody took that stance, and it
		# says whether it qualified: qualified it is part of the sum (D-055),
		# unqualified it is two cards spent for nothing, and both need to be
		# readable off the same line.
		var condition: String = ""
		if int((result as Dictionary)["condition_total"]) > 0:
			condition = " · C %d%s" % [
				int((result as Dictionary)["condition_total"]),
				"" if bool((result as Dictionary)["condition_qualified"]) else " (non qualificata)",
			]
		lines.append("S %d%s · O %d · Mondo %+d -> M %+d — %s" % [
			int((result as Dictionary)["support_total"]),
			condition,
			int((result as Dictionary)["oppose_total"]),
			int((result as Dictionary)["world_factor"]),
			int((result as Dictionary)["margin"]),
			str(OUTCOMES.get(outcome, outcome)),
		])
	_outcome.text = "\n".join(PackedStringArray(lines))


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
