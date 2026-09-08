extends SceneTree
## **Chi decide l'agenda del tavolo** ([D-482](../../docs/DECISIONS.md#d-482)).
##
##   godot --headless --path godot --script res://cli/run_agenda_probe.gd -- \
##       --runs=100 --seed=7000
##
## La Risonanza avviene comunque (D-257), ma da D-482 la carta stampa **due**
## Temi e chi la gioca sceglie quale scaldare. E' l'unica leva che chi gioca ha
## sull'agenda, perche' il Tema piu' caldo decide quale domanda va al Consiglio
## (D-260, D-261) — ed e' la risposta alla domanda del committente su qual e' il
## meccanismo di ECHOES ([ISSUES 132](../../docs/ISSUES.md#132)).
##
## Una leva che c'e' e che nessuno tira non e' una leva: questa sonda conta
## **quante volte la scelta esiste** e **quante volte cambia qualcosa** — cioe'
## quante volte il Tema scelto non e' quello stampato per primo.
##
## Si misura dove la scelta si fa: un avvolgente attorno al cervello, che
## delega tutto e segna cosa ha scelto. Nessuna regola cambia, e il seme resta
## quello — l'avvolgente non consuma RNG.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


class Agenda extends RefCounted:
	var inner: RefCounted
	## Carte calate che offrivano due Temi.
	var offered: int = 0
	## Di quelle, quante hanno scelto **l'altro**.
	var switched: int = 0
	## Carte calate che di Temi ne offrivano uno solo.
	var forced: int = 0
	## Quante volte ogni Tema ha preso il gettone, e quante da secondo.
	var by_theme: Dictionary = {}

	func _init(p_inner: RefCounted) -> void:
		inner = p_inner

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		var request: Dictionary = inner.choose_action(entity_id, ao_index, session)
		if str(request.get("template", "")) == "PLAY_CARD":
			_note(request.get("params", {}) as Dictionary, session)
		return request

	func _note(params: Dictionary, session: RefCounted) -> void:
		var card: Variant = session.data.assets.get(str(params.get("asset_id", "")))
		if card == null:
			return
		var echo: Dictionary = (
			((card as Dictionary).get("physical", {}) as Dictionary).get("resonance", {})
			as Dictionary
		)
		var first: String = str(echo.get("theme", ""))
		var second: String = str(echo.get("or_theme", ""))
		if first == "":
			return
		if second == "" or second == first:
			forced += 1
			_count(first, false)
			return
		offered += 1
		var chosen: String = str(params.get("resonance_theme", ""))
		if chosen == second:
			switched += 1
			_count(second, true)
		else:
			_count(first, false)

	func _count(theme_id: String, as_second: bool) -> void:
		var seen: Array = by_theme.get(theme_id, [0, 0]) as Array
		seen[0] += 1
		if as_second:
			seen[1] += 1
		by_theme[theme_id] = seen

	# Tutto il resto si inoltra com'e'.
	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		return inner.choose_commit(entity_id, context, limit, session)

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return inner.choose_question(context, options, session)

	func choose_side(entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted) -> Dictionary:
		return await inner.choose_side(entity_id, context, offer, session)

	func choose_box(entity_id: String, context: Dictionary, menu: Array, side: String, session: RefCounted) -> String:
		return await inner.choose_box(entity_id, context, menu, side, session)

	func choose_raise(entity_id: String, context: Dictionary, menu: Array, session: RefCounted) -> String:
		return await inner.choose_raise(entity_id, context, menu, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return inner.choose_recovery(context, session)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr(data.describe_errors())
		quit(1)
		return

	var mixed: bool = str(options.get("mixed", "1")) != "0"
	var agenda: Agenda = Agenda.new(null)
	var years: int = 0
	# Quale Tema ha aperto ogni Consiglio: e' il posto dove l'agenda si vede.
	var opened: Dictionary = {}

	for index in range(runs):
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr(session.last_error)
			session.dispose()
			continue
		agenda.inner = (
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		await session.run(agenda)
		# **Di cosa ha parlato il tavolo**, preso dove resta scritto: ogni
		# Consiglio che si chiude lascia un Echo col suo `tension_id`
		# (`EchoRecorder`), e la Tensione dice il Tema. La prima stesura di
		# questa sonda leggeva un `confluence_log` che non esiste, e stampava
		# una sezione vuota: la trappola di casa, presa di nuovo.
		for echo in (session.world.get("echo_log", []) as Array):
			var tension_id: String = str((echo as Dictionary).get("tension_id", ""))
			var tension: Variant = data.tensions.get(tension_id)
			if tension == null:
				continue
			var theme_id: String = str((tension as Dictionary).get("theme", ""))
			opened[theme_id] = int(opened.get(theme_id, 0)) + 1
		years += 1
		session.dispose()

	_report(data, agenda, opened, years)
	quit(0)


func _report(data: RefCounted, agenda: Agenda, opened: Dictionary, years: int) -> void:
	print("")
	print("== CHI DECIDE L'AGENDA - %d anni ==" % years)
	print("")
	var total: int = agenda.offered + agenda.forced
	print("  carte calate con una Risonanza:      %5d" % total)
	print("  di quelle, con due Temi da scegliere: %5d  (%.1f%%)" % [
		agenda.offered, 0.0 if total == 0 else 100.0 * agenda.offered / total,
	])
	print("  e la scelta ha spostato il gettone:   %5d  (%.1f%% delle volte che poteva)" % [
		agenda.switched, 0.0 if agenda.offered == 0 else 100.0 * agenda.switched / agenda.offered,
	])
	print("")
	print("  Tema                gettoni   di cui scelti al posto del primo")
	var ids: Array = []
	for theme_id in agenda.by_theme:
		ids.append(str(theme_id))
	ids.sort()
	for theme_id in ids:
		var seen: Array = agenda.by_theme[theme_id] as Array
		var theme: Variant = data.themes.get(theme_id)
		print("    %-18s %6d   %6d" % [
			theme_id if theme == null else str((theme as Dictionary).get("title", theme_id)),
			int(seen[0]), int(seen[1]),
		])
	print("")
	print("  I Consigli aperti, per Tema della domanda:")
	var aperti: Array = []
	for theme_id in opened:
		aperti.append(str(theme_id))
	aperti.sort()
	for theme_id in aperti:
		var theme: Variant = data.themes.get(theme_id)
		print("    %-18s %6d" % [
			theme_id if theme == null else str((theme as Dictionary).get("title", theme_id)),
			int(opened[theme_id]),
		])
	print("")


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		var body: String = text.substr(2)
		var cut: int = body.find("=")
		if cut < 0:
			out[body] = "1"
		else:
			out[body.substr(0, cut)] = body.substr(cut + 1)
	return out
