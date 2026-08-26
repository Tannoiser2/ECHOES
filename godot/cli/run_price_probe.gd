extends SceneTree
## La sonda dell'economia del Consiglio (D-280, e la pedina di D-267).
##
##   godot --headless --path godot --script res://cli/run_price_probe.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_01
##
## La forma del dibattito voluta dal committente: il proponente sceglie le
## opportunita', **gli avversari scelgono i malus**. Questa sonda dice se la
## scelta esiste davvero al tavolo - quante pedine si posano, quante volte il
## prezzo scattato e' quello del fronte avverso e non quello del mondo, e
## quante volte il tavolo tace e il silenzio paga. Una regola mai esercitata
## e' contenuto che esiste nei dati e non esiste al tavolo (lezione di D-035).

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var councils: int = 0
	var pedine: int = 0
	var chosen_costs: int = 0
	var chosen_vents: int = 0
	var silences: int = 0
	var counterclaims: int = 0
	var claimed_voices: int = 0
	var second_debates_spent: int = 0
	var unfinished: int = 0
	# **Quante voci diverse arrivano davvero al tavolo** (D-278). Un menu che
	# esiste nei dati e non si vede giocando e' contenuto che non esiste: qui si
	# contano le parole distinte che i Consigli hanno davvero letto.
	var costs_said: Dictionary = {}
	var vents_said: Dictionary = {}
	var faces_seen: Dictionary = {}
	# **L'economia** (D-280): quanti benefici si comprano davvero, e quanto si
	# paga. Una carta che offre cinque benefici e ne vede comprare sempre uno e'
	# un'economia che al tavolo non esiste.
	var bought_total: int = 0
	var bought_councils: int = 0
	var bought_spread: Dictionary = {}
	var paid_total: int = 0
	var scars_taken: int = 0
	var wanted_bought: int = 0

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito al seme %d: %s" % [seed_value, session.last_error])
			quit(3)
			return
		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		if report.is_empty():
			unfinished += 1
		councils += int(session.world["confluence_count"])
		# **Il Consiglio ha dato al proponente qualcosa che voleva?** (D-289)
		# Si guarda il registro degli Effetti, non il verbale: la firma
		# `confluence` porta con se' chi proponeva, e il profilo dice cosa
		# quella casa vuole lasciare nel mondo.
		for entry in (session.world.get("effect_log", []) as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var source: Dictionary = effect.get("source", {}) as Dictionary
			if str(source.get("kind", "")) != "confluence":
				continue
			if not str(effect.get("type", "")).begins_with("SET_"):
				continue
			var tag: String = str((effect.get("payload", {}) as Dictionary).get("tag", ""))
			var profile: Variant = data.get("entity_profiles").get(str(source.get("actor", "")))
			if tag == "" or profile == null:
				continue
			for voice in (profile as Dictionary).get("wants", []) as Array:
				if str((voice as Dictionary).get("tag", "")) == tag:
					wanted_bought += 1
		for line in session.log.lines:
			var text: String = str(line)
			if text.contains(" compra: "):
				bought_councils += 1
				var how_many: int = text.split(" · ").size()
				bought_total += how_many
				bought_spread[how_many] = int(bought_spread.get(how_many, 0)) + 1
			elif text.contains("H. Prezzo: "):
				paid_total += 1
				if text.contains("Cicatrice"):
					scars_taken += 1
			elif text.contains("Il prezzo lo sceglie ") or text.contains("La pedina del prezzo -"):
				pedine += 1
				# «D. La pedina del prezzo - Casa: se passa con un costo, X; se cade, Y.»
				for piece in text.split(";"):
					if piece.contains("se passa con un costo,"):
						costs_said[piece.split("se passa con un costo,")[1].strip_edges()] = true
					elif piece.contains("se cade,"):
						vents_said[piece.split("se cade,")[1].strip_edges().trim_suffix(".")] = true
			elif text.contains("Il costo e' quello della pedina"):
				chosen_costs += 1
			elif text.contains("Lo sfogo e' quello della pedina"):
				chosen_vents += 1
			elif text.contains("Il tavolo tace: il silenzio avvantaggia"):
				silences += 1
			elif text.contains("La controproposta di"):
				counterclaims += 1
			elif text.contains("La voce rivendicata parla di"):
				claimed_voices += 1
			elif text.contains("nessun secondo dibattito"):
				second_debates_spent += 1
		for tension_id in session.world["tensions"]:
			if not (data.tensions[str(tension_id)].get("physical", {}) as Dictionary).is_empty():
				faces_seen[str(tension_id)] = true
		session.dispose()

	print("")
	print("== LA PEDINA DEL PREZZO - %d anni di %s, semi da %d ==" % [runs, chronicle_id, first_seed])
	print("")
	print("  Consigli                 %d" % councils)
	print("  Pedine posate            %d  (%.0f%% dei Consigli)" % [
		pedine, 100.0 * float(pedine) / float(maxi(1, councils))
	])
	print("  Il prezzo l'ha deciso il fronte avverso:")
	print("    costi (passa pagando)  %d" % chosen_costs)
	print("    sfoghi (proposta caduta) %d" % chosen_vents)
	print("  Il tavolo ha taciuto     %d volte" % silences)
	print("  Controproposte (D-268)   %d  (voci del beneficio rivendicate e passate: %d; secondi dibattiti spesi: %d)" % [
		counterclaims, claimed_voices, second_debates_spent
	])
	print("")
	print("  L'economia (D-280):")
	print("    Consigli in cui si e' comprato  %d su %d" % [bought_councils, councils])
	print("    benefici comprati               %d  (%.2f a Consiglio)" % [
		bought_total, float(bought_total) / float(maxi(1, bought_councils))
	])
	var spread: PackedStringArray = PackedStringArray()
	for how_many in bought_spread:
		spread.append("%dx%d" % [int(how_many), int(bought_spread[how_many])])
	print("    quanti alla volta               %s" % " ".join(spread))
	print("    prezzi pagati                   %d  (Cicatrici: %d)" % [paid_total, scars_taken])
	# **E quanti di quei benefici davano al proponente un segno che il suo
	# profilo dichiara di volere** (D-289). E' il posto dove la strategia
	# dichiarata dovrebbe mordere di piu', perche' al Consiglio si **compra**.
	print("    di cui un segno che il proponente voleva  %d" % wanted_bought)
	print("")
	print("  Voci del prezzo lette al tavolo (D-278):")
	print("    costi diversi          %d" % costs_said.size())
	print("    sfoghi diversi         %d" % vents_said.size())
	print("    carte con faccia viste %d" % faces_seen.size())
	if unfinished > 0:
		print("  Partite non concluse: %d su %d" % [unfinished, runs])
	quit(1 if unfinished > 0 else 0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
