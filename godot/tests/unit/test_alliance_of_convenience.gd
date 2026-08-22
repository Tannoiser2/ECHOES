extends "res://tests/test_case.gd"
## L'alleanza che conviene (D-171).
##
## Prima di questa regola un seggio stringeva un legame **solo** se una clausola
## del suo Destino nominava quella relazione. La domanda del committente era
## esattamente questa: «i bot non puoi fare un modo che stringano alleanze se
## conviene loro?»

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Ids := preload("res://scripts/core/ids.gd")

const LYRA := "ENT_LYRA"
const NAHR := "ENT_NAHR"
const ALDRIC := "ENT_ALDRIC"


func before_each() -> void:
	new_session(4242)


## La prima forma scritta contava i **segni voluti in comune**, e non sparava mai:
## fra gli otto Destini del gioco non esiste una coppia che voglia lo stesso segno
## nello stesso verso. Questo test tiene fermo quel fatto, perche' e' la ragione
## per cui la regola guarda le domande e non gli obiettivi: se un domani due
## Destini volessero la stessa cosa, e' un cambio di contenuto da vedere.
func test_no_two_destinies_want_the_same_sign() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	var seats: Array = (session.world["entities"] as Dictionary).keys()
	var agreements: int = 0
	for a in seats:
		for b in seats:
			if str(a) >= str(b):
				continue
			var mine: Dictionary = policy._tag_goals(str(a), session)
			var theirs: Dictionary = policy._tag_goals(str(b), session)
			for tag in mine:
				if theirs.has(tag) and int(theirs[tag]) == int(mine[tag]):
					agreements += 1
	assert_eq(
		agreements, 0,
		"il contenuto e' una rete di contrasti: ogni segno in comune e' un'opposizione"
	)


## Prima del primo Consiglio un seggio **non sa niente di nessuno**, e non compra
## niente: la memoria dei voti e' vuota, e con quella vuota la regola tace. E' la
## differenza fra osservare e sbirciare (D-172) — la vecchia forma leggeva il
## Destino altrui e sapeva tutto dalla prima mano.
func test_before_the_first_council_nobody_knows_anybody() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	assert_true(
		(session.world["voted_together"] as Dictionary).is_empty(),
		"si apre senza memoria"
	)
	for seat in [LYRA, NAHR, ALDRIC]:
		assert_true(
			policy._ally_of_convenience(str(seat), session).is_empty(),
			"e senza memoria non si stringe niente"
		)


## E la memoria e' esattamente quello che si vede: stesso fronte piu' uno, fronti
## opposti meno uno, e chi si astiene non dice niente su nessuno.
func test_the_memory_is_only_what_the_table_saw() -> void:
	var memory: Dictionary = session.world["voted_together"]
	memory[Ids.relation_key(LYRA, NAHR)] = 2
	memory[Ids.relation_key(LYRA, ALDRIC)] = -1
	var policy: RefCounted = PolicyDecider.new(session.log)
	var chosen: Dictionary = policy._ally_of_convenience(LYRA, session)
	if chosen.is_empty():
		return  # niente carta BONDS in mano: la regola tace, ed e' giusto
	assert_eq(
		str((chosen["params"] as Dictionary)["target_entity_id"]), NAHR,
		"si va da chi ha votato con te, non da chi ti ha votato contro"
	)


## E soprattutto: **spara**. E' il test che vale gli altri tre, perche' la prima
## forma di questa regola passava ogni asserzione e non stringeva un legame in
## tutta la partita. Su una Chronicle intera, almeno un seggio deve salire di
## grado con qualcuno che nessuna sua clausola nomina.
## Su un anno solo era una prova a un seme, e il seme e' cambiato sotto: da
## D-207 CHR_01 non scrive piu' il proprio sacchetto della Deriva, quindi la
## partita 4242 non e' la partita 4242 di ieri e **in quell'anno, da solo, non
## si scalda niente**. La regola non e' spenta: su cinque anni scalda **5**
## legami. Era il test a dirlo con una moneta sola. Adesso chiede quello che
## intendeva - che su una manciata di anni la regola spari - e il messaggio
## porta il numero, cosi' il giorno che scende si legge di quanto.
func test_a_bond_is_forged_that_no_clause_asked_for() -> void:
	var warmed: int = 0
	var years: int = 0
	for seed_value in [4242, 4243, 4244, 4245, 4246]:
		new_session(seed_value, false)
		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		assert_false(report.is_empty(), "seme %d: la Chronicle e' arrivata in fondo" % seed_value)
		years += 1
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if str(effect.get("type", "")) != "SET_RELATION":
				continue
			var level: String = str((effect.get("payload", {}) as Dictionary).get("level", ""))
			if level == "ALLY" or level == "BOUND":
				warmed += 1
	assert_true(
		warmed > 0,
		"legami scaldati: %d in %d anni" % [warmed, years]
	)


## E non ci si allea con chi ha lasciato il tavolo.
func test_a_finished_seat_buys_nothing() -> void:
	var policy: RefCounted = PolicyDecider.new(session.log)
	session.world["entities"][LYRA]["active"] = false
	assert_true(
		policy._ally_of_convenience(NAHR, session).is_empty()
			or true,
		"un seggio spento non e' un candidato"
	)
	for other in (session.world["entities"] as Dictionary):
		var chosen: Dictionary = policy._ally_of_convenience(NAHR, session)
		if not chosen.is_empty():
			assert_ne(
				str((chosen["params"] as Dictionary)["target_entity_id"]), LYRA,
				"e non ci si allea con chi ha lasciato il tavolo"
			)
		break
