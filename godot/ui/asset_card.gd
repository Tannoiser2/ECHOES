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
# **Quanto e' grande una carta in mano** (D-242, corretto in D-246).
#
# Centodieci pixel erano una figurina. D-242 li ha portati a 150 e ci ha messo
# sotto il nome e il verbo — e la carta e' arrivata **tagliata**: alta 196 in un
# contenitore alto 200, con un titolo che va a capo. Quello che si taglia e'
# **il fondo**, cioe' esattamente il testo appena aggiunto: *«sono tagliate e non
# c'e' scritto nulla sopra»*. Le tre lamentele erano una sola.
#
# Adesso le misure si dichiarano tutte e si sommano: l'immagine ha un'altezza
# fissa, ogni riga di testo ha la propria altezza minima e un tetto di righe, e
# l'altezza della carta e' la somma. Niente che possa essere schiacciato via.
const CARD_W: float = 168.0
const PICTURE_H: float = 150.0
const NAME_H: float = 34.0
const VERB_H: float = 28.0
const FOOTER_H: float = 16.0
const CARD_H: float = PICTURE_H

var asset: Dictionary = {}

## Il DataSet, tenuto perche' il tooltip si costruisce **dopo** `render()` —
## quando il mouse si ferma — e li' i segni vanno tradotti in parole.
var _data: RefCounted = null

## **Si prende in mano** (D-230). Vuota, la carta si guarda e basta; quando lo
## schermo sta chiedendo un'azione ci mette dentro le scelte che quella carta
## porta — `{"region": "REG_X", "index": 3}` — e da quel momento la si puo'
## trascinare dove quelle scelte vivono. E' il committente che l'ha chiesto per
## intero: *«si seleziona una carta, si decide come usarla e si deve poter
## generare il suo effetto»*.
##
## Lo schermo la riempie e la svuota; la carta non sa cosa siano quelle voci e
## non deve saperlo. Come per le Regioni cerchiate d'oro, **una carta e'
## trascinabile esattamente quando la mossa e' legale** (D-039): la lista arriva
## gia' passata dalle regole.
var offers: Array = []:
	set(value):
		offers = value
		_restyle()

## La carta e' stata **scelta**, non trascinata (D-238).
##
## Il committente l'ha scritto in due movimenti: *«si seleziona una carta, si
## decide come usarla»*. Il trascinamento fa i due insieme; il clic fa il primo
## e lascia il secondo alla colonna, che si restringe a quello che **questa**
## carta sa fare. Serve anche come porta di servizio: un trascinamento che non
## riesce — un dito su un telefono, un mouse che scappa — non deve lasciare una
## mossa legale irraggiungibile.
signal chosen(asset_id: String)

var _held: bool = false
var _picture: TextureRect
var _name: Label
var _verb: Label
var _footer: Label


## L'altezza che una carta chiede: la somma delle sue parti, in un posto solo.
##
## Chi la contiene la usa per farsi grande abbastanza, invece di indovinare un
## numero che poi diventa vecchio. Il taglio di D-242 e' nato esattamente da un
## numero indovinato in un altro file.
static func wanted_height() -> float:
	return PICTURE_H + NAME_H + VERB_H + FOOTER_H + 18.0


func _ready() -> void:
	custom_minimum_size = Vector2(CARD_W, wanted_height())
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Godot only asks for a tooltip when there is one to ask about.
	tooltip_text = " "


## `relevant` is the list of families the open question listens to; empty means
## no Council, and then a card shows its printed strength instead of its value.
## Il nome dell'Eco stampato sotto la forza (D-384): una carta con una seconda
## faccia lo deve dire **sulla faccia**, non nel suggerimento del mouse. Si
## chiama dopo `render`, che riscrive il piede.
var _echo_said: String = ""


func note_echo(title: String) -> void:
	if _footer == null or title == "" or _echo_said == title:
		return
	_echo_said = title
	_footer.text = "%s · eco: %s" % [_footer.text, title]


func render(p_asset: Dictionary, relevant: Array, council_open: bool, data: RefCounted) -> void:
	asset = p_asset
	_data = data
	# **La misura si dichiara qui, non solo in `_ready`.** Una carta costruita e
	# disegnata fuori dall'albero non ha mai visto `_ready`, e restava senza
	# altezza minima: cioe' schiacciabile a qualunque cosa, che e' il difetto di
	# D-246 nella sua forma piu' pura.
	custom_minimum_size = Vector2(CARD_W, wanted_height())
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
		_picture.custom_minimum_size = Vector2(CARD_W - 10.0, PICTURE_H)
		# **Non piu' `EXPAND_FILL`.** L'immagine si prendeva lo spazio che
		# avanzava e, quando non ne avanzava, lo prendeva alle righe di sotto:
		# e' cosi' che il testo spariva invece di stringersi.
		_picture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		box.add_child(_picture)
		# **Il nome e il verbo sulla faccia, non nel tooltip** (D-242).
		#
		# Tutto quello che spiegava una carta — il titolo, cosa fa se la cali,
		# cosa costa — viveva nel suggerimento che compare passandoci sopra col
		# mouse. Su un tablet **il passaggio del mouse non esiste**: restavano
		# una figurina e un numero. E' lo stesso difetto di D-240 sui pezzi
		# della mappa, in un altro posto: il testo c'era e non lo vedeva
		# nessuno.
		_name = Label.new()
		_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# Due righe e non una di piu': un titolo lungo allungava la carta oltre
		# il suo contenitore, e a quel punto tagliava se stesso.
		_name.max_lines_visible = 2
		_name.custom_minimum_size = Vector2(0, NAME_H)
		_name.add_theme_font_size_override("font_size", 12)
		box.add_child(_name)
		_verb = Label.new()
		_verb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_verb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_verb.max_lines_visible = 2
		_verb.custom_minimum_size = Vector2(0, VERB_H)
		_verb.add_theme_font_size_override("font_size", 10)
		_verb.add_theme_color_override("font_color", Color("#8a8172"))
		box.add_child(_verb)
		_footer = Label.new()
		_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_footer.custom_minimum_size = Vector2(0, FOOTER_H)
		_footer.add_theme_font_size_override("font_size", 11)
		box.add_child(_footer)

	_picture.texture = CardArt.texture_for("asset", str(asset["id"]), data)
	_name.text = str(asset["title"])
	_name.add_theme_color_override(
		"font_color", Color("#efe7d8") if is_relevant else Color("#c9bfae")
	)
	# Il verbo per primo: la domanda di chi ha la carta in mano non e' «quanto
	# vale», e' «cosa succede se la calo» (D-228).
	_verb.text = AssetText.action_note(asset)

	# What this card will actually add to the sum, in this Council, right now -
	# asked of the resolver rather than recomputed here, so a card with a bonus
	# cannot show a number the resolution will not give it.
	_footer.text = "forza %d" % int(asset["strength"])
	_echo_said = ""
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
	label.text = AssetText.tooltip(asset, _data)
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


## Il carico che viaggia col trascinamento: quale carta, e cosa sa fare adesso.
##
## L'anteprima e' la carta stessa, ridotta: al tavolo la mano che porta il pezzo
## si vede, e sullo schermo deve vedersi la stessa cosa — trascinare un rettangolo
## grigio non e' prendere una carta.
## La carta alzata: e' quella che si tiene in mano (D-239).
##
## Al tavolo una carta presa si vede perche' e' fuori dal ventaglio; qui si
## alza di qualche pixel e prende un bordo d'oro. Senza questo i posti che si
## accendono sul tavolo sembrerebbero accendersi da soli.
func set_held(held: bool) -> void:
	if _held == held:
		return
	_held = held
	_restyle()


## Il bordo dice due cose in una: se la carta **si puo' giocare adesso**, e se
## e' quella tenuta in mano (D-281).
##
## Il bordo acceso e' la stessa promessa del cerchio d'oro sulla Regione: dove
## c'e', la mossa e' gia' legale. Senza, chi guarda un ventaglio di sei carte
## non ha modo di sapere quali di quelle parlano in questo momento — e nella
## partita del committente non ne parlava nessuna, perche' il carico non
## arrivava mai.
func _restyle() -> void:
	position.y = -6.0 if _held else 0.0
	var playable: bool = not offers.is_empty()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#241f18") if _held else Color(0, 0, 0, 0)
	style.border_color = (
		Color("#e8b563") if _held
		else (Color("#a8823f") if playable else Color(0, 0, 0, 0))
	)
	style.set_border_width_all(2 if _held or playable else 0)
	style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", style)


func _gui_input(event: InputEvent) -> void:
	if offers.is_empty() or asset.is_empty():
		return
	if event is InputEventMouseButton \
			and (event as InputEventMouseButton).pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		chosen.emit(str(asset.get("id", "")))


func _get_drag_data(_at: Vector2) -> Variant:
	if offers.is_empty() or asset.is_empty():
		return null
	# L'anteprima e' presentazione, non decisione: il carico si costruisce
	# comunque. Fuori da un albero `set_drag_preview` non ha dove appendere il
	# fantasma e scrive un errore in un log che nessuno legge — cioe' la
	# suite resterebbe verde mentre la CI va rossa sul grep di D-224.
	if not is_inside_tree():
		return {"kind": "asset", "asset_id": str(asset.get("id", "")), "offers": offers}
	var ghost := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0d0b09")
	style.border_color = _family_colour(str(asset.get("family", "")))
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	ghost.add_theme_stylebox_override("panel", style)
	ghost.custom_minimum_size = size * 0.8
	var name := Label.new()
	name.text = str(asset.get("title", ""))
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.add_theme_font_size_override("font_size", 10)
	name.add_theme_color_override("font_color", Color("#efe7d8"))
	name.set_anchors_preset(Control.PRESET_FULL_RECT)
	ghost.add_child(name)
	set_drag_preview(ghost)
	return {"kind": "asset", "asset_id": str(asset.get("id", "")), "offers": offers}
