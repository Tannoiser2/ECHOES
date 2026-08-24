extends SceneTree
## Quanto chiede un obiettivo (ISSUES 68, terza strada).
##
##   godot --headless --path godot --script res://cli/run_asking_probe.gd -- \
##       --runs=100 --seed=7000
##
## La sonda dei «passa» (D-254) ha isolato la causa maggiore e non l'ha spiegata:
## **il 64,9% di chi passa aveva quindici mosse legali e nessuna che gli
## servisse.** Non mancano le regole e non manca il mazzo: manca la ragione.
##
## Delle tre strade — un costo per il passare, un premio per il muovere,
## obiettivi che chiedono piu' di quanto il mondo dia da solo — il committente ha
## scelto la terza. Prima di toccare un obiettivo bisogna sapere **quanti di
## essi il mondo avvera da solo**: un obiettivo gia' vero all'apertura dell'anno
## non e' un traguardo, e' un punto in cassaforte, e chi lo tiene ha una ragione
## in meno per alzarsi.
##
## Per ogni obiettivo pescato la sonda guarda due volte la stessa clausola:
## **all'apertura**, quando nessuno ha ancora giocato, e **alla chiusura**. Da li'
## quattro caselle, e sono quattro cose diverse:
##
## | | apertura | chiusura | |
## |---|---|---|---|
## | **regalato** | vero | vero | il punto c'era prima di giocare |
## | **conquistato** | falso | vero | qualcuno ha fatto qualcosa |
## | **perso** | vero | falso | il mondo gliel'ha tolto |
## | **mai** | falso | falso | non e' successo |
##
## Solo la seconda colonna e' una ragione per agire. La prima e' il difetto che
## la terza strada deve togliere; la quarta e' un obiettivo che chiede troppo, e
## va guardata insieme alla prima perche' la cura dell'una e' la malattia
## dell'altra.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


## Il tavolo di pietra: **non spende mai un'Occasione**.
##
## Non e' un giocatore, e' un metro. Delega tutto il resto al cervello vero —
## il Consiglio si apre lo stesso, perche' il Consiglio non e' un'Occasione: e'
## l'orologio del mondo, e nessuno puo' rifiutarsi di esserci. Quello che resta
## e' esattamente la domanda della terza strada: **cosa si avvera se non ti alzi
## mai.**
class StoneSeat extends RefCounted:
	var inner: RefCounted

	func _init(who: RefCounted) -> void:
		inner = who

	func choose_action(_entity_id: String, _ao_index: int, _session: RefCounted) -> Dictionary:
		return {"template": "PASS", "params": {}}

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_proposition(context, options, session)

	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		return await inner.choose_stance(entity_id, context, session)

	func choose_commit(
		entity_id: String, context: Dictionary, limit: int, session: RefCounted
	) -> Array:
		return await inner.choose_commit(entity_id, context, limit, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return await inner.choose_recovery(context, session)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Gli stessi semi due volte: il tavolo vero e il tavolo di pietra.
	var played: Dictionary = await _play(data, runs, first_seed, chronicle_id, mixed, false)
	var still: Dictionary = await _play(data, runs, first_seed, chronicle_id, mixed, true)
	_report(played, still, data, runs, chronicle_id, mixed)
	quit(0)


## Un giro di anni. Torna obiettivo -> [pescati, regalati, conquistati, persi, mai].
func _play(
	data: RefCounted, runs: int, first_seed: int, chronicle_id: String,
	mixed: bool, stone: bool
) -> Dictionary:
	var tally: Dictionary = {}
	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(3)
			return {}
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)

		# **L'apertura si legge adesso**, con le pedine posate e nessuna mossa
		# giocata. Piu' tardi non si puo': il mondo di fine anno non sa piu' da
		# dove veniva.
		var at_dawn: Dictionary = _standing(session)

		var brain: RefCounted = (
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		var report: Dictionary = await session.run(StoneSeat.new(brain) if stone else brain)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return {}
		var at_dusk: Dictionary = _standing(session)

		for key in at_dawn:
			var objective_id: String = str((key as Array)[1])
			var cell: Array = tally.get(objective_id, [0, 0, 0, 0, 0])
			cell[0] = int(cell[0]) + 1
			var before: bool = bool(at_dawn[key])
			var after: bool = bool(at_dusk.get(key, false))
			if before and after:
				cell[1] = int(cell[1]) + 1
			elif not before and after:
				cell[2] = int(cell[2]) + 1
			elif before and not after:
				cell[3] = int(cell[3]) + 1
			else:
				cell[4] = int(cell[4]) + 1
			tally[objective_id] = cell
		session.dispose()
	return tally


## Ogni coppia (seggio, obiettivo pescato) e se la sua clausola vale adesso.
## La chiave e' la coppia perche' lo stesso obiettivo puo' stare in mano a due
## case nello stesso anno, e sono due storie diverse.
func _standing(session: RefCounted) -> Dictionary:
	var out: Dictionary = {}
	for entity_id in (session.world["entities"] as Dictionary).keys():
		var seat: Dictionary = (session.world["entities"] as Dictionary)[str(entity_id)] as Dictionary
		for objective_id in seat.get("objectives", []) as Array:
			var objective: Variant = session.data.objectives.get(str(objective_id))
			if objective == null:
				continue
			out[[str(entity_id), str(objective_id)]] = session.destinies.conditions.all_hold(
				(objective as Dictionary)["conditions"] as Array, {"self": str(entity_id)}
			)
	return out


func _report(
	played: Dictionary, still: Dictionary, data: RefCounted,
	runs: int, chronicle_id: String, mixed: bool
) -> void:
	print("")
	print("== QUANTO CHIEDE UN OBIETTIVO - %d anni, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme",
	])
	print("")
	print("  Ogni anno giocato due volte con lo stesso seme: una col tavolo vero,")
	print("  una col **tavolo di pietra** che non spende mai un'Occasione.")
	print("")
	var ids: Array = played.keys()
	ids.sort_custom(func(a: Variant, b: Variant) -> bool:
		return _gain(played, still, str(a)) < _gain(played, still, str(b))
	)
	print("  %-24s %7s %8s   %-17s %-17s %8s" % [
		"obiettivo", "in mano", "all'alba", "giocando", "stando fermi", "il gioco",
	])
	var dealt: int = 0
	var given: int = 0
	var won: int = 0
	var lost: int = 0
	var never: int = 0
	var free_points: int = 0
	for objective_id in ids:
		var cell: Array = played[str(objective_id)]
		dealt += int(cell[0])
		given += int(cell[1])
		won += int(cell[2])
		lost += int(cell[3])
		never += int(cell[4])
		var here: int = int(cell[1]) + int(cell[2])
		var idle: Array = still.get(str(objective_id), [0, 0, 0, 0, 0]) as Array
		var idle_met: int = int(idle[1]) + int(idle[2])
		free_points += idle_met
		print("  %-24s %7d %4d %3.0f%%   %5d su %-8d %5d su %-8d %+7.0f%%" % [
			str(objective_id).substr(4), int(cell[0]),
			int(cell[1]) + int(cell[3]),
			100.0 * float(int(cell[1]) + int(cell[3])) / float(maxi(1, int(cell[0]))),
			here, int(cell[0]),
			idle_met, int(idle[0]),
			100.0 * _gain(played, still, str(objective_id)),
		])
	print("")
	var met: int = given + won
	print("  Pescati %d volte, avverati %d (%.1f%%)." % [
		dealt, met, 100.0 * float(met) / float(maxi(1, dealt)),
	])
	print("  Di quelli avverati, **%d erano gia' veri all'apertura**: %.1f%%." % [
		given, 100.0 * float(given) / float(maxi(1, met)),
	])
	print("  Persi per strada: %d. Mai avverati: %d." % [lost, never])
	print("")
	print("  **Il tavolo di pietra ne avvera %d.** Giocare ne compra %d in piu': %+.1f%%." % [
		free_points, met - free_points,
		100.0 * float(met - free_points) / float(maxi(1, free_points)),
	])
	print("")
	print("  Gli obiettivi che stando fermi si avverano quanto o piu' che giocando:")
	var idle_ones: int = 0
	for objective_id in ids:
		if _gain(played, still, str(objective_id)) > 0.0:
			continue
		idle_ones += 1
		var cell: Array = played[str(objective_id)]
		var idle: Array = still.get(str(objective_id), [0, 0, 0, 0, 0]) as Array
		print("    %-24s giocando %3d, fermi %3d  — %s" % [
			str(objective_id).substr(4),
			int(cell[1]) + int(cell[2]), int(idle[1]) + int(idle[2]),
			str((data.objectives[str(objective_id)] as Dictionary)["title"]),
		])
	if idle_ones == 0:
		print("    nessuno.")


## Quanto rende **giocare**, per questo obiettivo: la quota avverata col tavolo
## vero meno quella del tavolo di pietra, sul suo stesso numero di pescate.
## Zero o meno vuol dire che l'obiettivo non chiede niente a chi lo tiene.
static func _gain(played: Dictionary, still: Dictionary, objective_id: String) -> float:
	var cell: Array = played.get(objective_id, [0, 0, 0, 0, 0]) as Array
	var idle: Array = still.get(objective_id, [0, 0, 0, 0, 0]) as Array
	var here: float = float(int(cell[1]) + int(cell[2])) / float(maxi(1, int(cell[0])))
	var there: float = float(int(idle[1]) + int(idle[2])) / float(maxi(1, int(idle[0])))
	return here - there


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not str(argument).begins_with("--"):
			continue
		var pair: PackedStringArray = str(argument).substr(2).split("=", true, 1)
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
