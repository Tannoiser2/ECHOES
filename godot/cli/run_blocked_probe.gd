extends SceneTree
## **Perche' una persona resta senza niente da fare** (ISSUES 136).
##
##   godot --headless --path godot --script res://cli/run_blocked_probe.gd -- \
##       --runs=20 --seed=7000
##
## [`run_empty_hand_probe`](run_empty_hand_probe.gd) ha detto **quanto**: la mano
## vuota vale il 4-6% delle Occasioni, e la sonda dei menu ha detto che una
## persona si trova con la sola voce «passa» nel **20%**. I due numeri insieme
## dicono che **tre volte su quattro chi e' bloccato ha carte in mano**, ed e'
## quella la cosa da spiegare — non la mano vuota.
##
## Questa sonda si siede al posto di una persona come quella dei menu, e ogni
## volta che l'unica cosa da fare e' passare **chiede al motore il perche'**,
## carta per carta e luogo per luogo: `why_not_reached` distingue gia' il segno
## vietato dal segno mancante (D-274), e la ragione non si indovina qui — si
## legge da li'.
##
## **La sonda si dichiara non cieca**: stampa anche quante Occasioni ha visto e
## quante carte aveva in mano nei momenti bloccati. Un blocco con zero carte in
## mano non e' un mistero, ed e' contato a parte.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")


## L'orecchio: registra i menu, sceglie sempre la prima voce (D-492), e quando
## il menu dell'azione ha la sola «passa» chiama il perche'.
class Orecchio extends RefCounted:
	var session: RefCounted
	var seat_id: String = ""
	var turni: int = 0
	var bloccati: int = 0
	var bloccati_a_secco: int = 0
	var carte_quando_bloccato: int = 0
	## ragione -> quante carte l'hanno data
	var ragioni: Dictionary = {}
	var esempi: Array = []

	func say(_text: String) -> void:
		pass

	func shows_state() -> bool:
		return true

	func choose(prompt: String, labels: Array, subjects: Array = []) -> int:
		var seen: int = 0
		for i in range(labels.size()):
			var subject: Dictionary = (subjects[i] if i < subjects.size() else {}) as Dictionary
			if not bool(subject.get("shortcut", false)):
				seen += 1
		if prompt.contains("cosa fai?"):
			turni += 1
			if seen <= 1:
				_perche()
		return 0

	## Il perche', chiesto al motore e non indovinato.
	func _perche() -> void:
		bloccati += 1
		if session == null or seat_id == "":
			return
		var hand: Array = session.service.hand(seat_id) as Array
		carte_quando_bloccato += hand.size()
		if hand.is_empty():
			bloccati_a_secco += 1
			_conta("la mano e' vuota")
			return
		for asset_id in hand:
			var detto: String = ""
			var arriva: bool = false
			for region_id in session.world["regions"]:
				var why: String = session.actions.why_not_reached(
					str(asset_id), str(region_id), ""
				)
				if why == "":
					arriva = true
					break
				if detto == "":
					detto = why
			if arriva:
				# La carta arriva da qualche parte: se il menu resta vuoto, il
				# rifiuto non e' il bersaglio a segni ma qualcos'altro — ed e'
				# la riga che dice di guardare oltre.
				_conta("la carta arriva a un luogo, ma l'Azione e' rifiutata lo stesso")
				if esempi.size() < 6:
					esempi.append("«%s» arriva, e non si puo' giocare" % str(asset_id))
				continue
			if detto.contains("vieta"):
				_conta("il luogo porta un segno che la carta vieta")
			elif detto.contains("non ne porta nessuno"):
				_conta("nessun luogo porta i segni del suo bersaglio")
			else:
				_conta("un altro rifiuto: %s" % detto)
			if esempi.size() < 6 and detto != "":
				esempi.append(detto)

	func _conta(ragione: String) -> void:
		ragioni[ragione] = int(ragioni.get(ragione, 0)) + 1


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 20))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr(data.describe_errors())
		quit(1)
		return

	var ear: Orecchio = Orecchio.new()
	for i in range(runs):
		var seats: Array = GameSession.seats_for(data, chronicle_id, first_seed + i)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, first_seed + i):
			session.dispose()
			continue
		ear.session = session
		ear.seat_id = str(seats[0])
		var table: RefCounted = SeatDecider.new([str(seats[0])], session.log)
		table.io = ear
		await session.run(table)
		session.dispose()

	print("")
	print("PERCHE' SI RESTA SENZA NIENTE DA FARE — %d anni, semi da %d" % [runs, first_seed])
	print("")
	print("  Occasioni viste da chi gioca:            %d" % ear.turni)
	print("  di cui con la sola voce «passa»:         %d (%d%%)" % [
		ear.bloccati, ear.bloccati * 100 / maxi(ear.turni, 1),
	])
	print("  di quelle, con la mano vuota:            %d (%d%%)" % [
		ear.bloccati_a_secco, ear.bloccati_a_secco * 100 / maxi(ear.bloccati, 1),
	])
	print("  carte in mano nei momenti bloccati:      %.2f in media" % [
		float(ear.carte_quando_bloccato) / maxf(1.0, float(ear.bloccati)),
	])
	print("")
	print("  LA RAGIONE, chiesta al motore carta per carta:")
	var totale: int = 0
	for r in ear.ragioni:
		totale += int(ear.ragioni[r])
	var righe: Array = []
	for r in ear.ragioni:
		righe.append([int(ear.ragioni[r]), str(r)])
	righe.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
	for riga in righe:
		print("    %5d (%3d%%)  %s" % [
			int(riga[0]), int(riga[0]) * 100 / maxi(totale, 1), str(riga[1]),
		])
	if not ear.esempi.is_empty():
		print("")
		print("  Qualche caso vero:")
		for e in ear.esempi:
			print("    %s" % str(e))
	print("")
	if ear.turni == 0 or totale == 0:
		print("  ATTENZIONE: la sonda non ha visto niente — e' cieca lei, non il gioco.")
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
