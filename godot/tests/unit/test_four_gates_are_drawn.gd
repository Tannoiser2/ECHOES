extends "res://tests/test_case.gd"
## **I varchi si disegnano dove stanno** (D-510 — ISSUES 127, D-429 rovesciata).
##
## Per centocinquanta versioni la regola era l'opposta, e per una buona ragione:
## la tessera si posava **girandola** ([D-390](docs/DECISIONS.md#d-390)), quindi
## un prompt che diceva a chi disegna *«questi due lati sono chiusi dal
## terreno»* dava all'illustrazione un sopra, e girata di novanta gradi mentiva
## — la frana finiva dove la strada passa. D-429 aveva tolto il problema alla
## radice: **la strada arriva a tutti i bordi**, e i lati chiusi li copre una
## pedina.
##
## Il committente ha tolto la rotazione: *«la tessera NON si gira, i testi
## devono essere visibili nella stessa direzione»*. Ogni tessera ha la sua
## casella nella rosa e ci va dritta, quindi il disegno **ha un sopra** e puo'
## dire la verita' sui suoi lati — anzi **deve**, perche' un varco dipinto dove
## il dato non ne ha uno sarebbe una strada che il tavolo vede e il motore no.
##
## Questa prova sorveglia la riga che lo dice a chi disegna. Il confronto col
## documento generato non basta: va rosso **dopo** che la riga e' cambiata, e
## non dice mai **cosa** deve dire.

const ArtBible := preload("res://scripts/core/art_bible.gd")


func before_each() -> void:
	new_session()


## Le condizioni si **fabbricano**: una tessera aperta da ogni parte, una con
## un lato solo, una con cinque chiusi. Cercarle fra le dieci vere vorrebbe
## dire che il giorno che i varchi cambiano questa prova smette di provare, in
## silenzio — ed e' la trappola che in questo progetto ha morso sedici volte.
func _face(edges: Array) -> Dictionary:
	return {"deck": "region", "title": "Tessera di prova", "edges": edges}


## **La riga dice sempre due cose sulla forma**, qualunque siano i varchi:
## l'esagono, e che non si gira. Sono le due che rendono possibile tutto il
## resto: senza l'orientamento fisso nominare i lati sarebbe di nuovo una
## bugia.
func test_every_tile_says_the_hexagon_and_the_fixed_orientation() -> void:
	for edges in [["N", "NE", "SE", "S", "SO", "NO"], ["N", "SO"], ["S"]]:
		var line: String = ArtBible._passages_line(_face(edges as Array))
		assert_true(
			line.contains("HEXAGON"),
			"la riga dice l'esagono (varchi %s, era: «%s»)" % [str(edges), line]
		)
		assert_true(
			line.contains("never rotated"),
			"e che non si gira (varchi %s, era: «%s»)" % [str(edges), line]
		)


## **Una tessera aperta da ogni parte non ha niente di chiuso da dire.** E' il
## caso in cui la riga deve tacere sul terreno: nominare un lato chiuso che non
## c'e' manderebbe chi disegna a murare una strada vera.
func test_a_tile_open_all_round_names_no_closed_edge() -> void:
	var line: String = ArtBible._passages_line(_face(["N", "NE", "SE", "S", "SO", "NO"]))
	assert_true(
		line.contains("top, upper-right, lower-right, bottom, lower-left and upper-left edges"),
		"la riga nomina tutti e sei i varchi (era: «%s»)" % line
	)
	assert_false(
		line.contains("closed by the land"),
		"e non parla di terreno chiuso (era: «%s»)" % line
	)


## **E una tessera murata dice quali lati sono muro, e di cosa.** E' il cuore di
## D-510: il disegno porta il dato. Le Montagne Rosse hanno **una** via, in
## basso, e chi le dipinge deve saperlo.
func test_a_walled_tile_names_its_closed_edges_and_what_closes_them() -> void:
	var line: String = ArtBible._passages_line(_face(["S"]))
	assert_true(
		line.contains("reaches the bottom edge"),
		"la riga dice l'unica via (era: «%s»)" % line
	)
	assert_true(
		line.contains("top, upper-right, lower-right, lower-left and upper-left edges are closed"),
		"e nomina i cinque muri (era: «%s»)" % line
	)
	assert_true(
		line.contains("cliff") and line.contains("no way through"),
		"dicendo di cosa sono fatti (era: «%s»)" % line
	)


## **Un lato solo si dice al singolare**, dalle due parti. Non e' pedanteria: il
## brief lo legge una persona, e «the top edges are closed» su un bordo solo e'
## la crepa da cui si capisce che la riga la scrive una macchina che non guarda.
func test_one_of_a_kind_is_said_in_the_singular() -> void:
	var uno_aperto: String = ArtBible._passages_line(_face(["N"]))
	assert_true(
		uno_aperto.contains("reaches the top edge;"),
		"un varco solo, al singolare (era: «%s»)" % uno_aperto
	)
	var uno_chiuso: String = ArtBible._passages_line(_face(["N", "NE", "SE", "S", "SO"]))
	assert_true(
		uno_chiuso.contains("the upper-left edge is closed"),
		"un muro solo, al singolare (era: «%s»)" % uno_chiuso
	)


## **E una tessera senza varchi dichiarati non dice niente.** Il prompt resta
## senza quella riga invece di inventarsene una: e' il caso dei mazzi che non
## sono tessere, e passa di qui.
func test_a_face_without_edges_says_nothing() -> void:
	assert_eq(ArtBible._passages_line(_face([])), "", "nessuna riga senza varchi")


## **Il gettone «varco chiuso» resta nella fustella, e adesso serve a quello per
## cui era nato.** Con D-429 rattoppava un disegno che non poteva sapere dove
## sarebbe finito; da D-510 il disegno lo sa, e la pedina torna a essere quella
## che il Consiglio posa quando **chiude una strada** (`SEAL_ROAD` ->
## `CLOSE_PASSAGE`). Se non fosse nella fustella, il Consiglio farebbe una cosa
## che sul tavolo non si vede.
func test_the_closed_passage_token_is_in_the_punchboard() -> void:
	var found: bool = false
	for icon in session.data.token_icons.values():
		if str((icon as Dictionary).get("tag", "")) == "pedina:varco_chiuso":
			found = true
			assert_eq(
				str((icon as Dictionary).get("fustella", "")), "PEDINE",
				"il varco chiuso sta sul foglio delle pedine"
			)
	assert_true(found, "la pedina «varco chiuso» e' nella fustella")
