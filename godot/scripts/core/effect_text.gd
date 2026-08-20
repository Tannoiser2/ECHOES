extends RefCounted
## An Effect, said out loud.
##
## The log has always printed the *consequences* of an Effect - a Tension's new
## value, a Scar's description - because that is what a reader of the log wants.
## This says what the Effect itself did, in one line, for the places that show a
## thing and then have to explain it: the Act-end Echo card, and whatever comes
## after it (D-044).
##
## Unknown types report themselves by name rather than staying silent. A card
## that quietly did something is worse than a card that says `SET_ENTITY_TAG`.

## The `function:` tag every Echo card writes is bookkeeping - it is how a later
## card can require an earlier one (D-030) - and saying it out loud would tell a
## player about the deck's plumbing instead of about their world.
const HIDDEN_TAG_PREFIX: String = "function:"

## Il vocabolario della mappa, in italiano. Un tag e' un identificativo: sta
## bene nei dati e non si legge al tavolo. Fino a 0.1.120 il registro pubblico
## e la console dicevano «Valle Verde: condition:lean», che e' esattamente il
## difetto che il committente ha trovato giocando — le frasi sono belle e non si
## capiscono. Quello che manca a un tag e' un verbo.
const TAGS: Dictionary = {
	# Come sta una Regione, adesso. Sbiadisce sui salti lunghi.
	"condition:starving": "si muore di fame",
	"condition:lean": "il raccolto non basta",
	"condition:rationed": "si mangia a razione",
	"condition:requisitioned": "il grano e' stato preso",
	"condition:unrest": "monta il malcontento",
	"condition:contested": "e' conteso",
	"condition:cut_off": "resta tagliato fuori",
	"condition:plundered": "e' stato depredato",
	"condition:abandoned": "e' stato lasciato",
	"condition:emptied": "si e' svuotato",
	"condition:mourning": "e' in lutto",
	"condition:exploited": "viene sfruttato",
	"condition:indebted": "e' pieno di debiti",
	# Cosa ci hanno costruito. Non sbiadisce mai.
	"structure:granary": "vi sorge un granaio",
	"structure:canal": "i canali portano acqua",
	"structure:tollgate": "vi sorge una barriera di pedaggio",
	"structure:watchtower": "vi sorge una torre di veglia",
	"structure:sealed": "e' stato murato",
	# Le cicatrici: la memoria visibile della mappa.
	"scar:burned": "la bruciatura",
	"scar:emptied": "il vuoto lasciato",
	"scar:abandoned": "l'abbandono",
	"scar:plundered": "la razzia",
	"scar:broken_bridge": "il ponte spezzato",
	"scar:broken_word": "la parola tradita",
	"scar:changed_hands": "il passaggio di mano",
	"scar:divided_seal": "il sigillo diviso",
	"scar:dragonfall": "la caduta del drago",
	"scar:open_wound": "la ferita aperta",
	"scar:sealed_border": "il confine chiuso",
	"scar:the_empty_chair": "la sedia vuota",
	"scar:unanswered": "la domanda senza risposta",
}


## Quando il segno **sparisce**. «non piu si muore di fame» non e' italiano: una
## condizione che finisce ha una frase sua. Dove manca si ripiega su «non piu».
const TAGS_GONE: Dictionary = {
	"condition:starving": "la fame e' passata",
	"condition:lean": "il raccolto ha tenuto",
	"condition:rationed": "la razione e' finita",
	"condition:requisitioned": "il grano e' tornato suo",
	"condition:unrest": "il malcontento si e' spento",
	"condition:contested": "non lo contende piu nessuno",
	"condition:cut_off": "la strada e' riaperta",
	"condition:plundered": "la razzia e' stata rimediata",
	"condition:abandoned": "ci si e' tornati",
	"condition:emptied": "si e' ripopolato",
	"condition:mourning": "il lutto e' finito",
	"condition:exploited": "lo sfruttamento e' cessato",
	"condition:indebted": "i debiti sono chiusi",
	"structure:granary": "il granaio non c'e' piu",
	"structure:canal": "i canali si sono insabbiati",
	"structure:tollgate": "la barriera e' stata tolta",
	"structure:watchtower": "la torre e' stata abbattuta",
	"structure:sealed": "il muro e' stato aperto",
}


## Il segno che sparisce, detto a voce.
static func tag_gone(tag: String) -> String:
	if TAGS_GONE.has(tag):
		return str(TAGS_GONE[tag])
	return "non piu %s" % tag_words(tag)


## Un tag detto a voce. I prefissi che il gioco usa come famiglie hanno una
## forma loro; il resto si legge come una frase invece che come un
## identificativo — `debt_called` e' «il debito chiamato», non `debt_called`.
static func tag_words(tag: String) -> String:
	if TAGS.has(tag):
		return str(TAGS[tag])
	if tag.begins_with("discovery:"):
		return "una Scoperta (%s)" % _plain(tag.substr(10))
	if tag.begins_with("settlement:"):
		return "un insediamento (%s)" % _plain(tag.substr(11))
	if tag.begins_with("legend:"):
		return "una leggenda (%s)" % _plain(tag.substr(7))
	if tag.begins_with("life:"):
		return "una vita nuova (%s)" % _plain(tag.substr(5))
	return _plain(tag)


static func _plain(tag: String) -> String:
	return tag.replace("_", " ").replace(":", " ")


static func say(effect: Dictionary, data: RefCounted) -> String:
	var target: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
	var payload: Dictionary = effect.get("payload", {})
	match str(effect.get("type", "")):
		"ADJUST_TENSION":
			var delta: int = int(payload.get("delta", 0))
			return "%s %s di %d" % [
				_tension(target, data), "sale" if delta >= 0 else "scende", absi(delta),
			]
		"SET_TENSION_VISIBILITY":
			return "%s adesso e %s" % [
				_tension(target, data),
				"aperta a tutti" if str(payload.get("visibility", "")) == "OPEN" else "velata",
			]
		"SET_REGION_TAG":
			return "%s: %s" % [_region(target, data), tag_words(str(payload.get("tag", "")))]
		"REMOVE_REGION_TAG":
			return "%s: %s" % [_region(target, data), tag_gone(str(payload.get("tag", "")))]
		"SET_GLOBAL_TAG":
			var tag: String = str(payload.get("tag", ""))
			return "" if tag.begins_with(HIDDEN_TAG_PREFIX) else "Nel mondo: %s" % tag_words(tag)
		"REMOVE_GLOBAL_TAG":
			return "Nel mondo: %s" % tag_gone(str(payload.get("tag", "")))
		"SET_ENTITY_TAG":
			return "%s: %s" % [_name(target, data), tag_words(str(payload.get("tag", "")))]
		"REMOVE_ENTITY_TAG":
			return "%s: %s" % [_name(target, data), tag_gone(str(payload.get("tag", "")))]
		"ADD_PRESENCE":
			return "%s mette una presenza in %s" % [
				_name(target, data), _region(str(payload.get("region_id", "")), data),
			]
		"REMOVE_PRESENCE":
			return "%s lascia %s" % [
				_name(target, data), _region(str(payload.get("region_id", "")), data),
			]
		"SET_CONTROL":
			var holder: Variant = payload.get("control", null)
			return "%s passa a %s" % [_region(target, data), _name(str(holder), data)] \
				if holder != null else "%s non e piu di nessuno" % _region(target, data)
		"SET_RELATION":
			var pair: PackedStringArray = target.split("|")
			var who: String = target.replace("|", " / ")
			if pair.size() == 2:
				who = "%s / %s" % [_name(str(pair[0]), data), _name(str(pair[1]), data)]
			return "Il rapporto %s diventa %s" % [
				who, str(payload.get("level", "")).to_lower(),
			]
		"ADD_SCAR":
			return "Cicatrice in %s: %s" % [
				_region(str(payload.get("region_id", "")), data),
				str(payload.get("description", "")),
			]
		"GRANT_ASSET":
			return "%s riceve %s" % [
				_name(target, data), _asset(str(payload.get("asset_id", "")), data),
			]
		"REMOVE_ASSET":
			return "%s perde %s" % [
				_name(target, data), _asset(str(payload.get("asset_id", "")), data),
			]
		"TRANSFER_ASSET":
			return "%s passa a %s" % [
				_asset(str(payload.get("asset_id", "")), data),
				_name(str(payload.get("to", target)), data),
			]
	return str(effect.get("type", ""))


## Every line of a list of Effects, with the silent ones dropped.
static func lines(effects: Array, data: RefCounted) -> Array:
	var out: Array = []
	for effect in effects:
		var line: String = say(effect as Dictionary, data)
		if line != "":
			out.append(line)
	return out


## Le caselle che un Effect scritto a mano lascia da riempire. Al momento di
## applicarlo sono gia' risolte; in **anteprima** — quando si guarda cosa farebbe
## una carta prima di calarla — non lo sono ancora, e stampare `$rival` e' il
## modo piu' rapido per far sembrare il gioco rotto.
const SLOTS: Dictionary = {
	"$proponent": "chi la cala",
	"$self": "chi la cala",
	"$rival": "un rivale",
	"$controller": "chi la tiene",
	"$region_focus": "la Regione della domanda",
	"$the_region": "la Regione della domanda",
	"$capital": "la capitale",
	"$rival_seat": "la terra di un rivale",
}


static func _slot(value: String) -> String:
	if SLOTS.has(value):
		return str(SLOTS[value])
	return "" if not value.begins_with("$") else value.substr(1).replace("_", " ")


static func _tension(tension_id: String, data: RefCounted) -> String:
	var tension: Variant = data.tensions.get(tension_id)
	if tension != null:
		return str(tension["title"])
	var slot: String = _slot(tension_id)
	return slot if slot != "" else tension_id


static func _region(region_id: String, data: RefCounted) -> String:
	var region: Variant = data.regions.get(region_id)
	if region != null:
		return str(region["name"])
	var slot: String = _slot(region_id)
	return slot if slot != "" else region_id


static func _name(entity_id: String, data: RefCounted) -> String:
	var entity: Variant = data.entities.get(entity_id)
	if entity != null:
		return str(entity["name"])
	var slot: String = _slot(entity_id)
	return slot if slot != "" else entity_id


static func _asset(asset_id: String, data: RefCounted) -> String:
	var asset: Variant = data.assets.get(asset_id)
	return asset_id if asset == null else str(asset["title"])
