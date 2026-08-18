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
const SaveSerializer := preload("res://scripts/core/save_serializer.gd")
const DevDashboard := preload("res://ui/dev_dashboard.gd")
const ExportPreview := preload("res://ui/export_preview.gd")
const ChronicleBookView := preload("res://ui/chronicle_book_view.gd")
const EchoCardView := preload("res://ui/echo_card_view.gd")
const LogExport := preload("res://scripts/core/log_export.gd")

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
## E quale Chronicle era, e in che anno: il log si scarica quasi sempre a partita
## finita, quando la sessione non c'e' piu'.
var _last_chronicle: String = ""
var _last_year: int = 0
## The Act-end Echo card waiting to be looked at, and what it did.
var _echo: PanelContainer
var _pending_echo: Dictionary = {}
## The map and the Council share the middle of the screen: one is visible at a
## time, because they answer different questions and a player looking at a
## Council is not choosing where to walk.
var _centre: Control
## Il cruscotto per chi sviluppa, e se e aperto adesso.
var _dev: PanelContainer
var _dev_open: bool = false
var _dev_button: Button
## Il tasto che porta via la cronaca. Sta accanto al cruscotto perche' i due
## servono alla stessa persona nello stesso momento: quella che ha finito di
## giocare e vuole rileggere.
var _log_button: Button
var _save_button: Button
## L'anteprima di stampa. Non guarda la partita - guarda i dati - quindi si apre
## anche dal menu, prima che una Chronicle esista.
var _export: PanelContainer
var _export_open: bool = false

## La cronaca dell'anno (voce 10, D-086): il salvataggio dell'ultima Chronicle
## finita, tenuto perche' la sessione a quel punto e' gia' stata congedata -
## come `_last_seed`, e per la stessa ragione.
var _cronaca: PanelContainer
var _cronaca_open: bool = false
var _cronaca_button: Button
var _year_save: Dictionary = {}
## Gli anni della saga in corso, in ordine (D-096): la fila che il libro
## della saga impagina. Si azzera quando dal menu comincia una storia nuova.
var _saga_saves: Array = []
var _status: VBoxContainer
var _hand: HBoxContainer
## The seat the board is drawn for, and the Tension under discussion if any.
var _viewer: String = ""
var _focus_tension: String = ""


func _ready() -> void:
	_build()
	_menu()


## F3 apre e chiude il cruscotto, F4 l'anteprima di stampa. Con l'anteprima
## aperta, le frecce scorrono le carte.
##
## I tasti restano, ma non sono piu' l'unica strada: **su un tablet non esiste un
## F3 da premere**, e la prima partita giocata su iPad ha trovato il cruscotto
## irraggiungibile. Il ragionamento che lo teneva dietro un tasto - mostra quello
## che al tavolo e' coperto, non e' una cosa da premere per curiosita' - vale
## contro un bottone *dentro* il flusso delle scelte, non contro uno in fondo
## alla colonna, accanto alle regole, che si preme apposta (D-062).
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.is_echo():
		return
	var key: int = (event as InputEventKey).keycode
	if _export_open and (key == KEY_LEFT or key == KEY_RIGHT):
		_export.step(1 if key == KEY_RIGHT else -1)
		get_viewport().set_input_as_handled()
		return
	if _cronaca_open and (key == KEY_LEFT or key == KEY_RIGHT):
		_cronaca.step(1 if key == KEY_RIGHT else -1)
		get_viewport().set_input_as_handled()
		return
	if key != KEY_F3 and key != KEY_F4:
		return
	if key == KEY_F3:
		_toggle_dev(not _dev_open)
	else:
		_toggle_export(not _export_open)
	get_viewport().set_input_as_handled()


## Il cruscotto (§25.14). Un solo posto che lo apre e lo chiude, che sia venuto
## da F3 o dal bottone: due strade che scrivono lo stesso stato si disallineano
## il giorno in cui una delle due cambia.
func _toggle_dev(open: bool) -> void:
	# Il cruscotto guarda una partita: senza sessione non ha niente da mostrare,
	# e un pannello vuoto e' peggio di un tasto spento.
	_dev_open = open and _session != null
	if _dev_open:
		_toggle_export(false)
		_toggle_cronaca(false)
		_help_button.button_pressed = false
	if _dev_button != null:
		_dev_button.set_pressed_no_signal(_dev_open)
	_dev.visible = _dev_open
	if _dev_open:
		_dev.render(_session)
	_refresh()


func _toggle_export(open: bool) -> void:
	_export_open = open
	if _export_open:
		_dev_open = false
		if _dev_button != null:
			_dev_button.set_pressed_no_signal(false)
		_toggle_cronaca(false)
		_help_button.button_pressed = false
	# L'anteprima legge i dati, non il mondo: da sola sa disegnarsi anche quando
	# non c'e' nessuna Chronicle, ed e' li' che serve di piu' - si corregge un
	# mazzo prima di sedersi, non durante.
	_export.visible = _export_open
	if _export_open:
		_export.render(_load_help_data())
	_refresh()


## La cronaca dell'anno finito (voce 10, D-086): le stesse pagine che il
## Chronicle Book stampera', rasterizzate. Si apre da sola a fine Chronicle e
## resta dietro il suo bottone finche' un'altra partita non la sostituisce.
func _toggle_cronaca(open: bool) -> void:
	# L'anno in corso conta se ha gia' scritto almeno una Truth: la cronaca a
	# meta' anno e' il registro fin qui, impaginato come lo sara' a fine anno.
	var live: Dictionary = {}
	if _year_save.is_empty() and _session != null \
			and not (_session.world["truth_log"] as Array).is_empty():
		live = _session.to_save("cronaca")
	_cronaca_open = open and (not _year_save.is_empty() or not live.is_empty())
	if _cronaca_open:
		_dev_open = false
		if _dev_button != null:
			_dev_button.set_pressed_no_signal(false)
		_export_open = false
		_export.visible = false
		_help_button.button_pressed = false
		# Con piu' anni in fila e' il libro della saga (D-096): la Timeline in
		# apertura, poi la cronaca di ogni anno. Con uno solo, quello di sempre.
		if _saga_saves.size() > 1:
			_cronaca.show_saga(_saga_saves, _load_help_data())
		elif not live.is_empty():
			_cronaca.show_year(live, _load_help_data())
		else:
			_cronaca.show_year(_year_save, _load_help_data())
	if _cronaca_button != null:
		_cronaca_button.set_pressed_no_signal(_cronaca_open)
	_cronaca.visible = _cronaca_open
	_dev.visible = _dev_open
	_refresh()


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

	# Il cruscotto (§25.14): stessa meta' di schermo di mappa, Consiglio e regole,
	# perche' chi lo sta leggendo non sta guardando il tavolo. Sta dietro F3 e non
	# dietro un bottone: mostra anche quello che al tavolo e coperto, e non e una
	# cosa da premere per curiosita' in mezzo a una partita.
	_dev = DevDashboard.new()
	_dev.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dev.visible = false
	_centre.add_child(_dev)

	# E l'anteprima di stampa (§25.15), stessa meta' di schermo: e' l'altra cosa
	# che si guarda invece di guardare il tavolo.
	_export = ExportPreview.new()
	_export.set_anchors_preset(Control.PRESET_FULL_RECT)
	_export.visible = false
	_centre.add_child(_export)

	# E la cronaca dell'anno finito (voce 10), stessa meta' di schermo.
	_cronaca = ChronicleBookView.new()
	_cronaca.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cronaca.visible = false
	_centre.add_child(_cronaca)

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

	# Fuori dal flusso delle scelte e in fondo alla colonna: due cose che non si
	# fanno *durante* una decisione, ma che devono essere raggiungibili senza una
	# tastiera. Piccole, e in una riga sola, perche' non competono con la partita.
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 5)
	right.add_child(tools)

	_dev_button = Button.new()
	_dev_button.text = "Cruscotto"
	_dev_button.tooltip_text = "Quello che al tavolo e coperto (anche F3)"
	_dev_button.toggle_mode = true
	_dev_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dev_button.add_theme_font_size_override("font_size", 12)
	_dev_button.toggled.connect(_toggle_dev)
	tools.add_child(_dev_button)

	_cronaca_button = Button.new()
	_cronaca_button.text = "La cronaca"
	_cronaca_button.tooltip_text = "Le pagine dell'anno finito, come le stampera' il Chronicle Book"
	_cronaca_button.toggle_mode = true
	_cronaca_button.disabled = true
	_cronaca_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cronaca_button.add_theme_font_size_override("font_size", 12)
	_cronaca_button.toggled.connect(_toggle_cronaca)
	tools.add_child(_cronaca_button)

	_log_button = Button.new()
	_log_button.text = "Scarica il log"
	_log_button.tooltip_text = "Tutta la cronaca di questa sessione, in un file di testo"
	_log_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_log_button.add_theme_font_size_override("font_size", 12)
	_log_button.pressed.connect(_on_log_pressed)
	tools.add_child(_log_button)

	# La voce 12 (D-092): il salvataggio si porta via come il log. Nel browser
	# e' l'unica rete quando lo storage non c'e'; altrove e' una copia in piu'.
	_save_button = Button.new()
	_save_button.text = "Scarica il salvataggio"
	_save_button.tooltip_text = "La partita in corso come file JSON, da tenere o riportare"
	_save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_save_button.add_theme_font_size_override("font_size", 12)
	_save_button.pressed.connect(_on_save_pressed)
	tools.add_child(_save_button)

	_hand = HandView.new()
	_hand.custom_minimum_size = Vector2(0, 140)
	rows.add_child(_hand)

	_help.render(_load_help_data())


## Redraw the board from the world. Called after every phase and before every
## question, because a player choosing an action must be looking at the state
## the action will apply to - not the state of the last screenshot.
func _refresh() -> void:
	_tools_state()
	if _session == null:
		return
	# Il cruscotto sta davanti a tutto quando e aperto: chi lo guarda non sta
	# guardando il tavolo, ed e per questo che occupa la stessa meta di schermo.
	_dev.visible = _dev_open
	_export.visible = _export_open
	if _dev_open:
		_dev.render(_session)
	var council_open: bool = _session.confluence.is_open()
	var busy: bool = _help.visible or _echo.visible or _dev_open or _export_open or _cronaca_open
	_board.visible = council_open and not busy
	_map.visible = not council_open and not busy
	if council_open:
		_board.render(_session, _viewer)
	_map.render(_session, _viewer)
	_status.render(_session, _viewer)
	_hand.render(_session, _viewer, _focus_tension)
	_context.text = _context_line()


## Lo stato dei due tasti in fondo alla colonna. Sta fuori dal corpo di
## `_refresh()` perche' quello esce subito quando non c'e' una sessione - ed e'
## esattamente li', a Chronicle finita e col registro delle Truth sullo schermo,
## che qualcuno preme «Scarica il log».
func _tools_state() -> void:
	if _dev_button == null:
		return
	_dev_button.disabled = _session == null
	if _session == null and _dev_open:
		_toggle_dev(false)
	if _cronaca_button != null:
		# La cronaca si legge anche a meta' anno (l'inventario dell'app): appena
		# c'e' una Truth scritta, le pagine esistono e si possono sfogliare.
		_cronaca_button.disabled = _year_save.is_empty() and (
			_session == null or (_session.world["truth_log"] as Array).is_empty()
		)


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
	if pressed:
		_dev_open = false
		_export_open = false
		_export.visible = false
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
## L'intero log, cioe' esattamente quello che si legge nella colonna di sinistra:
## non le sole righe del `GameLog`, ma anche il menu, le domande fatte a chi
## gioca e le sue risposte. Chi rilegge vuole la sessione, non il sottoinsieme
## che il motore considera pubblico.
func _on_log_pressed() -> void:
	var chronicle_id: String = _last_chronicle
	var year: int = _last_year
	if _session != null:
		chronicle_id = str(_session.world.get("chronicle_id", chronicle_id))
		year = int(_session.world.get("year", year))
	var title: String = ""
	var data: RefCounted = _load_help_data()
	if data != null and data.chronicles.has(chronicle_id):
		title = str(data.chronicles[chronicle_id]["title"])
	var text: String = (
		LogExport.header(title, year, _last_seed, Time.get_datetime_string_from_system(false, true))
		+ _transcript.get_parsed_text()
	)
	var said: String = LogExport.deliver(text, LogExport.file_name(chronicle_id, _last_seed))
	_hint.text = said if said != "" else "Non c'e ancora niente da scaricare."


## Il salvataggio come file (voce 12, D-092). La partita in corso se c'e', o
## l'anno appena finito; per la stessa via del log, con il MIME del JSON.
func _on_save_pressed() -> void:
	var save: Dictionary = {}
	if _session != null:
		save = _session.to_save("download")
	elif not _year_save.is_empty():
		save = _year_save
	if save.is_empty():
		_hint.text = "Non c'e ancora una partita da salvare."
		return
	var world: Dictionary = save.get("world_state", {})
	var said: String = LogExport.deliver(
		SaveSerializer.to_json(save),
		SaveSerializer.download_name(
			str(world.get("chronicle_id", "")), int(world.get("rng_seed", -1))
		),
		"application/json"
	)
	_hint.text = said if said != "" else "Non c'e ancora una partita da salvare."


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
	# La voce 12 (D-092): se il salvataggio vive in un browser, la schermata lo
	# dice prima di cominciare - non dopo, quando la scheda chiusa l'ha gia'
	# perso. Una partita persa in silenzio e' il difetto; la frase e' il fix.
	if OS.has_feature("web"):
		if OS.is_userfs_persistent():
			say("I salvataggi restano in questo browser. Con «Scarica il salvataggio»")
			say("puoi comunque portartene via una copia quando vuoi.")
		else:
			say("[color=#c8553d]Questo browser non tiene i salvataggi[/color] (navigazione privata")
			say("o storage bloccato): chiusa la scheda, la partita sparisce. Usa «Scarica")
			say("il salvataggio» per portartela via prima di chiudere.")
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
		if await _offer_to_resume():
			continue
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


## An interrupted Chronicle, if there is one (D-052).
##
## The save has existed and been tested since 0.0 and nothing on screen ever
## called it, which is the open line this closes. What was missing was not the
## file: it was somewhere to come back *to*. `run()` now starts from the Act and
## round the world is on, so a save taken at the close of a round is a place to
## stand.
func _offer_to_resume() -> bool:
	# In un browser `user://` sta in IndexedDB, e non e detto che ci sia: in
	# navigazione privata, o con lo storage bloccato, Godot lo segnala e quello
	# che si scrive sparisce alla chiusura della scheda. Offrire una ripresa che
	# non ci sara e peggio che non offrirla.
	if not OS.is_userfs_persistent():
		return false
	var save: Dictionary = SaveSerializer.read(SaveManager.save_path("autosave"))
	if save.is_empty():
		return false
	var world: Dictionary = save.get("world_state", {})
	var chronicle_id: String = str(world.get("chronicle_id", ""))
	var data: RefCounted = _load_help_data()
	if data == null or not data.chronicles.has(chronicle_id):
		return false
	# A Chronicle that ran to the end is not something to resume into.
	if int(world.get("act", 0)) <= 0:
		return false

	var choice: int = await ask(
		"C'e un anno lasciato a meta.",
		[
			"Riprendi %s, atto %d round %d" % [
				str(data.chronicles[chronicle_id]["title"]),
				int(world.get("act", 1)), int(world.get("round", 1)),
			],
			"Lascia perdere e comincia un anno nuovo",
		]
	)
	if choice != 0:
		return false
	await _resume(chronicle_id)
	return true


func _resume(chronicle_id: String) -> void:
	if _busy:
		return
	_busy = true
	_transcript.clear()
	# Una storia nuova azzera la fila della saga (D-096): il libro racconta
	# una saga alla volta.
	_saga_saves = []
	_help_button.button_pressed = false

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		_busy = false
		return
	_seats = _seats_of(chronicle_id)
	_session = GameSession.new(data)
	_session.setup(chronicle_id, _seats, 0)
	if not SaveManager.load_into(_session, "autosave"):
		say("[color=#c8553d]Il salvataggio non si e potuto rileggere.[/color]")
		_busy = false
		return
	_last_seed = int(_session.world["rng_seed"])
	_help.render(data, chronicle_id)
	await _drive(data, [], chronicle_id)


func _play(humans: Array, chronicle_id: String, seed_value: int) -> void:
	if _busy:
		return
	_busy = true
	_transcript.clear()
	# Una storia nuova azzera la fila della saga (D-096): il libro racconta
	# una saga alla volta.
	_saga_saves = []

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
	await _drive(data, humans, chronicle_id)


## Everything from "there is a session" to "the year is over". Split out of
## `_play` so a resumed Chronicle goes through exactly the same screen as a fresh
## one - the alternative was a second copy of it, and a second copy is where the
## two would stop agreeing (D-052).
func _drive(data: RefCounted, humans: Array, chronicle_id: String) -> void:
	_busy = true
	# Tenuti come `_last_seed`, e per la stessa ragione: a fine Chronicle la
	# sessione viene disposta, e il log si scarica proprio li' - a partita finita.
	# Senza questi il file uscirebbe senza nome e senza anno.
	_last_chronicle = chronicle_id
	_last_year = int(_session.world.get("year", 0))
	_help_button.button_pressed = false
	_dev.watch(_session)
	var shown: Dictionary = {"lines": 0}
	_session.chronicle.phase_changed.connect(
		func(_a: int, _r: int, phase: String) -> void:
			_flush(shown)
			_refresh()
			# Il punto di ripresa del motore e' l'inizio di un round (D-052), e
			# THRESHOLD_CHECK e' l'ultima cosa che succede dentro uno: salvare qui
			# vuol dire che riprendere costa al massimo il round in corso.
			if phase == "THRESHOLD_CHECK":
				SaveManager.autosave(_session)
	)
	# Held, not shown: the card is drawn deep inside the Act and the screen has
	# nowhere to suspend there. It is looked at at the next question, like the
	# closed Council.
	_session.chronicle.act_echo_drawn.connect(
		func(card: Dictionary, applied: Array) -> void:
			_pending_echo = {"card": card.duplicate(true), "applied": applied.duplicate(true)}
	)
	# L'eco del cambiamento (l'inventario dell'app): ogni effetto che tocca una
	# Regione accende un anello che sfuma li' dove e' successo. La mappa decide
	# da sola quale effetto tocca cosa; qui si passa soltanto il fatto.
	_session.effect_applied.connect(
		func(effect: Dictionary) -> void:
			_map.mark_changed(MapView.region_of_effect(effect))
	)

	say("[b]%s[/b] — anno %d, seme %d" % [
		str(data.chronicles[chronicle_id]["title"]), int(_session.world["year"]), _last_seed,
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
	# Il salvataggio si prende ADESSO: _ending congeda la sessione subito dopo,
	# e la cronaca deve poter restare sullo schermo a partita finita.
	_year_save = _session.to_save()
	_saga_saves.append(_year_save)
	_ending(data, report)

	# La saga continua da qui (D-095): quello che run_saga fa da sempre in
	# riga di comando, offerto a chi gioca. L'era dopo e' la biblioteca della
	# stessa eta', eredita il mondo e i risultati appena chiusi, e il seme
	# avanza dello stesso passo delle sonde - cosi' una saga giocata a mano e'
	# riproducibile come una simulata.
	var sequel: String = data.library_sequel_of(chronicle_id)
	if sequel != "":
		var choice: int = await ask(
			"L'anno e' chiuso, ma il mondo no. Il tempo passa.",
			[
				"Gioca l'era successiva — %s" % str(data.chronicles[sequel]["title"]),
				"Basta cosi: la saga si ferma qui",
			]
		)
		if choice == 0:
			var previous: Dictionary = (_session.world as Dictionary).duplicate(true)
			var results: Dictionary = (report["destiny_results"] as Dictionary).duplicate(true)
			_session.dispose()
			_toggle_cronaca(false)
			_session = GameSession.new(data)
			_last_seed = _last_seed + 97
			_seats = _seats_of(sequel)
			_session.setup(sequel, _seats, _last_seed)
			_session.inherit_from(previous, results)
			_help.render(data, sequel)
			say("")
			await _drive(data, humans, sequel)
			return

	_session.dispose()
	_session = null
	_busy = false
	_tools_state()


func _flush(shown: Dictionary) -> void:
	var lines: Array = _session.log.lines
	while int(shown["lines"]) < lines.size():
		say(str(lines[int(shown["lines"])]))
		shown["lines"] = int(shown["lines"]) + 1


func _ending(data: RefCounted, report: Dictionary) -> void:
	say("")
	say("== COM'È FINITA ==")
	_toggle_cronaca(true)
	for entity_id in _seats:
		var entry: Dictionary = report["destiny_results"][str(entity_id)]
		say("  %s — [b]%s[/b] %s" % [
			_session.service.name_of(str(entity_id)) if _session != null else str(data.entities[str(entity_id)]["name"]),
			str(entry["level"]), str(entry.get("label", "")),
		])
	# La rete della voce 12 (D-092), tesa nel momento in cui serve: un anno
	# finito in un browser senza storage e' un anno che sparisce con la scheda.
	if OS.has_feature("web") and not OS.is_userfs_persistent():
		say("")
		say("[color=#c8553d]Questo browser non tiene i salvataggi:[/color] scarica il log o il")
		say("salvataggio adesso, prima di chiudere la scheda.")
