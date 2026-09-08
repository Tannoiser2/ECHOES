extends "res://tests/test_case.gd"
## **Il Consiglio si puo' giocare** (ISSUES 73), a due domande (D-467, D-472).
##
## `test_a_turn_can_be_played` copre la fase delle Azioni: quando tocca a una
## persona, sullo schermo c'e' una strada visibile e le carte si prendono.
## Restava scoperto **il giro del Consiglio visto da chi siede**, e la voce lo
## diceva per nome: ogni passo *«e' una domanda che passa dallo stesso `io`, e
## ognuno puo' essere morto senza che un cancello se ne accorga.»*
##
## Il buco era proprio questo: fra una prova del motore, che chiede al
## `PolicyDecider` (che non ha mani), e una prova dello schermo, che disegna
## senza che nessuno chieda niente, ci stava un Consiglio che non si poteva
## giocare — verde da tutt'e due le parti.
##
## I passi sono quelli di D-472: la domanda da porre, la prima pedina di chi
## propone, la parte da prendere con la casella da posare, il rilancio o il
## passo, le carte da impegnare, cosa salvare se cade. I passi di D-280 — la
## proposta, i benefici comprati coi gettoni, il prezzo scelto dagli
## avversari, la controproposta, i costi del rivendicante — sono usciti dal
## motore e da qui.
##
## Qui ogni prova parte **dal decider** — lo stesso che guida il terminale — e
## finisce **su quello che si puo' toccare**. E chiede due cose a ogni passo:
##
##   1. che ci sia almeno un bottone (una domanda senza risposte visibili e' un
##      Consiglio fermo);
##   2. che nessun bottone parli per id (`TEN_`, `Q_`, `CNS_`, `B_`, `C_`) —
##      *«carte che spiegano esattamente cosa fanno e non tag o testi tecnici»*,
##      parola del committente in [ISSUES 63](../../docs/ISSUES.md#63).

const GameScreen := preload("res://ui/game_screen.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const ConfluenceBoard := preload("res://ui/confluence_board.gd")

## Gli id che al tavolo non si leggono mai. `AST_` sta gia' in
## `test_a_turn_can_be_played`; qui contano quelli del Consiglio.
const IDS: Array = ["TEN_", "CNF_", "Q_", "P_", "CNS_", "B_", "C_", "ENT_", "REG_"]

var _mine: RefCounted


func before_each() -> void:
	if _mine != null:
		return
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(_mine.setup("CHR_00", seats, 4242), "e l'anno si apre")
	for effect in _mine.factory_setup_effects():
		_mine.applier.apply(effect)
	_mine.world["act"] = 1
	_mine.world["round"] = 1
	session = _mine


## Uno schermo costruito e non avviato, con dentro la partita: `_ready()`
## aprirebbe il menu, che chiede e aspetta.
func _screen(seat: String) -> Node:
	var screen: Node = GameScreen.new()
	screen.call("_build")
	screen.set("_session", session)
	screen.set("_viewer", seat)
	return screen


## **Un Consiglio vero, aperto sulla partita vera.** Non una Confluence
## fabbricata: si prende la prima Tensione che il Consiglio sa aprire, cosi' la
## scheda, le domande e le caselle sono quelle che il tavolo ha davanti.
func _open_a_council() -> Dictionary:
	for tension_id in session.world["tensions"]:
		var context: Dictionary = session.confluence.open(
			str(tension_id), {"kind": "THRESHOLD", "entity_id": ""}
		)
		if not context.is_empty():
			return context
	return {}


## **Un Consiglio che soddisfa una condizione**, cercato invece che sperato.
##
## Regola di casa: *«una prova che cerca una condizione fra i dati spediti puo'
## smettere di provare senza dirlo, se quella condizione sparisce.
## Fabbricatela.»* Qui la condizione non si fabbrica — sarebbe un Consiglio
## finto — ma si **cerca su tutte le Tensioni in gioco**, e se non c'e' la prova
## lo dice invece di passare in silenzio. Il Consiglio si apre gia' con le
## due parti (D-470): non c'e' niente da scegliere prima di guardarlo.
func _a_council_where(condizione: Callable) -> Dictionary:
	for tension_id in session.world["tensions"]:
		var aperto: Dictionary = session.confluence.open(
			str(tension_id), {"kind": "THRESHOLD", "entity_id": ""}
		)
		if aperto.is_empty():
			continue
		if condizione.call(aperto):
			return aperto
	return {}


## Il primo seggio che non propone.
func _someone_else(context: Dictionary) -> String:
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(context["proponent"]):
			return str(entity_id)
	return ""


## I benefici liberi della parte A: la prima pedina di chi propone (D-470).
func _first_benefits() -> Array:
	var out: Array = []
	for entry in session.confluence.box_menu("A"):
		if str((entry as Dictionary)["list"]) == "benefits":
			out.append(entry)
	return out


## **Le scelte di un Consiglio non stanno nella colonna: stanno sulla plancia.**
##
## `GameScreen.ask()` lo dice in una riga — *«se il Consiglio e' aperto, la
## domanda va al `_board`»* — ed e' giusto cosi': la scelta vive accanto alla
## domanda a cui risponde. La prima stesura di queste prove guardava la colonna
## e trovava **zero** su tutt'e quattro i passi: **era la prova cieca, non lo
## schermo muto** — la trappola scritta in CLAUDE.md, presa in pieno.
##
## Una scelta del Consiglio e' disegnata come una carta (D-233): un `Button`
## con dentro delle etichette, non un bottone con una frase. Il testo si legge
## da quelle.
func _buttons(screen: Node) -> Array:
	var said: Array = []
	for child in screen.get("_board").get("_choices").get_children():
		var testo: String = _text_of(child)
		if testo != "":
			said.append(testo)
	return said


## Il testo di una carta-scelta, ovunque stia: sul bottone o nelle etichette
## che gli stanno sopra.
func _text_of(node: Node) -> String:
	var pezzi: Array = []
	if node is Button and str((node as Button).text) != "":
		pezzi.append(str((node as Button).text))
	for child in node.get_children():
		if child is Label:
			pezzi.append(str((child as Label).text))
		elif child is RichTextLabel:
			pezzi.append(str((child as RichTextLabel).text))
		else:
			var dentro: String = _text_of(child)
			if dentro != "":
				pezzi.append(dentro)
	return "\n".join(PackedStringArray(pezzi))


## **E da D-480 le caselle non stanno sotto: stanno sulla carta.**
##
## Quello che si tocca a un passo del Consiglio sono le carte-scelta **piu' le
## caselle accese** sulla carta girata: una casella offerta si accende e si
## prende toccandola, e non si ristampa sotto. Una prova che guardasse solo le
## carte-scelta troverebbe zero dove lo schermo offre tutto — la stessa trappola
## di prima, dall'altra parte.
func _touchable(screen: Node) -> Array:
	var said: Array = _buttons(screen)
	for row in screen.get("_board").get("_face").get_children():
		if (row as Node).has_meta("offered") and bool((row as Node).get_meta("offered")):
			said.append(_text_of(row))
	return said


## Le caselle accese, e basta: il testo stampato di ognuna.
func _lit_boxes(screen: Node) -> Array:
	var said: Array = []
	for row in screen.get("_board").get("_face").get_children():
		if (row as Node).has_meta("offered") and bool((row as Node).get_meta("offered")):
			said.append(_text_of(row))
	return said


## Le due domande che si fanno a ogni passo, in un posto solo.
func _the_step_can_be_answered(screen: Node, passo: String) -> void:
	var said: Array = _touchable(screen)
	assert_true(said.size() > 0, "«%s» offre qualcosa da toccare" % passo)
	var column: String = " · ".join(PackedStringArray(said))
	for id in IDS:
		assert_false(
			column.contains(str(id)),
			"«%s» non parla per id (%s): %s" % [passo, str(id), column]
		)


func _finish(screen: Node) -> void:
	screen.emit_signal("picked", -1)
	screen.free()


## **La domanda si sceglie, quando la carta ne offre piu' d'una.**
##
## Il passo B esiste solo se la Tensione ha aperto piu' di una domanda: quando
## ce n'e' una sola il Consiglio non chiede niente, ed e' giusto. La prova si
## cerca il caso invece di sperarlo — **una prova che smette di provare
## quando i dati cambiano non lo dice** (CLAUDE.md).
func test_the_proponent_can_choose_the_question() -> void:
	# Le domande si leggono **dopo** la ricerca: una lambda cattura per valore
	# (CLAUDE.md), e riempirle dentro la condizione lascerebbe vuota la lista
	# qui fuori — e un decider con niente da offrire non chiede niente.
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool: return session.confluence.available_questions().size() > 1
	)
	assert_false(context.is_empty(), "una carta con due domande aperte esiste")
	var options: Array = session.confluence.available_questions()
	assert_true(options.size() > 1, "e le sue domande sono piu' d'una: %d" % options.size())

	var screen: Node = _screen(str(context["proponent"]))
	var decider: RefCounted = SeatDecider.new([str(context["proponent"])], null)
	decider.io = screen
	# Senza `await`: la chiamata corre fino a dove lo schermo aspetta, ed e'
	# esattamente li' che si guarda.
	decider.choose_question(context, options, session)

	_the_step_can_be_answered(screen, "Quale domanda poni?")
	assert_eq(_buttons(screen).size(), options.size() + 1, "una carta per domanda, piu' «lascia decidere»")
	_finish(screen)


## **Chi propone posa la prima pedina, gratis** (D-470): un beneficio libero
## della sua domanda, e la casella si legge con la parola stampata.
func test_the_proponent_puts_down_the_first_pedina() -> void:
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool: return not _first_benefits().is_empty()
	)
	assert_false(context.is_empty(), "un Consiglio con un beneficio libero per la A esiste")
	var menu: Array = _first_benefits()
	var proponent: String = str(context["proponent"])

	var screen: Node = _screen(proponent)
	var decider: RefCounted = SeatDecider.new([proponent], null)
	decider.io = screen
	decider.choose_box(proponent, context, menu, "A", session)

	_the_step_can_be_answered(screen, "Cosa posi per prima?")
	# **Le caselle si accendono sulla carta** (D-480): si contano li', non fra
	# le carte-scelta, e sono esattamente quelle che il motore ha offerto.
	var lit: Array = _lit_boxes(screen)
	assert_eq(lit.size(), menu.size(), "una casella accesa per ogni beneficio libero della A")
	var column: String = " · ".join(PackedStringArray(lit))
	for voice in menu:
		assert_true(
			column.contains(str((voice as Dictionary).get("text", ""))),
			"«%s» si tocca sulla carta: %s" % [str((voice as Dictionary)["id"]), column]
		)
	_finish(screen)


## **Chi siede prende parte, e posa** (D-470): con A o con B, e la scelta e'
## la casella — la parte la dice lei, con la domanda che serve. Le pose sono
## parole, non sigle.
func test_a_seat_can_take_a_side() -> void:
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool:
			return not session.confluence.box_menu("A").is_empty() \
				and not session.confluence.box_menu("B").is_empty()
	)
	assert_false(context.is_empty(), "un Consiglio con caselle libere da tutt'e due le parti esiste")
	var voter: String = _someone_else(context)
	assert_ne(voter, "", "c'e' qualcuno che non ha proposto")
	var offer: Dictionary = {
		"A": session.confluence.box_menu("A"), "B": session.confluence.box_menu("B"),
	}

	var screen: Node = _screen(voter)
	var decider: RefCounted = SeatDecider.new([voter], null)
	decider.io = screen
	decider.choose_side(voter, context, offer, session)

	_the_step_can_be_answered(screen, "Da che parte stai, e cosa posi?")
	# Da D-480 le caselle delle due parti si accendono sulla carta, ognuna con
	# la marca della domanda che serve (D-469). La parte si dice toccandola: una
	# casella che serve tutt'e due apre le sue due scelte, «con A» e «con B».
	var lit: Array = _lit_boxes(screen)
	assert_true(lit.size() > 0, "le caselle delle due parti si accendono sulla carta")
	var column: String = " · ".join(PackedStringArray(lit))
	assert_false(column.contains("SUPPORT") or column.contains("OPPOSE"), "senza le sigle del motore")
	var shared: Array = []
	for voice in (offer["A"] as Array):
		for other in (offer["B"] as Array):
			if str((voice as Dictionary)["id"]) == str((other as Dictionary)["id"]):
				shared.append(str((voice as Dictionary)["id"]))
	var offered: Dictionary = ConfluenceBoard._boxes_offered(_subjects_of(offer))
	for voice_id in shared:
		assert_eq((offered.get(voice_id, []) as Array).size(), 2,
			"«%s» serve tutt'e due le domande e porta le sue due scelte" % voice_id)
	_finish(screen)


## Le scelte di `choose_side`, come il decider le dice al tabellone: una per
## casella e per parte.
func _subjects_of(offer: Dictionary) -> Array:
	var subjects: Array = []
	for side in ["A", "B"]:
		for voice in (offer.get(side, []) as Array):
			subjects.append({"box": str((voice as Dictionary)["id"]), "side": side})
	return subjects


## **Rilanciare o passare** (D-470): le caselle libere della propria parte, e
## «Passa» in fondo — perche' smettere e' una scelta come posare.
func test_a_seat_can_raise_or_pass() -> void:
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool: return session.confluence.box_menu("A").size() >= 2
	)
	assert_false(context.is_empty(), "un Consiglio con caselle da rilanciare esiste")
	var voter: String = _someone_else(context)
	assert_true(session.confluence.join_side(voter, "A"), "un seggio sta con A")
	var menu: Array = session.confluence.box_menu("A")

	var screen: Node = _screen(voter)
	var decider: RefCounted = SeatDecider.new([voter], null)
	decider.io = screen
	decider.choose_raise(voter, context, menu, session)

	_the_step_can_be_answered(screen, "Rilanci?")
	# Da D-480 le caselle si toccano sulla carta e «Passa» resta scritto sotto:
	# smettere non e' una casella, e senza quella carta non si potrebbe piu'
	# passare.
	assert_eq(_lit_boxes(screen).size(), menu.size(), "una casella accesa per ogni rilancio")
	var said: Array = _buttons(screen)
	assert_true(said.has("Passa"), "«Passa» resta fra le carte-scelta: %s" % str(said))
	_finish(screen)


## **E gli Asset si impegnano al voto dallo schermo**, che e' la seconda meta'
## dell'economia: si spende per fare, o si tiene per votare.
func test_a_seat_can_commit_assets_to_the_vote() -> void:
	var context: Dictionary = _a_council_where(
		func(c: Dictionary) -> bool:
			return session.confluence.max_commit_for(str(c["proponent"])) > 0
	)
	assert_false(context.is_empty(), "un Consiglio dove si puo' impegnare esiste")
	var voter: String = str(context["proponent"])
	var limit: int = session.confluence.max_commit_for(voter)

	var screen: Node = _screen(voter)
	var decider: RefCounted = SeatDecider.new([voter], null)
	decider.io = screen
	decider.choose_commit(voter, context, limit, session)

	_the_step_can_be_answered(screen, "Cosa impegni?")
	_finish(screen)


## **E chi sta con B dice cosa salverebbe da una sconfitta che non c'e' ancora**
## (§12.3). E' l'ultima decisione che le regole danno a chi gioca, e per
## duecento versioni non la chiedeva nessuno. A due domande chi si oppone e'
## chi sta con B (D-470).
func test_the_losing_side_can_name_what_it_saves() -> void:
	var context: Dictionary = _open_a_council()
	assert_false(context.is_empty(), "un Consiglio si apre")
	# La domanda si fa solo a chi si e' opposto **con almeno due carte da
	# salvare**: una carta sola non e' una scelta. Se la mano pescata non ne ha
	# due, si cerca un altro seggio invece di lasciar cadere la prova.
	var avversario: String = ""
	var tenute: Array = []
	for entity_id in session.world["turn_order"]:
		if str(entity_id) == str(context["proponent"]):
			continue
		var possibili: Array = []
		for asset_id in (session.world["entities"][str(entity_id)]["hand"] as Array):
			var asset: Dictionary = session.data.assets[str(asset_id)]
			if str(asset["discard_or_retain_rule"]) != "ALWAYS_DISCARD":
				possibili.append(str(asset_id))
		if possibili.size() >= 2:
			avversario = str(entity_id)
			tenute = [possibili[0], possibili[1]]
			break
	assert_true(tenute.size() >= 2, "un seggio con due carte da salvare esiste")
	assert_true(session.confluence.join_side(avversario, "B"), "e sta con B")
	assert_eq(session.confluence.stance_of(avversario), "OPPOSE", "che per il tavolo e' opporsi")
	var vivo: Dictionary = session.confluence.current
	vivo["commits"][avversario] = tenute

	var screen: Node = _screen(avversario)
	var decider: RefCounted = SeatDecider.new([avversario], null)
	decider.io = screen
	decider.choose_recovery(vivo, session)

	_the_step_can_be_answered(screen, "Cosa salvi se cade?")
	_finish(screen)


## **La plancia mostra quello che il Consiglio fa gia'** — il passo 1 di
## [ISSUES 80](../../docs/ISSUES.md#80).
##
## La voce, scritta in 0.1.253, diceva: *«dei benefici comprati, del prezzo,
## della pedina e della controproposta non mostra niente»*. Era vero allora.
## A due domande (D-471) quello che si vede sono **le pedine delle due
## parti** sulle caselle della carta, le liste coi titoli del cartone, cosa
## resta se vince l'una o l'altra e cosa succede se cade: questa prova lo
## tiene, cosi' la riga non torna a marcire.
func test_the_board_shows_the_pedine_of_both_sides() -> void:
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool:
			return not _first_benefits().is_empty() and not session.confluence.box_menu("B").is_empty()
	)
	assert_false(context.is_empty(), "un Consiglio con caselle vive da tutt'e due le parti esiste")
	var proponent: String = str(context["proponent"])
	var posata_a: Dictionary = _first_benefits()[0] as Dictionary
	assert_true(session.confluence.place_box(proponent, str(posata_a["id"])), "chi propone posa la prima")
	var other: String = _someone_else(context)
	assert_true(session.confluence.join_side(other, "B"), "un altro prende la B")
	var posata_b: Dictionary = session.confluence.box_menu("B")[0] as Dictionary
	assert_true(session.confluence.place_box(other, str(posata_b["id"])), "e posa una casella sua")

	var screen: Node = _screen(proponent)
	var board: Node = screen.get("_board")
	board.call("render", session, proponent)

	var scritto: String = _text_of(board.get("_face"))
	assert_true(scritto.contains("BENEFICI") and scritto.contains("COSTI"), "le liste hanno i titoli del cartone: %s" % scritto)
	assert_true(scritto.contains("SE CADE"), "e si legge cosa succede se cade")
	assert_eq(str(board.get("_consequences_title").text), "SE VINCE", "e cosa resta se vince l'una o l'altra")
	var pedine: Array = []
	for row in board.get("_face").get_children():
		if (row as Node).has_meta("marked") and bool((row as Node).get_meta("marked")):
			pedine.append(_text_of(row))
	assert_eq(pedine.size(), 2, "due pedine posate, due pedine sulla carta")
	for posata in [posata_a, posata_b]:
		var testo: String = str((posata as Dictionary)["text"])
		var trovata: bool = false
		for riga in pedine:
			if str(riga).contains(testo.substr(0, mini(24, testo.length()))):
				trovata = true
		assert_true(trovata, "la pedina sta sulla casella posata «%s»: %s" % [testo, str(pedine)])
	for id in IDS:
		assert_false(scritto.contains(str(id)), "e non parla per id (%s): %s" % [str(id), scritto])
	_finish(screen)
