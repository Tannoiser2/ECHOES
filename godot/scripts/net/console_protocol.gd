extends RefCounted
## Il protocollo delle console (voce 27, fase 2 — D-135): quattro messaggi.
##
## Dall'host al telefono: `state` (il ConsoleModel del seggio, D-134), `say`
## (una riga per quel seggio), `choose` (le opzioni del decider, con un
## `ask_id`). Dal telefono all'host: `chosen` (l'indice, con l'`ask_id` a cui
## risponde — una risposta vecchia si scarta). Ogni messaggio dell'host porta
## il `clock`: la sequenza degli Effect del mondo al momento dell'invio, il
## modo con cui un rientro capisce cosa e' stantio.
##
## La disciplina dei segreti NON abita qui: i payload sono i modelli di vista
## di D-134, filtrati alla costruzione. `audit()` e' la perquisizione che lo
## prova, messaggio per messaggio — la usano la sonda e i test.

const ConsoleModel := preload("res://scripts/views/console_model.gd")


static func clock(session: RefCounted) -> int:
	return int(session.world.get("effect_sequence", 0))


static func state_message(session: RefCounted, seat_id: String) -> Dictionary:
	return {
		"kind": "state",
		"clock": clock(session),
		"model": ConsoleModel.build(session, seat_id),
	}


static func say_message(session: RefCounted, text: String) -> Dictionary:
	return {"kind": "say", "clock": clock(session), "text": str(text)}


static func choose_message(
	session: RefCounted, ask_id: int, prompt: String, labels: Array, subjects: Array
) -> Dictionary:
	return {
		"kind": "choose",
		"clock": clock(session),
		"ask_id": ask_id,
		"prompt": str(prompt),
		"labels": labels.duplicate(),
		"subjects": subjects.duplicate(true),
	}


static func chosen_message(ask_id: int, index: int) -> Dictionary:
	return {"kind": "chosen", "ask_id": ask_id, "index": index}


static func encode(message: Dictionary) -> String:
	return JSON.stringify(message)


static func decode(text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


## La perquisizione (la regola dei pixel applicata ai messaggi, §11.1): un
## messaggio diretto alla console di `seat_id` non deve contenere un segreto
## di nessun altro seggio. Restituisce le violazioni trovate (vuoto =
## pulito), calcolate sul mondo di ADESSO: la sonda chiama qui a ogni invio,
## quando i segreti sono vivi.
##
## Le mani si perquisiscono sulla STRUTTURA, non sulle parole: le carte
## esistono in copie e il titolo e' condiviso fra loro — «Carovana» scartata
## da questo seggio sta legittimamente nel suo verbale anche se un vicino ne
## tiene un'altra copia in mano. Cio' che e' segreto e' QUALI copie hai in
## mano, e quello si prova sul campo `hand` dello state: deve essere
## esattamente la mano del seggio, ne' una carta in piu' ne' una di un
## altro. (La prima forma di questa perquisizione cercava i titoli nel
## testo: 658 «fughe» su 100 partite, tutte false — copie e prosa.)
## I gradini del Destino altrui restano un text-scan: sono frasi d'autore,
## uniche e mai legittime su una console che non le ha giurate.
static func audit(message: Dictionary, session: RefCounted, seat_id: String) -> Array:
	var found: Array = []
	var stringified: String = encode(message)
	for other in session.world["turn_order"]:
		if str(other) == seat_id:
			continue
		var destiny: Variant = session.data.destinies.get(
			session.service.destiny_of(str(other))
		)
		if destiny == null:
			continue
		for level in ["minimum", "victory", "triumph"]:
			var label: String = str((destiny as Dictionary)[level]["label"])
			if stringified.contains(label):
				found.append("il Destino di %s trapela («%s»)" % [str(other), label])

	if str(message.get("kind", "")) != "state":
		return found
	var model: Dictionary = message.get("model", {})

	# La mano dello state e' la mano del seggio, carta per carta.
	# Sugli id e non sui titoli, da quando la mano porta l'id per chiedere la
	# faccia (D-144): l'id e' la carta, il titolo e' come la chiamiamo.
	var mine: Array = []
	for asset_id in session.service.hand(seat_id):
		mine.append(str(asset_id))
	mine.sort()
	var shown: Array = []
	for card in model.get("hand", []):
		shown.append(str((card as Dictionary).get("id", "")))
	shown.sort()
	if shown != mine:
		found.append("la mano dello state non e' quella del seggio (%s ≠ %s)" % [
			str(shown), str(mine)
		])
	# E lo state e' proprio il SUO: un messaggio instradato male porterebbe
	# il nome di un altro.
	if str(model.get("name", "")) != session.service.name_of(seat_id):
		found.append("lo state porta il nome di un altro seggio («%s»)" % str(model.get("name", "")))

	# La domanda coperta: se il seggio non la conosce, il suo numero non deve
	# stare nel modello (il -1 e' il dorso).
	for tension in model.get("tensions", []):
		var entry: Dictionary = tension
		if int(entry.get("value", -1)) < 0:
			continue
		var tension_id: String = _tension_by_title(session, str(entry.get("title", "")))
		if tension_id == "":
			continue
		if session.service.visible_tension_value(tension_id, seat_id) < 0:
			found.append("il numero della domanda coperta «%s» trapela" % str(entry["title"]))
	return found


## La perquisizione della **vetrina** (D-144). Fin qui `audit` guardava i
## messaggi diretti a una console — che hanno un viewer, e quindi un metro. La
## vetrina non ha viewer: e' pubblica per costruzione, e proprio per questo
## nessuno le aveva mai chiesto conto di niente. Il metro qui non e' «cosa sa
## questo seggio» ma «cosa sa il tavolo»: quello che sta in una mano non e'
## roba del tavolo, di nessun seggio, mai.
static func audit_table(message: Dictionary, session: RefCounted) -> Array:
	var found: Array = []
	if str(message.get("kind", "")) != "table":
		return found
	var model: Dictionary = message.get("model", {})
	var held: Dictionary = {}
	for entity_id in session.world["entities"]:
		var seat: Dictionary = session.world["entities"][str(entity_id)]
		for card_id in seat.get("echo_hand", []):
			held[str(card_id)] = str(entity_id)
	for played in model.get("echoes_played", []):
		var entry: Dictionary = played
		var card_id: String = str(entry.get("id", ""))
		if held.has(card_id):
			found.append("la vetrina mostra «%s», che e' in mano a %s" % [
				str(entry.get("title", card_id)), session.service.name_of(str(held[card_id]))
			])
	# Le carte impegnate in un Consiglio **chiuso** sono roba del tavolo: gli
	# impegni si rivelano tutti insieme in seduta (D-014), e quello che il
	# tavolo ha visto rivelare puo' restare in tavola. Quelle di un Consiglio
	# **aperto** no: li' l'impegno e' ancora coperto, e mostrarlo sarebbe dire a
	# tutti cosa ha appena messo giu' chi non ha ancora rivelato (D-145).
	# Sull'identita' della seduta e non sul titolo della domanda: la stessa
	# domanda torna al Consiglio piu' volte in una Chronicle, e la prima stesura
	# di questa guardia ha gridato al lupo 58 volte per quello (D-145).
	if session.confluence.is_open():
		var open_id: String = str(session.confluence.current.get("confluence_id", ""))
		for council in model.get("councils", []):
			if open_id != "" and str((council as Dictionary).get("id", "")) == open_id:
				found.append("la vetrina mostra il Consiglio ancora aperto (%s)" % open_id)

	# Le carte Asset **non** si cercano per titolo, e la lezione e' costata due
	# volte: la prima forma di `audit` consegno' 658 fughe tutte false, questa
	# ne ha consegnate 54 — «la vetrina nomina "Sale", che e' in mano a Kessa».
	# «Sale» e' una carta e insieme una casa (la Gilda del Sale, CHR_03): un
	# titolo di una parola vive dentro la prosa di mezzo mondo. Il metro giusto
	# resta quello strutturale: il modello del tavolo non ha, e non deve avere,
	# nessun campo che elenchi una mano — se un domani ne spuntasse uno, la
	# fuga si prova aggiungendo qui il confronto su quel campo, non cercando
	# parole nel testo (D-135, D-144).
	return found


static func _tension_by_title(session: RefCounted, title: String) -> String:
	for tension_id in session.world["tensions"]:
		if str(session.data.tensions[str(tension_id)]["title"]) == title:
			return str(tension_id)
	return ""
