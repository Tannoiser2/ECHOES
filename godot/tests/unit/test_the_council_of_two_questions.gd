extends "res://tests/test_case.gd"
## **Il Consiglio a due domande** (D-467, giro 3 in D-470).
##
## La carta girata offre due domande in contrasto; chi propone ne prende una e
## posa un beneficio gratis, gli altri prendono posizione e posano sulle
## caselle marcate della loro parte, si rilancia, il prezzo si conta per
## parte, e si vota senza dado contro il mucchio: A, B, o nessuna. Queste prove
## giocano il tavolo spedito (CHR_00) con un decisore **scritto**, cosi' ogni
## esito e' fabbricato e non cercato. Da D-472 e' **l'unico giro** che il
## motore sa fare: il Consiglio di D-280 e' uscito dal codice, e anche la
## Chronicle di prova gioca a due domande senza doverlo dichiarare.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const HandRhythm := preload("res://scripts/world/hand_rhythm.gd")
const Effect := preload("res://scripts/core/effect.gd")


## Un decisore che fa quello che gli si dice: chi sta con B, quante carte
## impegna ognuno. Non pensa, esegue.
class Scripted extends RefCounted:
	var with_b: Array = []
	var cards_for: Dictionary = {}

	func choose_question(context: Dictionary, _options: Array, _session: RefCounted) -> String:
		return str(context.get("question_id", ""))

	func choose_box(_entity_id: String, _context: Dictionary, menu: Array, _side: String, _session: RefCounted) -> String:
		return "" if menu.is_empty() else str((menu[0] as Dictionary)["id"])

	func choose_side(entity_id: String, _context: Dictionary, offer: Dictionary, _session: RefCounted) -> Dictionary:
		var side: String = "B" if with_b.has(entity_id) else "A"
		if (offer.get(side, []) as Array).is_empty():
			side = "A" if side == "B" else "B"
		var menu: Array = offer.get(side, []) as Array
		return {"side": side, "voice_id": "" if menu.is_empty() else str((menu[0] as Dictionary)["id"])}

	func choose_raise(_entity_id: String, _context: Dictionary, _menu: Array, _session: RefCounted) -> String:
		return ""

	## **Dal piatto che il Consiglio accetta** (D-504), non dalla mano: dove si
	## copre, una carta in mano viene **rifiutata**, e un decisore scritto che
	## la offrisse farebbe impegnare zero carte senza che questa prova se ne
	## accorga — misurerebbe un Consiglio vuoto credendo di misurarne uno pieno.
	func choose_commit(entity_id: String, _context: Dictionary, limit: int, session: RefCounted) -> Array:
		var wanted: int = mini(int(cards_for.get(entity_id, 0)), limit)
		return (session.service.commit_pool(entity_id) as Array).slice(0, wanted)

	func choose_recovery(_context: Dictionary, _session: RefCounted) -> Dictionary:
		return {}


var _mine: RefCounted


func _table() -> RefCounted:
	if _mine != null:
		return _mine
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 7000)
	assert_true(_mine.setup("CHR_00", seats, 7000), "e l'anno si apre")
	for effect in _mine.factory_setup_effects():
		_mine.applier.apply(effect)
	# **E le carte coperte**, che a un Consiglio vero ci sono sempre: qui si
	# apre un Consiglio senza giocare i turni che le avrebbero prodotte.
	_cover_some(_mine)
	return _mine


## **Le carte coperte, che al tavolo ci sono gia'** (D-504).
##
## Sul tavolo spedito il Consiglio si paga con quello che si e' **coperto** a
## fine turno, e questa prova apre un Consiglio **senza giocare un turno**: senza
## questa riga nessuno ha niente da impegnare e la prova misurerebbe un tavolo
## che non esiste — zero carte sul piatto, e non perche' il Consiglio sia rotto.
##
## Si copre col suo Effetto, non scrivendo nel mondo: e' la stessa strada che
## prende il controller alla fine di ogni turno.
func _cover_some(live: RefCounted, how_many: int = 3) -> void:
	if HandRhythm.cover_per_round(
		live.data.chronicles[str(live.world["chronicle_id"])] as Dictionary
	) <= 0:
		return
	for entity_id in live.world["turn_order"]:
		var id: String = str(entity_id)
		for asset_id in (live.service.ranked_by_strength(
			live.service.hand(id)
		) as Array).slice(0, how_many):
			live.applier.apply(Effect.make(
				"COVER_ASSET", "entity", id, {"asset_id": str(asset_id)},
				Effect.source("test", "TEST", id, 1, 1, 0)
			))


func after_each() -> void:
	super.after_each()
	if _mine != null:
		_mine.dispose()
		_mine = null


## La prima domanda in gioco che un Consiglio sa aprire.
func _openable(live: RefCounted) -> String:
	for tension_id in live.world["tensions"]:
		if live.confluence.can_open(str(tension_id)):
			return str(tension_id)
	return ""


func _heat(live: RefCounted, tension_id: String, value: int) -> void:
	var theme_id: String = str((live.data.tensions[tension_id] as Dictionary).get("theme", ""))
	(live.world["theme_heat"] as Dictionary)[theme_id] = value


## Non c'e' piu' una dichiarazione da fare (D-472): il tavolo spedito e la
## Chronicle di prova aprono tutti e due con due parti, e la B e' l'altra
## domanda della carta anche quando la Tensione non l'ha ancora resa idonea.
func test_both_the_shipped_table_and_the_test_one_open_with_two_sides() -> void:
	var live: RefCounted = _table()
	live.confluence.open(_openable(live), {"kind": "THRESHOLD"})
	assert_true(live.confluence.sides_open(), "CHR_00 apre con due parti")
	live.confluence.current = {}
	new_session()
	var context: Dictionary = session.confluence.open("TEN_FAMINE", {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Chronicle di prova apre il suo Consiglio")
	assert_true(session.confluence.sides_open(), "e apre con due parti, senza dichiararlo")
	assert_eq(session.confluence.side_question("A"), str(context["question_id"]), "la A e' la domanda presa")
	assert_ne(session.confluence.side_question("B"), "", "e la B e' l'altra della carta")
	assert_ne(session.confluence.side_question("B"), session.confluence.side_question("A"), "non la stessa")


func test_opening_makes_two_sides_and_reads_the_pile() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	assert_ne(tension_id, "", "una domanda si apre")
	_heat(live, tension_id, 3)
	var context: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio si apre")
	assert_true(live.confluence.sides_open(), "con due parti")
	assert_eq(live.confluence.side_question("A"), str(context["question_id"]), "la A e' la domanda presa")
	var ids: Array = []
	for entry in (live.data.confluence_template_for(tension_id)["questions"] as Array):
		ids.append(str((entry as Dictionary)["id"]))
	assert_true(ids.has(live.confluence.side_question("B")), "la B e' l'altra della carta")
	assert_ne(live.confluence.side_question("B"), live.confluence.side_question("A"), "e non la stessa")
	assert_eq(live.confluence.pile(), 3, "il mucchio e' il valore rivelato del Tema")
	assert_eq(live.confluence.side_of(str(context["proponent"])), "A", "chi propone sta con A")
	live.confluence.current = {}


func test_a_pedina_falls_only_on_a_box_marked_for_its_side() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	var context: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var b_question: String = live.confluence.side_question("B")
	for entry in live.confluence.box_menu("B"):
		assert_true(
			((entry as Dictionary).get("for", []) as Array).has(b_question),
			"«%s» serve la domanda B" % str((entry as Dictionary)["id"])
		)
	var other: String = ""
	for entity_id in live.confluence.stance_order():
		other = str(entity_id)
		break
	assert_true(live.confluence.join_side(other, "B"), "un seggio prende la B")
	assert_eq(live.confluence.side_leader("B"), other, "ed e' lui che la guida")
	assert_eq(live.confluence.stance_of(other), "OPPOSE", "per il tavolo si oppone")
	assert_false(live.confluence.place_box(other, "NON_ESISTE"), "una casella che non c'e' si rifiuta")
	var a_only: String = ""
	for entry in live.confluence.box_menu("A"):
		if not ((entry as Dictionary).get("for", []) as Array).has(b_question):
			a_only = str((entry as Dictionary)["id"])
			break
	if a_only != "":
		assert_false(live.confluence.place_box(other, a_only), "e una casella della sola A non si posa per B")
	var menu: Array = live.confluence.box_menu("B")
	if not menu.is_empty():
		var first: String = str((menu[0] as Dictionary)["id"])
		assert_true(live.confluence.place_box(other, first), "una casella della B si posa")
		for entry in live.confluence.box_menu("B"):
			assert_ne(str((entry as Dictionary)["id"]), first, "e non e' piu' libera")
	live.confluence.current = {}


func test_the_price_is_settled_per_side_at_the_vote() -> void:
	var live: RefCounted = _table()
	var context: Dictionary = live.confluence.open(_openable(live), {"kind": "THRESHOLD"})
	var part: Dictionary = (live.confluence.current["sides"] as Dictionary)["A"] as Dictionary
	part["boxes"] = [
		{"by": "x", "voice": "B_1", "list": "benefits"},
		{"by": "x", "voice": "B_2", "list": "benefits"},
		{"by": "x", "voice": "C_1", "list": "costs"},
		{"by": "x", "voice": "B_3", "list": "benefits"},
	]
	var removed: Array = live.confluence.settle_prices()
	assert_eq(removed, ["B_3"], "un beneficio in piu' dei costi si tiene, il resto si toglie dall'ultimo")
	assert_eq(live.confluence.side_boxes("A", "benefits"), ["B_1", "B_2"], "restano due benefici")
	assert_eq(live.confluence.side_boxes("A", "costs"), ["C_1"], "e il costo")
	assert_false(context.is_empty(), "il Consiglio era aperto")
	live.confluence.current = {}


## **Il gettone del RIVENDICARE compra il beneficio di troppo**
## ([D-476](DECISIONS.md#d-476), parola del committente: *«il Rivendicare
## dovrebbe sempre dare i gettoni con cui comprare benefici e costi»*).
##
## Il caso e' **fabbricato**, e deve esserlo: il gettone si conia due volte
## l'anno su tutto il tavolo (`run_claim_probe`), e cercare in partita una parte
## che ne abbia uno **e** sia sopra il tetto vorrebbe dire una prova che smette
## di provare appena il seme cambia.
func test_a_claim_token_buys_the_benefit_over_the_ceiling() -> void:
	var live: RefCounted = _table()
	var context: Dictionary = live.confluence.open(_openable(live), {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio si apre")
	var who: String = str(live.confluence.current["proponent"])
	var part: Dictionary = (live.confluence.current["sides"] as Dictionary)["A"] as Dictionary
	var boxes: Array = [
		{"by": who, "voice": "B_1", "list": "benefits"},
		{"by": who, "voice": "B_2", "list": "benefits"},
	]

	# Senza moneta: due benefici e nessun costo, il secondo si ritira.
	part["boxes"] = boxes.duplicate(true)
	(live.world["entities"][who] as Dictionary)["claim_tokens"] = 0
	assert_eq(
		live.confluence.settle_prices(), ["B_2"],
		"senza gettone il beneficio di troppo si toglie"
	)

	# Con la moneta in mano: la pedina resta, e il gettone se ne va.
	part["boxes"] = boxes.duplicate(true)
	(live.world["entities"][who] as Dictionary)["claim_tokens"] = 1
	assert_true(
		live.confluence.settle_prices().is_empty(),
		"col gettone non si toglie niente"
	)
	assert_eq(
		live.confluence.side_boxes("A", "benefits"), ["B_1", "B_2"],
		"e restano tutt'e due i benefici"
	)
	assert_eq(
		int((live.world["entities"][who] as Dictionary).get("claim_tokens", -1)), 0,
		"il gettone e' stato speso"
	)
	live.confluence.current = {}


## E **un gettone compra una pedina sola**: non e' un lasciapassare, e' una
## moneta. Con tre benefici, nessun costo e una moneta, una pedina resta e
## l'altra si ritira lo stesso.
func test_one_token_buys_one_piece_and_no_more() -> void:
	var live: RefCounted = _table()
	var context: Dictionary = live.confluence.open(_openable(live), {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio si apre")
	var who: String = str(live.confluence.current["proponent"])
	var part: Dictionary = (live.confluence.current["sides"] as Dictionary)["A"] as Dictionary
	part["boxes"] = [
		{"by": who, "voice": "B_1", "list": "benefits"},
		{"by": who, "voice": "B_2", "list": "benefits"},
		{"by": who, "voice": "B_3", "list": "benefits"},
	]
	(live.world["entities"][who] as Dictionary)["claim_tokens"] = 1
	assert_eq(
		live.confluence.settle_prices().size(), 1,
		"col tetto a uno e una moneta, di tre benefici se ne ritira uno"
	)
	assert_eq(
		int((live.world["entities"][who] as Dictionary).get("claim_tokens", -1)), 0,
		"e la moneta e' finita"
	)
	live.confluence.current = {}


func test_three_outcomes_against_the_pile() -> void:
	assert_eq(ConfluenceResolution.two_sides_outcome(5, 3, 4), ConfluenceResolution.SUCCESS, "A batte B e il mucchio")
	assert_eq(ConfluenceResolution.two_sides_outcome(9, 3, 4), ConfluenceResolution.DECISIVE, "di molto")
	assert_eq(ConfluenceResolution.two_sides_outcome(4, 3, 4), ConfluenceResolution.SUCCESS_WITH_COST, "di misura")
	assert_eq(ConfluenceResolution.two_sides_outcome(3, 5, 4), ConfluenceResolution.COUNTER, "B batte A e il mucchio")
	assert_eq(ConfluenceResolution.two_sides_outcome(4, 4, 2), ConfluenceResolution.FAILURE, "a parita' non passa nessuna")
	assert_eq(ConfluenceResolution.two_sides_outcome(5, 3, 6), ConfluenceResolution.FAILURE, "e nemmeno sotto il mucchio")
	assert_eq(ConfluenceResolution.winner_of(ConfluenceResolution.COUNTER), "B", "vince la B")
	assert_false(ConfluenceResolution.is_success(ConfluenceResolution.COUNTER), "che per chi propone non e' un successo")


func test_when_b_wins_its_base_outcome_applies() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	_heat(live, tension_id, 1)
	var decider: Scripted = Scripted.new()
	# Chi propone lo dice il Consiglio aperto, e si richiude prima di giocarlo.
	var peek: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var proponent: String = str(peek["proponent"])
	live.confluence.current = {}
	for entity_id in live.world["entities"]:
		if str(entity_id) != proponent:
			decider.with_b.append(str(entity_id))
			decider.cards_for[str(entity_id)] = 2
	var result: Dictionary = await live.chronicle.run_confluence(tension_id, {"kind": "THRESHOLD", "entity_id": ""}, decider)
	assert_false(result.is_empty(), "il Consiglio si e' risolto")
	assert_eq(str(result["outcome"]), ConfluenceResolution.COUNTER, "tre seggi con carte contro nessuna: vince la B (%s)" % str(result))
	assert_eq(str(result["winner"]), "B", "e lo dice")
	var b_question: String = str(result["winning_question_id"])
	var base: Array = []
	for entry in (live.data.confluence_template_for(tension_id)["questions"] as Array):
		if str((entry as Dictionary)["id"]) == b_question:
			base = (entry as Dictionary)["base"] as Array
	assert_true(not base.is_empty(), "la B ha un esito di base")
	for consequence_id in base:
		assert_true((result["consequence_ids"] as Array).has(str(consequence_id)), "e si applica: %s" % str(consequence_id))
	assert_false(result.has("world_factor"), "e senza dado: il risultato non ne porta nemmeno la chiave")


## **Il di piu' di una vittoria netta** (D-488). Il pool `decisive_bonus` sta
## nei dodici template e nello schema dal principio, e fino al 0.1.457 non lo
## leggeva **nessuno**: misurato, zero applicazioni in cento anni. Adesso lo
## legge la fascia larga, e la legge per tutt'e due le parti — qui vince la B,
## che prima non poteva prenderselo per nessun margine.
func test_a_wide_win_takes_the_decisive_bonus() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	_heat(live, tension_id, 1)
	var bonus: Array = (
		(live.data.confluence_template_for(tension_id).get("consequence_pools", {}) as Dictionary)
			.get("decisive_bonus", []) as Array
	)
	assert_true(not bonus.is_empty(), "la carta ha un di piu' scritto per chi stravince")
	var decider: Scripted = Scripted.new()
	var peek: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var proponent: String = str(peek["proponent"])
	live.confluence.current = {}
	for entity_id in live.world["entities"]:
		if str(entity_id) != proponent:
			decider.with_b.append(str(entity_id))
			decider.cards_for[str(entity_id)] = 2
	var result: Dictionary = await live.chronicle.run_confluence(tension_id, {"kind": "THRESHOLD", "entity_id": ""}, decider)
	assert_eq(str(result["outcome"]), ConfluenceResolution.COUNTER, "vince la controdomanda")
	assert_eq(
		str(result["band"]), ConfluenceResolution.WIDE,
		"e di larga misura: A %d contro B %d" % [int(result["support_total"]), int(result["oppose_total"])]
	)
	assert_true(
		(result["consequence_ids"] as Array).has(str(bonus[0])),
		"quindi il di piu' si applica: %s" % str(result["consequence_ids"])
	)


func test_when_nobody_reaches_the_pile_nothing_passes() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	_heat(live, tension_id, 99)
	var decider: Scripted = Scripted.new()
	for entity_id in live.world["entities"]:
		decider.cards_for[str(entity_id)] = 1
	var result: Dictionary = await live.chronicle.run_confluence(tension_id, {"kind": "THRESHOLD", "entity_id": ""}, decider)
	assert_eq(str(result["outcome"]), ConfluenceResolution.FAILURE, "nessuna parte arriva a 99")
	assert_eq(str(result["winner"]), "", "e non vince nessuno")
	assert_eq(int(result["pile"]), 99, "il mucchio e' scritto nel risultato")


const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const ConfluenceBoard := preload("res://ui/confluence_board.gd")


## **Il cervello fa la sua parte del mucchio** (D-471): da solo su una parte
## col mucchio a 4 impegna carte finche' vale almeno 4, o quante ne puo'; col
## mucchio a zero ne mette una.
func test_the_brain_commits_its_share_of_the_pile() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	_heat(live, tension_id, 4)
	var context: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var proponent: String = str(context["proponent"])
	var brain: PolicyDecider = PolicyDecider.new()
	var limit: int = live.confluence.max_commit_for(proponent)
	var chosen: Array = brain.choose_commit(proponent, context, limit, live)
	assert_true(not chosen.is_empty(), "da solo con A impegna qualcosa")
	var relevant: Array = live.service.relevant_families(tension_id)
	var total: int = 0
	for asset_id in chosen:
		total += ConfluenceResolution.asset_value(live.data.assets[str(asset_id)], relevant, "SUPPORT")
	assert_true(
		# **Il piatto, non la mano** (D-504): dove si copre, «tutto quello che
		# puo'» sono le sue coperte. Letto sulla mano, questo controllo
		# chiederebbe al cervello di impegnare carte che il Consiglio rifiuta.
		total >= 4
		or chosen.size() == limit
		or chosen.size() == (live.service.commit_pool(proponent) as Array).size(),
		"arriva al mucchio (%d) o da' tutto quello che puo' (%d carte)" % [total, chosen.size()]
	)
	live.confluence.current = {}
	_heat(live, tension_id, 0)
	context = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var few: Array = brain.choose_commit(proponent, context, limit, live)
	assert_true(few.size() <= 2, "col mucchio a zero non svuota la mano (%d)" % few.size())
	live.confluence.current = {}


## **Il tabellone dice le due parti** (D-471): le domande con la lettera, le
## posizioni «propone A», «propone B», «con A», «con B», le caselle con la
## marca e la pedina del colore della parte, e cosa resta se vince l'una o
## l'altra.
func test_the_board_shows_both_sides() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	var context: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var others: Array = live.confluence.stance_order()
	assert_true(others.size() >= 2, "ci sono altri seggi")
	live.confluence.join_side(str(others[0]), "B")
	live.confluence.join_side(str(others[1]), "A")
	var menu_b: Array = live.confluence.box_menu("B")
	if not menu_b.is_empty():
		live.confluence.place_box(str(others[0]), str((menu_b[0] as Dictionary)["id"]))
	var board: Node = ConfluenceBoard.new()
	board.render(live, str(context["proponent"]))
	var said: Array = []
	_labels_of(board, said)
	var whole: String = " · ".join(PackedStringArray(said))
	assert_true(whole.contains("A · "), "la domanda A porta la lettera: %s" % str(board._question.text))
	assert_true(str(board._proposition.text).begins_with("B · "), "e la B la sua")
	assert_true(whole.contains("propone A"), "chi propone propone A")
	assert_true(whole.contains("propone B"), "chi ha preso la B la propone")
	assert_true(whole.contains("con A"), "e chi sta con A lo dice")
	assert_true(whole.contains("BENEFICI") and whole.contains("COSTI"), "le liste sono quelle del cartone")
	assert_true(whole.contains("SE VINCE"), "e si legge cosa resta se vince l'una o l'altra")
	var pedine: int = 0
	for row in board._face.get_children():
		if (row as Node).has_meta("marked") and bool((row as Node).get_meta("marked")):
			pedine += 1
	var placed: int = 0
	for side in ["A", "B"]:
		for list_name in ["benefits", "costs"]:
			placed += live.confluence.side_boxes(side, list_name).size()
	assert_eq(pedine, placed, "ogni pedina posata si vede sulla carta")

	# **Quanto nettamente vince l'altra domanda** (D-488): A ha tre parole per
	# dire il suo margine, la B ne aveva una sola per qualunque distanza. Le
	# tre si leggono qui, sul tabellone, con lo stesso esito e fasce diverse.
	var said_by_band: Array = []
	for pair in [[7, 8], [4, 8], [1, 8]]:
		board._render_outcome({
			"pile": 4,
			"result": {
				"outcome": ConfluenceResolution.COUNTER,
				"support_total": int(pair[0]),
				"oppose_total": int(pair[1]),
				"margin": int(pair[0]) - int(pair[1]),
				"band": ConfluenceResolution.band_of(
					int(pair[0]), int(pair[1]), ConfluenceResolution.COUNTER
				),
			},
		})
		said_by_band.append(str(board._verdict.text))
	assert_eq(said_by_band.size(), 3, "tre margini")
	for word in said_by_band:
		assert_true(str(word).contains("altra domanda"), "e ognuno dice che vince l'altra: %s" % str(word))
	assert_eq(
		said_by_band, [
			"Vince l'altra domanda, per un soffio",
			"Vince l'altra domanda",
			"Vince l'altra domanda, senza discussione",
		],
		"con tre parole diverse e non una sola"
	)

	board.free()
	live.confluence.current = {}


func _labels_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label and (child as Label).visible:
			into.append(str((child as Label).text))
		_labels_of(child, into)
