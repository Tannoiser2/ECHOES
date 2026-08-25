extends "res://tests/test_case.gd"
## I sei mazzetti sullo schermo (D-279, parola del committente).
##
## Il patto e' che ci siano **tutti e sei, sempre** — anche quelli freddi — e
## che ognuno abbia il suo posto senza sovrapporsi al vicino: sul tavolo i
## mazzetti stanno affiancati, e un mazzetto che sparisce quando e' freddo
## toglie a chi gioca l'unica cosa che dice di cosa si parlera'.

const ThemeDecksView := preload("res://ui/theme_decks_view.gd")


func before_each() -> void:
	new_session()


## **Sei mazzetti, sei posti, nessuna sovrapposizione.**
func test_every_theme_has_its_own_slot() -> void:
	var view: Control = ThemeDecksView.new()
	view.size = Vector2(320, 190)
	view.render(session)
	var themes: Array = data().themes.keys()
	assert_eq(themes.size(), 6, "i Temi sono sei")
	var slots: Array = []
	for i in range(themes.size()):
		var box: Rect2 = view._slot(i)
		assert_true(box.size.x > 0.0 and box.size.y > 0.0, "il mazzetto %d ha un posto" % i)
		assert_true(
			Rect2(Vector2.ZERO, view.size).encloses(box),
			"il mazzetto %d sta dentro la vista" % i
		)
		for other in slots:
			assert_false(
				(other as Rect2).intersects(box),
				"il mazzetto %d non si sovrappone a un altro" % i
			)
		slots.append(box)
	view.free()


## **Il dito trova il mazzetto che tocca**, e fuori non trova niente.
func test_the_finger_finds_the_deck() -> void:
	var view: Control = ThemeDecksView.new()
	view.size = Vector2(320, 190)
	view.render(session)
	var themes: Array = data().themes.keys()
	for i in range(themes.size()):
		var box: Rect2 = view._slot(i)
		assert_eq(
			view._deck_at(box.get_center()), str(themes[i]),
			"al centro del mazzetto %d c'e' il suo Tema" % i
		)
	assert_eq(view._deck_at(Vector2(-40.0, -40.0)), "", "fuori dalla vista non c'e' nessun mazzetto")
	view.free()


## **La vista legge il tavolo, non se lo inventa**: i gettoni caduti e la carta
## girata vengono dal mondo, e il conto per girare dalla Chronicle.
func test_the_view_reads_the_table() -> void:
	var theme_id: String = str(data().themes.keys()[0])
	assert_eq(
		int(session.tensions.theme_token_count(theme_id)), 0,
		"si comincia con i mazzetti freddi"
	)
	assert_true(session.tensions.reveal_at() >= 2, "il conto per girare e' dichiarato dalla Chronicle")
	# Un gettone alla volta fino al conto: alla soglia la carta si gira, ed e'
	# quello che la vista deve poter mostrare.
	session.world["theme_tokens"][theme_id] = session.tensions.reveal_at()
	assert_eq(
		str(session.tensions.theme_front(theme_id)), "",
		"i gettoni da soli non girano niente: e' il motore che gira, quando la Risonanza cade"
	)
	assert_ne(str(session.tensions.flip_theme_front(theme_id)), "", "e girando esce una domanda")
	assert_ne(
		str(session.tensions.theme_front(theme_id)), "",
		"da li' in poi il mazzetto ha la sua carta scoperta"
	)
