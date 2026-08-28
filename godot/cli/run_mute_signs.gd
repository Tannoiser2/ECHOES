extends SceneTree
## Quanto spesso esce un segno che nessuno legge (ISSUES 61).
##
##   godot --headless --path godot --script res://cli/run_mute_signs.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_00
##
## [D-225](../docs/DECISIONS.md#d-225) ha contato i segni **nei dati**: 71
## scritti sul mondo, 10 che nessuna regola, nessun obiettivo e nessuna pesca
## legge. ISSUES 61 chiede la seconda meta' prima di decidere cosa farne, e la
## chiede con le parole giuste: *«per ognuno dei dieci, quante volte esce in 100
## anni. Un segno muto che compare due volte in un secolo e' un problema minore
## di uno che compare duecento.»*
##
## Il registro conta le **penne**; questa sonda conta le **volte**. Sono due
## domande diverse e nessuna delle due risponde all'altra: una carta che scrive
## un segno muto e non viene mai giocata e' un difetto sulla carta, non sul
## mondo.
##
## Ogni segno esce con il suo posto nella classifica di **tutti** i segni, perche'
## «venti volte in cento anni» non vuol dire niente da solo: vuol dire qualcosa
## accanto alla mediana di quelli che mordono.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

## I dieci dichiarati muti, copiati da `MUTI_NOTI` in
## `tools/build_sign_registry.py`. La copia e' voluta: il cancello dei dati e'
## la', questa e' una sonda che si legge e non un secondo cancello, e tenerli
## uguali e' compito di chi accorcia l'elenco — che e' esattamente il momento in
## cui questa sonda serve.
const MUTI: Array = [
	"account_settled", "burden_shared", "condition:contested", "condition:lean",
	"condition:requisitioned", "dragon_slain", "heir_named",
	"settlement:$proponent", "succession_settled", "water_rights",
]

const WRITE_TYPES: Array = ["SET_REGION_TAG", "SET_GLOBAL_TAG", "SET_ENTITY_TAG"]


## Un segno dichiarato con un buco dentro non esiste con quel nome sul mondo.
##
## `settlement:$proponent` e' la forma **scritta**: il compilatore delle
## Conseguenze sostituisce anche il payload, quindi sul mondo finisce
## `settlement:ENT_NAHR`. Cercare la forma scritta dava zero, e zero e' la
## risposta piu' pericolosa che una sonda possa dare: dice «non succede mai»
## quando la verita' e' «non l'hai cercato». Un buco vale come prefisso.
static func _matches(declared: String, written: String) -> bool:
	if not declared.contains("$"):
		return declared == written
	var head: String = declared.substr(0, declared.find("$"))
	return head != "" and written.begins_with(head)


static func _tally(declared: String, written: Dictionary) -> int:
	var total: int = 0
	for tag in written:
		if _matches(declared, str(tag)):
			total += int(written[tag])
	return total


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var written: Dictionary = {}   # segno -> volte scritto
	var years_with: Dictionary = {} # segno -> anni in cui compare almeno una volta

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(3)
			return
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return

		var here: Dictionary = {}
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if not WRITE_TYPES.has(str(effect.get("type", ""))):
				continue
			var tag: String = str((effect.get("payload", {}) as Dictionary).get("tag", ""))
			if tag == "":
				continue
			written[tag] = int(written.get(tag, 0)) + 1
			here[tag] = true
		for tag in here:
			years_with[tag] = int(years_with.get(tag, 0)) + 1
		session.dispose()

	# La mediana di **tutti** i segni scritti: e' il metro contro cui leggere i
	# dieci. Senza, «esce 12 volte» non e' ne' tanto ne' poco.
	var counts: Array = []
	for tag in written:
		counts.append(int(written[tag]))
	counts.sort()
	var median: int = 0 if counts.is_empty() else int(counts[counts.size() / 2])

	var years: float = float(runs)
	print("")
	print("== I SEGNI MUTI - %d anni, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme",
	])
	print("")
	print("  %d segni diversi scritti sul mondo; la mediana ne conta %d in %d anni." % [
		written.size(), median, runs,
	])
	print("")
	print("  I dieci dichiarati muti (ISSUES 61):")
	print("")
	print("    %-26s %8s %8s   %s" % ["segno", "scritte", "anni", "parola"])
	var quiet: Array = MUTI.duplicate()
	quiet.sort_custom(func(a: Variant, b: Variant) -> bool:
		return _tally(str(a), written) > _tally(str(b), written)
	)
	var never: int = 0
	for tag in quiet:
		var times: int = _tally(str(tag), written)
		if times == 0:
			never += 1
		print("    %-26s %8d %7d%%   %s" % [
			str(tag), times,
			int(round(100.0 * float(_tally(str(tag), years_with)) / years)),
			SignLabels.label(str(tag), data),
		])
	print("")
	print("  %d dei dieci non escono mai in %d anni." % [never, runs])
	print("")
	print("  Per confronto, i dieci segni piu' scritti del mondo:")
	var loud: Array = written.keys()
	loud.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(written[a]) > int(written[b])
	)
	for i in range(mini(10, loud.size())):
		print("    %-26s %8d %7d%%" % [
			str(loud[i]), int(written[loud[i]]),
			int(round(100.0 * float(int(years_with.get(str(loud[i]), 0))) / years)),
		])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not str(argument).begins_with("--"):
			continue
		var pair: PackedStringArray = str(argument).substr(2).split("=", true, 1)
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
