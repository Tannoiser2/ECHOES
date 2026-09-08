extends "res://tests/test_case.gd"
## **La guardia dei doppioni morde** (D-473).
##
## La sonda della pagina conta le frasi che si leggono in due punti diversi
## dello schermo, e sulla pagina di oggi ne trova **zero**. Regola di casa: *un
## numero zero e' quasi sempre la sonda cieca, non il gioco guarito* — in
## questo progetto e' successo quattro volte di fila.
##
## Quindi lo zero si prova su casi **fabbricati**, che devono dare non-zero: se
## un giorno il conto della pagina resta zero perche' la sonda ha smesso di
## guardare, queste prove diventano rosse per prime.

const PageSurvey := preload("res://cli/run_page_survey.gd")


func test_the_same_sentence_in_two_panels_is_a_double() -> void:
	var frase: String = "Le domande gia' sul tavolo quest'anno."
	var doubled: Array = PageSurvey._doubled([
		{"page": "la colonna", "text": frase},
		{"page": "la mia casa", "text": frase},
	])
	assert_eq(doubled.size(), 1, "la stessa frase in due pannelli e' un doppione")
	assert_eq(str((doubled[0] as Dictionary)["text"]), frase, "ed e' quella frase")
	assert_eq(
		((doubled[0] as Dictionary)["pages"] as Array).size(), 2,
		"detta in due posti"
	)


## Due volte nello stesso pannello non e' un doppione: e' una lista.
func test_twice_in_the_same_panel_is_not_a_double() -> void:
	var frase: String = "Le domande gia' sul tavolo quest'anno."
	var doubled: Array = PageSurvey._doubled([
		{"page": "la colonna", "text": frase},
		{"page": "la colonna", "text": frase},
	])
	assert_true(doubled.is_empty(), "due righe uguali nella stessa lista non si contano")


## **Un nome ripetuto e' il tavolo, non un doppione.** La stessa casa ha una
## pedina sulla mappa, un posto nella riga dei seggi e una carta: se contassimo
## i nomi, il conto direbbe che il tavolo e' un difetto.
func test_a_name_repeated_is_the_table() -> void:
	var doubled: Array = PageSurvey._doubled([
		{"page": "la mappa", "text": "Re Aldric"},
		{"page": "chi siede", "text": "Re Aldric"},
	])
	assert_true(doubled.is_empty(), "«Re Aldric» in due posti e' la stessa casa")


## E la pagina vera, adesso, non ne ha nessuna: e' il numero che il giro
## promette di tenere a zero.
func test_the_page_today_says_nothing_twice() -> void:
	var doubled: Array = PageSurvey._doubled([])
	assert_true(doubled.is_empty(), "senza testi non si inventano doppioni")
