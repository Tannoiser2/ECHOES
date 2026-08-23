extends "res://tests/test_case.gd"
## Ogni sonda di `godot/cli/` deve almeno **compilare**.
##
## Le sonde non stanno nel cancello — girano a mano, quando serve una misura —
## e per questo si rompono in silenzio. È successo davvero: un cambio di firma
## in `GameSession` (D-213) ha lasciato cinque sonde con un identificatore fuori
## posto, la suite è rimasta verde, la CI pure, e il difetto si è visto solo
## quando è servita quella misura. Una sonda che non parte non è uno strumento
## rotto: è **una misura che non si può più fare**, e il progetto sta in piedi
## sulle misure.
##
## Questa prova non le esegue — costerebbe minuti — ma le carica tutte: un
## errore di sintassi, una firma cambiata, un identificatore inventato non
## passano più.

func test_every_probe_still_compiles() -> void:
	var directory: DirAccess = DirAccess.open("res://cli")
	assert_true(directory != null, "la cartella delle sonde esiste")
	if directory == null:
		return
	var checked: int = 0
	for file_name in directory.get_files():
		var name: String = str(file_name)
		if not name.ends_with(".gd"):
			continue
		var script: Resource = load("res://cli/%s" % name)
		assert_true(script != null, "%s compila" % name)
		checked += 1
	assert_true(checked >= 20, "e le sonde caricate sono tutte: %d" % checked)
