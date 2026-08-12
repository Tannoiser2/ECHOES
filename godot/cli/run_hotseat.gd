extends SceneTree
## Play ECHOES at the keyboard, one seat or four, on one terminal.
##
##   godot --headless --path godot --script res://cli/run_hotseat.gd -- \
##       --seats=ENT_NAHR --seed=812
##
##   --seats=all          all four played by hand
##   --seats=ENT_NAHR     one seat by hand, the other three by the policy
##   --seed=812           same seed, same world
##   --chronicle=CHR_02   the library Chronicle instead of the authored one
##   --quiet              only the Councils, the Echo cards and the ending -
##                        no per-round rules trace
##
## This is 0.1's hotseat with a terminal where the map will go. Nothing about
## the rules is special-cased for it: the ChronicleController asks a decider,
## and this one asks a person. That is the whole change.
##
## Piping a file of answers works and is how the smoke test drives it; when the
## answers run out the policy finishes the Chronicle.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const TerminalIo := preload("res://cli/terminal_io.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var seed_value: int = int(options.get("seed", 812))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var quiet: bool = options.has("quiet")
	var humans: Array = _seats(str(options.get("seats", "ENT_NAHR")))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var session: RefCounted = GameSession.new(data)
	session.setup(chronicle_id, SEATS, seed_value)

	_opening(session, data, humans, seed_value)

	# The rules trace is the same log the sims write, echoed live so a player can
	# watch the world answer them. --quiet drops the per-round bookkeeping but
	# never the Councils: a player who cannot see the Council cannot play.
	var state: Dictionary = {"shown": 0, "keep": true}
	session.chronicle.phase_changed.connect(
		func(_act: int, _round: int, _phase: String) -> void: _flush(session, state, quiet)
	)

	var seat: RefCounted = SeatDecider.new(humans, session.log)
	seat.io = TerminalIo.new()
	var report: Dictionary = await session.run(seat)
	_flush(session, state, quiet)
	_closing(session, data, report)
	session.dispose()
	quit(0)


## Print whatever the log has gained since last time. In quiet mode a section
## header decides whether its lines are worth a player's attention, and the
## decision holds until the next header.
func _flush(session: RefCounted, state: Dictionary, quiet: bool) -> void:
	var lines: Array = session.log.lines
	while int(state["shown"]) < lines.size():
		var line: String = str(lines[int(state["shown"])])
		state["shown"] = int(state["shown"]) + 1
		if quiet and line.begins_with("=="):
			state["keep"] = (
				line.contains("CONFLUENCE") or line.contains("ECHO") or line.contains("FINE")
			)
		if not quiet or bool(state["keep"]):
			print(line)


func _opening(session: RefCounted, data: RefCounted, humans: Array, seed_value: int) -> void:
	var chronicle: Dictionary = data.chronicles[str(session.world["chronicle_id"])]
	print("")
	print("=========================================================")
	print(" ECHOES - %s" % str(chronicle["title"]))
	print(" anno %d, seme %d" % [int(session.world["year"]), seed_value])
	print("=========================================================")
	print("")
	for entity_id in SEATS:
		var destiny: Dictionary = data.destinies[session.service.destiny_of(str(entity_id))]
		print("  %-14s %-34s %s" % [
			session.service.name_of(str(entity_id)), str(destiny["title"]),
			"<- tu" if humans.has(str(entity_id)) else "(policy)",
		])
	print("")
	print("  Invio a vuoto su qualsiasi scelta = la lascia decidere alla policy.")


func _closing(session: RefCounted, data: RefCounted, report: Dictionary) -> void:
	print("")
	print("=========================================================")
	print(" COM'E FINITA")
	print("=========================================================")
	for entity_id in SEATS:
		var entry: Dictionary = report["destiny_results"][str(entity_id)]
		print("  %-14s %-10s %s" % [
			session.service.name_of(str(entity_id)),
			str(entry["level"]), str(entry.get("label", "")),
		])
	if not (session.world["truth_log"] as Array).is_empty():
		print("")
		print(" Quello che resta scritto:")
		for truth in session.world["truth_log"]:
			print("  - %s" % str(truth["text"]))
	if not (session.world["scars"] as Array).is_empty():
		print("")
		print(" Quello che resta sulla mappa:")
		for scar in session.world["scars"]:
			print("  - %s: %s" % [
				str(data.regions[str(scar["region_id"])]["name"]),
				str(scar["description"]),
			])


func _seats(text: String) -> Array:
	if text == "all" or text == "tutti":
		return SEATS.duplicate()
	var out: Array = []
	for token in text.split(",", false):
		var entity_id: String = str(token).strip_edges().to_upper()
		if not entity_id.begins_with("ENT_"):
			entity_id = "ENT_%s" % entity_id
		if SEATS.has(entity_id):
			out.append(entity_id)
		else:
			printerr("Seggio sconosciuto: %s" % token)
	return out


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		text = text.substr(2)
		var split: int = text.find("=")
		if split < 0:
			options[text] = true
		else:
			options[text.substr(0, split)] = text.substr(split + 1)
	return options
