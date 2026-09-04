extends SceneTree
## **La scheda di ogni tipo di carta, e il dato per generarle** (D-445).
##
##   godot --headless --path godot --script res://cli/run_card_sheets.gd -- \
##       --out=docs/SCHEDE_CARTE.md --json=docs/schede --bible=docs/ART_BIBLE.md
##
## Scrive il documento e un JSON per mazzo. Tutto quello che sa stare in
## `scripts/core/card_sheets.gd` sta li', cosi' una prova lo chiama senza
## passare da qui.

const DataSet := preload("res://scripts/core/data_set.gd")
const ArtBible := preload("res://scripts/core/art_bible.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const CardSheets := preload("res://scripts/core/card_sheets.gd")


func _initialize() -> void:
	var out_path: String = "docs/SCHEDE_CARTE.md"
	var json_dir: String = "docs/schede"
	var bible_path: String = "docs/ART_BIBLE.md"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)
		elif a.begins_with("--json="):
			json_dir = a.substr(7)
		elif a.begins_with("--bible="):
			bible_path = a.substr(8)

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for e in data.errors:
			printerr("  %s" % e)
		quit(3)
		return
	var bible: RefCounted = ArtBible.new()
	if not bible.read(bible_path):
		printerr("la ART_BIBLE non si legge: %s" % bible_path)
		quit(3)
		return

	# **Prima la guardia**: una scheda che tace una voce stampata, o ne promette
	# una che nessuna faccia stampa, non si scrive.
	var complaints: Array = CardSheets.complaints(data)
	if not complaints.is_empty():
		for line in complaints:
			printerr("  %s" % str(line))
		quit(5)
		return

	if DirAccess.make_dir_recursive_absolute(json_dir) != OK and not DirAccess.dir_exists_absolute(json_dir):
		printerr("non riesco a creare %s" % json_dir)
		quit(4)
		return
	var written: int = 0
	for deck in CardFace.printed():
		var path: String = "%s/%s.json" % [json_dir, str(deck)]
		var handle: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if handle == null:
			printerr("non riesco a scrivere %s" % path)
			quit(4)
			return
		handle.store_string(CardSheets.deck_json(str(deck), data, bible))
		handle.close()
		written += 1

	# Il documento cita la cartella dei JSON come si legge dal repository, non
	# col percorso temporaneo con cui il cancello lo confronta.
	var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		printerr("non riesco a scrivere %s" % out_path)
		quit(4)
		return
	file.store_string(CardSheets.document(data, bible, "schede"))
	file.close()
	print("SCHEDE -> %s, e %d JSON in %s" % [out_path, written, json_dir])
	quit(0)
