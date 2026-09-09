extends SceneTree
## **Quanto e' lungo un anno sul banco delle prove**, e quanti Consigli cadono.
##
##   godot --headless --path godot --script res://cli/run_year_length_probe.gd -- --runs=24
##
## `test_balance` sorveglia da sempre una banda — quanti Consigli fa una
## Chronicle a quattro Tensioni — e quella banda si e' mossa cinque volte in
## questo progetto, ogni volta con l'aritmetica scritta nel file. Non c'era una
## sonda che la misurasse: quando la banda va rossa il numero si legge dentro il
## messaggio di un'asserzione, e con quello non si confronta niente.
##
## Questa lo misura, e **chiama il banco invece di ricopiarlo**: apre
## `test_case.gd` e usa la sua `new_session`, quindi gioca esattamente la
## partita che la suite gioca — il §10 di sempre, il sacchetto spento, i quattro
## seggi scritti. Una sonda che si ricostruisse il banco a mano misurerebbe un
## terzo gioco, ed e' l'errore che D-184 e D-198 hanno gia' pagato due volte.
##
## Stampa la distribuzione dei Consigli per anno, la mediana, e **quanti
## finiscono senza che nessuna domanda passi**: e' l'altra meta' della stessa
## domanda, perche' un tavolo che decide di piu' fa anni piu' corti.
##
## Deterministica: stessi semi, stesso banco, ogni volta.

const TestCase := preload("res://tests/test_case.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Resolution := preload("res://scripts/confluence/confluence_resolution.gd")

const FIRST_SEED: int = 500


func _initialize() -> void:
	var runs: int = 24
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--runs="):
			runs = int(str(argument).split("=")[1])

	var banco: RefCounted = TestCase.new()
	var counts: Array = []
	var outcomes: Dictionary = {}
	var councils: int = 0
	for i in range(runs):
		var session: RefCounted = banco.new_session(FIRST_SEED + i, false)
		await session.run(PolicyDecider.new(session.log))
		counts.append(int(session.world["confluence_count"]))
		for entry in session.chronicle.confluence_results:
			councils += 1
			var esito: String = str((entry as Dictionary)["outcome"])
			outcomes[esito] = int(outcomes.get(esito, 0)) + 1

	counts.sort()
	var median: int = int(counts[counts.size() / 2])
	var total: int = 0
	for c in counts:
		total += int(c)
	print("")
	print("== SONDA DELLA LUNGHEZZA DELL'ANNO - %d Chronicle, il banco delle prove ==" % runs)
	print("")
	print("Consigli per anno")
	print("  media    %.2f" % (float(total) / maxf(runs, 1)))
	print("  mediana  %d" % median)
	print("  distribuzione %s" % str(counts))
	print("")
	print("Esiti (%d Consigli in tutto)" % councils)
	var keys: Array = outcomes.keys()
	keys.sort()
	for key in keys:
		print("  %-20s %4d (%2d%%)" % [
			str(key), int(outcomes[key]), int(outcomes[key]) * 100 / maxi(councils, 1),
		])
	print("")
	print("  caduti (nessuna domanda passa): %d su %d" % [
		int(outcomes.get(Resolution.FAILURE, 0)), councils,
	])
	quit(0)
