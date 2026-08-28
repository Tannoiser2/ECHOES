extends SceneTree
## Il sacchetto dei segnalini coperti (proposta del committente).
##
##   godot --headless --path godot --script res://cli/run_token_probe.gd -- \
##       --runs=60 --seed=7000 --chronicle=CHR_00
##
## «Ogni carta o azione fa pescare uno o piu' segnalini coperti che danno un
## valore a una tensione. A un certo punto, quando parte la Confluence, si
## girano, e la tensione col punteggio piu' alto viene dibattuta nel Consiglio.»
##
## Questa sonda **non cambia nessuna regola**. Gioca le partite come sono e, a
## fianco, tiene un mondo ombra: ogni volta che un seggio agisce pesca un
## segnalino dal sacchetto e lo posa coperto. Serve a sapere il prezzo prima di
## riscrivere §11, come il preventivo di ISSUES 47 (D-183).
##
## Il sacchetto esiste gia' nel gioco: la Deriva e' **nove gettoni mescolati col
## seme** (`drift_distribution`), pescati uno per round dal mondo. La proposta
## cambia due cose — **chi pesca** (i giocatori, agendo) e **quando si guarda**
## (al Consiglio, non subito) — e questa sonda misura entrambe.
##
## Le quattro domande:
##
##   1. **quanti segnalini** scendono in un anno, contro i 9 della Deriva di oggi;
##   2. **su quali domande** finiscono, e quanto e' squilibrato il mucchio;
##   3. **quanti Consigli** darebbe ciascuno dei tre inneschi (a orologio, a
##      quantita', a chiamata);
##   4. **quale domanda vincerebbe** il confronto al buio, e quante volte e'
##      **diversa** da quella che il gioco ha davvero dibattuto. Se e' sempre la
##      stessa, la regola nuova e' colore; se e' spesso diversa, e' un gioco
##      diverso.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")

## Le due composizioni del sacchetto che vale la pena confrontare: tutti i
## segnalini da 1 (com'e' la Deriva oggi) e un sacchetto misto, dove un segnalino
## puo' pesare 1, 2 o 3 — e allora girarli e' una sorpresa vera.
const FLAT: Array = [1, 1, 1, 1, 1, 1, 1, 1, 1]
const MIXED: Array = [1, 1, 1, 1, 2, 2, 2, 3, 3]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 60))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr("dati non validi: %s" % data.describe_errors())
		quit(1)
		return

	print("SONDA DEI SEGNALINI - %d Chronicle %s, semi da %d" % [
		runs, chronicle_id, first_seed
	])
	print("  Oggi la Deriva pesca 9 gettoni in un anno, uno per round, e li mostra.")

	var tally: Dictionary = {
		"tokens": 0,          # segnalini posati in tutto
		"seat_years": 0,
		"acts": 0,            # inneschi «a orologio, fine Atto»
		"rounds": 0,          # inneschi «a orologio, fine round»
		"councils": 0,        # Consigli veri, per il confronto
		"agreed": 0,          # ...in cui la domanda piu' calda coperta e' quella dibattuta
		"weight_flat": 0,
		"weight_mixed": 0,
	}
	var by_tension: Dictionary = {}
	var spread_by_act: Array = [0.0, 0.0, 0.0]
	var spread_samples: Array = [0, 0, 0]
	var quantity_hits: Dictionary = {}   # soglia N -> quanti inneschi in un anno

	for run in range(runs):
		var session: RefCounted = GameSession.new(data)
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		session.setup(chronicle_id, seats, seed_value)
		var table: RefCounted = Characters.deal(seats, session.rng, session.log)

		# Il sacchetto: la stessa composizione della Deriva, perche' e' la
		# distribuzione che il committente ha gia' tarato (D-047).
		var bag: Array = []
		for entry in (data.chronicles[chronicle_id]["drift_distribution"] as Array):
			for _i in range(int((entry as Dictionary)["count"])):
				bag.append(str((entry as Dictionary)["tension_id"]))

		var pile: Dictionary = {}        # tension_id -> somma coperta (sacchetto piatto)
		var pile_mixed: Dictionary = {}  # ...col sacchetto misto
		var placed: Array = [0]          # quanti segnalini in tutto, quest'anno

		# Ogni azione riuscita posa un segnalino. Le azioni si riconoscono dalla
		# firma dell'Effetto: `source.kind == "action"`, e una sola per azione
		# (gli Effetti di una stessa azione condividono la sequenza).
		var seen: Dictionary = {}
		session.effect_applied.connect(
			func(effect: Dictionary) -> void:
				var source: Dictionary = effect.get("source", {}) as Dictionary
				if str(source.get("kind", "")) != "action":
					return
				var key: String = "%s|%s|%d" % [
					str(source.get("id", "")), str(source.get("actor", "")),
					int(source.get("sequence", 0))
				]
				if seen.has(key):
					return
				seen[key] = true
				var drawn: String = str(bag[session.rng.range_int(0, bag.size() - 1)])
				var flat: int = int(FLAT[session.rng.range_int(0, FLAT.size() - 1)])
				var mixed: int = int(MIXED[session.rng.range_int(0, MIXED.size() - 1)])
				pile[drawn] = int(pile.get(drawn, 0)) + flat
				pile_mixed[drawn] = int(pile_mixed.get(drawn, 0)) + mixed
				by_tension[drawn] = int(by_tension.get(drawn, 0)) + 1
				placed[0] = int(placed[0]) + 1
				tally["tokens"] = int(tally["tokens"]) + 1
				tally["weight_flat"] = int(tally["weight_flat"]) + flat
				tally["weight_mixed"] = int(tally["weight_mixed"]) + mixed
		)

		# Il confronto che conta: quando un Consiglio si apre davvero, la domanda
		# piu' calda **del mucchio coperto** e' la stessa che il gioco dibatte?
		session.chronicle.confluence_resolved.connect(
			func(result: Dictionary) -> void:
				tally["councils"] = int(tally["councils"]) + 1
				var hottest: String = _hottest(pile, session.world["tensions"])
				if hottest != "" and hottest == str(result.get("tension_id", "")):
					tally["agreed"] = int(tally["agreed"]) + 1
		)

		session.chronicle.phase_changed.connect(
			func(act: int, round_number: int, phase: String) -> void:
				if phase != "THRESHOLD_CHECK":
					return
				tally["rounds"] = int(tally["rounds"]) + 1
				if round_number == int(data.chronicles[chronicle_id]["rounds_per_act"]):
					tally["acts"] = int(tally["acts"]) + 1
					var values: Array = []
					for tension_id in session.world["tensions"]:
						values.append(int(pile.get(str(tension_id), 0)))
					values.sort()
					if not values.is_empty():
						spread_by_act[act - 1] = (
							float(spread_by_act[act - 1])
							+ float(int(values[values.size() - 1]) - int(values[0]))
						)
						spread_samples[act - 1] = int(spread_samples[act - 1]) + 1
		)

		tally["seat_years"] = int(tally["seat_years"]) + seats.size()
		await session.run(table)
		# L'innesco «a quantita'»: quante volte in un anno si sarebbe girato, per
		# ogni soglia candidata. I segnalini scendono e non risalgono, quindi a
		# fine anno il conto e' una divisione.
		for threshold in [2, 3, 4, 6, 8]:
			quantity_hits[threshold] = (
				int(quantity_hits.get(threshold, 0)) + int(placed[0]) / int(threshold)
			)
		session.dispose()
		if (run + 1) % 20 == 0:
			print("  %d/%d partite" % [run + 1, runs])

	var years: float = float(maxi(1, runs))
	print("")
	print("== 1. QUANTI SEGNALINI SCENDONO ==")
	print("  In un anno, tutto il tavolo:  %.1f segnalini   (la Deriva ne pesca 9)" % [
		float(int(tally["tokens"])) / years
	])
	print("  Peso posato in un anno:  %.1f col sacchetto piatto,  %.1f col misto" % [
		float(int(tally["weight_flat"])) / years,
		float(int(tally["weight_mixed"])) / years,
	])
	print("  (oggi la Deriva ne mette 9: uno per round, sempre da 1)")
	print("  Il mondo si scalderebbe **%.1f volte** piu' in fretta col sacchetto piatto," % [
		float(int(tally["weight_flat"])) / years / 9.0
	])
	print("  **%.1f volte** con quello misto. Le soglie di oggi (4-7) andrebbero rifatte." % [
		float(int(tally["weight_mixed"])) / years / 9.0
	])

	print("")
	print("== 2. SU QUALI DOMANDE, E QUANTO E' STORTO IL MUCCHIO ==")
	var ids: Array = by_tension.keys()
	ids.sort_custom(func(a: String, b: String) -> bool:
		return int(by_tension[a]) > int(by_tension[b])
	)
	for tension_id in ids:
		var tension: Variant = data.tensions.get(str(tension_id))
		print("    %-28s %5.2f segnalini l'anno" % [
			str(tension_id) if tension == null else str((tension as Dictionary)["title"]),
			float(int(by_tension[str(tension_id)])) / years,
		])
	print("  Scarto fra il mucchio piu' alto e il piu' basso, a fine Atto:")
	for i in range(spread_by_act.size()):
		print("    atto %d   %.2f" % [
			i + 1, float(spread_by_act[i]) / float(maxi(1, int(spread_samples[i])))
		])

	print("")
	print("== 3. QUANTI CONSIGLI DAREBBE OGNI INNESCO ==")
	print("    a orologio, fine Atto        %.2f l'anno" % [float(int(tally["acts"])) / years])
	print("    a orologio, fine round       %.2f l'anno" % [float(int(tally["rounds"])) / years])
	for threshold in [2, 3, 4, 6, 8]:
		print("    a quantita', ogni %2d segnalini  %.2f l'anno" % [
			threshold, float(int(quantity_hits.get(threshold, 0))) / years
		])
	print("    il gioco di oggi (a soglia)  %.2f l'anno" % [
		float(int(tally["councils"])) / years
	])

	print("")
	print("== 4. LA DOMANDA PIU' CALDA E' QUELLA GIUSTA? ==")
	var councils: float = float(maxi(1, int(tally["councils"])))
	print("  Su %d Consigli veri, il mucchio coperto avrebbe scelto **la stessa**" % [
		int(tally["councils"])
	])
	print("  domanda %d volte: il %.0f%%." % [
		int(tally["agreed"]), 100.0 * float(int(tally["agreed"])) / councils
	])
	print("  (vicino al 100%% la regola nuova e' colore; lontano, e' un gioco diverso)")
	quit(0)


func _hottest(pile: Dictionary, live: Dictionary) -> String:
	var best: String = ""
	var most: int = -1
	var ids: Array = live.keys()
	ids.sort()
	for tension_id in ids:
		var value: int = int(pile.get(str(tension_id), 0))
		if value > most:
			most = value
			best = str(tension_id)
	return best


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
