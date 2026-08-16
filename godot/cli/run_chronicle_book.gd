extends SceneTree
## La cronaca dell'anno, da un salvataggio alle pagine (ISSUES voce 10).
##
##   godot --headless --path godot --script res://cli/run_chronicle_book.gd -- \
##       --save=../out/plan_a_grain_accord.save.json --out=../out/cronaca
##
## Legge un salvataggio (`session.to_save()`: i piani scriptati, l'hotseat, un
## anno qualsiasi) e scrive le pagine A4 della cronaca — le Verita' in ordine,
## atto per atto, e come e' finita per i seggi. Con `--pdf` in
## `tools/run_export.sh` non c'entra: queste pagine dipendono da una partita
## giocata, non dai dati, e si generano quando la partita c'e'.

const DataSet := preload("res://scripts/core/data_set.gd")
const ChronicleBook := preload("res://scripts/core/chronicle_book.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var save_path: String = str(options.get("save", ""))
	var out_dir: String = str(options.get("out", "out/cronaca"))
	if save_path == "":
		printerr("serve --save=<salvataggio.json>")
		quit(2)
		return

	var handle: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if handle == null:
		printerr("salvataggio non trovato: %s" % save_path)
		quit(2)
		return
	var save: Variant = JSON.parse_string(handle.get_as_text())
	handle.close()
	if typeof(save) != TYPE_DICTIONARY:
		printerr("salvataggio illeggibile: %s" % save_path)
		quit(2)
		return

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var pages: Array = ChronicleBook.pages(save, data)
	DirAccess.make_dir_recursive_absolute(out_dir)
	var year: int = int((save.get("world_state", {}) as Dictionary).get("year", 0))
	var written: Array = []
	for index in range(pages.size()):
		var path: String = "%s/cronaca_%d_%02d.svg" % [out_dir, year, index + 1]
		var out_handle: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		out_handle.store_string(str(pages[index]))
		out_handle.close()
		written.append(path)
	print("OK  %d pagine della cronaca dell'anno %d in %s" % [written.size(), year, out_dir])
	quit(0)


func _parse_args(args: Array) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if text.begins_with("--") and text.contains("="):
			var parts: PackedStringArray = text.substr(2).split("=", true, 1)
			out[str(parts[0])] = str(parts[1])
	return out
