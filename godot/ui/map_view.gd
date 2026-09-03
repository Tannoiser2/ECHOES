extends Control
## The board: six Regions, the roads between them, and who is standing where.
##
## Draws from WorldState and nothing else. It does not know a rule, cannot reach
## a decider, and never asks a question - `render(session, viewer_id)` is its
## whole input. That is what lets the same node serve a Chronicle played by a
## person and one played by four policies, and what will let 0.2 swap the
## rendering for real art without touching a line of engine code.
##
## `viewer_id` matters: a Region shows what *that seat* is entitled to see. It is
## the same rule the terminal follows (§11.1), applied to pixels.

const RegionArt := preload("res://scripts/core/region_art.gd")
const Glyph := preload("res://ui/glyph.gd")
const ArtLibrary := preload("res://scripts/core/art_library.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

## Quanto e' grande una tessera. Cresce con lo spazio che ha: a schermo intero
## una mappa di sei bolli piccoli in mezzo al vuoto spreca l'unica vista che
## racconta dove sono le cose - e il terreno, che e' il motivo per cui la tessera
## e' disegnata, a 46 pixel non si vede.
const RADIUS_MIN: float = 42.0
const RADIUS_MAX: float = 92.0
var _radius: float = RADIUS_MIN

## Region id -> centre, in pixels. Rebuilt on every resize.
var _points: Dictionary = {}
var _regions: Array = []
var _session: RefCounted
var _viewer: String = ""
var _hovered: String = ""

## Region ids the player may act on right now, mapped to whatever the caller
## wants back when one is pressed. The map does not decide what is in here and
## cannot: the set comes from the choices SeatDecider has already had the rules
## accept, so a Region is pressable exactly when the action is legal (D-039).
var highlighted: Dictionary = {}

## **La Regione dove una carta trascinata cadrebbe adesso**, o "". Serve solo a
## disegnare: l'anello si accende sotto il pezzo che sta arrivando, cosi' chi
## trascina vede *dove* sta per lasciarlo prima di lasciarlo.
var _landing: String = ""

## Emesso quando una carta viene lasciata cadere su una Regione che l'accetta.
## Porta l'indice della scelta, che e' quello che `ask()` sta aspettando.
signal card_dropped(index: int)

## L'eco del cambiamento (l'inventario dell'app, ISSUES 22): al tavolo fisico
## vedi la mano che sposta il pezzo, sullo schermo il pezzo e' gia' spostato.
## Quando un effetto tocca una Regione, un anello ambra le si accende intorno
## e sfuma in qualche secondo - un'evidenza, non un'informazione: cosa sia
## cambiato lo dicono il verbale e i segnalini, questo dice solo *dove* guardare.
const ECHO_SECONDS: float = 6.0
var _echoes: Dictionary = {}

signal region_clicked(region_id: String)

## --- i nodi sopra la pittura (D-444, ISSUES 65) --------------------------------
##
## La tessera resta dipinta — terreno, pedine, pezzi sono cartone — ma **quello
## che si legge e si tocca e' un nodo**: il nome della Regione, le domande che
## abitano la tessera (un posto dove posare una carta, come la riga della
## colonna in D-231), e le parole dei segni sotto i pezzi, che fino a qui
## uscivano solo sotto il mouse — cioe' mai, per chi gioca col dito. La sonda
## della pagina li vede, un lettore di schermo li dice, un dito li trova.
const DropSlot := preload("res://ui/drop_slot.gd")

## `region_id -> Label` col nome, e con le parole dei segni.
var _names: Dictionary = {}
var _words: Dictionary = {}
## `tension_id -> DropSlot`: la domanda sulla tessera dove abita adesso.
var _questions: Dictionary = {}
## `"tension:ID" -> indice della scelta`, riempito da chi tiene la carta in mano.
var held_places: Dictionary = {}

## Una carta **tenuta in mano** e' stata posata su una domanda della mappa.
signal card_placed(index: int)
## Qualcuno vuole leggere la scheda di questa domanda, toccandola sulla mappa.
signal tension_opened(tension_id: String)
## Una carta trascinata e' caduta su una domanda: le scelte che porta per lei.
signal card_dropped_on_question(indices: Array)


## Accende le domande dove la carta tenuta in mano puo' andare, e spegne le altre.
func hold(places: Dictionary) -> void:
	held_places = places.duplicate()
	for tension_id in _questions:
		(_questions[tension_id] as Object).call(
			"light", held_places.has("tension:%s" % str(tension_id))
		)


## I nodi che mancano, costruiti; quelli che non abitano piu' nessuna tessera,
## tolti. Si chiama a ogni `render`, perche' le domande in gioco cambiano.
func _ensure_nodes() -> void:
	for region_id in _regions:
		var id: String = str(region_id)
		if not _names.has(id):
			var name := Label.new()
			name.mouse_filter = Control.MOUSE_FILTER_IGNORE
			name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name.add_theme_font_size_override("font_size", 13)
			name.add_theme_color_override("font_color", Color("#efe7d8"))
			name.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
			name.add_theme_constant_override("shadow_offset_x", 1)
			name.add_theme_constant_override("shadow_offset_y", 1)
			name.clip_text = true
			add_child(name)
			_names[id] = name
			var words := Label.new()
			words.mouse_filter = Control.MOUSE_FILTER_IGNORE
			words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			words.add_theme_font_size_override("font_size", 11)
			words.add_theme_color_override("font_color", Color("#efe7d8"))
			words.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
			words.add_theme_constant_override("shadow_offset_x", 1)
			words.add_theme_constant_override("shadow_offset_y", 1)
			words.clip_text = true
			add_child(words)
			_words[id] = words
		(_names[id] as Label).text = str(_session.data.regions[id]["name"])
	var alive: Dictionary = {}
	for tension_id in _session.world["tensions"]:
		var id: String = str(tension_id)
		alive[id] = true
		if _questions.has(id):
			continue
		var slot: PanelContainer = DropSlot.new()
		slot.field = "tension"
		slot.key = id
		# **Alto come un dito** (D-243): e' un bersaglio, e un bersaglio
		# stretto e' una bugia per chi gioca sul tablet.
		slot.custom_minimum_size = Vector2(0, 44)
		# La domanda ferma il tocco: la tessera sotto non deve rispondere allo
		# stesso dito che ha posato la carta sulla domanda.
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var line := Label.new()
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_theme_font_size_override("font_size", 11)
		line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.clip_text = true
		slot.add_child(line)
		slot.card_dropped.connect(
			func(indices: Array) -> void: card_dropped_on_question.emit(indices)
		)
		slot.gui_input.connect(func(event: InputEvent) -> void:
			if not (event is InputEventMouseButton):
				return
			var press := event as InputEventMouseButton
			if not press.pressed or press.button_index != MOUSE_BUTTON_LEFT:
				return
			var where: String = "tension:%s" % id
			if held_places.has(where):
				card_placed.emit(int(held_places[where]))
			else:
				tension_opened.emit(id)
		)
		add_child(slot)
		_questions[id] = slot
	for tension_id in _questions.keys():
		if not alive.has(str(tension_id)):
			(_questions[tension_id] as Node).queue_free()
			_questions.erase(tension_id)


## Ogni nodo al suo posto sulla tessera, e con le parole giuste.
func _place_nodes() -> void:
	if _session == null:
		return
	var half: float = _radius
	for region_id in _regions:
		var id: String = str(region_id)
		if not _points.has(id) or not _names.has(id):
			continue
		var centre: Vector2 = _points[id]
		var name: Label = _names[id]
		name.position = Vector2(centre.x - half + 4.0, centre.y + half - 22.0)
		name.size = Vector2(half * 2.0 - 8.0, 18.0)
		var words: Label = _words[id]
		words.text = _words_of(id)
		words.visible = words.text != ""
		words.position = Vector2(centre.x - half, centre.y + half + 10.0 + PIECE + 8.0)
		words.size = Vector2(half * 2.0, 16.0)
	var stacked: Dictionary = {}
	for tension_id in _questions:
		var id: String = str(tension_id)
		var slot: Control = _questions[id]
		var home: String = str(_session.confluence.narrative.focus_region(id))
		if home == "" or not _points.has(home):
			slot.visible = false
			continue
		slot.visible = true
		var row: int = int(stacked.get(home, 0))
		stacked[home] = row + 1
		var centre: Vector2 = _points[home]
		slot.position = Vector2(centre.x - half + 4.0, centre.y - half + 4.0 + float(row) * 46.0)
		slot.size = Vector2(half * 2.0 - 8.0, 44.0)
		# La misura si **dichiara**, non si ottiene e basta: la sonda della pagina
		# legge quello che un nodo chiede, e un posto che chiede zero di
		# larghezza le risulta stretto quanto un capello.
		slot.custom_minimum_size = slot.size
		var threshold: int = _session.tensions.threshold(id)
		var value: int = _session.service.visible_tension_value(id, _viewer)
		var title: String = str(_session.data.tensions[id]["title"])
		var line: Label = slot.get_child(0) as Label
		var tint: Color = Color("#8a8172")
		if value < 0:
			line.text = "%s · velata" % title
		else:
			line.text = "%s · %d/%d" % [title, value, threshold]
			var margin: int = threshold - value
			tint = Color("#6fa88a")
			if margin <= 0:
				tint = Color("#c8553d")
			elif margin <= 1:
				tint = Color("#e8b563")
		line.add_theme_color_override("font_color", tint)


## Le parole dei pezzi di una tessera, in italiano da giocatore: quello che il
## cartone stampa sotto ogni segnalino.
func _words_of(region_id: String) -> String:
	var region: Dictionary = _session.world["regions"][region_id]
	var data: RefCounted = _session.data
	var words: Array = []
	for record in region.get("structures", []):
		var stone: Dictionary = record as Dictionary
		var kind: String = str(stone.get("structure_type", ""))
		var word: String = SignLabels.grade_name(kind, int(stone.get("grade", 1)), data)
		if word != "":
			words.append(word)
	var marks: Array = []
	for tag in region["tags"]:
		var text: String = str(tag)
		if text.begins_with("condition:") or text.begins_with("scar:"):
			marks.append(text)
	marks.sort()
	for tag in marks:
		if SignLabels.piece(str(tag), data) == "":
			continue
		var word: String = SignLabels.label(str(tag), data)
		if word != "":
			words.append(word)
	return " · ".join(PackedStringArray(words))


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_on_resized)
	set_process(false)


## La Regione che un Effect applicato ha toccato, o "" se non ne tocca nessuna.
## Pura e statica, cosi' la mappa dei tipi sta in un posto solo ed e' provabile
## in headless. I no-op non accendono niente: non e' cambiato nulla.
static func region_of_effect(effect: Dictionary) -> String:
	if bool(effect.get("inverse_payload", {}).get("noop", false)):
		return ""
	var payload: Dictionary = effect.get("payload", {})
	match str(effect.get("type", "")):
		"SET_CONTROL", "SET_REGION_TAG", "REMOVE_REGION_TAG":
			return str(effect.get("target", {}).get("id", ""))
		"ADD_PRESENCE", "REMOVE_PRESENCE":
			return str(payload.get("region_id", ""))
		"ADD_SCAR", "REMOVE_SCAR":
			return str(payload.get("region_id", ""))
	return ""


func mark_changed(region_id: String) -> void:
	if region_id == "" or _session == null or not _session.world["regions"].has(region_id):
		return
	_echoes[region_id] = 1.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if _echoes.is_empty():
		set_process(false)
		return
	var gone: Array = []
	for region_id in _echoes:
		_echoes[region_id] = float(_echoes[region_id]) - delta / ECHO_SECONDS
		if float(_echoes[region_id]) <= 0.0:
			gone.append(region_id)
	for region_id in gone:
		_echoes.erase(region_id)
	queue_redraw()


## The only way in. Called after every phase, and after every action.
func render(session: RefCounted, viewer_id: String) -> void:
	_session = session
	_viewer = viewer_id
	if _regions.is_empty():
		var ids: Array = (session.world["regions"] as Dictionary).keys()
		ids.sort()
		_regions = ids
	_ensure_nodes()
	_relayout()
	_place_nodes()
	queue_redraw()


## Il tabellone dipinto, se qualcuno l'ha messo in `res://art/map/board.png`.
## Quando c'e', il terreno generato si fa da parte: l'immagine **e'** il terreno,
## e la mappa disegna solo quello che il quadro non sa - chi tiene un posto, chi
## ci sta, cosa gli e' successo quest'anno.
##
## **Vale solo per la mappa d'autore.** Sul tavolo pescato le tessere si posano
## in griglia (D-275) e ognuna porta il suo quadro (`region.<id>`, D-277): il
## tabellone dipinto li' sarebbe un'altra mappa sotto quella vera.
func _board() -> Texture2D:
	if _session != null and not (
		_session.world.get("map_positions", {}) as Dictionary
	).is_empty():
		return null
	return ArtLibrary.texture(ArtLibrary.BOARD)


## Il rettangolo del quadro dentro questa vista, a proporzioni rispettate.
func _board_rect(board: Texture2D) -> Rect2:
	var art: Vector2 = board.get_size()
	var scale: float = minf(size.x / art.x, size.y / art.y)
	var span: Vector2 = art * scale
	return Rect2((size - span) * 0.5, span)


## Al cambio di misura le tessere si ridispongono, **e i nodi con loro**: un
## nome, una domanda, una riga di parole posati al `render` e lasciati li'
## resterebbero sulla tessera di prima.
func _on_resized() -> void:
	_relayout()
	_place_nodes()


func _relayout() -> void:
	if _session == null:
		return
	_points.clear()
	# Sei tessere e la mappa piu grande possibile che le contiene: il raggio esce
	# dallo spazio disponibile invece di essere una costante, cosi la stessa vista
	# funziona in una finestra stretta e a schermo intero.
	_radius = clampf(minf(size.x, size.y) * 0.17, RADIUS_MIN, RADIUS_MAX)

	# **La posa comanda** (D-275): sul tavolo pescato le tessere stanno in
	# griglia nell'ordine di pesca, e lo schermo le mette dove stanno sul
	# tavolo — non dove le coordinate d'autore della mappa scritta le
	# metterebbero. Vicino e' chi si tocca: quello che la vista mostra e'
	# esattamente quello che la regola legge.
	var posa: Dictionary = (_session.world.get("map_positions", {}) as Dictionary)
	if not posa.is_empty():
		var columns: int = 1
		var rows: int = 1
		for spot in posa.values():
			columns = maxi(columns, int((spot as Array)[0]) + 1)
			rows = maxi(rows, int((spot as Array)[1]) + 1)
		# **Accostate, non distanziate** (D-279): sono tessere di cartone posate
		# una accanto all'altra. Il lato e' il piu' grande che sta nello spazio
		# con tre colonne e due righe, e il blocco si centra: fra una tessera e
		# l'altra c'e' una fuga, non un prato.
		var side: float = minf(size.x / float(columns), size.y / float(rows))
		_radius = side * 0.5
		var block: Vector2 = Vector2(side * float(columns), side * float(rows))
		var origin: Vector2 = (size - block) * 0.5
		for region_id in _regions:
			var spot: Variant = posa.get(str(region_id))
			if spot == null:
				continue
			_points[str(region_id)] = origin + Vector2(
				(float(int((spot as Array)[0])) + 0.5) * side,
				(float(int((spot as Array)[1])) + 0.5) * side
			)
		return

	# Con il quadro le coordinate dei dati si prendono **alla lettera**: chi ha
	# dipinto la mappa ha messo la citta' dove i dati dicevano che stava, e
	# allungare il riquadro come si fa senza quadro sposterebbe i segnalini fuori
	# dai posti dipinti.
	var board: Texture2D = _board()
	if board != null:
		var frame: Rect2 = _board_rect(board)
		# Le presenze stanno nelle aree calme che il quadro lascia libere, quindi
		# il raggio serve solo a tenerle raccolte e a dare un bersaglio al dito.
		_radius = clampf(minf(frame.size.x, frame.size.y) * 0.10, 30.0, 70.0)
		for region_id in _regions:
			var known: Variant = _session.data.regions.get(str(region_id))
			var spot: Variant = null if known == null else known.get("map_position")
			if spot == null:
				continue
			_points[str(region_id)] = frame.position + Vector2(
				float(spot["x"]), float(spot["y"])
			) * frame.size
		return
	var area: Vector2 = size - Vector2(_radius * 2.4, _radius * 2.8)
	var origin: Vector2 = Vector2(_radius * 1.2, _radius * 1.2)
	# Le coordinate scritte nei dati vanno da 0.16 a 0.81: prese alla lettera
	# lasciano un quinto di schermo vuoto in basso. Si allunga il **riquadro** che
	# le contiene fino a riempire lo spazio, il che sposta tutto insieme e non
	# cambia di una virgola dove sta una Regione rispetto alle altre.
	var low: Vector2 = Vector2(1.0, 1.0)
	var high: Vector2 = Vector2(0.0, 0.0)
	for region_id in _regions:
		var known: Variant = _session.data.regions.get(str(region_id))
		var spot: Variant = null if known == null else known.get("map_position")
		if spot == null:
			continue
		low = Vector2(minf(low.x, float(spot["x"])), minf(low.y, float(spot["y"])))
		high = Vector2(maxf(high.x, float(spot["x"])), maxf(high.y, float(spot["y"])))
	var span: Vector2 = Vector2(maxf(0.01, high.x - low.x), maxf(0.01, high.y - low.y))

	for i in range(_regions.size()):
		var region_id: String = str(_regions[i])
		var definition: Variant = _session.data.regions.get(region_id)
		var place: Variant = null if definition == null else definition.get("map_position")
		if place == null:
			# No authored position: fall back to a circle, so a Chronicle that
			# forgets its coordinates still draws something readable.
			var angle: float = TAU * float(i) / float(maxi(1, _regions.size())) - PI / 2.0
			_points[region_id] = size * 0.5 + Vector2(cos(angle), sin(angle)) * (minf(size.x, size.y) * 0.34)
		else:
			_points[region_id] = origin + Vector2(
				(float(place["x"]) - low.x) / span.x, (float(place["y"]) - low.y) / span.y
			) * area


## Only the Regions the current question offers answer to the mouse. A Region
## that lights up under the cursor and then does nothing when pressed reads as a
## broken game, so one that cannot be chosen does not light up at all.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# **Sotto il dito, non sotto la mossa** (D-240). Fino a qui `_hovered`
		# valeva solo per le Regioni *raggiungibili*, e siccome i nomi dei pezzi
		# si scrivono per la Regione guardata, **quei nomi non comparivano quasi
		# mai**: fuori da una scelta nessuna Regione e' raggiungibile. Guardare e
		# poter andare sono due cose diverse, e la seconda ha gia' il suo anello
		# d'oro per dirsi.
		var was: String = _hovered
		_hovered = _region_at((event as InputEventMouseMotion).position)
		if was != _hovered:
			mouse_default_cursor_shape = (
				Control.CURSOR_POINTING_HAND if highlighted.has(_hovered)
				else Control.CURSOR_ARROW
			)
			queue_redraw()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
			var hit: String = _offered_at(button.position)
			if hit != "":
				region_clicked.emit(hit)
				return
			# **Un tocco su un tablet non ha un «sopra»** (D-240). Senza mouse
			# non esiste il passaggio del cursore, quindi i nomi dei pezzi non
			# si vedono mai: il tocco su una Regione che non e' un bersaglio
			# vale come guardarla, e la nomina.
			var looked: String = _region_at(button.position)
			if looked != _hovered:
				_hovered = looked
				queue_redraw()


func _offered_at(point: Vector2) -> String:
	var hit: String = _region_at(point)
	return hit if highlighted.has(hit) else ""


func _region_at(point: Vector2) -> String:
	# Sul tavolo pescato la tessera e' un quadrato (D-279): il dito prende il
	# quadrato. Col cerchio, i quattro angoli di ogni tessera — cioe' un
	# quinto della sua superficie — non rispondevano al tocco.
	var square: bool = _session != null and not (
		_session.world.get("map_positions", {}) as Dictionary
	).is_empty() and _board() == null
	for region_id in _points:
		var centre: Vector2 = _points[region_id]
		if square:
			if absf(point.x - centre.x) <= _radius and absf(point.y - centre.y) <= _radius:
				return str(region_id)
		elif point.distance_to(centre) <= _radius:
			return str(region_id)
	return ""


# --- drawing ----------------------------------------------------------------

func _draw() -> void:
	if _session == null or _points.is_empty():
		return
	var board: Texture2D = _board()
	if board != null:
		draw_texture_rect(board, _board_rect(board), false)
	elif (_session.world.get("map_positions", {}) as Dictionary).is_empty():
		# Senza quadro le strade sono disegnate; con il quadro ci sono gia'
		# dentro, e ridisegnarle sopra sarebbe una seconda mappa sulla prima.
		#
		# **Sul tavolo pescato non si disegnano affatto** (D-279): le tessere
		# si toccano, e vicino e' chi si tocca (D-275). Una strada fra due
		# tessere accostate sarebbe un segno che al tavolo non c'e' — e per di
		# piu' disegnata dal grafo scritto nei dati, che li' non vale.
		_draw_roads()
	for region_id in _regions:
		_draw_region(str(region_id))


## Roads first, so the Regions sit on top of them. Drawn once per pair: the
## adjacency list holds both directions and drawing both leaves a doubled line
## that reads as a thicker, more important road.
##
## Due tratti invece di uno: una banda scura larga e un filo chiaro dentro. Una
## strada disegnata con una riga sola e' un collegamento in un diagramma; questa
## e' terra battuta, ed e' la lettura che la mappa deve dare - i posti sono
## posti, non nodi.
func _draw_roads() -> void:
	var drawn: Dictionary = {}
	for region_id in _regions:
		var definition: Variant = _session.data.regions.get(str(region_id))
		if definition == null:
			continue
		for other in definition["adjacency"]:
			var key: String = "|".join(PackedStringArray(
				[str(region_id), str(other)] if str(region_id) < str(other)
				else [str(other), str(region_id)]
			))
			if drawn.has(key) or not _points.has(str(other)):
				continue
			drawn[key] = true
			var from: Vector2 = _points[str(region_id)]
			var to: Vector2 = _points[str(other)]
			var along: Vector2 = (to - from).normalized()
			var start: Vector2 = from + along * (_radius * 0.86)
			var end: Vector2 = to - along * (_radius * 0.86)
			draw_line(start, end, Color("#2a241c"), 9.0, true)
			draw_line(start, end, Color("#4a4033"), 3.0, true)


func _draw_region(region_id: String) -> void:
	var centre: Vector2 = _points[region_id]
	var region: Dictionary = _session.world["regions"][region_id]
	var definition: Dictionary = _session.data.regions[region_id]
	var control: Variant = region.get("control", null)

	var offered: bool = highlighted.has(region_id)
	if _board() != null:
		_draw_over_board(region_id, centre, control, offered)
		return
	# **Sul tavolo pescato la tessera e' un quadrato** (D-279, parola del
	# committente: «la mappa deve essere con le immagini affiancate a quadrato
	# con un 3x2, non a esagoni»). Le tessere di cartone si accostano lato a
	# lato: l'esagono era una figura che sul tavolo non esiste, e nascondeva
	# meta' del quadro dipinto ritagliandolo.
	if not (_session.world.get("map_positions", {}) as Dictionary).is_empty():
		_draw_square_tile(region_id, centre, control, offered)
		return
	# Il terreno, generato dal bioma e dall'id: la tessera si riconosce da lontano
	# per quello che e', non per l'etichetta scritta sotto (D-057). Il centro
	# resta calmo perche' e' li che cadono presenze e segni.
	var art: Dictionary = RegionArt.plan(region_id, str(definition["biome"]))
	var box: Rect2 = Rect2(centre - Vector2(_radius, _radius), Vector2(_radius, _radius) * 2.0)
	var lift: float = 0.0
	if offered:
		lift += 0.10
	if _hovered == region_id or _landing == region_id:
		lift += 0.12
	# La tessera dipinta, se e' stata consegnata: ritagliata dentro l'esagono
	# invece che appoggiata sopra, cosi' la Regione resta una Regione e non
	# diventa un quadro con un bordo (D-059).
	var painted: Texture2D = ArtLibrary.texture(str(definition.get("art_prompt_key", "")))
	if painted != null:
		_draw_painted(art["outline"], box, painted, lift)
	else:
		_draw_terrain(art, box, lift)

	# The ring is who holds the place. No ring means nobody does, which is a
	# fact worth seeing rather than a blank.
	# Segue la sagoma della tessera: un cerchio sopra un esagono sarebbe una
	# seconda forma che non vuol dire niente.
	var ring: Color = Color("#4a4238")
	var width: float = 2.0
	if control != null:
		ring = _entity_colour(str(control))
		width = 4.0
	_draw_outline(art["outline"], box, ring, width)

	# A second ring, outside the first, for "you may go here". Outside because
	# the inner ring already means something else - who holds the place - and the
	# two facts have to stay separable at a glance.
	if offered:
		# L'anello si accende anche sotto la carta che **sta arrivando**
		# (D-230): chi trascina deve vedere dove sta per lasciare il pezzo
		# prima di lasciarlo, come la mano che esita sopra il tavolo.
		var lit: bool = _hovered == region_id or _landing == region_id
		_draw_outline(
			art["outline"], box.grow(7.0),
			Color("#e8b563") if lit else Color("#7a6338"),
			3.0 if lit else 2.0
		)

	var font: Font = ThemeDB.fallback_font
	var name: String = str(definition["name"])
	var name_size: Vector2 = font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(
		font, centre + Vector2(-name_size.x * 0.5, _radius + 16.0),
		name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d9d2c5")
	)

	_draw_echo(centre, region_id)
	_draw_presence(centre, region_id)
	_draw_marks(centre, region_id, region)


## La tessera quadrata del tavolo pescato (D-279).
##
## Il quadro della Regione riempie il quadrato per intero — nessun ritaglio,
## nessuna sagoma: e' la tessera di cartone, vista da sopra. Senza quadro resta
## il terreno generato, dipinto dentro lo stesso quadrato. Sopra ci vanno le
## sole cose che il quadro non sa: chi la tiene, chi ci sta, cosa le e'
## successo quest'anno.
func _draw_square_tile(
	region_id: String, centre: Vector2, control: Variant, offered: bool
) -> void:
	var definition: Dictionary = _session.data.regions[region_id]
	var half: float = _radius
	var box: Rect2 = Rect2(centre - Vector2(half, half), Vector2(half, half) * 2.0)
	var lift: float = 0.0
	if offered:
		lift += 0.10
	if _hovered == region_id or _landing == region_id:
		lift += 0.12

	var painted: Texture2D = ArtLibrary.texture(str(definition.get("art_prompt_key", "")))
	if painted != null:
		draw_texture_rect(painted, box, false, Color(1, 1, 1).lightened(lift))
	else:
		var art: Dictionary = RegionArt.plan(region_id, str(definition["biome"]))
		draw_rect(box, Color(str(art["ground"])).lightened(lift), true)
		_draw_terrain_strokes(art, box, lift)
	# Il centro resta calmo anche qui: un velo sotto i segnalini, perche' un
	# pezzo chiaro su un campo chiaro sparisce.
	draw_circle(centre, half * 0.62, Color(0.07, 0.06, 0.05, 0.28))

	# Il bordo: la fuga fra due tessere accostate, e chi tiene il posto.
	var ring: Color = Color("#2a241c")
	var width: float = 2.0
	if control != null:
		ring = _entity_colour(str(control))
		width = 4.0
	draw_rect(box, ring, false, width)
	if offered:
		var lit: bool = _hovered == region_id or _landing == region_id
		draw_rect(
			box.grow(-3.0), Color("#e8b563") if lit else Color("#7a6338"), false,
			3.0 if lit else 2.0
		)

	# Il nome sta **dentro** la tessera, in basso, ed e' un nodo (D-444): qui
	# resta solo la fascia scura che lo stacca dal quadro.
	draw_rect(
		Rect2(centre + Vector2(-half + 4.0, half - 24.0), Vector2(half * 2.0 - 8.0, 22.0)),
		Color(0.05, 0.04, 0.03, 0.62), true
	)

	_draw_echo(centre, region_id)
	_draw_presence(centre, region_id)
	_draw_marks(centre, region_id, _session.world["regions"][region_id])


## I tratti del bioma dentro un rettangolo, senza la sagoma piena: la usa la
## tessera quadrata quando il quadro non e' stato consegnato.
func _draw_terrain_strokes(art: Dictionary, box: Rect2, lift: float) -> void:
	for stroke in art["strokes"]:
		var item: Dictionary = stroke
		var colour: Color = Color(str(item["colour"])).lightened(lift)
		var at: PackedVector2Array = _mapped(item["points"], box)
		match str(item["kind"]):
			"poly":
				draw_colored_polygon(at, colour)
			"line":
				draw_polyline(at, colour, maxf(1.0, float(item["width"]) * box.size.x), true)
			"dot":
				draw_circle(at[0], float(item["width"]) * box.size.x, colour)


## Quello che il quadro non sa.
##
## Un velo scuro appena accennato sotto i segnalini - senza, un token chiaro su
## un campo chiaro sparisce - poi l'anello di chi tiene il posto, il nome e i
## segni. Nessuna sagoma piena: l'immagine sotto e' il pezzo forte, e coprirla
## sarebbe come stampare una mappa e incollarci sopra dei cerchi.
func _draw_over_board(region_id: String, centre: Vector2, control: Variant, offered: bool) -> void:
	var veil: float = 0.30
	if offered:
		veil += 0.10
	if _hovered == region_id:
		veil += 0.12
	draw_circle(centre, _radius, Color(0.07, 0.06, 0.05, veil))

	if control != null:
		draw_arc(centre, _radius, 0.0, TAU, 40, _entity_colour(str(control)), 3.0, true)
		# E il vessillo piantato sul bordo: il controllo non e' una presenza -
		# non si conta, si pianta - e chi guarda da lontano vede subito di chi
		# e' il posto senza dover leggere il colore di un anello sottile.
		_draw_piece(
			"banner", centre + Vector2(0.0, -_radius), 20.0, _entity_colour(str(control))
		)
	if offered:
		draw_arc(
			centre, _radius + 6.0, 0.0, TAU, 40,
			Color("#e8b563") if _hovered == region_id else Color("#7a6338"),
			3.0 if _hovered == region_id else 2.0, true
		)

	# Il nome e' un nodo (D-444), con la sua ombra: qui non si dipinge.
	_draw_echo(centre, region_id)
	_draw_presence(centre, region_id)
	_draw_marks(centre, region_id, _session.world["regions"][region_id])


## L'anello che sfuma: qualcosa e' appena successo qui. Fuori da tutti gli
## altri anelli, perche' quelli vogliono dire altro (chi tiene il posto, dove
## si puo' andare) e i tre fatti devono restare separabili a colpo d'occhio.
func _draw_echo(centre: Vector2, region_id: String) -> void:
	if not _echoes.has(region_id):
		return
	var strength: float = clampf(float(_echoes[region_id]), 0.0, 1.0)
	draw_arc(
		centre, _radius + 12.0, 0.0, TAU, 48,
		Color(0.91, 0.71, 0.39, 0.85 * strength), 2.0 + 2.5 * strength, true
	)


## L'illustrazione dentro la sagoma. Le UV sono le stesse coordinate normalizzate
## del piano - il disegno generato e l'immagine vera occupano lo stesso quadrato,
## quindi il ritaglio coincide senza calcoli.
func _draw_painted(outline: Array, box: Rect2, painted: Texture2D, lift: float) -> void:
	var points: PackedVector2Array = _mapped(outline, box)
	var uvs: PackedVector2Array = PackedVector2Array()
	for point in outline:
		uvs.append(point as Vector2)
	draw_colored_polygon(points, Color(1, 1, 1).darkened(0.12 - lift), uvs, painted)


## Il terreno: la sagoma piena, poi i tratti del bioma. `lift` schiarisce tutto
## insieme - la tessera sotto il cursore e' la stessa tessera un po piu vicina
## alla luce, non un'altra tavolozza.
func _draw_terrain(art: Dictionary, box: Rect2, lift: float) -> void:
	draw_colored_polygon(_mapped(art["outline"], box), Color(str(art["ground"])).lightened(lift))
	for stroke in art["strokes"]:
		var item: Dictionary = stroke
		var colour: Color = Color(str(item["colour"])).lightened(lift)
		var at: PackedVector2Array = _mapped(item["points"], box)
		match str(item["kind"]):
			"poly":
				draw_colored_polygon(at, colour)
			"line":
				draw_polyline(at, colour, maxf(1.0, float(item["width"]) * box.size.x), true)
			"dot":
				draw_circle(at[0], float(item["width"]) * box.size.x, colour)


func _draw_outline(outline: Array, box: Rect2, colour: Color, width: float) -> void:
	var points: PackedVector2Array = _mapped(outline, box)
	points.append(points[0])
	draw_polyline(points, colour, width, true)


## Dal quadrato unitario del piano ai pixel di questa tessera.
func _mapped(points: Array, box: Rect2) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for point in points:
		out.append(box.position + (point as Vector2) * box.size)
	return out


## Una pedina per presenza, in cerchio dentro la Regione. Contare le presenze e'
## una cosa che un giocatore fa di continuo, quindi si disegnano come cose da
## contare invece che scriverne il numero — e si disegnano come **pezzi**: la
## sagoma della pedina (D-137/D-097) e' la stessa che esce dalla fustella, con
## la sua ombra sul terreno e il suo contorno scuro. Un tondo colorato dice
## «qualcuno e' qui»; una pedina dice chi, e si riconosce con la coda
## dell'occhio anche da bordo tavolo.
const PAWN: float = 22.0


func _draw_presence(centre: Vector2, region_id: String) -> void:
	var tokens: Array = []
	for entity_id in _session.world["turn_order"]:
		var count: int = _session.service.presence_count(str(entity_id), region_id)
		for i in range(count):
			tokens.append(str(entity_id))
	if tokens.is_empty():
		return
	var step: float = TAU / float(maxi(tokens.size(), 3))
	for i in range(tokens.size()):
		var angle: float = -PI / 2.0 + step * float(i)
		var at: Vector2 = centre + Vector2(cos(angle), sin(angle)) * (_radius * 0.52)
		_draw_piece("pawn", at, PAWN, _entity_colour(str(tokens[i])))


## Un pezzo posato sul terreno: l'ombra che lo stacca dal fondo, il contorno
## scuro che lo tiene leggibile su una mappa chiara o scura, e la sagoma piena
## nel colore della casa. Tre passate, nessuna texture: la stessa forma che il
## foglio-fustella stampa.
func _draw_piece(glyph: String, at: Vector2, side: float, colour: Color) -> void:
	var box: Rect2 = Rect2(at - Vector2(side, side) * 0.5, Vector2(side, side))
	draw_circle(at + Vector2(0.0, side * 0.34), side * 0.30, Color(0.05, 0.04, 0.03, 0.40))
	Glyph.paint(self, glyph, box.grow(1.6), Color("#12100e"))
	Glyph.paint(self, glyph, box, colour)


## **I pezzi sulla Regione** (D-229).
##
## Prima erano una fila di parole in grigio sotto il nome: un granaio, una
## carestia e una cicatrice si leggevano tutti uguali, e per sapere cosa c'era
## bisognava leggere. Il committente l'ha detto per intero — *«non ci sono pedine
## che rappresentano edifici, condizioni, cicatrici e tutto quello che dovrebbe
## apparire in una copia fisica del gioco»* — e aveva ragione: su un tavolo un
## pezzo si riconosce dalla **forma**, da lontano, senza leggere niente.
##
## Adesso ogni segno e' un gettone: un tondo col suo glifo, colorato per livello,
## e per le pietre i **punti del grado** accanto — un punto una torre di veglia,
## tre una reggia. La parola resta, ma solo sotto il mouse: al tavolo la carta si
## legge quando la prendi in mano, non mentre guardi la plancia.
const PIECE_COLOURS: Dictionary = {
	"scar": "#c8553d",
	"condition": "#c99a4e",
	"presidio": "#a8a294",
	"insediamento": "#a8a294",
	"opera": "#a8a294",
	"studio": "#a8a294",
	"luogo": "#7f9a7f",
}

# **Quanto e' grande un pezzo sulla plancia** (D-240). Diciassette pixel erano
# leggibili su un monitor a un palmo dagli occhi e illeggibili su un tablet
# tenuto in mano: *«le pedine e cicatrici sulla mappa non si capiscono e sono
# troppo piccole»*. Un pezzo di cartone si riconosce dalla forma prima che dal
# nome, e una forma dentro diciassette pixel non e' una forma: e' una macchia.
const PIECE: float = 26.0
const PIECE_GAP: float = 7.0


func _draw_marks(centre: Vector2, region_id: String, region: Dictionary) -> void:
	var data: RefCounted = _session.data if _session != null else null
	var pieces: Array = []

	# **Le pietre si leggono dal mondo, non dai tag.** `region.structures` porta
	# `{structure_type, grade, owner}`: il tag dice soltanto *che tipo* c'e', e
	# uno stesso tag copre piu' gradi — `structure:granary` e' sia il Granaio sia
	# il Grande Granaio. Il grado e il padrone stanno nel record, ed e' li' che
	# vanno presi: una reggia disegnata come una torre sarebbe una plancia che
	# mente.
	for record in region.get("structures", []):
		var stone: Dictionary = record as Dictionary
		var kind: String = str(stone.get("structure_type", ""))
		var family: String = SignLabels.family_of(kind, data)
		if family == "":
			continue
		var holder: Variant = stone.get("owner", null)
		pieces.append({
			"glyph": family,
			"grade": int(stone.get("grade", 1)),
			# **Di chi e' la pietra si vede dal colore**, come la pedina: chi
			# tiene una reggia la tiene davvero, e da lontano si conta.
			"tint": _entity_colour(str(holder)) if holder != null else Color(str(PIECE_COLOURS.get(family, "#a8a294"))),
			"word": SignLabels.grade_name(kind, int(stone.get("grade", 1)), data),
		})

	# E i segni che non sono pietre: quello che *succede* a una Regione e quello
	# che le e' successo e non viene piu' via.
	var marks: Array = []
	for tag in region["tags"]:
		var text: String = str(tag)
		if text.begins_with("condition:") or text.begins_with("scar:"):
			marks.append(text)
	marks.sort()
	for tag in marks:
		var piece: String = SignLabels.piece(str(tag), data)
		if piece == "":
			continue
		pieces.append({
			"glyph": piece, "grade": 0,
			"tint": Color(str(PIECE_COLOURS.get(piece, "#8a8172"))),
			"word": SignLabels.label(str(tag), data),
		})

	if pieces.is_empty():
		return

	var row: float = float(pieces.size()) * (PIECE + PIECE_GAP) - PIECE_GAP
	var left: float = centre.x - row * 0.5
	var top: float = centre.y + _radius + 10.0

	for i in range(pieces.size()):
		var piece_data: Dictionary = pieces[i] as Dictionary
		var tint: Color = piece_data["tint"]
		var at: Vector2 = Vector2(left + float(i) * (PIECE + PIECE_GAP), top)
		var middle: Vector2 = at + Vector2(PIECE, PIECE) * 0.5

		# Il tondo scuro sotto e il bordo: serve a staccare il pezzo dal terreno
		# dipinto, che sotto un glifo sottile lo mangia.
		draw_circle(middle, PIECE * 0.62, Color("#16130f"))
		draw_arc(middle, PIECE * 0.62, 0.0, TAU, 20, tint, 1.4, true)
		Glyph.paint(self, str(piece_data["glyph"]), Rect2(at, Vector2(PIECE, PIECE)).grow(-3.0), tint)

		# I punti del grado, sotto il pezzo: si contano con gli occhi, come i
		# piani di una torre che diventa castello e poi reggia.
		var grade: int = int(piece_data["grade"])
		if grade > 1:
			var pips: float = float(grade) * 6.0 - 1.5
			for pip in range(grade):
				draw_circle(
					Vector2(middle.x - pips * 0.5 + float(pip) * 6.0 + 1.5, at.y + PIECE + 5.0),
					2.2, tint
				)

	# Le parole dei pezzi sono un nodo sempre visibile (D-444): al tavolo il
	# cartone le stampa sotto il segnalino, e un dito non ha un «sopra» da cui
	# far uscire un suggerimento.


## Four colours, readable next to each other, handed out by seat rather than by
## name (D-050).
##
## They used to be a `match` on `ENT_ALDRIC` and its three neighbours, which was
## fine while there was one saga and stopped being fine the moment there were
## two: every house of the second one came out the same grey, on a map that is
## the same six places. The turn order is the right hook - it is per Chronicle,
## it is stable inside one, and it works for a saga nobody has written yet.
const SEAT_COLOURS: Array = ["#e8b563", "#6fa88a", "#7fa6c9", "#b06b8f", "#c8a86b", "#7f9a8b"]


func _entity_colour(entity_id: String) -> Color:
	if _session == null:
		return Color("#8a8172")
	var at: int = (_session.world["turn_order"] as Array).find(entity_id)
	if at < 0:
		return Color("#8a8172")
	return Color(str(SEAT_COLOURS[at % SEAT_COLOURS.size()]))


## --- prendere una carta e lasciarla sulla mappa (D-230) ----------------------
##
## Il committente: *«la GUI deve prevedere movimenti drag & drop, non pulsanti
## che dicono cosa fare»*. La mappa non decide niente di nuovo — accetta una
## carta esattamente sulle Regioni che `highlighted` gia' dichiara raggiungibili,
## cioe' quelle per cui le regole hanno gia' detto di si' (D-039). Il
## trascinamento e' un altro modo di dire la stessa cosa, non un'altra regola.

func _can_drop_data(at: Vector2, payload: Variant) -> bool:
	var index: int = _offer_at(at, payload)
	var region: String = _region_at(at)
	if index < 0:
		if _landing != "":
			_landing = ""
			queue_redraw()
		return false
	if _landing != region:
		_landing = region
		queue_redraw()
	return true


func _drop_data(at: Vector2, payload: Variant) -> void:
	var index: int = _offer_at(at, payload)
	_landing = ""
	queue_redraw()
	if index >= 0:
		card_dropped.emit(index)


## La scelta che questa carta, lasciata qui, farebbe — o -1.
##
## Due filtri, e sono lo stesso filtro visto da due parti: la Regione dev'essere
## fra le raggiungibili, e la carta deve portare una scelta *per quella Regione*.
## Una carta che sa muovere non puo' cadere dove nessuna sua mossa arriva.
func _offer_at(at: Vector2, payload: Variant) -> int:
	if typeof(payload) != TYPE_DICTIONARY:
		return -1
	var carried: Dictionary = payload as Dictionary
	if str(carried.get("kind", "")) != "asset":
		return -1
	var region: String = _region_at(at)
	if region == "" or not highlighted.has(region):
		return -1
	for offer in carried.get("offers", []):
		var entry: Dictionary = offer as Dictionary
		if str(entry.get("region", "")) == region:
			return int(entry.get("index", -1))
	return -1

