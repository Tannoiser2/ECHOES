extends SceneTree
## Perche' non si supera il Minimo (D-151)
##
##   godot --headless --path godot --script res://cli/run_rung_probe.gd -- \
##       --runs=60 --seed=7000
##
## D-150 ha corretto una lettura: il Minimo di ogni Destino e' «esistere», cioe'
## una soglia di sopravvivenza e non un obiettivo, e il numero che conta e'
## **quanti la superano** — fermo al 30% su trenta Chronicle, col pool dei
## Destini acceso e spento allo stesso modo.
##
## Questa sonda non chiede *se* la Vittoria e' difficile: chiede **quale
## clausola** non si avvera. Il rapporto dei Destini porta gia' `unmet` — le
## condizioni rimaste in sospeso, una per una — quindi qui non si valuta
## niente: si contano. Una clausola che manca nel 95% delle partite non e' un
## obiettivo ambizioso, e' un obiettivo che nessuno ha mai visto da vicino.
##
## Tavolo misto (D-053): quattro ottimizzatori identici sono il caso in cui
## tutti falliscono le stesse clausole per la stessa ragione.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const LEVELS: Array = ["minimum", "victory", "triumph"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 60))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var missed: Dictionary = {}   # "livello|destino|etichetta" -> volte non soddisfatta
	var played: Dictionary = {}   # destino -> quante volte giocato
	var per_destiny: Dictionary = {}  # "destino|livello" -> quante volte
	var reached: Dictionary = {}  # livello raggiunto -> quante volte
	var control_hist: Dictionary = {}  # Regioni tenute a fine anno -> quanti seggi
	var per_seat: Dictionary = {}   # casa -> [Regioni all'inizio, somma a fine anno, partite]
	var claims_made: int = 0      # ACT_CLAIM in CREATE: la rivendicazione aperta
	var claims_forced: int = 0    # ACT_CLAIM in FORCE: il Consiglio strappato
	var granted: Dictionary = {}  # Chronicle -> quante volte una casella e' passata di mano
	var cleared: Dictionary = {}  # Chronicle -> quante volte una casella e' rimasta a nessuno
	var owned_regions: int = 0    # caselle con un padrone, sommate su tutte le partite
	var total_regions: int = 0    # caselle esistite, sommate su tutte le partite
	# Le pietre, contate come si conta il controllo. Una clausola che chiede un
	# presidio di grado 2 e' impossibile o gratis a seconda di questi numeri, e
	# D-161 ha gia' pagato una volta il prezzo di scriverla senza guardarli.
	var stones: Dictionary = {}   # casa -> [strutture a fine anno, grado>=2, grado>=3, partite]
	var by_family: Dictionary = {}  # famiglia -> quante possedute a fine anno
	var raised_in_year: int = 0   # BUILD_STRUCTURE dentro i round
	var raised_at_setup: int = 0  # BUILD_STRUCTURE all'apertura
	var regraded: int = 0         # SET_STRUCTURE_GRADE dentro i round
	var razed: int = 0            # RAZE_STRUCTURE, ovunque
	var scar_hist: Dictionary = {}  # cicatrici sulla mappa a fine anno -> quante partite
	var stone_hist: Dictionary = {}  # "casa|quante" -> quante partite
	var scars_by_region: Dictionary = {}  # Regione -> quante volte segnata
	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
		session.setup(chronicle_id, seats, seed_value)
		var decider: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		# Quante Regioni ha in mano ogni casa *prima* che si giochi: e' il termine
		# di paragone che manca a una clausola scritta come «almeno due».
		for entity_id in seats:
			var row: Array = per_seat.get(str(entity_id), [0, 0, 0]) as Array
			row[0] = int(row[0]) + int(session.service.control_count(str(entity_id)))
			per_seat[str(entity_id)] = row
		var report: Dictionary = await session.run(decider)
		for entity_id in seats:
			var result: Dictionary = (report["destiny_results"] as Dictionary)[str(entity_id)]
			var destiny_id: String = str(result["destiny_id"])
			played[destiny_id] = int(played.get(destiny_id, 0)) + 1
			reached[str(result["level"])] = int(reached.get(str(result["level"]), 0)) + 1
			var lane: String = "%s|%s" % [destiny_id, str(result["level"])]
			per_destiny[lane] = int(per_destiny.get(lane, 0)) + 1
			var destiny: Dictionary = data.destinies[destiny_id]
			for condition in result["unmet"]:
				var label: String = str((condition as Dictionary).get("label", "?"))
				var key: String = "%s|%s|%s" % [_level_of(destiny, label), destiny_id, label]
				missed[key] = int(missed.get(key, 0)) + 1
			# Quante Regioni tiene davvero, a fine anno. La clausola chiede due:
			# la domanda e' se due sia raro o se sia fuori dal mondo.
			var held: int = int(session.service.control_count(str(entity_id)))
			control_hist[held] = int(control_hist.get(held, 0)) + 1
			var seat_row: Array = per_seat.get(str(entity_id), [0, 0, 0]) as Array
			seat_row[1] = int(seat_row[1]) + held
			seat_row[2] = int(seat_row[2]) + 1
			per_seat[str(entity_id)] = seat_row
			# Lo stesso conto, sulle pietre: quante ne tiene, e quante di quelle
			# hanno passato il primo e il secondo gradino.
			var stone_row: Array = stones.get(str(entity_id), [0, 0, 0, 0]) as Array
			var mine_now: int = 0
			for region_id in (session.world["regions"] as Dictionary):
				for structure in ((session.world["regions"] as Dictionary)[region_id] as Dictionary).get("structures", []):
					var record: Dictionary = structure as Dictionary
					if str(record.get("owner", "")) != str(entity_id):
						continue
					mine_now += 1
					stone_row[0] = int(stone_row[0]) + 1
					if int(record["grade"]) >= 2:
						stone_row[1] = int(stone_row[1]) + 1
					if int(record["grade"]) >= 3:
						stone_row[2] = int(stone_row[2]) + 1
					var definition: Variant = data.structure_types.get(str(record["structure_type"]))
					if definition != null:
						var family: String = str((definition as Dictionary)["family"])
						by_family[family] = int(by_family.get(family, 0)) + 1
			stone_row[3] = int(stone_row[3]) + 1
			stones[str(entity_id)] = stone_row
			var stone_key: String = "%s|%d" % [str(entity_id), mine_now]
			stone_hist[stone_key] = int(stone_hist.get(stone_key, 0)) + 1
		# Nessuna azione assegna il controllo di suo: ACT_CLAIM apre una
		# rivendicazione su un *dominio di Tensione*, e in FORCE la consuma per
		# strappare un Consiglio da proponente. La Regione arriva solo se quel
		# Consiglio cade su una delle Consequence che portano un SET_CONTROL a
		# `$proponent`. Contare le tre cose insieme dice dove si perde la catena.
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var effect_type: String = str(effect.get("type", ""))
			if effect_type == "CREATE_CLAIM":
				claims_made += 1
			elif effect_type == "CONSUME_CLAIM":
				claims_forced += 1
			elif effect_type == "BUILD_STRUCTURE":
				var when: int = int((effect.get("source", {}) as Dictionary).get("round", 0))
				if when > 0:
					raised_in_year += 1
				else:
					raised_at_setup += 1
			elif effect_type == "SET_STRUCTURE_GRADE":
				regraded += 1
			elif effect_type == "RAZE_STRUCTURE":
				razed += 1
			if effect_type != "SET_CONTROL":
				continue
			var to: Variant = (effect.get("payload", {}) as Dictionary).get("entity_id", null)
			if to == null or str(to) == "":
				cleared[chronicle_id] = int(cleared.get(chronicle_id, 0)) + 1
			else:
				granted[chronicle_id] = int(granted.get(chronicle_id, 0)) + 1
		var scars_here: int = (session.world["scars"] as Array).size()
		scar_hist[scars_here] = int(scar_hist.get(scars_here, 0)) + 1
		for scar in (session.world["scars"] as Array):
			var where: String = str((scar as Dictionary).get("region_id", "?"))
			scars_by_region[where] = int(scars_by_region.get(where, 0)) + 1
		for region_id in (session.world["regions"] as Dictionary):
			total_regions += 1
			var owner: Variant = (session.world["regions"] as Dictionary)[region_id].get("control", null)
			if owner != null and str(owner) != "":
				owned_regions += 1
		session.dispose()
		if (index + 1) % 10 == 0:
			print("  %d/%d partite" % [index + 1, runs])

	print("")
	print("== I GRADINI - %d Chronicle a tavolo misto, semi da %d ==" % [runs, first_seed])
	var total: int = 0
	for level in reached:
		total += int(reached[level])
	for level in ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]:
		var count: int = int(reached.get(level, 0))
		print("  %-8s %3d  (%.0f%%)" % [level, count, 100.0 * float(count) / maxf(1.0, float(total))])
	var above: int = int(reached.get("VICTORY", 0)) + int(reached.get("TRIUMPH", 0))
	print("  Supera il Minimo: %.0f%%" % (100.0 * float(above) / maxf(1.0, float(total))))

	# Dove finiscono le partite, Destino per Destino. Il totale non dice quale
	# carta del pool porta i Trionfi, e due Destini della stessa casa possono
	# essere uno un muro e l'altro una porta aperta.
	print("")
	print("  Dove arriva ogni Destino (NONE / MINIMUM / VICTORY / TRIUMPH):")
	var destinies: Array = played.keys()
	destinies.sort()
	for destiny_id in destinies:
		var row: String = ""
		for level in ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]:
			row += "%4d" % int(per_destiny.get("%s|%s" % [str(destiny_id), level], 0))
		print("    %-24s %s   su %d" % [str(destiny_id), row, int(played[destiny_id])])

	# La mappa a fine anno: quante Regioni tiene un seggio, e quante ne restano
	# senza padrone. Una clausola che chiede due Regioni si legge solo qui.
	print("")
	print("  Regioni tenute a fine anno (per seggio):")
	var seats_seen: int = 0
	for held in control_hist:
		seats_seen += int(control_hist[held])
	var keys: Array = control_hist.keys()
	keys.sort()
	for held in keys:
		var count: int = int(control_hist[held])
		print("    %d Regioni: %3d seggi  (%.0f%%)" % [
			int(held), count, 100.0 * float(count) / maxf(1.0, float(seats_seen))
		])
	print("  Caselle con un padrone: %d su %d  (%.0f%%)" % [
		owned_regions, total_regions,
		100.0 * float(owned_regions) / maxf(1.0, float(total_regions))
	])
	print("  Da dove parte e dove arriva ogni casa (media delle Regioni tenute):")
	var houses: Array = per_seat.keys()
	houses.sort()
	for entity_id in houses:
		var row: Array = per_seat[entity_id] as Array
		var games: float = maxf(1.0, float(row[2]))
		print("    %-12s inizio %.2f  ->  fine %.2f" % [
			str(entity_id), float(row[0]) / games, float(row[1]) / games
		])
	print("  La catena per prendere una Regione, su %d partite:" % runs)
	print("    Rivendicazioni aperte (ACT_CLAIM CREATE):  %d" % claims_made)
	print("    Consigli strappati    (ACT_CLAIM FORCE):   %d" % claims_forced)
	print("    Rivendicazioni morte senza essere usate:   %d" % (claims_made - claims_forced))
	print("  Caselle passate di mano in gioco (solo via Consequence):")
	for chronicle_id in ["CHR_01", "CHR_03"]:
		print("    %s: %d prese, %d lasciate a nessuno" % [
			chronicle_id, int(granted.get(chronicle_id, 0)), int(cleared.get(chronicle_id, 0))
		])

	# Le pietre: quello che una clausola puo' davvero chiedere. Si legge come la
	# tabella del controllo — se una colonna e' quasi zero la clausola che la
	# nomina e' un muro, se e' quasi uno e' un regalo.
	print("")
	print("  Pietre tenute a fine anno (media per partita):")
	var stone_houses: Array = stones.keys()
	stone_houses.sort()
	for entity_id in stone_houses:
		var row: Array = stones[entity_id] as Array
		var games: float = maxf(1.0, float(row[3]))
		print("    %-12s tutte %.2f   grado>=2 %.2f   grado>=3 %.2f" % [
			str(entity_id), float(row[0]) / games, float(row[1]) / games, float(row[2]) / games
		])
	print("  Per famiglia, su tutti i seggi e tutte le partite:")
	var families: Array = by_family.keys()
	families.sort()
	for family in families:
		print("    %-14s %d" % [str(family), int(by_family[family])])
	print("  Cosa succede alle pietre dentro l'anno, su %d partite:" % runs)
	print("    Alzate all'apertura:      %d" % raised_at_setup)
	print("    Alzate giocando:          %d" % raised_in_year)
	print("    Cambiate di grado:        %d" % regraded)
	print("    Abbattute:                %d" % razed)
	print("  Quante pietre tiene una casa, partita per partita:")
	var hist_keys: Array = stone_hist.keys()
	hist_keys.sort()
	for key in hist_keys:
		print("    %-20s %3d partite" % [str(key).replace("|", ": "), int(stone_hist[key])])
	print("  Cicatrici sulla mappa a fine anno:")
	var scar_keys: Array = scar_hist.keys()
	scar_keys.sort()
	for count in scar_keys:
		print("    %d cicatrici: %3d partite  (%.0f%%)" % [
			int(count), int(scar_hist[count]),
			100.0 * float(scar_hist[count]) / maxf(1.0, float(runs))
		])
	print("  Dove cadono, su %d partite:" % runs)
	var scarred: Array = scars_by_region.keys()
	scarred.sort()
	for where in scarred:
		print("    %-22s %d" % [str(where), int(scars_by_region[where])])

	# Le clausole che nessuno vede mai, in ordine di quanto spesso mancano.
	for level in ["victory", "triumph"]:
		print("")
		print("  Clausole di %s mai soddisfatte (su quante volte quel Destino e' stato giocato):" % level.to_upper())
		var rows: Array = []
		for key in missed:
			if not str(key).begins_with(level + "|"):
				continue
			var parts: PackedStringArray = str(key).split("|")
			var destiny_id: String = str(parts[1])
			var times: int = int(played.get(destiny_id, 1))
			rows.append({
				"share": float(missed[key]) / maxf(1.0, float(times)),
				"line": "    %3.0f%%  %-22s %s" % [
					100.0 * float(missed[key]) / maxf(1.0, float(times)), destiny_id, str(parts[2])
				],
			})
		rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return float(a["share"]) > float(b["share"])
		)
		for row in rows:
			print(str(row["line"]))
	quit(0)


static func _level_of(destiny: Dictionary, label: String) -> String:
	for level in LEVELS:
		for condition in (destiny[level] as Dictionary)["conditions"]:
			if str((condition as Dictionary).get("label", "")) == label:
				return level
	return "?"


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
