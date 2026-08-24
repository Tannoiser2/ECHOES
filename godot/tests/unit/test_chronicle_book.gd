extends "res://tests/test_case.gd"
## La cronaca dell'anno come pagine (ISSUES voce 10, D-086).
##
## Le Verita' sono l'unico pezzo di carta che il gioco produce invece di
## consumare, e queste guardie tengono fermo il minimo: ogni Verita' scritta
## finisce sulla pagina, le pagine sono A4 veri, un anno lungo si spezza in
## piu' pagine invece di uscire dal foglio, e un anno muto lo dice.

const ChronicleBook := preload("res://scripts/core/chronicle_book.gd")
const BookView := preload("res://ui/chronicle_book_view.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func test_every_truth_written_ends_up_on_a_page() -> void:
	new_session(4242, false)
	await session.run(PolicyDecider.new(session.log))
	var save: Dictionary = session.to_save()
	var truths: Array = (save["world_state"] as Dictionary).get("truth_log", [])
	assert_true(truths.size() > 0, "la partita di guardia scrive almeno una Verita'")
	var book: String = "\n".join(PackedStringArray(ChronicleBook.pages(save, data())))
	for truth in truths:
		var text: String = str((truth as Dictionary)["text"])
		var separator: int = text.find(": ")
		if separator > 0 and text.substr(0, separator).begins_with("Anno "):
			text = text.substr(separator + 2)
		# La pagina manda a capo a mano: si controlla la prima parola lunga,
		# che sopravvive intera a qualunque a-capo.
		var probe: String = ""
		for word in text.split(" ", false):
			if str(word).length() >= 8:
				probe = str(word)
				break
		if probe != "":
			assert_true(
				book.contains(probe.xml_escape()) or book.contains(probe),
				"la Verita' «%s...» e' sulla pagina" % text.substr(0, 30)
			)


func test_pages_are_true_a4_and_numbered() -> void:
	new_session(4242, false)
	await session.run(PolicyDecider.new(session.log))
	var pages: Array = ChronicleBook.pages(session.to_save(), data())
	assert_true(pages.size() >= 1, "almeno una pagina")
	for index in range(pages.size()):
		var page: String = str(pages[index])
		assert_true(page.contains('width="210mm" height="297mm"'), "la pagina e' un A4 vero")
		assert_true(
			page.contains("pagina %d di %d" % [index + 1, pages.size()]),
			"e porta il proprio numero"
		)


func test_a_long_year_breaks_into_more_pages() -> void:
	var truths: Array = []
	for index in range(80):
		truths.append({
			"act": 1 + (index / 30), "round": 1,
			"truth_id": "TRU_%04d" % index, "echo_id": "ECHO_%04d" % index,
			"text": "Anno 900, Atto 1: la lunga voce numero %d del registro, scritta apposta per riempire la pagina fino a mandarla a capo. (S1 O0 M1)." % index,
		})
	var save: Dictionary = {
		"chronicle_id": "CHR_01",
		"world_state": {"year": 900, "truth_log": truths, "entities": {}},
		"destiny_results": {},
	}
	var pages: Array = ChronicleBook.pages(save, data())
	assert_true(pages.size() > 1, "ottanta Verita' non stanno su una pagina: %d" % pages.size())


## La vista in-app rasterizza l'SVG delle pagine: se una pagina non si lascia
## disegnare, al tavolo si vedrebbe un pannello vuoto.
##
## **Questa prova ha detto il falso per mesi** (D-248). Disegnava a scala 2, e
## l'applicazione disegnava a scala 4: due cose diverse, e quella misurata non
## era quella che si vedeva. A scala 4 un A4 esce **3175x4490**, il lato lungo
## supera il massimo che una scheda di un tablet accetta, la texture non si
## carica e la pagina resta nera — *«la cronaca dell'anno e' sempre una pagina
## vuota»*. La prova restava verde perche' guardava altrove.
##
## Adesso chiama **la stessa funzione che chiama lo schermo**, ed e' l'unico
## modo in cui una prova su questa vista puo' voler dire qualcosa.
func test_every_page_rasterizes_for_the_screen() -> void:
	new_session(4242, false)
	await session.run(PolicyDecider.new(session.log))
	var pages: Array = ChronicleBook.pages(session.to_save(), data())
	assert_true(pages.size() > 0, "l'anno ha lasciato almeno una pagina")
	for index in range(pages.size()):
		var image: Image = BookView.raster(str(pages[index]))
		assert_true(image != null, "la pagina %d si rasterizza" % (index + 1))
		assert_true(image.get_width() > 0, "e ha dei pixel")
		# **E ci sta dentro una texture.** E' il difetto, in una riga: una
		# pagina piu' larga del tetto non e' una pagina brutta, e' una pagina
		# che non esiste.
		var side: int = maxi(image.get_width(), image.get_height())
		assert_true(
			float(side) <= BookView.MAX_SIDE,
			"e sta sotto il tetto della texture: %d contro %d" % [
				side, int(BookView.MAX_SIDE)
			]
		)
		# Nitida abbastanza da leggersi: il tetto non deve diventare la scusa
		# per una pagina illeggibile.
		assert_true(side >= 1000, "e resta leggibile: lato lungo %d" % side)


func test_a_silent_year_says_so() -> void:
	var save: Dictionary = {
		"chronicle_id": "CHR_01",
		"world_state": {"year": 813, "truth_log": [], "entities": {}},
		"destiny_results": {},
	}
	var pages: Array = ChronicleBook.pages(save, data())
	assert_eq(pages.size(), 1, "un anno muto e' comunque una pagina")
	assert_true(
		str(pages[0]).contains("senza lasciare storia"),
		"e la pagina dice che l'anno non ha lasciato storia"
	)


## D-096: il libro della saga. Due anni in fila danno la Timeline in apertura
## - anni, salti, chi sedeva e com'e' finita - e poi le cronache di ogni anno,
## nell'ordine in cui sono state vissute. Con un anno solo resta il libro di
## sempre.
func test_the_saga_book_opens_with_the_timeline() -> void:
	var first: Dictionary = {
		"chronicle_id": "CHR_01",
		"world_state": {
			"year": 812,
			"truth_log": [{"act": 1, "round": 1, "truth_id": "TRU_0001",
				"text": "Anno 812, Atto 1: il granaio fu conteso davanti a tutti. (S3 O1 M2)."}],
			"entities": {"ENT_ALDRIC": {"name": "Re Aldric"}},
		},
		"destiny_results": {"ENT_ALDRIC": {"level": "VICTORY"}},
	}
	var second: Dictionary = {
		"chronicle_id": "CHR_02",
		"world_state": {
			"year": 904,
			"truth_log": [{"act": 1, "round": 1, "truth_id": "TRU_0002",
				"text": "Anno 904, Atto 1: la strada fu giurata sotto scorta. (S2 O0 M3)."}],
			"entities": {"ENT_ALDRIC": {"name": "Re Serane"}},
		},
		"destiny_results": {"ENT_ALDRIC": {"level": "MINIMUM"}},
	}

	var pages: Array = ChronicleBook.saga_pages([first, second], data())
	assert_true(pages.size() >= 3, "Timeline piu' due cronache: almeno tre pagine")
	var timeline: String = str(pages[0])
	assert_true(timeline.contains("LA SAGA"), "la prima pagina e' il frontespizio della saga")
	assert_true(timeline.contains("Anni 812"), "e dice da dove parte")
	assert_true(timeline.contains("92 anni dopo"), "la Timeline conta il salto")
	assert_true(timeline.contains("Re Serane"), "e nomina chi si e' seduto dopo")
	assert_true(timeline.contains("la vittoria"), "com'e' finita, in breve")
	var book: String = "\n".join(PackedStringArray(pages))
	assert_true(book.contains("granaio"), "la cronaca del primo anno c'e'")
	assert_true(book.contains("giurata"), "e quella del secondo")

	assert_eq(
		ChronicleBook.saga_pages([first], data()),
		ChronicleBook.pages(first, data()),
		"con un anno solo il libro della saga e' il libro di sempre"
	)
