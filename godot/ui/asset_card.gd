extends PanelContainer
## One card in the hand — **la carta stampata, non un pannello che le somiglia**
## (D-101).
##
## Dalla 0.1.59 il corpo della carta e' la faccia dei fogli di stampa,
## rasterizzata da `card_art.gd`: titolo, testo di regola, glifo e colore di
## famiglia stanno dove stanno sulla carta fisica, perche' *sono* la carta
## fisica. Lo schermo aggiunge solo quello che il tavolo saprebbe a voce: il
## bordo di rilevanza quando un Consiglio e' aperto, e la riga «vale N» - che
## e' chiesta al resolver, non ricalcolata qui (D-040).
##
## The tooltip is drawn rather than defaulted (`_make_custom_tooltip`) because
## the default one does not wrap (D-042) - e resta: a mano stretta la carta
## rasterizzata si legge col cursore sopra.

const AssetText := preload("res://scripts/core/asset_text.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const CardArt := preload("res://ui/card_art.gd")

## Alta come la fila della mano: 63x88 in proporzione, ~79x110.
const CARD_H: float = 110.0

var asset: Dictionary = {}

var _picture: TextureRect
var _footer: Label


func _ready() -> void:
	custom_minimum_size = Vector2(CARD_H * 63.0 / 88.0 + 6.0, CARD_H + 22.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Godot only asks for a tooltip when there is one to ask about.
	tooltip_text = " "


## `relevant` is the list of families the open question listens to; empty means
## no Council, and then a card shows its printed strength instead of its value.
func render(p_asset: Dictionary, relevant: Array, council_open: bool, data: RefCounted) -> void:
	asset = p_asset
	var family: String = str(asset["family"])
	var is_relevant: bool = relevant.has(family)

	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0d0b09")
	style.border_color = _family_colour(family) if is_relevant else Color("#2a251d")
	style.set_border_width_all(2 if is_relevant else 1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 3
	style.content_margin_bottom = 2
	add_theme_stylebox_override("panel", style)

	if _picture == null:
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 1)
		add_child(box)
		_picture = TextureRect.new()
		_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_picture.custom_minimum_size = Vector2(CARD_H * 63.0 / 88.0, CARD_H)
		_picture.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(_picture)
		_footer = Label.new()
		_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_footer.add_theme_font_size_override("font_size", 10)
		box.add_child(_footer)

	_picture.texture = CardArt.texture_for("asset", str(asset["id"]), data)

	# What this card will actually add to the sum, in this Council, right now -
	# asked of the resolver rather than recomputed here, so a card with a bonus
	# cannot show a number the resolution will not give it.
	_footer.text = "forza %d" % int(asset["strength"])
	if council_open:
		_footer.text = "vale %d" % AssetText.value_on(asset, relevant)
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


## Lo stesso accento che finisce sulla carta stampata: la tavolozza sta in
## `card_face.gd` perche' la mano sullo schermo e il foglio in stampa devono
## dire la stessa cosa sulla stessa famiglia.
func _family_colour(family: String) -> Color:
	return Color(CardFace.family_colour(family))
