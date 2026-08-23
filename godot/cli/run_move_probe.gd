extends SceneTree
## Perche' le pedine non si muovono? (ISSUES 48)
##
##   godot --headless --path godot --script res://cli/run_move_probe.gd -- \
##       --runs=40 --seed=6000 --chronicle=CHR_01
##
## La mappa di fine anno e' quasi quella d'inizio, e per due volte un rimedio
## misurato non ha spostato niente ([D-186](DECISIONS.md#d-186),
## [D-205](DECISIONS.md#d-205)): un Pedaggio sulla Strada dei Mercanti e un
## cervello che conta anche i domini. Zero e zero. Vuol dire che la causa non
## era dove la cercavano.
##
## Questa sonda non chiede **dove** vanno le pedine: chiede **perche' non
## partono**. Per ogni occasione in cui un seggio poteva muovere, registra
## quale delle porte era chiusa:
##
##   · **il gettone** — sono gia' tutte sul tavolo, muovere vorrebbe dire
##     togliere una pedina da dove vive;
##   · **la carta** — nel gioco a carte MUOVERE si pronuncia solo con una
##     carta MUOVERE in mano (D-188), e in mazzo ce ne sono 11 su 48;
##   · **la porta** — cacciata (D-067), segno che sbarra (ISSUES 24),
##     adiacenza, o Regione piena;
##   · **la voglia** — tutto era possibile e il seggio ha scelto altro.
##
## L'ultima colonna e' quella che decide se ISSUES 48 e' un problema di
## regole o di cervello.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 6000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var cap: int = int(data.chronicles[chronicle_id]["presence_tokens"])

	var placed_open: Dictionary = {}
	var placed_close: Dictionary = {}
	var spare_at_open: int = 0
	var moves_placing: int = 0
	var moves_relocating: int = 0
	var move_cards_drawn: int = 0
	var move_cards_played: int = 0
	# Le porte chiuse, contate una volta per occasione d'azione.
	var blocked_token: int = 0
	var blocked_card: int = 0
	var blocked_door: int = 0
	var chose_other: int = 0
	var occasions: int = 0
	# Il tavolo cambia a ogni seme (D-213) ma quanti siedono no: si tiene la
	# **dimensione**, che e' l'unica cosa che serve per fare le medie per seggio.
	var seats_per_table: int = 0

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
		for entity_id in seats:
			var here: Array = session.service.regions_with_presence(str(entity_id))
			for region_id in here:
				placed_open[str(region_id)] = int(placed_open.get(str(region_id), 0)) + 1
			spare_at_open += cap - session.service.tokens_placed(str(entity_id))
		session.dispose()

		# La partita vera, con lo stesso seme: la posizione d'apertura sopra e'
		# la stessa che `run()` ricostruisce, e serviva solo a contarla prima
		# che qualcuno la tocchi.
		session = GameSession.new(data)
		session.setup(chronicle_id, seats, seed_value)
		var decider: RefCounted = (
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		var report: Dictionary = await session.run(decider)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return

		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(effect.get("type", "")) != "ADD_PRESENCE":
				continue
			if str((effect.get("source", {}) as Dictionary).get("kind", "")) == "SETUP":
				continue
		for entity_id in seats:
			for region_id in session.service.regions_with_presence(str(entity_id)):
				placed_close[str(region_id)] = int(placed_close.get(str(region_id), 0)) + 1

		var counted: Dictionary = _read_the_log(session.log.text())
		moves_placing += int(counted["placing"])
		moves_relocating += int(counted["relocating"])
		move_cards_played += int(counted["placing"]) + int(counted["relocating"])
		move_cards_drawn += _move_cards_seen(session, data)

		var doors: Dictionary = _doors(session, data, seats, cap)
		occasions += int(doors["occasions"])
		blocked_token += int(doors["token"])
		blocked_card += int(doors["card"])
		blocked_door += int(doors["door"])
		chose_other += int(doors["other"])
		seats_per_table = seats.size()
		session.dispose()

	print("")
	print("== PERCHE' LE PEDINE NON SI MUOVONO - %d partite, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme"
	])
	print("  Pedine per casa: %d all'apertura, tetto %d — **%.2f di riserva** per seggio" % [
		cap - (spare_at_open / maxi(1, runs * seats_per_table)), cap,
		float(spare_at_open) / float(maxi(1, runs * seats_per_table))
	])
	print("")
	print("  MUOVERE giocate: %.2f l'anno — %.2f posano, %.2f spostano" % [
		float(moves_placing + moves_relocating) / float(runs),
		float(moves_placing) / float(runs),
		float(moves_relocating) / float(runs),
	])
	print("  Carte MUOVERE viste in mano: %.2f l'anno, giocate %.2f" % [
		float(move_cards_drawn) / float(runs), float(move_cards_played) / float(runs)
	])
	print("")
	print("  A fine anno, su %d occasioni di seggio:" % occasions)
	_door("il gettone (tutte gia' sul tavolo)", blocked_token, occasions)
	_door("la carta (nessuna MUOVERE in mano)", blocked_card, occasions)
	_door("la porta (cacciata, segno, adiacenza, pieno)", blocked_door, occasions)
	_door("la voglia (poteva, ha scelto altro)", chose_other, occasions)
	print("")
	print("  Presenze per Regione, apertura -> fine:")
	var regions: Array = (data.chronicles[chronicle_id]["regions"] as Array).duplicate()
	regions.sort()
	for region_id in regions:
		var open_count: int = int(placed_open.get(str(region_id), 0))
		var close_count: int = int(placed_close.get(str(region_id), 0))
		print("    %-24s %5.2f -> %5.2f   %s" % [
			str(data.regions[str(region_id)]["name"]),
			float(open_count) / float(runs), float(close_count) / float(runs),
			"DESERTA" if close_count == 0 else ""
		])
	quit(0)


func _door(label: String, count: int, total: int) -> void:
	print("    %-46s %5d   %5.1f%%" % [
		label, count, 100.0 * float(count) / float(maxi(1, total))
	])


## Le due righe che il resolver scrive quando MUOVERE riesce (D-030): «pone un
## token» e «sposta un token». Contarle dal verbale invece che dagli Effect
## distingue posare da spostare senza aggiungere un campo al mondo.
static func _read_the_log(text: String) -> Dictionary:
	var placing: int = 0
	var relocating: int = 0
	for line in text.split("\n"):
		if str(line).contains("pone un token presenza in"):
			placing += 1
		elif str(line).contains("sposta un token da"):
			relocating += 1
	return {"placing": placing, "relocating": relocating}


## Quante carte MUOVERE sono passate per le mani del tavolo: quelle ancora in
## mano a fine anno piu' quelle finite negli scarti.
static func _move_cards_seen(session: RefCounted, data: RefCounted) -> int:
	var seen: int = 0
	for entity_id in session.world["entities"]:
		for asset_id in session.service.hand(str(entity_id)):
			if _is_move_card(data, str(asset_id)):
				seen += 1
	for family in session.world["decks"]:
		for asset_id in (session.world["decks"][family]["discard"] as Array):
			if _is_move_card(data, str(asset_id)):
				seen += 1
	return seen


static func _is_move_card(data: RefCounted, asset_id: String) -> bool:
	var card: Variant = data.assets.get(asset_id)
	if card == null:
		return false
	return str(((card as Dictionary).get("card_action", {}) as Dictionary).get("kind", "")) == "MOVE"


## Quale porta era chiusa, letta sulla posizione di fine anno. Una fotografia,
## non un film: dice quante case **finiscono** l'anno con ciascuna porta
## chiusa, che e' la domanda di ISSUES 48 - se la mappa e' ferma, cos'e' che la
## tiene ferma.
static func _doors(
	session: RefCounted, data: RefCounted, seats: Array, cap: int
) -> Dictionary:
	var out: Dictionary = {"occasions": 0, "token": 0, "card": 0, "door": 0, "other": 0}
	for entity_id in seats:
		var id: String = str(entity_id)
		out["occasions"] = int(out["occasions"]) + 1
		if session.service.tokens_placed(id) >= cap:
			out["token"] = int(out["token"]) + 1
			continue
		var has_card: bool = false
		for asset_id in session.service.hand(id):
			if _is_move_card(data, str(asset_id)):
				has_card = true
				break
		if not has_card:
			out["card"] = int(out["card"]) + 1
			continue
		var somewhere: bool = false
		for region_id in (session.world["regions"] as Dictionary):
			if session.service.regions_with_presence(id).has(str(region_id)):
				continue
			if not session.service.can_move_to(id, str(region_id)):
				continue
			if session.service.region_free_slots(str(region_id)) <= 0:
				continue
			somewhere = true
			break
		if not somewhere:
			out["door"] = int(out["door"]) + 1
			continue
		out["other"] = int(out["other"]) + 1
	return out


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
