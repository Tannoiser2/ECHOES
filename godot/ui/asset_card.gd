extends PanelContainer
## One card in the hand.
##
## Small on purpose - a hand of seven has to fit across the bottom of the screen
## - so the card itself carries only what a player scans for: the title, the
## family colour, and what it is worth in the question on the table. Everything
## else waits under the cursor.
##
## The tooltip is drawn rather than defaulted (`_make_custom_tooltip`) because
## the default one does not wrap: a card whose authored line runs to 130
## characters painted itself across the hand below it (D-042).

const AssetText := preload("res://scripts/core/asset_text.gd")

var asset: Dictionary = {}

var _title: Label
var _footer: Label


func _ready() -> void:
	custom_minimum_size = Vector2(118, 74)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Godot only asks for a tooltip when there is one to ask about.
	tooltip_text = " "


## `relevant` is the list of families the open question listens to; empty means
## no Council, and then a card shows its printed strength instead of its value.
func render(p_asset: Dictionary, relevant: Array, council_open: bool) -> void:
	asset = p_asset
	var family: String = str(asset["family"])
	var is_relevant: bool = relevant.has(family)

	var style := StyleBoxFlat.new()
	style.bg_color = Color("#221d15") if is_relevant else Color("#1c1915")
	style.border_color = _family_colour(family)
	style.set_border_width_all(2 if is_relevant else 1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)

	if _title == null:
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		add_child(box)
		_title = Label.new()
		_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_title.add_theme_font_size_override("font_size", 12)
		_title.add_theme_color_override("font_color", Color("#d9d2c5"))
		box.add_child(_title)
		_footer = Label.new()
		_footer.add_theme_font_size_override("font_size", 10)
		box.add_child(_footer)

	_title.text = str(asset["title"])
	# What this card will actually add to the sum, in this Council, right now -
	# asked of the resolver rather than recomputed here, so a card with a bonus
	# cannot show a number the resolution will not give it.
	_footer.text = "%s · %d" % [family.to_lower(), int(asset["strength"])]
	if council_open:
		_footer.text = "%s · vale %d" % [family.to_lower(), AssetText.value_on(asset, relevant)]
		var bonus: String = AssetText.modifier_note(asset)
		if bonus.ends_with("se ti opponi"):
			_footer.text += " (%s)" % bonus
	_footer.add_theme_color_override(
		"font_color", _family_colour(family) if is_relevant else Color("#6b6355")
	)


func _make_custom_tooltip(_for_text: String) -> Object:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#16130f")
	style.border_color = Color("#3a332a")
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = AssetText.tooltip(asset)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(300, 0)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("#c9bfae"))
	panel.add_child(label)
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
