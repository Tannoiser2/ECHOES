extends "res://tests/test_case.gd"
## Le icone di sistema (D-058).
##
## Un'icona si giudica guardandola, e la prova a occhio esiste: la scrive
## `run_export.gd` come `prova_icone.svg`, ogni glifo da 16 a 64 px su fondo
## chiaro e su fondo scuro. Questi test tengono ferme le cose che si rompono in
## silenzio - un glifo che manca, un tratto che esce dal quadrato, un segno che
## diventa uguale a un altro.

const IconSet := preload("res://scripts/core/icon_set.gd")
const CardFace := preload("res://scripts/core/card_face.gd")


## Ogni famiglia dei dati ha il proprio glifo, e ogni livello di tag che la mappa
## puo' disegnare pure. Una famiglia nuova senza icona esce come punto
## interrogativo, e questo test lo dice prima che lo dica il tavolo.
func test_everything_the_game_shows_has_a_glyph() -> void:
	var families: Dictionary = {}
	for asset_id in data().assets:
		families[str(data().assets[str(asset_id)]["family"])] = true
	for family in families:
		assert_true(
			IconSet.FAMILIES.has(str(family)),
			"la famiglia %s ha il proprio glifo" % str(family)
		)
	assert_eq(families.size(), 6, "sei famiglie, come dice il §19.4")

	var levels: Dictionary = {}
	for region_id in data().regions:
		for tag in data().regions[str(region_id)]["tags"]:
			if str(tag).contains(":"):
				levels[str(tag).split(":")[0]] = true
	for level in levels:
		# `domain:` non e' un overlay: e' il dominio della Regione, e non si
		# disegna sulla tessera.
		if str(level) == "domain":
			continue
		assert_true(
			IconSet.LEVELS.has(str(level)),
			"il livello %s ha il proprio glifo" % str(level)
		)


## Ogni tratto sta nel quadrato del glifo: un'icona che sborda si mangia il testo
## che ha accanto, e sulla mappa il testo accanto e' il nome della cosa.
func test_every_glyph_stays_in_its_square() -> void:
	for name in IconSet.names():
		var strokes: Array = IconSet.glyph(str(name))
		assert_true(strokes.size() > 0, "%s e disegnato" % str(name))
		assert_true(strokes.size() <= 4, "%s resta un segno, non un disegno" % str(name))
		for stroke in strokes:
			var item: Dictionary = stroke
			# Una spezzata deborda di meta spessore per lato; un `dot` deborda del
			# proprio raggio, che e' quello che `width` significa li.
			var margin: float = 0.0
			if str(item["kind"]) == "line":
				margin = float(item["width"]) * 0.5
			elif str(item["kind"]) == "dot":
				margin = float(item["width"])
			for point in item["points"]:
				var at: Vector2 = point
				assert_true(
					at.x - margin >= -0.01 and at.x + margin <= 1.01
					and at.y - margin >= -0.01 and at.y + margin <= 1.01,
					"%s: un tratto esce dal quadrato (%.2f, %.2f)" % [str(name), at.x, at.y]
				)


## Il vincolo della ART_BIBLE, per quanto un test lo possa controllare: due
## glifi non possono avere la stessa forma, perche' in monocromatico la forma e'
## tutto quello che resta.
##
## E' una condizione necessaria e non sufficiente - la prova vera e' guardare
## `prova_icone.svg` - ma prende il caso che capita davvero, cioe' due segni
## copiati l'uno dall'altro con una coordinata cambiata.
func test_no_two_glyphs_are_the_same_shape() -> void:
	var seen: Dictionary = {}
	for name in IconSet.names():
		var shape: String = ""
		for stroke in IconSet.glyph(str(name)):
			var item: Dictionary = stroke
			shape += "%s%d:" % [str(item["kind"]), (item["points"] as Array).size()]
			for point in item["points"]:
				shape += "%.2f,%.2f;" % [(point as Vector2).x, (point as Vector2).y]
		assert_false(seen.has(shape), "%s non e la copia di %s" % [str(name), str(seen.get(shape, ""))])
		seen[shape] = str(name)
	assert_eq(seen.size(), (IconSet.names() as Array).size(), "dodici segni diversi")


## Nessun glifo e' un segno solo appena inclinato rispetto a un altro: a 16 px la
## differenza fra due tratti quasi paralleli non esiste. Si controlla il **centro
## di massa** dei punti, che e' grossolano e proprio per questo utile.
func test_glyphs_do_not_sit_on_top_of_each_other() -> void:
	var centres: Dictionary = {}
	for name in IconSet.names():
		var sum: Vector2 = Vector2.ZERO
		var count: int = 0
		for stroke in IconSet.glyph(str(name)):
			for point in (stroke as Dictionary)["points"]:
				sum += point as Vector2
				count += 1
		centres[str(name)] = sum / float(maxi(1, count))
	for name in centres:
		for other in centres:
			if str(name) >= str(other):
				continue
			assert_true(
				(centres[name] as Vector2).distance_to(centres[other]) > 0.001
				or IconSet.glyph(str(name)).size() != IconSet.glyph(str(other)).size(),
				"%s e %s sono lo stesso segno" % [str(name), str(other)]
			)


## Il glifo esce come SVG di un colore solo. Se dovesse contenere un secondo
## colore vorrebbe dire che si legge grazie al colore, che e' esattamente quello
## che la ART_BIBLE vieta.
func test_the_svg_uses_one_colour_only() -> void:
	for name in IconSet.names():
		var svg: String = IconSet.svg(str(name), 0.0, 0.0, 16.0, "#123456")
		assert_true(svg.contains("#123456"), "%s si disegna del colore chiesto" % str(name))
		assert_eq(svg.count("#"), svg.count("#123456"), "%s non ha altri colori" % str(name))


## La carta Asset porta la propria famiglia fino in stampa: e' cosi che il glifo
## finisce sul foglio senza che il foglio sappia cos'e' una famiglia.
func test_the_printed_card_carries_its_family() -> void:
	for face in CardFace.deck_of("asset", data()):
		assert_true(
			IconSet.FAMILIES.has(str((face as Dictionary)["family"])),
			"%s porta la propria famiglia" % str((face as Dictionary)["id"])
		)
	for face in CardFace.deck_of("echo", data()):
		assert_eq(str((face as Dictionary)["family"]), "", "una carta Echo non ha famiglia di Asset")


## La prova a occhio si rigenera con tutto il resto, quindi non puo' invecchiare.
func test_the_proof_sheet_shows_every_glyph() -> void:
	var proof: String = IconSet.proof_svg()
	assert_true(proof.begins_with("<svg"), "e un SVG")
	assert_true(proof.ends_with("</svg>\n"), "chiuso")
	for name in IconSet.names():
		assert_true(proof.contains(">%s<" % str(name)), "%s e nella prova" % str(name))
