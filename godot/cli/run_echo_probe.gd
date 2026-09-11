extends SceneTree
## **Quanti Echi guadagna una casa in un anno** (ISSUES 136, domanda del
## committente: *«misura gli echi guadagnati in un anno, anche perche' gli echi
## sono solo tre/quattro per partita, un po' poco»*).
##
##   godot --headless --path godot --script res://cli/run_echo_probe.gd -- \
##       --runs=40 --seed=7000
##
## Un Eco si scrive quando il tavolo ha prodotto qualcosa che vale la pena
## ricordare (`echo_recorder.gd`): una decisione vinta nella fascia larga, una
## vinta chiaramente dove tutt'e due i fronti hanno speso molto, o una caduta
## che e' costata cara all'opposizione. La fascia di misura non lascia Eco.
##
## La sonda conta, su tutto il tavolo e **per casa**:
##
##   · quanti Echi in un anno, e quante Verita';
##   · **a chi vanno**: se un Eco nasce da un Consiglio, la casa che l'ha vinto
##     e' quella che lo porta — ed e' il numero che decide se un mazzo fatto di
##     Echi si sentirebbe o no;
##   · quanti Consigli si chiudono **senza** Eco, e perche' la fascia non basta.
##
## Si conta dal registro degli Effetti, che e' l'unica fonte di verita' su cosa
## e' successo — e la sonda si dichiara cieca se i Consigli contati sono zero.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


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

	var echoes: int = 0
	var truths: int = 0
	var years: int = 0
	var by_seat: Dictionary = {}
	var won_by: Dictionary = {}
	var nobody_won: int = 0
	var seatings: Dictionary = {}
	var by_band: Dictionary = {}

	for index in range(runs):
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			session.dispose()
			continue
		for entity_id in seats:
			seatings[str(entity_id)] = int(seatings.get(str(entity_id), 0)) + 1
		await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
		)
		years += 1
		for entry in (session.world.get("effect_log", []) as Array):
			var effect: Dictionary = entry as Dictionary
			match str(effect.get("type", "")):
				"CREATE_ECHO":
					echoes += 1
					# **E adesso a chi va l'Eco sta scritto** (D-508, ISSUES
					# 136 punto 6). Il primo risultato di questa sonda era che
					# il payload portava `participants`, `outcome`,
					# `tension_id` — e chi aveva **vinto** no, quindi la sonda
					# poteva contare solo chi c'era. Ora conta tutt'e due, e le
					# due colonne messe in fila dicono quanto «partecipare»
					# distingueva poco.
					var payload: Dictionary = effect.get("payload", {}) as Dictionary
					for who in (payload.get("participants", []) as Array):
						var id: String = str(who)
						by_seat[id] = int(by_seat.get(id, 0)) + 1
					var leader: String = str(payload.get("won_by", ""))
					if leader == "":
						nobody_won += 1
					else:
						won_by[leader] = int(won_by.get(leader, 0)) + 1
				"APPEND_TRUTH":
					truths += 1
		# **I Consigli si contano dal riepilogo dell'anno, non da un registro
		# che non c'e'.** Al primo giro la sonda cercava `confluence_log` nel
		# mondo: non esiste, e il conto tornava **zero** — la riga che si
		# dichiara cieca l'ha detto. Il numero vero sta nel risultato della
		# partita, che e' quello che il cancello legge da sempre.
		# **I Consigli non si contano qui.** Ci ho provato in due modi — un
		# registro nel mondo che non esiste, e un campo `result` sulla
		# sessione che non esiste nemmeno — e tutt'e due le volte la sonda ha
		# guardato nel posto sbagliato. Il numero c'e' gia' e lo misura il
		# cancello: **5,58 Consigli l'anno**. Rimisurare male un numero che
		# un'altra sonda misura bene non serve a niente.
		session.dispose()

	var n: float = maxf(1.0, float(years))
	print("")
	print("GLI ECHI DI UN ANNO — %d anni, semi da %d, tavolo misto" % [years, first_seed])
	print("")
	print("  Echi scritti            %6.2f l'anno   (%d in tutto)" % [echoes / n, echoes])
	print("  Verita' scritte         %6.2f l'anno   (%d in tutto)" % [truths / n, truths])
	print("  Consigli l'anno, dal cancello dei 100 semi:  5.58")
	print("  quindi Consigli che lasciano un Eco:       %d%%" % int(
		(float(echoes) / n) * 100.0 / 5.58
	))
	print("")
	print("  PER CASA, in un anno che gioca: a quanti Echi **partecipa**, e quanti")
	print("  ne **ottiene** — che e' la colonna che prima non si poteva scrivere.")
	print("    %-22s %8s %8s" % ["casa", "al tavolo", "ottenuti"])
	var ids: Array = seatings.keys()
	ids.sort()
	for id in ids:
		var sat: float = maxf(1.0, float(seatings[id]))
		print("    %-22s %8.2f %8.2f" % [
			str(data.entities.get(str(id), {}).get("name", id)).substr(0, 21),
			float(by_seat.get(str(id), 0)) / sat,
			float(won_by.get(str(id), 0)) / sat,
		])
	print("")
	print("  Echi che nessuno ha ottenuto (nessuna domanda al mucchio): %d su %d" % [
		nobody_won, echoes,
	])
	print("")
	if echoes == 0:
		print("  ATTENZIONE: zero Consigli contati — la sonda e' cieca lei, non il gioco.")
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
