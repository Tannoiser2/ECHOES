extends SceneTree
## La stanza senza schermo (voce 27 — D-142): l'host della stanza, il filo e le
## pagine, senza la scena Godot che li avvolge. Serve a due cose: provare la
## console da un altro apparecchio senza aprire una finestra, e fotografare
## quello che si vede sul telefono con un browser vero al posto di un mockup.
##
##   godot --headless --path godot --script res://cli/run_room.gd -- \
##       --seed=7000 --chronicle=CHR_01 --port=8137 --pages=8123
##
## Stampa una riga per seggio con l'indirizzo da aprire, poi gioca: i seggi
## umani aspettano il telefono, gli altri sono policy — le stesse regole della
## stanza vera, perche' e' lo stesso `ConsoleHost` e lo stesso `SeatDecider`.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ConsoleHost := preload("res://scripts/net/console_host.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var seed_value: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var port: int = int(options.get("port", 8137))
	var pages: int = int(options.get("pages", 8123))
	var seats_wanted: int = int(options.get("seats", 2))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
	var humans: Array = []
	for index in range(mini(seats_wanted, seats.size())):
		humans.append(str(seats[index]))

	var session: RefCounted = GameSession.new(data)
	session.setup(chronicle_id, seats, seed_value)
	var host: RefCounted = ConsoleHost.new(session)
	var tokens: Dictionary = host.open(port, humans, seed_value)
	if not host.serve_pages(pages):
		printerr("La porta %d e' occupata: chiudi l'altra stanza e riapri." % pages)
		quit(1)
		return

	print("== LA STANZA E' APERTA - %s, seme %d ==" % [chronicle_id, seed_value])
	print("  La vetrina:  http://127.0.0.1:%d/tavolo" % pages)
	for seat in humans:
		print("  %-22s http://127.0.0.1:%d/?t=%s" % [
			session.service.name_of(str(seat)), pages, str(tokens[str(seat)])
		])
	print("  (gli altri seggi giocano da soli)")

	var decider: RefCounted = SeatDecider.new(humans, session.log)
	for seat in humans:
		decider.ios[str(seat)] = host.io_for(str(seat))
	host.seated(humans)

	var finished: Array = [false]
	_play(session, decider, finished)
	while not finished[0]:
		host.poll()
		await process_frame
	host.close()
	print("")
	print("La Chronicle e' chiusa.")
	quit(0)


func _play(session: RefCounted, decider: RefCounted, finished: Array) -> void:
	await session.run(decider)
	finished[0] = true


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
