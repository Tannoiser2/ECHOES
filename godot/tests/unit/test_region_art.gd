extends "res://tests/test_case.gd"
## Il terreno delle Regioni (D-057).
##
## E' grafica, e la grafica si giudica guardandola. Quello che un test puo' fare
## e' tenere ferme le tre cose che, se si rompono, si rompono in silenzio: che il
## disegno resti dentro la tessera, che ogni bioma abbia il proprio, e che la
## stessa Regione esca identica a ogni partita e a ogni export.

const RegionArt := preload("res://scripts/core/region_art.gd")
const CardFace := preload("res://scripts/core/card_face.gd")


## Ogni punto sta nel quadrato della tessera. Un tratto che esce si vede sullo
## schermo come una riga che invade la Regione vicina, e sul foglio stampato come
## inchiostro oltre il segno di taglio.
func test_every_stroke_stays_inside_its_tile() -> void:
	for region_id in data().regions:
		var region: Dictionary = data().regions[str(region_id)]
		var plan: Dictionary = RegionArt.plan(str(region_id), str(region["biome"]))
		var points: Array = (plan["outline"] as Array).duplicate()
		for stroke in plan["strokes"]:
			points.append_array((stroke as Dictionary)["points"])
		assert_true(points.size() > 6, "%s ha un disegno" % str(region_id))
		for point in points:
			var at: Vector2 = point
			assert_true(
				at.x >= 0.0 and at.x <= 1.0 and at.y >= 0.0 and at.y <= 1.0,
				"%s: un punto esce dalla tessera (%.2f, %.2f)" % [str(region_id), at.x, at.y]
			)


## Ogni bioma ha una tavolozza e un vocabolario suoi. Un bioma che cade nel ramo
## di riserva disegna la steppa e nessuno se ne accorge finche' non lo guarda.
func test_every_biome_in_the_data_has_its_own_drawing() -> void:
	var seen: Dictionary = {}
	for region_id in data().regions:
		var biome: String = str(data().regions[str(region_id)]["biome"])
		assert_true(
			RegionArt.BIOMES.has(biome),
			"%s: il bioma %s ha la propria tavolozza" % [str(region_id), biome]
		)
		var plan: Dictionary = RegionArt.plan(str(region_id), biome)
		var shape: String = "%s|%d" % [str(plan["ground"]), (plan["strokes"] as Array).size()]
		assert_false(seen.has(shape), "%s non disegna quello che disegna gia un'altra" % biome)
		seen[shape] = true
	assert_true(seen.size() >= 6, "sei Regioni, sei disegni diversi: %d" % seen.size())


## Stessa Regione, stesso disegno: la mappa non deve cambiare fra due partite, e
## l'export non deve cambiare fra due rigenerazioni.
func test_the_same_region_is_drawn_the_same_way_every_time() -> void:
	var once: Dictionary = RegionArt.plan("REG_TEST", "MOUNTAIN")
	var twice: Dictionary = RegionArt.plan("REG_TEST", "MOUNTAIN")
	assert_eq(once, twice, "due chiamate, lo stesso disegno")
	assert_ne(
		RegionArt.plan("REG_OTHER", "MOUNTAIN")["outline"], once["outline"],
		"due Regioni dello stesso bioma non hanno la stessa sagoma"
	)


## Un bioma che nessuno ha previsto disegna qualcosa invece di niente: una
## tessera vuota sulla mappa e' un buco, e un buco non si legge come «bioma
## sconosciuto», si legge come un errore del gioco.
func test_an_unknown_biome_still_draws_something() -> void:
	var plan: Dictionary = RegionArt.plan("REG_STRANGE", "TUNDRA")
	assert_eq(plan["ground"], RegionArt.UNKNOWN["ground"], "prende la tavolozza di riserva")
	assert_true((plan["strokes"] as Array).size() > 0, "e disegna comunque un terreno")


## La tessera stampata porta il proprio terreno e non il segnaposto generico: e'
## la stessa immagine della mappa, sull'altro supporto.
func test_the_printed_tile_carries_the_same_terrain() -> void:
	for face in CardFace.deck_of("region", data()):
		var item: Dictionary = face
		assert_true(
			RegionArt.BIOMES.has(str(item["terrain"])),
			"%s porta il proprio bioma in stampa" % str(item["id"])
		)
	# E nessun altro mazzo lo fa: le carte hanno il segnaposto, non il terreno.
	for deck in ["asset", "echo", "destiny"]:
		for face in CardFace.deck_of(str(deck), data()):
			assert_eq(str((face as Dictionary)["terrain"]), "", "%s non ha terreno" % deck)


## L'SVG della tessera e' XML e sta dove gli si dice.
func test_the_tile_svg_is_well_formed() -> void:
	var svg: String = RegionArt.svg("REG_TEST", "CITY", 10.0, 20.0, 40.0, 40.0)
	assert_true(svg.contains("<polygon"), "c'e la sagoma")
	assert_false(svg.contains("nan"), "nessuna coordinata degenere")
	for fragment in svg.split("\n"):
		var line: String = str(fragment)
		assert_true(line.begins_with("<"), "ogni riga e un elemento: %s" % line)
		assert_true(line.ends_with("/>"), "e si chiude: %s" % line)
