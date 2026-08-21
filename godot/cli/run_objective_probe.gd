extends SceneTree
## Quattro obiettivi al posto dei tre gradini (proposta del committente).
##
##   godot --headless --path godot --script res://cli/run_objective_probe.gd -- \
##       --runs=100 --seed=7000
##
## «Gli obiettivi sostituiscono i gradini: se si ottengono tutti e 4 e' un
## trionfo, se non se ne raggiunge nessuno e' un NONE, gli altri sono successi
## parziali, e vittorie che danno numeri alla fine della saga.»
##
## Questa sonda **non cambia nessuna regola**. Gioca le partite come sono e, a
## fine anno, legge il mondo una seconda volta chiedendo cose che il gioco non
## chiede: quante volte si sarebbe avverato ciascun obiettivo candidato. E' il
## preventivo di D-190 applicato al punteggio — sapere il prezzo prima di
## riscrivere §14.
##
## Come si traducono i dati di oggi in obiettivi, e perche':
##
##   * **il palese** e' il Destino scritto dell'entita' ("uno e' palese ed e'
##     legato all'entita'"). Un Destino oggi ha tre gradini; se i gradini
##     spariscono, il suo contenuto deve collassare in *un* traguardo, e il
##     candidato naturale e' la **Vittoria** — quello per cui la casa e' venuta.
##     Il Minimo no: D-150 ha stabilito che il Minimo e' sopravvivere, non un
##     obiettivo. Il Trionfo si misura a parte, come palese alternativo.
##   * **il pool nascosto** sono i Destini condivisibili (D-115, `$self`), che
##     sono gia' scritti per essere giurati da chiunque: Vittoria e Trionfo di
##     ciascuno diventano due obiettivi distinti. Oggi sono sei carte in tutto:
##     poche per un pool vero, abbastanza per sapere **quali sono gratis e quali
##     sono fuori dal mondo** prima di scriverne dodici.
##
## Le quattro domande:
##
##   1. **la riga di partenza**: dove arrivano i seggi oggi, coi tre gradini;
##   2. **il tasso di ciascun obiettivo**: quante volte si avvera, seggio per
##      seggio. Un obiettivo all'85% e' un regalo, uno al 5% e' un arredo;
##   3. **la distribuzione dei quattro**: pescando 1 palese + 3 nascosti col
##      seme, quanti se ne portano a casa — l'istogramma da 0 a 4. Se il 4 non
##      esce mai il trionfo non esiste, se lo 0 non esce mai il NONE e' finto;
##   4. **i numeri della saga**: cosa diventa il punteggio di campagna con la
##      mappa di oggi (`saga_scoring`) e con una mappa a obiettivo, a parita' di
##      partite giocate.
##
## Tavolo misto (D-053): quattro ottimizzatori identici sono il caso in cui
## tutti mancano gli stessi obiettivi per la stessa ragione.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")

## I due gradini che diventano obiettivi. Il Minimo resta fuori: e' la soglia di
## sopravvivenza, non un traguardo (D-150).
const AS_OBJECTIVE: Array = ["victory", "triumph"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr("dati non validi: %s" % data.describe_errors())
		quit(1)
		return

	# Il pool nascosto: i Destini condivisibili, un obiettivo per gradino.
	var pool: Array = []
	for destiny_id in _sorted(data.destinies.keys()):
		var destiny: Dictionary = data.destinies[str(destiny_id)] as Dictionary
		if str(destiny["entity_id"]) != "$self":
			continue
		for level in AS_OBJECTIVE:
			pool.append({
				"key": "%s/%s" % [str(destiny_id), level],
				"title": str((destiny[level] as Dictionary)["label"]),
				"conditions": (destiny[level] as Dictionary)["conditions"],
			})

	print("SONDA DEGLI OBIETTIVI - %d Chronicle, semi da %d" % [runs, first_seed])
	print("  Oggi: tre gradini cumulativi per Destino. Domani: quattro obiettivi,")
	print("  uno palese e tre nascosti, e il conto di quanti se ne portano a casa.")
	print("  Pool nascosto disponibile: %d obiettivi (dai Destini condivisibili)." % [pool.size()])
	print("")

	var reached: Dictionary = {}        # livello di oggi -> quanti seggi
	var hits: Dictionary = {}           # "obiettivo|seggio" -> quante volte avverato
	var seen: Dictionary = {}           # "obiettivo|seggio" -> quante volte misurato
	var pool_hits: Dictionary = {}      # obiettivo del pool -> quante volte avverato
	var pool_seen: Dictionary = {}      # obiettivo del pool -> quante volte misurato
	var owned: Dictionary = {"victory": 0, "triumph": 0, "seats": 0}
	var counts: Dictionary = {}         # quanti obiettivi su 4 -> quanti seggi
	var score_now: int = 0
	var score_then: int = 0
	var seats_total: int = 0

	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
		session.setup(chronicle_id, seats, seed_value)
		var decider: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		var report: Dictionary = await session.run(decider)
		var scoring: Dictionary = (data.chronicles[chronicle_id] as Dictionary).get(
			"saga_scoring", {}
		) as Dictionary
		# La seconda lettura del mondo: le stesse clausole, chieste a fine anno.
		var conditions: RefCounted = ConditionEvaluator.new(session.world, data)
		# Il sacchetto dei nascosti: mescolato col seme, come tutto il resto.
		var bag: RefCounted = RngService.new(seed_value * 97 + 13)

		for entity_id in seats:
			seats_total += 1
			var result: Dictionary = (report["destiny_results"] as Dictionary)[str(entity_id)]
			reached[str(result["level"])] = int(reached.get(str(result["level"]), 0)) + 1
			score_now += int(scoring.get(str(result["level"]).to_lower(), 0))

			var context: Dictionary = {"self": str(entity_id)}
			var destiny: Dictionary = data.destinies[str(result["destiny_id"])] as Dictionary

			# 1. Il palese: la Vittoria del Destino scritto, e il Trionfo a fianco.
			owned["seats"] = int(owned["seats"]) + 1
			var public_holds: bool = false
			for level in AS_OBJECTIVE:
				var holds: bool = conditions.all_hold(
					(destiny[level] as Dictionary)["conditions"], context
				)
				if holds:
					owned[level] = int(owned[level]) + 1
				if level == "victory":
					public_holds = holds
				var lane: String = "PALESE %s/%s|%s" % [
					str(result["destiny_id"]), level, str(entity_id)
				]
				seen[lane] = int(seen.get(lane, 0)) + 1
				if holds:
					hits[lane] = int(hits.get(lane, 0)) + 1

			# 2. Il pool: ogni obiettivo condivisibile, chiesto per ogni seggio.
			var truth: Dictionary = {}
			for objective in pool:
				var key: String = str((objective as Dictionary)["key"])
				var holds_here: bool = conditions.all_hold(
					(objective as Dictionary)["conditions"], context
				)
				truth[key] = holds_here
				pool_seen[key] = int(pool_seen.get(key, 0)) + 1
				if holds_here:
					pool_hits[key] = int(pool_hits.get(key, 0)) + 1

			# 3. La pescata vera: il palese piu' tre nascosti, senza rimpiazzo.
			var drawn: Array = bag.shuffle(pool.duplicate())
			var got: int = 1 if public_holds else 0
			for i in range(mini(3, drawn.size())):
				if bool(truth.get(str((drawn[i] as Dictionary)["key"]), false)):
					got += 1
			counts[got] = int(counts.get(got, 0)) + 1
			score_then += _score_of(got, scoring)

	var years: float = float(maxi(1, runs))
	var seats: float = float(maxi(1, seats_total))

	print("== 1. LA RIGA DI PARTENZA: DOVE ARRIVANO OGGI ==")
	for level in ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]:
		var many: int = int(reached.get(level, 0))
		print("    %-8s %4d seggi  %5.1f%%" % [level, many, 100.0 * float(many) / seats])
	print("    punteggio di saga, mappa di oggi: %+.2f per seggio" % [
		float(score_now) / seats
	])

	print("")
	print("== 2. QUANTO COSTA OGNI OBIETTIVO ==")
	print("  Il palese, letto come Vittoria del Destino scritto:")
	print("    si avvera nel %.1f%% dei seggi." % [
		100.0 * float(int(owned["victory"])) / float(maxi(1, int(owned["seats"])))
	])
	print("  Lo stesso Destino letto come Trionfo (palese alternativo):")
	print("    si avvera nel %.1f%% dei seggi." % [
		100.0 * float(int(owned["triumph"])) / float(maxi(1, int(owned["seats"])))
	])
	print("  Il pool nascosto, obiettivo per obiettivo:")
	var lanes: Array = _sorted(pool_seen.keys())
	for key in lanes:
		var many: int = int(pool_hits.get(str(key), 0))
		var total: int = maxi(1, int(pool_seen.get(str(key), 0)))
		var rate: float = 100.0 * float(many) / float(total)
		var verdict: String = "  <- regalo" if rate >= 80.0 else (
			"  <- arredo" if rate <= 10.0 else ""
		)
		print("    %-34s %5.1f%%%s" % [str(key), rate, verdict])
	print("  I palesi, casa per casa (chi ha scritto il Destino piu' caro):")
	for key in _sorted(seen.keys()):
		var many2: int = int(hits.get(str(key), 0))
		var total2: int = maxi(1, int(seen.get(str(key), 0)))
		print("    %-52s %5.1f%%" % [str(key), 100.0 * float(many2) / float(total2)])

	print("")
	print("== 3. QUANTI OBIETTIVI SU QUATTRO SI PORTANO A CASA ==")
	var carried: int = 0
	for got in [0, 1, 2, 3, 4]:
		var many: int = int(counts.get(got, 0))
		carried += got * many
		print("    %d su 4   %4d seggi  %5.1f%%  %s" % [
			got, many, 100.0 * float(many) / seats, "#".repeat(int(round(float(many) / seats * 40.0)))
		])
	print("    media: %.2f obiettivi per seggio" % [float(carried) / seats])
	print("    (se il 4 non esce mai il trionfo non esiste; se lo 0 non esce mai,")
	print("     il NONE e' finto e la mappa dei numeri va riscritta)")

	print("")
	print("== 4. I NUMERI DELLA SAGA ==")
	print("    mappa di oggi (none %d, minimo %d, vittoria %d, trionfo %d):" % [
		-1, 1, 3, 6
	])
	print("      %+.2f per seggio" % [float(score_now) / seats])
	print("    mappa a obiettivo (0 -> -1, 1 -> 1, 2 -> 2, 3 -> 4, 4 -> 6):")
	print("      %+.2f per seggio" % [float(score_then) / seats])
	print("    (la seconda mappa e' una proposta da bocciare o correggere, non un dato)")
	print("")
	print("  %d Chronicle, %d seggi, semi %d-%d." % [
		runs, seats_total, first_seed, first_seed + runs - 1
	])
	quit(0)


## La mappa proposta: un punto per obiettivo, con il salto sul terzo e il premio
## sul quarto, cosi' che «tutti e quattro» resti un trionfo e non un'aritmetica.
func _score_of(got: int, scoring: Dictionary) -> int:
	match got:
		0:
			return int(scoring.get("none", -1))
		1:
			return 1
		2:
			return 2
		3:
			return 4
		_:
			return int(scoring.get("triumph", 6))


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var body: String = argument.substr(2)
		var split: int = body.find("=")
		if split == -1:
			out[body] = true
		else:
			out[body.substr(0, split)] = body.substr(split + 1)
	return out
