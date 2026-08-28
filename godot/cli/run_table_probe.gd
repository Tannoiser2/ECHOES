extends SceneTree
## La temperatura del tavolo che il seme apparecchia (ISSUES 48 / D-216)
##
##   godot --headless --path godot --script res://cli/run_table_probe.gd -- \
##       --runs=200 --seed=7000 --chronicle=CHR_00
##
## Con le case pescate ([D-213](DECISIONS.md#d-213)) il tavolo cambia a ogni
## seme, e con lui cambia **cosa le quattro case sono gia' l'una per l'altra
## prima che qualcuno muova**. Era il debito dichiarato di quella decisione: le
## relazioni erano scritte solo dentro la vecchia linea, quindi un tavolo misto
## apriva piatto — quattro estranei — mentre uno storico apriva con rancori e
## patti gia' in campo.
##
## «Piatto» non e' un aggettivo: e' un numero, ed e' quello che questa sonda
## conta. Un tavolo senza nessuna coppia calda non e' un tavolo tranquillo, e'
## **un tavolo senza storia**: le clausole che leggono un legame non si
## qualificano, il peso dell'alleanza al Consiglio non si applica mai, e
## FORGIARE parte da zero per tutti.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")

const ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 200))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Cosa dice il dato, prima di giocare: la mappa delle coppie scritte.
	var written: Dictionary = {}
	for entity_id in data.entities:
		for relation in (data.entities[str(entity_id)]["relations"] as Array):
			var pair: Array = [str(entity_id), str((relation as Dictionary)["with"])]
			pair.sort()
			written["%s|%s" % [pair[0], pair[1]]] = str((relation as Dictionary)["level"])

	var by_level: Dictionary = {}
	var hot_pairs: int = 0
	for key in written:
		var level: String = str(written[str(key)])
		by_level[level] = int(by_level.get(level, 0)) + 1
		if level != "NEUTRAL":
			hot_pairs += 1

	# E cosa arriva al tavolo: per ogni seme, quante delle sei coppie sedute
	# sono calde.
	var histogram: Array = [0, 0, 0, 0, 0, 0, 0]
	var flat: int = 0
	var hot_total: int = 0
	var allied: int = 0
	var hostile: int = 0
	for run in range(runs):
		var seats: Array = GameSession.seats_for(data, chronicle_id, first_seed + run)
		var hot: int = 0
		for i in range(seats.size()):
			for j in range(i + 1, seats.size()):
				var pair: Array = [str(seats[i]), str(seats[j])]
				pair.sort()
				var level: String = str(written.get("%s|%s" % [pair[0], pair[1]], "NEUTRAL"))
				if level == "NEUTRAL":
					continue
				hot += 1
				if ORDER.find(level) > ORDER.find("NEUTRAL"):
					allied += 1
				else:
					hostile += 1
		histogram[clampi(hot, 0, 6)] += 1
		hot_total += hot
		if hot == 0:
			flat += 1

	print("")
	print("== LA TEMPERATURA DEL TAVOLO - %d semi, %s ==" % [runs, chronicle_id])
	print("")
	print("  Nel dato: %d coppie scritte su %d possibili, di cui %d calde" % [
		written.size(), _pairs(data.entities.size()), hot_pairs
	])
	var levels: Array = by_level.keys()
	levels.sort()
	for level in levels:
		print("    %-10s %d" % [str(level), int(by_level[str(level)])])
	print("")
	print("  Coppie calde fra le sei sedute:")
	for count in range(7):
		if int(histogram[count]) == 0:
			continue
		print("    %d su 6:  %3d tavoli  %5.1f%%" % [
			count, int(histogram[count]), 100.0 * float(histogram[count]) / float(runs)
		])
	print("")
	print("  TAVOLI PIATTI (nessuno si conosce): %d su %d — %.1f%%" % [
		flat, runs, 100.0 * float(flat) / float(runs)
	])
	print("  Coppie calde per tavolo, in media: %.2f su 6" % [
		float(hot_total) / float(maxi(1, runs))
	])
	print("    di cui alleanze %.2f, ostilita' %.2f" % [
		float(allied) / float(maxi(1, runs)), float(hostile) / float(maxi(1, runs))
	])
	quit(0)


static func _pairs(count: int) -> int:
	return count * (count - 1) / 2


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
