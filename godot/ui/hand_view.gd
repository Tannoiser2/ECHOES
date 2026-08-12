extends HBoxContainer
## The seat's hand, as cards rather than a comma-separated list.
##
## An Asset is worth double in a Tension that finds its family relevant (§12.2 E),
## and that is the single fact a player needs when deciding what to commit. So a
## card carries its family colour and its strength, and when a Council is open it
## says out loud which of the two it is worth here.

var _cards: Array = []


func _ready() -> void:
	add_theme_constant_override("separation", 6)


## `tension_id` empty means no Council is open: cards are drawn plain, because
## relevance has no meaning outside a question.
func render(session: RefCounted, viewer_id: String, tension_id: String = "") -> void:
	for card in _cards:
		card.queue_free()
		remove_child(card)
	_cards.clear()
	if viewer_id == "":
		return

	var relevant: Array = []
	if tension_id != "" and session.world["tensions"].has(tension_id):
		relevant = session.data.tensions[tension_id]["relevant_asset_families"]

	for asset_id in session.service.hand(viewer_id):
		var asset: Variant = session.data.assets.get(str(asset_id))
		if asset == null:
			continue
		_cards.append(_card(asset, relevant.has(str(asset["family"]))))
		add_child(_cards[_cards.size() - 1])


func _card(asset: Dictionary, is_relevant: bool) -> Control:
	var family: String = str(asset["family"])
	var strength: int = int(asset["strength"])

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(118, 74)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1c1915")
	style.border_color = _family_colour(family)
	style.set_border_width_all(1)
	if is_relevant:
		style.set_border_width_all(2)
		style.bg_color = Color("#221d15")
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	panel.add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)

	var title := Label.new()
	title.text = str(asset["title"])
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color("#d9d2c5"))
	box.add_child(title)

	var footer := Label.new()
	# The doubled strength is the number that actually enters the sum, so it is
	# the number shown - not the printed one with a note attached.
	footer.text = ("%s · %d ×2 = %d" % [family.to_lower(), strength, strength * 2]) \
		if is_relevant else ("%s · %d" % [family.to_lower(), strength])
	footer.add_theme_font_size_override("font_size", 10)
	footer.add_theme_color_override(
		"font_color", _family_colour(family) if is_relevant else Color("#6b6355")
	)
	box.add_child(footer)
	return panel


func _family_colour(family: String) -> Color:
	match family:
		"AUTHORITY": return Color("#e8b563")
		"FORCE": return Color("#c8553d")
		"PEOPLE": return Color("#6fa88a")
		"KNOWLEDGE": return Color("#7fa6c9")
		"WEALTH": return Color("#c9a86a")
		"BONDS": return Color("#b06b8f")
	return Color("#8a8172")
