extends SceneTree
## **Cosa una casella sa dire, e cosa il Consiglio fa lo stesso** (ISSUES 89).
##
##   godot --headless --path godot --script res://cli/run_box_survey.gd -- \
##       --out=docs/MISURA_CASELLE.md
##
## Il Consiglio cambia il mondo in **due modi che girano insieme**: le
## caselle di D-280, che il tavolo posa con le pedine, e le Conseguenze
## d'autore che la proposta porta con se'. Da D-341 la scheda stampa **solo le
## caselle**, e questa sonda dice quanto grande e' la differenza.
##
## Il vocabolario delle caselle **non e' riscritto qui**: la sonda chiama
## `CouncilEconomy.effects_for` con un contesto finto e guarda **cosa esce**.
## Una tabella copiata accanto a una che esegue e' la trappola che questo
## progetto ha gia' pagato quattro volte (D-329, D-333, D-336, D-338).

const DataSet := preload("res://scripts/core/data_set.gd")
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")
const AssetText := preload("res://scripts/core/asset_text.gd")

## Il posto di cui si discute, in tutti i modi in cui i dati lo dicono.
const QUI: Array = ["$region_focus", "$focus_region", "$tension", "$world", "WORLD", ""]

## Come si chiamerebbe la casella che sa dire un Effetto che oggi nessuna dice.
## E' l'unica riga scritta a mano di questa sonda, ed e' un **nome**, non una
## regola: quello che il verbo fa lo dice il tipo di Effetto accanto.
const NEW_BOXES: Dictionary = {
	"ADJUST_TENSION": "SPOSTA UNA DOMANDA — chi propone nomina quale",
	"SET_ENTITY_TAG": "POSA UN SEGNO SU UNA CASATA",
	"REMOVE_ENTITY_TAG": "POSA UN SEGNO SU UNA CASATA",
	"SET_RELATION": "MUOVI UN RAPPORTO",
	"SET_STRUCTURE_GRADE": "UNA PIETRA SALE O SCENDE",
	"REMOVE_PRESENCE": "UNA PRESENZA ENTRA O SE NE VA",
	"ADD_PRESENCE": "UNA PRESENZA ENTRA O SE NE VA",
	"REMOVE_GLOBAL_TAG": "IL MONDO DIMENTICA",
	"SET_TENSION_VISIBILITY": "UNA DOMANDA VELATA SI SCOPRE",
	"SET_ENTITY_ACTIVE": "UNA CASATA LASCIA IL TAVOLO",
	"CLOSE_PASSAGE": "CHIUDI LA STRADA FRA DUE SEGNI",
}


func _initialize() -> void:
	var out_path: String = "docs/MISURA_CASELLE.md"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for e in data.errors:
			printerr("  %s" % e)
		quit(3)
		return

	var spoken: Dictionary = _what_the_boxes_emit()
	if spoken.is_empty():
		printerr("la sonda non ha visto uscire un solo Effetto dalle caselle: e' cieca lei")
		quit(4)
		return

	var seen: Dictionary = {}
	var uses: Dictionary = {}
	var order: Array = []
	# **Tutto quello che un Consiglio puo' applicare**, non solo le proposte che
	# passano: i tre pool (il prezzo, se cade, il di piu' di una vittoria netta)
	# e le clausole che gli avversari attaccano. Il primo giro ne guardava uno
	# solo su cinque, e un documento che ne conta un quinto e non fallisce e' la
	# forma di difetto che questo progetto ha gia' visto sei volte.
	for template_id in data.confluence_templates:
		var template: Dictionary = data.confluence_templates[str(template_id)]
		var reachable: Array = []
		for entry in template["propositions"]:
			reachable.append_array((entry as Dictionary).get("success_consequences", []))
		var pools: Dictionary = template.get("consequence_pools", {})
		for pool in pools:
			reachable.append_array(pools[str(pool)] as Array)
		for consequence_id in reachable:
			var consequence: Variant = data.consequences.get(str(consequence_id))
			if consequence == null:
				continue
			for effect_v in (consequence as Dictionary).get("effects", []):
				_count(effect_v as Dictionary, seen, uses, order)
		# Le clausole portano i loro Effetti addosso, non un id di Conseguenza.
		for clause_v in template.get("condition_clauses", []):
			for effect_v in (clause_v as Dictionary).get("effects", []):
				_count(effect_v as Dictionary, seen, uses, order)

	var groups: Dictionary = {"0": [], "2": [], "3": []}
	for key in order:
		groups[_verdict(seen[key] as Dictionary, spoken)].append(key)

	var lines: Array = []
	lines.append("# ECHOES — Le caselle e quello che il Consiglio fa lo stesso")
	lines.append("")
	lines.append("<!-- GENERATO da `tools/run_box_survey.sh` — non si corregge qui. -->")
	lines.append("")
	lines.append("Il Consiglio cambia il mondo in **due modi che girano insieme**: le")
	lines.append("caselle che il tavolo posa con le pedine, e le Conseguenze d'autore che")
	lines.append("la proposta porta con se'. Dalla 0.1.306 la scheda stampa **solo le")
	lines.append("caselle**: questa e' la misura di cosa resta fuori.")
	lines.append("")
	lines.append("## Il vocabolario che esegue")
	lines.append("")
	lines.append("Letto da `CouncilEconomy` chiamandolo, non ricopiato: ogni casella")
	lines.append("e' stata girata una volta per ogni posto che accetta, e la colonna")
	lines.append("«dove sa puntare» e' **cosa e' uscito puntato**, non un elenco a mano.")
	lines.append("")
	lines.append("| casella | in quale lista | Effetti che produce | dove sa puntare |")
	lines.append("|---|---|---|---|")
	for verb in spoken:
		var box: Dictionary = spoken[verb] as Dictionary
		var liste: Array = []
		if CouncilEconomy.BENEFIT_VERBS.has(str(verb)):
			liste.append("benefici")
		if CouncilEconomy.COST_VERBS.has(str(verb)):
			liste.append("costi")
		lines.append("| **%s** — %s | %s | %s | %s |" % [
			str(verb), str(CouncilEconomy.entry(str(verb)).get("label", "")),
			" e ".join(PackedStringArray(liste)),
			", ".join(PackedStringArray(box["types"] as Array)),
			"`%s`" % "`, `".join(PackedStringArray(box["places"] as Array)),
		])
	lines.append("")
	var total_d: int = order.size()
	var total_u: int = 0
	for key in uses:
		total_u += int(uses[key])
	lines.append("## Il conto")
	lines.append("")
	lines.append("| | distinti | applicazioni |")
	lines.append("|---|---|---|")
	for pair in [
		["0", "una casella di oggi lo sa dire"],
		["2", "verbo giusto, posto che la casella non sa dire"],
		["3", "verbo che manca"],
	]:
		var group: Array = groups[str(pair[0])]
		var count: int = 0
		for key in group:
			count += int(uses[key])
		lines.append("| **%s** | %d | %d |" % [str(pair[1]), group.size(), count])
	lines.append("| | **%d** | **%d** |" % [total_d, total_u])
	lines.append("")
	# **Quante caselle nuove servono**, che e' la domanda vera: non «quanto non
	# e' traducibile» — quella misura c'era e faceva sembrare un muro quello che
	# e' un elenco. Il raggruppamento e' derivato dal tipo di Effetto.
	lines.append("## Le caselle che mancano")
	lines.append("")
	lines.append("| casella da scrivere | Effetti | distinti | applicazioni |")
	lines.append("|---|---|---|---|")
	var by_verb: Dictionary = {}
	for key in groups["3"]:
		var kind: String = str((seen[key] as Dictionary)["type"])
		var box: String = str(NEW_BOXES.get(kind, "senza nome ancora"))
		var row: Array = by_verb.get(box, [[], 0, 0])
		if not (row[0] as Array).has(kind):
			(row[0] as Array).append(kind)
		row[1] = int(row[1]) + 1
		row[2] = int(row[2]) + int(uses[key])
		by_verb[box] = row
	var ranked: Array = by_verb.keys()
	ranked.sort_custom(func(a, b): return int((by_verb[a] as Array)[2]) > int((by_verb[b] as Array)[2]))
	for box in ranked:
		var row: Array = by_verb[str(box)]
		lines.append("| **%s** | `%s` | %d | %d |" % [
			str(box), "`, `".join(PackedStringArray(row[0] as Array)),
			int(row[1]), int(row[2]),
		])
	if ranked.is_empty():
		lines.append("| *nessuna* | | 0 | 0 |")
	lines.append("")

	for pair in [
		["3", "I verbi che mancano"],
		["2", "Il posto che la casella non sa dire"],
		["0", "Quello che una casella gia' dice"],
	]:
		lines.append("## %s" % str(pair[1]))
		lines.append("")
		lines.append("| Effetto | dove | usi | come si direbbe |")
		lines.append("|---|---|---|---|")
		if (groups[str(pair[0])] as Array).is_empty():
			lines.append("| *nessuno* | | | |")
		for key in groups[str(pair[0])]:
			var effect: Dictionary = seen[key]
			var where: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
			lines.append("| `%s` | %s | %d | %s |" % [
				str(effect["type"]), "*dove si discute*" if QUI.has(where) else "`%s`" % where,
				int(uses[key]), _how(effect, data),
			])
		lines.append("")

	var file := FileAccess.open(out_path, FileAccess.WRITE)
	file.store_string("\n".join(PackedStringArray(lines)).strip_edges() + "\n")
	file.close()
	print("MISURA CASELLE -> %s" % out_path)
	print("  %d Effetti distinti, %d applicazioni" % [total_d, total_u])
	print("  gia' detti: %d · posto sbagliato: %d · verbo che manca: %d" % [
		(groups["0"] as Array).size(), (groups["2"] as Array).size(),
		(groups["3"] as Array).size(),
	])
	quit(0)


static func _count(effect: Dictionary, seen: Dictionary, uses: Dictionary, order: Array) -> void:
	var key: String = "%s|%s" % [
		str(effect["type"]), str((effect.get("target", {}) as Dictionary).get("id", "")),
	]
	if not seen.has(key):
		seen[key] = effect
		order.append(key)
	uses[key] = int(uses.get(key, 0)) + 1


## **Cosa esce davvero da ogni casella, e dove sa puntare** — chiedendoglielo.
##
## Da D-366 una casella non ha piu' un solo bersaglio: `dove` e `chi` dicono su
## quale Regione, quale domanda e quale casa la pedina parla. La sonda gira ogni
## casella **una volta per ogni posto che accetta**, con un contesto fatto di
## nomi finti che si riconoscono — `$adjacent`, `$capital`, `TEN_PROVA` — e
## guarda **su cosa esce puntato**. Cosi' l'elenco dei posti non e' una tabella
## copiata accanto a una che esegue: e' la stessa che esegue.
static func _what_the_boxes_emit() -> Dictionary:
	# **Il contesto finto deve avere tutto quello che una casella guarda.** La
	# prima versione non passava `tension`, e le due caselle che muovono una
	# domanda (D-343) uscivano vuote: il documento diceva che nessuna casella sa
	# muovere una domanda mentre due lo facevano. Uno zero e' quasi sempre la
	# sonda cieca, e qui lo era.
	#
	# I valori sono i **nomi dei buchi**, non nomi veri: quello che esce e'
	# leggibile a occhio, ed e' lo stesso vocabolario con cui i dati scrivono i
	# loro bersagli. Un bersaglio che esce «$adjacent» e uno che nei dati e'
	# scritto «$adjacent» sono lo stesso posto, e il confronto e' esatto.
	var context: Dictionary = {
		"region_focus": "$region_focus", "proponent": "$proponent",
		"rival": "$rival", "tension": "$tension",
		"adjacent": "$adjacent", "capital": "$capital", "rival_seat": "$rival_seat",
	}
	# Un mondo dove ogni posto esiste: la Regione col segno, la casa col segno,
	# la domanda chiamata per nome, la Pietra da alzare, i fili fra le case. Una
	# casella che non trova il suo bersaglio non produce niente, e la sonda
	# leggerebbe zero senza che nessuna casella sia muta.
	# **Il segno che sceglie la Regione lo porta una sola tessera.** Se lo
	# portassero tutte, «una Regione col segno» tornerebbe la prima dell'ordine
	# — che e' quella di cui si discute — e la sonda direbbe che nessuna casella
	# sa puntare altrove mentre tutte lo sanno fare. E' la stessa trappola dello
	# zero cieco, con un valore diverso da zero.
	var region: Dictionary = {
		"tags": ["condition:cut_off"],
		"structures": [{"structure_type": "STR_GRANARY", "grade": 1, "owner": null}],
		"control": null,
	}
	var segnata: Dictionary = region.duplicate(true)
	(segnata["tags"] as Array).append("PROVA")
	var world: Dictionary = {
		"regions": {
			"$region_focus": region.duplicate(true),
			"$adjacent": region.duplicate(true),
			"$capital": region.duplicate(true),
			"$rival_seat": region.duplicate(true),
			"$region_with:PROVA": segnata,
		},
		"tensions": {
			"$tension": {"current_value": 3, "visibility": "VEILED"},
			"TEN_PROVA": {"current_value": 3, "visibility": "VEILED"},
		},
		"entities": {
			"$proponent": {"tags": [], "presence": [], "active": true},
			"$rival": {"tags": [], "presence": ["$region_focus"], "active": true},
			"$entity_with:PROVA": {"tags": ["PROVA"], "presence": [], "active": true},
		},
		"turn_order": ["$proponent", "$rival", "$entity_with:PROVA"],
		"relations": {
			"$proponent|$rival": {"level": "NEUTRAL", "tags": []},
			"$proponent|$entity_with:PROVA": {"level": "NEUTRAL", "tags": []},
		},
		"adjacency": {
			"$region_focus": ["$adjacent", "$capital", "$rival_seat", "$region_with:PROVA"],
			"$adjacent": ["$region_focus"],
			"$capital": ["$region_focus"],
			"$rival_seat": ["$region_focus"],
			"$region_with:PROVA": ["$region_focus"],
		},
		"global_tags": ["memory:prova"],
	}
	# **E un secondo tavolo, senza Pietre.** COSTRUISCI PIETRA fa due cose
	# diverse secondo cosa c'e' gia' (D-305): alza la Pietra che manca, oppure
	# passa di mano quella che c'e'. Girata su un tavolo solo, la sonda ne
	# vedeva una e dichiarava che nessuna casella sa alzare una Pietra — con
	# quattro Effetti veri messi fra «i verbi che mancano». Quello che una
	# casella sa fare e' l'unione di quello che fa sui tavoli possibili.
	var spoglio: Dictionary = world.duplicate(true)
	for region_id in (spoglio["regions"] as Dictionary):
		((spoglio["regions"] as Dictionary)[region_id] as Dictionary)["structures"] = []
	var out: Dictionary = {}
	for pair in [[CouncilEconomy.BENEFIT_VERBS, "benefits"], [CouncilEconomy.COST_VERBS, "costs"]]:
		var table: Dictionary = pair[0]
		for verb in table:
			var box: Dictionary = {"types": [], "places": []}
			for tavolo in [world, spoglio]:
				_turn_the_box(str(verb), str(pair[1]), context, tavolo as Dictionary, box)
			if (box["types"] as Array).is_empty():
				# Una casella che con un contesto pieno non produce niente e'
				# una casella muta, o una sonda che non le ha dato quello che
				# guarda. In tutti e due i casi si dichiara, non si salta.
				printerr("la casella «%s» non produce alcun Effetto: sonda cieca o casella muta" % str(verb))
				continue
			(box["places"] as Array).sort()
			out[str(verb)] = box
	return out


## Una casella girata su tutti i posti e tutte le case che accetta, su un tavolo
## dato. Quello che esce si somma a quello che era gia' uscito.
static func _turn_the_box(
	verb: String, kind: String, context: Dictionary, world: Dictionary, box: Dictionary
) -> void:
	for dove in CouncilEconomy.places_for(verb):
		for chi in CouncilEconomy.HOUSES:
			var voice: Dictionary = {
				"id": "V", "verb": verb, "text": "",
				"tag": "memory:prova", "structure": "STR_GRANARY",
				"level": "ALLY", "dove": str(dove), "chi": str(chi),
				"place_tag": "PROVA", "who_tag": "PROVA", "question": "TEN_PROVA",
				# L'altro capo della strada, che deve essere un posto diverso da
				# questo o la casella non taglia niente.
				"verso": "FOCUS" if str(dove) != "FOCUS" else "ADJACENT",
				"verso_tag": "PROVA",
			}
			for effect_v in CouncilEconomy.effects_for(
				voice, kind, context, world, "THM_POTERE", {}
			):
				var made: String = str((effect_v as Dictionary)["type"])
				if not (box["types"] as Array).has(made):
					(box["types"] as Array).append(made)
				var where: String = _family(str(
					((effect_v as Dictionary).get("target", {}) as Dictionary).get("id", "")
				))
				if not (box["places"] as Array).has(where):
					(box["places"] as Array).append(where)


## **Un posto, ridotto al suo genere.** «$region_with:granary» e
## «$region_with:trade» sono la stessa casella con un segno diverso stampato
## sopra, e vanno contati insieme; lo stesso per una domanda chiamata per nome.
## Tutti i modi in cui i dati dicono «qui» diventano `$region_focus`.
static func _family(id: String) -> String:
	if QUI.has(id):
		return "$region_focus"
	for prefix in ["$region_with:", "$entity_with:"]:
		if id.begins_with(prefix):
			return prefix
	if id.begins_with("TEN_"):
		return "TEN_"
	if id.contains("|"):
		return "|"
	return id


## I posti su cui **qualche** casella sa puntare questo genere di Effetto.
static func _places_of(kind: String, spoken: Dictionary) -> Array:
	var out: Array = []
	for verb in spoken:
		var box: Dictionary = spoken[verb] as Dictionary
		if not (box["types"] as Array).has(kind):
			continue
		for place in (box["places"] as Array):
			if not out.has(str(place)):
				out.append(str(place))
	return out


static func _verdict(effect: Dictionary, spoken: Dictionary) -> String:
	var kind: String = str(effect["type"])
	var where: String = _family(str((effect.get("target", {}) as Dictionary).get("id", "")))
	var places: Array = _places_of(kind, spoken)
	if places.is_empty():
		return "3"
	return "0" if places.has(where) else "2"


static func _how(effect: Dictionary, data: RefCounted) -> String:
	return AssetText.effect_note(effect, data)
