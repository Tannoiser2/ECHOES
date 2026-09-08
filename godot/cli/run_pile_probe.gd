extends SceneTree
## **Quante volte il mondo segnato muove il mucchio** (D-477).
##
##   godot --headless --path godot --script res://cli/run_pile_probe.gd -- --runs=100
##
## Le ventun regole `COUNCIL_MODIFIER` sono state puntate sul mucchio: la fame
## sparsa in giro alza la soglia di un Consiglio sulla Carestia, una citta' che
## parla forte la abbassa. **Rimetterle in vita non basta**: una regola che
## esiste e non morde mai e' identica, per il gioco, a una regola che non c'e'
## (D-035), e questa e' la differenza che solo una misura sa dire.
##
## Tre numeri, e il terzo e' quello che decide:
##
##   1. **quanti Consigli** il mondo tocca, su quanti se ne tengono;
##   2. **di quanto** lo muove, quando lo muove;
##   3. **quali delle ventuno** mordono davvero, e quali restano scritte e mute.
##
## Nessuna regola cambia: la sonda gioca le partite come sono e conta il mucchio
## all'apertura di ogni Consiglio, che e' dove `ConfluenceController` lo scrive.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

var councils: int = 0
var moved: int = 0
var raised: int = 0
var lowered: int = 0
var total_shift: int = 0
var by_rule: Dictionary = {}


func _initialize() -> void:
	var runs: int = 100
	var first: int = 7000
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--runs="):
			runs = int(a.substr(7))
		elif a.begins_with("--seed="):
			first = int(a.substr(7))
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for e in data.errors:
			printerr("  %s" % e)
		quit(3)
		return

	for run in range(runs):
		var seed_value: int = first + run
		var seats: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup("CHR_00", seats, seed_value):
			printerr(session.last_error)
			quit(3)
			return
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		# Il mucchio si legge **alla chiusura**, e non all'apertura: il
		# controller emette due soli passi, `QUESTION` e `RESOLVED`, e le due
		# parti si aprono in mezzo senza segnale. Al `RESOLVED` il record porta
		# ancora `pile_shift`, che e' quello che serve.
		#
		# La prima stesura ascoltava un passo «SIDES» che non esiste e contava
		# **zero Consigli su cinquecento**: in questo progetto uno zero e' quasi
		# sempre la sonda cieca, ed e' stato cosi' anche stavolta.
		session.confluence.step_changed.connect(_watch)
		var brain: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		await session.run(brain)

	print("IL MONDO SEGNATO SUL MUCCHIO - %d anni, semi da %d" % [runs, first])
	print("")
	print("  Consigli tenuti          %d" % councils)
	print("  ...col mucchio mosso     %d   (%.0f%%)" % [
		moved, 0.0 if councils == 0 else 100.0 * float(moved) / float(councils)
	])
	print("     — soglia alzata       %d" % raised)
	print("     — soglia abbassata    %d" % lowered)
	if moved > 0:
		print("  spostamento medio        %.2f (quando si muove)" % (
			float(total_shift) / float(moved)
		))
	print("")
	print("  LE VENTUNO, UNA PER UNA")
	var names: Array = by_rule.keys()
	names.sort_custom(func(a, b) -> bool: return int(by_rule[a]) > int(by_rule[b]))
	for name in names:
		print("    %-46s %d" % [str(name), int(by_rule[name])])
	print("    (le altre non hanno mai morso)")
	quit(0)


func _watch(step: String, council: Dictionary) -> void:
	if step != "RESOLVED":
		return
	councils += 1
	var shift: int = int(council.get("pile_shift", 0))
	if shift == 0:
		return
	moved += 1
	total_shift += absi(shift)
	if shift > 0:
		raised += 1
	else:
		lowered += 1
	for title in (council.get("pile_shift_titles", []) as Array):
		by_rule[str(title)] = int(by_rule.get(str(title), 0)) + 1
