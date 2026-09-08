extends VBoxContainer
## The Council, while it happens.
##
## The map answers "where are we"; this answers "what is being decided, by whom,
## and at what cost". It takes over the middle of the screen when a Council opens
## and gives it back when the Council closes.
##
## Same seam as everything else in `ui/`: it reads `session.confluence.current` -
## the same dictionary the log renders and the 0.0 terminal printed - and it
## decides nothing. Choices arrive as `ask(prompt, labels)`, already formatted by
## SeatDecider, and are drawn as cards. The board does not know whether it is
## showing questions, sides or Assets, and it must not: that is what keeps
## the browser and the terminal offering the same options.

## Emitted by whichever card was pressed.
signal picked(index: int)


## I colori delle due parti (D-467, giro 4): A ocra come chi propone, B
## azzurra come l'altra domanda. Sono le pedine sul cartone.
const SIDE_COLOURS: Dictionary = {"A": "#e8b563", "B": "#7fa6c9"}

const STANCE_COLOURS: Dictionary = {
	"SUPPORT": "#6fa88a", "OPPOSE": "#c8553d",
	"ABSTAIN": "#5f584c",
}

## Le posizioni in parole: i nomi del motore sono per il verbale, e sul
## tabellone comparivano in inglese e minuscolo — «support», «oppose»,
## «abstain», «proponent» — sotto gli occhi di chi gioca (D-463).
const STANCE_WORDS: Dictionary = {
	"PROPONENT": "propone", "SUPPORT": "a favore",
	"OPPOSE": "contro", "ABSTAIN": "si astiene",
}

## What the four outcomes are, in words. The engine's names are for the log; a
## table wants to know whether the thing passed.
const OUTCOMES: Dictionary = {
	"FAILURE": "Respinta",
	"SUCCESS_WITH_COST": "Passa, ma si paga",
	"SUCCESS": "Passa",
	"DECISIVE_SUCCESS": "Passa senza discussione",
	"COUNTER": "Vince l'altra domanda",
}

## L'esito a colori: verde quando passa, rosso quando cade, ocra quando passa
## ma si paga.
const VERDICT_COLOURS: Dictionary = {
	"FAILURE": "#c8553d",
	"SUCCESS_WITH_COST": "#e8b563",
	"SUCCESS": "#6fa88a",
	"DECISIVE_SUCCESS": "#6fa88a",
	"COUNTER": "#7fa6c9",
}

## La carta girata a sinistra e il conto a destra hanno una larghezza loro;
## chi siede prende quello che resta. Sul tablet di D-465 (1366 punti, meno
## i margini del Consiglio) restano circa 560 punti per il centro.
const CARD_WIDTH: float = 420.0
const COUNT_WIDTH: float = 280.0

## Il lato della pedina disegnata accanto a una voce della carta.
const PEDINA: float = 16.0

var _header: Label
var _question: Label
var _proposition: Label
var _face: VBoxContainer
var _stances: VBoxContainer
var _consequences: VBoxContainer
var _consequences_title: Label
var _stances_title: Label
var _outcome: Label
var _verdict: Label
var _choices: HFlowContainer
var _prompt: Label


func _ready() -> void:
	add_theme_constant_override("separation", 10)
	_build()


## Il tabellone si costruisce da solo alla prima lettura, se nessuno lo ha
## ancora messo nell'albero: `_ready()` non gira per un nodo costruito fuori —
## e' la trappola di casa, e senza questa riga una prova che disegna il
## Consiglio muore a meta' invece di fallire.
func _ensure_built() -> void:
	if _header == null:
		_build()


func _build() -> void:
	# **Il Consiglio a schermo intero, disegnato** (D-466). Da D-464 il
	# Consiglio ha una schermata sua, ma il tabellone era ancora quello di
	# D-463: una colonna stretta in mezzo a tre quarti di pagina vuoti. Ora
	# la pagina e' disposta come il tavolo quando un Consiglio si apre:
	#
	#   sinistra — **la carta girata**, un pannello di cartone con la
	#              domanda, la proposta e le tre liste (D-291, D-449);
	#   centro   — **chi siede**: posizione e carte impegnate, e sotto cosa
	#              lascia al mondo (SE PASSA / COSA RESTA);
	#   destra   — **il conto**: il dado, le somme, l'esito — in parole;
	#   sotto    — la domanda del tabellone e le sue scelte, a tutta
	#              larghezza, sempre in vista.
	#
	# Ogni colonna scorre per conto suo: quello che si legge non trabocca
	# (D-463), e le scelte restano in fondo.
	_header = _label(15, "#e8b563")
	add_child(_header)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 24)
	add_child(columns)

	# La carta della domanda, girata sul retro, posata al centro del tavolo
	# (D-101): l'immagine non c'e' perche' la carta e' tutta testo (le sue
	# schede lo dicono), quindi si disegna il cartone, non una figura.
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(CARD_WIDTH, 0)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color("#1a1712")
	skin.border_color = Color("#6b5a3a")
	skin.set_border_width_all(1)
	skin.set_corner_radius_all(6)
	skin.set_content_margin_all(16)
	card.add_theme_stylebox_override("panel", skin)
	columns.add_child(card)
	var card_scroll := _scroll()
	card.add_child(card_scroll)
	var face_column := _column(8)
	card_scroll.add_child(face_column)

	_question = _label(19, "#efe7d8")
	face_column.add_child(_question)

	_proposition = _label(14, "#c9bfae")
	face_column.add_child(_proposition)

	var rule := ColorRect.new()
	rule.color = Color("#3a332a")
	rule.custom_minimum_size = Vector2(0, 1)
	face_column.add_child(rule)

	# **La carta girata, con le sue due liste** (D-291). Il Consiglio si decide
	# su quello che la carta offre e su quello che chiede in cambio: finche' le
	# due liste stavano solo nel motore, al tavolo si votava alla cieca una
	# frase d'autore — ed e' quello che il committente ha visto guardando
	# l'app: *«il Concilio e' ancora quello vecchio»*.
	_face = VBoxContainer.new()
	_face.add_theme_constant_override("separation", 2)
	face_column.add_child(_face)

	# Chi siede, e cosa resta.
	var middle := _scroll()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(middle)
	var table := _column(10)
	middle.add_child(table)

	_stances_title = _label(11, "#8a8172")
	_stances_title.text = "CHI SIEDE"
	table.add_child(_stances_title)

	_stances = VBoxContainer.new()
	_stances.add_theme_constant_override("separation", 3)
	table.add_child(_stances)

	_consequences_title = _label(12, "#8a8172")
	table.add_child(_consequences_title)

	_consequences = VBoxContainer.new()
	_consequences.add_theme_constant_override("separation", 6)
	table.add_child(_consequences)

	# Il conto, in parole.
	var count := _column(8)
	count.custom_minimum_size = Vector2(COUNT_WIDTH, 0)
	columns.add_child(count)

	var count_title := _label(11, "#8a8172")
	count_title.text = "IL CONTO"
	count.add_child(count_title)

	_outcome = _label(15, "#efe7d8")
	count.add_child(_outcome)

	_verdict = _label(22, "#efe7d8")
	count.add_child(_verdict)

	_prompt = _label(14, "#e8b563")
	add_child(_prompt)

	_choices = HFlowContainer.new()
	_choices.add_theme_constant_override("h_separation", 8)
	_choices.add_theme_constant_override("v_separation", 8)
	add_child(_choices)


func _scroll() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	return scroll


func _column(separation: int) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", separation)
	return column

func _label(font_size: int, colour: String) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(colour))
	return label


# --- reading the Council ----------------------------------------------------

func render(session: RefCounted, _viewer_id: String) -> void:
	if not session.confluence.is_open():
		return
	_paint_council(session, session.confluence.current)


## The same board, drawn from a Council that has already closed.
##
## `resolve()` is atomic and clears `current` at the end of it, so the one
## moment the whole game turns on - the roll, the sum, and what it wrote on the
## map - would otherwise never be on screen for a single frame. The screen keeps
## the snapshot it was handed at RESOLVED and draws it until the player has
## looked at it (D-039).
func render_closed(session: RefCounted, council: Dictionary) -> void:
	if council.is_empty():
		return
	_paint_council(session, council)


func _paint_council(session: RefCounted, council: Dictionary) -> void:
	_ensure_built()
	# **La scheda della carta, non il template grezzo** (D-310, D-378): la
	# plancia disegnava la Domanda e la Proposta di ripiego del template,
	# non quelle stampate sulla carta Tensione che sta in tavola.
	var template: Dictionary = session.data.confluence_template_for(
		str(council["tension_id"])
	)
	var title: String = str(session.data.tensions[str(council["tension_id"])]["title"])
	# **Le due domande** (D-467, giro 4): A e' quella presa da chi propone, B
	# l'altra, con chi la guida — o «nessuno», finche' nessuno la prende.
	var sides: Dictionary = council["sides"] as Dictionary
	var leader_b: String = str((sides["B"] as Dictionary).get("leader", ""))
	_header.text = "%s — A: %s · B: %s" % [
		title, session.service.name_of(str(council["proponent"])),
		"nessuno" if leader_b == "" else session.service.name_of(leader_b),
	]
	_question.text = "A · %s" % _fill(
		session, council, _question_text(template, str((sides["A"] as Dictionary)["question_id"]))
	)
	_proposition.text = "B · %s" % _fill(
		session, council, _question_text(template, str((sides["B"] as Dictionary)["question_id"]))
	)

	_render_face(session, council)
	_render_stances(session, council)
	_render_consequences(session, council, template)
	_render_outcome(council)


## **Le due liste della carta**, come stanno stampate (D-291), con le pedine
## delle due parti sopra (D-467). Si legge dalla faccia stampata della
## Tensione, non dal template, cosi' vale identico su un Consiglio aperto e su
## uno gia' chiuso, dove `current` non c'e' piu'.
func _render_face(session: RefCounted, council: Dictionary) -> void:
	for child in _face.get_children():
		child.queue_free()
		_face.remove_child(child)
	var tension: Variant = session.data.tensions.get(str(council.get("tension_id", "")))
	if tension == null:
		return
	var face: Dictionary = (tension as Dictionary).get("physical", {}) as Dictionary
	if face.is_empty():
		return
	_render_sides_face(session, council, face)


## **La carta a due domande sul tabellone** (D-467, giro 4): le tre liste con
## la marca della domanda davanti a ogni casella — A, B, AB — come sul
## cartone, e la pedina del colore della parte che l'ha presa. Una casella
## che qui non farebbe niente si vede spenta (D-306). Vale identico su un
## Consiglio aperto e su uno chiuso: le parti e le pedine stanno nel record.
func _render_sides_face(session: RefCounted, council: Dictionary, face: Dictionary) -> void:
	var sides: Dictionary = council["sides"] as Dictionary
	var letters: Dictionary = {
		str((sides["A"] as Dictionary)["question_id"]): "A",
		str((sides["B"] as Dictionary)["question_id"]): "B",
	}
	var taken: Dictionary = {}
	for side in ["A", "B"]:
		for box in ((sides[side] as Dictionary).get("boxes", []) as Array):
			taken[str((box as Dictionary)["voice"])] = side
	var live: Dictionary = {}
	if session.confluence.is_open():
		for list_name in ["benefits", "costs"]:
			for voice in session.confluence.live_voices(list_name):
				live[str((voice as Dictionary)["id"])] = true
	for pair in [["benefits", "BENEFICI", "#6fa88a", "#5f6b62"], ["costs", "COSTI", "#c8553d", "#7a5a52"]]:
		_face.add_child(_face_heading(str(pair[1])))
		for voice in (face.get(str(pair[0]), []) as Array):
			var voice_id: String = str((voice as Dictionary)["id"])
			var marks: String = ""
			for question_id in ((voice as Dictionary).get("for", []) as Array):
				marks += str(letters.get(str(question_id), ""))
			var text: String = "%s · %s" % [marks, str((voice as Dictionary).get("text", ""))]
			var side: String = str(taken.get(voice_id, ""))
			if side != "":
				_face.add_child(_face_voice(text, true, str(SIDE_COLOURS[side])))
			elif session.confluence.is_open() and not live.has(voice_id):
				_face.add_child(_face_voice(text + "   — non qui: non cambierebbe niente", false, str(pair[3])))
			else:
				_face.add_child(_face_voice(text, false, str(pair[2])))
	var falls: Array = face.get("failure", []) as Array
	if not falls.is_empty():
		_face.add_child(_face_heading("SE CADE — se non passa nessuna delle due"))
		for voice in falls:
			_face.add_child(_face_voice(str((voice as Dictionary).get("text", "")), false, "#8a8172"))
	# **Le monete che le due parti hanno in mano** (D-476). Un gettone di
	# rivendicazione alza di uno il tetto dei benefici della sua parte, e una
	# regola che non si vede non e' una regola del tavolo: al cartone la moneta
	# sta davanti a chi la porta, e qui sta sotto le due liste, dove si guarda
	# prima di posare la pedina di troppo. Non si stampa se il tavolo non ne ha
	# nessuna, che e' quasi sempre.
	var purses: Array = []
	for side in ["A", "B"]:
		var purse: int = _claim_tokens_of_side(session, sides, side)
		if purse > 0:
			purses.append("%s: %d" % [side, purse])
	if not purses.is_empty():
		_face.add_child(_face_heading("GETTONI — ognuno compra un beneficio oltre il tetto"))
		_face.add_child(_face_voice(" · ".join(PackedStringArray(purses)), false, "#c9a14a"))


## Le monete di rivendicazione di una parte: la parte e' una, e il gettone di
## chi la sostiene vale per lei (D-476).
func _claim_tokens_of_side(session: RefCounted, sides: Dictionary, side: String) -> int:
	var part: Dictionary = sides.get(side, {}) as Dictionary
	var seats: Array = (part.get("seats", []) as Array).duplicate()
	var leader: String = str(part.get("leader", ""))
	if leader != "" and not seats.has(leader):
		seats.append(leader)
	var purse: int = 0
	for entity_id in seats:
		var entity: Variant = (session.world["entities"] as Dictionary).get(str(entity_id))
		if entity != null:
			purse += int((entity as Dictionary).get("claim_tokens", 0))
	return purse


func _face_heading(text: String) -> Label:
	var label: Label = _label(11, "#8a8172")
	label.text = text
	return label


## Una voce della carta: la pedina posata o la casella libera. E' il disegno
## del cartone, non una lista puntata: quello che si vede al tavolo e' dove
## stanno le pedine.
##
## **La pedina e' disegnata, non scritta** (D-466): «●» e «○» erano glifi che
## il carattere dell'export web non ha, e sulla pagina uscivano quadratini
## vuoti — la stessa trappola delle frecce di D-463. Una riga porta la pedina
## come nodo, con `marked` scritto sopra, cosi' una prova la legge senza
## cercare un segno.
func _face_voice(text: String, marked: bool, colour: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.set_meta("marked", marked)
	var pedina := Control.new()
	pedina.custom_minimum_size = Vector2(PEDINA, PEDINA)
	pedina.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	pedina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pedina.draw.connect(_draw_pedina.bind(pedina, marked, Color(colour)))
	row.add_child(pedina)
	var label: Label = _label(12, colour if marked else "#5f584c")
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	return row


## La pedina: un tondo pieno se posata, il bordo della casella se libera.
func _draw_pedina(node: Control, marked: bool, colour: Color) -> void:
	var centre := Vector2(PEDINA * 0.5, PEDINA * 0.5 + 2.0)
	var radius: float = PEDINA * 0.36
	if marked:
		node.draw_circle(centre, radius, colour)
	node.draw_arc(centre, radius, 0.0, TAU, 24, colour if marked else Color("#5f584c"), 1.0, true)


## The narrative slots ($the_region, $rival...) filled from the bindings this
## Council resolved at step A. Taken from the snapshot rather than from the
## controller, because a closed Council has no bindings left to ask for.
func _fill(session: RefCounted, council: Dictionary, text: String) -> String:
	return session.confluence.narrative.fill(text, council.get("text_bindings", {}))


func _question_text(template: Dictionary, question_id: String) -> String:
	for question in template["questions"]:
		if str(question["id"]) == question_id:
			return str(question["text"])
	return ""


## Stances as they are declared, in the order the table declared them, with the
## commits beside them once E has revealed everything at once. Before the
## reveal the column is deliberately empty: what someone put down is not public
## until it is public.
func _render_stances(session: RefCounted, current: Dictionary) -> void:
	for child in _stances.get_children():
		child.queue_free()
		_stances.remove_child(child)

	var seats: Array = [str(current["proponent"])]
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(current["proponent"]):
			seats.append(str(entity_id))

	var commits: Dictionary = current.get("commits", {})
	for entity_id in seats:
		var is_proponent: bool = entity_id == str(current["proponent"])
		var record: Variant = (current.get("stances", {}) as Dictionary).get(entity_id)
		var stance: String = "PROPONENT" if is_proponent else (
			"" if record == null else str(record["stance"])
		)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_stances.add_child(row)

		var who := Label.new()
		who.text = session.service.name_of(entity_id)
		who.custom_minimum_size = Vector2(120, 0)
		who.add_theme_font_size_override("font_size", 13)
		who.add_theme_color_override("font_color", Color("#c9bfae"))
		row.add_child(who)

		var said := Label.new()
		said.text = "…" if stance == "" else str(STANCE_WORDS.get(stance, stance.to_lower()))
		var tint: Color = Color("#e8b563") if is_proponent else Color(str(STANCE_COLOURS.get(stance, "#5f584c")))
		if current.has("sides"):
			# **Con A, con B** (D-467, giro 4): la posizione e' la parte, e il
			# colore e' quello delle sue pedine. Chi guida la B «propone B».
			var leader_b: String = str(((current["sides"] as Dictionary)["B"] as Dictionary).get("leader", ""))
			if is_proponent:
				said.text = "propone A"
			elif entity_id == leader_b:
				said.text = "propone B"
				tint = Color(str(SIDE_COLOURS["B"]))
			elif stance == "SUPPORT":
				said.text = "con A"
				tint = Color(str(SIDE_COLOURS["A"]))
			elif stance == "OPPOSE":
				said.text = "con B"
				tint = Color(str(SIDE_COLOURS["B"]))
		said.custom_minimum_size = Vector2(90, 0)
		said.add_theme_font_size_override("font_size", 13)
		said.add_theme_color_override("font_color", tint)
		row.add_child(said)

		var spent: Array = commits.get(entity_id, [])
		if not spent.is_empty():
			var cards := Label.new()
			var titles: Array = []
			for asset_id in spent:
				var asset: Variant = session.data.assets.get(str(asset_id))
				titles.append(str(asset_id) if asset == null else str(asset["title"]))
			cards.text = ", ".join(PackedStringArray(titles))
			cards.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cards.add_theme_font_size_override("font_size", 12)
			cards.add_theme_color_override("font_color", Color("#8a8172"))
			row.add_child(cards)


## What the proposition on the table would write into the world, and - once it
## has been voted - what it actually wrote.
##
## This is the number-free half of the Council and the one that decides whether
## a stance is worth taking: "sostieni" and "opponiti" mean nothing until you can
## read what you are supporting. The list is authored data (title, description,
## and whether it leaves a Scar); the board picks none of it, it only knows which
## ids to look up - before the vote, the proposition's own; after it, the ones
## the resolution recorded.
func _render_consequences(
	session: RefCounted, council: Dictionary, template: Dictionary
) -> void:
	for child in _consequences.get_children():
		child.queue_free()
		_consequences.remove_child(child)

	var result: Variant = council.get("result", null)
	var ids: Array = []
	if result != null:
		ids = (result as Dictionary).get("consequence_ids", [])
		_consequences_title.text = "COSA RESTA"
	else:
		# **Se vince A, se vince B** (D-467, giro 4): l'esito di base di ognuna
		# delle due domande, cosi' si sa per cosa si posa una pedina.
		_consequences_title.text = "SE VINCE"
		for side in ["A", "B"]:
			var question_id: String = str(((council["sides"] as Dictionary)[side] as Dictionary)["question_id"])
			for entry in template.get("questions", []) as Array:
				if str((entry as Dictionary).get("id", "")) != question_id:
					continue
				var names: PackedStringArray = PackedStringArray()
				for consequence_id in ((entry as Dictionary).get("base", []) as Array):
					var consequence: Variant = session.data.consequences.get(str(consequence_id))
					if consequence != null:
						names.append(str((consequence as Dictionary).get("title", consequence_id)))
				var line: Label = _label(13, str(SIDE_COLOURS[side]))
				line.text = "%s · %s" % [side, " · ".join(names) if not names.is_empty() else "niente di scritto"]
				_consequences.add_child(line)
		return
	if ids.is_empty():
		_consequences_title.text = ""
		return

	for consequence_id in ids:
		var consequence: Variant = session.data.consequences.get(str(consequence_id))
		if consequence == null:
			continue
		var scars: bool = bool(consequence.get("creates_scar", false))
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 1)
		_consequences.add_child(box)

		var title := _label(13, "#c8553d" if scars else "#c9bfae")
		# A Scar is the one mark that never comes off, so it says so where the
		# decision is taken rather than in the log afterwards.
		title.text = ("%s — lascia una Cicatrice" % str(consequence["title"])) if scars \
			else str(consequence["title"])
		box.add_child(title)

		var body := _label(11, "#8a8172")
		body.text = _fill(session, council, str(consequence["description"]))
		box.add_child(body)


## The maths in the clear, once F has rolled. §12.2 G is the moment the game
## decides something, and a player should be able to check the arithmetic.
func _render_outcome(council: Dictionary) -> void:
	_verdict.text = ""
	# **Senza dado** (D-467): il mucchio e' la soglia, e il conto si legge in
	# parole (D-466).
	var pile: int = int(council.get("pile", 0))
	var result_v: Variant = council.get("result", null)
	if result_v == null:
		# **E perche' vale quello** ([D-477](../../docs/DECISIONS.md#d-477)): se
		# il mondo segnato ha mosso la soglia, il tavolo deve sapere quale segno
		# gliel'ha mossa. Una regola che non si vede non e' una regola del
		# tavolo: e' un numero che cambia e nessuno sa perche'.
		var shift: int = int(council.get("pile_shift", 0))
		var titles: Array = council.get("pile_shift_titles", []) as Array
		if shift == 0 or titles.is_empty():
			_outcome.text = "Il mucchio sulla domanda vale %d: chi vince deve arrivarci." % pile
		else:
			_outcome.text = "Il mucchio sulla domanda vale %d — %s di uno perche' %s: chi vince deve arrivarci." % [
				pile,
				"alzato" if shift > 0 else "abbassato",
				" e ".join(PackedStringArray(titles)),
			]
		return
	var settled: Dictionary = result_v as Dictionary
	var outcome: String = str(settled["outcome"])
	_outcome.text = "
".join(PackedStringArray([
		"A %d · B %d · mucchio %d" % [
			int(settled["support_total"]), int(settled["oppose_total"]), pile,
		],
		"Margine %+d" % int(settled["margin"]),
	]))
	_verdict.text = str(OUTCOMES.get(outcome, outcome))
	_verdict.add_theme_color_override(
		"font_color", Color(str(VERDICT_COLOURS.get(outcome, "#efe7d8")))
	)

# --- asking ------------------------------------------------------------------

## Draw the choices as cards and suspend until one is pressed. The board neither
## knows nor cares what they are.
func ask(prompt: String, labels: Array) -> int:
	_prompt.text = prompt
	for child in _choices.get_children():
		child.queue_free()
		_choices.remove_child(child)

	for i in range(labels.size()):
		var index: int = i
		var card := _choice_card(str(labels[i]))
		card.pressed.connect(func() -> void: picked.emit(index))
		_choices.add_child(card)

	var chosen: int = await picked
	_prompt.text = ""
	for child in _choices.get_children():
		child.queue_free()
		_choices.remove_child(child)
	return chosen


## Una scelta del Consiglio disegnata come una carta, non come un bottone con
## dentro una frase (ISSUES 63, D-233).
##
## La prima riga e' **quello che si dice** — la proposta, la posizione, la carta
## che si impegna; le righe dopo sono **quello che costa o che resta**, in grigio
## e piu' piccole. E' la stessa gerarchia che ha una carta di cartone: il titolo
## si legge da lontano, la lettera piccola quando la prendi in mano.
##
## Resta un `Button` sotto, e non per pigrizia: e' quello che sa gia' cosa
## significa avere il fuoco della tastiera, essere premuto con Invio e apparire
## a chi legge lo schermo con un lettore. Le etichette sopra non intercettano il
## mouse (`MOUSE_FILTER_IGNORE`), quindi il clic arriva sempre al bottone.
func _choice_card(label: String) -> Button:
	var card := Button.new()
	card.text = ""
	# Larga abbastanza per una proposta, stretta abbastanza che tre stiano in
	# riga; alta abbastanza per due righe di lettera piccola.
	card.custom_minimum_size = Vector2(260, 78)
	card.clip_text = false
	card.tooltip_text = label

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 8
	box.offset_right = -8
	box.offset_top = 6
	box.offset_bottom = -6
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 3)
	card.add_child(box)

	var parts: PackedStringArray = label.split("\n", false)
	for line_index in range(parts.size()):
		var line := Label.new()
		line.text = str(parts[line_index])
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if line_index == 0:
			line.add_theme_font_size_override("font_size", 13)
		else:
			line.add_theme_font_size_override("font_size", 11)
			line.add_theme_color_override("font_color", Color("#9b9382"))
		box.add_child(line)
	return card
