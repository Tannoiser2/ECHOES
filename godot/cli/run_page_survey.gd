extends SceneTree
## **Cosa la pagina dice, e con quale dito** (ISSUES 65).
##
##   godot --headless --path godot --script res://cli/run_page_survey.gd -- \
##       --out=docs/MISURA_PAGINA.md
##
## La voce 65 del committente — *«tutta la pagina dell'app va rivista»* — porta
## scritta accanto la ragione per cui e' rimasta ferma:
##
## > *«Da misurare, e non c'e' ancora modo: nessuna delle sonde tocca questa
## > pagina. Finche' una persona con l'app in mano resta l'unico strumento, ogni
## > giro costa un suo pomeriggio — ed e' successo tre volte di fila.»*
##
## Questa e' quella sonda. Misura le quattro cose che i sei difetti trovati su
## un tablet avevano in comune, cosi' che ogni passata si giudichi con dei
## numeri invece che con un pomeriggio. La rivista da fare l'ha scelta il
## committente (D-427, la terza: *l'app mostra il tavolo, non lo stato*) ed e'
## fatta in D-444: da li' la sonda dice **se la pagina la segue**.
##
## Quello che si misura e' **quello che la pagina chiede**, non quello che
## ottiene: senza una finestra vera non c'e' un passaggio di disposizione, e
## `custom_minimum_size` piu' `get_combined_minimum_size()` sono cio' che un
## nodo dichiara di volere. Un bersaglio che non dichiara niente non e' per
## questo grande: e' **non dichiarato**, e sta in una colonna sua.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")

const StatusPanel := preload("res://ui/status_panel.gd")
const MapView := preload("res://ui/map_view.gd")
const ConfluenceBoard := preload("res://ui/confluence_board.gd")
const TableView := preload("res://ui/table_view.gd")
const ThemeDecksView := preload("res://ui/theme_decks_view.gd")
const SeatsStrip := preload("res://ui/seats_strip.gd")
const HelpPanel := preload("res://ui/help_panel.gd")
const HandView := preload("res://ui/hand_view.gd")

## **La cornice non si guarda da qui, e va detto.** `ui/game_screen.gd` — dove
## stanno i bottoni degli strumenti e il menu — nomina l'autoload `SaveManager`,
## e una sonda lanciata con `--script` non ha autoload: il file non compila
## nemmeno. Quindi i bersagli contati qui sono quelli **dentro** i pannelli, e
## il numero e' un pavimento, non un totale.
const CORNICE_FUORI: String = "ui/game_screen.gd (dipende da un autoload)"

## Il lato del bersaglio sotto cui un dito comincia a sbagliare. Non e' un
## numero inventato qui: e' la misura che le due guide dei sistemi a tocco
## danno da anni, ed e' gia' quella che D-243 ha usato per le carte in mano.
const DITO: float = 44.0

## La larghezza di un tablet tenuto in verticale, che e' come il committente
## l'ha provata. Serve solo a dire **quanto la pagina chiede in confronto**.
const TAVOLETTA: float = 768.0

## **La pagina di D-444, in due numeri presi da `ui/game_screen.gd`**: la colonna
## delle scelte a destra del tavolo, e i margini — 12 per lato piu' i 12 fra le
## due colonne. Sono ricopiati, non letti: la cornice non compila da qui (sopra),
## e una cifra ricopiata e' la trappola nota. Se la cornice cambia, cambiano qui.
const COLONNA: float = 240.0
const MARGINI: float = 36.0


var _out_path: String = "docs/MISURA_PAGINA.md"
var _pages: Array = []
var _session: RefCounted
var _data: RefCounted
var _viewer: String = ""

## I segni della scatola, per nome. Serve a riconoscere un segno crudo sullo
## schermo senza inventarsi come e' fatto un segno.
var _dictionary: Dictionary = {}

## **Si costruisce a un giro e si guarda al giro dopo.** Un `RichTextLabel`
## riempito con `append_text` non ha ancora un testo da leggere nello stesso
## giro in cui e' nato: la pagina d'aiuto risultava senza una parola.
var _giro: int = 0


## **Il lavoro si fa al primo giro dell'albero, non in `_initialize`.**
##
## Seduto un pannello sotto `root` mentre il ciclo principale non e' ancora
## partito, `_ready()` non gli arriva — e tre pannelli su sette costruiscono
## tutto li' dentro. Al primo giro il conto passava da 118 nodi a quelli veri.
## E' la trappola scritta in CLAUDE.md, vista dal suo lato piu' cattivo: non
## un errore, un pannello **vuoto** che sembra pulito.
func _process(_delta: float) -> bool:
	_giro += 1
	if _giro == 1:
		_pages = _build(_session, _data, _viewer)
		return false
	_survey()
	return true


func _initialize() -> void:
	var out_path: String = "docs/MISURA_PAGINA.md"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for e in data.errors:
			printerr("  %s" % e)
		quit(3)
		return

	var session: RefCounted = GameSession.new(data)
	var seats: Array = GameSession.seats_for(data, "CHR_00", 4242)
	if not session.setup("CHR_00", seats, 4242):
		printerr("l'anno non si apre: la sonda non ha una pagina da guardare")
		quit(4)
		return
	for effect in session.factory_setup_effects():
		session.applier.apply(effect)
	var viewer: String = str(session.world["turn_order"][0])

	_out_path = out_path
	for tag_id in data.tags:
		_dictionary[str(tag_id)] = true
	_session = session
	_data = data
	_viewer = viewer


## Guardata la pagina, non costruita: qui i pannelli hanno gia' avuto il loro
## giro d'albero.
func _survey() -> void:
	var out_path: String = _out_path
	var pages: Array = _pages
	if pages.is_empty():
		printerr("nessun pannello costruito: la sonda e' cieca lei")
		quit(4)
		return

	var mouse: Array = []
	var small: Array = []
	var undeclared: Array = []
	var technical: Array = []
	var widths: Array = []
	var nodes: int = 0
	var targets: int = 0
	var words: int = 0
	var rich: int = 0
	for page_v in pages:
		var page: Dictionary = page_v as Dictionary
		var root: Node = page["node"] as Node
		var name: String = str(page["name"])
		var seen: Dictionary = {"nodes": 0, "targets": 0, "words": 0, "rich": 0}
		_walk(root, name, seen, mouse, small, undeclared, technical)
		nodes += int(seen["nodes"])
		targets += int(seen["targets"])
		words += int(seen["words"])
		rich += int(seen["rich"])
		var wanted: Vector2 = (root as Control).get_combined_minimum_size()
		widths.append({
			"name": name, "w": wanted.x, "h": wanted.y, "nodes": int(seen["nodes"]),
			"where": str(page.get("where", "")),
		})

	# **Una sonda che torna zero e' quasi sempre cieca lei** (regola di casa).
	# I suggerimenti del mouse ci sono, si contano a mano nei sorgenti: se
	# questa lista esce vuota non e' che la pagina e' guarita.
	if nodes < 50:
		printerr("la sonda ha visto %d nodi in tutto: non e' una pagina" % nodes)
		quit(4)
		return

	var lines: Array = _write(
		nodes, targets, words, rich, mouse, small, undeclared, technical, widths
	)
	var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		printerr("non riesco a scrivere %s" % out_path)
		quit(5)
		return
	file.store_string("\n".join(PackedStringArray(lines)) + "\n")
	file.close()
	print("Scritto: %s  (%d nodi, %d bersagli, %d parole)" % [
		out_path, nodes, targets, words
	])
	quit(0)


## I pannelli che si costruiscono da soli, con una partita vera dietro. Ognuno
## dice **dove sta** nella pagina di D-444: `tavolo` (in colonna a sinistra, con
## la colonna delle scelte accanto), `centro` (al posto del tavolo, uno alla
## volta), `sotto` (la mano, tutta la larghezza), `stanza` (la pagina della
## stanza, prima di sedersi: non e' la pagina di gioco).
func _build(session: RefCounted, data: RefCounted, viewer: String) -> Array:
	var out: Array = []

	var status: Node = StatusPanel.new()
	_seat(status)
	status.render(session, viewer)
	out.append({"name": "colonna di stato", "node": status, "where": "centro"})

	var map: Node = MapView.new()
	_seat(map)
	# La mappa dispone le tessere secondo lo spazio che ha: la misura di un
	# tablet meno la colonna delle scelte, come nella pagina vera.
	(map as Control).size = Vector2(TAVOLETTA - 240.0, 520.0)
	map.render(session, viewer)
	out.append({"name": "mappa", "node": map, "where": "tavolo"})

	# **Il tabellone si guarda aperto.** `render` esce subito se non c'e' un
	# Consiglio in corso, e una sonda che guarda un tabellone chiuso direbbe che
	# la cosa centrale del gioco non ha nemmeno un bersaglio.
	_open_a_council(session)
	var board: Node = ConfluenceBoard.new()
	_seat(board)
	board.render(session, viewer)
	out.append({"name": "il Consiglio", "node": board, "where": "centro"})

	var table: Node = TableView.new()
	_seat(table)
	# Largo come la stanza che lo ospita: senza una misura la mappa che ha
	# dentro si stringe a un raggio minimo, e i suoi posti risultano stretti
	# quanto un capello — un difetto della sonda, non della pagina.
	(table as Control).size = Vector2(TAVOLETTA, 520.0)
	table.render(session)
	out.append({"name": "il tavolo", "node": table, "where": "stanza"})

	var decks: Node = ThemeDecksView.new()
	_seat(decks)
	# **Larga come una striscia** (D-444): sul tavolo i sei mazzetti stanno in
	# fila lungo il bordo alto della mappa, e la vista dispone i suoi nodi
	# secondo lo spazio che ha. Senza una misura si disporrebbe come un
	# riquadro vuoto, che non e' la pagina.
	(decks as Control).size = Vector2(TAVOLETTA - 240.0, 96.0)
	decks.render(session)
	out.append({"name": "i mazzi dei Temi", "node": decks, "where": "tavolo"})

	var seats: Node = SeatsStrip.new()
	_seat(seats)
	seats.render(session, viewer)
	out.append({"name": "chi siede", "node": seats, "where": "tavolo"})

	var help: Node = HelpPanel.new()
	_seat(help)
	help.render(data, "CHR_00")
	out.append({"name": "la pagina d'aiuto", "node": help, "where": "centro"})

	var hand: Node = HandView.new()
	_seat(hand)
	hand.render(session, viewer)
	out.append({"name": "la mano", "node": hand, "where": "sotto"})

	return out


## **`_ready()` non gira per un nodo costruito fuori dall'albero** — e' una
## delle trappole scritte in CLAUDE.md, e questa sonda ci e' cascata al primo
## giro: 118 nodi in tutto, cioe' pannelli quasi vuoti. Seduti nell'albero,
## diventano la pagina vera.
func _seat(node: Node) -> void:
	root.add_child(node)


## Un Consiglio vero, aperto sulla prima domanda che il tavolo sa aprire.
static func _open_a_council(session: RefCounted) -> void:
	for tension_id in session.world["tensions"]:
		if not session.confluence.open(str(tension_id), {"kind": "THRESHOLD"}):
			continue
		var options: Array = session.confluence.available_propositions()
		if options.is_empty():
			continue
		session.confluence.set_proposition(str((options[0] as Dictionary)["id"]))
		return


func _walk(
	node: Node, page: String, seen: Dictionary,
	mouse: Array, small: Array, undeclared: Array, technical: Array
) -> void:
	seen["nodes"] = int(seen["nodes"]) + 1
	if node is Control:
		var control: Control = node as Control
		var tip: String = str(control.tooltip_text).strip_edges()
		if tip.length() > 3:
			seen["words"] = int(seen["words"]) + 1
			if not _said_out_loud(control, tip):
				mouse.append({"page": page, "who": _who(control), "text": tip})
	if node is BaseButton or _is_slot(node):
		seen["targets"] = int(seen["targets"]) + 1
		var wanted: Vector2 = (node as Control).get_combined_minimum_size()
		var label: String = _who(node)
		if wanted.x <= 0.0 or wanted.y <= 0.0:
			undeclared.append({"page": page, "who": label})
		elif wanted.x < DITO or wanted.y < DITO:
			small.append({
				"page": page, "who": label,
				"size": "%.0f × %.0f" % [wanted.x, wanted.y],
			})
	# **Il testo ricco questa sonda non lo sa leggere, e lo dichiara.**
	# `RichTextLabel` riempito con `append_text` tiene le parole in un albero
	# che, senza un vero server di caratteri, headless resta vuoto: provato,
	# `text` e `get_parsed_text()` tornano tutti e due lunghezza zero. Contarlo
	# come «nessuna parola» sarebbe la bugia peggiore di tutte — quella di una
	# sonda cieca che sembra pulita. Si contano i pannelli, non le parole.
	if node is RichTextLabel:
		seen["rich"] = int(seen["rich"]) + 1
	var text: String = ""
	if node is Label:
		text = str((node as Label).text).strip_edges()
	if text != "":
		seen["words"] = int(seen["words"]) + 1
		for riga in text.split("\n", false):
			if _is_technical(str(riga)):
				technical.append({"page": page, "text": str(riga).strip_edges()})
				break
	for child in node.get_children():
		_walk(child, page, seen, mouse, small, undeclared, technical)


## Un posto dove una carta puo' cadere e' un bersaglio quanto un bottone.
static func _is_slot(node: Node) -> bool:
	return node.has_method("light") or node.get("field") != null and node.get("key") != null


## Il suggerimento e' **anche** scritto sotto gli occhi? Basta la prima frase:
## un testo che si ripete parola per parola non capita, e non e' quello che si
## sta cercando — si cerca se, tolto il mouse, resta qualcosa che lo dica.
static func _said_out_loud(control: Control, tip: String) -> bool:
	var head: String = tip.split("\n")[0].split(":")[0].strip_edges()
	if head.length() < 4:
		return true
	var said: Array = []
	_labels(control, said)
	for line in said:
		if str(line).contains(head):
			return true
	return false


static func _labels(node: Node, into: Array) -> void:
	if node is Label:
		into.append(str((node as Label).text))
	if node is RichTextLabel:
		into.append(str((node as RichTextLabel).text))
	if node is BaseButton and node.get("text") != null:
		into.append(str(node.get("text")))
	for child in node.get_children():
		_labels(child, into)


## Una parola tecnica e' un id, uno slot o un **segno crudo** finito sotto gli
## occhi di chi gioca: `REG_VALLE_VERDE`, `$rival`, `condition:unrest`.
##
## I segni non si riconoscono a naso: **si chiedono al dizionario**. Il primo
## giro li indovinava con una regola sui due punti, e prendeva per un segno
## `«quello che la tua casa si porta addosso: fama»* — italiano, non dati. Un
## elenco copiato accanto a uno che esiste e' la trappola gia' pagata quattro
## volte in questo progetto.
func _is_technical(text: String) -> bool:
	if text.contains("$"):
		return true
	for word in text.split(" ", false):
		var bare: String = str(word).strip_edges()
		for coda in [",", ".", ":", ";", ")", "»", "\"", "'"]:
			bare = bare.trim_suffix(str(coda))
		for testa in ["(", "«", "\"", "`"]:
			bare = bare.trim_prefix(str(testa))
		if bare.length() < 4:
			continue
		if _dictionary.has(bare):
			return true
		if bare == bare.to_upper() and bare.contains("_") and not bare.contains(" "):
			return true
	return false


static func _who(node: Node) -> String:
	if node is Label:
		return str((node as Label).text).substr(0, 40)
	if node is BaseButton and str(node.get("text")) != "":
		return str(node.get("text")).substr(0, 40)
	if node.get("key") != null and str(node.get("key")) != "":
		return "posto: %s" % str(node.get("key"))
	return node.get_class()


func _write(
	nodes: int, targets: int, words: int, rich: int,
	mouse: Array, small: Array, undeclared: Array, technical: Array, widths: Array
) -> Array:
	var lines: Array = []
	lines.append("# ECHOES — cosa la pagina dice, e con quale dito")
	lines.append("")
	lines.append("<!-- GENERATO da `tools/run_page_survey.sh` — non si corregge qui. -->")
	lines.append("")
	lines.append("La voce [65](ISSUES.md#65) dice *«tutta la pagina dell'app va rivista»*, e")
	lines.append("accanto porta la ragione per cui e' rimasta ferma: **nessuna sonda tocca")
	lines.append("questa pagina**, quindi ogni giro costa il pomeriggio di una persona con")
	lines.append("l'app in mano. Questa e' quella sonda.")
	lines.append("")
	lines.append("Misura le quattro cose che i sei difetti trovati su un tablet avevano in")
	lines.append("comune, cosi' ogni passata si giudica coi numeri. La rivista l'ha scelta il")
	lines.append("committente — [D-427](DECISIONS.md#d-427), la terza: *l'app mostra il")
	lines.append("tavolo, non lo stato* — ed e' fatta in [D-444](DECISIONS.md#d-444): da li'")
	lines.append("questa pagina dice **se la pagina la segue**.")
	lines.append("")
	lines.append("**Si misura quello che la pagina chiede, non quello che ottiene**: senza")
	lines.append("una finestra vera non c'e' un passaggio di disposizione. Un bersaglio che")
	lines.append("non dichiara una misura non e' per questo grande — e' *non dichiarato*, e")
	lines.append("sta in una colonna sua.")
	lines.append("")
	lines.append("| | |")
	lines.append("|---|---|")
	lines.append("| pannelli guardati | %d |" % widths.size())
	lines.append("| nodi in tutto | %d |" % nodes)
	lines.append("| testi sotto gli occhi | %d |" % words)
	lines.append("| *piu' %d blocchi di testo ricco che questa sonda non sa leggere* | |" % rich)
	lines.append("| **testi che vivono solo nel suggerimento del mouse** | **%d** |" % mouse.size())
	lines.append("| bersagli che si toccano | %d |" % targets)
	lines.append("| **piu' stretti di un dito (%d px)** | **%d** |" % [int(DITO), small.size()])
	lines.append("| di cui non dichiarano nessuna misura | %d |" % undeclared.size())
	lines.append("| **parole tecniche sotto gli occhi** | **%d** |" % technical.size())
	lines.append("")
	lines.append("**Il testo ricco resta fuori, e va detto.** Un `RichTextLabel`")
	lines.append("riempito con `append_text` tiene le parole in un albero che, senza un vero")
	lines.append("server di caratteri, headless resta vuoto: provato, `text` e")
	lines.append("`get_parsed_text()` tornano tutti e due lunghezza zero. Sono la pagina")
	lines.append("d'aiuto e parte del tabellone del Consiglio. Contarli come «nessuna")
	lines.append("parola» sarebbe la bugia peggiore: una sonda cieca che sembra pulita.")
	lines.append("")
	lines.append("**I bersagli sono un pavimento, non un totale.** La cornice —")
	lines.append("`%s` — non si guarda da qui: nomina un" % CORNICE_FUORI)
	lines.append("autoload, e una sonda lanciata con `--script` non ne ha, quindi il file")
	lines.append("non compila. I bottoni degli strumenti e il menu restano fuori dal conto,")
	lines.append("e chiuderli e' il primo pezzo di lavoro che questa misura si porta dietro.")
	lines.append("")

	lines.append("## 1. I testi che vivono nel suggerimento del mouse")
	lines.append("")
	lines.append("Il difetto che [D-242](DECISIONS.md#d-242) ha trovato su un tablet: col")
	lines.append("dito non c'e' nessun «sopra» da cui far uscire un suggerimento, quindi")
	lines.append("quel testo per meta' dei giocatori **non esiste**. Qui ci sono quelli che")
	lines.append("nessuna scritta accanto ripete.")
	lines.append("")
	if mouse.is_empty():
		lines.append("Nessuno: tutto quello che il mouse direbbe e' scritto anche sotto.")
	else:
		lines.append("| pannello | dove | cosa direbbe |")
		lines.append("|---|---|---|")
		for entry_v in mouse:
			var entry: Dictionary = entry_v as Dictionary
			lines.append("| %s | %s | %s |" % [
				str(entry["page"]), str(entry["who"]),
				str(entry["text"]).replace("\n", " ").substr(0, 90),
			])
	lines.append("")

	lines.append("## 2. I bersagli che un dito non prende")
	lines.append("")
	lines.append("Sotto i %d px un dito comincia a sbagliare, ed e' la stessa misura che" % int(DITO))
	lines.append("[D-243](DECISIONS.md#d-243) ha gia' usato per le carte in mano.")
	lines.append("")
	if small.is_empty():
		lines.append("Nessuno fra quelli che dichiarano una misura.")
	else:
		lines.append("| pannello | bersaglio | chiede |")
		lines.append("|---|---|---|")
		for entry_v in small:
			var entry: Dictionary = entry_v as Dictionary
			lines.append("| %s | %s | %s |" % [
				str(entry["page"]), str(entry["who"]), str(entry["size"]),
			])
	lines.append("")
	lines.append("**E %d bersagli non dichiarano niente.** Non vuol dire che siano" % undeclared.size())
	lines.append("piccoli: vuol dire che la loro misura la decide la disposizione, e")
	lines.append("nessuno l'ha scritta. Su una finestra stretta e' li' che si stringono.")
	lines.append("")

	lines.append("## 3. Le parole tecniche sotto gli occhi")
	lines.append("")
	lines.append("Un id, uno slot o un segno crudo arrivato fino allo schermo: `$rival`,")
	lines.append("`REG_VALLE_VERDE`, `condition:unrest`. Il committente lo dice dalla 63 —")
	lines.append("*«carte che spiegano esattamente cosa fanno e non tag o testi tecnici»*.")
	lines.append("")
	if technical.is_empty():
		lines.append("Nessuna: tutto quello che si legge e' in italiano da giocatore.")
	else:
		lines.append("| pannello | cosa si legge |")
		lines.append("|---|---|")
		for entry_v in technical:
			var entry: Dictionary = entry_v as Dictionary
			lines.append("| %s | `%s` |" % [
				str(entry["page"]), str(entry["text"]).replace("\n", " ").substr(0, 80),
			])
	lines.append("")

	lines.append("## 4. Quanto la pagina chiede")
	lines.append("")
	lines.append("Da [D-444](DECISIONS.md#d-444) la pagina e' **il tavolo, e una cosa alla")
	lines.append("volta**: a sinistra il tavolo — i mazzetti, la mappa, chi siede, il")
	lines.append("racconto — e accanto una colonna di **%d px** con quello che serve per" % int(COLONNA))
	lines.append("decidere adesso. La colonna di stato, il Consiglio e l'aiuto non stanno")
	lines.append("piu' intorno al tavolo: si aprono **al suo posto**, uno alla volta. La")
	lines.append("mano sta sotto, per tutta la larghezza. Il tablet e' largo **%d px**." % int(TAVOLETTA))
	lines.append("")
	lines.append("Una colonna fatta per scorrere chiede **tutta la sua lunghezza**: la")
	lines.append("colonna d'altezza si legge cosi', non come «quanto e' alto lo schermo».")
	lines.append("Un pannello che *si adatta* non dichiara niente perche' prende lo spazio")
	lines.append("che resta: e' la mappa, ed e' giusto che sia lei.")
	lines.append("")
	lines.append("| pannello | dove sta | nodi | larghezza chiesta | altezza chiesta |")
	lines.append("|---|---|---|---|---|")
	var tavolo: float = 0.0
	var centro: float = 0.0
	var centro_chi: String = ""
	var sotto: float = 0.0
	var painted: Array = []
	for entry_v in widths:
		var entry: Dictionary = entry_v as Dictionary
		var name: String = str(entry["name"])
		var where: String = str(entry["where"])
		var w: float = float(entry["w"])
		if _paints(entry):
			painted.append(name)
			lines.append("| %s | %s | %d | *dipinge: non lo dichiara* | |" % [
				name, _where_said(where), int(entry["nodes"]),
			])
			continue
		if w <= 0.0:
			lines.append("| %s | %s | %d | *si adatta* | |" % [
				name, _where_said(where), int(entry["nodes"]),
			])
			continue
		lines.append("| %s | %s | %d | %.0f | %.0f |" % [
			name, _where_said(where), int(entry["nodes"]), w, float(entry["h"]),
		])
		match where:
			"tavolo":
				tavolo = maxf(tavolo, w)
			"centro":
				if w > centro:
					centro = w
					centro_chi = name
			"sotto":
				sotto = maxf(sotto, w)
	lines.append("")
	if not painted.is_empty():
		lines.append("**%d pannelli tornano a dipingere**: %s. Una scritta dipinta non ha" % [
			painted.size(), ", ".join(PackedStringArray(painted)),
		])
		lines.append("una misura, non e' un bersaglio, e nessun lettore di schermo la vede. Da")
		lines.append("D-444 quello che si legge e si tocca e' un nodo: questo e' un passo indietro.")
		lines.append("")
	var pagina: float = tavolo + COLONNA + MARGINI
	var posto: float = TAVOLETTA - COLONNA - MARGINI
	var sotto_posto: float = TAVOLETTA - (MARGINI - 12.0)
	lines.append("Tre misure, una per posto:")
	lines.append("")
	lines.append("| | chiede | ha | |")
	lines.append("|---|---|---|---|")
	lines.append("| **il tavolo con la colonna accanto** — il piu' largo dei suoi pannelli (%.0f), la colonna (%d), i margini (%d) | **%.0f** | %.0f | %s |" % [
		tavolo, int(COLONNA), int(MARGINI), pagina, TAVOLETTA, _fits(pagina, TAVOLETTA),
	])
	lines.append("| **al centro, uno alla volta** — il piu' largo e' «%s» | **%.0f** | %.0f | %s |" % [
		centro_chi, centro, posto, _fits(centro, posto),
	])
	lines.append("| **sotto, la mano** | **%.0f** | %.0f | %s |" % [
		sotto, sotto_posto, _fits(sotto, sotto_posto),
	])
	lines.append("")
	if pagina <= TAVOLETTA and centro <= posto and sotto <= sotto_posto:
		lines.append("**La pagina sta dentro il tablet**, in tutti e tre i posti. Fino a D-444")
		lines.append("chiedeva 788 px in fila senza contare la mappa: non e' che i pannelli si")
		lines.append("sono stretti, e' che non stanno piu' in fila.")
	else:
		lines.append("**La pagina non sta nel tablet**, e la riga col ✗ dice dove. Non si")
		lines.append("ripara stringendo un pannello: si guarda cosa ci sta accanto.")
	return lines


## Dove sta un pannello, detto a parole.
static func _where_said(where: String) -> String:
	match where:
		"tavolo":
			return "sul tavolo"
		"centro":
			return "al centro, uno alla volta"
		"sotto":
			return "sotto, tutta la larghezza"
		"stanza":
			return "nella stanza, prima di sedersi"
	return where


static func _fits(asked: float, had: float) -> String:
	if asked <= had:
		return "✓ ne avanzano %.0f" % (had - asked)
	return "✗ ne mancano %.0f" % (asked - had)

## Un pannello che dipinge invece di costruire: nessuna misura dichiarata e
## nessun figlio. Non e' vuoto — e' fatto in un altro modo.
static func _paints(entry: Dictionary) -> bool:
	return float(entry["w"]) <= 0.0 and int(entry["nodes"]) <= 2
