extends SceneTree
## **Chi partecipa davvero a un Consiglio** (D-451).
##
##   godot --headless --path godot --script res://cli/run_participation_probe.gd -- \
##       --runs=30 --seed=7000 [--out=FILE] [--no-abstain=support|oppose|condition]
##
## `--no-abstain` e' un **esperimento**, non una regola: risponde alla domanda
## del committente *«e se non ci si potesse astenere?»* sostituendo ogni
## ABSTAIN con la posizione detta — SUPPORT o OPPOSE (la lettura `condition`
## e' rimasta nel verbale di D-452, e con D-454 non esiste piu').
## Il documento generato con l'opzione lo dice in testa e non e' quello del
## cancello.
##
## Il cancello dei 100 semi conta i Consigli e i loro esiti, non chi ci
## partecipa: un Consiglio con tre astenuti conta verde quanto uno combattuto.
## La saga al seme 812 l'ha mostrato — trentatre' Consigli, tutti chiusi a
## opposizione zero, novantanove astensioni su novantanove prese di posizione.
## Il Consiglio si teneva, ma non era un dibattito: era una firma.
##
## Questa sonda gioca gli stessi anni del cancello, sui due tavoli, e per ogni
## Consiglio guarda **chi non propone**: che posizione prende, quante carte
## impegna, e se alla fine sul piatto c'e' un'opposizione che pesa. Il numero
## che decide e' l'ultimo: **Consigli con opposizione nel margine**. Se e' zero
## su un tavolo intero, lo script che la chiama esce rosso.
##
## Un cane da guardia si siede fra il cervello e il Consiglio e conta senza
## decidere niente, come in `run_boxes_probe`. Le prese di posizione passano
## di li'; i totali del margine li dice il registro dei Consigli risolti, che
## e' l'unica fonte di verita' su quanto ha pesato ognuno.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const STANCES: Array = ["SUPPORT", "OPPOSE", "ABSTAIN"]


## Il cane da guardia: inoltra tutto, e annota posizioni e impegni per Consiglio.
class Spy extends RefCounted:
	var inner: RefCounted
	## Un record per Consiglio, nell'ordine in cui si aprono:
	## {proponent, stances: {entity: stance}, commits: {entity: n}}
	var councils: Array = []
	## L'esperimento: "" gioca com'e'; altrimenti ogni ABSTAIN diventa questo.
	var forced: String = ""
	var forced_count: int = 0

	func _init(who: RefCounted, p_forced: String = "") -> void:
		inner = who
		forced = p_forced

	func _current(context: Dictionary) -> Dictionary:
		var proponent: String = str(context.get("proponent", ""))
		if councils.is_empty() or str((councils.back() as Dictionary)["closed"]) == "yes":
			councils.append({"proponent": proponent, "stances": {}, "commits": {}, "closed": "no"})
		return councils.back() as Dictionary

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		return await inner.choose_action(entity_id, ao_index, session)

	## Il Consiglio si chiude quando il registro lo risolve: e' il segnale
	## `confluence_resolved`, non la domanda scelta — con una sola domanda
	## eleggibile il controllore non chiede niente a nessuno, e due Consigli
	## finivano in un record solo (la prima stesura era cieca cosi').
	func close() -> void:
		if not councils.is_empty():
			(councils.back() as Dictionary)["closed"] = "yes"

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_proposition(context, options, session)

	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		var declared: Dictionary = await inner.choose_stance(entity_id, context, session)
		if forced != "" and str(declared.get("stance", "ABSTAIN")) == "ABSTAIN":
			forced_count += 1
			match forced:
				"support":
					declared = {"stance": "SUPPORT", "clause_id": ""}
				"oppose":
					declared = {"stance": "OPPOSE", "clause_id": ""}
		var record: Dictionary = _current(context)
		(record["stances"] as Dictionary)[entity_id] = str(declared.get("stance", "ABSTAIN"))
		return declared

	func choose_commit(
		entity_id: String, context: Dictionary, limit: int, session: RefCounted
	) -> Array:
		var committed: Array = await inner.choose_commit(entity_id, context, limit, session)
		var record: Dictionary = _current(context)
		(record["commits"] as Dictionary)[entity_id] = committed.size()
		return committed

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return await inner.choose_recovery(context, session)

	func choose_benefits(
		entity_id: String, context: Dictionary, menu: Array, session: RefCounted
	) -> Array:
		return await inner.choose_benefits(entity_id, context, menu, session)

	func choose_costs(
		entity_id: String, context: Dictionary, menu: Array, due: int, session: RefCounted
	) -> Array:
		return await inner.choose_costs(entity_id, context, menu, due, session)

	func choose_cost_token(
		entity_id: String, context: Dictionary, menu: Array, session: RefCounted
	) -> String:
		return await inner.choose_cost_token(entity_id, context, menu, session)

	func choose_counterclaim(
		entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted
	) -> Dictionary:
		return await inner.choose_counterclaim(entity_id, context, offer, session)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 30))
	var first_seed: int = int(options.get("seed", 7000))
	var out_path: String = str(options.get("out", ""))
	var forced: String = str(options.get("no-abstain", ""))
	if forced != "" and not ["support", "oppose"].has(forced):
		printerr("--no-abstain vuole support o oppose")
		quit(4)
		return

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var mixed: Dictionary = await _play(data, runs, first_seed, true, forced)
	var same: Dictionary = await _play(data, runs, first_seed, false, forced)
	if bool(mixed["blind"]) or bool(same["blind"]):
		quit(3)
		return

	var lines: Array = _document(runs, first_seed, mixed, same, data, forced)
	var text: String = "\n".join(PackedStringArray(lines)) + "\n"
	if out_path == "":
		print(text)
	else:
		var handle: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
		if handle == null:
			printerr("non scrivo %s" % out_path)
			quit(3)
			return
		handle.store_string(text)
		handle.close()

	# **Il cancello**: un tavolo intero senza un'opposizione che pesa nel
	# margine e' un Consiglio che nessuno gioca. Esce 2, e lo script lo dice.
	var opposed_mixed: int = int(mixed["opposed"])
	var opposed_same: int = int(same["opposed"])
	print("opposizione nel margine: misto %d su %d, uniforme %d su %d" % [
		opposed_mixed, int(mixed["councils"]), opposed_same, int(same["councils"])
	])
	if opposed_mixed == 0 or opposed_same == 0:
		printerr("ROSSO: un tavolo intero senza opposizione nel margine")
		quit(2)
		return
	quit(0)


func _play(data: RefCounted, runs: int, first_seed: int, mixed: bool, forced: String = "") -> Dictionary:
	var out: Dictionary = {
		"councils": 0, "opposed": 0, "declared_opposed": 0, "silent": 0, "forced": 0,
		"stances": {}, "by_seat": {}, "by_character": {},
		"cards_proponent": 0, "cards_others": 0, "others_with_cards": 0, "others": 0,
		"outcomes": {}, "margin_sum": 0, "bought": 0, "blind": false,
	}
	for index in range(runs):
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		session.setup("CHR_00", seats, seed_value)
		var table: RefCounted = null
		var decider: RefCounted = null
		if mixed:
			table = Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
			decider = table
		else:
			decider = PolicyDecider.new(session.log)
		var spy: Spy = Spy.new(decider, forced)
		session.chronicle.confluence_resolved.connect(func(_result: Dictionary) -> void: spy.close())
		var report: Dictionary = await session.run(spy)
		var results: Array = report["confluences"] as Array
		# Il cane conta i Consigli aperti; il registro quelli risolti. Se non
		# combaciano la sonda e' cieca, e lo dice invece di dare zero.
		if spy.councils.size() != results.size():
			printerr("sonda cieca: %d Consigli visti, %d risolti (seme %d)" % [
				spy.councils.size(), results.size(), seed_value
			])
			out["blind"] = true
			session.dispose()
			return out
		for i in range(results.size()):
			_count(out, spy.councils[i] as Dictionary, results[i] as Dictionary, seats, table)
		out["forced"] = int(out["forced"]) + spy.forced_count
		session.dispose()
	return out


func _count(out: Dictionary, seen: Dictionary, result: Dictionary, seats: Array, table: RefCounted) -> void:
	out["councils"] = int(out["councils"]) + 1
	var proponent: String = str(seen["proponent"])
	var stances: Dictionary = seen["stances"] as Dictionary
	var commits: Dictionary = seen["commits"] as Dictionary
	var silent: bool = true
	var declared_opposed: bool = false
	for entity_id in seats:
		var seat: String = str(entity_id)
		if seat == proponent:
			out["cards_proponent"] = int(out["cards_proponent"]) + int(commits.get(seat, 0))
			continue
		var stance: String = str(stances.get(seat, "ABSTAIN"))
		out["stances"][stance] = int(out["stances"].get(stance, 0)) + 1
		var by_seat: String = "%s/%s" % [seat, stance]
		out["by_seat"][by_seat] = int(out["by_seat"].get(by_seat, 0)) + 1
		if table != null:
			var by_character: String = "%s/%s" % [str(table.names[seat]), stance]
			out["by_character"][by_character] = int(out["by_character"].get(by_character, 0)) + 1
		if stance != "ABSTAIN":
			silent = false
		if stance == "OPPOSE":
			declared_opposed = true
		out["others"] = int(out["others"]) + 1
		var cards: int = int(commits.get(seat, 0))
		out["cards_others"] = int(out["cards_others"]) + cards
		if cards > 0:
			out["others_with_cards"] = int(out["others_with_cards"]) + 1
	if silent:
		out["silent"] = int(out["silent"]) + 1
	if declared_opposed:
		out["declared_opposed"] = int(out["declared_opposed"]) + 1
	# **L'opposizione che pesa**: carte contro nel margine, o un gettone
	# comprato contro (D-419). Una posizione dichiarata e non pagata non e' qui.
	var weight: int = int(result.get("oppose_total", 0)) + int(result.get("bought_opposition", 0))
	if weight > 0:
		out["opposed"] = int(out["opposed"]) + 1
	out["bought"] = int(out["bought"]) + int(result.get("bought_opposition", 0))
	out["margin_sum"] = int(out["margin_sum"]) + int(result.get("margin", 0))
	var band: String = str(result.get("outcome", ""))
	out["outcomes"][band] = int(out["outcomes"].get(band, 0)) + 1


func _document(runs: int, first_seed: int, mixed: Dictionary, same: Dictionary, data: RefCounted, forced: String = "") -> Array:
	var lines: Array = []
	lines.append("# Misura della partecipazione — chi gioca davvero un Consiglio")
	lines.append("")
	if forced != "":
		lines.append("> **ESPERIMENTO `--no-abstain=%s`**: ogni ABSTAIN e' stato sostituito (%d volte" % [forced, int(mixed["forced"])])
		lines.append("> sul misto, %d sull'uniforme). Non e' il documento del cancello." % int(same["forced"]))
		lines.append("")
	lines.append("Generato da `tools/run_participation_probe.sh` (D-451). **Non si scrive a mano.**")
	lines.append("")
	lines.append("%d anni pescati di CHR_00, semi da %d, sui due tavoli del cancello: **misto**" % [runs, first_seed])
	lines.append("(quattro caratteri diversi) e **uniforme** (quattro ottimizzatori). Per ogni")
	lines.append("Consiglio si guarda chi **non** propone: che posizione prende, quante carte")
	lines.append("impegna, e se alla fine sul piatto c'e' un'opposizione che pesa nel margine.")
	lines.append("")
	lines.append("Il cancello dei 100 semi conta i Consigli e i loro esiti, non chi ci partecipa:")
	lines.append("un Consiglio con tre astenuti conta verde quanto uno combattuto. Questa misura")
	lines.append("conta l'altra cosa. **Il numero che decide e' l'ultima riga della prima tabella**:")
	lines.append("se su un tavolo intero e' zero, il cancello e' rosso.")
	lines.append("")
	lines.append("## Il conto")
	lines.append("")
	lines.append("| | misto | uniforme |")
	lines.append("|---|---|---|")
	lines.append("| Consigli | %d | %d |" % [int(mixed["councils"]), int(same["councils"])])
	lines.append("| prese di posizione dei non proponenti | %d | %d |" % [int(mixed["others"]), int(same["others"])])
	for stance in STANCES:
		lines.append("| — %s | %s | %s |" % [
			stance, _share(int(mixed["stances"].get(stance, 0)), int(mixed["others"])),
			_share(int(same["stances"].get(stance, 0)), int(same["others"])),
		])
	lines.append("| Consigli col tavolo in silenzio (tutti astenuti) | %s | %s |" % [
		_share(int(mixed["silent"]), int(mixed["councils"])),
		_share(int(same["silent"]), int(same["councils"])),
	])
	lines.append("| Consigli con un OPPOSE dichiarato | %s | %s |" % [
		_share(int(mixed["declared_opposed"]), int(mixed["councils"])),
		_share(int(same["declared_opposed"]), int(same["councils"])),
	])
	lines.append("| carte impegnate dal proponente, per Consiglio | %.2f | %.2f |" % [
		_per(int(mixed["cards_proponent"]), int(mixed["councils"])),
		_per(int(same["cards_proponent"]), int(same["councils"])),
	])
	lines.append("| carte impegnate dagli altri tre, per Consiglio | %.2f | %.2f |" % [
		_per(int(mixed["cards_others"]), int(mixed["councils"])),
		_per(int(same["cards_others"]), int(same["councils"])),
	])
	lines.append("| non proponenti che impegnano almeno una carta | %s | %s |" % [
		_share(int(mixed["others_with_cards"]), int(mixed["others"])),
		_share(int(same["others_with_cards"]), int(same["others"])),
	])
	lines.append("| gettoni di opposizione comprati (D-419) | %d | %d |" % [int(mixed["bought"]), int(same["bought"])])
	lines.append("| margine medio | %.2f | %.2f |" % [
		_per(int(mixed["margin_sum"]), int(mixed["councils"])),
		_per(int(same["margin_sum"]), int(same["councils"])),
	])
	lines.append("| **Consigli con opposizione nel margine** | **%s** | **%s** |" % [
		_share(int(mixed["opposed"]), int(mixed["councils"])),
		_share(int(same["opposed"]), int(same["councils"])),
	])
	lines.append("")
	lines.append("## Gli esiti")
	lines.append("")
	lines.append("| esito | misto | uniforme |")
	lines.append("|---|---|---|")
	var bands: Array = []
	for band in mixed["outcomes"]:
		if not bands.has(str(band)):
			bands.append(str(band))
	for band in same["outcomes"]:
		if not bands.has(str(band)):
			bands.append(str(band))
	bands.sort()
	for band in bands:
		lines.append("| %s | %d | %d |" % [
			str(band), int(mixed["outcomes"].get(band, 0)), int(same["outcomes"].get(band, 0))
		])
	lines.append("")
	lines.append("## Chi si astiene, seggio per seggio")
	lines.append("")
	lines.append("Le posizioni di ogni casa quando non propone, sui due tavoli.")
	lines.append("")
	lines.append("| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |")
	lines.append("|---|---|---|---|---|")
	var seats: Array = []
	for key in mixed["by_seat"]:
		var seat: String = str(key).split("/")[0]
		if not seats.has(seat):
			seats.append(seat)
	for key in same["by_seat"]:
		var seat: String = str(key).split("/")[0]
		if not seats.has(seat):
			seats.append(seat)
	seats.sort()
	for seat in seats:
		var name: String = str((data.entities.get(seat, {}) as Dictionary).get("name", seat))
		for pair in [["misto", mixed], ["uniforme", same]]:
			var tally: Dictionary = (pair[1] as Dictionary)["by_seat"] as Dictionary
			var cells: Array = []
			for stance in STANCES:
				cells.append(str(int(tally.get("%s/%s" % [seat, stance], 0))))
			lines.append("| %s | %s | %s |" % [name, str(pair[0]), " | ".join(PackedStringArray(cells))])
	lines.append("")
	lines.append("## E carattere per carattere, sul tavolo misto")
	lines.append("")
	lines.append("| carattere | SUPPORT | OPPOSE | ABSTAIN |")
	lines.append("|---|---|---|---|")
	for character in Characters.NAMES:
		var cells: Array = []
		for stance in STANCES:
			cells.append(str(int(mixed["by_character"].get("%s/%s" % [str(character), stance], 0))))
		lines.append("| %s | %s |" % [str(character), " | ".join(PackedStringArray(cells))])
	lines.append("")
	lines.append("## Come leggerla")
	lines.append("")
	lines.append("- Una **posizione dichiarata** (OPPOSE) e una **opposizione nel")
	lines.append("  margine** sono due cose: la seconda vuole carte impegnate contro, o un gettone")
	lines.append("  comprato contro (D-419). Un OPPOSE a mani vuote non sposta niente.")
	lines.append("- Col tavolo in silenzio il proponente prende il bonus del silenzio-assenso")
	lines.append("  (PZ-5, D-267): un Consiglio dove nessuno parla non e' neutro.")
	lines.append("- Le sedie automatiche prendono posizione solo quando la proposta tocca il loro")
	lines.append("  Destino. L'economia di D-280 — gli avversari scelgono in che moneta paga il")
	lines.append("  proponente — c'e' dalla 0.1.308 (ISSUES 72): questa misura dice quanto viene")
	lines.append("  giocata davvero.")
	return lines


func _share(part: int, whole: int) -> String:
	if whole <= 0:
		return "—"
	return "%d (%.0f%%)" % [part, 100.0 * float(part) / float(whole)]


func _per(total: int, count: int) -> float:
	return 0.0 if count <= 0 else float(total) / float(count)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if arg.begins_with("--"):
			var pair: PackedStringArray = arg.substr(2).split("=", true, 1)
			out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "true"
	return out
