extends SceneTree
## **Il verbale, misurato: quante righe, e quante dicono qualcosa.**
##
##   godot --headless --path godot --script res://cli/run_log_probe.gd -- --runs=8
##
## Parola del committente dopo un'ora di gioco: *«Il LOG non si capisce
## nulla»*. Prima di riscriverlo, si conta cosa c'e' dentro — e si conta col
## verbale che vede **chi gioca sulla pagina**, non quello del terminale: sono
## due cose diverse, e la differenza e' il difetto.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")


## Un `io` come quello della pagina: sente tutto e non sceglie niente.
class Orecchio extends RefCounted:
	var heard: Array = []
	var shows: bool = false

	func say(text: String) -> void:
		heard.append(text)

	func shows_state() -> bool:
		return shows

	func choose(_prompt: String, _labels: Array, _subjects: Array = []) -> int:
		return -1


func _initialize() -> void:
	var runs: int = 8
	var first_seed: int = 3000
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--runs="):
			runs = int(str(argument).split("=")[1])
		elif str(argument).begins_with("--seed="):
			first_seed = int(str(argument).split("=")[1])

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# **Due giri, e la differenza e' il difetto.** Un `io` che non dichiara
	# niente riceve anche il cartiglio a caratteri del seggio; uno che dichiara
	# di disegnarselo — il telefono da D-143, la pagina da D-491 — no. Misurare
	# tutt'e due dice quanto pesa quella riga sola.
	var righe_verbale: int = 0
	var muto: Orecchio = Orecchio.new()
	var che_disegna: Orecchio = Orecchio.new()
	che_disegna.shows = true
	for orecchio in [muto, che_disegna]:
		righe_verbale = 0
		for i in range(runs):
			var seats: Array = GameSession.seats_for(data, "CHR_00", first_seed + i)
			var session: RefCounted = GameSession.new(data)
			session.setup("CHR_00", seats, first_seed + i)
			var table: RefCounted = SeatDecider.new([str(seats[0])], session.log)
			table.io = orecchio
			await session.run(table)
			righe_verbale += session.log.text().split("\n").size()
			session.dispose()

	_racconta(muto.heard, "chi non si disegna lo stato (il terminale)", runs, righe_verbale)
	_racconta(che_disegna.heard, "chi se lo disegna (la pagina, il telefono)", runs, righe_verbale)
	quit(0)


func _racconta(heard: Array, chi: String, runs: int, righe_verbale: int) -> void:
	var righe: Array = []
	for detto in heard:
		for riga in str(detto).split("\n"):
			righe.append(str(riga))
	var pannello: int = 0
	var vuote: int = 0
	var ripetute: int = 0
	var conto: Dictionary = {}
	var prima: String = ""
	for riga in righe:
		var testo: String = str(riga).strip_edges()
		if testo == "":
			vuote += 1
		if _e_pannello(testo):
			pannello += 1
		if testo != "" and testo == prima:
			ripetute += 1
		prima = testo
		if testo != "":
			conto[testo] = int(conto.get(testo, 0)) + 1

	print("")
	print("== SONDA DEL VERBALE — %d anni — %s ==" % [runs, chi])
	print("")
	print("Righe dette al seggio: %d  (%d per anno)" % [
		righe.size(), righe.size() / maxi(runs, 1),
	])
	print("  il pannello di stato ristampato   %d (%d%%)" % [
		pannello, pannello * 100 / maxi(righe.size(), 1),
	])
	print("  righe vuote                       %d (%d%%)" % [
		vuote, vuote * 100 / maxi(righe.size(), 1),
	])
	print("  righe identiche a quella prima    %d (%d%%)" % [
		ripetute, ripetute * 100 / maxi(righe.size(), 1),
	])
	print("")
	print("Il verbale del motore, per confronto: %d righe (%d per anno)" % [
		righe_verbale, righe_verbale / maxi(runs, 1),
	])
	print("")
	print("Le righe dette piu' volte:")
	var chiavi: Array = conto.keys()
	chiavi.sort_custom(func(a, b): return int(conto[a]) > int(conto[b]))
	for i in range(mini(10, chiavi.size())):
		print("  %4dx  %s" % [int(conto[chiavi[i]]), str(chiavi[i]).substr(0, 78)])


## Il pannello a caratteri di `SeatDecider._board`: le sue righe si riconoscono
## dal telaio e dalle voci fisse.
static func _e_pannello(testo: String) -> bool:
	for inizio in [
		"+-- ATTO", "Le domande dell'anno:", "Sulla mappa:", "In mano:",
		"Il tuo Destino:", "ATTO ", "Rapporti:", "I tuoi segni:",
	]:
		if testo.begins_with(str(inizio)):
			return true
	return false
