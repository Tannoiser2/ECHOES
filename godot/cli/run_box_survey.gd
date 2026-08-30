extends SceneTree
## **Cosa una casella sa dire, e cosa il Consiglio fa lo stesso** (ISSUES 89).
##
##   godot --headless --path godot --script res://cli/run_box_survey.gd -- \
##       --out=docs/MISURA_CASELLE.md
##
## Il Consiglio cambia il mondo in **due modi che girano insieme**: le dodici
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
	lines.append("Letto da `CouncilEconomy` chiamandolo, non ricopiato.")
	lines.append("")
	lines.append("| casella | Effetti che produce |")
	lines.append("|---|---|")
	for verb in spoken:
		lines.append("| **%s** | %s |" % [
			str(verb), ", ".join(PackedStringArray(spoken[verb] as Array)),
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


## Cosa esce davvero da ogni casella, chiedendoglielo.
static func _what_the_boxes_emit() -> Dictionary:
	# **Il contesto finto deve avere tutto quello che una casella guarda.** La
	# prima versione non passava `tension`, e le due caselle che muovono una
	# domanda (D-343) uscivano vuote: il documento diceva che nessuna casella sa
	# muovere una domanda mentre due lo facevano. Uno zero e' quasi sempre la
	# sonda cieca, e qui lo era.
	var context: Dictionary = {
		"region_focus": "REG_PROVA", "proponent": "ENT_UNO", "rival": "ENT_DUE",
		"tension": "TEN_PROVA",
	}
	var world: Dictionary = {
		"regions": {"REG_PROVA": {"tags": ["condition:cut_off"]}},
		"tensions": {"TEN_PROVA": {"current_value": 3}},
	}
	var out: Dictionary = {}
	for pair in [[CouncilEconomy.BENEFIT_VERBS, "benefits"], [CouncilEconomy.COST_VERBS, "costs"]]:
		var table: Dictionary = pair[0]
		for verb in table:
			var voice: Dictionary = {
				"id": "V", "verb": str(verb), "text": "",
				"tag": "condition:rationed", "structure": "STR_GRANARY",
			}
			var types: Array = []
			for effect_v in CouncilEconomy.effects_for(
				voice, str(pair[1]), context, world, "THM_POTERE", {}
			):
				var kind: String = str((effect_v as Dictionary)["type"])
				if not types.has(kind):
					types.append(kind)
			if types.is_empty():
				# Una casella che con un contesto pieno non produce niente e'
				# una casella muta, o una sonda che non le ha dato quello che
				# guarda. In tutti e due i casi si dichiara, non si salta.
				printerr("la casella «%s» non produce alcun Effetto: sonda cieca o casella muta" % str(verb))
				continue
			out[str(verb)] = types
	return out


static func _verdict(effect: Dictionary, spoken: Dictionary) -> String:
	var kind: String = str(effect["type"])
	var where: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
	var known: bool = false
	for verb in spoken:
		if (spoken[verb] as Array).has(kind):
			known = true
			break
	if not known:
		return "3"
	return "0" if QUI.has(where) else "2"


static func _how(effect: Dictionary, data: RefCounted) -> String:
	return AssetText.effect_note(effect, data)
