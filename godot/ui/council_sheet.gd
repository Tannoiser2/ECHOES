extends PanelContainer
## La scheda di una domanda: cosa si potra' proporre, e cosa lascia al mondo.
##
## Il committente ha deciso che **per adesso si gioca all'app** e il cartone si
## vedra' poi ([D-236](../../docs/DECISIONS.md#d-236)). Quella decisione ha una
## conseguenza immediata: il materiale del Consiglio non puo' restare in un
## documento che si legge fuori dal gioco. Se lo schermo e' il tavolo, quello che
## al tavolo staresti a guardare mentre pensi deve stare **sullo schermo**.
##
## Fino a qui le proposte comparivano una riga alla volta **a Consiglio gia'
## aperto**, cioe' quando decidere e' tardi: chi scalda una domanda non poteva
## sapere cosa ci sarebbe stato da proporre. Questa scheda si apre quando vuoi,
## sulla domanda che vuoi, e dice le stesse cose che direbbe una scheda stampata
## — con i nomi veri, perche' qui la partita c'e'.
##
## Nessuna logica: legge `CouncilText` ([D-232](../../docs/DECISIONS.md#d-232)),
## che e' l'unico posto dove una proposta diventa italiano. La scheda stampata e
## questa pagina non possono dire due cose diverse, perche' escono dalla stessa
## funzione (D-233).

signal closed()

const CouncilText := preload("res://scripts/core/council_text.gd")

var _column: VBoxContainer


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#15130f")
	style.border_color = Color("#3b352c")
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(14)
	add_theme_stylebox_override("panel", style)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_column = VBoxContainer.new()
	_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_column.add_theme_constant_override("separation", 6)
	scroll.add_child(_column)


## Disegna la scheda della domanda `tension_id`.
##
## `session` puo' mancare: senza partita i buchi si **spiegano** invece che
## riempirsi, esattamente come su una scheda stampata. E' la stessa scelta di
## `CouncilText`, e vale la pena poterla vedere anche qui — una scheda che si
## legge prima di cominciare e' meta' del motivo per cui esiste.
func show_tension(tension_id: String, data: RefCounted, session: RefCounted = null) -> void:
	for child in _column.get_children():
		child.queue_free()
		_column.remove_child(child)

	var tension: Variant = data.tensions.get(tension_id)
	if tension == null:
		_line("Questa domanda non e' nella scatola.", 13, "#c8553d")
		return
	var voice: Callable = _voice_for(tension_id, session)

	_line(str((tension as Dictionary)["title"]).to_upper(), 15, "#e8dcc8")
	_line("Se questa domanda arriva al Consiglio, ecco cosa si potra' proporre.", 11, "#8a8172")

	# **Il Consiglio di una domanda si trova come lo trova il motore** (D-278):
	# 52 carte su 60 non nominano un template proprio e giocano su quello
	# generico del loro dominio. Cercandolo per id soltanto, questa scheda
	# diceva «Nessun Consiglio scritto» su cinquantadue domande su sessanta —
	# cioe' sulla quasi totalita' del mazzo.
	var template: Variant = data.confluence_template_for(tension_id)
	if template == null or (template as Dictionary).is_empty():
		_line("Nessun Consiglio scritto per questa domanda.", 12, "#9b9382")
		_close_button()
		return

	for entry in (template as Dictionary).get("propositions", []):
		var said: Dictionary = CouncilText.proposition(
			template as Dictionary, str((entry as Dictionary)["id"]), data, voice
		)
		if said.is_empty():
			continue
		_gap()
		_line(str(said["question"]), 11, "#7f8f7a")
		_line(str(said["text"]), 13, "#d9d2c5")
		for need in said["needs"]:
			_line("Solo se: %s" % str(need), 11, "#c9a14a")
		# Una riga per Conseguenza, col suo nome. Una proposta puo' portarne
		# due, e fonderle in una riga sola faceva una filza di nove cose senza
		# dire che erano **due esiti diversi** — al tavolo quella distinzione e'
		# tutto: sapere che «passa» vuol dire questo *oppure* quello.
		var said_anything: bool = false
		for record in said["consequences"]:
			var line: String = str((record as Dictionary)["leaves"])
			if line == "":
				continue
			said_anything = true
			_line("Se passa — %s: %s" % [str((record as Dictionary)["title"]), line], 11, "#9b9382")
		if not said_anything:
			_line("Non lascia segni sul mondo.", 11, "#9b9382")

	var clauses: Array = CouncilText.clauses(template as Dictionary, data, voice)
	if not clauses.is_empty():
		_gap()
		_line("Le clausole che si possono attaccare", 12, "#8a8172")
		for clause in clauses:
			var record: Dictionary = clause as Dictionary
			# La frase d'autore comincia gia' con i suoi puntini: aggiungerne
			# altri tre faceva «......purche'».
			var text: String = str(record["text"])
			_line(text if text.begins_with("...") else "...%s" % text, 12, "#d9d2c5")
			if str(record["leaves"]) != "":
				_line("se qualificata: %s" % str(record["leaves"]), 11, "#9b9382")
	_the_two_lists(tension as Dictionary)
	_close_button()


## **Le due liste della carta** (D-278): cosa il proponente puo' promettere e
## cosa il fronte avverso puo' fargli pagare. Sta in fondo perche' si legge
## dopo aver capito di che si discute — ma sta **qui**, sulla scheda della
## domanda, perche' al tavolo sta sulla stessa carta.
func _the_two_lists(tension: Dictionary) -> void:
	var face: Dictionary = tension.get("physical", {}) as Dictionary
	if face.is_empty():
		return
	for pair in [
		["benefits", "Benefici possibili — li compra chi propone (massimo 3 pedine)"],
		["costs", "Costi possibili — li sceglie il fronte avverso (massimo 2 pedine)"],
		["failure", "Se la proposta non passa — non li sceglie nessuno"],
	]:
		var voices: Array = face.get(str(pair[0]), []) as Array
		if voices.is_empty():
			continue
		_gap()
		_line(str(pair[1]), 12, "#8a8172")
		for voice in voices:
			_line("○ %s" % str((voice as Dictionary)["text"]), 12, "#d9d2c5")
	# La riga dell'economia, che e' la regola vera della carta (D-280).
	_gap()
	_line(
		"1 beneficio e' gratis. Ogni beneficio in piu' richiede 1 costo."
		+ "  Al massimo 3: il tetto non si sfonda.",
		11, "#c9a14a"
	)


## La voce con cui questa scheda parla, ed e' il punto delicato di tutta la
## pagina.
##
## `ConfluenceController.say()` riempie i buchi con le `text_bindings` del
## Consiglio **aperto**. Ma una scheda si legge proprio quando il Consiglio non
## e' aperto: li' quelle bindings sono vuote e la pagina mostrerebbe
## `$region_focus` a chi gioca. La prima stesura faceva esattamente questo, e la
## prova l'ha preso al primo giro.
##
## Il mondo pero' le risposte ce le ha lo stesso: **di quale Regione parla questa
## domanda adesso** e **chi la porterebbe se si aprisse** si calcolano senza
## Consiglio — e' la stessa strada che una carta Echo percorre da sempre
## (`card_bindings`). Quindi: prima si riempie con quello che il mondo sa, e
## quello che resta **si spiega**. Un nome vero quando c'e', un ruolo quando non
## c'e', mai un `$`.
func _voice_for(tension_id: String, session: RefCounted) -> Callable:
	if session == null:
		return Callable()
	if not (session.world["tensions"] as Dictionary).has(tension_id):
		return Callable()
	var narrative: RefCounted = session.confluence.narrative
	# **Chi la porterebbe se si aprisse adesso.** Non e' un'invenzione della
	# pagina: e' la stessa regola che il Consiglio applica quando si apre, ed e'
	# gia' la strada che una carta Echo percorre fuori da ogni Consiglio.
	var bindings: Dictionary = narrative.bindings_for(
		tension_id, session.service.determine_proponent(tension_id)
	)
	return func(text: String) -> String:
		return CouncilText.speak(narrative.fill(text, bindings))


func _line(text: String, size: int, colour: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(colour))
	_column.add_child(label)


func _gap() -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	_column.add_child(spacer)


func _close_button() -> void:
	_gap()
	var button := Button.new()
	button.text = "Chiudi la scheda"
	button.add_theme_font_size_override("font_size", 12)
	button.pressed.connect(func() -> void: closed.emit())
	_column.add_child(button)
