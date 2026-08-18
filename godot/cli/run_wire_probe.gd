extends SceneTree
## La sonda del filo (voce 27, fase 2 — D-135): la stessa partita due volte,
## una senza rete e una con due console WebSocket vere su localhost. Le
## decisioni dei due seggi umani vengono dalla stessa formula pura
## (`scripted_io.pick`), quindi ogni differenza fra le due partite sarebbe
## colpa del filo — e il «fatto quando» della fase 2 e' che non ce ne sia
## nessuna: salvataggio e verbale identici byte per byte.
##
##   godot --headless --path godot --script res://cli/run_wire_probe.gd -- \
##       --seed=7000 --chronicle=CHR_01 --port=8137

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ScriptedIO := preload("res://scripts/net/scripted_io.gd")
const ConsoleHost := preload("res://scripts/net/console_host.gd")
const ProbeClient := preload("res://scripts/net/console_probe_client.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var seed_value: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var port: int = int(options.get("port", 8137))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return
	var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
	var humans: Array = [str(seats[0]), str(seats[1])]

	# La partita senza rete: gli io copione rispondono in casa.
	var local: RefCounted = GameSession.new(data)
	local.setup(chronicle_id, seats, seed_value)
	var local_decider: RefCounted = SeatDecider.new(humans, local.log)
	local_decider.ios = {
		humans[0]: ScriptedIO.new(seed_value + 1),
		humans[1]: ScriptedIO.new(seed_value + 2),
	}
	await local.run(local_decider)

	# La stessa partita col filo: host WebSocket, due console simulate.
	var remote: RefCounted = GameSession.new(data)
	remote.setup(chronicle_id, seats, seed_value)
	var host: RefCounted = ConsoleHost.new(remote)
	var tokens: Dictionary = host.open(port, humans, seed_value)
	var remote_decider: RefCounted = SeatDecider.new(humans, remote.log)
	remote_decider.ios = {
		humans[0]: host.io_for(humans[0]),
		humans[1]: host.io_for(humans[1]),
	}
	var url: String = "ws://127.0.0.1:%d" % port
	var consoles: Array = [
		ProbeClient.new(url, str(tokens[humans[0]]), seed_value + 1),
		ProbeClient.new(url, str(tokens[humans[1]]), seed_value + 2),
	]

	var finished: Array = [false]
	_run_remote(remote, remote_decider, finished)
	var turns: int = 0
	while not finished[0]:
		host.poll()
		for console in consoles:
			console.poll()
		turns += 1
		if turns > 200000:
			printerr("IL FILO SI E' INCEPPATO: la partita remota non finisce.")
			quit(1)
			return
		await process_frame
	for console in consoles:
		console.close()
	host.close()

	var answered: int = 0
	var received: int = 0
	for console in consoles:
		answered += int(console.answered)
		received += int(console.received)

	print("")
	print("== LA SONDA DEL FILO - %s, seme %d ==" % [chronicle_id, seed_value])
	print("  Messaggi alle console: %d   risposte dai telefoni: %d" % [received, answered])
	var same_save: bool = (
		JSON.stringify(local.to_save()) == JSON.stringify(remote.to_save())
	)
	var same_log: bool = local.log.text() == remote.log.text()
	if same_save and same_log:
		print("  IL FILO E' TRASPARENTE: salvataggio e verbale identici byte per byte.")
		quit(0)
		return
	if not same_save:
		printerr("  IL SALVATAGGIO DIFFERISCE: il filo ha toccato la partita.")
	if not same_log:
		printerr("  IL VERBALE DIFFERISCE: il filo ha toccato la partita.")
	quit(1)


func _run_remote(session: RefCounted, decider: RefCounted, finished: Array) -> void:
	await session.run(decider)
	finished[0] = true


func _parse_args(args: Array) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if text.begins_with("--") and text.contains("="):
			var parts: PackedStringArray = text.substr(2).split("=", true, 1)
			out[str(parts[0])] = str(parts[1])
	return out
