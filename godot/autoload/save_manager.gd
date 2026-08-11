extends Node
## Save, load, autosave and pre-Confluence snapshots (§22).

const SaveSerializer := preload("res://scripts/core/save_serializer.gd")

const SAVE_DIR: String = "user://saves"

signal saved(path: String)
signal loaded(path: String)


func save_path(name: String) -> String:
	return "%s/%s.json" % [SAVE_DIR, name]


func save_session(session: RefCounted, name: String, label: String = "") -> String:
	if session == null:
		push_error("SaveManager: no session to save")
		return ""
	var path: String = save_path(name)
	if not SaveSerializer.write(session.to_save(label), path):
		return ""
	saved.emit(path)
	return path


## Autosave after every Confluence (§22). Kept separate from manual saves so a
## player cannot lose a deliberate save to an automatic one.
func autosave(session: RefCounted) -> String:
	return save_session(session, "autosave", "autosave")


func load_into(session: RefCounted, name: String) -> bool:
	var save: Dictionary = SaveSerializer.read(save_path(name))
	if save.is_empty():
		return false
	if not session.restore(save):
		push_error("SaveManager: %s" % session.last_error)
		return false
	loaded.emit(save_path(name))
	return true


func list_saves() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return names
	for file_name in dir.get_files():
		if file_name.ends_with(".json"):
			names.append(file_name.trim_suffix(".json"))
	names.sort()
	return names
