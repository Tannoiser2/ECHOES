extends RefCounted
## Versioned save serialisation (§22).
##
## The save is the WorldState plus the seat assignments and, if a save is taken
## mid-Confluence, the open Confluence context. Keys are written sorted, and no
## wall-clock value ever enters the file: same seed + same plan must produce a
## byte-identical save (§18.3).

const SAVE_VERSION: String = "0.0.1"


static func to_save(session: RefCounted, label: String = "") -> Dictionary:
	var save: Dictionary = {
		"save_version": SAVE_VERSION,
		"data_version": str(session.data.data_version),
		"chronicle_id": str(session.world["chronicle_id"]),
		"world_state": (session.world as Dictionary).duplicate(true),
		"assignments": (session.assignments as Dictionary).duplicate(true),
		"pending_confluence": null,
		"destiny_results": (session.destiny_results as Dictionary).duplicate(true),
		# I Consigli gia' chiusi vivono nel ChronicleController, non nel mondo:
		# senza portarli nel salvataggio, una Chronicle ripresa li dimentica e il
		# rapporto di fine anno conta un Consiglio in meno (ISSUES 23 fase 2).
		"confluence_results": (session.chronicle.confluence_results as Array).duplicate(true),
	}
	if session.confluence != null and session.confluence.is_open():
		save["pending_confluence"] = (session.confluence.current as Dictionary).duplicate(true)
	if label != "":
		save["label"] = label
	return save


## Canonical text form. sort_keys keeps the byte output independent of the order
## in which the engine happened to build its dictionaries.
static func to_json(save: Dictionary, pretty: bool = true) -> String:
	return JSON.stringify(save, "  " if pretty else "", true, false)


## Il nome del salvataggio da portarsi via (voce 12, D-092). Stessa grammatica
## del log: lettere, numeri e trattini, cosi' passa per una cartella Download e
## per un allegato senza sorprese - e il seme nel nome dice quale mondo e'.
static func download_name(chronicle_id: String, seed_value: int) -> String:
	var slug: String = chronicle_id.to_lower().replace("_", "-")
	if slug == "":
		slug = "sessione"
	if seed_value < 0:
		return "echoes-salvataggio-%s.json" % slug
	return "echoes-salvataggio-%s-%d.json" % [slug, seed_value]


static func write(save: Dictionary, path: String) -> bool:
	var directory: String = path.get_base_dir()
	if directory != "" and not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveSerializer: cannot write '%s' (%d)" % [path, FileAccess.get_open_error()])
		return false
	file.store_string(to_json(save))
	file.close()
	return true


static func read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("SaveSerializer: no save at '%s'" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveSerializer: '%s' is not a save file" % path)
		return {}
	var save: Dictionary = parsed
	if str(save.get("save_version", "")) != SAVE_VERSION:
		push_warning(
			"SaveSerializer: save version '%s' differs from '%s'"
			% [save.get("save_version", "?"), SAVE_VERSION]
		)
	return _restore_ints(save)


## Godot's JSON parser hands back floats for whole numbers in some builds. The
## WorldState is integer-typed throughout, so normalise on the way in; without
## this a load/save round-trip would not be byte-identical.
static func _restore_ints(value: Variant) -> Variant:
	match typeof(value):
		TYPE_FLOAT:
			var number: float = value
			if is_equal_approx(number, roundf(number)) and absf(number) < 9.0e15:
				return int(number)
			return number
		TYPE_DICTIONARY:
			var out: Dictionary = {}
			for key in (value as Dictionary):
				out[key] = _restore_ints((value as Dictionary)[key])
			return out
		TYPE_ARRAY:
			var list: Array = []
			for item in (value as Array):
				list.append(_restore_ints(item))
			return list
	return value
