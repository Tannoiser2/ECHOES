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

## **Una frase che non dice dove non dice niente** (D-336).
##
## Fino alla 0.1.300 queste erano stringhe fisse, una per tipo di Effetto, e la
## frase prometteva sempre lo stesso posto: *«si alza una costruzione dove si
## discute»*, *«la domanda in gioco sale»*. Contro i dati, **89 righe stampate su
## 164 dicevano il falso**: la costruzione si alza in un'altra Regione, la
## domanda che sale e' un'altra, quella «in gioco» spesso scende. Il catalogo dei
## Consigli le stampava cosi', e il suo cancello non se ne accorgeva — controlla
## che il documento combaci col generatore, non che il generatore dica il vero.
##
## Adesso ogni frase si costruisce dall'Effetto intero: il verbo dal tipo, il
## posto dal bersaglio, il verso dal payload. Un bersaglio che non sappiamo dire
## **si dichiara**, come gia' faceva un tipo senza parole: un posto inventato
## sembra una regola e non lo e'.

## Dove cade un Effetto, detto come si dice al tavolo.
## **E «dove si discute» non vale su ogni carta** (D-344). E' la parola del
## Consiglio, giusta sulla scheda e sbagliata su una carta Eco, che un Consiglio
## non lo apre: dodici Effetti su centodieci puntano al luogo della carta, e su
## quelli si leggeva una regola che parlava di un tavolo che non c'e'. Chi
## disegna la faccia dice come si chiama quel posto; il ripiego resta il
## Consiglio, che e' il caso piu' frequente.
static func _place(id: String, data = null, here: String = "dove si discute") -> String:
	match id:
		"$region_focus", "$focus_region":
			return here
		"$adjacent":
			return "in una Regione confinante"
		"$rival_seat":
			return "nella sede del rivale"
		"$capital":
			return "nella capitale"
	if id.begins_with("$region_with:"):
		return "in una Regione con %s" % _sign(id.substr(13), data)
	return "in un posto che la carta non sa dire (%s)" % id


## A chi tocca.
static func _house(id: String, data = null) -> String:
	match id:
		"$proponent":
			return "chi propone"
		"$rival":
			return "il rivale"
		"$actor":
			return "chi gioca"
		"$controller":
			return "chi tiene la Regione"
		"$conditioner":
			return "chi ha posto la condizione"
	if id.begins_with("$entity_with:"):
		return "la casa che porta %s" % _sign(id.substr(13), data)
	return "una casa che la carta non sa dire (%s)" % id


## Quale domanda: quella aperta, o un'altra chiamata per nome.
static func _question(id: String, data = null) -> String:
	if id == "$tension":
		return "la domanda in gioco"
	if data != null:
		var card: Variant = (data.tensions as Dictionary).get(id)
		if card != null:
			return str((card as Dictionary).get("title", id))
	return id


## La parola stampata di un segno; se non ne ha una, il segno nudo.
##
## **Col cancelletto davanti quando e' una parola sola** (D-344). Il committente:
## *«ogni azione, effetto e #tag deve essere visibile sulla carta»* — e al tavolo
## il cancelletto e' il modo in cui si distingue **una cosa che si posa** da una
## parola qualunque: `#granaio`, `#razionato`, `#conteso`.
##
## Non tutti i segni hanno un nome da segnalino, pero'. Il dizionario stampa
## `domain:SURVIVAL` come *«dominio: la sopravvivenza»* e le memorie come frasi
## intere — *«il grano e' stato requisito»* — e un cancelletto davanti a una
## frase non e' un segnalino, e' un errore di stampa. La regola guarda **il nome
## stampato dal dizionario**, non una tabella accanto: una parola sola prende il
## cancelletto, una frase resta una frase.
static func _sign(tag: String, data = null) -> String:
	if tag == "":
		return tag
	var word: String = SignLabels.label(tag, data)
	if word == "":
		return tag
	# **Il cancelletto solo su una parola sola.** Un nome stampato di piu' parole
	# — «tagliato fuori», «dominio: la sopravvivenza», «il grano e' stato
	# requisito» — non e' un segnalino: e' una frase, e cucirla con dei trattini
	# bassi per farci stare un cancelletto la fa tornare a somigliare a un id,
	# che e' esattamente quello che D-339 ha tolto dalle carte. La prova che
	# nessuna frase porti un nome interno lo ha preso al primo giro.
	if word.contains(" ") or _category_of(tag, data) == "MEMORY":
		return word
	return "#%s" % word


## La categoria di un segno, dal dizionario. Vuota se il segno non c'e' o se il
## set dei dati non e' a portata.
static func _category_of(tag: String, data = null) -> String:
	if data == null:
		return ""
	var card: Variant = (data.tags as Dictionary).get(tag)
	return "" if card == null else str((card as Dictionary).get("category", ""))


## Di quanto, e da che parte.
static func _steps(n: int) -> String:
	return "di %d" % n if n > 1 else ""

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
static func effect_note(effect: Dictionary, data = null, focus: String = "dove si discute") -> String:
	var kind: String = str(effect.get("type", ""))
	var target: Dictionary = effect.get("target", {}) as Dictionary
	var payload: Dictionary = effect.get("payload", {}) as Dictionary
	var id: String = str(target.get("id", ""))
	var tag: String = str(payload.get("tag", ""))
	# Una Presenza ha come bersaglio la **casa**: il posto sta nel payload.
	var here: String = _place(str(payload.get("region_id", id)), data, focus)
	var there: String = _place(id, data, focus)

	match kind:
		"SET_REGION_TAG":
			return "%s diventa %s" % [there, _sign(tag, data)]
		"REMOVE_REGION_TAG":
			return "%s non e' piu' %s" % [there, _sign(tag, data)]
		"SET_GLOBAL_TAG":
			return "il mondo registra: %s" % _sign(tag, data)
		"REMOVE_GLOBAL_TAG":
			return "il mondo dimentica: %s" % _sign(tag, data)
		"SET_ENTITY_TAG":
			return "%s porta addosso: %s" % [_house(id, data), _sign(tag, data)]
		"REMOVE_ENTITY_TAG":
			return "%s perde: %s" % [_house(id, data), _sign(tag, data)]
		"ADJUST_TENSION":
			var delta: int = int(payload.get("delta", 0))
			var verso: String = "sale" if delta > 0 else "scende"
			return " ".join(PackedStringArray(
				[_question(id, data), verso, _steps(abs(delta))]
			)).strip_edges()
		"BUILD_STRUCTURE":
			return "si alza %s %s" % [_stone(str(payload.get("structure_type", "")), data), there]
		"RAZE_STRUCTURE":
			return "viene giu' %s %s" % [_stone(str(payload.get("structure_type", "")), data), there]
		"SET_STRUCTURE_GRADE":
			return "%s %s va al grado %d" % [
				_stone(str(payload.get("structure_type", "")), data), there,
				int(payload.get("grade", 1)),
			]
		"SET_STRUCTURE_OWNER":
			return "una costruzione %s passa di mano" % there
		"SET_CONTROL":
			return "%s cambia padrone" % there
		"ADD_PRESENCE":
			return "%s entra %s" % [_house(id, data), here]
		"REMOVE_PRESENCE":
			return "%s se ne va %s" % [_house(id, data), here]
		"CLOSE_PASSAGE":
			return "si chiude la strada %s" % here
		"SET_RELATION":
			return "il rapporto fra %s cambia" % _pair(id, data)
		"SET_TENSION_VISIBILITY":
			return "%s si apre a tutti" % _question(id, data)
		"SET_ENTITY_ACTIVE":
			return "%s esce dal tavolo, o ci rientra" % _house(id, data)
	return "un effetto senza parole (%s)" % kind


## Le due case di un rapporto, che nel bersaglio stanno separate da una barra.
static func _pair(id: String, data = null) -> String:
	var parts: PackedStringArray = id.split("|")
	if parts.size() != 2:
		return "due case che la carta non sa dire (%s)" % id
	return "%s e %s" % [_house(str(parts[0]), data), _house(str(parts[1]), data)]


## Il nome stampato di una Pietra.
static func _stone(id: String, data = null) -> String:
	if id != "" and data != null:
		var stone: Variant = (data.structure_types as Dictionary).get(id)
		if stone != null:
			return str((stone as Dictionary).get("name", "una costruzione"))
	return "una costruzione"



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


## ---------------------------------------------------------------------------
## La faccia fisica, riga per riga (D-340).
##
## Fino alla 0.1.304 la carta Asset stampava `rules_text` — il racconto — e
## taceva **tutto** il blocco `physical`: bersaglio a segni, due Azioni,
## Risonanza, uso in Consiglio. Quarantotto carte su quarantotto, cioe' la
## faccia che si gioca al tavolo non era stampata da nessuna parte.
##
## Il committente, guardandola: *«devi eliminare ogni narrativa prolissa e far
## capire esattamente al giocatore che quel beneficio e' un #tag che si mette in
## un posto preciso, o una azione che si fa»*.
##
## Tre di queste cinque righe **non si scrivono a mano**: Risonanza e uso in
## Consiglio sono interamente campi strutturati, e generarle e' l'unico modo
## perche' la carta non possa dire una cosa e il motore farne un'altra (D-042).
## Le altre due — il bersaglio e le due Azioni — hanno un testo d'autore, ed e'
## quello che va scritto in imperativo, come lo schema gia' chiede.

## Il nome stampato di un segno, per chi disegna una faccia. Pubblico perche' la
## scheda del Consiglio deve dire una Cicatrice **col suo segno e il suo posto**
## e non con la frase d'autore che le sta accanto (D-341).
static func sign_word(tag: String, data = null) -> String:
	return _sign(tag, data)


## Il posto, per chi disegna una faccia.
static func place_word(id: String, data = null, focus: String = "dove si discute") -> String:
	return _place(id, data, focus)


## Un segno come si legge sulla carta: col cancelletto davanti, che al tavolo e'
## il modo in cui si distingue «una cosa che si posa» da una parola qualunque.
## **Il cancelletto lo decide `_sign`, e nessun altro.**
##
## Questa funzione lo rimetteva a forza — `word if word.begins_with("#") else
## "#%s"` — e cosi' disfaceva, sull'unica riga che la chiama, la regola che
## D-344 aveva scritto due righe piu' su: il cancelletto **solo su una parola
## sola**. Risultato, **33 facce su 266**: `#il tradimento e' stato detto ad
## alta voce`, `#il grano e' stato requisito`, `#l'erede nominato`. Una regola
## che vale in un posto e non nell'altro non e' una regola.
static func _hash(tag: String, data = null) -> String:
	return _sign(tag, data)


## Il nome stampato di un Tema.
static func _theme(id: String, data = null) -> String:
	if data != null:
		var theme: Variant = (data.themes as Dictionary).get(id)
		if theme != null:
			return str((theme as Dictionary).get("title", id))
	return id


## **DOVE si gioca.** La riga e' d'autore perche' porta condizioni che i campi
## non reggono ancora («dove hai gia' una presenza»): quelle stanno solo qui, ed
## e' una voce aperta, non una scelta.
static func target_line(physical: Dictionary) -> String:
	var target: Dictionary = physical.get("target", {})
	var text: String = str(target.get("text", ""))
	return "DOVE  %s" % text if text != "" else ""


## **Le due Azioni**, numerate: al tavolo si sceglie per numero, non per nome.
static func action_lines(physical: Dictionary) -> Array:
	const NUMBERS: Array = ["①", "②"]
	var lines: Array = []
	var actions: Array = physical.get("actions", [])
	for i in actions.size():
		var action: Dictionary = actions[i]
		var number: String = str(NUMBERS[i]) if i < NUMBERS.size() else "%d" % (i + 1)
		lines.append("%s %s — %s" % [number, str(action["label"]), str(action["text"])])
	return lines


## **La Risonanza, generata.** Avviene sempre e non si sceglie: scalda un Tema, e
## se il bersaglio porta un certo segno scalda di piu' e lascia qualcosa.
## Tutto questo sta in `theme`/`heat`/`if_target_tag`/`extra_heat`/`extra_tag`:
## il campo `text` accanto e' voce d'autore e sulla carta non ci va.
static func resonance_line(physical: Dictionary, data = null) -> String:
	var resonance: Dictionary = physical.get("resonance", {})
	if resonance.is_empty():
		return ""
	var parts: Array = ["%s +%d" % [
		_theme(str(resonance.get("theme", "")), data), int(resonance.get("heat", 0)),
	]]
	var condition: String = str(resonance.get("if_target_tag", ""))
	if condition != "":
		var extra: Array = []
		var extra_heat: int = int(resonance.get("extra_heat", 0))
		if extra_heat > 0:
			extra.append("+%d ancora" % extra_heat)
		var extra_tag: String = str(resonance.get("extra_tag", ""))
		if extra_tag != "":
			extra.append("posa %s" % _hash(extra_tag, data))
		if not extra.is_empty():
			parts.append("se il bersaglio ha %s: %s" % [
				_hash(condition, data), " e ".join(PackedStringArray(extra)),
			])
	return "SEMPRE  %s" % " · ".join(PackedStringArray(parts))


## **Quanto vale impegnata**, generato: forza base e il Tema che la fa valere di
## piu'.
static func council_line(physical: Dictionary, data = null) -> String:
	var use: Dictionary = physical.get("council_use", {})
	if use.is_empty():
		return ""
	var line: String = "AL CONSIGLIO  %d" % int(use.get("base_strength", 0))
	var themes: Array = use.get("bonus_if_theme", [])
	if not themes.is_empty():
		var named: Array = []
		for id in themes:
			named.append(_theme(str(id), data))
		line += " · +1 se si discute di %s" % " o ".join(PackedStringArray(named))
	return line


## Le cinque righe della faccia fisica, nell'ordine in cui si leggono.
static func physical_lines(asset: Dictionary, data = null) -> Array:
	var physical: Dictionary = asset.get("physical", {})
	if physical.is_empty():
		return []
	var lines: Array = [target_line(physical)]
	lines.append_array(action_lines(physical))
	lines.append(resonance_line(physical, data))
	lines.append(council_line(physical, data))
	var said: Array = []
	for line in lines:
		if str(line) != "":
			said.append(str(line))
	return said
