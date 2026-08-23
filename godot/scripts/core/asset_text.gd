extends RefCounted
## What a card does, in one line, said the same way everywhere.
##
## The authored `rules_text` is the card's voice - it explains and it flavours.
## This is the mechanical summary underneath it: what the modifier gives, what
## happens to the card afterwards, and what committing it costs the world. It is
## built from the fields the resolver actually reads, so a card cannot say one
## thing and do another (D-042).
##
## Shared because both front-ends need it and neither should own it: the
## terminal prints it beside a commit option, the browser puts it in the card's
## tooltip. Pure functions over an Asset dictionary - no world, no session.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

## **Cosa fa la carta se la cali.** Prima non lo diceva nessuno: la scheda
## portava famiglia, forza, modificatore, che fine fa la carta e cosa costa
## impegnarla — e mai il verbo. Si sceglieva una carta senza sapere cosa fa
## giocarla, che al tavolo e' la prima domanda e non l'ultima.
##
## Il verbo lo dice il dato (`card_action.kind`); qui c'e' solo la frase, e che
## ogni verbo scritto nei dati abbia la sua la tiene una prova.
const ACTIONS: Dictionary = {
	"MOVE": "MUOVERE — sposti una tua presenza su un'altra Regione",
	"INFLUENCE": "INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno",
	"SCHEME": "TRAMARE — leggi in privato qualcosa che e' coperto",
	"FORGE": "FORGIARE — muovi di un passo il rapporto con un'altra casa",
	"CLAIM": "RIVENDICARE — ti prendi il diritto di aprire il Consiglio",
	"ACQUIRE": "ACQUISIRE — peschi una carta della famiglia che scegli",
}

## Gli effetti che **non** nominano un segno: per questi basta il tipo.
##
## Prima erano quattro, e gli altri sette stampavano il proprio tipo in
## minuscolo: 28 effetti su 49. Sull'«Assedio» un giocatore leggeva davvero
## «costa: la domanda in gioco sale, raze_structure».
const COSTS: Dictionary = {
	"ADJUST_TENSION": "la domanda in gioco sale",
	"ADD_PRESENCE": "il tuo rivale entra dove si discute",
	"REMOVE_PRESENCE": "perdi la tua presenza dove si discute",
	"SET_TENSION_VISIBILITY": "la domanda si apre a tutti",
	"SET_RELATION": "il rapporto con chi tocca cambia di un passo",
	"BUILD_STRUCTURE": "si alza una costruzione dove si discute",
	"RAZE_STRUCTURE": "viene giu' una costruzione dove si discute",
	"REMOVE_ENTITY_TAG": "una casa perde un segno che portava addosso",
	# **Gli Effetti che solo le Conseguenze usano** (D-232). Nessuna carta li
	# porta, quindi non erano mai serviti — e quando il catalogo dei Consigli ha
	# cominciato a leggere le Conseguenze, cinque tipi su sedici sono usciti col
	# proprio nome in maiuscolo. Il vocabolario e' condiviso, e adesso e' intero.
	"SET_CONTROL": "la Regione discussa cambia padrone",
	"SET_STRUCTURE_GRADE": "una costruzione sale o scende di grado",
	"SET_ENTITY_ACTIVE": "una casa esce dal tavolo, o ci rientra",
	"CLOSE_PASSAGE": "una strada fra due Regioni si chiude",
}

## E i quattro che posano o tolgono un segno si dicono **col nome del segno
## dentro**: «la Regione discussa diventa affamata» dice una cosa, e
## `set_region_tag` non ne dice nessuna. La parola la da' `SignLabels`, che e'
## l'unico posto dove un tag diventa italiano — la stessa che sta sulla mappa e
## sul segnalino di cartone.
const SIGN_COSTS: Dictionary = {
	"SET_REGION_TAG": "la Regione discussa diventa %s",
	"REMOVE_REGION_TAG": "la Regione discussa non e' piu' %s",
	"SET_GLOBAL_TAG": "il mondo registra: %s",
	"REMOVE_GLOBAL_TAG": "il mondo dimentica: %s",
	# **Un segno addosso a una casa ha un nome, e il nome e' meta' della
	# regola.** Diceva «una casa porta addosso un segno nuovo», che e' vero e
	# inutile: su una scheda del Consiglio quella riga e' esattamente il pezzo
	# che fa decidere (D-236).
	"SET_ENTITY_TAG": "una casa porta addosso: %s",
}

const DISPOSITION: Dictionary = {
	"DISCARD": "si scarta se la impegni",
	"ALWAYS_DISCARD": "si scarta comunque",
	"RETAIN": "non si scarta mai",
	"RETAIN_ON_SUCCESS": "torna in mano se la proposta passa",
}


## The mechanical half, comma-separated: bonus, disposition, cost.
static func note(asset: Dictionary, data = null) -> String:
	var parts: Array = []
	var bonus: String = modifier_note(asset)
	if bonus != "":
		parts.append(bonus)
	parts.append(str(DISPOSITION.get(str(asset["discard_or_retain_rule"]), "")))
	var cost: String = cost_note(asset, data)
	if cost != "":
		parts.append("costa: %s" % cost)
	return " · ".join(PackedStringArray(parts))


static func modifier_note(asset: Dictionary) -> String:
	var modifier: Dictionary = asset.get("confluence_modifier", {"kind": "NONE", "value": 0})
	var value: int = int(modifier.get("value", 0))
	match str(modifier.get("kind", "NONE")):
		"FLAT_BONUS":
			return "+%d sempre" % value
		"RELEVANT_BONUS":
			return "+%d sul suo tema" % value
		"OPPOSE_BONUS":
			return "+%d se ti opponi" % value
	return ""


static func cost_note(asset: Dictionary, data = null) -> String:
	var said: Array = []
	for effect in asset.get("on_commit_effects", []):
		var text: String = effect_note(effect as Dictionary, data)
		if text != "" and not said.has(text):
			said.append(text)
	return ", ".join(PackedStringArray(said))


## Un effetto, in una frase da tavolo.
##
## Se non c'e' modo di dirlo la funzione **lo dichiara**, invece di stampare il
## tipo: un tipo in minuscolo sembra una regola e non lo e'. Cosi' un effetto
## nuovo senza parole si vede subito, e la prova lo prende.
static func effect_note(effect: Dictionary, data = null) -> String:
	var kind: String = str(effect.get("type", ""))
	if SIGN_COSTS.has(kind):
		var tag: String = str((effect.get("payload", {}) as Dictionary).get("tag", ""))
		var word: String = SignLabels.label(tag, data) if tag != "" else ""
		if word != "" and word != tag:
			return str(SIGN_COSTS[kind]) % word
		return "un segno cade sul mondo"
	if COSTS.has(kind):
		return str(COSTS[kind])
	return "un effetto senza parole (%s)" % kind


## Il verbo che la carta porta, per chi la deve calare.
static func action_note(asset: Dictionary) -> String:
	var kind: String = str((asset.get("card_action", {}) as Dictionary).get("kind", ""))
	if kind == "" or kind == "NONE":
		return ""
	return str(ACTIONS.get(kind, "un'azione senza parole (%s)" % kind))


## What this card adds to the Support front of a Council on this Tension - the
## resolver's own arithmetic, not a copy of it.
static func value_on(asset: Dictionary, relevant_families: Array) -> int:
	return ConfluenceResolution.asset_value(asset, relevant_families, "SUPPORT")


## Everything the card would say if it had room: what it is, what it does, and
## the sentence its author wrote.
static func tooltip(asset: Dictionary, data = null) -> String:
	var lines: Array = ["%s — %s, forza %d" % [
		str(asset["title"]), str(asset["family"]).to_lower(), int(asset["strength"]),
	]]
	# **Il verbo per primo.** E' la domanda che si fa chi ha la carta in mano:
	# non «quanto vale», ma «cosa succede se la calo».
	var verb: String = action_note(asset)
	if verb != "":
		lines.append(verb)
	lines.append(note(asset, data))
	var rules: String = str(asset.get("rules_text", ""))
	if rules != "":
		lines.append("")
		lines.append(rules)
	return "\n".join(PackedStringArray(lines))
