extends "res://tests/test_case.gd"
## **Il ritmo della mano a cinque, e la carta coperta** (D-504, ISSUES 136).
##
## Forma decisa dal committente:
##
## > *«Nel primo turno si pescano 5 carte, se ne giocano due e se ne sceglie una
## > per il concilio. Le due rimaste si possono scartare oppure tenere. Nel
## > secondo turno si torna a pescare per arrivare a 5 carte e si ripete.»*
##
## Le prove girano sul **tavolo spedito** (CHR_00), che e' quello che dichiara la
## regola: una prova che se la accendesse a mano su CHR_TEST proverebbe il
## proprio interruttore invece del gioco. La sola che gira su CHR_TEST e' quella
## che guarda il **lato spento**, e serve a dire che l'interruttore si legge.

const HandRhythm := preload("res://scripts/world/hand_rhythm.gd")
const Effect := preload("res://scripts/core/effect.gd")
const TableModel := preload("res://scripts/views/table_model.gd")

var _mine: RefCounted

## Un decisore che non sa rispondere a niente: il motore ripiega sui suoi
## ripieghi, che e' proprio quello che queste prove vogliono misurare.
class Mute extends RefCounted:
	pass


func _table() -> RefCounted:
	if _mine != null:
		return _mine
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(_mine.setup("CHR_00", seats, 4242), "e l'anno si apre")
	for effect in _mine.factory_setup_effects():
		_mine.applier.apply(effect)
	_mine.world["act"] = 1
	_mine.world["round"] = 1
	return _mine


func after_each() -> void:
	super.after_each()
	if _mine != null:
		_mine.dispose()
		_mine = null


func _chronicle_of(live: RefCounted) -> Dictionary:
	return live.data.chronicles[str(live.world["chronicle_id"])] as Dictionary


func _a_seat(live: RefCounted) -> String:
	return str((live.world["turn_order"] as Array)[0])


## **Il tavolo spedito dichiara il ritmo**, e le due meta' sono accese insieme.
## Senza questa prova le altre potrebbero passare su un tavolo che il ritmo non
## ce l'ha, e non se ne accorgerebbe nessuno.
func test_the_shipped_table_declares_the_rhythm() -> void:
	var live: RefCounted = _table()
	var chronicle: Dictionary = _chronicle_of(live)
	assert_eq(HandRhythm.hand_target(chronicle), 5, "la mano torna a cinque")
	assert_eq(HandRhythm.cover_per_round(chronicle), 1, "e si copre una carta per turno")
	assert_true(
		HandRhythm.council_pays_from_covered(chronicle),
		"quindi il Consiglio si paga con le coperte"
	)


## **A inizio turno la mano e' esattamente cinque.** Qui si prova il mezzo giro
## che pesca: si svuota la mano e il turno la riporta al numero.
func test_the_round_fills_the_hand_up_to_five() -> void:
	var live: RefCounted = _table()
	var seat: String = _a_seat(live)
	(live.world["entities"][seat] as Dictionary)["hand"] = []
	await live.chronicle.call("_level_the_hands", 1, 1, Mute.new())
	assert_eq(live.service.hand_size(seat), 5, "la mano e tornata a cinque")


## **E scarta quello che sta sopra** — parola del committente: *«se se ne
## acquistano troppo vanno comunque scartate»*.
##
## **Fabbricata**, perche' sul tavolo automatico non capita: il cervello non
## acquisisce abbastanza da sfondare il cinque, quindi questa meta' della regola
## non si accenderebbe mai in una misura. Una regola che non si accende non si
## dichiara viva: si prova su una condizione costruita.
func test_the_round_also_discards_down_to_five() -> void:
	var live: RefCounted = _table()
	var seat: String = _a_seat(live)
	var deck: Dictionary = (live.world["personal_decks"] as Dictionary)[seat] as Dictionary
	var before_discard: int = (deck["discard"] as Array).size()
	while live.service.hand_size(seat) < 7:
		var spare: Array = deck["draw"] as Array
		assert_false(spare.is_empty(), "il pozzo ha carte da mettere in mano a mano")
		(live.world["entities"][seat] as Dictionary)["hand"].append(str(spare[0]))
		spare.remove_at(0)
	assert_eq(live.service.hand_size(seat), 7, "sette in mano, due oltre il ritmo")

	await live.chronicle.call("_level_the_hands", 1, 1, Mute.new())
	assert_eq(live.service.hand_size(seat), 5, "il turno la riporta a cinque")
	assert_eq(
		(deck["discard"] as Array).size(), before_discard + 2,
		"e le due di troppo tornano nel **proprio** scarto, non in quello comune"
	)


## **La carta coperta esce dalla mano**, e non e' uno scarto: resta sua.
func test_covering_takes_the_card_out_of_the_hand() -> void:
	var live: RefCounted = _table()
	var seat: String = _a_seat(live)
	var before: int = live.service.hand_size(seat)
	var card: String = str((live.service.hand(seat) as Array)[0])
	live.applier.apply(Effect.make(
		"COVER_ASSET", "entity", seat, {"asset_id": card},
		Effect.source("test", "TEST", seat, 1, 1, 0)
	))
	assert_eq(live.service.hand_size(seat), before - 1, "la mano ne ha una in meno")
	assert_true((live.service.covered(seat) as Array).has(card), "e la carta e fra le coperte")
	assert_false((live.service.hand(seat) as Array).has(card), "e non e piu in mano")


## **Al Consiglio si paga con le coperte, e con niente altro.** E' la meta' della
## regola che cambia il gioco: l'impegno e' una scelta presa prima di sapere di
## cosa si parlera'.
func test_the_council_only_takes_what_was_covered() -> void:
	var live: RefCounted = _table()
	var seat: String = _a_seat(live)
	var covered_card: String = str((live.service.hand(seat) as Array)[0])
	live.applier.apply(Effect.make(
		"COVER_ASSET", "entity", seat, {"asset_id": covered_card},
		Effect.source("test", "TEST", seat, 1, 1, 0)
	))
	var in_hand: String = str((live.service.hand(seat) as Array)[0])
	assert_eq(
		live.service.commit_pool(seat), [covered_card],
		"il piatto degli impegni e' la coperta, non la mano"
	)

	var tension_id: String = ""
	for candidate in live.world["tensions"]:
		if live.confluence.can_open(str(candidate)):
			tension_id = str(candidate)
			break
	assert_ne(tension_id, "", "un Consiglio si puo aprire")
	live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var proponent: String = str(live.confluence.current["proponent"])
	if proponent != seat:
		assert_true(live.confluence.join_side(seat, "B"), "il seggio prende una parte")

	assert_false(
		live.confluence.commit(seat, [in_hand]),
		"una carta tenuta in mano non si impegna"
	)
	assert_true(
		str(live.confluence.last_error).contains("coperte"),
		"e il motivo dice dove doveva stare: «%s»" % str(live.confluence.last_error)
	)
	assert_true(live.confluence.commit(seat, [covered_card]), "la coperta si impegna")
	live.confluence.current = {}


## **Le coperte si contano, non si leggono.** Al tavolo vero un mucchietto a
## faccia in giu' davanti a qualcuno si vede: quante sono e' pubblico, quali sono
## e' il segreto. Se l'app non le contasse direbbe **meno** del tavolo.
func test_the_table_counts_the_covered_cards_without_naming_them() -> void:
	var live: RefCounted = _table()
	var seat: String = _a_seat(live)
	var card: String = str((live.service.hand(seat) as Array)[0])
	live.applier.apply(Effect.make(
		"COVER_ASSET", "entity", seat, {"asset_id": card},
		Effect.source("test", "TEST", seat, 1, 1, 0)
	))
	var model: Dictionary = TableModel.build(live)
	var counted: int = -1
	for entry in (model["seats"] as Array):
		if str((entry as Dictionary)["name"]) == live.service.name_of(seat):
			counted = int((entry as Dictionary)["covered"])
	assert_eq(counted, 1, "il tavolo dice che quel seggio ha una coperta")
	assert_false(
		JSON.stringify(model).contains(card),
		"e **non** dice quale: l'id della carta non compare da nessuna parte nel tavolo"
	)


## **Scartare e' pescare** (D-504): la mano torna al suo numero all'inizio del
## turno dopo, quindi buttare non costa niente e la carta buttata torna nel
## proprio mazzetto. E' l'incentivo che fa girare il mazzo — e senza di lui il
## «tieni o scarta» sarebbe una scelta finta, perche' nessuno scarterebbe mai.
func test_discarding_is_drawing() -> void:
	var live: RefCounted = _table()
	var seat: String = _a_seat(live)
	await live.chronicle.call("_level_the_hands", 1, 1, Mute.new())
	assert_eq(live.service.hand_size(seat), 5, "si parte da cinque")
	var deck: Dictionary = (live.world["personal_decks"] as Dictionary)[seat] as Dictionary
	var before_discard: int = (deck["discard"] as Array).size()
	for asset_id in (live.service.hand(seat) as Array).slice(0, 2):
		live.chronicle.call("_own_discard", seat, str(asset_id), 1, 1)
	assert_eq(live.service.hand_size(seat), 3, "buttate due, ne restano tre")
	assert_eq(
		(deck["discard"] as Array).size(), before_discard + 2,
		"e le due buttate sono nel proprio scarto, quindi torneranno"
	)

	await live.chronicle.call("_level_the_hands", 1, 2, Mute.new())
	assert_eq(live.service.hand_size(seat), 5, "e il turno dopo la mano e di nuovo cinque")


## **Una Pietra compra una coperta** (D-505), e questa e' la prova che regge
## tutto il giro: parola del committente, *«se hai una pietra o una presenza o
## qualunque altra cosa puoi alzare il numero di carte che puoi coprire»*.
##
## Provata **girando il mondo**, non l'interruttore: si conta quanto copre una
## casa, le si costruisce una Pietra, e si riconta. Se il conto non cambia, la
## mappa non compra niente e la regola e' scritta e non letta.
func test_a_stone_buys_a_covered_card() -> void:
	var live: RefCounted = _table()
	var chronicle: Dictionary = _chronicle_of(live)
	# **La coppia si cerca, non si spera** (D-510). Prima questa prova prendeva
	# la prima casa senza Pietre e la prima tessera dove stava, e andava bene
	# finche' la mappa era quella: sulla rosa la casa senza Pietre si trovava
	# sotto un Maniero gia' costruito, il BUILD_STRUCTURE faceva noop, e la
	# prova andava rossa per la mappa invece che per la regola. Adesso si cerca
	# una casa senza Pietre **su una tessera dove un Maniero ci sta**, e se al
	# tavolo non c'e' si va rossi dicendo quello.
	var seat: String = ""
	for entity_id in live.world["turn_order"]:
		if live.service.stones_held(str(entity_id)) == 0:
			seat = str(entity_id)
			break
	assert_ne(seat, "", "una casa senza Pietre esiste al tavolo pescato")
	# La tessera dove alzarla: una **senza Maniero**, perche' un secondo Maniero
	# sulla stessa tessera e' un noop e la prova andrebbe rossa per la mappa
	# invece che per la regola.
	var where: String = ""
	for region_id in live.world["regions"]:
		var built: bool = false
		for piece in ((live.world["regions"][str(region_id)] as Dictionary).get(
				"structures", []) as Array):
			if str((piece as Dictionary).get("structure_type", "")) == "STR_KEEP":
				built = true
		if not built:
			where = str(region_id)
			break
	assert_ne(where, "", "e sulla rosa c'e' una tessera dove un Maniero ci sta")
	var before: int = HandRhythm.cover_for(chronicle, live.service, seat)
	assert_eq(before, 1, "senza Pietre copre il pavimento")

	live.applier.apply(Effect.make(
		"BUILD_STRUCTURE", "region", where,
		{"structure_type": "STR_KEEP", "owner": seat, "grade": 1},
		Effect.source("test", "TEST", seat, 1, 1, 0)
	))
	assert_eq(live.service.stones_held(seat), 1, "la Pietra e' sua e sta sulla mappa")
	assert_eq(
		HandRhythm.cover_for(chronicle, live.service, seat), before + 1,
		"e adesso copre una carta in piu'"
	)


## **Il terreno non e' una Pietra.** Foresta, Sorgente, Sito antico e Passo sono
## `owned: false`: stanno sulla tessera, non sono di nessuno, e **non si sono
## costruiti**. Senza questa prova il conto gonfierebbe in silenzio — una casa
## che si siede su un bosco si troverebbe una coperta in piu' che non ha pagato.
func test_the_terrain_is_not_a_stone() -> void:
	var live: RefCounted = _table()
	var chronicle: Dictionary = _chronicle_of(live)
	var seat: String = str((live.world["turn_order"] as Array)[0])
	var before: int = HandRhythm.cover_for(chronicle, live.service, seat)
	var stones_before: int = live.service.stones_held(seat)
	var where: String = str((live.service.regions_with_presence(seat) as Array)[0])
	live.applier.apply(Effect.make(
		"BUILD_STRUCTURE", "region", where,
		{"structure_type": "STR_FOREST", "grade": 1},
		Effect.source("test", "TEST", seat, 1, 1, 0)
	))
	assert_eq(
		live.service.stones_held(seat), stones_before,
		"un bosco non entra nel conto delle Pietre"
	)
	assert_eq(
		HandRhythm.cover_for(chronicle, live.service, seat), before,
		"e non compra nessuna coperta"
	)


## **Il tetto vero e' la mano, non il dato** — e questo e' il tetto che il
## committente ha scelto: *«fino al massimo delle tre che ti rimangono»*.
##
## **Fabbricata**: si da' alla casa un bonus enorme e una sola carta in mano. Il
## dato direbbe tre, il tavolo dice una.
func test_what_is_left_in_hand_is_the_real_cap() -> void:
	var live: RefCounted = _table()
	var chronicle: Dictionary = _chronicle_of(live)
	var seat: String = str((live.world["turn_order"] as Array)[0])
	var decks: Dictionary = chronicle["personal_decks"] as Dictionary
	var written: Variant = decks.get("cover_bonus")
	decks["cover_bonus"] = {"per_token": 3, "cap": 3}
	assert_eq(
		HandRhythm.cover_for(chronicle, live.service, seat), 3,
		"col bonus grosso il dato dice tre"
	)

	var hand: Array = live.world["entities"][seat]["hand"] as Array
	while hand.size() > 1:
		hand.remove_at(hand.size() - 1)
	await live.chronicle.call("_cover_and_churn", 1, 1, Mute.new())
	assert_eq(
		live.service.covered_size(seat), 1,
		"ma con una carta in mano se ne copre una: il tetto e' quello che resta"
	)
	if written == null:
		decks.erase("cover_bonus")
	else:
		decks["cover_bonus"] = written


## **E il numero dice da dove viene.** Un numero guadagnato che non spiega come,
## al tavolo e' un numero che nessuno puo' controllare.
func test_the_number_says_where_it_comes_from() -> void:
	var live: RefCounted = _table()
	var chronicle: Dictionary = _chronicle_of(live)
	var seat: String = ""
	for entity_id in live.world["turn_order"]:
		if live.service.stones_held(str(entity_id)) > 0:
			seat = str(entity_id)
			break
	if seat == "":
		seat = str((live.world["turn_order"] as Array)[0])
		live.applier.apply(Effect.make(
			"BUILD_STRUCTURE", "region",
			str((live.service.regions_with_presence(seat) as Array)[0]),
			{"structure_type": "STR_KEEP", "owner": seat, "grade": 1},
			Effect.source("test", "TEST", seat, 1, 1, 0)
		))
	var reasons: Array = HandRhythm.cover_reasons(chronicle, live.service, seat)
	assert_true(str(reasons[0]).contains("di base"), "la prima ragione e' il pavimento")
	assert_true(
		" · ".join(PackedStringArray(reasons)).contains("Pietra"),
		"e la seconda nomina la Pietra: %s" % str(reasons)
	)


## **E dove la Chronicle non dichiara il ritmo, non cambia niente.**
##
## Provato girando l'interruttore invece di fidarsi: CHR_TEST non lo dichiara, e
## li' il Consiglio si paga dalla mano come e' sempre stato. Senza questa prova
## le altre potrebbero passare con la regola inchiodata sempre accesa, e nessuno
## saprebbe che l'interruttore non si legge.
func test_without_the_rule_the_council_still_pays_from_the_hand() -> void:
	new_session()
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	assert_eq(HandRhythm.hand_target(chronicle), 0, "la Chronicle di prova non lo dichiara")
	assert_false(
		HandRhythm.council_pays_from_covered(chronicle),
		"quindi il Consiglio non chiede coperte"
	)
	assert_true(session.service.hand_size("ENT_ALDRIC") > 0, "il seggio ha carte in mano")
	assert_eq(
		session.service.commit_pool("ENT_ALDRIC"), session.service.hand("ENT_ALDRIC"),
		"e il piatto degli impegni **e'** la mano"
	)
