extends SceneTree
## **Quante volte chi gioca arriva a un'Occasione senza carte** (ISSUES 136,
## parola del committente dopo un anno giocato a mano: *«ho passato l'atto 2 e 3
## senza carte in mano e ho dovuto passare, questo e' inaccettabile»*).
##
##   godot --headless --path godot --script res://cli/run_empty_hand_probe.gd -- \
##       --runs=40 --seed=7000
##
## La [sonda della mano](run_hand_probe.gd) misura **il rubinetto proposto**:
## quante carte darebbe la mappa. Questa misura **il rubinetto di adesso**, ed
## e' l'altra meta' della stessa domanda — quante volte, oggi, il gioco chiede
## a una persona di agire e la persona non ha niente in mano.
##
## Si conta a ogni Occasione, prima che il decisore scelga:
##
##   · **la mano** — quante carte ci sono;
##   · **a secco** — quante volte e' vuota;
##   · **passo** — quante volte la scelta e' passare, con e senza carte;
##   · e tutto **per Atto**, perche' il committente ha detto *«l'atto 2 e 3»* e
##     un numero medio sull'anno nasconderebbe proprio quello.
##
## **La sonda si prova prima di crederle** (regola di casa, sesta volta): un
## conto che torna zero e' quasi sempre cieco lui. Qui il controllo e' che le
## Occasioni contate siano 18 per seggio per anno, che e' il numero che la
## Chronicle promette; se non torna, la sonda guarda altrove e lo dice.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


## L'avvolgente: delega tutto, guarda la mano un attimo prima della scelta.
class Watcher extends RefCounted:
	var inner: RefCounted
	var session_ref: RefCounted
	var act_now: int = 1
	## per Atto: [occasioni, a secco, passi, passi a secco, carte in mano]
	var by_act: Dictionary = {}
	var seen: Dictionary = {}

	func _init(p_inner: RefCounted) -> void:
		inner = p_inner

	func _row(act: int) -> Array:
		if not by_act.has(act):
			by_act[act] = [0, 0, 0, 0, 0]
		return by_act[act] as Array

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		var act: int = int(session.world.get("act", 1))
		var hand: int = (session.service.hand(entity_id) as Array).size()
		var row: Array = _row(act)
		row[0] += 1
		row[4] += hand
		if hand == 0:
			row[1] += 1
		var request: Dictionary = inner.choose_action(entity_id, ao_index, session)
		var template: String = str(request.get("template", ""))
		seen[template] = int(seen.get(template, 0)) + 1
		if template == "" or template == "PASS":
			row[2] += 1
			if hand == 0:
				row[3] += 1
		return request

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
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr(data.describe_errors())
		quit(1)
		return

	var mixed: bool = str(options.get("mixed", "1")) != "0"
	var watcher: Watcher = Watcher.new(null)
	var years: int = 0
	var seats_count: int = 0

	for index in range(runs):
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		seats_count = seats.size()
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr(session.last_error)
			session.dispose()
			continue
		watcher.inner = (
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		await session.run(watcher)
		years += 1
		session.dispose()

	print("SONDA DELLA MANO VUOTA - %d anni, semi da %d, tavolo %s" % [
		years, first_seed, "misto" if mixed else "uniforme",
	])
	var total: int = 0
	for act in watcher.by_act:
		total += int((watcher.by_act[act] as Array)[0])
	print()
	print("  atto   occasioni   mano media   a secco        passa        passa a secco")
	for act in [1, 2, 3]:
		if not watcher.by_act.has(act):
			continue
		var row: Array = watcher.by_act[act] as Array
		var n: int = int(row[0])
		print("   %d      %6d      %5.2f      %4d (%4.1f%%)  %4d (%4.1f%%)  %4d (%4.1f%%)" % [
			act, n, float(row[4]) / maxf(1.0, float(n)),
			int(row[1]), 100.0 * float(row[1]) / maxf(1.0, float(n)),
			int(row[2]), 100.0 * float(row[2]) / maxf(1.0, float(n)),
			int(row[3]), 100.0 * float(row[3]) / maxf(1.0, float(n)),
		])
	print()
	print("  cosa sceglie davvero il decisore:")
	for t in watcher.seen:
		print("    %-24s %d" % [t if str(t) != "" else "(vuoto)", int(watcher.seen[t])])
	print()
	# **La prova che la sonda non e' cieca** (regola di casa): le Occasioni
	# contate devono essere quelle che la Chronicle promette. Se non tornano,
	# questa sonda sta guardando un altro posto e i suoi zeri non valgono.
	var promised: int = 0
	var chronicle: Variant = data.chronicles.get(chronicle_id)
	if chronicle != null:
		var c: Dictionary = chronicle as Dictionary
		promised = int(c.get("acts", 0)) * int(c.get("rounds_per_act", 0)) * 2 * seats_count * years
	print("  occasioni contate %d, promesse dalla Chronicle %d — %s" % [
		total, promised,
		"la sonda vede tutto il tavolo" if total == promised and promised > 0
		else "ATTENZIONE: la sonda guarda altrove, i suoi zeri non valgono",
	])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if not arg.begins_with("--"):
			continue
		var body: String = arg.substr(2)
		var eq: int = body.find("=")
		if eq < 0:
			out[body] = "1"
		else:
			out[body.substr(0, eq)] = body.substr(eq + 1)
	return out
