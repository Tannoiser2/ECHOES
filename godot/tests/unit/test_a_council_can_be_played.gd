extends "res://tests/test_case.gd"
## **Il Consiglio si puo' giocare** (ISSUES 73).
##
## `test_a_turn_can_be_played` copre la fase delle Azioni: quando tocca a una
## persona, sullo schermo c'e' una strada visibile e le carte si prendono.
## Restava scoperto **il giro del Consiglio visto da chi siede**, e la voce lo
## diceva per nome: *«la proposta, i benefici comprati, il prezzo scelto, gli
## impegni. Ognuno e' una domanda che passa dallo stesso `io`, e ognuno puo'
## essere morto senza che un cancello se ne accorga.»*
##
## Il buco era proprio questo: fra una prova del motore, che chiede al
## `PolicyDecider` (che non ha mani), e una prova dello schermo, che disegna
## senza che nessuno chieda niente, ci stava un Consiglio che non si poteva
## giocare — verde da tutt'e due le parti.
##
## Qui ogni prova parte **dal decider** — lo stesso che guida il terminale — e
## finisce **su quello che si puo' toccare**. E chiede due cose a ogni passo:
##
##   1. che ci sia almeno un bottone (una domanda senza risposte visibili e' un
##      Consiglio fermo);
##   2. che nessun bottone parli per id (`TEN_`, `P_`, `CNS_`, `B_`, `C_`) —
##      *«carte che spiegano esattamente cosa fanno e non tag o testi tecnici»*,
##      parola del committente in [ISSUES 63](../../docs/ISSUES.md#63).

const GameScreen := preload("res://ui/game_screen.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")

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
## scheda, le proposte e le caselle sono quelle che il tavolo ha davanti.
func _open_a_council() -> Dictionary:
	for tension_id in session.world["tensions"]:
		var context: Dictionary = session.confluence.open(
			str(tension_id), {"kind": "THRESHOLD", "entity_id": ""}
		)
		if not context.is_empty():
			return context
	return {}


## **Le scelte di un Consiglio non stanno nella colonna: stanno sulla plancia.**
##
## `GameScreen.ask()` lo dice in una riga — *«se il Consiglio e' aperto, la
## domanda va al `_board`»* — ed e' giusto cosi': la scelta vive accanto alla
## domanda a cui risponde. La prima stesura di queste prove guardava
## `_buttons` e trovava **zero** su tutt'e quattro i passi: **era la prova
## cieca, non lo schermo muto** — la trappola scritta in CLAUDE.md, presa in
## pieno.
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


## Le due domande che si fanno a ogni passo, in un posto solo.
func _the_step_can_be_answered(screen: Node, passo: String) -> void:
	var said: Array = _buttons(screen)
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


## **Il proponente vede cosa sta proponendo, e cosa lascera' al mondo.**
##
## E' la decisione centrale del gioco (D-233): senza la riga «se passa», si
## sceglie fra tre frasi belle senza sapere quale alza una torre e quale lascia
## una cicatrice.
func test_the_proponent_can_choose_a_proposition() -> void:
	var context: Dictionary = _open_a_council()
	assert_false(context.is_empty(), "un Consiglio si apre")
	var proponent: String = str(context["proponent"])
	var options: Array = session.confluence.available_propositions()
	assert_true(options.size() > 0, "e ha delle proposte: %d" % options.size())

	var screen: Node = _screen(proponent)
	var decider: RefCounted = SeatDecider.new([proponent], null)
	decider.io = screen
	# Senza `await`: la chiamata corre fino a dove lo schermo aspetta, ed e'
	# esattamente li' che si guarda.
	decider.choose_proposition(context, options, session)

	_the_step_can_be_answered(screen, "Cosa proponi?")
	var column: String = " · ".join(PackedStringArray(_buttons(screen)))
	assert_true(
		column.contains("Se passa") or column.contains("Non lascia segni"),
		"e ogni proposta dice cosa lascia: %s" % column
	)
	_finish(screen)


## **Chi siede puo' dichiarare la sua posizione**, e le pose sono quattro
## parole, non quattro sigle.
func test_a_seat_can_declare_its_stance() -> void:
	var context: Dictionary = _open_a_council()
	assert_false(context.is_empty(), "un Consiglio si apre")
	session.confluence.set_proposition(
		str((session.confluence.available_propositions()[0] as Dictionary)["id"])
	)
	var voter: String = ""
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(context["proponent"]):
			voter = str(entity_id)
			break
	assert_ne(voter, "", "c'e' qualcuno che non ha proposto")

	var screen: Node = _screen(voter)
	var decider: RefCounted = SeatDecider.new([voter], null)
	decider.io = screen
	decider.choose_stance(voter, context, session)

	_the_step_can_be_answered(screen, "Che posizione prendi?")
	_finish(screen)


## **Il proponente compra** (D-280): le caselle della carta si toccano, e
## dicono cosa fanno con la parola stampata.
func test_the_proponent_can_buy_what_the_card_sells() -> void:
	var context: Dictionary = _open_a_council()
	assert_false(context.is_empty(), "un Consiglio si apre")
	session.confluence.set_proposition(
		str((session.confluence.available_propositions()[0] as Dictionary)["id"])
	)
	var menu: Array = session.confluence.benefit_menu()
	if menu.is_empty():
		# La carta pescata puo' non avere caselle vive adesso (D-306). Non e' un
		# difetto dello schermo, e chiamarlo tale sarebbe una prova bugiarda.
		return
	var proponent: String = str(context["proponent"])

	var screen: Node = _screen(proponent)
	var decider: RefCounted = SeatDecider.new([proponent], null)
	decider.io = screen
	decider.choose_benefits(proponent, context, menu, session)

	_the_step_can_be_answered(screen, "Cosa ottieni?")
	var column: String = " · ".join(PackedStringArray(_buttons(screen)))
	assert_true(column.contains("Basta cosi"), "e si puo' smettere di comprare: %s" % column)
	_finish(screen)


## **E gli Asset si impegnano al voto dallo schermo**, che e' la seconda meta'
## dell'economia: si spende per fare, o si tiene per votare.
func test_a_seat_can_commit_assets_to_the_vote() -> void:
	var context: Dictionary = _open_a_council()
	assert_false(context.is_empty(), "un Consiglio si apre")
	session.confluence.set_proposition(
		str((session.confluence.available_propositions()[0] as Dictionary)["id"])
	)
	var voter: String = str(context["proponent"])
	var limit: int = session.confluence.max_commit_for(voter)
	if limit <= 0:
		return

	var screen: Node = _screen(voter)
	var decider: RefCounted = SeatDecider.new([voter], null)
	decider.io = screen
	decider.choose_commit(voter, context, limit, session)

	_the_step_can_be_answered(screen, "Cosa impegni?")
	_finish(screen)
