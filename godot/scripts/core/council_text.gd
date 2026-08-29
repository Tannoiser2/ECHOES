extends RefCounted
## Un Consiglio, in parole che una persona legge (D-232).
##
## Le domande, le proposte, le clausole e le conseguenze vivono in
## `chronicle_*/confluences/*.json` e in `consequences/*.json`, scritte con dei
## **buchi**: `$proponent`, `$region_focus`, `$rival`. Al tavolo li riempie la
## partita — `ConfluenceController.say()` con le sue `text_bindings` — e va bene
## cosi': una proposta parla della Regione di **questo** Consiglio, non di una
## scritta a mano.
##
## Ma fuori dal tavolo quei buchi non si possono riempire, e non si devono:
## **si spiegano**. Su una scheda stampata «$rival» non e' un nome mancante, e'
## una regola — *«il tuo rivale in questa situazione»* — e chi legge la scheda
## prima della partita deve capirla senza avere una partita davanti.
##
## Questo e' l'unico posto dove un buco diventa una frase italiana, come
## `SignLabels` per i segni e `AssetText` per le carte. Il vincolo e' lo stesso e
## una prova lo tiene: **nessuna frase che arriva a una persona porta ancora un
## `$`**.

const AssetText := preload("res://scripts/core/asset_text.gd")

## Cosa vuol dire ogni buco, per chi legge fuori dalla partita.
const SLOTS: Dictionary = {
	"proponent": "chi propone",
	"rival_seat": "la casa rivale",
	"rival": "il rivale",
	"region_focus": "la Regione di cui si discute",
	"in_region": "nella Regione di cui si discute",
	"of_region": "della Regione di cui si discute",
	"the_region": "la Regione di cui si discute",
	"region_with": "una Regione che porta quel segno",
	"adjacent": "una Regione confinante",
	"capital": "la capitale",
	"controller": "chi tiene la Regione",
	"conditioner": "chi ha posto la condizione",
	"tension": "la domanda in discussione",
}


## Una frase d'autore con i buchi spiegati invece che riempiti.
##
## I buchi piu' lunghi per primi, sempre: `$region` e' un prefisso di
## `$region_focus`, e sostituirlo prima lascerebbe «_focus» in mezzo alla riga.
## E' la stessa cautela di `NarrativeText.fill`, per la stessa ragione.
static func speak(text: String) -> String:
	if not text.contains("$"):
		return text
	var keys: Array = SLOTS.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool:
		return str(a).length() > str(b).length()
	)
	var out: String = text
	for key in keys:
		out = out.replace("$%s" % str(key), str(SLOTS[key]))
	# Un buco a inizio frase si porta dietro il proprio articolo minuscolo: la
	# maiuscola appartiene alla frase, non al nome.
	if text.begins_with("$") and not out.is_empty():
		out = out.substr(0, 1).to_upper() + out.substr(1)
	return out


## La stessa frase, detta da chi la sta dicendo.
##
## Fuori dalla partita un buco **si spiega** (`speak`). Al tavolo invece la
## partita lo sa riempire, e sarebbe assurdo leggere «la Regione di cui si
## discute» quando quella Regione ha un nome e sta sullo schermo. Chi chiama
## passa la propria voce — `ConfluenceController.say` — e ottiene la stessa
## struttura con dentro i nomi veri.
##
## Le due letture restano **una sola sorgente**: la scheda stampata e la riga
## sullo schermo nascono dalla stessa funzione, quindi non possono dire due cose
## diverse della stessa proposta. E' lo stesso motivo per cui `consequence_note`
## chiede a `AssetText` invece di riscrivere gli Effetti.
static func _voice(text: String, voice: Callable) -> String:
	if voice.is_valid():
		return str(voice.call(text))
	return speak(text)


## Cosa lascia al mondo una Conseguenza, in una riga.
##
## Gli Effetti li racconta gia' `AssetText`, che e' il posto dove un Effetto
## diventa italiano (D-228): qui non si riscrive niente, si chiede a lui. Una
## Conseguenza che dice una cosa e ne fa un'altra non e' possibile, perche' la
## frase nasce dagli stessi campi che il motore applica.
static func consequence_note(
	consequence: Dictionary, data = null, voice: Callable = Callable()
) -> String:
	var said: Array = []
	for effect in consequence.get("effects", []):
		# Il buco puo' stare **dentro il segno**, non solo nella frase d'autore:
		# `settlement:$proponent` diventa «insediamento: $proponent» e il `$`
		# arriva fino alla scheda. Si spiega qui, dove si spiega tutto il resto.
		var line: String = _voice(AssetText.effect_note(effect as Dictionary, data), voice)
		if line != "" and not said.has(line):
			said.append(line)
	# **Una Cicatrice e' un segno in un posto, non una frase** (D-341). Stampava
	# la `description` — voce d'autore, 1.142 caratteri su quindici schede — e
	# taceva le due cose che al tavolo servono: quale segno si posa e dove. Sono
	# tutti e due campi, `tag` e `region_id`. La frase resta nel dato e si
	# corregge da `REVISIONE_TESTI`, che la porta gia' col suo id.
	var scar: Dictionary = consequence.get("scar", {}) as Dictionary
	if not scar.is_empty():
		said.append("e resta una Cicatrice: %s %s" % [
			AssetText.sign_word(str(scar.get("tag", "")), data),
			AssetText.place_word(str(scar.get("region_id", "")), data),
		])
	return " · ".join(PackedStringArray(said))


## Una proposta, come si legge su una scheda: la domanda a cui risponde, quello
## che chiede, e cosa lascia al mondo se passa.
static func proposition(
	template: Dictionary, proposition_id: String, data = null,
	voice: Callable = Callable()
) -> Dictionary:
	for entry in template.get("propositions", []):
		var found: Dictionary = entry as Dictionary
		if str(found["id"]) != proposition_id:
			continue
		var leaves: Array = []
		for consequence_id in found.get("success_consequences", []):
			var consequence: Variant = null if data == null else data.consequences.get(
				str(consequence_id)
			)
			if consequence == null:
				continue
			leaves.append({
				"title": str((consequence as Dictionary)["title"]),
				"leaves": consequence_note(consequence as Dictionary, data, voice),
			})
		return {
			"id": proposition_id,
			"question": _voice(_question_of(template, str(found.get("question_id", ""))), voice),
			"text": _voice(str(found["text"]), voice),
			"needs": _needs(found.get("eligibility", []), voice),
			"consequences": leaves,
		}
	return {}


## Le clausole che gli altri possono attaccare a una proposta.
static func clauses(
	template: Dictionary, data = null, voice: Callable = Callable()
) -> Array:
	var out: Array = []
	for entry in template.get("condition_clauses", []):
		var clause: Dictionary = entry as Dictionary
		out.append({
			"id": str(clause["id"]),
			"text": _voice(str(clause["text"]), voice),
			"leaves": consequence_note(clause, data, voice),
		})
	return out


## Quando una proposta si puo' fare, in parole. Le condizioni portano gia' la
## propria `label` d'autore: e' scritta per chi gioca, e qui si usa quella.
static func needs_of(eligibility: Array, voice: Callable = Callable()) -> Array:
	return _needs(eligibility, voice)


static func _needs(eligibility: Array, voice: Callable = Callable()) -> Array:
	var out: Array = []
	for condition in eligibility:
		var said: String = str((condition as Dictionary).get("label", ""))
		if said != "":
			out.append(_voice(said, voice))
	return out


static func _question_of(template: Dictionary, question_id: String) -> String:
	for question in template.get("questions", []):
		if str((question as Dictionary)["id"]) == question_id:
			return str((question as Dictionary)["text"])
	return ""
