extends RefCounted
## **Il tavolo di prova, e chi glielo mette in mano** (D-319).
##
## `CHR_TEST` e `CHR_TEST_HEIR` stanno sotto `tests/` e non finiscono nella
## scatola: sono il banco, non il gioco. Nascono quando gli anni d'autore sono
## stati cancellati (D-318) e la suite, che ci stava sopra, e' rimasta senza
## tavolo.
##
## Sta in un file suo perche' **due tipi di prova ne hanno bisogno**: quelle
## che usano `test_case.new_session()`, e quelle che si costruiscono un
## `DataSet` loro per misurare la scatola come e' spedita. Le seconde chiamano
## `add_to()` a mano.
##
## Cosa e' lecito che nomini: contenuto spedito — Regioni, case, Tensioni,
## template di Consiglio — perche' e' quello che le prove devono provare. Cosa
## non nomina piu': una Chronicle che qualcuno potrebbe voler togliere.

const PATH: String = "res://tests/fixtures/chronicle_test.json"


## Mette `CHR_TEST` e `CHR_TEST_HEIR` dentro un DataSet gia' caricato.
## Torna false se il banco non si apre: chi chiama lo dichiara come
## fallimento, cosi' una prova non gira mai su un tavolo che non c'e'.
static func add_to(into: RefCounted) -> bool:
	var file: FileAccess = FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return false
	var added: int = 0
	for item in ((parsed as Dictionary).get("items", []) as Array):
		var chronicle: Dictionary = item as Dictionary
		into.chronicles[str(chronicle["id"])] = chronicle
		added += 1
	return added > 0
