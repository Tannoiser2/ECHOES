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
## **Un Consiglio che soddisfa una condizione**, cercato invece che sperato.
##
## Regola di casa: *«una prova che cerca una condizione fra i dati spediti puo'
## smettere di provare senza dirlo, se quella condizione sparisce.
## Fabbricatela.»* Qui la condizione non si fabbrica — sarebbe un Consiglio
## finto — ma si **cerca su tutte le Tensioni in gioco**, e se non c'e' la prova
## lo dice invece di passare in silenzio.
func _a_council_where(condizione: Callable) -> Dictionary:
	for tension_id in session.world["tensions"]:
		var aperto: Dictionary = session.confluence.open(
			str(tension_id), {"kind": "THRESHOLD", "entity_id": ""}
		)
		if aperto.is_empty():
			continue
		var proposte: Array = session.confluence.available_propositions()
		if proposte.is_empty():
			continue
		session.confluence.set_proposition(str((proposte[0] as Dictionary)["id"]))
		if condizione.call(aperto):
			return aperto
	return {}


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
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool: return not session.confluence.benefit_menu().is_empty()
	)
	assert_false(context.is_empty(), "un Consiglio con delle caselle vive esiste")
	var menu: Array = session.confluence.benefit_menu()
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


## **La domanda si sceglie, quando la carta ne offre piu' d'una.**
##
## Il passo B esiste solo se la Tensione ha aperto piu' di una domanda: quando
## ce n'e' una sola il Consiglio non chiede niente, ed e' giusto. La prova si
## fabbrica il caso invece di sperarlo — **una prova che smette di provare
## quando i dati cambiano non lo dice** (CLAUDE.md).
func test_the_proponent_can_choose_the_question() -> void:
	var context: Dictionary = {}
	var options: Array = []
	for tension_id in session.world["tensions"]:
		var aperto: Dictionary = session.confluence.open(
			str(tension_id), {"kind": "THRESHOLD", "entity_id": ""}
		)
		if aperto.is_empty():
			continue
		options = session.confluence.available_questions()
		if options.size() > 1:
			context = aperto
			break
	assert_false(context.is_empty(), "una carta con due domande aperte esiste")

	var screen: Node = _screen(str(context["proponent"]))
	var decider: RefCounted = SeatDecider.new([str(context["proponent"])], null)
	decider.io = screen
	decider.choose_question(context, options, session)

	_the_step_can_be_answered(screen, "Su cosa si decide?")
	_finish(screen)


## **Gli avversari scelgono in che moneta paga** (D-280, D-387): la pedina del
## prezzo si posa su una casella stampata, e la casella si legge.
func test_the_other_side_can_name_the_price() -> void:
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool:
			return not (session.confluence.price_menu()["cost"] as Array).is_empty()
	)
	assert_false(context.is_empty(), "un Consiglio con un prezzo da posare esiste")
	var menu: Array = (session.confluence.price_menu()["cost"] as Array)
	var avversario: String = ""
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(context["proponent"]):
			avversario = str(entity_id)
			break
	# **Il gettone e\' la condizione della domanda** (D-387): senza, il Consiglio
	# non chiede niente e la prova misurerebbe un silenzio legittimo.
	session.world["entities"][avversario]["claim_tokens"] = 1

	var screen: Node = _screen(avversario)
	var decider: RefCounted = SeatDecider.new([avversario], null)
	decider.io = screen
	decider.choose_cost_token(avversario, context, menu, session)

	_the_step_can_be_answered(screen, "Chi paga, e con che moneta?")
	_finish(screen)


## **E chi si oppone dice cosa salverebbe da una sconfitta che non c\'e' ancora**
## (§12.3). E' l'ultima decisione che le regole danno a chi gioca, e per
## duecento versioni non la chiedeva nessuno.
func test_the_losing_side_can_name_what_it_saves() -> void:
	var context: Dictionary = _open_a_council()
	assert_false(context.is_empty(), "un Consiglio si apre")
	session.confluence.set_proposition(
		str((session.confluence.available_propositions()[0] as Dictionary)["id"])
	)
	var avversario: String = ""
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(context["proponent"]):
			avversario = str(entity_id)
			break
	# La domanda si fa solo a chi si e' opposto **con almeno due carte da
	# salvare**: una carta sola non e' una scelta. Se la mano pescata non ne ha
	# due, si cerca un altro seggio invece di lasciar cadere la prova.
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
	var vivo: Dictionary = session.confluence.current
	vivo["stances"][avversario] = {"stance": "OPPOSE", "clause_id": ""}
	vivo["commits"][avversario] = tenute

	var screen: Node = _screen(avversario)
	var decider: RefCounted = SeatDecider.new([avversario], null)
	decider.io = screen
	decider.choose_recovery(vivo, session)

	_the_step_can_be_answered(screen, "Cosa salvi se cade?")
	_finish(screen)


## **La controproposta del RIVENDICARE** (D-268), che e' la strada piu' battuta
## di tutte: su cento anni le prese di parola si spendono qui **153 volte su
## 204** ([D-404](../../docs/DECISIONS.md#d-404)). Chi ha il diritto sceglie fra
## tenerselo, prendersi la pedina del prezzo, o rivendicare una casella che il
## proponente ha appena comprato.
func test_the_claimant_can_counter() -> void:
	var context: Dictionary = _open_a_council()
	assert_false(context.is_empty(), "un Consiglio si apre")
	session.confluence.set_proposition(
		str((session.confluence.available_propositions()[0] as Dictionary)["id"])
	)
	var rivendicante: String = ""
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(context["proponent"]):
			rivendicante = str(entity_id)
			break
	var offer: Dictionary = {
		"price": session.confluence.price_menu(),
		"benefits": session.confluence.claimable_benefits(),
	}

	var screen: Node = _screen(rivendicante)
	var decider: RefCounted = SeatDecider.new([rivendicante], null)
	decider.io = screen
	decider.choose_counterclaim(rivendicante, context, offer, session)

	_the_step_can_be_answered(screen, "Controproposta?")
	var column: String = " · ".join(PackedStringArray(_buttons(screen)))
	assert_true(
		column.contains("secondo dibattito"),
		"e si puo' tenere il diritto invece di spenderlo: %s" % column
	)
	_finish(screen)


## **E chi si prende la pedina del prezzo sceglie le voci, una per una.**
##
## `choose_costs` e' l'unica domanda annidata: ci si arriva solo dicendo di si'
## alla controproposta. Sta qui perche' il criterio della voce dice **ogni
## passo in cui il motore chiede qualcosa a una persona**, e questo lo e'.
func test_the_claimant_can_pick_the_costs() -> void:
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool:
			return not (session.confluence.price_menu()["cost"] as Array).is_empty()
	)
	assert_false(context.is_empty(), "un Consiglio con un prezzo da posare esiste")
	var menu: Array = (session.confluence.price_menu()["cost"] as Array)
	var rivendicante: String = ""
	for entity_id in session.world["turn_order"]:
		if str(entity_id) != str(context["proponent"]):
			rivendicante = str(entity_id)
			break

	var screen: Node = _screen(rivendicante)
	var decider: RefCounted = SeatDecider.new([rivendicante], null)
	decider.io = screen
	decider.choose_costs(rivendicante, context, menu, 1, session)

	_the_step_can_be_answered(screen, "Quali costi paga chi vince?")
	_finish(screen)


## **La plancia mostra quello che il Consiglio fa gia'** — il passo 1 di
## [ISSUES 80](../../docs/ISSUES.md#80).
##
## La voce, scritta in 0.1.253, dice: *«dei benefici comprati, del prezzo, della
## pedina e della controproposta non mostra niente»*. Era vero allora. D-291,
## D-304 e D-387 hanno scritto quel pezzo, e da allora nessuno era tornato a
## verificarlo: questa prova lo tiene, cosi' la riga non torna a marcire.
func test_the_board_shows_what_was_bought_and_at_what_price() -> void:
	var context: Dictionary = _a_council_where(
		func(_c: Dictionary) -> bool: return not session.confluence.benefit_menu().is_empty()
	)
	assert_false(context.is_empty(), "un Consiglio con delle caselle vive esiste")
	var comprata: String = str(
		(session.confluence.benefit_menu()[0] as Dictionary)["id"]
	)
	assert_true(session.confluence.set_benefits([comprata]), "il proponente compra la prima")

	var screen: Node = _screen(str(context["proponent"]))
	var board: Node = screen.get("_board")
	board.call("render", session, str(context["proponent"]))

	var scritto: String = _text_of(board.get("_face"))
	assert_true(scritto.contains("COSA SI COMPRA"), "la plancia dice cosa si compra: %s" % scritto)
	var testo: String = str(session.confluence.call("_voice_text", "benefits", comprata))
	assert_true(
		scritto.contains(testo.substr(0, mini(24, testo.length()))),
		"e nomina la casella comprata «%s»: %s" % [testo, scritto]
	)
	for id in IDS:
		assert_false(scritto.contains(str(id)), "e non parla per id (%s): %s" % [str(id), scritto])
	_finish(screen)

