extends "res://tests/test_case.gd"
## La soglia (D-276, rifatta in D-279): la copertina, e chi siede al tavolo.
##
## Parola del committente: *«lo splash screen deve essere con questa immagine,
## lì devo scegliere i seggi e i giocatori (chi è persona e chi Bot)»*. Le
## prove tengono i tre patti che ne seguono: i seggi sono quelli veri della
## Chronicle, la scelta arriva alla sala, e la sala esiste dove la porta punta.

const TitleScreen := preload("res://ui/title_screen.gd")
const TableChoice := preload("res://scripts/core/table_choice.gd")
const ArtLibrary := preload("res://scripts/core/art_library.gd")


func after_each() -> void:
	# La scelta e' statica: una prova che la lascia sporca farebbe aprire la
	# sala del test dopo con un tavolo che nessuno ha scelto.
	TableChoice.forget()


## **I seggi della soglia sono quelli del tavolo.** Non una lista scritta a
## mano nella schermata (il difetto di D-050): quelli che la Chronicle apre.
func test_the_threshold_offers_the_real_seats() -> void:
	var seats: Array = TitleScreen.seats_of(data())
	assert_true(seats.size() >= 2, "la soglia offre i seggi del tavolo (%d)" % seats.size())
	for seat in seats:
		assert_true(
			data().entities.has(str(seat)),
			"«%s» e' una casa della scatola" % [str(seat)]
		)
	var chronicle_id: String = preload("res://ui/game_screen.gd").first_chronicle(data())
	assert_eq(
		seats, (data().chronicles[chronicle_id]["entities"] as Array),
		"e sono esattamente quelli della Chronicle da cui si comincia"
	)


## **La scelta arriva alla sala.** Chi e' persona e chi e' bot si decide qui, e
## la partita non lo richiede piu'.
func test_the_choice_reaches_the_hall() -> void:
	assert_false(TableChoice.chosen, "prima della soglia non c'e' nessuna scelta")
	var seats: Array = TitleScreen.seats_of(data())
	TableChoice.take([str(seats[0])])
	assert_true(TableChoice.chosen, "la soglia ha scelto")
	assert_eq(TableChoice.humans, [str(seats[0])], "e la sala sa chi gioca")
	# Nessuna persona e' una scelta legittima: si guardano giocare le policy.
	TableChoice.take([])
	assert_true(TableChoice.chosen, "anche «tutti bot» e' una scelta fatta")
	assert_eq(TableChoice.humans, [], "e non c'e' nessuno da chiedere")


## **La porta porta nella sala, e la copertina ha il suo posto.**
func test_the_door_and_the_cover() -> void:
	assert_eq(TitleScreen.GAME_SCENE, "res://ui/main.tscn", "la porta punta alla sala")
	assert_true(ResourceLoader.exists(TitleScreen.GAME_SCENE), "la sala esiste")
	assert_true(
		ResourceLoader.exists("res://ui/title_screen.tscn"),
		"la soglia e' la scena che l'app apre"
	)
	assert_eq(ArtLibrary.COVER, "ui.copertina", "la copertina ha la sua chiave")
	assert_true(
		ArtLibrary.texture(ArtLibrary.COVER) != null,
		"e il file della copertina e' al suo posto (art/ui/copertina.png)"
	)
