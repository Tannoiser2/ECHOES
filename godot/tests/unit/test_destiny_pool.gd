extends "res://tests/test_case.gd"
## Il pool dei Destini (D-150): che cosa vuole una casa quest'anno.
##
## Il banco di prova **neutralizza** la pesca (`test_case.new_session` rimette a
## ogni casa il Destino scritto), altrimenti misurerebbe il caso invece del
## codice. Qui la si accende apposta.

const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


## Senza pool, ogni casa vuole quello che ha sempre voluto: una Chronicle che
## non lo dichiara si comporta come prima di D-150.
func test_without_a_pool_a_house_keeps_its_written_destiny() -> void:
	var set: RefCounted = data()
	var chronicle: Dictionary = (set.chronicles["CHR_01"] as Dictionary).duplicate(true)
	chronicle.erase("destiny_pool")
	var world: Dictionary = WorldStateFactory.build(
		chronicle, set, RngService.new(4242), chronicle["entities"]
	)
	for entity_id in chronicle["entities"]:
		assert_eq(
			str(world["entities"][str(entity_id)]["destiny_id"]),
			str(set.entities[str(entity_id)]["destiny_id"]),
			"%s insegue il Destino scritto sull'Entita'" % str(entity_id)
		)


## Col pool, il Destino esce da quella lista — e da nessun'altra parte: non si
## permuta niente fra le case (SEDUTA_LINEE §2).
func test_with_a_pool_the_destiny_comes_from_that_house_s_list() -> void:
	var set: RefCounted = data()
	# Il pool e' **spento nei dati** finche' gli otto Destini alternativi non
	# saranno misurati uno per uno (D-150): il meccanismo si prova qui su una
	# Chronicle costruita apposta, che e' anche il modo di provarlo senza
	# dipendere da come sono scritte le Chronicle vere.
	var chronicle: Dictionary = (set.chronicles["CHR_01"] as Dictionary).duplicate(true)
	chronicle["destiny_pool"] = {
		"ENT_ALDRIC": ["DST_ALDRIC", "DST_ALDRIC_RECORD"],
		"ENT_NAHR": ["DST_NAHR", "DST_NAHR_ROOTED"],
		"ENT_LYRA": ["DST_LYRA", "DST_LYRA_TAUGHT"],
		"ENT_VAERAX": ["DST_VAERAX", "DST_VAERAX_WATCHED"],
	}
	for seed_value in [1, 2, 3, 7, 11, 4242]:
		var world: Dictionary = WorldStateFactory.build(
			chronicle, set, RngService.new(int(seed_value)), chronicle["entities"]
		)
		for entity_id in chronicle["entities"]:
			var pool: Array = (chronicle["destiny_pool"] as Dictionary)[str(entity_id)]
			var chosen: String = str(world["entities"][str(entity_id)]["destiny_id"])
			assert_true(
				pool.has(chosen),
				"«%s» esce dal pool di %s" % [chosen, str(entity_id)]
			)
			assert_eq(
				str(set.destinies[chosen]["entity_id"]), str(entity_id),
				"e il Destino «%s» e' scritto per questa casa" % chosen
			)


## Semi diversi vogliono cose diverse: se la pesca desse sempre lo stesso, il
## pool sarebbe un campo in piu' e nient'altro.
func test_two_seeds_want_different_things() -> void:
	var set: RefCounted = data()
	var chronicle: Dictionary = (set.chronicles["CHR_01"] as Dictionary).duplicate(true)
	chronicle["destiny_pool"] = {
		"ENT_ALDRIC": ["DST_ALDRIC", "DST_ALDRIC_RECORD"],
		"ENT_NAHR": ["DST_NAHR", "DST_NAHR_ROOTED"],
		"ENT_LYRA": ["DST_LYRA", "DST_LYRA_TAUGHT"],
		"ENT_VAERAX": ["DST_VAERAX", "DST_VAERAX_WATCHED"],
	}
	var seen: Dictionary = {}
	for seed_value in range(1, 25):
		var world: Dictionary = WorldStateFactory.build(
			chronicle, set, RngService.new(seed_value), chronicle["entities"]
		)
		var hand: Array = []
		for entity_id in chronicle["entities"]:
			hand.append(str(world["entities"][str(entity_id)]["destiny_id"]))
		seen["|".join(PackedStringArray(hand))] = true
	assert_true(seen.size() >= 4, "in ventiquattro semi il tavolo vuole almeno quattro cose diverse")


## E il dado dei Destini e' a parte (D-051, D-150): accendere il pool cambia
## cosa la gente vuole, non che mondo trova. Se attingesse al caso della
## partita, sposterebbe mazzi, deriva e domande — ed e' successo davvero.
func test_the_draw_does_not_move_the_world() -> void:
	var set: RefCounted = data()
	var without: Dictionary = (set.chronicles["CHR_01"] as Dictionary).duplicate(true)
	without.erase("destiny_pool")
	var with_pool: Dictionary = (without as Dictionary).duplicate(true)
	with_pool["destiny_pool"] = {
		"ENT_ALDRIC": ["DST_ALDRIC", "DST_ALDRIC_RECORD"],
		"ENT_NAHR": ["DST_NAHR", "DST_NAHR_ROOTED"],
		"ENT_LYRA": ["DST_LYRA", "DST_LYRA_TAUGHT"],
		"ENT_VAERAX": ["DST_VAERAX", "DST_VAERAX_WATCHED"],
	}
	var a: Dictionary = WorldStateFactory.build(
		with_pool, set, RngService.new(4242), with_pool["entities"]
	)
	var b: Dictionary = WorldStateFactory.build(
		without, set, RngService.new(4242), without["entities"]
	)
	assert_eq(
		JSON.stringify(a["tensions"]), JSON.stringify(b["tensions"]),
		"le domande dell'anno non cambiano perche' si pesca un Destino"
	)
	assert_true(a.has("decks"), "il mondo ha i mazzi (o questa prova guarda il nulla)")
	assert_eq(
		JSON.stringify(a["decks"]), JSON.stringify(b["decks"]),
		"e nemmeno i mazzi"
	)
	assert_eq(
		JSON.stringify(a["echo_deck"]), JSON.stringify(b["echo_deck"]),
		"ne' il mazzo del Narratore"
	)
