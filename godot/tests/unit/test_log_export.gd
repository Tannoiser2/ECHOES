extends "res://tests/test_case.gd"
## Portarsi via la cronaca (D-062).
##
## Il log era leggibile e non prendibile: su un tablet una partita finita si puo'
## solo fotografare. Quello che questi test tengono fermo e' che il file che esce
## sia **ritrovabile e rigiocabile** - un nome che sopravvive a una cartella
## Download e un'intestazione che porta il seme con se'.

const LogExport := preload("res://scripts/core/log_export.gd")


func test_the_name_survives_a_filesystem() -> void:
	assert_eq(
		LogExport.file_name("CHR_03", 12345), "echoes-chr-03-12345.txt",
		"minuscolo, trattini, e il seme dentro"
	)
	assert_false(LogExport.file_name("CHR_03", 12345).contains(" "), "niente spazi")


## Prima di sedersi non c'e' ne' una Chronicle ne' un seme, e il tasto c'e' lo
## stesso: il menu e' gia' log, e chi lo vuole se lo porta via.
func test_a_session_without_a_chronicle_still_has_a_name() -> void:
	assert_eq(LogExport.file_name("", -1), "echoes-sessione.txt", "un nome c'e sempre")


## Il seme e' la parte che rende il file una prova invece che un racconto.
func test_the_header_carries_the_seed() -> void:
	var head: String = LogExport.header("Le Citta Libere", 1640, 4242, "2026-08-14 10:00:00")
	assert_true(head.contains("seme 4242"), "il seme c'e")
	assert_true(head.contains("Le Citta Libere, anno 1640"), "e si sa che partita era")
	for line in head.strip_edges().split("\n"):
		assert_true(str(line).begins_with("#"), "ogni riga di intestazione e commentata")


## Senza partita l'intestazione non inventa niente: nessun anno zero, nessun seme
## -1 scritto come se fosse un numero vero.
func test_the_header_says_nothing_it_does_not_know() -> void:
	var head: String = LogExport.header("", 0, -1, "")
	assert_false(head.contains("seme"), "nessun seme finto")
	assert_false(head.contains("anno"), "nessun anno finto")
	assert_true(head.begins_with("# ECHOES"), "ma il file si riconosce lo stesso")


## Fuori dal browser il file si scrive, e chi ha premuto deve sapere dove: una
## cosa che accade in silenzio non e' distinguibile da una che non accade.
func test_outside_the_browser_the_file_is_written_and_named() -> void:
	var name: String = "echoes-prova-di-test.txt"
	var said: String = LogExport.deliver("== PROVA ==\n  - una riga\n", name)
	assert_false(said == "", "qualcosa viene detto a chi ha premuto")
	if OS.has_feature("web"):
		return
	assert_true(said.contains(name), "e quello che viene detto contiene il nome del file")
	var written: String = FileAccess.get_file_as_string("user://%s" % name)
	assert_true(written.contains("una riga"), "il contenuto e quello del log")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://%s" % name))


## Un log vuoto non e' un errore: e' una sessione appena cominciata, e non deve
## scaricare un file di zero byte che sembra un guasto.
func test_an_empty_log_downloads_nothing() -> void:
	assert_eq(LogExport.deliver("   \n  ", "echoes-vuoto.txt"), "", "niente file, niente riga")
	assert_false(
		FileAccess.file_exists("user://echoes-vuoto.txt"), "e niente scritto sul disco"
	)
