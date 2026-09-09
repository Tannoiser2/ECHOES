extends "res://tests/test_case.gd"
## **Il tabellone del Consiglio mostra la carta girata** (D-291, taglio 1),
## a due domande (D-467, D-471, D-472).
##
## Parola del committente davanti all'app: *«il Concilio e' ancora quello
## vecchio, mi sa che va cambiato tutto»*. Aveva ragione su quello che vedeva:
## lo schermo disegnava la meta' vecchia e taceva l'economia che il motore
## eseguiva. Un'economia che gira e non si vede non e' un'economia: e' un
## conto che fa qualcun altro.
##
## Da D-472 l'economia e' quella delle **due parti**: le due liste della carta
## con la marca della domanda davanti a ogni casella, la pedina del colore
## della parte che l'ha posata, cosa resta se vince l'una o l'altra, cosa
## succede se cade, e il conto in parole contro il mucchio — senza dado.
## `test_the_council_of_two_questions` guarda lo stesso tabellone sul tavolo
## spedito, con le lettere e le posizioni; qui si fabbrica tutto su
## `TEN_FAMINE`, casella per casella.

const ConfluenceBoard := preload("res://ui/confluence_board.gd")

const TENSION: String = "TEN_FAMINE"


func before_each() -> void:
	new_session()


func _voices(list_name: String) -> Array:
	var out: Array = []
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
		out.append(str((voice as Dictionary)["id"]))
	return out


func _text_of(list_name: String, voice_id: String) -> String:
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			return str((voice as Dictionary)["text"])
	return ""


## Il Consiglio aperto col mucchio a 3 — fissato **prima** di aprire, perche'
## il mucchio si legge all'apertura (D-470) — e ogni casella della carta viva.
func _open() -> void:
	var theme_id: String = str(data().tensions[TENSION].get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = 3
	session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	_make_every_casella_live()


## **Il tavolo in cui ogni casella della carta puo' fare qualcosa** (D-306).
## Da D-306 una casella che qui non farebbe niente non si posa; una prova che
## guarda il **tabellone** vuole la carta intera, quindi se la fabbrica.
func _make_every_casella_live() -> void:
	var context: Dictionary = session.confluence.effect_context()
	var region_id: String = str(context.get("region_focus", ""))
	assert_ne(region_id, "", "il Consiglio discute di un luogo")
	var region: Dictionary = session.world["regions"][region_id]
	var tags: Array = region["tags"] as Array
	for tag in ["condition:starving", "condition:cut_off"]:
		if not tags.has(tag):
			tags.append(tag)
	for tag in ["condition:rationed", "structure:tollgate", "condition:indebted"]:
		tags.erase(tag)
	var proponent: String = str(context.get("proponent", ""))
	var rival: String = str(context.get("rival", ""))
	for entity_id in session.world["entities"]:
		if str(entity_id) != proponent and str(entity_id) != rival:
			region["control"] = str(entity_id)
			break


## Un seggio che non propone.
func _other() -> String:
	for entity_id in session.confluence.stance_order():
		return str(entity_id)
	return ""


func _board() -> Node:
	var board: Node = ConfluenceBoard.new()
	board.render(session, str(session.world["turn_order"][0]))
	return board


func _drawn() -> Array:
	var board: Node = _board()
	var said: Array = []
	_labels_of(board, said)
	board.free()
	return said


func _labels_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label and (child as Label).visible:
			into.append(str((child as Label).text))
		_labels_of(child, into)


## Le righe della carta sul tabellone: `{text, marked, colour}` per ognuna.
## La pedina e' un nodo disegnato, non un segno nel testo (D-466), e la riga
## lo dice con `marked`; il colore e' quello dell'etichetta accanto.
func _rows() -> Array:
	var board: Node = _board()
	var out: Array = []
	for row in board._face.get_children():
		if not (row as Node).has_meta("marked"):
			continue
		var label: Label = null
		for child in (row as Node).get_children():
			if child is Label:
				label = child as Label
		out.append({
			"text": "" if label == null else str(label.text),
			"marked": bool((row as Node).get_meta("marked")),
			"colour": Color("#000000") if label == null else label.get_theme_color("font_color"),
		})
	board.free()
	return out


func _row_of(list_name: String, voice_id: String) -> Dictionary:
	var text: String = _text_of(list_name, voice_id)
	for row in _rows():
		if str((row as Dictionary)["text"]).contains(text):
			return row as Dictionary
	return {}


## Le due liste della carta stanno sul tabellone, tutte e due intere e coi
## titoli del cartone, e **a quale domanda serve una casella si legge** — che e'
## la cosa che conta (D-469).
##
## **Ma non piu' da una sigla su ogni riga** (D-497, ISSUES 137, parola del
## committente: *«non si sa chi sta facendo cosa e le voci sono tutte
## mescolate»*). La sigla «A», «B», «BA» davanti al testo era meta' del
## disordine: la ripeteva ogni riga e non la spiegava nessuna. Adesso le voci
## stanno in **gruppi** dentro le due liste — per la domanda A, per la B, per
## tutte e due — e la prova prende **il gruppo**, che e' dove la stessa
## informazione e' andata a stare.
func test_the_board_draws_both_lists() -> void:
	_open()
	var column: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(column.contains("BENEFICI"), "la lista dei benefici c'e': %s" % column)
	assert_true(column.contains("COSTI"), "e quella dei costi")
	assert_false(column.contains("COSA SI COMPRA") or column.contains("IL PREZZO"), "coi titoli di D-280 usciti")
	# **E si dice chi sceglie in ognuna** (D-280): il proponente compra i
	# benefici, gli avversari scelgono i costi, e non stava scritto da nessuna
	# parte.
	assert_true(column.contains("li compra chi propone"), "chi compra i benefici: %s" % column)
	assert_true(column.contains("li scelgono gli avversari"), "e chi sceglie i costi")
	var a_question: String = session.confluence.side_question("A")
	var b_question: String = session.confluence.side_question("B")
	assert_ne(a_question, b_question, "le due parti hanno due domande")
	# Ogni casella si legge, e sta sotto il gruppo della domanda che serve: si
	# scorrono le righe in ordine e il gruppo aperto e' quello che vale.
	var rows: Array = _drawn()
	var groups: Dictionary = {}
	var open_group: String = ""
	for row in rows:
		var line: String = str(row)
		if line.contains("per la domanda A"):
			open_group = "A"
		elif line.contains("per la domanda B"):
			open_group = "B"
		elif line.contains("per tutte e due"):
			open_group = "AB"
		elif line.contains("BENEFICI") or line.contains("COSTI"):
			open_group = ""
		elif open_group != "":
			groups[line] = open_group
	var checked: int = 0
	for list_name in ["benefits", "costs"]:
		for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
			var voice_id: String = str((voice as Dictionary)["id"])
			var row: Dictionary = _row_of(list_name, voice_id)
			assert_false(row.is_empty(), "«%s» si legge" % voice_id)
			if row.is_empty():
				continue
			# **E la sigla non c'e' piu' davanti al testo.**
			assert_false(
				str(row["text"]).begins_with("A · ") or str(row["text"]).begins_with("B · ")
				or str(row["text"]).begins_with("BA · "),
				"«%s» non porta piu' la sigla: %s" % [voice_id, str(row["text"])]
			)
			var served: Array = (voice as Dictionary).get("for", []) as Array
			var expected: String = ""
			for question_id in served:
				expected += "A" if str(question_id) == a_question else ("B" if str(question_id) == b_question else "")
			if expected.length() > 1:
				expected = "AB"
			var mine: String = str(groups.get(str(row["text"]), ""))
			assert_eq(mine, expected, "«%s» sta sotto il gruppo della sua domanda" % voice_id)
			checked += 1
	assert_true(checked >= 8, "e vale per ogni casella della carta: %d" % checked)


## **La pedina posata si vede sulla casella**, del colore della parte che
## l'ha posata: e' la riga che rende il Consiglio una decisione invece di un
## menu. Fabbricato: chi propone posa un beneficio della A, un altro seggio
## prende la B e posa una casella sua.
func test_what_each_side_placed_is_marked_in_its_colour() -> void:
	_open()
	var proponent: String = str(session.confluence.current["proponent"])
	var menu_a: Array = session.confluence.box_menu("A")
	assert_true(not menu_a.is_empty(), "la A ha caselle libere")
	var voice_a: Dictionary = menu_a[0] as Dictionary
	assert_true(session.confluence.place_box(proponent, str(voice_a["id"])), "chi propone posa")
	var other: String = _other()
	assert_true(session.confluence.join_side(other, "B"), "un altro prende la B")
	var menu_b: Array = session.confluence.box_menu("B")
	assert_true(not menu_b.is_empty(), "e la B ha caselle libere")
	var voice_b: Dictionary = menu_b[0] as Dictionary
	assert_true(session.confluence.place_box(other, str(voice_b["id"])), "e posa")

	var marked: Array = []
	for row in _rows():
		if bool((row as Dictionary)["marked"]):
			marked.append(row)
	assert_eq(marked.size(), 2, "due pedine posate, due pedine disegnate — non una lista puntata")
	var row_a: Dictionary = _row_of(str(voice_a["list"]), str(voice_a["id"]))
	assert_true(bool(row_a.get("marked", false)), "la pedina sta sulla casella che A ha preso")
	assert_eq(row_a.get("colour"), Color(str(ConfluenceBoard.SIDE_COLOURS["A"])), "del colore della A")
	var row_b: Dictionary = _row_of(str(voice_b["list"]), str(voice_b["id"]))
	assert_true(bool(row_b.get("marked", false)), "e su quella che B ha preso")
	assert_eq(row_b.get("colour"), Color(str(ConfluenceBoard.SIDE_COLOURS["B"])), "del colore della B")


## **Una casella che qui non farebbe niente si vede spenta** (D-306), e lo
## dice. Fabbricato: col Tema gia' a zero, «Raffredda il Tema» non morde.
func test_a_box_that_would_do_nothing_is_shown_off() -> void:
	_open()
	var lit: Dictionary = _row_of("benefits", "B_COOL")
	assert_false(lit.is_empty(), "«Raffredda il Tema» si legge")
	assert_false(str(lit.get("text", "")).contains("non qui"), "col Tema caldo e' viva: %s" % str(lit.get("text", "")))
	var theme_id: String = str(data().tensions[TENSION].get("theme", ""))
	(session.world["theme_heat"] as Dictionary)[theme_id] = 0
	var off: Dictionary = _row_of("benefits", "B_COOL")
	assert_true(str(off.get("text", "")).contains("non qui: non cambierebbe niente"), "col Tema a zero e' spenta, e lo dice: %s" % str(off.get("text", "")))
	assert_false(bool(off.get("marked", true)), "e senza pedina")


## L'intestazione dice chi guida le due parti: la B e' di «nessuno» finche'
## nessuno la prende, poi di chi l'ha presa per primo (D-470).
func test_the_header_says_who_leads_each_side() -> void:
	_open()
	var proponent: String = str(session.confluence.current["proponent"])
	var before: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(before.contains("A: %s" % session.service.name_of(proponent)), "la A e' di chi propone: %s" % before)
	assert_true(before.contains("B: nessuno"), "e la B ancora di nessuno")
	var other: String = _other()
	assert_true(session.confluence.join_side(other, "B"), "un seggio prende la B")
	var after: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(after.contains("B: %s" % session.service.name_of(other)), "e adesso la B e' sua: %s" % after)
	assert_false(after.contains("B: nessuno"), "non piu' di nessuno")


## E cosa resta se vince l'una o l'altra (D-471), e cosa succede se cade: e'
## l'informazione che rende «con B» una scelta e non un gesto. La carta ce
## l'ha stampata, e prima nessuno la sceglieva.
func test_the_board_says_what_each_side_leaves_and_what_happens_if_it_falls() -> void:
	_open()
	var board: Node = _board()
	assert_eq(str(board._consequences_title.text), "SE VINCE", "prima del voto si legge cosa resta se vince")
	var lines: Array = []
	_labels_of(board._consequences, lines)
	assert_eq(lines.size(), 2, "una riga per parte")
	var template: Dictionary = session.data.confluence_template_for(TENSION)
	for i in range(mini(2, lines.size())):
		var side: String = ["A", "B"][i]
		var line: String = str(lines[i])
		assert_true(line.begins_with("%s · " % side), "la riga porta la lettera: %s" % line)
		var question_id: String = session.confluence.side_question(side)
		for entry in (template.get("questions", []) as Array):
			if str((entry as Dictionary)["id"]) != question_id:
				continue
			for consequence_id in ((entry as Dictionary).get("base", []) as Array):
				var title: String = str((session.data.consequences[str(consequence_id)] as Dictionary)["title"])
				assert_true(line.contains(title), "e nomina «%s», l'esito di base della %s" % [title, side])
	board.free()
	var column: String = " · ".join(PackedStringArray(_drawn()))
	assert_true(column.contains("SE CADE"), "c'e' la terza lista: %s" % column)
	for voice in (data().tensions[TENSION]["physical"]["failure"] as Array):
		assert_true(
			column.contains(str((voice as Dictionary)["text"])),
			"e si legge intera"
		)


## **Il conto in parole, contro il mucchio** (D-466, D-472): «S 5 · O 3 ·
## Mondo +3» era il verbale del motore sotto gli occhi di chi gioca, e il
## dado non c'e' piu'. Fabbricato: un Consiglio gia' votato, e si legge
## «A … · B … · mucchio …», il margine col suo nome, e l'esito a parte.
func test_the_count_is_in_player_words() -> void:
	var board: Node = ConfluenceBoard.new()
	board._ensure_built()
	board._render_outcome({
		"pile": 3,
		"result": {
			"outcome": "DECISIVE_SUCCESS", "support_total": 9, "oppose_total": 3, "margin": 6,
		},
	})
	var count: String = str(board._outcome.text)
	assert_true(count.contains("A 9 · B 3 · mucchio 3"), "le due parti e il mucchio, in parole: %s" % count)
	assert_true(count.contains("Margine +6"), "e il margine col suo nome")
	assert_false(count.contains("S 9") or count.contains("O 3"), "niente sigle")
	assert_false(count.to_lower().contains("dado") or count.contains("1d6"), "e niente dado")
	assert_eq(str(board._verdict.text), "Passa senza discussione", "l'esito sta a parte, grande")
	board._render_outcome({
		"pile": 3,
		"result": {"outcome": "COUNTER", "support_total": 2, "oppose_total": 4, "margin": -2},
	})
	assert_eq(str(board._verdict.text), "Vince l'altra domanda", "e la B che vince ha il suo nome")
	board._render_outcome({"pile": 3})
	assert_eq(str(board._verdict.text), "", "prima del voto non c'e' un esito")
	assert_true(str(board._outcome.text).contains("mucchio"), "e il conto dice quanto vale il mucchio")
	assert_true(str(board._outcome.text).contains("3"), "col suo numero")
	board.free()


## --- e la casella sulla carta e' la scelta (D-480) --------------------------


## **La ripetizione che il committente ha visto guardando il tabellone**:
## *«perche' mi ripeti le opzioni della carta sotto? Basterebbe che io scelgo un
## cerchietto per scegliere cosa fare, e' una ripetizione inutile.»*
##
## Le caselle stavano gia' disegnate sulla carta girata, ognuna col suo
## cerchietto, e sotto tornavano tutte come carte-scelta. Adesso una casella
## offerta si **accende sulla carta** — alta un dito (D-243), e risponde al
## tocco — e non si ristampa sotto.
func test_an_offered_box_lights_up_on_the_card_and_is_not_reprinted() -> void:
	_open()
	var menu: Array = session.confluence.box_menu("A")
	assert_true(menu.size() >= 2, "la A ha almeno due caselle libere")
	var first: String = str((menu[0] as Dictionary)["id"])
	var second: String = str((menu[1] as Dictionary)["id"])

	var board: Node = _board()
	board.ask("cosa posi?", ["la prima", "la seconda"],
		[{"box": first, "side": "A"}, {"box": second, "side": "A"}])
	assert_eq(board._choices.get_child_count(), 0,
		"nessuna carta-scelta: le due caselle si toccano sulla carta")

	var lit: int = 0
	for row in board._face.get_children():
		if (row as Node).has_meta("offered") and bool((row as Node).get_meta("offered")):
			lit += 1
			assert_eq((row as Control).custom_minimum_size.y, 44.0,
				"una casella che si tocca e' alta un dito")
			assert_ne((row as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE,
				"e risponde al tocco")
	assert_eq(lit, 2, "due caselle offerte, due caselle accese")
	board.picked.emit(0)
	board.free()


## **Quello che non e' una casella resta una carta-scelta**, se no non si
## potrebbe piu' scegliere: «Passa» non sta sulla carta.
func test_what_is_not_a_box_stays_a_choice_card() -> void:
	_open()
	var menu: Array = session.confluence.box_menu("A")
	var first: String = str((menu[0] as Dictionary)["id"])
	var board: Node = _board()
	board.ask("rilanci?", ["la prima", "Passa"], [{"box": first}, {}])
	assert_eq(board._choices.get_child_count(), 1, "resta solo «Passa»")
	board.picked.emit(1)
	board.free()


## **E una casella che serve tutt'e due le domande porta con se' due scelte.**
## La stessa casella compare «con A» e «con B»: toccarla non dice da che parte
## stai, ma ha tolto di mezzo tutto il resto — restano quelle due, ed e' il
## gesto del tavolo (D-231). Il patto di D-238 e' intero: nessuna scelta legale
## resta irraggiungibile.
func test_a_box_two_questions_share_carries_both_choices() -> void:
	var subjects: Array = [
		{"box": "B_ONE", "side": "A"}, {"box": "B_ONE", "side": "B"},
		{"box": "B_TWO", "side": "A"},
	]
	var offered: Dictionary = ConfluenceBoard._boxes_offered(subjects)
	assert_eq((offered.get("B_ONE", []) as Array).size(), 2,
		"la casella condivisa porta le due scelte")
	assert_eq((offered.get("B_TWO", []) as Array), [2],
		"quella di una parte sola ne porta una, ed e' quella giusta")


## E toccata, la casella condivisa lascia sotto **solo** le sue due scelte.
func test_touching_a_shared_box_narrows_to_its_two_choices() -> void:
	_open()
	var board: Node = _board()
	board.ask("da che parte stai?", ["con A", "con B", "altro"],
		[{"box": "B_X", "side": "A"}, {"box": "B_X", "side": "B"}, {}])
	assert_eq(board._choices.get_child_count(), 1, "sotto resta solo quello che non e' una casella")
	board._only_these(["con A", "con B", "altro"], [0, 1])
	assert_eq(board._choices.get_child_count(), 2, "toccata la casella, restano le sue due")
	board.picked.emit(0)
	board.free()


## E si **vede** che si puo' prendere: la riga accesa e il suo cerchietto
## passano all'ocra di chi sceglie. Un bersaglio grande e invisibile non e' un
## bersaglio.
func test_an_offered_box_is_painted_as_offered() -> void:
	_open()
	var first: String = str((session.confluence.box_menu("A")[0] as Dictionary)["id"])
	var board: Node = _board()
	board.ask("cosa posi?", ["la prima"], [{"box": first, "side": "A"}])
	var painted: int = 0
	for row in board._face.get_children():
		if not ((row as Node).has_meta("offered") and bool((row as Node).get_meta("offered"))):
			continue
		for child in (row as Node).get_children():
			if child is Label:
				painted += 1
				assert_eq(
					(child as Label).get_theme_color("font_color"),
					Color(ConfluenceBoard.OFFER_COLOUR),
					"la casella offerta si vede offerta"
				)
	assert_eq(painted, 1, "una casella offerta, una riga dipinta")
	board.picked.emit(0)
	board.free()
