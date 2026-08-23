extends SceneTree
## La sonda dei messaggi (voce 27, fase 2 — D-135): cento partite a tavolo
## misto con due seggi su console, e OGNI messaggio diretto a un telefono
## perquisito al momento dell'invio — quando i segreti sono vivi — con
## `console_protocol.audit`: nessuna carta di una mano altrui, nessun gradino
## di un Destino altrui, nessun numero di domanda coperta che il seggio non
## ha sbirciato. «Fatto quando» della fase 2: FUGHE: 0.
##
##   godot --headless --path godot --script res://cli/run_console_probe.gd -- \
##       --runs=100 --seed=7000
##
## Le decisioni vengono dall'io copione; i messaggi sono ESATTAMENTE quelli
## che ConsoleIO manderebbe (stato fresco prima di ogni domanda, il say, la
## domanda stessa), costruiti e perquisiti in sincrono: la sonda misura il
## contenuto, la trasparenza del trasporto la misura run_wire_probe.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ScriptedIO := preload("res://scripts/net/scripted_io.gd")
const Protocol := preload("res://scripts/net/console_protocol.gd")
const TableModel := preload("res://scripts/views/table_model.gd")


## L'io che gioca col copione e perquisisce ogni messaggio che partirebbe.
class AuditingIO:
	var session: RefCounted
	var seat_id: String
	var seed_value: int
	var asked: int = 0
	var sent: Array = [0]
	var leaks: Array
	## La vetrina la guarda uno solo dei due, o la conteremmo due volte: non e'
	## di nessun seggio, e' del tavolo (D-144).
	var watches_table: bool = false

	func _init(
		p_session: RefCounted, p_seat: String, p_seed: int, p_leaks: Array, p_sent: Array
	) -> void:
		session = p_session
		seat_id = p_seat
		seed_value = p_seed
		leaks = p_leaks
		sent = p_sent

	func _audit(message: Dictionary) -> void:
		sent[0] += 1
		for violation in Protocol.audit(message, session, seat_id):
			leaks.append("%s: %s" % [seat_id, str(violation)])

	## Come la console vera (D-143): il pannello a caratteri non le arriva, e la
	## sonda deve perquisire i messaggi che partono davvero, non quelli che
	## partivano prima.
	func shows_state() -> bool:
		return true

	func say(text: String) -> void:
		_audit(Protocol.say_message(session, text))

	## La vetrina, perquisita col metro del tavolo: quello che sta in una mano
	## non e' roba del tavolo, di nessun seggio, mai (D-144).
	func _audit_table() -> void:
		if not watches_table:
			return
		sent[0] += 1
		var message: Dictionary = {"kind": "table", "model": TableModel.build(session)}
		for violation in Protocol.audit_table(message, session):
			leaks.append("vetrina: %s" % str(violation))

	func choose(prompt: String, labels: Array, subjects: Array = []) -> int:
		asked += 1
		_audit_table()
		_audit(Protocol.state_message(session, seat_id))
		_audit(Protocol.choose_message(session, asked, prompt, labels, subjects))
		return ScriptedIO.pick(seed_value, asked, labels.size())


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var leaks: Array = []
	var sent: Array = [0]
	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		session.setup(chronicle_id, seats, seed_value)
		var humans: Array = [str(seats[0]), str(seats[1])]
		var decider: RefCounted = SeatDecider.new(humans, session.log)
		var first: RefCounted = AuditingIO.new(session, humans[0], seed_value + 1, leaks, sent)
		first.watches_table = true
		decider.ios = {
			humans[0]: first,
			humans[1]: AuditingIO.new(session, humans[1], seed_value + 2, leaks, sent),
		}
		await session.run(decider)
		session.dispose()
		# Il progresso, partita per partita: una sonda che tace per un'ora non
		# si distingue da una inceppata - e una volta lo e' stata davvero.
		print("  partita %d/%d (%s, seme %d): messaggi %d, fughe %d" % [
			index + 1, runs, chronicle_id, seed_value, sent[0], leaks.size()
		])

	print("")
	print("== LA SONDA DEI MESSAGGI - %d partite, semi da %d ==" % [runs, first_seed])
	print("  Messaggi perquisiti: %d" % sent[0])
	if leaks.is_empty():
		print("  FUGHE: 0. Sul filo di ogni console viaggia solo il suo seggio,")
		print("  e sulla vetrina solo quello che il tavolo ha gia' visto.")
		quit(0)
		return
	print("  FUGHE (%d) - un segreto sul filo sbagliato e' un bug:" % leaks.size())
	var shown: Dictionary = {}
	for leak in leaks:
		shown[str(leak)] = int(shown.get(str(leak), 0)) + 1
	for key in shown:
		print("    %s (×%d)" % [str(key), int(shown[key])])
	quit(1)


func _parse_args(args: Array) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if text.begins_with("--") and text.contains("="):
			var parts: PackedStringArray = text.substr(2).split("=", true, 1)
			out[str(parts[0])] = str(parts[1])
	return out
