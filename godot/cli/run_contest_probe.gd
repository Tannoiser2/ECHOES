extends SceneTree
## La lotta per la mappa: c'e'?
##
##   godot --headless --path godot --script res://cli/run_contest_probe.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_01
##
## «Modificare la mappa dovrebbe essere la priorita' del gioco e una maggioranza
## dovrebbe essere una lotta fra entita'» — decisione del committente. Prima di
## disegnare qualcosa bisogna sapere **se quella lotta esiste**, e la voce
## finora non e' mai stata misurata.
##
## Quattro domande, e ognuna e' un numero:
##
## 1. **Quante Regioni cambiano padrone in un anno?** Se sono zero, la mappa non
##    e' contesa: e' assegnata all'apertura e confermata nove volte.
## 2. **Quante Regioni hanno dentro piu' di una casa?** Una Regione con dentro
##    un solo seggio non e' una maggioranza, e' una proprieta'.
## 3. **Quanto rende una presenza in piu'?** La mano si riempie a due carte per
##    gettone, ma con un tetto: oltre quello, spostarsi non paga piu'.
## 4. **Gli obiettivi si incrociano?** Due case che vogliono la stessa Regione
##    danno battaglia; due case che vogliono cose parallele giocano da sole
##    allo stesso tavolo.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


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

	var handovers: int = 0          # SET_CONTROL che cambiano davvero padrone
	var first_owner: int = 0        # da nessuno a qualcuno
	var lost: int = 0               # da qualcuno a nessuno
	var contested_open: float = 0.0 # Regioni con 2+ case dentro, all'apertura
	var contested_close: float = 0.0
	var held_at_end: float = 0.0
	var regions_seen: int = 0
	var hand_sizes: Dictionary = {} # gettoni posati -> [carte pescate, rifornimenti]
	var by_control: Dictionary = {}  # Regioni tenute -> [carte pescate, rifornimenti]

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
		contested_open += float(_contested(session))
		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return

		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(effect.get("type", "")) != "SET_CONTROL":
				continue
			var to: Variant = (effect.get("payload", {}) as Dictionary).get("entity_id", null)
			var back: Variant = (effect.get("inverse_payload", {}) as Dictionary).get("entity_id", null)
			if str(to if to != null else "") == str(back if back != null else ""):
				continue
			if to == null:
				lost += 1
			elif back == null:
				first_owner += 1
			else:
				handovers += 1

		contested_close += float(_contested(session))
		for region_id in session.world["regions"]:
			regions_seen += 1
			if (session.world["regions"][region_id] as Dictionary).get("control", null) != null:
				held_at_end += 1.0

		# Le pedine **al momento del rifornimento**, non a fine anno.
		#
		# Questa sonda ha sbagliato la domanda due volte, e ogni volta il numero
		# cambiava conclusione. Prima contava le carte **in mano a fine anno**:
		# ma chi ha piu' pedine pesca di piu' *e spende di piu'*, e le due cose
		# si annullano. Poi contava le carte **pescate**, ma raggruppate per le
		# pedine di fine anno: chi finisce con cinque pedine le ha posate tardi,
		# quindi per due Atti su tre ha pescato da due. Il numero diceva che
		# espandersi rende **meno**, che e' un artefatto del raggruppamento.
		#
		# La domanda vera e' una coppia: **con quante pedine sul tavolo si e'
		# pescato quanto**, e si ricostruisce dal registro degli Effetti in
		# ordine — l'unica fonte che sa *quando* ogni cosa e' successa (§6.3).
		var standing: Dictionary = {}
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var kind: String = str(effect.get("type", ""))
			var who: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
			if kind == "ADD_PRESENCE":
				standing[who] = int(standing.get(who, 0)) + 1
			elif kind == "REMOVE_PRESENCE":
				standing[who] = maxi(0, int(standing.get(who, 0)) - 1)
			elif kind == "GRANT_ASSET":
				if str((effect.get("source", {}) as Dictionary).get("id", "")) != "HAND_REFILL":
					continue
				var key: String = str(int(standing.get(who, 0)))
				var cell: Array = hand_sizes.get(key, [0, 0])
				cell[0] = int(cell[0]) + 1
				hand_sizes[key] = cell
		# E quante volte il rubinetto e' stato aperto con quella presenza, per
		# poter dire **carte per rifornimento** invece di un totale che dipende
		# da quanti seggi ci sono passati.
		# E la stessa coppia per il **possesso**: con quante Regioni in mano si e'
		# pescato quanto. Sono due monete diverse e vanno lette separate — stare
		# dentro e tenere non sono la stessa cosa.
		var owns: Dictionary = {}
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var kind: String = str(effect.get("type", ""))
			if kind == "SET_CONTROL":
				var to: Variant = (effect.get("payload", {}) as Dictionary).get("entity_id", null)
				var back: Variant = (effect.get("inverse_payload", {}) as Dictionary).get("entity_id", null)
				if back != null:
					owns[str(back)] = maxi(0, int(owns.get(str(back), 0)) - 1)
				if to != null:
					owns[str(to)] = int(owns.get(str(to), 0)) + 1
			elif kind == "GRANT_ASSET":
				if str((effect.get("source", {}) as Dictionary).get("id", "")) != "HAND_REFILL":
					continue
				var who2: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
				var key3: String = str(int(owns.get(who2, 0)))
				var cell3: Array = by_control.get(key3, [0, 0])
				cell3[0] = int(cell3[0]) + 1
				by_control[key3] = cell3

		var seen: Dictionary = {}
		var again: Dictionary = {}
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var kind: String = str(effect.get("type", ""))
			var who: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
			if kind == "ADD_PRESENCE":
				again[who] = int(again.get(who, 0)) + 1
			elif kind == "REMOVE_PRESENCE":
				again[who] = maxi(0, int(again.get(who, 0)) - 1)
			elif kind == "GRANT_ASSET":
				if str((effect.get("source", {}) as Dictionary).get("id", "")) != "HAND_REFILL":
					continue
				var mark: String = "%s|%d|%d" % [
					who, int(effect.get("source", {}).get("act", 0)), int(again.get(who, 0))
				]
				if seen.has(mark):
					continue
				seen[mark] = true
				var key2: String = str(int(again.get(who, 0)))
				var cell2: Array = hand_sizes.get(key2, [0, 0])
				cell2[1] = int(cell2[1]) + 1
				hand_sizes[key2] = cell2
		session.dispose()

	var years: float = float(runs)
	print("")
	print("== LA LOTTA PER LA MAPPA - %d partite, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme"
	])
	print("")
	print("  Il padrone di una Regione, in un anno:")
	print("    passa di mano da una casa all'altra   %5.2f volte" % [float(handovers) / years])
	print("    da nessuno a qualcuno                 %5.2f" % [float(first_owner) / years])
	print("    da qualcuno a nessuno                 %5.2f" % [float(lost) / years])
	print("")
	print("  Regioni con dentro piu' di una casa:")
	print("    all'apertura   %.2f su 6" % [contested_open / years])
	print("    a fine anno    %.2f su 6" % [contested_close / years])
	print("  Regioni con un padrone a fine anno: %.2f su 6" % [
		held_at_end / years
	])
	print("")
	print("  Quanto rende una presenza in piu' (carte pescate a ogni rifornimento):")
	var keys: Array = hand_sizes.keys()
	keys.sort_custom(func(a: String, b: String) -> bool: return int(a) < int(b))
	for key in keys:
		var cell: Array = hand_sizes[str(key)]
		print("    %2s pedine sul tavolo: %5.2f carte   (%d rifornimenti)" % [
			str(key), float(int(cell[0])) / float(maxi(1, int(cell[1]))), int(cell[1])
		])
	print("")
	print("  E quanto rende **tenere** una Regione (carte pescate al rifornimento):")
	var owned_keys: Array = by_control.keys()
	owned_keys.sort_custom(func(a: String, b: String) -> bool: return int(a) < int(b))
	for key in owned_keys:
		var cell: Array = by_control[str(key)]
		print("    %2s Regioni tenute: %5d carte in tutto" % [str(key), int(cell[0])])
	quit(0)


static func _contested(session: RefCounted) -> int:
	var count: int = 0
	for region_id in session.world["regions"]:
		var inside: int = 0
		for entity_id in session.world["entities"]:
			if session.service.presence_count(str(entity_id), str(region_id)) > 0:
				inside += 1
		if inside > 1:
			count += 1
	return count


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
