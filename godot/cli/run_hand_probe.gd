extends SceneTree
## L'economia della mano, se le carte le desse la mappa (proposta del committente).
##
##   godot --headless --path godot --script res://cli/run_hand_probe.gd -- \
##       --runs=60 --seed=7000 --chronicle=CHR_01
##
## «Tutte le azioni si fanno con le carte, e le carte si pescano a inizio atto a
## seconda della presenza in una regione: due presenze, due carte.»
##
## Questa sonda **non cambia nessuna regola**: gioca le partite come sono e, a
## inizio di ogni Atto, guarda dove stanno le pedine e scrive quante carte quel
## rubinetto darebbe. Serve a sapere il prezzo prima di riscrivere quarantotto
## carte, ed e' la stessa disciplina del banco delle clausole - misurare cosa
## costa una regola **prima** di scriverla.
##
## Le tre domande, nell'ordine in cui contano:
##
##   1. **quanto si stringe** - carte in un anno contro le 18 azioni di oggi;
##   2. **se il ciclo diverge** - piu' presenza da' piu' carte, piu' carte danno
##      piu' presenza: lo scarto fra il primo e l'ultimo cresce di atto in atto?
##   3. **chi resta a secco** - un seggio senza pedine non pesca, e da li' non
##      si rialza.
##
## E una quarta che e' venuta guardando i dati: se la Regione decide **quale**
## famiglia peschi, qualche famiglia diventa irraggiungibile per qualcuno?

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")

const FAMILIES: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 60))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var acts: int = int(data.chronicles[chronicle_id]["acts"])
	var per_round: int = int(data.chronicles[chronicle_id]["action_opportunities_per_round"])
	var rounds: int = int(data.chronicles[chronicle_id]["rounds_per_act"])
	var actions_today: int = acts * rounds * per_round

	print("SONDA DELLA MANO - %d Chronicle %s, semi da %d" % [runs, chronicle_id, first_seed])
	print("  Oggi ogni seggio ha %d azioni in un anno (%d atti x %d round x %d)." % [
		actions_today, acts, rounds, per_round
	])

	# per atto: [carte col rubinetto a pedina, carte a Regione, seggi a zero]
	var by_act: Array = []
	for _i in range(acts):
		by_act.append([0, 0, 0, 0])   # tokens, regions, zeri, quanti campioni
	var spread_by_act: Array = []     # atto -> somma degli scarti max-min
	for _i in range(acts):
		spread_by_act.append(0.0)
	var year_totals: Array = []       # carte in un anno, per seggio-partita
	var reach: Dictionary = {}        # famiglia -> quante volte raggiungibile
	# La mano **vera**, quando la Chronicle il rubinetto ce l'ha davvero acceso:
	# e' li' che si vede se il tetto comprime lo scarto o no (D-185).
	var real_hand: Array = []
	for _i in range(acts):
		real_hand.append([0.0, 0.0, 0])
	var seat_reach: Array = []        # quante famiglie distinte raggiunge un seggio
	# Dove stanno davvero le pedine: se una Regione non ne vede mai, le famiglie
	# che offre valgono come se non ci fossero (D-186).
	var tokens_by_region: Dictionary = {}
	# Il fabbisogno (richiesta del committente): «le carte per ogni atto devono
	# essere pescate in numero sufficiente per fare le stesse azioni e per
	# influenzare i concili come adesso». Due voci, per seggio e per anno:
	# le azioni che col nuovo sistema costerebbero una carta - cioe' tutte
	# tranne ACQUISIRE, che sparisce perche' la sostituisce il rubinetto - e le
	# carte impegnate ai Consigli, che gia' oggi costano.
	var acts_by_template: Dictionary = {}
	var actions_seen: Dictionary = {}
	# I contatori stanno in un Dizionario perche' le lambda di GDScript catturano
	# gli interi **per valore**: un `var` catturato non torna indietro.
	var tally: Dictionary = {"acted": 0, "committed": 0, "seat_years": 0}

	for run in range(runs):
		var session: RefCounted = GameSession.new(data)
		var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
		var seed_value: int = first_seed + run
		session.setup(chronicle_id, seats, seed_value)
		var table: RefCounted = Characters.deal(seats, session.rng, session.log)

		var year: Dictionary = {}
		var families_seen: Dictionary = {}
		session.chronicle.phase_changed.connect(
			func(act: int, round_number: int, phase: String) -> void:
				if phase != "ACTIONS" or round_number != 1:
					return
				var counts: Array = []
				for entity_id in seats:
					var presence: Array = (
						(session.world["entities"] as Dictionary)[str(entity_id)] as Dictionary
					).get("presence", []) as Array
					var tokens: int = presence.size()
					var regions: Dictionary = {}
					var mine: Dictionary = families_seen.get(str(entity_id), {})
					for region_id in presence:
						regions[str(region_id)] = true
						tokens_by_region[str(region_id)] = (
							int(tokens_by_region.get(str(region_id), 0)) + 1
						)
						for family in (data.regions[str(region_id)] as Dictionary).get(
							"asset_sources", []
						):
							mine[str(family)] = true
							reach[str(family)] = int(reach.get(str(family), 0)) + 1
					families_seen[str(entity_id)] = mine
					var row: Array = by_act[act - 1] as Array
					row[0] = int(row[0]) + tokens
					row[1] = int(row[1]) + regions.size()
					if tokens == 0:
						row[2] = int(row[2]) + 1
					row[3] = int(row[3]) + 1
					by_act[act - 1] = row
					counts.append(tokens)
					year[str(entity_id)] = int(year.get(str(entity_id), 0)) + tokens
				var hands: Array = []
				for entity_id in seats:
					hands.append(
						((session.world["entities"] as Dictionary)[str(entity_id)] as Dictionary).get(
							"hand", []
						).size()
					)
				hands.sort()
				var hand_row: Array = real_hand[act - 1] as Array
				var hand_sum: float = 0.0
				for value in hands:
					hand_sum += float(value)
				hand_row[0] = float(hand_row[0]) + hand_sum / float(hands.size())
				hand_row[1] = (
					float(hand_row[1]) + float(int(hands[hands.size() - 1]) - int(hands[0]))
				)
				hand_row[2] = int(hand_row[2]) + 1
				real_hand[act - 1] = hand_row
				counts.sort()
				spread_by_act[act - 1] = (
					float(spread_by_act[act - 1])
					+ float(int(counts[counts.size() - 1]) - int(counts[0]))
				)
		)
		session.effect_applied.connect(
			func(effect: Dictionary) -> void:
				var source: Dictionary = effect.get("source", {}) as Dictionary
				if str(source.get("kind", "")) != "action":
					return
				var template_id: String = str(source.get("id", ""))
				var key: String = "%s|%s|%d" % [
					template_id, str(source.get("actor", "")), int(source.get("sequence", 0))
				]
				if actions_seen.has(key):
					return
				actions_seen[key] = true
				acts_by_template[template_id] = int(acts_by_template.get(template_id, 0)) + 1
				# ACQUISIRE sparisce (lo sostituisce il rubinetto) e DISPLACED non
				# e' un'azione giocata: e' il contraccolpo di INFLUENZARE.
				if template_id != "ACT_ACQUIRE" and template_id != "ACT_INFLUENCE_DISPLACED":
					tally["acted"] = int(tally["acted"]) + 1
		)
		session.confluence.step_changed.connect(
			func(step: String, context: Dictionary) -> void:
				if step != "RESOLVED":
					return
				for entity_id in (context.get("commits", {}) as Dictionary):
					tally["committed"] = int(tally["committed"]) + (
						(context["commits"][entity_id] as Array).size()
					)
		)
		tally["seat_years"] = int(tally["seat_years"]) + seats.size()
		await session.run(table)
		for entity_id in year:
			year_totals.append(int(year[entity_id]))
		for entity_id in families_seen:
			seat_reach.append((families_seen[str(entity_id)] as Dictionary).size())
		session.dispose()
		if (run + 1) % 20 == 0:
			print("  %d/%d partite" % [run + 1, runs])

	print("")
	print("== 1. QUANTO SI STRINGE ==")
	var total: float = 0.0
	for value in year_totals:
		total += float(value)
	var average: float = total / float(maxi(1, year_totals.size()))
	print("  Carte in un anno, per seggio:  media %.1f   (oggi le azioni sono %d)" % [
		average, actions_today
	])
	print("  Il gioco si stringe a circa %d%% di quello che e' adesso." % [
		int(round(100.0 * average / float(actions_today)))
	])
	var least: int = 99
	var most: int = 0
	for value in year_totals:
		least = mini(least, int(value))
		most = maxi(most, int(value))
	print("  Dal seggio piu' povero al piu' ricco: da %d a %d carte." % [least, most])

	print("")
	print("== 2. IL CICLO DIVERGE? ==")
	print("  atto    carte medie a seggio    scarto medio fra primo e ultimo")
	for i in range(acts):
		var row: Array = by_act[i] as Array
		var samples: int = maxi(1, int(row[3]))
		print("   %d          %.2f                     %.2f" % [
			i + 1, float(row[0]) / float(samples), float(spread_by_act[i]) / float(runs),
		])
	print("  (se lo scarto cresce di atto in atto, chi parte avanti si allontana)")

	print("")
	print("== 2bis. LA MANO VERA, se il rubinetto e' acceso ==")
	print("  atto    carte in mano (media)    scarto fra la piu' piena e la piu' vuota")
	for i in range(acts):
		var row: Array = real_hand[i] as Array
		var samples: int = maxi(1, int(row[2]))
		print("   %d          %.2f                     %.2f" % [
			i + 1, float(row[0]) / float(samples), float(row[1]) / float(samples),
		])
	print("  (col rubinetto spento e' la mano di ACQUISIRE, e serve da metro di paragone)")
	print("")
	print("== 3. CHI RESTA A SECCO ==")
	for i in range(acts):
		var row: Array = by_act[i] as Array
		print("   atto %d: %d seggi senza nessuna pedina su %d" % [
			i + 1, int(row[2]), int(row[3])
		])

	print("")
	print("== 4. E QUALI CARTE, SE LE SCEGLIE LA MAPPA ==")
	var reach_total: float = 0.0
	for value in seat_reach:
		reach_total += float(value)
	print("  Famiglie diverse raggiungibili da un seggio in un anno: %.1f su 6" % [
		reach_total / float(maxi(1, seat_reach.size()))
	])
	for family in FAMILIES:
		print("    %-12s raggiunta %d volte" % [family, int(reach.get(family, 0))])

	print("")
	print("== 5. DOVE STANNO DAVVERO LE PEDINE ==")
	var placed: float = 0.0
	for region_id in tokens_by_region:
		placed += float(int(tokens_by_region[str(region_id)]))
	var region_ids: Array = data.regions.keys()
	region_ids.sort()
	var ranked: Array = []
	for region_id in region_ids:
		ranked.append([int(tokens_by_region.get(str(region_id), 0)), str(region_id)])
	ranked.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) > int(b[0]))
	for row in ranked:
		print("    %-24s %5d pedine  (%4.1f%%)  offre %s" % [
			str(row[1]), int(row[0]),
			100.0 * float(int(row[0])) / maxf(1.0, placed),
			(data.regions[str(row[1])] as Dictionary).get("asset_sources", [])
		])
	print("  (una Regione che non vede pedine non e' una sorgente: le sue famiglie non escono)")

	print("")
	print("== 6. IL FABBISOGNO: quante carte servono per giocare come adesso ==")
	var years: float = float(maxi(1, int(tally["seat_years"])))
	var per_seat_actions: float = float(int(tally["acted"])) / years
	var per_seat_commits: float = float(int(tally["committed"])) / years
	print("  Per seggio, in un anno:")
	print("    azioni che costerebbero una carta   %5.2f   (tutte tranne ACQUISIRE)" % [
		per_seat_actions
	])
	print("    carte impegnate ai Consigli         %5.2f" % [per_seat_commits])
	print("    ------------------------------------------")
	print("    fabbisogno                          %5.2f  carte l'anno, %.2f per Atto" % [
		per_seat_actions + per_seat_commits, (per_seat_actions + per_seat_commits) / float(acts)
	])
	var templates: Array = acts_by_template.keys()
	templates.sort()
	print("  Le azioni giocate, per tipo (tutto il tavolo, %d anni):" % [runs])
	for template_id in templates:
		print("    %-24s %d" % [str(template_id), int(acts_by_template[str(template_id)])])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var body: String = argument.substr(2)
		var split: int = body.find("=")
		if split == -1:
			out[body] = true
		else:
			out[body.substr(0, split)] = body.substr(split + 1)
	return out
