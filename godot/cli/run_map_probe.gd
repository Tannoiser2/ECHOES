extends SceneTree
## La mappa: e' una lotta o una spartizione?
##
##   godot --headless --path godot --script res://cli/run_map_probe.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_00
##
## «Modificare la mappa dovrebbe essere la priorita' del gioco e **una
## maggioranza dovrebbe essere una lotta fra entita'**» — parola del committente.
## La seconda meta' di quella frase non e' mai stata misurata.
##
## Il motore ricontrolla le forze a ogni round e **la presenza piu' forte tiene
## la Regione**; a parita' non cambia niente, chi ce l'ha se la tiene. Quindi la
## frase si traduce in un numero solo, e chiaro:
##
##   **di quanto vince chi vince.**
##
## Una Regione tenuta con tre pedine contro zero non e' una maggioranza: e' una
## proprieta'. Una tenuta con due contro una e' una lotta, e la prossima pedina
## la ribalta. Il conto qui e' il **margine** fra il primo e il secondo, e sul
## tavolo si vede a occhio: si guardano due mucchietti di legno accanto.
##
## E tre domande che vengono prima, perche' una lotta ha bisogno di un posto
## dove farla e di un motivo per farla:
##
##   · **le prese**: quante volte il controllo si toglie a qualcuno, e quante
##     volte si raccoglie da terra;
##   · **le clausole morte**: quante righe dei Destini nominano una Regione che
##     la mappa non ha pescato — una riga che al tavolo non si puo' nemmeno
##     provare a fare;
##   · **le Regioni che nessuno vuole**: pescate, e nessun Destino le nomina.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var margins: Dictionary = {}      # margine -> quante Regioni tenute cosi'
	var held: int = 0                 # Regioni con un padrone a fine anno
	var no_owner: int = 0
	var taken_from: int = 0           # prese a qualcuno
	var taken_free: int = 0           # raccolte da terra
	var lost: int = 0
	var dead_clauses: int = 0         # righe che nominano una Regione non pescata
	var live_clauses: int = 0
	var dead_by_region: Dictionary = {}
	var wanted_regions: int = 0       # Regioni pescate che qualcuno nomina
	var ignored_regions: int = 0

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(3)
			return
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)

		# Le righe che nominano una Regione: quante di quelle nominate stanno
		# sul tavolo pescato? Si guarda **prima** di giocare, perche' e' una
		# proprieta' della pesca e non della partita.
		var asked: Dictionary = {}
		for entity_id in session.world["entities"]:
			var seat: Dictionary = session.world["entities"][str(entity_id)] as Dictionary
			var carried: Array = []
			var destiny: Variant = data.destinies.get(str(seat.get("destiny_id", "")))
			if destiny != null:
				_clauses(destiny, carried)
			for objective_id in (seat.get("objectives", []) as Array):
				var objective: Variant = data.objectives.get(str(objective_id))
				if objective != null:
					_clauses(objective, carried)
			for clause in carried:
				var cl: Dictionary = clause as Dictionary
				# **Una riga mirata a segni** (D-327): vive se una delle terre
				# pescate porta uno di quei segni, e chiede *quelle*. Il
				# validatore garantisce che ce ne sia sempre almeno una, ma la
				# sonda lo misura lo stesso: una garanzia non provata in partita
				# e' una promessa.
				var signs: Array = cl.get("any_tag", []) as Array
				if not signs.is_empty():
					var found: bool = false
					for region_id in session.world["regions"]:
						for sign in signs:
							if session.service.region_has_tag(str(region_id), str(sign)):
								asked[str(region_id)] = true
								found = true
								break
					if found:
						live_clauses += 1
					else:
						dead_clauses += 1
						var missing: String = "segni: %s" % str(signs)
						dead_by_region[missing] = int(dead_by_region.get(missing, 0)) + 1
					continue
				var named: String = str(cl.get("region_id", ""))
				if named == "" or named.begins_with("$"):
					continue
				if (session.world["regions"] as Dictionary).has(named):
					live_clauses += 1
					asked[named] = true
				else:
					dead_clauses += 1
					dead_by_region[named] = int(dead_by_region.get(named, 0)) + 1
		for region_id in session.world["regions"]:
			if asked.has(str(region_id)):
				wanted_regions += 1
			else:
				ignored_regions += 1

		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return

		# **Il margine**, a fine anno: primo contro secondo, in forza.
		for region_id in session.world["regions"]:
			var here: String = str(region_id)
			var owner: Variant = (
				session.world["regions"][here] as Dictionary
			).get("control", null)
			if owner == null:
				no_owner += 1
				continue
			held += 1
			var best: int = 0
			var second: int = 0
			for entity_id in session.world["turn_order"]:
				var strength: int = session.service.control_strength(str(entity_id), here)
				if strength > best:
					second = best
					best = strength
				elif strength > second:
					second = strength
			var margin: int = best - second
			margins[margin] = int(margins.get(margin, 0)) + 1

		# Le prese, dal registro: a qualcuno o da terra.
		for entry in (session.world["effect_log"] as Array):
			var e: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(e.get("type", "")) != "SET_CONTROL":
				continue
			var to: Variant = (e.get("payload", {}) as Dictionary).get("entity_id", null)
			var back: Variant = (e.get("inverse_payload", {}) as Dictionary).get("entity_id", null)
			if str(to if to != null else "") == str(back if back != null else ""):
				continue
			if to == null:
				lost += 1
			elif back == null:
				taken_free += 1
			else:
				taken_from += 1
		session.dispose()

	_report(
		runs, mixed, margins, held, no_owner, taken_from, taken_free, lost,
		dead_clauses, live_clauses, dead_by_region, wanted_regions, ignored_regions
	)
	quit(0)


func _clauses(item: Variant, out: Array) -> void:
	if item is Dictionary:
		var d: Dictionary = item as Dictionary
		if d.has("type"):
			out.append(d)
		for key in d:
			_clauses(d[key], out)
	elif item is Array:
		for value in (item as Array):
			_clauses(value, out)


func _report(
	runs: int, mixed: bool, margins: Dictionary, held: int, no_owner: int,
	taken_from: int, taken_free: int, lost: int, dead_clauses: int,
	live_clauses: int, dead_by_region: Dictionary, wanted: int, ignored: int
) -> void:
	print("")
	print("== LA MAPPA: E' UNA LOTTA O UNA SPARTIZIONE? ==")
	print("   CHR_00, %d partite, tavolo %s" % [runs, "misto" if mixed else "uniforme"])
	print("")

	print("  **Di quanto vince chi vince** (Regioni tenute a fine anno: %d)" % held)
	var keys: Array = margins.keys()
	keys.sort()
	var fights: int = 0
	for margin in keys:
		var many: int = int(margins[margin])
		var share: float = 100.0 * float(many) / float(maxi(1, held))
		var note: String = ""
		if int(margin) <= 1:
			note = "   <-- una pedina la ribalta"
			fights += many
		elif int(margin) >= 4:
			note = "   <-- nessuno la puo' toccare"
		print("    margine %2d   %5d   %5.1f%%%s" % [int(margin), many, share, note])
	print("")
	print("    **Regioni decise per una pedina o meno: %.1f%%**" % [
		100.0 * float(fights) / float(maxi(1, held))
	])
	print("    Regioni senza padrone a fine anno: %.2f per partita" % [
		float(no_owner) / float(maxi(1, runs))
	])
	print("")

	var moves: int = taken_from + taken_free + lost
	print("  **Come si prende una Regione** (%d passaggi in %d partite)" % [moves, runs])
	print("    tolta a un'altra casa      %5d   %5.1f%%" % [
		taken_from, 100.0 * float(taken_from) / float(maxi(1, moves))
	])
	print("    raccolta da terra          %5d   %5.1f%%" % [
		taken_free, 100.0 * float(taken_free) / float(maxi(1, moves))
	])
	print("    persa e basta              %5d   %5.1f%%" % [
		lost, 100.0 * float(lost) / float(maxi(1, moves))
	])
	print("")

	var total_clauses: int = dead_clauses + live_clauses
	print("  **Le righe che nominano una Regione** (%d in %d partite)" % [total_clauses, runs])
	print("    su una Regione pescata     %5d   %5.1f%%" % [
		live_clauses, 100.0 * float(live_clauses) / float(maxi(1, total_clauses))
	])
	print("    su una che non c'e'        %5d   %5.1f%%   <-- non si possono nemmeno provare" % [
		dead_clauses, 100.0 * float(dead_clauses) / float(maxi(1, total_clauses))
	])
	var names: Array = dead_by_region.keys()
	names.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(dead_by_region[a]) > int(dead_by_region[b]))
	for name in names:
		print("      %-26s %d" % [str(name), int(dead_by_region[name])])
	print("")

	var places: int = wanted + ignored
	print("  **Le Regioni pescate** (%d in %d partite)" % [places, runs])
	print("    qualcuno le nomina         %5d   %5.1f%%" % [
		wanted, 100.0 * float(wanted) / float(maxi(1, places))
	])
	print("    non le nomina nessuno      %5d   %5.1f%%" % [
		ignored, 100.0 * float(ignored) / float(maxi(1, places))
	])
	print("")


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		var body: String = text.substr(2)
		var split: int = body.find("=")
		if split < 0:
			out[body] = true
		else:
			out[body.substr(0, split)] = body.substr(split + 1)
	return out
