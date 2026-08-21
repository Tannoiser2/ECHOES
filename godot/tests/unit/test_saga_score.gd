extends "res://tests/test_case.gd"
## Il vincitore della saga (D-180), su richiesta del committente.
##
## «Per vincere la saga ci vuole un contatore di vittorie nelle singole partite.
## Dare un valore ai livelli di vittoria che si sommano alla fine della saga
## decretando il vincitore.»
##
## Tre cose vanno provate, e la terza e' quella che tiene onesta la regola: che
## una Chronicle senza `saga_scoring` non tenga nessun conto. Il punteggio e'
## una regola della Chronicle, non del motore.

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func before_each() -> void:
	new_session()


## I valori d'autore: un anno perso toglie, esistere vale poco, osare vale il
## doppio di riuscire.
func test_the_scale_is_the_one_the_chronicle_declares() -> void:
	var rules: Dictionary = data().chronicles["CHR_01"].get("saga_scoring", {})
	assert_false(rules.is_empty(), "CHR_01 tiene il conto della saga")
	assert_eq(int(rules["none"]), -1, "un anno senza nemmeno il Minimo costa")
	assert_eq(int(rules["minimum"]), 1, "esistere vale poco")
	assert_eq(int(rules["victory"]), 3, "riuscire vale")
	assert_eq(int(rules["triumph"]), 6, "osare vale il doppio di riuscire")


## Il conto parte da zero e si somma con il livello dell'anno.
func test_a_closed_year_adds_its_level_to_the_seat() -> void:
	for entity_id in SEATS:
		assert_eq(
			int(session.world["entities"][entity_id]["saga_score"]), 0,
			"all'apertura nessuno ha punti"
		)
	var controller: RefCounted = session.chronicle
	var scored: Dictionary = {
		"ENT_ALDRIC": {"level": "TRIUMPH"},
		"ENT_NAHR": {"level": "VICTORY"},
		"ENT_LYRA": {"level": "MINIMUM"},
		"ENT_VAERAX": {"level": "NONE"},
	}
	controller.call("_score_the_saga", scored, session.log)
	assert_eq(int(session.world["entities"]["ENT_ALDRIC"]["saga_score"]), 6, "il Trionfo vale 6")
	assert_eq(int(session.world["entities"]["ENT_NAHR"]["saga_score"]), 3, "la Vittoria vale 3")
	assert_eq(int(session.world["entities"]["ENT_LYRA"]["saga_score"]), 1, "il Minimo vale 1")
	assert_eq(int(session.world["entities"]["ENT_VAERAX"]["saga_score"]), -1, "il NONE toglie")
	# E si somma, invece di sostituire.
	controller.call("_score_the_saga", scored, session.log)
	assert_eq(int(session.world["entities"]["ENT_ALDRIC"]["saga_score"]), 12, "due Trionfi fanno 12")
	assert_eq(int(session.world["entities"]["ENT_VAERAX"]["saga_score"]), -2, "due anni persi fanno -2")


## Il conto attraversa le ere: e' della **campagna**, non dell'anno. E segue il
## seggio, non la persona - chi siede cambia, il conto no.
func test_the_count_crosses_the_eras() -> void:
	var controller: RefCounted = session.chronicle
	controller.call("_score_the_saga", {
		"ENT_ALDRIC": {"level": "TRIUMPH"},
		"ENT_NAHR": {"level": "MINIMUM"},
		"ENT_LYRA": {"level": "MINIMUM"},
		"ENT_VAERAX": {"level": "MINIMUM"},
	}, session.log)
	var previous: Dictionary = session.world.duplicate(true)

	var next: RefCounted = GameSession.new(data())
	next.setup("CHR_01", SEATS, 99)
	next.inherit_from(previous, {})
	assert_eq(
		int(next.world["entities"]["ENT_ALDRIC"]["saga_score"]), 6,
		"l'anno nuovo apre col conto dell'anno prima"
	)
	assert_eq(
		int(next.world["entities"]["ENT_LYRA"]["saga_score"]), 1,
		"e vale per ogni seggio, non solo per chi ha vinto"
	)
	next.dispose()


## La soglia della campagna (D-181), decisa dal committente: «direi la saga
## almeno 10 partite». Prima di dieci Chronicle il conto si tiene ma nessuno ha
## vinto; dalla decima in poi il tavolo puo' chiudere quando vuole.
func test_the_campaign_is_not_decided_before_the_tenth_year() -> void:
	var rules: Dictionary = data().chronicles["CHR_01"].get("saga_scoring", {})
	assert_eq(int(rules["decides_after"]), 10, "una campagna e' almeno dieci anni")
	assert_eq(
		int(session.world["chronicles_played"]), 1,
		"la prima Chronicle e' il primo anno della saga"
	)
	var controller: RefCounted = session.chronicle
	controller.call("_score_the_saga", {"ENT_ALDRIC": {"level": "TRIUMPH"}}, session.log)
	var said: String = "\n".join(PackedStringArray(session.log.lines))
	assert_true(
		said.contains("non e' ancora decisa"),
		"al primo anno la campagna non ha un vincitore"
	)
	assert_false(said.contains("la vince"), "e non lo dichiara")

	# Al decimo, invece, si'.
	session.world["chronicles_played"] = 10
	controller.call("_score_the_saga", {"ENT_ALDRIC": {"level": "TRIUMPH"}}, session.log)
	var later: String = "\n".join(PackedStringArray(session.log.lines))
	assert_true(later.contains("la vince Re Aldric"), "al decimo anno la campagna si decide")


## E il conto degli anni di campagna cresce attraversando le ere, che e' l'unico
## modo di sapere quanto e' lunga una saga: `year` conta gli anni del mondo, e
## fra due Chronicle ne possono passare duecento.
func test_the_years_of_the_campaign_are_counted() -> void:
	var previous: Dictionary = session.world.duplicate(true)
	var next: RefCounted = GameSession.new(data())
	next.setup("CHR_01", SEATS, 99)
	next.inherit_from(previous, {})
	assert_eq(int(next.world["chronicles_played"]), 2, "il secondo anno di campagna")
	var third: Dictionary = next.world.duplicate(true)
	var last: RefCounted = GameSession.new(data())
	last.setup("CHR_01", SEATS, 101)
	last.inherit_from(third, {})
	assert_eq(int(last.world["chronicles_played"]), 3, "e il terzo")
	next.dispose()
	last.dispose()


## La guardia che tiene onesta la regola: senza `saga_scoring` nella Chronicle
## non si conta niente. Il punteggio e' contenuto, non motore - una Chronicle
## puo' essere un anno che sta in piedi da solo, come in v0.2.
func test_without_the_rule_nothing_is_counted() -> void:
	var controller: RefCounted = session.chronicle
	var chronicle: Dictionary = controller.get("_chronicle") as Dictionary
	var kept: Variant = chronicle.get("saga_scoring")
	chronicle.erase("saga_scoring")
	controller.call("_score_the_saga", {
		"ENT_ALDRIC": {"level": "TRIUMPH"},
	}, session.log)
	assert_eq(
		int(session.world["entities"]["ENT_ALDRIC"]["saga_score"]), 0,
		"senza la regola, un Trionfo non vale nessun punto"
	)
	if kept != null:
		chronicle["saga_scoring"] = kept
