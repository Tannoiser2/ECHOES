extends SceneTree
## **Quanto grande dev'essere il mazzetto personale** (ISSUES 136, forma decisa
## dal committente: *«il mazzetto viene creato diverso da entità a entità in base
## agli obiettivi e alla presenza sulla mappa e poi ognuno lo costruisce mano a
## mano»*).
##
##   godot --headless --path godot --script res://cli/run_deck_probe.gd -- \
##       --runs=40 --seed=7000
##
## **Non cambia nessuna regola.** Gioca le partite come sono e, a ogni inizio di
## Atto, scrive quante carte darebbe il mazzetto proposto — la stessa disciplina
## di [`run_hand_probe`](run_hand_probe.gd), che misuro' il rubinetto della
## mappa prima che qualcuno lo scrivesse.
##
## Il mazzetto si compone di due pezzi che **stanno gia' nei dati**:
##
##   · le carte di partenza dell'entita' (`starting_assets`) — due, di due
##     famiglie diverse: e' la sua identita';
##   · piu' `PER_FAMIGLIA` carte per ogni famiglia che la sua **presenza**
##     raggiunge sulla mappa (`asset_sources` delle Regioni dove ha pedine).
##
## E cresce: ogni ACQUISIRE aggiunge una carta al mazzetto, che e' il pezzo
## «deck builder» della frase del committente.
##
## Le domande, nell'ordine in cui contano:
##
##   1. **quanto grande di partenza**, contro il fabbisogno di 3,92 carte l'Atto;
##   2. **quanto cresce** in un anno, e se cresce per tutti o solo per chi parte
##      avanti;
##   3. **quante famiglie** tocca un mazzetto — un mazzetto di una famiglia sola
##      e' un giocatore che non ha scelte.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

## Quante carte per ogni famiglia che la presenza raggiunge. Il numero non e'
## scelto qui: si prova a 1, 2 e 3 e si stampano tutti e tre, cosi' il
## committente sceglie su un numero e non su un'idea.
const PER_FAMIGLIA: Array = [1, 2, 3]


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

	# Per ogni seggio: [carte di partenza, famiglie raggiunte, acquisti nell'anno]
	var start_cards: Dictionary = {}
	var start_families: Dictionary = {}
	var bought: Dictionary = {}
	var seats_seen: Dictionary = {}
	## Quante volte ogni casa si e' seduta: i seggi sono quattro su otto, e
	## dividere per gli anni invece che per le sedute dimezzava ogni media.
	var played: Dictionary = {}
	var years: int = 0

	for index in range(runs):
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			session.dispose()
			continue
		# **Il mazzetto di partenza, letto dal mondo appena montato.**
		for entity_id in seats:
			var id: String = str(entity_id)
			seats_seen[id] = true
			var entity: Dictionary = (session.world["entities"] as Dictionary)[id] as Dictionary
			var owned: Array = (data.entities[id] as Dictionary).get("starting_assets", []) as Array
			# **La presenza si legge dai dati, non dal mondo appena montato.**
			# Sul tabellone le pedine non ci sono ancora: si posano giocando,
			# ed e' la domanda «cosa posi per prima?» del primo round. Chiedere
			# `regions_with_presence` qui torna una lista **vuota** — la sonda
			# se n'e' accorta da sola, con la riga che si dichiara cieca, ed e'
			# la settima volta in questo progetto.
			#
			# E leggere dai dati non e' un ripiego: il mazzetto si compone
			# **nella scatola**, prima che qualcuno posi una pedina, e la
			# presenza scritta nell'entita' e' esattamente quello che la scatola
			# sa di lei.
			var families: Dictionary = {}
			for region_id in ((data.entities[id] as Dictionary).get("presence", []) as Array):
				var region: Variant = data.regions.get(str(region_id))
				if region == null:
					continue
				for family in ((region as Dictionary).get("asset_sources", []) as Array):
					families[str(family)] = true
			start_cards[id] = int(start_cards.get(id, 0)) + owned.size()
			start_families[id] = int(start_families.get(id, 0)) + families.size()
			played[id] = int(played.get(id, 0)) + 1
		var before: Dictionary = {}
		for entity_id in seats:
			before[str(entity_id)] = 0
		await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
		)
		# Gli acquisti dell'anno: si contano dal registro degli Effetti, che e'
		# l'unica fonte di verita' su cosa e' successo.
		for entry in (session.world.get("effect_log", []) as Array):
			var effect: Dictionary = entry as Dictionary
			if str(effect.get("type", "")) != "GRANT_ASSET":
				continue
			var who: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
			if who != "":
				bought[who] = int(bought.get(who, 0)) + 1
		years += 1
		session.dispose()

	print("")
	print("IL MAZZETTO PERSONALE — %d anni, semi da %d" % [years, first_seed])
	print("  (nessuna regola cambiata: si guarda cosa darebbe, giocando come adesso)")
	print("")
	var n: int = maxi(years, 1)
	var seats_list: Array = seats_seen.keys()
	seats_list.sort()
	print("  %-22s %8s %10s %10s" % ["casa", "partenza", "famiglie", "acquisti/anno"])
	var tot_start: float = 0.0
	var tot_fam: float = 0.0
	var tot_bought: float = 0.0
	for id in seats_list:
		var sat: float = maxf(1.0, float(played.get(id, 0)))
		var s: float = float(start_cards.get(id, 0)) / sat
		var f: float = float(start_families.get(id, 0)) / sat
		var b: float = float(bought.get(id, 0)) / sat
		tot_start += s
		tot_fam += f
		tot_bought += b
		print("  %-22s %8.1f %10.1f %10.1f" % [
			str(data.entities.get(id, {}).get("name", id)).substr(0, 21), s, f, b,
		])
	var seats_n: float = maxf(1.0, float(seats_list.size()))
	print("")
	print("  medie:  partenza %.1f   famiglie %.1f   acquisti %.1f l'anno" % [
		tot_start / seats_n, tot_fam / seats_n, tot_bought / seats_n,
	])
	print("")
	print("  IL MAZZETTO, a tre misure diverse (il fabbisogno e' 3,92 carte l'Atto):")
	print("  %10s %10s %12s %14s" % [
		"per fam.", "partenza", "a fine anno", "carte per Atto",
	])
	for per in PER_FAMIGLIA:
		var start: float = tot_start / seats_n + (tot_fam / seats_n) * float(per)
		var ending: float = start + tot_bought / seats_n
		print("  %10d %10.1f %12.1f %14.2f" % [per, start, ending, start / 3.0])
	print("")
	if years == 0 or tot_fam == 0.0:
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
