extends Control
## La stanza (voce 27, fase 3 — D-136): il computer apre la porta, l'iPad
## apre la vetrina nel browser, i telefoni le console. Questa scena fa tre
## cose e basta: mostra gli indirizzi da digitare, dice chi e' collegato, e
## quando il tavolo e' pronto avvia la Chronicle con le console come io.
##
## Chi ha una console collegata al via e' umano; chi non ce l'ha e' una
## policy - la connessione decide, senza altre domande. Durante la partita
## lo schermo del computer e' la vetrina (o si spegne: la vera vetrina puo'
## essere l'iPad sulla pagina /tavolo), con la diagnosi onesta della rete
## («la console di X non risponde») e il bottone che rigenera un codice.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ConsoleHost := preload("res://scripts/net/console_host.gd")
const TableView := preload("res://ui/table_view.gd")

const WS_PORT: int = 8137
const HTTP_PORT: int = 8123
const QUIET_AFTER_MSEC: int = 20000

var _data: RefCounted = null
var _session: RefCounted = null
var _host: RefCounted = null
var _tokens: Dictionary = {}
var _seats: Array = []
var _running: bool = false
var _table: Control = null
var _rows: Dictionary = {}      # seat -> Label di stato
var _lobby_box: VBoxContainer = null
var _strip: HBoxContainer = null
var _clock_shown: int = -1


func _ready() -> void:
	_data = DataSet.new()
	if not _data.load_from("res://data"):
		var sorry := Label.new()
		sorry.text = "I dati non si caricano."
		add_child(sorry)
		return
	_ask_chronicle()


func _process(_delta: float) -> void:
	if _host == null:
		return
	_host.poll()
	_refresh_statuses()
	if _running and _table != null and _session != null:
		var clock: int = int(_session.world.get("effect_sequence", 0))
		if clock != _clock_shown:
			_clock_shown = clock
			_table.render(_session)


# --- il vestibolo -----------------------------------------------------------

func _ask_chronicle() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	var title := Label.new()
	title.text = "La stanza — quale anno si gioca?"
	title.add_theme_font_size_override("font_size", 20)
	box.add_child(title)
	var ids: Array = _data.chronicles.keys()
	ids.sort()
	for chronicle_id in ids:
		var chronicle: Dictionary = _data.chronicles[str(chronicle_id)]
		# Gli anni-biblioteca pescano le domande e vivono dentro una saga:
		# la serata al tavolo comincia da un anno scritto.
		if typeof(chronicle.get("years_after_previous", 1)) == TYPE_DICTIONARY:
			continue
		var button := Button.new()
		button.text = "%s — anno %d" % [str(chronicle["title"]), int(chronicle["start_year"])]
		button.pressed.connect(_open_room.bind(str(chronicle_id), box))
		box.add_child(button)


func _open_room(chronicle_id: String, vestibule: Control) -> void:
	vestibule.queue_free()
	_seats = (_data.chronicles[chronicle_id]["entities"] as Array).duplicate()
	_session = GameSession.new(_data)
	var seed_value: int = int(Time.get_unix_time_from_system()) % 100000
	_session.setup(chronicle_id, _seats, seed_value)
	_host = ConsoleHost.new(_session)
	_tokens = _host.open(WS_PORT, _seats, seed_value * 7 + 3)
	var served: bool = _host.serve_pages(HTTP_PORT)

	_lobby_box = VBoxContainer.new()
	_lobby_box.set_anchors_preset(Control.PRESET_CENTER)
	_lobby_box.add_theme_constant_override("separation", 10)
	add_child(_lobby_box)

	var address: String = ConsoleHost.local_address()
	var head := Label.new()
	head.text = "La stanza è aperta — seme %d" % seed_value
	head.add_theme_font_size_override("font_size", 22)
	_lobby_box.add_child(head)
	var table_line := Label.new()
	table_line.text = (
		"La vetrina (iPad o secondo schermo):  http://%s:%d/tavolo" % [address, HTTP_PORT]
		if served else "La porta %d è occupata: chiudi l'altra stanza e riapri." % HTTP_PORT
	)
	table_line.add_theme_font_size_override("font_size", 16)
	_lobby_box.add_child(table_line)

	for seat in _seats:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var who := Label.new()
		who.text = _session.service.name_of(str(seat))
		who.custom_minimum_size = Vector2(220, 0)
		who.add_theme_font_size_override("font_size", 16)
		row.add_child(who)
		var link := Label.new()
		link.text = "http://%s:%d/?t=%s" % [address, HTTP_PORT, str(_tokens[str(seat)])]
		link.add_theme_font_size_override("font_size", 15)
		link.add_theme_color_override("font_color", Color("#e8b563"))
		row.add_child(link)
		var status := Label.new()
		status.text = "in attesa"
		status.add_theme_font_size_override("font_size", 14)
		row.add_child(status)
		_rows[str(seat)] = {"status": status, "link": link}
		var reissue := Button.new()
		reissue.text = "Rigenera il codice"
		reissue.pressed.connect(_reissue.bind(str(seat)))
		row.add_child(reissue)
		_lobby_box.add_child(row)

	var hint := Label.new()
	hint.text = "Chi è collegato al via gioca dal telefono; gli altri seggi giocano da soli."
	hint.add_theme_color_override("font_color", Color("#8a8172"))
	_lobby_box.add_child(hint)
	var go := Button.new()
	go.text = "Si comincia"
	go.pressed.connect(_start)
	_lobby_box.add_child(go)


func _reissue(seat: String) -> void:
	var fresh: String = _host.reissue(seat, randi())
	_tokens[seat] = fresh
	if _rows.has(seat) and not _running:
		(_rows[seat]["link"] as Label).text = "http://%s:%d/?t=%s" % [
			ConsoleHost.local_address(), HTTP_PORT, fresh
		]


# --- la partita -------------------------------------------------------------

func _start() -> void:
	if _running:
		return
	var humans: Array = []
	for seat in _seats:
		if _host.connected(str(seat)):
			humans.append(str(seat))
	var decider: RefCounted = SeatDecider.new(humans, _session.log)
	for seat in humans:
		decider.ios[str(seat)] = _host.io_for(str(seat))
	_lobby_box.queue_free()

	_table = TableView.new()
	_table.set_anchors_preset(Control.PRESET_FULL_RECT)
	_table.offset_top = 34.0
	add_child(_table)
	_strip = HBoxContainer.new()
	_strip.add_theme_constant_override("separation", 18)
	add_child(_strip)
	_rows.clear()
	for seat in humans:
		var status := Label.new()
		status.add_theme_font_size_override("font_size", 13)
		_strip.add_child(status)
		_rows[str(seat)] = {"status": status}

	_running = true
	_run(decider)


func _run(decider: RefCounted) -> void:
	await _session.run(decider)
	_running = false
	var done := Label.new()
	done.text = "La Chronicle è chiusa: il verbale qui sotto racconta com'è finita."
	done.add_theme_font_size_override("font_size", 16)
	done.add_theme_color_override("font_color", Color("#e8b563"))
	_strip.add_child(done)


func _refresh_statuses() -> void:
	for seat in _rows.keys():
		var status: Label = (_rows[seat] as Dictionary)["status"]
		var name: String = _session.service.name_of(str(seat))
		if not _host.connected(str(seat)):
			status.text = "%s: console assente" % name if _running else "in attesa"
			status.add_theme_color_override("font_color", Color("#c8553d"))
			continue
		var silence: int = int(_host.silence_of(str(seat)))
		if silence > QUIET_AFTER_MSEC:
			status.text = "%s: non risponde da %ds" % [name, silence / 1000]
			status.add_theme_color_override("font_color", Color("#c8553d"))
		else:
			status.text = "%s: al tavolo" % name if _running else "collegato"
			status.add_theme_color_override("font_color", Color("#6fa88a"))
