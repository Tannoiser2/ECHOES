extends "res://tests/test_case.gd"
## Riprendere un anno lasciato a meta (D-052).
##
## `SaveManager` esiste ed e testato dalla 0.0, e non lo chiamava niente. La
## voce e rimasta aperta sulla roadmap della 0.1 con la ragione scritta accanto:
## non mancava il file, mancava un posto in cui *tornare*. `run()` era tre cicli
## annidati che partivano sempre da Atto 1, round 1, quindi rileggere un mondo a
## meta voleva dire ridistribuire le mani e rigiocare l'anno da capo.
##
## Adesso `run()` parte dall'Atto e dal round su cui il mondo si trova. Il test
## che conta e questo: una partita interrotta e ripresa deve finire **identica**
## a una che non e stata interrotta. Se non lo e, il salvataggio non e un
## salvataggio, e una campagna che ci si appoggia sopra sta mentendo.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SaveSerializer := preload("res://scripts/core/save_serializer.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
const SEED: int = 4242


func _fresh() -> RefCounted:
	var made: RefCounted = GameSession.new(data())
	made.setup("CHR_01", SEATS, SEED)
	return made


## Interrompere sull'**ultimo** round di un Atto e il caso che rompe tutto se lo
## si sbaglia: la carta Echo di fine Atto non e ancora uscita, e riprendere dal
## primo round dell'Atto dopo la salterebbe - cioe perderebbe l'unica mossa che
## il mondo fa da solo. Stesso confronto, punto di interruzione diverso.
func test_a_chronicle_resumed_on_an_act_boundary_still_plays_its_echo_card() -> void:
	await _compare_interrupted_at(1, 3)


## Un anno giocato di fila, e lo stesso anno interrotto alla fine del secondo
## round e ripreso da li: stesso registro, stessi Consigli, stessi Destini.
func test_a_resumed_chronicle_ends_exactly_where_an_uninterrupted_one_does() -> void:
	await _compare_interrupted_at(1, 2)


func _compare_interrupted_at(stop_act: int, stop_round: int) -> void:
	var whole: RefCounted = _fresh()
	var expected: Dictionary = await whole.run(PolicyDecider.new(whole.log))
	var expected_log: Array = (whole.log.lines as Array).duplicate()
	var expected_effects: int = (whole.world["effect_log"] as Array).size()
	whole.dispose()

	# La stessa partita, fermata a meta: si gioca fino a quando il secondo round
	# si chiude, e si tiene il mondo com'e in quel momento.
	var half: RefCounted = _fresh()
	var save: Dictionary = {}
	half.chronicle.phase_changed.connect(
		func(act: int, round_number: int, phase: String) -> void:
			if phase == "THRESHOLD_CHECK" and act == stop_act and round_number == stop_round and save.is_empty():
				half.sync_rng_state()
				save.merge(half.to_save("test"), true)
	)
	await half.run(PolicyDecider.new(half.log))
	half.dispose()
	assert_false(save.is_empty(), "il salvataggio e stato preso a meta anno")

	# E si riparte da li, con un motore che non sa niente di quello che e stato.
	var resumed: RefCounted = GameSession.new(data())
	resumed.setup("CHR_01", SEATS, SEED)
	assert_true(resumed.restore(save), "il mondo si rilegge: %s" % resumed.last_error)
	var report: Dictionary = await resumed.run(PolicyDecider.new(resumed.log))

	assert_eq(
		(report["confluences"] as Array).size(),
		(expected["confluences"] as Array).size(),
		"stessi Consigli"
	)
	for entity_id in SEATS:
		assert_eq(
			str(report["destiny_results"][str(entity_id)]["level"]),
			str(expected["destiny_results"][str(entity_id)]["level"]),
			"%s finisce allo stesso livello" % str(entity_id)
		)
	assert_eq(
		(resumed.world["effect_log"] as Array).size(), expected_effects,
		"e il registro degli Effect e lungo uguale: niente e stato rifatto due volte"
	)

	# Il registro non riparte da capo - la ripresa lo dice - ma da dove riprende
	# in poi deve raccontare la stessa cosa.
	var tail: Array = expected_log.slice(expected_log.size() - 12)
	var got: Array = (resumed.log.lines as Array).slice((resumed.log.lines as Array).size() - 12)
	assert_eq(got, tail, "e le ultime dodici righe dell'anno sono le stesse")
	resumed.dispose()


## Il punto di ripresa e l'inizio di un round: un mondo appena creato parte da
## Atto 1 round 1 e non si comporta come una ripresa.
func test_a_fresh_world_is_not_mistaken_for_an_interrupted_one() -> void:
	var made: RefCounted = _fresh()
	assert_eq(int(made.world["act"]), 0, "un mondo appena creato non e su nessun Atto")
	await made.run(PolicyDecider.new(made.log))
	var opened: bool = false
	for line in made.log.lines:
		if str(line).contains("SITUAZIONE INIZIALE"):
			opened = true
		assert_false(str(line).contains("SI RIPRENDE"), "e non annuncia una ripresa")
	assert_true(opened, "ha fatto il proprio setup")
	made.dispose()
