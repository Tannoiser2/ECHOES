extends "res://tests/test_case.gd"
## La scheda di una domanda dice quello che il Consiglio offrira' (D-236).
##
## Il committente ha deciso che per adesso si gioca **all'app**. Da quel momento
## una cosa che al tavolo fisico prenderesti in mano — la scheda della Tensione,
## per sapere cosa ci sara' da proporre **prima** di decidere se scaldarla — o
## sta sullo schermo, o non esiste.
##
## Il cancello non gioca con le mani (§5ter), quindi nessuna misura copre questa
## pagina. Queste prove la coprono con la stessa regola di D-224, D-228 e D-232:
## **niente di quello che arriva a una persona parla in tecnico**, e la pagina
## arriva in fondo invece di fermarsi a meta'.

const CouncilSheet := preload("res://ui/council_sheet.gd")


func before_each() -> void:
	new_session()


## Costruisce la scheda e restituisce le righe che disegna. Il `free()` e' del
## chiamante — un pannello e' un Node, e un Node che nessuno libera resta.
func _page(tension_id: String, with_session: bool) -> Array:
	var sheet: PanelContainer = CouncilSheet.new()
	sheet._ready()
	sheet.show_tension(tension_id, session.data, session if with_session else null)
	var lines: Array = []
	_gather(sheet, lines)
	sheet.free()
	return lines


func _gather(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label:
			into.append(str((child as Label).text))
		_gather(child, into)


## Ogni domanda della scatola ha una scheda, e la scheda arriva in fondo.
##
## «In fondo» non e' un dettaglio: in GDScript una chiave che non c'e' non alza
## niente, **interrompe la funzione** e lascia una pagina mezza disegnata che
## sembra sana. Il bottone di chiusura e' l'ultima cosa che la scheda scrive: se
## c'e', la pagina e' arrivata alla fine.
func test_every_question_has_a_sheet_and_it_reaches_the_end() -> void:
	var checked: int = 0
	for tension_id in session.data.tensions:
		var lines: Array = _page(str(tension_id), true)
		assert_true(
			lines.size() >= 2, "la scheda di %s disegna qualcosa" % str(tension_id)
		)
		assert_eq(
			str(lines[0]), str(session.data.tensions[str(tension_id)]["title"]).to_upper(),
			"e si apre col nome della domanda"
		)
		checked += 1
	assert_true(checked >= 12, "per ogni domanda della scatola: %d" % checked)


## E nessuna riga parla al programmatore.
##
## Un `$rival` rimasto, un `SET_REGION_TAG` in maiuscolo o un `CNS_` sono tutti
## lo stesso difetto: la pagina ha smesso di parlare a chi gioca. Con la partita
## davanti i buchi si **riempiono**, quindi qui non ne deve restare nessuno.
func test_no_line_speaks_to_the_developer() -> void:
	var lines: int = 0
	for tension_id in session.data.tensions:
		for line in _page(str(tension_id), true):
			var text: String = str(line)
			lines += 1
			assert_false(text.contains("$"), "nessun buco rimasto: %s" % text)
			assert_false(text.contains("CNS_"), "nessun id di Conseguenza: %s" % text)
			assert_false(text.contains("TEN_"), "nessun id di domanda: %s" % text)
			assert_false(text.contains("REG_"), "nessun id di Regione: %s" % text)
			for word in ["SET_REGION_TAG", "SET_GLOBAL_TAG", "ADJUST_TENSION", "BUILD_STRUCTURE"]:
				assert_false(text.contains(word), "nessun tipo di Effetto: %s" % text)
	assert_true(lines > 100, "e vale su tutta la scatola: %d righe" % lines)


## Senza partita i buchi si **spiegano** invece di riempirsi.
##
## E' la stessa scelta di `CouncilText`, e vale la pena poterla vedere anche
## qui: una scheda si legge prima di cominciare, quando non c'e' ancora una
## Regione a cui riferirsi. Se un giorno la scheda senza partita smettesse di
## spiegare, mostrerebbe `$region_focus` a chi non ha una partita aperta.
func test_without_a_game_the_holes_are_explained() -> void:
	var spoken: int = 0
	for tension_id in session.data.tensions:
		for line in _page(str(tension_id), false):
			assert_false(str(line).contains("$"), "nemmeno senza partita: %s" % str(line))
			if str(line).contains("la Regione di cui si discute"):
				spoken += 1
	assert_true(spoken > 0, "e almeno una riga spiega il buco invece di riempirlo")


## Una proposta sulla scheda dice cosa lascia al mondo, come la dice al
## Consiglio (D-233) — e lo dice **una riga per Conseguenza, col suo nome**,
## perche' una proposta che ne porta due porta due esiti diversi e fonderli in
## una filza sola nascondeva proprio quella distinzione. Se qui tacesse, la scheda servirebbe a meno di niente:
## direbbe cosa si puo' proporre senza dire cosa costa.
func test_a_proposition_on_the_sheet_says_what_it_leaves() -> void:
	var leaves: int = 0
	var sheets: int = 0
	for tension_id in session.data.tensions:
		var found: bool = false
		for line in _page(str(tension_id), true):
			if str(line).begins_with("Se passa — ") or str(line) == "Non lascia segni sul mondo.":
				leaves += 1
				found = true
		if found:
			sheets += 1
	assert_true(sheets >= 8, "le schede che dicono cosa resta: %d" % sheets)
	assert_true(leaves >= 30, "e lo dicono per ogni proposta: %d righe" % leaves)
