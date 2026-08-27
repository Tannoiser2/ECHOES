extends SceneTree
## Quante delle sessanta Tensioni scritte arrivano al tavolo.
##
##   godot --headless --path godot --script res://cli/run_tension_reach_probe.gd -- \
##       --runs=20 --seed=7000 --chronicle=CHR_01
##
## La scatola ha **60 carte Tensione**, dieci per Tema, e ognuna porta la sua
## Domanda, le sue proposte e le sue Conseguenze ([D-264](../docs/DECISIONS.md#d-264),
## [D-265](../docs/DECISIONS.md#d-265)). Il catalogo le conta tutte e sessanta.
##
## Questa sonda chiede l'altra meta' della domanda: **quante ne vede un
## giocatore.** Tre numeri, e vanno letti in quest'ordine:
##
## 1. **Quante Tensioni stanno sul tavolo** in una partita, e quante distinte
##    si vedono nell'arco di molte partite. Se il secondo numero non cresce, il
##    mazzo non gira: la scatola e' grande e la partita e' sempre la stessa.
## 2. **Dove arrivano**, contro la loro soglia: media, picco, spinte in su e in
##    giu'. Una Tensione che non arriva mai a soglia non apre mai il suo
##    Consiglio, e allora le sue Conseguenze sono contenuto che nessuno legge.
## 3. **Quante tengono davvero un Consiglio**, che e' l'unico modo in cui le
##    loro Conseguenze scrivono qualcosa nel mondo.
##
## Nata da [ISSUES 92](../docs/ISSUES.md): undici segni che nessun Destino
## vedeva mai comparire. La prima diagnosi diceva «propone solo il proponente»
## ed era **sbagliata** — la sonda ha trovato altro, e la storia sta in
## [D-317](../docs/DECISIONS.md#d-317).

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 20))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr("dati non caricati")
		quit(3)
		return

	var peak: Dictionary = {}
	var total: Dictionary = {}
	var moves: Dictionary = {}
	var on_table: Dictionary = {}
	var held: Dictionary = {}
	var sizes: Array = []
	var councils: int = 0
	var played: int = 0

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
		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
			if mixed else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return
		played += 1

		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(effect.get("type", "")) != "ADJUST_TENSION":
				continue
			var moved: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
			var delta: int = int((effect.get("payload", {}) as Dictionary).get("delta", 0))
			var key: String = "%s|%s" % [moved, "su" if delta > 0 else "giu"]
			moves[key] = int(moves.get(key, 0)) + absi(delta)

		# `last_proponent` porta una chiave per ogni Tensione che ha tenuto
		# almeno un Consiglio in quest'anno: e' il registro piu' diretto.
		for spoken in (session.world.get("last_proponent", {}) as Dictionary):
			held[str(spoken)] = int(held.get(str(spoken), 0)) + 1
		councils += int(session.world.get("confluence_count", 0))

		sizes.append((session.world["tensions"] as Dictionary).size())
		for tension_id in session.world["tensions"]:
			on_table[str(tension_id)] = int(on_table.get(str(tension_id), 0)) + 1
			var value: int = int(session.service.tension_value(str(tension_id)))
			total[str(tension_id)] = int(total.get(str(tension_id), 0)) + value
			peak[str(tension_id)] = maxi(int(peak.get(str(tension_id), 0)), value)

	var seen: int = maxi(1, played)
	var dealt: int = 0
	for count in sizes:
		dealt += int(count)

	print("")
	print("== QUANTE DELLE TENSIONI SCRITTE ARRIVANO AL TAVOLO ==")
	print("   %s, tavolo %s, %d partite, semi %d-%d" % [
		chronicle_id, "misto" if mixed else "uniforme",
		played, first_seed, first_seed + played - 1,
	])
	print("")
	print("  **Quante ne vede un giocatore**")
	print("    Tensioni sul tavolo, per partita        %6.1f" % [
		float(dealt) / float(maxi(1, sizes.size())),
	])
	print("    distinte viste in %d partite            %6d" % [played, on_table.size()])
	print("    scritte nella scatola                   %6d" % [data.tensions.size()])
	print("    **mai viste**                           %6d" % [
		data.tensions.size() - on_table.size(),
	])
	print("")
	print("  **Dove arrivano quelle che ci sono**")
	print("    %-20s %7s %8s %7s %8s %8s" % [
		"tensione", "soglia", "media", "picco", "spinte+", "spinte-",
	])
	var ids: Array = total.keys()
	ids.sort()
	for tension_id in ids:
		var definition: Variant = data.tensions.get(str(tension_id))
		var gate: int = 0
		if definition != null:
			gate = int((definition as Dictionary).get("threshold", 0))
		print("    %-20s %7d %8.2f %7d %8d %8d" % [
			str(tension_id), gate,
			float(int(total[tension_id])) / float(seen),
			int(peak[tension_id]),
			int(moves.get("%s|su" % tension_id, 0)),
			int(moves.get("%s|giu" % tension_id, 0)),
		])
	print("")
	print("  **Quante tengono davvero un Consiglio**")
	print("    Consigli aperti                         %6d" % [councils])
	print("    Tensioni che ne hanno tenuto uno        %6d   su %d nella scatola" % [
		held.size(), data.tensions.size(),
	])
	var spoken_ids: Array = held.keys()
	spoken_ids.sort()
	for tension_id in spoken_ids:
		print("      %-20s %d" % [str(tension_id), int(held[tension_id])])
	quit(0)


func _parse_args(argv: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for raw in argv:
		var argument: String = str(raw)
		if not argument.begins_with("--"):
			continue
		var body: String = argument.substr(2)
		var split: int = body.find("=")
		if split < 0:
			out[body] = true
		else:
			out[body.substr(0, split)] = body.substr(split + 1)
	return out
