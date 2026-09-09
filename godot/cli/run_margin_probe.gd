extends SceneTree
## Da dove viene il margine, e cosa dicono le fasce (D-467, giro 3).
##
##   godot --headless --path godot --script res://cli/run_margin_probe.gd -- --runs=40 --tavolo=misto
##
## `run_balance_probe.gd` conta gli *esiti*: quanti Fallimenti, quanti Decisivi.
## Questa conta il numero che ci sta sotto - A, B, il mucchio e il margine -
## perche' una tabella di esiti puo' muoversi molto mentre il margine medio non
## si muove, e allora la tabella non sta dicendo cosa e' cambiato.
##
## E' successo esattamente quando la libreria degli Asset e' passata da 12 carte
## a 48 (D-040): il margine medio si e' mosso di 0,14 e il Successo Decisivo e'
## passato da un terzo dei Consigli a meta'. La ragione si vedeva solo qui - le
## 12 carte ammucchiavano la massa su M=+4, un punto sotto la fascia Decisiva.
##
## **A due domande la domanda e' un'altra** (D-471): il voto e' contro il
## mucchio, non contro il dado, e le fasce di A sono ancora quelle di D-280.
## Questa sonda le misura dove vanno lette - **fra i Consigli che A ha vinto** -
## e misura la fascia unica di B, per dire se le tre parole di A e la parola
## sola di B stanno dicendo qualcosa.
##
## Deterministica: stessi semi, stesso tavolo, ogni volta.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const Resolution := preload("res://scripts/confluence/confluence_resolution.gd")

const FIRST_SEED: int = 1000


func _initialize() -> void:
	var runs: int = 40
	# `--chronicle` come nella sonda delle posizioni (D-066): questa guardava
	# solo la prima saga, con i seggi cablati nel file.
	var chronicle_id: String = "CHR_00"
	# `--tavolo=misto` come nella sonda delle scelte: l'ottimizzatore da solo
	# quasi non si oppone, e un margine misurato senza opposizione dice poco.
	var mixed: bool = false
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--runs="):
			runs = int(str(argument).split("=")[1])
		elif str(argument).begins_with("--chronicle="):
			chronicle_id = str(argument).split("=")[1]
		elif str(argument) == "--tavolo=misto":
			mixed = true

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	if not data.chronicles.has(chronicle_id):
		printerr("nessuna Chronicle '%s'" % chronicle_id)
		quit(4)
		return

	var councils: int = 0
	var a_sum: int = 0
	var b_sum: int = 0
	var pile_sum: int = 0
	var unopposed: int = 0
	var outcomes: Dictionary = {}
	var a_margins: Dictionary = {}
	var b_margins: Dictionary = {}
	var short_by: Dictionary = {}
	var tied: int = 0
	var pedine_a: int = 0
	var pedine_b: int = 0
	var echoes: Dictionary = {}
	var renown: int = 0
	var with_consequence: int = 0
	var spent: Dictionary = {}
	for i in range(runs):
		var seats: Array = GameSession.seats_for(data, chronicle_id, FIRST_SEED + i)
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, seats, FIRST_SEED + i)
		var table: RefCounted = PolicyDecider.new(session.log)
		if mixed:
			table = Characters.deal(seats, RngService.new(FIRST_SEED + i), session.log)
		var report: Dictionary = await session.run(table)
		for result in report["confluences"]:
			councils += 1
			var a: int = int(result["support_total"])
			var b: int = int(result["oppose_total"])
			var pile: int = int(result.get("pile", 0))
			a_sum += a
			b_sum += b
			pile_sum += pile
			pedine_a += int(result.get("pedine_a", 0))
			pedine_b += int(result.get("pedine_b", 0))
			if b == 0:
				unopposed += 1
			var outcome: String = str(result["outcome"])
			_tally(outcomes, outcome)
			if bool(result.get("echo_created", false)):
				_tally(echoes, outcome)
			var said: Array = result.get("consequence_ids", []) as Array
			if said.has("CNS_DECISIVE_RENOWN"):
				renown += 1
			if not said.is_empty():
				with_consequence += 1
			_tally(spent, a + b)
			if outcome == Resolution.COUNTER:
				_tally(b_margins, b - a)
			elif outcome != Resolution.FAILURE:
				_tally(a_margins, a - b)
			else:
				# Non passa nessuna: o le due parti sono pari, o chi guida non
				# arriva al mucchio. Le due cose sono difetti diversi.
				if a == b:
					tied += 1
				else:
					_tally(short_by, pile - maxi(a, b))
		session.dispose()

	print("")
	print("== SONDA DEI MARGINI - %d Chronicle, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme",
	])
	print("")
	print("Consigli: %d" % councils)
	print("  A medio        %.2f  (di cui pedine %.2f)" % [
		float(a_sum) / maxf(councils, 1), float(pedine_a) / maxf(councils, 1),
	])
	print("  B medio        %.2f  (di cui pedine %.2f)" % [
		float(b_sum) / maxf(councils, 1), float(pedine_b) / maxf(councils, 1),
	])
	print("  mucchio medio  %.2f" % (float(pile_sum) / maxf(councils, 1)))
	print("  senza nessuno che si oppone: %d (%d%%)" % [
		unopposed, unopposed * 100 / maxi(councils, 1),
	])
	print("")
	print("Esiti, e quanti lasciano un Eco:")
	for key in _sorted(outcomes):
		var many: int = int(outcomes[key])
		print("  %-20s %4d (%2d%%)   Echi %4d (%d%%)" % [
			str(key), many, many * 100 / maxi(councils, 1),
			int(echoes.get(key, 0)), int(echoes.get(key, 0)) * 100 / maxi(many, 1),
		])
	print("")
	_histogram("Quanto pesa il Consiglio (A+B): la porta dell'Eco chiede 12 alle due parti", spent)
	print("")
	print("Consigli con almeno una Conseguenza: %d" % with_consequence)
	print("Il di piu' di una vittoria netta (`decisive_bonus`), applicato: %d volte" % renown)

	# Le fasce si leggono qui e non sull'istogramma di tutti i Consigli: un
	# margine negativo, a due domande, non e' un Fallimento ma la vittoria di B.
	_histogram("Margine di A **fra i Consigli che A ha vinto** (0-1 con Costo · 2-4 Successo · >=5 Decisivo)", a_margins)
	_bands("Le tre fasce di A", a_margins)
	_histogram("Margine di B **fra i Consigli che B ha vinto** (fascia unica: COUNTER)", b_margins)
	_bands("Le stesse tre soglie, se B le avesse", b_margins)
	print("")
	print("Non passa nessuna: %d a parita', %d perche' chi guida non arriva al mucchio" % [
		tied, _total(short_by),
	])
	_histogram("Quanto manca al mucchio a chi guida", short_by)
	quit(0)


func _tally(into: Dictionary, value: Variant) -> void:
	into[value] = int(into.get(value, 0)) + 1


func _total(counts: Dictionary) -> int:
	var sum: int = 0
	for key in counts:
		sum += int(counts[key])
	return sum


func _sorted(counts: Dictionary) -> Array:
	var keys: Array = counts.keys()
	keys.sort()
	return keys


func _histogram(title: String, counts: Dictionary) -> void:
	print("")
	print("%s:" % title)
	if counts.is_empty():
		print("  (nessuno)")
		return
	for key in _sorted(counts):
		print("  %+3d  %s (%d)" % [int(key), "#".repeat(int(counts[key])), int(counts[key])])


## Le tre parole, contate dove si leggono. Una fascia che prende quattro quinti
## dei casi non e' una fascia: e' il nome dell'esito.
func _bands(title: String, counts: Dictionary) -> void:
	var total: int = _total(counts)
	if total == 0:
		return
	var low: int = 0
	var mid: int = 0
	var high: int = 0
	for key in counts:
		var margin: int = int(key)
		if margin >= 5:
			high += int(counts[key])
		elif margin >= 2:
			mid += int(counts[key])
		else:
			low += int(counts[key])
	print("")
	print("%s (su %d):" % [title, total])
	print("  0-1  con Costo   %4d (%d%%)" % [low, low * 100 / total])
	print("  2-4  Successo    %4d (%d%%)" % [mid, mid * 100 / total])
	print("  >=5  Decisivo    %4d (%d%%)" % [high, high * 100 / total])
