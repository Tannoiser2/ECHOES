extends "res://tests/test_case.gd"
## Quattro varchi disegnati, e i chiusi li copre un gettone (D-429 — ISSUES 127).
##
## La tessera si posa **girandola** finche' un varco combacia con quella accanto
## ([D-390](docs/DECISIONS.md#d-390)). Finche' il prompt d'arte diceva a chi
## disegna *«questi due lati sono chiusi dal terreno»*, l'illustrazione aveva un
## sopra — e girata di novanta gradi mentiva: la frana finiva dove la strada
## passa. La strada (2), scelta dal committente, toglie il problema alla
## radice: **ogni tessera si illustra con la strada che arriva a tutti e quattro
## i bordi**, e i lati che il dato chiude si coprono al tavolo con la pedina
## «varco chiuso».
##
## Questa prova sorveglia la riga che lo dice a chi disegna. Non c'era: il
## brief era guardato solo dal confronto col documento generato, che va rosso
## **dopo** che la riga e' cambiata e non dice mai **cosa** deve dire.

const ArtBible := preload("res://scripts/core/art_bible.gd")


func before_each() -> void:
	new_session()


## Le condizioni si **fabbricano**: una tessera con tutti e quattro i varchi e
## una con due chiusi. Cercarle fra le dieci vere vorrebbe dire che il giorno
## che l'Isola Muta diventa una croce questa prova smette di provare, in
## silenzio — ed e' la trappola che in questo progetto ha morso sedici volte.
func _face(edges: Array) -> Dictionary:
	return {"deck": "region", "title": "Tessera di prova", "edges": edges}


## **Una tessera aperta da ogni parte lo dice, e basta.** Nove delle dieci sono
## croci: la riga non deve nominare nessun gettone.
func test_a_cross_tile_says_all_four_edges() -> void:
	var line: String = ArtBible._passages_line(_face(["N", "E", "S", "O"]))
	assert_true(
		line.contains("all four edges"),
		"la riga dice i quattro bordi (era: «%s»)" % line
	)
	assert_false(
		line.contains("token"),
		"una croce non ha lati da coprire (era: «%s»)" % line
	)


## **E una tessera con dei lati chiusi chiede lo stesso quattro varchi.** E' il
## cuore della strada (2): il disegno non cambia con l'orientamento, perche'
## non c'e' nessun bordo disegnato diverso dagli altri. Quello che cambia e'
## il tavolo, dove un gettone copre la strada che li' non si puo' fare.
func test_a_closed_tile_still_asks_for_four_ways_and_names_the_token() -> void:
	var line: String = ArtBible._passages_line(_face(["N", "O"]))
	assert_true(
		line.contains("all four edges"),
		"anche la tessera chiusa si disegna aperta (era: «%s»)" % line
	)
	assert_true(
		line.contains("landslide token"),
		"la riga nomina il gettone che copre (era: «%s»)" % line
	)
	assert_true(
		line.contains("right") and line.contains("bottom"),
		"e nomina **quali** lati si coprono (era: «%s»)" % line
	)


## **Un lato solo si dice al singolare.** Non e' pedanteria: il brief lo legge
## una persona, e «the right edges» su un bordo solo e' la crepa da cui si
## capisce che la riga la scrive una macchina che non guarda.
func test_a_single_closed_edge_is_said_in_the_singular() -> void:
	var line: String = ArtBible._passages_line(_face(["N", "E", "S"]))
	assert_true(
		line.contains("the left edge, which"),
		"un lato solo, al singolare (era: «%s»)" % line
	)


## **E una tessera senza varchi dichiarati non dice niente.** Il prompt resta
## senza quella riga invece di inventarsene una: e' il caso dei mazzi che non
## sono tessere, e passa di qui.
func test_a_face_without_edges_says_nothing() -> void:
	assert_eq(ArtBible._passages_line(_face([])), "", "nessuna riga senza varchi")


## **Il gettone esiste nella fustella.** La riga del brief promette una pedina
## che si posa al tavolo: se quella pedina non e' fra i segnalini che la
## fustella taglia, il brief promette un pezzo che nessuno stampa.
func test_the_landslide_token_is_in_the_punchboard() -> void:
	var found: bool = false
	for icon in session.data.token_icons.values():
		if str((icon as Dictionary).get("tag", "")) == "pedina:varco_chiuso":
			found = true
			assert_eq(
				str((icon as Dictionary).get("fustella", "")), "PEDINE",
				"il varco chiuso sta sul foglio delle pedine"
			)
	assert_true(found, "la pedina «varco chiuso» e' nella fustella")
