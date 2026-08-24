extends RefCounted
## Drift, omens and threshold checks (§11).

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var log: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted, p_applier: RefCounted, p_log: RefCounted) -> void:
	world = p_world
	data = p_data
	applier = p_applier
	log = p_log


## §11.2: at the end of every round the world pushes one Tension up by 1,
## following the drift track shuffled at setup.
func apply_drift() -> String:
	# D-192: quando il calore lo pescano i giocatori, l'orologio si ferma. I due
	# insieme farebbero 27,7 gettoni l'anno contro i 9 di oggi — un terzo gioco
	# che nessuno ha chiesto.
	if _tokens_replace_drift():
		return ""
	var track: Array = world["drift_track"]
	var index: int = int(world["drift_index"])
	if index >= track.size():
		log.bullet("Drift: la traccia e esaurita, nessuna Tensione sale.")
		return ""
	var tension_id: String = str(track[index])
	world["drift_index"] = index + 1

	var source: Dictionary = Effect.source(
		"system", "DRIFT", "", int(world["act"]), int(world["round"]), index
	)
	applier.apply(
		Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": 1}, source)
	)
	log.bullet("Drift: %s sale di 1." % _public_name(tension_id))
	fire_omens(source)
	return tension_id


## Public narrative signals (§11.3). The message comes from the data; the code
## never invents one, and a veiled Tension never leaks its number here.
func fire_omens(source: Dictionary) -> void:
	for tension_id in world["tensions"]:
		var state: Dictionary = world["tensions"][tension_id]
		var definition: Dictionary = data.tensions[tension_id]
		for omen in definition["omen_thresholds"]:
			var at: int = int(omen["at"])
			if int(state["current_value"]) < at:
				continue
			if (state["fired_omens"] as Array).has(at):
				continue
			state["fired_omens"].append(at)
			log.bullet("Presagio - %s" % str(omen["message"]))
			if bool(omen.get("reveals_value", false)):
				var revealed: Dictionary = applier.apply(
					Effect.make(
						"SET_TENSION_VISIBILITY",
						"tension",
						str(tension_id),
						{"visibility": "OPEN"},
						source
					)
				)
				# ISSUES 22 (fase 4): il presagio parlava, la rivelazione no -
				# il numero arrivava sul tavolo in silenzio. Se ha davvero
				# svelato qualcosa (niente no-op), adesso lo dice.
				var said: String = EffectNarrator.narrate(revealed, data)
				if said != "":
					log.bullet(said)


## §7: at most one Confluence opens per round. Tensions at or over threshold are
## ranked by value, then by the Chronicle's definition order; the rest queue up.
## Il cancello del tavolo (D-203), scelta **b** del committente: «una soglia sola
## per il tavolo, non una per domanda».
##
## Dichiarato `tension_tokens.table_gate`, non e' piu' la singola Tensione a
## chiamare il Consiglio quando supera la propria soglia: il Consiglio si apre
## quando sono scesi **tanti gettoni in tutto**, e la domanda che si dibatte e'
## **il mucchio piu' alto**. E' la differenza fra un mondo dove ogni domanda ha
## il suo orologio e un mondo dove il tavolo ne ha uno solo — e la sonda ombra
## di D-190 diceva che sette volte su dieci la domanda scelta e' un'altra.
##
## A zero, o senza la dichiarazione, decide la soglia di ciascuna come sempre.
func table_gate() -> int:
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return 0
	var rules: Dictionary = (chronicle as Dictionary).get("tension_tokens", {}) as Dictionary
	return 0 if rules.is_empty() else int(rules.get("table_gate", 0))


## I mucchi sono coperti? (ISSUES 49 fase 3) La Chronicle lo dichiara col
## sacchetto dei valori: se un gettone puo' valere 0, 1 o 2, il mucchio non si
## legge piu' contando i gettoni, e allora vale la pena coprirlo.
func piles_are_covered() -> bool:
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return false
	var rules: Dictionary = (chronicle as Dictionary).get("tension_tokens", {}) as Dictionary
	return not (rules.get("covered", []) as Array).is_empty()


## Quanti gettoni sono caduti su una domanda: quello che al tavolo si **vede**
## quando i mucchi sono coperti. Contati dal registro degli Effetti, che e'
## l'unica fonte di verita' su cosa e' successo (§6.3) — e che registra anche il
## gettone bianco, perche' cadere e valere sono due cose diverse.
func tokens_on(tension_id: String) -> int:
	var seen: int = 0
	for entry in (world.get("effect_log", []) as Array):
		var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
		if str(effect.get("type", "")) != "ADJUST_TENSION":
			continue
		if str((effect.get("target", {}) as Dictionary).get("id", "")) != tension_id:
			continue
		# `Effect.source("system", "TENSION_TOKEN", ...)`: il tipo sta in `kind`,
		# il **motivo** in `id`. Guardare `kind` avrebbe contato ogni Effetto di
		# sistema, Deriva compresa.
		if str((effect.get("source", {}) as Dictionary).get("id", "")) != "TENSION_TOKEN":
			continue
		seen += 1
	return seen


# --- i mazzetti dei Temi (D-261) --------------------------------------------


## A quanti segnalini si gira la prima carta del mazzetto. Parola del
## committente: due. Il conto e' dei **gettoni caduti**, non del loro valore,
## perche' e' quello che il tavolo vede.
func reveal_at() -> int:
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return 2
	var rules: Dictionary = (chronicle as Dictionary).get("theme_tokens", {}) as Dictionary
	return int(rules.get("reveal_at", 2))


## La carta girata del Tema: la Tensione che il tavolo sa essere quella che si
## va scaldando li'. Vuota, il mazzetto e' tutto coperto.
func theme_front(theme_id: String) -> String:
	return str((world.get("theme_front", {}) as Dictionary).get(theme_id, ""))


## Quanti gettoni coperti stanno sul mazzetto del Tema.
func theme_token_count(theme_id: String) -> int:
	return int((world.get("theme_tokens", {}) as Dictionary).get(theme_id, 0))


## Gira la prima carta del mazzetto (D-261): da qui in poi il tavolo sa quale
## Tensione si va scaldando su questo Tema. L'ordine del mazzetto l'ha deciso
## il setup col suo dado; girare **consuma dalla testa e basta**, quindi e' un
## gesto raccontabile e ripetibile — come pescare da un mazzo vero. Torna la
## Tensione girata, o "" se il mazzetto e' finito.
func flip_theme_front(theme_id: String) -> String:
	var decks: Dictionary = world.get("theme_decks", {}) as Dictionary
	var deck: Array = decks.get(theme_id, []) as Array
	if deck.is_empty():
		return ""
	var tension_id: String = str(deck.pop_front())
	decks[theme_id] = deck
	world["theme_front"][theme_id] = tension_id
	log.bullet("La prima carta del mazzetto di %s si gira: e' «%s» che si va scaldando." % [
		str((data.themes.get(theme_id, {}) as Dictionary).get("title", theme_id)),
		_public_name(tension_id),
	])
	# **Girare apre la questione** (D-264). Col mazzetto pieno la carta girata
	# puo' essere una domanda che l'anno non aveva ancora aperto: da questo
	# momento e' in gioco — stato strutturale con la forma del setup, come una
	# questione pescata all'apertura. Non entra nel sacchetto della Deriva
	# dell'anno: si scalda coi mazzetti e coi Consigli, ed e' dichiarato.
	if not (world["tensions"] as Dictionary).has(tension_id) and data.tensions.has(tension_id):
		var definition: Dictionary = data.tensions[tension_id]
		world["tensions"][tension_id] = {
			"id": tension_id,
			"current_value": int(definition["current_value"]),
			"visibility": str(definition["visibility"]),
			"fired_omens": [],
			"resolved_count": 0,
		}
		log.bullet("«%s» entra in gioco: il tavolo adesso se lo chiede." % _public_name(tension_id))
	return tension_id


## Il mucchio piu' alto: la domanda che il tavolo ha scaldato di piu'. A parita'
## vince quella che viene prima nell'ordine del mondo, cosi' il seme decide e non
## l'ordine con cui un Dictionary si lascia leggere.
func hottest_pile() -> String:
	var best: String = ""
	var most: int = -1
	for tension_id in world["tensions"]:
		var here: int = int(world["tensions"][tension_id]["current_value"])
		if here > most:
			most = here
			best = str(tension_id)
	return best


func tensions_at_threshold() -> Array:
	var gate: int = table_gate()
	if gate > 0:
		if int(world.get("tokens_in_bag", 0)) < gate:
			return []
		var hottest: String = hottest_pile()
		return [] if hottest == "" else [hottest]
	var ready: Array = []
	for tension_id in world["tensions"]:
		var value: int = int(world["tensions"][tension_id]["current_value"])
		if value >= threshold(str(tension_id)):
			ready.append(str(tension_id))
	# Draw order for a library Chronicle, written order for an authored one:
	# world["tensions"] holds whichever applies (D-028).
	var order: Array = (world["tensions"] as Dictionary).keys()
	ready.sort_custom(func(a: String, b: String) -> bool:
		var value_a: int = int(world["tensions"][a]["current_value"])
		var value_b: int = int(world["tensions"][b]["current_value"])
		if value_a == value_b:
			return order.find(a) < order.find(b)
		return value_a > value_b
	)
	return ready


func value(tension_id: String) -> int:
	return int(world["tensions"][tension_id]["current_value"])


## La soglia scritta sulla Tensione, piu' il ritocco che la Chronicle dichiara.
##
## Il ritocco esiste perche' le soglie sono **dato della Tensione, condiviso dai
## due lati dell'interruttore** (D-192): col sacchetto acceso il mondo si scalda
## di piu' e le soglie vanno alzate, ma la stessa Tensione gioca anche dove il
## sacchetto e' spento, e li' una soglia alzata non si raggiunge mai. Il numero
## scritto resta quello del gioco di sempre; il ritocco vive con la regola che lo
## rende necessario.
func threshold(tension_id: String) -> int:
	return int(data.tensions[tension_id]["threshold"]) + _threshold_bonus()


func _threshold_bonus() -> int:
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return 0
	var rules: Dictionary = (chronicle as Dictionary).get("tension_tokens", {}) as Dictionary
	return 0 if rules.is_empty() else int(rules.get("threshold_bonus", 0))


func is_veiled(tension_id: String) -> bool:
	return str(world["tensions"][tension_id]["visibility"]) != "OPEN"


## La Deriva a orologio si spegne quando il sacchetto dei giocatori la sostituisce.
func _tokens_replace_drift() -> bool:
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return false
	var rules: Dictionary = (chronicle as Dictionary).get("tension_tokens", {}) as Dictionary
	return not rules.is_empty() and bool(rules.get("replaces_drift", true))


## La Chronicle dice cosa nasconde il velo (D-187): tutto, o solo la soglia.
func hides_threshold_only() -> bool:
	return WorldStateService.veil_hides_threshold_only(world, data)


## Una velata e' fuori portata solo finche' il velo copre **tutto**: se copre la
## sola soglia, sulla domanda si agisce come su ogni altra — non sapere quando
## esplodera' e' il rischio, non un divieto.
func out_of_reach(tension_id: String, knows: bool) -> bool:
	return is_veiled(tension_id) and not hides_threshold_only() and not knows


## La soglia che ci si aspetta quando non si sa: la media di quelle in gioco,
## arrotondata. Serve ai seggi quando il velo copre la soglia (D-187) — non
## sapere non vuol dire non avere un'idea, e un'idea deterministica e' l'unica
## che una macchina puo' avere senza barare guardando il dato.
func typical_threshold() -> int:
	var total: int = 0
	var count: int = 0
	for tension_id in world["tensions"]:
		total += int(data.tensions[str(tension_id)]["threshold"])
		count += 1
	if count == 0:
		return 0
	return int(round(float(total) / float(count)))


## What the public log is allowed to say about a Tension.
##
## Col cancello del tavolo la soglia della singola domanda **non decide piu'
## niente** (D-203), e stamparla sarebbe la bugia piu' semplice del gioco: una
## persona leggerebbe «4/7» e aspetterebbe il sette, mentre il Consiglio si apre
## quando il tavolo ha posato tre gettoni e a dibattersi va il mucchio piu' alto.
## Quindi si dice il mucchio, e si dice **se e' il piu' alto**.
func public_status(tension_id: String) -> String:
	if table_gate() > 0:
		if is_veiled(tension_id) and not hides_threshold_only():
			return "%s: velata" % _public_name(tension_id)
		# **Coperto si vede il mucchio, non il punteggio** (ISSUES 49 fase 3).
		# E non si dice nemmeno quale sia il piu' alto: quella riga e'
		# esattamente l'informazione che coprire toglie, e stamparla renderebbe
		# la copertura una decorazione.
		if piles_are_covered():
			var pile: int = tokens_on(tension_id)
			return "%s: %d %s coperti" % [
				_public_name(tension_id), pile, "gettone" if pile == 1 else "gettoni"
			]
		var mark: String = " (il più alto)" if hottest_pile() == tension_id else ""
		return "%s: %d%s" % [_public_name(tension_id), value(tension_id), mark]
	if is_veiled(tension_id):
		if hides_threshold_only():
			return "%s: %d/?" % [_public_name(tension_id), value(tension_id)]
		return "%s: velata" % _public_name(tension_id)
	return "%s: %d/%d" % [
		_public_name(tension_id), value(tension_id), threshold(tension_id)
	]


func _public_name(tension_id: String) -> String:
	return str(data.tensions[tension_id]["title"])
