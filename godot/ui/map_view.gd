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
## La griglia del tavolo, **al minimo** (D-464, allargata da D-510): tre colonne
## e due righe sono il piu' piccolo foglio che si disegna, e la rosa ne chiede
## tre e tre. Le vere le conta `_relayout` dalle caselle occupate: una costante
## che decide quanto mondo ci sta e' una costante che un giorno lo taglia.
const GRID_COLUMNS: int = 3
const GRID_ROWS: int = 2
const SEAM: float = 14.0
const SLOT: float = 26.0
const SLOT_GAP: float = 6.0
const STONE_SLOTS: int = 4
const SCAR_SLOTS: int = 3
var _grid_side: float = 0.0
var _grid_origin: Vector2 = Vector2.ZERO
const RADIUS_MIN: float = 42.0
const RADIUS_MAX: float = 92.0
var _radius: float = RADIUS_MIN

## **L'esagono della rosa** (D-512), nell'orientamento che i dati chiamano per
## nome: lato piatto sopra e sotto, punte a sinistra e a destra. Cosi' i sei
## lati sono `N NE SE S SO NO` in senso orario dall'alto — gli stessi che la
## tessera porta stampati — e il petalo a nord sta **davvero** sopra il centro.
const SQRT3: float = 1.7320508


## I sei vertici, a partire dalla punta di destra.
static func _hex_points(centre: Vector2, r: float) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for k in range(6):
		var a: float = deg_to_rad(60.0 * float(k))
		out.append(centre + Vector2(r * cos(a), -r * sin(a)))
	return out


## Dove cade la casella [colonna, riga] rispetto alla prima. Le colonne pari
## scendono di mezza riga: e' l'incastro degli esagoni.
static func _hex_offset(column: int, row: int, r: float) -> Vector2:
	var lift: float = 0.0 if column % 2 == 1 else -0.5
	return Vector2(1.5 * r * float(column), SQRT3 * r * (float(row) + lift))


## Quanto e' larga la tessera a `dy` dal suo centro: sopra e sotto l'esagono si
## stringe, e un segnalino messo alla larghezza del centro uscirebbe dal cartone.
static func _hex_half_width(dy: float, r: float) -> float:
	return maxf(0.0, r * (1.0 - absf(dy) / (SQRT3 * r)))

## Region id -> centre, in pixels. Rebuilt on every resize.
var _points: Dictionary = {}

## **Si gioca sulla rosa?** Vero quando il mondo porta una posa e non c'e' il
## quadro d'autore sotto. Una domanda sola, in un posto solo: era scritta in
## tre punti diversi come «map_positions non vuoto e board nullo», ed e' il
## genere di riga che diverge in silenzio.
var _hex: bool = false
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
	# **Le domande non abitano piu' la tessera** (D-464, parola del
	# committente): stanno nella colonna a sinistra, scoperte, coi gettoni
	# coperti sopra. La tessera porta solo quello che e' della Regione.


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
		# Le parole dei pezzi stanno **dentro** la tessera, sopra la fila degli
		# spazi (D-464): fuori, sotto la tessera, coprivano la striscia dei
		# segnalini della riga sotto.
		words.position = Vector2(centre.x - half + 4.0, centre.y + half - 24.0 - SLOT - 8.0 - 16.0)
		words.size = Vector2(half * 2.0 - 8.0, 16.0)


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
	_hex = not (_session.world.get("map_positions", {}) as Dictionary).is_empty() \
		and _board() == null
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
		# **La rosa e' fatta di esagoni** (D-512): le tessere si accostano come
		# sul tavolo, lato a lato, e non come quadrati messi a rosa. Le colonne
		# distano `1,5 R` e le righe `√3 R`, e le colonne di lato scendono di
		# mezza riga: e' il passo dell'incastro, non un accorgimento grafico.
		#
		# `map_positions` resta la verita' del mondo — [colonna, riga] — e qui
		# si legge come coordinata d'esagono. La vista segue la posa: se un
		# giorno la rosa cambia forma, cambia da sola.
		var columns: int = GRID_COLUMNS
		var rows: int = GRID_ROWS
		for region_id in _regions:
			var where: Variant = posa.get(str(region_id))
			if where == null:
				continue
			columns = maxi(columns, int((where as Array)[0]) + 1)
			rows = maxi(rows, int((where as Array)[1]) + 1)
		var strip: float = SLOT + SLOT_GAP * 2.0
		# Largo: `1,5 R` per colonna piu' le due mezze punte ai lati = 1,5(c-1)+2.
		# Alto: `√3 R` per riga, piu' la mezza riga di sfasamento e le strisce.
		_radius = minf(
			(size.x - SEAM) / (1.5 * float(columns - 1) + 2.0),
			(size.y - strip * 2.0 - SEAM) / (SQRT3 * (float(rows) + 0.5))
		)
		_radius = clampf(_radius, RADIUS_MIN * 0.5, RADIUS_MAX)
		_grid_side = _radius * 2.0
		var block: Vector2 = Vector2(
			_radius * (1.5 * float(columns - 1) + 2.0),
			_radius * SQRT3 * (float(rows) + 0.5) + strip * 2.0
		)
		var origin: Vector2 = (size - block) * 0.5 + Vector2(_radius, strip + _radius * SQRT3 * 0.5)
		_grid_origin = origin
		for region_id in _regions:
			var spot: Variant = posa.get(str(region_id))
			if spot == null:
				continue
			var column: int = int((spot as Array)[0])
			var row: int = int((spot as Array)[1])
			_points[str(region_id)] = origin + _hex_offset(column, row, _radius)
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
	# **Il dito prende la tessera, non il rettangolo che la contiene** (D-512).
	# Con la forma quadrata bastavano due confronti; su un esagono quei due
	# confronti prenderebbero anche i sei angoli che la fustella toglie — cioe'
	# un tocco che cade **fuori dal cartone** e accende la tessera lo stesso.
	# Si guarda dentro il poligono, che e' la stessa figura che si disegna.
	for region_id in _points:
		var centre: Vector2 = _points[region_id]
		if _hex:
			if Geometry2D.is_point_in_polygon(point, _hex_points(centre, _radius)):
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
	if not (_session.world.get("map_positions", {}) as Dictionary).is_empty():
		_draw_seams()


## **Il confine e' un varco** (D-390), e si vede (D-464, parola del
## committente: *«i lati di adiacenza comuni creano una zona dove e'
## possibile capire che le tessere sono adiacenti e si possono spostare
## cose»*). Nella fuga fra due tessere accostate: un ponte chiaro se il varco
## c'e' su tutte e due, un muro scuro se no.
func _draw_seams() -> void:
	var links: Dictionary = _session.world.get("adjacency", {}) as Dictionary
	# **Sei direzioni, non due** (D-512). Col quadrato bastava guardare a destra
	# e in basso; su una rosa i vicini stanno tutt'intorno, e la coppia si
	# riconosce dalla distanza fra i centri — il passo dell'incastro — invece
	# che da un passo di griglia. Ogni coppia una volta sola: `here < there`.
	var passo: float = SQRT3 * _radius
	var seen: Array = _points.keys()
	seen.sort()
	for i in range(seen.size()):
		for j in range(i + 1, seen.size()):
			var here: String = str(seen[i])
			var there: String = str(seen[j])
			var a: Vector2 = _points[here]
			var b: Vector2 = _points[there]
			if absf(a.distance_to(b) - passo) > _radius * 0.30:
				continue
			var mid: Vector2 = (a + b) * 0.5
			var across: Vector2 = (b - a).normalized()
			var along: Vector2 = across.orthogonal() * (_radius * 0.34)
			var open: bool = (links.get(here, []) as Array).has(there)
			if open:
				# Il varco: un ponte chiaro nella fuga, largo quanto il lato.
				draw_line(mid - along, mid + along, Color("#b08a4e"), SEAM, true)
				draw_line(mid - along, mid + along, Color("#e8b563"), 2.0, true)
			else:
				# Il muro: un lato chiuso si vede quanto un varco aperto. E
				# quando il varco c'e' da una parte sola — **una strada
				# interrotta** (D-511) — la strada che muore contro la roccia
				# la racconta il muro, che e' quello che si vede al tavolo.
				var wall: Vector2 = across.orthogonal() * (_radius * 0.5)
				draw_line(mid - wall, mid + wall, Color("#0b0a08"), SEAM - 2.0, true)
				draw_line(mid - wall, mid + wall, Color("#5a2f27"), 3.0, true)


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
	# **Sul tavolo la tessera e' un esagono** (D-512). D-279 l'aveva fatta
	# quadrata, e la ragione era giusta allora: la mappa era un 3x2 di cartoni
	# quadrati, e ritagliare a esagono avrebbe nascosto meta' del quadro. Da
	# D-510 il cartone e' esagonale davvero, e lo schermo deve dire quello che
	# dice il tavolo — con dei quadrati messi a rosa direbbe un'altra cosa.
	if _hex:
		_draw_hex_tile(region_id, centre, control, offered)
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
func _draw_hex_tile(
	region_id: String, centre: Vector2, control: Variant, offered: bool
) -> void:
	var definition: Dictionary = _session.data.regions[region_id]
	var half: float = _radius
	# La fuga fra due cartoni: l'esagono si disegna un filo piu' piccolo del
	# passo della posa, cosi' fra due tessere si vede il lato che si toccano.
	var shape: PackedVector2Array = _hex_points(centre, half - SEAM * 0.25)
	var box: Rect2 = Rect2(centre - Vector2(half, half), Vector2(half, half) * 2.0)
	var lift: float = 0.0
	if offered:
		lift += 0.10
	if _hovered == region_id or _landing == region_id:
		lift += 0.12

	var painted: Texture2D = ArtLibrary.texture(str(definition.get("art_prompt_key", "")))
	if painted != null:
		# Il quadro **ritagliato dentro l'esagono**: le coordinate della
		# tessitura si prendono dal riquadro che lo contiene, cosi' l'immagine
		# resta intera e a essere tagliati sono solo i sei angoli — che sul
		# cartone la fustella toglie comunque.
		var uv: PackedVector2Array = PackedVector2Array()
		for p in shape:
			uv.append((p - box.position) / box.size)
		draw_colored_polygon(shape, Color(1, 1, 1).lightened(lift), uv, painted)
	else:
		var art: Dictionary = RegionArt.plan(region_id, str(definition["biome"]))
		draw_colored_polygon(shape, Color(str(art["ground"])).lightened(lift))
		_draw_terrain_strokes(art, box.grow(-half * 0.20), lift)
	# Il centro resta calmo: un velo sotto i segnalini, perche' un pezzo chiaro
	# su un campo chiaro sparisce.
	draw_circle(centre, half * 0.52, Color(0.07, 0.06, 0.05, 0.28))

	# Il bordo: chi tiene il posto, sulla sagoma vera e non su un rettangolo.
	var ring: Color = Color("#2a241c")
	var width: float = 2.0
	if control != null:
		ring = _entity_colour(str(control))
		width = 4.0
	_draw_hex_outline(shape, ring, width)
	if offered:
		var lit: bool = _hovered == region_id or _landing == region_id
		_draw_hex_outline(
			_hex_points(centre, half - SEAM * 0.25 - 4.0),
			Color("#e8b563") if lit else Color("#7a6338"), 3.0 if lit else 2.0
		)

	# Il nome sta **dentro** la tessera, in basso, ed e' un nodo (D-444): qui
	# resta solo la fascia scura che lo stacca dal quadro. In basso l'esagono e'
	# largo quanto un lato, non quanto la tessera: una fascia larga come prima
	# uscirebbe dai due angoli.
	var band_y: float = half * SQRT3 * 0.5 - 26.0
	var band_half: float = _hex_half_width(band_y, half) - 4.0
	draw_rect(
		Rect2(centre + Vector2(-band_half, band_y), Vector2(band_half * 2.0, 22.0)),
		Color(0.05, 0.04, 0.03, 0.62), true
	)

	_draw_echo(centre, region_id)
	_draw_presence(centre, region_id)
	_draw_slots(centre, region_id, _session.world["regions"][region_id])


## Il contorno di una sagoma chiusa. `draw_polyline` lascia aperto l'ultimo
## lato, e un esagono con un lato mancante si legge come un difetto.
func _draw_hex_outline(shape: PackedVector2Array, tint: Color, width: float) -> void:
	for i in range(shape.size()):
		draw_line(shape[i], shape[(i + 1) % shape.size()], tint, width, true)


## **Gli spazi della tessera** (D-464, parola del committente). Ogni tessera
## ha, sul lato esterno del tavolo — sopra se sta nella riga alta, sotto se
## sta in quella bassa — **sei spazi** per i segnalini di stato della
## Regione, tre a sinistra e tre a destra; e dentro, sopra il nome, **quattro
## spazi quadrati** per le Pietre e **tre tondi** per le Cicatrici. Uno spazio
## vuoto si vede: e' la casella stampata sul cartone, e dice quanto ci sta.
func _draw_slots(centre: Vector2, region_id: String, region: Dictionary) -> void:
	var data: RefCounted = _session.data if _session != null else null
	var half: float = _radius
	# **La striscia sta dalla parte di fuori** (D-464, portata alla rosa da
	# D-512). Col 3x2 «fuori» voleva dire sopra la riga alta e sotto la riga
	# bassa; sulla rosa vuol dire dalla parte opposta al centro del tavolo — e
	# per la capitale, che al centro ci sta, vuol dire sotto.
	var alto: bool = centre.y < _rose_centre().y - 1.0
	var mezza: float = half * SQRT3 * 0.5
	var outer_y: float = (
		centre.y - mezza - SLOT_GAP - SLOT * 0.5 if alto
		else centre.y + mezza + SLOT_GAP + SLOT * 0.5
	)

	var conditions: Array = []
	var scars: Array = []
	for tag in region["tags"]:
		var text: String = str(tag)
		if text.begins_with("condition:"):
			conditions.append(text)
		elif text.begins_with("scar:"):
			scars.append(text)
	conditions.sort()
	scars.sort()

	# La striscia dei sei spazi: tre da un lato, tre dall'altro, con un vuoto
	# in mezzo che e' il posto della pedina di controllo.
	var pitch: float = SLOT + SLOT_GAP
	var xs: Array = []
	for i in range(3):
		xs.append(centre.x - half + SLOT * 0.5 + 4.0 + float(i) * pitch)
	for i in range(3):
		xs.append(centre.x + half - SLOT * 0.5 - 4.0 - float(2 - i) * pitch)
	for i in range(xs.size()):
		var at: Vector2 = Vector2(float(xs[i]), outer_y)
		var box: Rect2 = Rect2(at - Vector2(SLOT, SLOT) * 0.5, Vector2(SLOT, SLOT))
		draw_rect(box, Color("#14110e"), true)
		draw_rect(box, Color("#3a332a"), false, 1.0)
		if i < conditions.size():
			_draw_token(str(conditions[i]), box, data)

	# Dentro la tessera, sopra il nome: le Pietre (quadrati) e le Cicatrici
	# (tondi). Sulla rosa la riga si tiene alla **larghezza vera dell'esagono a
	# quell'altezza**: con la mezza larghezza del centro i pezzi di bordo
	# finirebbero fuori dal cartone, dove la fustella non ha lasciato niente.
	var inner_y: float = centre.y + mezza - 26.0 - SLOT_GAP - SLOT * 0.5
	if not _hex:
		inner_y = centre.y + half - 24.0 - SLOT_GAP - SLOT * 0.5
	var inner_half: float = _hex_half_width(inner_y - centre.y, half) if _hex else half
	var stones: Array = []
	for record in region.get("structures", []):
		stones.append(record as Dictionary)
	for i in range(STONE_SLOTS):
		var at: Vector2 = Vector2(centre.x - inner_half + 4.0 + SLOT * 0.5 + float(i) * pitch, inner_y)
		var box: Rect2 = Rect2(at - Vector2(SLOT, SLOT) * 0.5, Vector2(SLOT, SLOT))
		draw_rect(box, Color(0.08, 0.07, 0.05, 0.85), true)
		draw_rect(box, Color("#4a4238"), false, 1.0)
		if i < stones.size():
			_draw_stone(stones[i] as Dictionary, box, data)
	for i in range(SCAR_SLOTS):
		var at: Vector2 = Vector2(centre.x + inner_half - 4.0 - SLOT * 0.5 - float(SCAR_SLOTS - 1 - i) * pitch, inner_y)
		draw_circle(at, SLOT * 0.5, Color(0.08, 0.07, 0.05, 0.85))
		draw_arc(at, SLOT * 0.5, 0.0, TAU, 20, Color("#4a4238"), 1.0, true)
		if i < scars.size():
			_draw_token(str(scars[i]), Rect2(at - Vector2(SLOT, SLOT) * 0.5, Vector2(SLOT, SLOT)), data)


## Il centro della rosa: la media delle tessere poste. Serve a una cosa sola —
## sapere da che parte e' **fuori**, per ogni tessera.
func _rose_centre() -> Vector2:
	if _points.is_empty():
		return size * 0.5
	var sum: Vector2 = Vector2.ZERO
	for region_id in _points:
		sum += _points[region_id] as Vector2
	return sum / float(_points.size())


## Un segnalino di condizione o di Cicatrice nel suo spazio.
func _draw_token(tag: String, box: Rect2, data: RefCounted) -> void:
	var piece: String = SignLabels.piece(tag, data)
	if piece == "":
		return
	var tint: Color = Color(str(PIECE_COLOURS.get(piece, "#8a8172")))
	draw_circle(box.get_center(), SLOT * 0.5 - 1.0, Color("#16130f"))
	draw_arc(box.get_center(), SLOT * 0.5 - 1.0, 0.0, TAU, 20, tint, 1.4, true)
	Glyph.paint(self, piece, box.grow(-4.0), tint)


## Una Pietra nel suo spazio quadrato, col colore di chi la tiene e i punti
## del grado.
func _draw_stone(stone: Dictionary, box: Rect2, data: RefCounted) -> void:
	var kind: String = str(stone.get("structure_type", ""))
	var family: String = SignLabels.family_of(kind, data)
	if family == "":
		return
	var holder: Variant = stone.get("owner", null)
	var tint: Color = (
		_entity_colour(str(holder)) if holder != null
		else Color(str(PIECE_COLOURS.get(family, "#a8a294")))
	)
	draw_rect(box, Color("#16130f"), true)
	draw_rect(box, tint, false, 1.4)
	Glyph.paint(self, family, box.grow(-4.0), tint)
	var grade: int = int(stone.get("grade", 1))
	if grade > 1:
		var pips: float = float(grade) * 5.0 - 1.5
		for pip in range(grade):
			draw_circle(
				Vector2(box.get_center().x - pips * 0.5 + float(pip) * 5.0 + 1.5, box.end.y - 3.0),
				1.8, tint
			)


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

