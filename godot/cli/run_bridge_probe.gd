extends SceneTree
## **Il ponte fra quello che vuoi e quello che peschi** (ISSUES 136, punto 5).
##
##   godot --headless --path godot --script res://cli/run_bridge_probe.gd -- --semi=200
##
## Il mazzetto personale si compone sulle **famiglie che la presenza raggiunge**
## (D-499): la mappa decide da quali mazzi peschi. I tre obiettivi che l'anno ti
## da' non entrano nel conto — e sei su 19 chiedono un **gesto fatto
## quest'anno**, che lo fa una faccia di carta, piu' tre che chiedono carte di
## una famiglia.
##
## La domanda della sonda e' una: **quante volte una casa si siede con un
## obiettivo che il suo mazzetto non puo' servire?** Non «quante volte lo
## manca»: quante volte non ha nemmeno la carta per provarci.
##
## Guarda solo il **montaggio**: non gioca l'anno, quindi duecento semi costano
## pochi secondi e non c'e' nessuna policy in mezzo a scegliere per te.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Bridge := preload("res://scripts/world/objective_bridge.gd")


func _initialize() -> void:
	var runs: int = 200
	var first_seed: int = 7000
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--semi="):
			runs = int(str(argument).split("=")[1])
		elif str(argument).begins_with("--seed="):
			first_seed = int(str(argument).split("=")[1])

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var orphans: Array = Bridge.self_test()
	if not orphans.is_empty():
		printerr("gesti senza una faccia che li serva: %s" % str(orphans))
		quit(3)
		return

	var pairs: int = 0
	var unserved: int = 0
	var asking: int = 0
	var seats: int = 0
	var seats_with_a_hole: int = 0
	var per_objective: Dictionary = {}
	var per_house: Dictionary = {}
	var reasons: Dictionary = {}
	var examples: Array = []
	var smallest: int = 99
	var biggest: int = 0
	var over_copies: int = 0
	var leftovers: Dictionary = {}

	for i in range(runs):
		var seed_value: int = first_seed + i
		var chosen: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup("CHR_00", chosen, seed_value):
			printerr("il montaggio non riesce al seme %d" % seed_value)
			quit(3)
			return
		for entity_id in (session.world["turn_order"] as Array):
			var id: String = str(entity_id)
			var entity: Dictionary = (session.world["entities"] as Dictionary)[id]
			var pile: Array = (
				(session.world["personal_decks"] as Dictionary)[id] as Dictionary
			)["draw"] as Array
			seats += 1
			smallest = mini(smallest, pile.size())
			biggest = maxi(biggest, pile.size())
			var holes: int = 0
			for objective_id in (entity.get("objectives", []) as Array):
				var objective: Dictionary = data.objectives[str(objective_id)] as Dictionary
				var asks: Dictionary = Bridge.asks_of_deck(objective)
				pairs += 1
				if (asks["verbs"] as Array).is_empty() \
						and (asks["families"] as Dictionary).is_empty():
					continue
				asking += 1
				var missing: Array = Bridge.missing_in(pile, objective, data)
				if missing.is_empty():
					continue
				unserved += 1
				holes += 1
				per_objective[str(objective_id)] = int(per_objective.get(str(objective_id), 0)) + 1
				per_house[id] = int(per_house.get(id, 0)) + 1
				for line in missing:
					reasons[str(line)] = int(reasons.get(str(line), 0)) + 1
				if examples.size() < 6:
					examples.append("%s con %s — %s" % [
						id, str(objective_id), " · ".join(PackedStringArray(missing)),
					])
			if holes > 0:
				seats_with_a_hole += 1
		# **La scatola non si gonfia**: lo scambio prende una carta dai mazzi
		# comuni e ne rimette giu' una, quindi nessun id puo' esistere piu'
		# volte di quante copie ne ha la scatola. Se questa riga contasse
		# qualcosa, il rimedio stamperebbe carte.
		var seen: Dictionary = {}
		for pile_id in (session.world["personal_decks"] as Dictionary):
			for asset_id in (
				(session.world["personal_decks"] as Dictionary)[pile_id] as Dictionary
			)["draw"]:
				seen[str(asset_id)] = int(seen.get(str(asset_id), 0)) + 1
		for family in (session.world["decks"] as Dictionary):
			var deck: Dictionary = (session.world["decks"] as Dictionary)[family]
			for asset_id in ((deck["draw"] as Array) + (deck.get("discard", []) as Array)):
				seen[str(asset_id)] = int(seen.get(str(asset_id), 0)) + 1
		for asset_id in seen:
			var copies: int = int(
				(data.assets[str(asset_id)] as Dictionary).get("deck_copies", 1)
			)
			if int(seen[asset_id]) > copies:
				over_copies += 1
		# **Quanto margine resta al rimedio.** La carta che entra la prestano i
		# mazzi comuni, e a montaggio finito il Sapere arriva a **zero**: se un
		# giorno gli obiettivi ne chiedessero di piu', il rimedio non troverebbe
		# niente da far entrare e gli obiettivi tornerebbero scoperti — con
		# questa riga si vede prima, invece che dopo.
		for family in (session.world["decks"] as Dictionary):
			var deck: Dictionary = (session.world["decks"] as Dictionary)[str(family)]
			var size: int = (deck["draw"] as Array).size()
			if not leftovers.has(str(family)) or size < int(leftovers[str(family)]):
				leftovers[str(family)] = size
		session.dispose()

	print("")
	print("== IL PONTE FRA OBIETTIVO E MAZZETTO ==")
	print("  %d semi dal %d, montaggio soltanto" % [runs, first_seed])
	print("  coppie casa-obiettivo            %d" % pairs)
	print("  di quelle, chiedono carte        %d (%.0f%%)" % [
		asking, 100.0 * float(asking) / float(maxi(pairs, 1)),
	])
	print("  **che il mazzetto non puo' servire  %d (%.1f%% di quelle che chiedono)**" % [
		unserved, 100.0 * float(unserved) / float(maxi(asking, 1)),
	])
	print("  seggi con almeno un obiettivo scoperto  %d su %d (%.0f%%)" % [
		seats_with_a_hole, seats, 100.0 * float(seats_with_a_hole) / float(maxi(seats, 1)),
	])
	print("  mazzetti, dal piu' corto al piu' lungo  %d - %d" % [smallest, biggest])
	print("  carte esistenti in piu' copie di quante ne ha la scatola  %d" % over_copies)
	print("")
	print("  e quanto resta nei mazzi comuni a montaggio finito, nel caso peggiore")
	print("  (e' il margine del rimedio: da li' prende la carta che fa entrare)")
	var families: Array = leftovers.keys()
	families.sort()
	for family in families:
		print("    %-12s %d" % [str(family), int(leftovers[family])])
	_table("  per obiettivo:", per_objective)
	_table("  per casa:", per_house)
	_table("  e cosa manca:", reasons)
	if not examples.is_empty():
		print("")
		print("  qualche caso:")
		for line in examples:
			print("    %s" % str(line))
	print("")
	quit(0)


func _table(title: String, counts: Dictionary) -> void:
	if counts.is_empty():
		return
	print("")
	print(title)
	var keys: Array = counts.keys()
	keys.sort_custom(func(a, b): return int(counts[a]) > int(counts[b]))
	for key in keys:
		print("    %-46s %d" % [str(key), int(counts[key])])
