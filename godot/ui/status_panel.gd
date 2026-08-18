extends VBoxContainer
## The year's questions, and where the seat stands on its own ladder.
##
## Same contract as the map: `render(session, viewer_id)` and nothing else. A
## Tension shows a number only to a seat entitled to read it, so a veiled
## question the viewer has not scouted is drawn as a bar with no fill and the
## word "velata" - present, unreadable, and clearly *there*, which is the whole
## point of a veiled Tension.

## The five levels a relation can sit at, warmest last, with the colour each one
## is drawn in. FORGE moves a relation one step along this list.
const RELATIONS: Dictionary = {
	"ENEMY": "#c8553d", "HOSTILE": "#b06b8f", "NEUTRAL": "#8a8172",
	"ALLY": "#6fa88a", "BOUND": "#e8b563",
}

const CardArt := preload("res://ui/card_art.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

var _rows: Dictionary = {}
var _destiny: VBoxContainer
var _casata_card: TextureRect
var _destiny_card: TextureRect
var _relations: VBoxContainer
var _claims: VBoxContainer
var _claims_header: Label
var _signs: VBoxContainer
var _signs_header: Label
var _title: Label


func _ready() -> void:
	add_theme_constant_override("separation", 4)


func render(session: RefCounted, viewer_id: String) -> void:
	if _title == null:
		_build()
	for tension_id in _sorted(session.world["tensions"].keys()):
		var id: String = str(tension_id)
		if not _rows.has(id):
			_rows[id] = _add_row(str(session.data.tensions[id]["title"]))
		_update_row(_rows[id], session, id, viewer_id)
	_update_relations(session, viewer_id)
	_update_claims(session, viewer_id)
	_update_signs(session, viewer_id)
	_update_destiny(session, viewer_id)


func _build() -> void:
	_title = Label.new()
	_title.text = "LE DOMANDE DELL'ANNO"
	_title.add_theme_font_size_override("font_size", 12)
	_title.add_theme_color_override("font_color", Color("#8a8172"))
	add_child(_title)


func _add_row(title: String) -> Dictionary:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	add_child(box)

	var header := HBoxContainer.new()
	box.add_child(header)
	var name := Label.new()
	name.text = title
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.add_theme_font_size_override("font_size", 13)
	name.add_theme_color_override("font_color", Color("#d9d2c5"))
	header.add_child(name)
	var value := Label.new()
	value.add_theme_font_size_override("font_size", 13)
	header.add_child(value)

	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 8)
	box.add_child(bar)
	return {"value": value, "bar": bar}


func _update_row(row: Dictionary, session: RefCounted, tension_id: String, viewer_id: String) -> void:
	var threshold: int = session.tensions.threshold(tension_id)
	var visible_value: int = session.service.visible_tension_value(tension_id, viewer_id)
	var bar: ProgressBar = row["bar"]
	var value: Label = row["value"]
	bar.max_value = float(maxi(threshold, 1))

	if visible_value < 0:
		bar.value = 0.0
		value.text = "velata"
		value.add_theme_color_override("font_color", Color("#5f584c"))
		return
	bar.value = float(visible_value)
	value.text = "%d/%d" % [visible_value, threshold]
	# The colour is the warning: a question one step from its threshold is the
	# one worth spending an action on, and it should be findable at a glance.
	var margin: int = threshold - visible_value
	var tint: Color = Color("#6fa88a")
	if margin <= 0:
		tint = Color("#c8553d")
	elif margin <= 1:
		tint = Color("#e8b563")
	value.add_theme_color_override("font_color", tint)
	var fill := StyleBoxFlat.new()
	fill.bg_color = tint
	bar.add_theme_stylebox_override("fill", fill)


## Where you stand with the other three. Public information - FORGE announces
## itself and the terminal has printed the level inside its own action labels
## since 0.0 - but until 0.1.6 the only way to read it in the browser was to
## look at a button offering to break it. Destinies count these levels, so a
## player who cannot see them is being scored on something invisible.
func _update_relations(session: RefCounted, viewer_id: String) -> void:
	if _relations == null:
		add_child(_spacer())
		var header := Label.new()
		header.text = "I RAPPORTI"
		header.add_theme_font_size_override("font_size", 12)
		header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(header)
		_relations = VBoxContainer.new()
		_relations.add_theme_constant_override("separation", 1)
		add_child(_relations)

	for child in _relations.get_children():
		child.queue_free()
		_relations.remove_child(child)
	if viewer_id == "":
		return

	for entity_id in session.world["turn_order"]:
		var other: String = str(entity_id)
		if other == viewer_id:
			continue
		var level: String = session.service.relation_level(viewer_id, other)
		var row := HBoxContainer.new()
		_relations.add_child(row)

		var name := Label.new()
		name.text = session.service.name_of(other)
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name.add_theme_font_size_override("font_size", 12)
		name.add_theme_color_override("font_color", Color("#c9bfae"))
		row.add_child(name)

		var value := Label.new()
		value.text = level.to_lower()
		value.add_theme_font_size_override("font_size", 12)
		value.add_theme_color_override("font_color", Color(str(RELATIONS.get(level, "#8a8172"))))
		row.add_child(value)


## I Diritti sul tavolo (l'inventario dell'app, ISSUES 22): un Claim creato e'
## un fatto pubblico - l'azione si annuncia - ma fin qui viveva solo nel
## verbale, e un giocatore non poteva guardare lo schermo e sapere chi tiene
## un diritto pronto a forzare un Consiglio. Il proprio in ambra, gli altrui
## nel colore neutro, il dominio con la sua parola italiana.
func _update_claims(session: RefCounted, viewer_id: String) -> void:
	if _claims == null:
		add_child(_spacer())
		_claims_header = Label.new()
		_claims_header.text = "I DIRITTI"
		_claims_header.add_theme_font_size_override("font_size", 12)
		_claims_header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(_claims_header)
		_claims = VBoxContainer.new()
		_claims.add_theme_constant_override("separation", 1)
		add_child(_claims)

	for child in _claims.get_children():
		child.queue_free()
		_claims.remove_child(child)
	var shown: int = 0
	for claim in session.world.get("claims", []):
		var holder: String = str(claim.get("entity_id", ""))
		var line := Label.new()
		line.text = "%s — %s (atto %d)" % [
			session.service.name_of(holder),
			SignLabels.domain(str(claim.get("domain", ""))),
			int(claim.get("act", 0)),
		]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		line.add_theme_color_override(
			"font_color", Color("#e8b563") if holder == viewer_id else Color("#c9bfae")
		)
		_claims.add_child(line)
		shown += 1
	# Senza diritti la sezione sparisce, come i segni: niente intestazioni vuote.
	_claims_header.visible = shown > 0
	_claims.visible = shown > 0


## I segni che questa casa porta con sé - la fama, le scoperte, la scorta
## giurata, la porta sbarrata (ISSUES 22, D-107). Da quando i segni hanno un
## dente (D-105), un giocatore che non vede i propri viene giudicato da regole
## invisibili. Le parole vengono dal dizionario condiviso: le stesse dei
## segnalini di cartone.
func _update_signs(session: RefCounted, viewer_id: String) -> void:
	if _signs == null:
		add_child(_spacer())
		_signs_header = Label.new()
		_signs_header.text = "I SEGNI DELLA CASA"
		_signs_header.add_theme_font_size_override("font_size", 12)
		_signs_header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(_signs_header)
		_signs = VBoxContainer.new()
		_signs.add_theme_constant_override("separation", 1)
		add_child(_signs)

	for child in _signs.get_children():
		child.queue_free()
		_signs.remove_child(child)
	var holder: Variant = session.world["entities"].get(viewer_id)
	if holder == null:
		_signs_header.visible = false
		_signs.visible = false
		return
	var tags: Array = (holder["tags"] as Array).duplicate()
	tags.sort()
	var shown: int = 0
	for tag in tags:
		var line := Label.new()
		line.text = SignLabels.label(str(tag), session.data)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		line.add_theme_color_override(
			"font_color",
			Color("#c8553d") if str(tag).begins_with("evicted:") else Color("#c9bfae")
		)
		_signs.add_child(line)
		shown += 1
	# Senza segni la sezione sparisce: un'intestazione sopra il nulla è rumore.
	_signs_header.visible = shown > 0
	_signs.visible = shown > 0


func _spacer() -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	return spacer


## The ladder, with the rungs that hold already ticked. A player who cannot read
## their own goal cannot steer towards it.
func _update_destiny(session: RefCounted, viewer_id: String) -> void:
	if _destiny == null:
		add_child(_spacer())
		var header := Label.new()
		header.text = "IL TUO DESTINO"
		header.add_theme_font_size_override("font_size", 12)
		header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(header)
		# I tarocchi dietro il paravento (D-101): la Casata e il Destino del
		# seggio sono le carte 70x120 dei fogli di stampa - il Destino lo vede
		# solo chi lo giura, come al tavolo, perche' questo pannello e' gia'
		# disegnato per il solo viewer.
		var tarots := HBoxContainer.new()
		tarots.add_theme_constant_override("separation", 6)
		add_child(tarots)
		_casata_card = _tarot()
		tarots.add_child(_casata_card)
		_destiny_card = _tarot()
		tarots.add_child(_destiny_card)
		_destiny = VBoxContainer.new()
		_destiny.add_theme_constant_override("separation", 2)
		add_child(_destiny)

	for child in _destiny.get_children():
		child.queue_free()
		_destiny.remove_child(child)
	if viewer_id == "":
		return
	var entity: Variant = session.data.entities.get(viewer_id)
	if entity == null:
		return
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(viewer_id))
	if destiny == null:
		return
	# Il tarocco segue la vita (D-111): quando il seggio si trasforma, sul
	# tavolo si posa la carta della vita nuova - qui come al tavolo fisico.
	var casata_id: String = viewer_id
	var seat_state: Dictionary = session.world["entities"].get(viewer_id, {})
	var life_index: int = int(seat_state.get("incarnation", 0))
	var lives: Array = entity.get("incarnations", [])
	if life_index > 0 and life_index < lives.size():
		casata_id = str(lives[life_index]["id"])
	_casata_card.texture = CardArt.texture_for("entity", casata_id, session.data)
	_destiny_card.texture = CardArt.texture_for(
		"destiny", session.service.destiny_of(viewer_id), session.data
	)
	for level in ["minimum", "victory", "triumph"]:
		var holds: bool = session.destinies.conditions.all_hold(destiny[level]["conditions"], {"self": viewer_id})
		var line := Label.new()
		# ASCII on purpose: the fallback font a Web export ships has no check mark,
		# and a missing glyph renders as a tofu box - which reads as a bug in the
		# game rather than a gap in the font.
		line.text = "%s %s" % ["[x]" if holds else "[ ]", str(destiny[level]["label"])]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		line.add_theme_color_override(
			"font_color", Color("#6fa88a") if holds else Color("#5f584c")
		)
		_destiny.add_child(line)


func _tarot() -> TextureRect:
	var picture := TextureRect.new()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = Vector2(70.0, 120.0) * 1.85
	picture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return picture


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out
