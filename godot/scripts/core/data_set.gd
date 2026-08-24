extends RefCounted
## Loads and validates every static data document under res://data (§5, §17).
##
## Deliberately free of autoload dependencies: the CLI harness and the test
## runner build their own DataSet, and the DataRegistry autoload wraps one.

const SchemaValidator := preload("res://scripts/core/schema_validator.gd")

var assets: Dictionary = {}
var regions: Dictionary = {}
var entities: Dictionary = {}
var tensions: Dictionary = {}
var actions: Dictionary = {}
var echo_cards: Dictionary = {}
var consequences: Dictionary = {}
var destinies: Dictionary = {}
var objectives: Dictionary = {}
var confluence_templates: Dictionary = {}
var chronicles: Dictionary = {}
var sim_plans: Dictionary = {}
var tag_rules: Dictionary = {}
var structure_types: Dictionary = {}
## I sei Temi fisici (D-256): la traccia di Calore che i giocatori guardano.
var themes: Dictionary = {}
## Il dizionario dei segni (PZ-0): per ogni tag il nome stampato, la categoria,
## l'ambito e chi lo tocca. La guardia sta in tools/validate_physical.py.
var tags: Dictionary = {}

var errors: PackedStringArray = PackedStringArray()
var data_version: String = ""
var loaded_documents: int = 0

const _TARGETS: Dictionary = {
	"asset": "assets",
	"region": "regions",
	"entity": "entities",
	"tension": "tensions",
	"echo_card": "echo_cards",
	"consequence": "consequences",
	"destiny": "destinies",
	"objective": "objectives",
	"confluence_template": "confluence_templates",
	"chronicle": "chronicles",
	"sim_plan": "sim_plans",
	"tag_rule": "tag_rules",
	"structure_type": "structure_types",
	"theme": "themes",
	"tag": "tags",
}


func load_from(root: String = "res://data") -> bool:
	errors = PackedStringArray()
	loaded_documents = 0
	var paths: PackedStringArray = _collect_json(root)
	if paths.is_empty():
		errors.append("no data documents found under %s" % root)
		return false
	# Sorted so boot validation reports the same order every run.
	var sorted: Array = Array(paths)
	sorted.sort()
	for path in sorted:
		_load_document(str(path))
	if errors.is_empty():
		_check_references()
	return errors.is_empty()


func _load_document(path: String) -> void:
	var text: String = FileAccess.get_file_as_string(path)
	if text == "":
		errors.append("%s: unreadable or empty" % path)
		return
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		errors.append("%s: not a JSON object" % path)
		return
	var document: Dictionary = parsed

	var document_errors: PackedStringArray = SchemaValidator.validate_document(document, path)
	if not document_errors.is_empty():
		errors.append_array(document_errors)
		return

	loaded_documents += 1
	var schema_id: String = str(document["schema_id"])
	if data_version == "":
		data_version = str(document.get("version", ""))

	if schema_id == "action":
		for item in document["items"]:
			actions[str(item["template"])] = item
		return
	if not _TARGETS.has(schema_id):
		errors.append("%s: no runtime store for schema_id '%s'" % [path, schema_id])
		return
	var store: Dictionary = get(_TARGETS[schema_id])
	for item in document["items"]:
		var id: String = str(item["id"])
		if store.has(id):
			errors.append("%s: duplicate id '%s'" % [path, id])
			continue
		store[id] = item


func _collect_json(root: String) -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	var dir := DirAccess.open(root)
	if dir == null:
		errors.append("cannot open data directory %s" % root)
		return found
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var path: String = root.path_join(name)
		if dir.current_is_dir():
			found.append_array(_collect_json(path))
		elif name.ends_with(".json"):
			found.append(path)
		name = dir.get_next()
	dir.list_dir_end()
	return found


## Cross-document integrity. tools/validate_data.py runs the exhaustive version;
## this catches the references the engine will actually dereference at runtime,
## so a bad data drop fails at boot instead of mid-Chronicle.
func _check_references() -> void:
	for entity in entities.values():
		for asset_id in entity["starting_assets"]:
			if not assets.has(asset_id):
				errors.append("%s: unknown starting asset '%s'" % [entity["id"], asset_id])
		for region_id in entity["presence"]:
			if not regions.has(region_id):
				errors.append("%s: unknown starting region '%s'" % [entity["id"], region_id])
		if not destinies.has(entity["destiny_id"]):
			errors.append("%s: unknown destiny '%s'" % [entity["id"], entity["destiny_id"]])
	for region in regions.values():
		for neighbour in region["adjacency"]:
			if not regions.has(neighbour):
				errors.append("%s: unknown adjacent region '%s'" % [region["id"], neighbour])
	for template in confluence_templates.values():
		if template.has("tension_id") and not tensions.has(template["tension_id"]):
			errors.append("%s: unknown tension '%s'" % [template["id"], template["tension_id"]])
		for proposition in template["propositions"]:
			for consequence_id in proposition["success_consequences"]:
				if not consequences.has(consequence_id):
					errors.append(
						"%s: unknown consequence '%s'" % [template["id"], consequence_id]
					)
		for pool_name in template["consequence_pools"]:
			for consequence_id in template["consequence_pools"][pool_name]:
				if not consequences.has(consequence_id):
					errors.append(
						"%s: unknown consequence '%s'" % [template["id"], consequence_id]
					)
	for chronicle in chronicles.values():
		for entity_id in chronicle["entities"]:
			if not entities.has(entity_id):
				errors.append("%s: unknown entity '%s'" % [chronicle["id"], entity_id])
		var declared: Array = chronicle.get("tensions", [])
		if not (chronicle.get("tension_pool", {}) as Dictionary).is_empty():
			declared = (chronicle["tension_pool"]["candidates"] as Array) + (
				chronicle["tension_pool"].get("always", []) as Array
			)
			for tension_id in chronicle.get("tensions", []):
				if not declared.has(str(tension_id)):
					declared.append(str(tension_id))
		if chronicle.has("sequel_id") and not chronicles.has(str(chronicle["sequel_id"])):
			errors.append("%s: unknown sequel '%s'" % [chronicle["id"], chronicle["sequel_id"]])
		for tension_id in declared:
			if not tensions.has(tension_id):
				errors.append("%s: unknown tension '%s'" % [chronicle["id"], tension_id])
	for template in ["ACQUIRE", "MOVE", "INFLUENCE", "FORGE", "SCHEME", "CLAIM"]:
		if not actions.has(template):
			errors.append("missing action template '%s'" % template)


# --- convenience lookups ---------------------------------------------------

## A Council bound to this exact Tension wins; otherwise one bound to its whole
## domain serves it. The second form is what makes a Council library content: the
## structure of a survival crisis is not specific to one famine, so a Chronicle
## that draws a new SURVIVAL Tension gets a Council without anyone writing one
## (D-028). Ids are sorted so the fallback is deterministic.
func confluence_template_for(tension_id: String) -> Dictionary:
	var tension: Variant = tensions.get(tension_id)
	for template in confluence_templates.values():
		if str(template.get("tension_id", "")) == tension_id:
			return template
	if tension == null:
		return {}
	var domain: String = str(tension["domain"])
	var ids: Array = confluence_templates.keys()
	ids.sort()
	for template_id in ids:
		var template: Dictionary = confluence_templates[template_id]
		if str(template.get("applies_to_domain", "")) == domain:
			return template
	return {}


## La Chronicle-biblioteca che prosegue questa eta' (D-095): quella che pesca
## le sue domande (`tension_pool`) e siede **lo stesso tavolo di Entita'**.
## E' il criterio con cui run_saga incatena le ere da sempre - CHR_01 prosegue
## in CHR_02, CHR_03 in CHR_04 - scritto una volta sola invece che in ogni
## chiamante. Una biblioteca prosegue se stessa; un'eta' senza biblioteca
## torna stringa vuota, e la saga li' finisce.
func library_sequel_of(chronicle_id: String) -> String:
	var current: Variant = chronicles.get(chronicle_id)
	if current == null:
		return ""
	# **Il seguito si dichiara.** Fino a 0.1.175 il criterio era «ha una
	# biblioteca», e finche' solo le Chronicle di seguito ne avevano una era
	# vero per caso. Dando la biblioteca anche all'anno d'apertura (D-207)
	# diventava falso nel modo peggiore: `library_sequel_of("CHR_01")` avrebbe
	# risposto `CHR_01`, e una saga avrebbe rigiocato la Carestia per dieci
	# secoli senza che niente segnalasse l'errore. Adesso il dato lo dice.
	if (current as Dictionary).has("sequel_id"):
		return str((current as Dictionary)["sequel_id"])
	if (current as Dictionary).has("tension_pool"):
		return chronicle_id
	var table: Array = ((current as Dictionary)["entities"] as Array).duplicate()
	table.sort()
	var ids: Array = chronicles.keys()
	ids.sort()
	for id in ids:
		var candidate: Dictionary = chronicles[str(id)]
		if not candidate.has("tension_pool"):
			continue
		var seats: Array = (candidate["entities"] as Array).duplicate()
		seats.sort()
		if seats == table:
			return str(id)
	return ""


func assets_of_family(family: String) -> Array:
	var out: Array = []
	for asset in assets.values():
		if str(asset["family"]) == family:
			out.append(asset)
	out.sort_custom(func(a, b): return str(a["id"]) < str(b["id"]))
	return out


func echo_cards_of_families(families: Array) -> Array:
	var out: Array = []
	for card in echo_cards.values():
		if families.has(str(card["dramatic_family"])):
			out.append(card)
	out.sort_custom(func(a, b): return str(a["id"]) < str(b["id"]))
	return out


func describe_errors() -> String:
	return "\n".join(Array(errors))
