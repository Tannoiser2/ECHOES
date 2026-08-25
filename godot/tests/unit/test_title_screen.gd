extends "res://tests/test_case.gd"
## La soglia (D-276): la schermata d'ingresso mostra una pesca **vera**.
##
## Il patto e' uno solo: quello che la soglia promette e' quello che il tavolo
## poi da'. L'assaggio rifa' la pesca con la stessa derivazione del seme di
## `game_session.gd` — se un giorno una delle due derivazioni cambia da sola,
## queste prove vanno rosse.

const TitleScreen := preload("res://ui/title_screen.gd")


## **Stesso seme, stesse tessere, stessa posa.** L'assaggio della soglia e la
## partita aperta a quel seme devono coincidere tessera per tessera, e la posa
## dell'assaggio deve essere la posa del mondo (D-275).
func test_the_threshold_shows_a_true_draw() -> void:
	var tiles: Array = TitleScreen.preview(data(), 7042)
	assert_eq(tiles.size(), 6, "sei tessere sull'assaggio della soglia")

	var opened: RefCounted = GameSession.new(data())
	var seats: Array = GameSession.seats_for(data(), "CHR_00", 7042)
	assert_true(opened.setup("CHR_00", seats, 7042), "CHR_00 si apre al seme 7042")
	var order: Array = (opened.world["regions"] as Dictionary).keys()
	for i in range(tiles.size()):
		var entry: Dictionary = tiles[i] as Dictionary
		assert_eq(
			str(entry["region_id"]), str(order[i]),
			"la tessera %d della soglia e' la tessera %d della partita" % [i, i]
		)
		assert_eq(
			opened.world["map_positions"][str(order[i])],
			[int(entry["col"]), int(entry["row"])],
			"la posa della soglia e' la posa del mondo (tessera %d)" % i
		)
	opened.dispose()


## **Ogni tessera porta i suoi segni stampati e il suo terreno.** I segni si
## dicono col cancelletto (D-262), i domini restano alle iconcine; il piano del
## terreno e' quello di RegionArt — sagoma a sei lati, colore di terra.
func test_every_tile_wears_its_signs_and_its_ground() -> void:
	for seed_value in [7000, 7042]:
		var tiles: Array = TitleScreen.preview(data(), seed_value)
		for tile in tiles:
			var entry: Dictionary = tile as Dictionary
			assert_true(
				str(entry["signs"]).begins_with("#"),
				"«%s» stampa i suoi segni a cancelletto (seme %d)"
				% [str(entry["name"]), seed_value]
			)
			assert_false(
				str(entry["signs"]).contains("domain:"),
				"i domini non stanno nella riga dei segni"
			)
			var plan: Dictionary = entry["plan"] as Dictionary
			assert_eq(
				(plan["outline"] as Array).size(), 6,
				"la sagoma della tessera ha sei lati"
			)
			assert_ne(str(plan["ground"]), "", "la tessera ha un colore di terra")


## **La porta porta nella sala.** Il bottone della soglia apre la scena di
## sempre — quella del menu, della stanza e della partita.
func test_the_door_leads_to_the_hall() -> void:
	assert_eq(TitleScreen.GAME_SCENE, "res://ui/main.tscn", "la porta punta alla sala")
	assert_true(
		ResourceLoader.exists(TitleScreen.GAME_SCENE), "la sala esiste dove la porta punta"
	)
	assert_true(
		ResourceLoader.exists("res://ui/title_screen.tscn"),
		"la scena della soglia esiste ed e' quella che l'app apre"
	)
