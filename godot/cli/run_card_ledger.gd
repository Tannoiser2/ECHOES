extends SceneTree
## Il libro mastro delle carte.
##
##   godot --headless --path godot --script res://cli/run_card_ledger.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_01
##
## Il committente ha chiesto se le carte «fanno qualcosa» e se azioni ed effetti
## sono ben bilanciati. Lo statico lo dice a meta': le quarantotto carte hanno
## tutte un'azione e tutte un effetto proprio, e le sei famiglie portano la
## stessa identica scala di forza. Ma **avere** un mestiere non e' **esercitarlo**:
## una carta si spende per agire *oppure* si impegna al voto, e le due cose si
## escludono. Chi non fa mai ne' l'una ne' l'altra e' contenuto che non esiste,
## che e' la frase che questo progetto ha gia' scritto tre volte (D-035, ISSUES
## 56).
##
## Questa sonda conta, carta per carta, su cento anni:
##
##   · quante volte e' finita **in mano** a qualcuno;
##   · quante volte e' stata **calata per agire** (e allora l'azione ha girato);
##   · quante volte e' stata **impegnata al voto** (e allora l'effetto proprio ha
##     girato, che e' l'unico momento in cui gira).
##
## Il conto si prende dove i fatti succedono: un decisore che avvolge quello
## vero, delega ogni scelta e segna cosa ha scelto. Nessuna regola cambia, e il
## seme resta quello — l'avvolgente non consuma RNG.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


## L'avvolgente: delega tutto, segna due cose.
class Ledger extends RefCounted:
	var inner: RefCounted
	var played: Dictionary = {}
	var committed: Dictionary = {}

	func _init(p_inner: RefCounted) -> void:
		inner = p_inner

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		var request: Dictionary = inner.choose_action(entity_id, ao_index, session)
		if str(request.get("template", "")) == "PLAY_CARD":
			var asset_id: String = str((request.get("params", {}) as Dictionary).get("asset_id", ""))
			if asset_id != "":
				played[asset_id] = int(played.get(asset_id, 0)) + 1
		return request

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		var out: Array = inner.choose_commit(entity_id, context, limit, session)
		for asset_id in out:
			committed[str(asset_id)] = int(committed.get(str(asset_id), 0)) + 1
		return out

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return inner.choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		return inner.choose_proposition(context, options, session)

	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		return inner.choose_stance(entity_id, context, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return inner.choose_recovery(context, session)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr(data.describe_errors())
		quit(1)
		return

	# Il tavolo misto, come il cancello: i quattro caratteri di
	# `table_of_characters` giocano in modo diverso, e misurare le carte con
	# quattro ottimizzatori identici direbbe cosa fa **un** cervello, non cosa
	# fanno le carte.
	var mixed: bool = str(options.get("mixed", "1")) != "0"
	var ledger: Ledger = Ledger.new(null)
	var held: Dictionary = {}
	var years: int = 0

	for index in range(runs):
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr(session.last_error)
			session.dispose()
			continue
		ledger.inner = (
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		await session.run(ledger)
		# Quello che e' passato per una mano: la sonda lo prende dal registro
		# degli Effetti, che e' l'unica fonte di verita' su cosa e' successo.
		for entry in (session.world.get("effect_log", []) as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(effect.get("type", "")) != "GRANT_ASSET":
				continue
			var asset_id: String = str((effect.get("payload", {}) as Dictionary).get("asset_id", ""))
			if asset_id != "":
				held[asset_id] = int(held.get(asset_id, 0)) + 1
		years += 1
		session.dispose()

	_report(data, held, ledger, years)
	quit(0)


func _report(data: RefCounted, held: Dictionary, ledger: Ledger, years: int) -> void:
	print("")
	print("== IL LIBRO MASTRO DELLE CARTE - %d anni ==" % years)
	print("")

	var ids: Array = []
	for asset_id in data.assets:
		ids.append(str(asset_id))
	ids.sort()

	var rows: Array = []
	var mute_action: Array = []
	var mute_effect: Array = []
	var never: Array = []
	var by_family: Dictionary = {}
	var by_action: Dictionary = {}

	for asset_id in ids:
		var card: Dictionary = data.assets[asset_id] as Dictionary
		var hands: int = int(held.get(asset_id, 0))
		var plays: int = int(ledger.played.get(asset_id, 0))
		var votes: int = int(ledger.committed.get(asset_id, 0))
		rows.append([asset_id, str(card["title"]), str(card["family"]),
			str((card.get("card_action", {}) as Dictionary).get("kind", "—")),
			int(card["strength"]), hands, plays, votes])
		if hands == 0:
			never.append(str(card["title"]))
		else:
			if plays == 0:
				mute_action.append(str(card["title"]))
			if votes == 0:
				mute_effect.append(str(card["title"]))
		var fam: Array = by_family.get(str(card["family"]), [0, 0, 0]) as Array
		fam[0] += hands; fam[1] += plays; fam[2] += votes
		by_family[str(card["family"])] = fam
		var kind: String = str((card.get("card_action", {}) as Dictionary).get("kind", "—"))
		var act: Array = by_action.get(kind, [0, 0]) as Array
		act[0] += hands; act[1] += plays
		by_action[kind] = act

	rows.sort_custom(func(a, b): return int(a[6]) + int(a[7]) < int(b[6]) + int(b[7]))

	print("  carta                             fam    azione     f   in mano  calata  al voto")
	for row in rows:
		print("  %-32s %-6s %-10s %d   %6d  %6d  %7d" % [
			str(row[1]).substr(0, 32), str(row[2]).substr(0, 6), str(row[3]),
			int(row[4]), int(row[5]), int(row[6]), int(row[7]),
		])

	print("")
	print("  LE CARTE MUTE")
	print("    mai in mano a nessuno:        %d %s" % [never.size(), _list(never)])
	print("    mai calate per agire:         %d %s" % [mute_action.size(), _list(mute_action)])
	print("    mai impegnate al voto:        %d %s" % [mute_effect.size(), _list(mute_effect)])
	print("    (una carta mai impegnata e' una carta il cui effetto proprio non gira mai)")

	print("")
	print("  PER FAMIGLIA          in mano  calata  al voto   %% calate")
	var families: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]
	for family in families:
		var fam: Array = by_family.get(family, [0, 0, 0]) as Array
		print("    %-18s %6d  %6d  %7d    %5.1f%%" % [
			family, int(fam[0]), int(fam[1]), int(fam[2]),
			0.0 if int(fam[0]) == 0 else 100.0 * float(fam[1]) / float(fam[0]),
		])

	print("")
	print("  PER AZIONE            in mano  calata   %% calate")
	var kinds: Array = by_action.keys()
	kinds.sort()
	for kind in kinds:
		var act: Array = by_action[str(kind)] as Array
		print("    %-18s %6d  %6d    %5.1f%%" % [
			str(kind), int(act[0]), int(act[1]),
			0.0 if int(act[0]) == 0 else 100.0 * float(act[1]) / float(act[0]),
		])

	var total_hands: int = 0
	var total_plays: int = 0
	var total_votes: int = 0
	for row in rows:
		total_hands += int(row[5]); total_plays += int(row[6]); total_votes += int(row[7])
	print("")
	print("  IN TUTTO  %d carte pescate, %d calate (%.1f%%), %d impegnate (%.1f%%)" % [
		total_hands, total_plays,
		0.0 if total_hands == 0 else 100.0 * float(total_plays) / float(total_hands),
		total_votes,
		0.0 if total_hands == 0 else 100.0 * float(total_votes) / float(total_hands),
	])
	print("  Una carta pescata su %.1f non fa ne' l'una ne' l'altra: resta in mano." % (
		1.0 if total_plays + total_votes == 0
		else float(total_hands) / maxf(1.0, float(total_hands - total_plays - total_votes))
	))


func _list(names: Array) -> String:
	if names.is_empty():
		return ""
	var shown: Array = names.slice(0, mini(6, names.size()))
	var text: String = "— %s" % ", ".join(PackedStringArray(shown))
	return text if names.size() <= 6 else "%s, e altre %d" % [text, names.size() - 6]


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		var pair: PackedStringArray = text.substr(2).split("=")
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
