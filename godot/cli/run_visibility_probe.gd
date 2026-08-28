extends SceneTree
## La sonda della visibilità (ISSUES 22, fase 4): un effetto invisibile è un
## bug, non un'atmosfera.
##
##   godot --headless --path godot --script res://cli/run_visibility_probe.gd -- \
##       --runs=100 --seed=7000
##
## Cento partite a tavolo misto (la lezione di D-063: si misura col tavolo
## vero), e poi il registro degli Effect riletto riga per riga contro il
## verbale della stessa partita. Per ogni effetto applicato la sonda decide:
##
## - **tace per scelta** — i silenzi dichiarati di D-103: i no-op, i delta
##   finiti a zero, la contabilità di Propp (`function:`), le Scar e i registri
##   Echo/Truth che hanno le loro righe, il setup che si racconta in apertura;
## - **il flusso ha la sua riga** — le azioni dei giocatori (il resolver
##   scrive una riga per template), la stagione che gira, la sovraestensione;
## - **deve stare a verbale** — tutto ciò che arriva da Conseguenze, clausole
##   e Consigli, e dalla carta del Narratore: la frase di `EffectNarrator`
##   deve comparire nel verbale, parola per parola;
## - **le carte che passano di mano** — GRANT/REMOVE/TRANSFER_ASSET: qualunque
##   sia la fonte, il titolo della carta deve comparire nel verbale (la pesca
##   lo scrive con parole sue, e va bene così: il testimone è il titolo).
##
## Quello che resta è **senza voce**, e la sonda lo nomina: tipo, fonte, e un
## esempio. «Fatto quando» della voce 22: questa lista è vuota.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var counts: Dictionary = {}          # tipo -> applicati
	var silent_by_choice: Dictionary = {} # categoria -> quanti
	var spoken: Dictionary = {}          # tipo -> con voce trovata
	var voiceless: Dictionary = {}       # "tipo/fonte" -> {count, example}

	for index in range(runs):
		var chronicle_id: String = "CHR_00"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		session.setup(chronicle_id, seats, seed_value)
		var table: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		await session.run(table)

		var text: String = session.log.text()
		for effect in session.world["effect_log"]:
			var type: String = str(effect.get("type", ""))
			counts[type] = int(counts.get(type, 0)) + 1
			var verdict: String = _classify(effect, data, text)
			if verdict == "":
				spoken[type] = int(spoken.get(type, 0)) + 1
				continue
			if verdict.begins_with("SENZA VOCE"):
				var source: Dictionary = effect.get("source", {})
				var key: String = "%s da %s/%s" % [
					type, str(source.get("kind", "?")), str(source.get("id", "?"))
				]
				if not voiceless.has(key):
					voiceless[key] = {"count": 0, "example": verdict.trim_prefix("SENZA VOCE: ")}
				voiceless[key]["count"] = int(voiceless[key]["count"]) + 1
			else:
				silent_by_choice[verdict] = int(silent_by_choice.get(verdict, 0)) + 1
		session.dispose()

	print("")
	print("== LA SONDA DELLA VISIBILITA' - %d partite, semi da %d ==" % [runs, first_seed])
	print("")
	print("Effect applicati, per tipo (con voce trovata a verbale):")
	for type in _sorted(counts.keys()):
		print("  %-24s %6d   (a verbale: %d)" % [type, int(counts[type]), int(spoken.get(type, 0))])
	print("")
	print("I silenzi dichiarati (D-103):")
	for category in _sorted(silent_by_choice.keys()):
		print("  %-46s %6d" % [category, int(silent_by_choice[category])])
	print("")
	if voiceless.is_empty():
		print("SENZA VOCE: 0. Ogni effetto che deve parlare, parla.")
	else:
		print("SENZA VOCE (un effetto invisibile e' un bug):")
		for key in _sorted(voiceless.keys()):
			print("  %-52s %5d   es: %s" % [
				key, int(voiceless[key]["count"]), str(voiceless[key]["example"])
			])
	quit(0 if voiceless.is_empty() else 1)


## "" = ha la sua voce; una categoria = tace per scelta; "SENZA VOCE: ..." = bug.
func _classify(effect: Dictionary, data: RefCounted, text: String) -> String:
	var type: String = str(effect.get("type", ""))
	var payload: Dictionary = effect.get("payload", {})
	var source: Dictionary = effect.get("source", {})
	var source_kind: String = str(source.get("kind", ""))
	var source_id: String = str(source.get("id", ""))

	# I registri che hanno le loro righe: la Scar parla con la sua voce, Echo e
	# Truth hanno le loro sezioni nel verbale.
	if type in ["ADD_SCAR", "REMOVE_SCAR", "CREATE_ECHO", "APPEND_TRUTH"]:
		return "registro con la sua riga (Scar/Echo/Truth)"
	# Un no-op non ha mosso niente: tacere e' correttezza, non silenzio.
	if bool(effect.get("inverse_payload", {}).get("noop", false)):
		return "no-op: niente da dire"
	if type == "ADJUST_TENSION" and int(effect.get("inverse_payload", {}).get("delta", 0)) == 0:
		return "delta finito a zero (clamp)"
	if type == "SET_GLOBAL_TAG" and str(payload.get("tag", "")).begins_with("function:"):
		return "contabilita' di Propp (D-030)"
	# Il tavolo iniziale si racconta nella SITUAZIONE INIZIALE, non effetto per
	# effetto; l'eredita' di una saga nel verbale d'apertura (D-089).
	if source_kind == "system" and source_id in ["SETUP", "INHERITANCE"]:
		return "setup/eredita': si raccontano in apertura"
	# La stagione che gira e la sovraestensione scrivono la loro riga nel punto
	# in cui accadono; il Drift si legge nello stato delle Tensioni a fine round.
	if source_kind == "system":
		return "sistema con la sua riga (%s)" % source_id

	# Le carte che passano di mano: qualunque flusso le muova, il titolo della
	# carta deve stare a verbale (la pesca lo scrive con parole sue).
	if type in ["GRANT_ASSET", "REMOVE_ASSET", "TRANSFER_ASSET"]:
		var asset: Variant = data.assets.get(str(payload.get("asset_id", "")))
		var title: String = "" if asset == null else str(asset["title"])
		if title != "" and text.contains(title):
			return ""
		return "SENZA VOCE: %s di «%s» (%s/%s)" % [type, title, source_kind, source_id]

	# Le azioni dei giocatori: il resolver scrive una riga per template, ed e'
	# gia' asserito altrove che ogni azione offerta e' legale e raccontata.
	if source_kind == "action" and source_id != "ACT_PLAY_ECHO":
		return "azione: il resolver ha la sua riga"

	# Due voci di flusso dichiarate nel Consiglio, con parole loro: il Ripple
	# («K. Ripple: <titolo> +N») e la spirale che si chiude quando la domanda
	# caduta viene ridecisa (D-094). Il verbale le ha gia'; la sonda le accetta.
	if type == "ADJUST_TENSION" and source_kind == "confluence":
		var tension: Variant = data.tensions.get(str(effect.get("target", {}).get("id", "")))
		if tension != null and text.contains("Ripple: %s" % str(tension["title"])):
			return ""
	if type == "REMOVE_GLOBAL_TAG" and str(payload.get("tag", "")) == "question_unresolved" \
			and text.contains("la spirale si chiude"):
		return "la spirale si chiude: ha la sua riga (D-094)"

	# Tutto il resto - Conseguenze, clausole, Consigli, carta del Narratore -
	# deve stare a verbale con la frase del narratore, parola per parola.
	var said: String = EffectNarrator.narrate(effect, data)
	if said == "":
		return "SENZA VOCE: %s muto per il narratore (%s/%s)" % [type, source_kind, source_id]
	if text.contains(said):
		return ""
	return "SENZA VOCE: manca a verbale «%s» (%s/%s)" % [said, source_kind, source_id]


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out


func _parse_args(args: Array) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if text.begins_with("--") and text.contains("="):
			var parts: PackedStringArray = text.substr(2).split("=", true, 1)
			out[str(parts[0])] = str(parts[1])
	return out
