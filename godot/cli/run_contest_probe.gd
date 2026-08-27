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
##
## La quarta e' rimasta scritta qui e mai eseguita fino a 0.1.276: la sonda
## prometteva quattro domande e ne stampava tre. Adesso c'e', e guarda **due
## corsie**, perche' il punteggio ne ha due:
##
##   · la **mappa** — le Regioni che due Destini nominano insieme, e i posti
##     che due case si contendono davvero a fine anno;
##   · il **mondo** — le memorie che un Destino vuole e un altro teme.
##
## E la domanda che decide se il gioco e' una gara o un solitario a piu' mani:
## **quanti punti si sono presi senza che nessuno potesse impedirlo**. Una
## clausola centrata che nessun altro al tavolo aveva motivo di contrastare
## non e' una vittoria: e' un regalo che il calendario ha consegnato.
##
## E infine, la piu' dura: **i punti che avevi gia' prima di giocare.** Ogni
## clausola si valuta due volte — subito dopo il setup, prima di ogni mossa, e
## alla fine. Quella vera in entrambi i momenti non l'hai vinta: l'hai trovata
## nella dotazione. In 0.1.276 erano il 60.5% ([D-314](../../docs/DECISIONS.md#d-314)).

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
	# **Il tetto** (ISSUES 55, dopo [D-226](DECISIONS.md#d-226)). Riaccendere il
	# peso della terra al Consiglio non ha mosso la mappa, e la ragione e' che il
	# padrone lo decide la contesa di presenza e non il Consiglio. Allora la
	# domanda diventa: **quanto potrebbe muoversi?** Con `--presence=N` la sonda
	# gioca lo stesso seme con piu' pedine a testa, e se il numero non sale
	# nemmeno li' il collo di bottiglia non e' la quantita' di legno.
	var presence: int = int(options.get("presence", 0))

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

	# La quarta domanda: gli obiettivi si incrociano?
	var clash_map: int = 0        # coppie di seggi che vogliono la stessa Regione
	var clash_world: int = 0      # coppie che vogliono/temono la stessa memoria
	var tables: int = 0
	var won_map: int = 0          # clausole centrate che guardano la mappa
	var won_world: int = 0        # ...che guardano una memoria del mondo
	var won_house: int = 0        # ...che guardano quello che una casa porta addosso
	var free_points: int = 0      # clausole centrate che nessuno poteva contrastare
	var fought_points: int = 0
	var why: Dictionary = {}      # perche' una clausola risultava contesa
	var never: Dictionary = {}    # e di che tipo erano quelle mai contese
	# **I punti che avevi gia' prima di giocare.** Una clausola vera
	# all'apertura e ancora vera alla fine non l'hai vinta: l'hai trovata.
	var already: int = 0
	var earned: int = 0
	var found: Dictionary = {}    # di che tipo erano le clausole trovate gia' fatte
	# **Le memorie temute che qualcuno ha davvero provato a scrivere.** Non
	# «un altro Destino nomina quel segno» — quello e' un indizio sulla carta.
	# Questo si legge nel registro degli Effetti, **Regione per Regione**: la
	# memoria e' comparsa li' dove quella clausola la temeva, oppure no.
	var threatened: int = 0
	var untouched: int = 0
	var safe: Dictionary = {}     # e quali sono rimaste intoccate
	var hit: Dictionary = {}      # e quali il mondo ha scritto davvero

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		# L'override va messo **prima** di `setup()`: le pedine si posano li', e
		# da D-223 `presence_tokens` e' anche il tetto che l'applier fa rispettare.
		if presence > 0:
			(session.data.chronicles[chronicle_id] as Dictionary)["presence_tokens"] = presence
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(3)
			return

		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		contested_open += float(_contested(session))
		# Le clausole gia' vere **all'apertura**: prima che qualcuno giochi.
		# Servono a distinguere i punti vinti da quelli trovati nella dotazione.
		var at_open: Dictionary = {}
		for entity_id0 in session.world["entities"]:
			var seat0: Dictionary = session.world["entities"][str(entity_id0)] as Dictionary
			var destiny0: Variant = data.destinies.get(str(seat0.get("destiny_id", "")))
			if destiny0 == null:
				continue
			var mine0: Array = []
			_clauses(destiny0, mine0)
			for objective_id0 in (seat0.get("objectives", []) as Array):
				var objective0: Variant = data.objectives.get(str(objective_id0))
				if objective0 != null:
					_clauses(objective0, mine0)
			for clause0 in mine0:
				var c0: Dictionary = clause0 as Dictionary
				if session.destinies.conditions.holds(c0, {"self": str(entity_id0)}):
					at_open["%s|%s" % [str(entity_id0), JSON.stringify(c0)]] = true
		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return

		# Ogni memoria comparsa in quest'anno, col posto dove e' comparsa.
		var written: Dictionary = {}
		for entry in (session.world["effect_log"] as Array):
			var e: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var et: String = str(e.get("type", ""))
			if et != "SET_REGION_TAG" and et != "SET_GLOBAL_TAG" and et != "SET_ENTITY_TAG":
				continue
			var where: String = str((e.get("target", {}) as Dictionary).get("id", ""))
			var what: String = str((e.get("payload", {}) as Dictionary).get("tag", ""))
			written["%s|%s" % [where, what]] = true

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
		# --- 4. Gli obiettivi si incrociano? -------------------------------
		#
		# Si guarda il tavolo **vero**: i quattro seggi che hanno giocato questo
		# anno, coi Destini che hanno pescato loro. Due case che nominano la
		# stessa Regione si daranno battaglia; due che vogliono cose parallele
		# no. E per il mondo: uno vuole la memoria, l'altro la teme.
		tables += 1
		var wants: Dictionary = {}   # seggio -> {segno voluto}
		var fears: Dictionary = {}   # seggio -> {segno temuto}
		var places: Dictionary = {}  # seggio -> {Regione nominata}
		var seats_here: Array = []
		for entity_id in session.world["entities"]:
			var seat: Dictionary = session.world["entities"][str(entity_id)] as Dictionary
			var destiny: Variant = data.destinies.get(str(seat.get("destiny_id", "")))
			if destiny == null:
				continue
			seats_here.append(str(entity_id))
			var mine: Array = []
			_clauses(destiny, mine)
			for objective_id in (seat.get("objectives", []) as Array):
				var objective: Variant = data.objectives.get(str(objective_id))
				if objective != null:
					_clauses(objective, mine)
			for clause in mine:
				var c: Dictionary = clause as Dictionary
				var kind: String = str(c.get("type", ""))
				if kind == "state_tag_present" and str(c.get("tag", "")) != "":
					(wants.get_or_add(str(entity_id), {}) as Dictionary)[str(c["tag"])] = true
				elif kind == "state_tag_absent" and str(c.get("tag", "")) != "":
					(fears.get_or_add(str(entity_id), {}) as Dictionary)[str(c["tag"])] = true
				elif kind == "region_presence" and str(c.get("region_id", "")) != "":
					(places.get_or_add(str(entity_id), {}) as Dictionary)[str(c["region_id"])] = true
		for i in range(seats_here.size()):
			for j in range(i + 1, seats_here.size()):
				var a: String = str(seats_here[i])
				var b: String = str(seats_here[j])
				var pa: Dictionary = places.get(a, {}) as Dictionary
				var pb: Dictionary = places.get(b, {}) as Dictionary
				for region_id in pa:
					if pb.has(region_id):
						clash_map += 1
						break
				var wa: Dictionary = wants.get(a, {}) as Dictionary
				var fb: Dictionary = fears.get(b, {}) as Dictionary
				var wb: Dictionary = wants.get(b, {}) as Dictionary
				var fa: Dictionary = fears.get(a, {}) as Dictionary
				var crossed: bool = false
				for tag in wa:
					if fb.has(tag):
						crossed = true
						break
				if not crossed:
					for tag in wb:
						if fa.has(tag):
							crossed = true
							break
				if crossed:
					clash_world += 1

		# E i punti presi: di che corsia erano, e qualcuno poteva impedirli?
		for entity_id in seats_here:
			var seat2: Dictionary = session.world["entities"][str(entity_id)] as Dictionary
			var destiny2: Dictionary = data.destinies[str(seat2["destiny_id"])] as Dictionary
			var mine2: Array = []
			_clauses(destiny2, mine2)
			for objective_id in (seat2.get("objectives", []) as Array):
				var objective2: Variant = data.objectives.get(str(objective_id))
				if objective2 != null:
					_clauses(objective2, mine2)
			for clause in mine2:
				var c2: Dictionary = clause as Dictionary
				# La memoria temuta: qualcuno ha provato a scriverla **li'**?
				if str(c2.get("type", "")) == "state_tag_absent":
					var scope2: String = str(c2.get("scope", "GLOBAL"))
					var spot: String = "WORLD"
					if scope2 == "REGION":
						spot = str(c2.get("region_id", ""))
					elif scope2 == "ENTITY":
						spot = str(c2.get("entity_id", "$self"))
						if spot == "$self":
							spot = str(entity_id)
					var mark: String = str(c2.get("tag", ""))
					if written.has("%s|%s" % [spot, mark]):
						threatened += 1
						hit[mark] = int(hit.get(mark, 0)) + 1
					else:
						untouched += 1
						safe[mark] = int(safe.get(mark, 0)) + 1
				if not session.destinies.conditions.holds(c2, {"self": str(entity_id)}):
					continue
				if at_open.has("%s|%s" % [str(entity_id), JSON.stringify(c2)]):
					already += 1
					var kf: String = str(c2.get("type", ""))
					found[kf] = int(found.get(kf, 0)) + 1
				else:
					earned += 1
				match _lane(c2, data):
					"mappa": won_map += 1
					"mondo": won_world += 1
					"casa": won_house += 1
				# Qualcun altro al tavolo aveva un motivo scritto per impedirlo?
				var contested: bool = false
				var kind2: String = str(c2.get("type", ""))
				for other in seats_here:
					if str(other) == str(entity_id):
						continue
					if kind2 == "state_tag_present":
						if (fears.get(str(other), {}) as Dictionary).has(str(c2.get("tag", ""))):
							contested = true
					elif kind2 == "state_tag_absent":
						if (wants.get(str(other), {}) as Dictionary).has(str(c2.get("tag", ""))):
							contested = true
					elif kind2 == "region_presence":
						if (places.get(str(other), {}) as Dictionary).has(str(c2.get("region_id", ""))):
							contested = true
					elif kind2 == "control_count":
						# Le Regioni sono poche e le vogliono tutti: e' contesa
						# per scarsita', non per nome.
						contested = true
					if contested:
						break
				if contested:
					fought_points += 1
					why[kind2] = int(why.get(kind2, 0)) + 1
				else:
					free_points += 1
					never[kind2] = int(never.get(kind2, 0)) + 1

		session.dispose()

	var years: float = float(runs)
	print("")
	print("== LA LOTTA PER LA MAPPA - %d partite, %s, tavolo %s%s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme",
		"" if presence <= 0 else ", %d pedine a testa" % presence,
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
	# --- la quarta domanda, stampata --------------------------------------
	var couples: float = float(maxi(1, tables)) * 6.0   # 4 seggi -> 6 coppie
	var points: int = maxi(1, free_points + fought_points)
	var lanes: int = maxi(1, won_map + won_world + won_house)
	print("")
	print("  **Gli obiettivi si incrociano?**  (%d tavoli, 6 coppie per tavolo)" % tables)
	print("    coppie che si contendono una Regione   %5.1f%%   (%d)" % [
		100.0 * float(clash_map) / couples, clash_map,
	])
	print("    coppie che si contendono una memoria   %5.1f%%   (%d)" % [
		100.0 * float(clash_world) / couples, clash_world,
	])
	print("")
	print("  **Con cosa si sono presi i punti**")
	print("    clausole centrate sulla mappa          %5.1f%%   (%d)" % [
		100.0 * float(won_map) / float(lanes), won_map,
	])
	print("    clausole centrate sul mondo            %5.1f%%   (%d)" % [
		100.0 * float(won_world) / float(lanes), won_world,
	])
	print("    clausole centrate su quello che porti  %5.1f%%   (%d)" % [
		100.0 * float(won_house) / float(lanes), won_house,
	])
	print("")
	print("  **Quanti punti nessuno poteva impedire**")
	print("    clausole che qualcuno contendeva       %5.1f%%   (%d)" % [
		100.0 * float(fought_points) / float(points), fought_points,
	])
	print("    clausole che nessuno contendeva        %5.1f%%   (%d)" % [
		100.0 * float(free_points) / float(points), free_points,
	])
	print("")
	print("  **I punti che avevi gia' prima di giocare**")
	var got: int = maxi(1, already + earned)
	print("    clausole gia' vere all'apertura        %5.1f%%   (%d)" % [
		100.0 * float(already) / float(got), already,
	])
	print("    clausole conquistate giocando          %5.1f%%   (%d)" % [
		100.0 * float(earned) / float(got), earned,
	])
	print("")
	print("    contese, per tipo di clausola:")
	var wk: Array = why.keys(); wk.sort()
	for k in wk:
		print("      %-24s %d" % [str(k), int(why[k])])
	print("    mai contese, per tipo:")
	var nk: Array = never.keys(); nk.sort()
	for k in nk:
		print("      %-24s %d" % [str(k), int(never[k])])
	print("")
	print("  **Le memorie temute: qualcuno ha provato a scriverle?**")
	var fears_seen: int = maxi(1, threatened + untouched)
	print("    memorie temute che il mondo ha davvero scritto  %5.1f%%   (%d)" % [
		100.0 * float(threatened) / float(fears_seen), threatened,
	])
	print("    memorie temute che nessuno ha mai toccato       %5.1f%%   (%d)" % [
		100.0 * float(untouched) / float(fears_seen), untouched,
	])
	print("    per segno — scritte / mai toccate:")
	var sk: Array = safe.keys()
	for k in hit:
		if not sk.has(k):
			sk.append(k)
	sk.sort()
	for k in sk:
		var h: int = int(hit.get(k, 0))
		var u: int = int(safe.get(k, 0))
		print("      %-24s %4d / %4d   %s" % [
			str(k), h, u, "<-- MAI" if h == 0 else "",
		])
	print("")
	print("    gia' vere all'apertura, per tipo:")
	var fk: Array = found.keys(); fk.sort()
	for k in fk:
		print("      %-24s %d" % [str(k), int(found[k])])
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


## Le clausole che un Destino chiede, appiattite: `some_of` porta con se' le sue
## strade, e una strada e' una clausola come le altre.
func _clauses(node: Variant, out: Array) -> void:
	if node is Dictionary:
		var d: Dictionary = node as Dictionary
		if str(d.get("type", "")) != "" and str(d["type"]) != "some_of":
			out.append(d)
		for key in d:
			_clauses(d[key], out)
	elif node is Array:
		for item in (node as Array):
			_clauses(item, out)


## A quale corsia del punteggio guarda una clausola.
func _lane(clause: Dictionary, data: RefCounted) -> String:
	var kind: String = str(clause.get("type", ""))
	match kind:
		"region_presence", "control_count", "structure_count", "scar_count":
			return "mappa"
		"discovery_count", "relation_state":
			return "casa"
		"state_tag_present", "state_tag_absent":
			var tag: Variant = data.tags.get(str(clause.get("tag", "")))
			if tag == null:
				return "altro"
			var scope: Array = (tag as Dictionary).get("scope", []) as Array
			if scope.has("GLOBAL"):
				return "mondo"
			if scope.has("ENTITY"):
				return "casa"
			return "mappa"
	return "altro"




func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
