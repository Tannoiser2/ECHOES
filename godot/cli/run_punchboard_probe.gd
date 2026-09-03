extends SceneTree
## **La fustella al tavolo**: quanti segnalini si posano davvero (D-296).
##
##   godot --headless --path godot --script res://cli/run_punchboard_probe.gd -- \
##       --runs=40 --seed=7000 --chronicle=CHR_00
##
## Parola del committente, guardando il censimento dei componenti: *«certo che
## 183 segnalini sono tanti, forse troppi»*. Il 183 era il **dizionario** e non
## la fustella — quella taglia 34 tipi per la mappa — ma la domanda sotto resta
## buona, e non si risponde a occhio: **quanti tipi diversi un tavolo vede
## davvero in un anno?** Un segnalino che esce una volta ogni venti partite non
## costa cartone: costa che qualcuno impari a riconoscerlo.
##
## Conta per **anno**, non per Regione: un segno che sta su tre Regioni nello
## stesso anno e' un tipo solo da imparare.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

## Sotto questa frequenza un tipo e' coda: meno di un anno su cinque.
const CODA: float = 0.2


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var anni_con: Dictionary = {}   # tipo -> in quanti anni e' comparso
	var per_anno: Array = []

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito al seme %d" % seed_value)
			quit(3)
			return
		# **I due tavoli, non uno solo** (D-433). Fino alla 0.1.403 questa sonda
		# giocava solo il tavolo uniforme — quattro ottimizzatori uguali — e la
		# fustella non e' del tavolo uniforme: e' della scatola. Sullo stesso
		# anno un tavolo misto pesca carte diverse e posa segni diversi, e la
		# lista dei «mai visti» **cambia**. Un pezzo lo si taglia dal cartone
		# solo se non lo usa nessuno dei due.
		var cervello: RefCounted = (
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
			if run % 2 == 1 else PolicyDecider.new(session.log)
		)
		await session.run(cervello)
		var qui: Dictionary = {}
		for region_id in session.world["regions"]:
			for tag in (session.world["regions"][str(region_id)] as Dictionary).get("tags", []):
				if SignLabels.REGION_WORDS.has(str(tag)):
					qui[str(tag)] = true
		# **E i gettoni che si posano e si tolgono dentro l'anno** (D-433).
		# Fino alla 0.1.403 questa sonda guardava **solo il tavolo a fine anno**,
		# e diceva che `condition:lean` non usciva **mai** in quarant'anni.
		# `run_mark_probe`, sullo stesso tavolo, lo contava posato **trenta
		# volte**: era vero tutt'e due le volte, perche' la magra arriva e
		# qualcuno la risolve prima di dicembre.
		#
		# Ma la domanda della fustella non e' *«cosa resta a fine anno»*: e'
		# **quanti pezzi la scatola deve avere**. Un gettone che si prende e si
		# rimette nella riserva la stessa sera va tagliato nel cartone lo stesso
		# — e chi legge quella lista per potare la fustella, sul numero vecchio,
		# potava pezzi che il gioco usa.
		for entry in (session.world.get("effect_log", []) as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(effect.get("type", "")) != "SET_REGION_TAG":
				continue
			var posato: String = str((effect.get("payload", {}) as Dictionary).get("tag", ""))
			if SignLabels.REGION_WORDS.has(posato):
				qui[posato] = true
		for tag in qui:
			anni_con[str(tag)] = int(anni_con.get(str(tag), 0)) + 1
		per_anno.append(qui.size())
		session.dispose()

	var somma: int = 0
	var massimo: int = 0
	for quanti in per_anno:
		somma += int(quanti)
		massimo = maxi(massimo, int(quanti))

	var tipi: int = SignLabels.REGION_WORDS.size()
	print("")
	print("== LA FUSTELLA AL TAVOLO - %d anni di %s ==" % [runs, chronicle_id])
	print("")
	print("  tipi disegnati sulla fustella della mappa   %d" % tipi)
	print("  tipi visti almeno una volta                 %d" % anni_con.size())
	print("  tipi sul tavolo in un anno solo   media %.1f   massimo %d" % [
		float(somma) / float(maxi(1, runs)), massimo
	])
	print("")
	var mai: PackedStringArray = PackedStringArray()
	for tag in SignLabels.REGION_WORDS:
		if not anni_con.has(str(tag)):
			mai.append(str(tag))
	print("  mai visti in %d anni (%d):" % [runs, mai.size()])
	for tag in mai:
		print("    %s" % tag)
	print("")
	var righe: Array = anni_con.keys()
	righe.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(anni_con[a]) > int(anni_con[b])
	)
	print("  la coda - meno di un anno su cinque:")
	var coda: int = 0
	for tag in righe:
		if float(anni_con[tag]) / float(runs) < CODA:
			coda += 1
			print("    %-32s %d anni su %d" % [str(tag), int(anni_con[tag]), runs])
	print("")
	print("  **%d tipi su %d valgono la coda o non escono mai.**" % [coda + mai.size(), tipi])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
