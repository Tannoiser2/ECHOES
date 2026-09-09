extends "res://tests/test_case.gd"
## **La pagina e' disegnata alla misura del tablet, e i caratteri si misurano
## li'** (D-465).
##
## Fino a D-464 la pagina era disegnata a 1920x1080 e sull'iPad del committente
## arrivava a 0,71: un testo da 12 si leggeva da 8, e nessuna misura lo diceva.
## Ora la finestra di progetto e' il tablet, un pixel e' un punto, e la sonda
## della pagina legge la taglia di ogni testo per quel fattore. Queste prove
## guardano il fattore, e che la guardia morda su un testo **fabbricato** —
## perche' una prova che cerca un testo piccolo fra quelli veri smette di
## provare il giorno che l'ultimo sparisce.

const Survey := preload("res://cli/run_page_survey.gd")


## Il progetto dichiara la finestra del tablet: un pixel della pagina e' un
## punto dello schermo, ne' piu' ne' meno.
func test_a_pixel_of_the_page_is_a_point_of_the_tablet() -> void:
	var viewport: Vector2 = Survey._project_viewport()
	assert_eq(
		viewport, Vector2(Survey.TAVOLETTA_LARGA, Survey.TAVOLETTA_ALTA),
		"la finestra di progetto e' il tablet tenuto per il largo"
	)
	assert_eq(Survey._tablet_scale(viewport), 1.0, "e un pixel vale un punto")


## La finestra vecchia, per confronto: a 1920x1080 il tablet la mostrava a 0,71,
## e un 12 diventava un 8 e mezzo — sotto il pavimento.
func test_the_old_window_shrank_a_twelve_under_the_floor() -> void:
	var scale: float = Survey._tablet_scale(Vector2(1920.0, 1080.0))
	assert_true(absf(scale - 0.711) < 0.005, "a 1920x1080 il tablet vale 0,71 (%.3f)" % scale)
	assert_true(Survey._too_small(12, scale), "un 12 a 1920 sul tablet e' un 8,5: rosso")
	assert_false(Survey._too_small(12, 1.0), "lo stesso 12 alla misura del tablet si legge")
	assert_false(Survey._too_small(11, 1.0), "e 11 e' il pavimento, non sotto")
	assert_true(Survey._too_small(10, 1.0), "10 sta sotto")
	assert_eq(Survey._tablet_scale(Vector2.ZERO), 0.0, "una finestra senza misura non vale niente")


## La guardia legge la taglia che il nodo dichiara — su un'etichetta, un blocco
## di testo ricco, un bottone — e su chi non dichiara niente legge il tema,
## non zero: un testo senza taglia non e' per questo piccolo.
func test_a_fabricated_small_text_is_caught() -> void:
	var label := Label.new()
	label.text = "otto punti"
	label.add_theme_font_size_override("font_size", 8)
	assert_eq(Survey._font_of(label), 8, "l'etichetta dichiara 8")
	assert_true(Survey._has_words(label), "e ha parole")
	assert_true(Survey._too_small(Survey._font_of(label), 1.0), "8 sul tablet e' rosso")

	var rich := RichTextLabel.new()
	rich.add_theme_font_size_override("normal_font_size", 9)
	assert_eq(Survey._font_of(rich), 9, "il testo ricco dichiara la sua taglia normale")
	assert_true(Survey._has_words(rich), "e conta come testo anche se le parole restano fuori")

	var button := Button.new()
	button.text = "Avanti"
	assert_true(Survey._font_of(button) > 0, "un bottone senza taglia ha quella del tema, non zero")
	assert_true(Survey._has_words(button), "un bottone con una scritta ha parole")

	var empty := Label.new()
	assert_false(Survey._has_words(empty), "un'etichetta vuota non e' un testo")
	var box := Control.new()
	assert_eq(Survey._font_of(box), 0, "e un nodo senza parole non ha una taglia")

	label.free()
	rich.free()
	button.free()
	empty.free()
	box.free()


## Le foto a grandezza vera hanno mostrato il cartiglio del turno ancora con
## le sue cornici da terminale: arriva al verbale in un blocco solo di piu'
## righe, e il filtro di D-464 guardava la prima. Fabbricato, non cercato.
func test_the_turn_card_reaches_the_transcript_without_its_frames() -> void:
	var screen: Script = load("res://ui/game_screen.gd")
	var block: String = "\n".join(PackedStringArray([
		"+-- ATTO 1, ROUND 1 ----------------------------------------",
		"| Le domande dell'anno: La Leva 2/6",
		"| In mano: Diritto di Corona",
		"Una riga senza cornice resta com'e'.",
	]))
	var said: String = screen._without_frames(block)
	assert_false(said.contains("+--"), "la cornice sopra e' sparita")
	assert_false(said.contains("\n| "), "e le sbarre a sinistra pure")
	assert_false(said.contains("---"), "i trattini di coda con lei")
	assert_true(said.contains("ATTO 1, ROUND 1"), "resta quello che dice")
	assert_true(said.contains("Le domande dell'anno: La Leva 2/6"), "riga per riga")
	assert_true(said.ends_with("Una riga senza cornice resta com'e'."), "e chi non ha cornici non si tocca")


## **E adesso quel cartiglio non arriva nemmeno** (D-491).
##
## La pagina disegna gia' domande, mappa, mano, Destino e rapporti: riceverne
## anche la versione a caratteri, a ogni Occasione, voleva dire ristampare nel
## verbale le stesse cose che stavano sullo schermo. Misurato con
## `cli/run_log_probe.gd`: **144 righe su 880 dette al seggio**, il 16%, erano
## quel pannello. Il telefono lo dichiara da D-143; adesso lo dichiara anche
## lei, e il filtro qui sopra resta come rete per chi non lo dichiara.
func test_the_page_draws_its_own_state() -> void:
	var screen: Node = load("res://ui/game_screen.gd").new()
	assert_true(
		screen.has_method("shows_state") and bool(screen.call("shows_state")),
		"la pagina dice al decisore che il pannello se lo disegna da se'"
	)
	screen.free()


## **Ogni posto della pagina ha una larghezza** (D-466): la sonda misura i
## pannelli contro il posto in cui stanno — sinistra, centro, sotto, schermo
## intero — e i posti, messi in fila coi margini, fanno il tablet. Un pannello
## che non sta sulla pagina non ha un posto.
func test_every_place_on_the_page_has_a_width() -> void:
	for where_v in ["sinistra", "centro", "sotto", "schermo", "stanza"]:
		assert_true(Survey._room_for(str(where_v)) > 0.0, "il posto «%s» ha una larghezza" % str(where_v))
	assert_eq(Survey._room_for("fuori"), 0.0, "un pannello fuori dalla pagina non ha un posto")
	var in_a_row: float = (
		Survey.MARGINE * 2.0 + Survey.SINISTRA + Survey.FUGA * 2.0
		+ Survey._room_for("centro") + Survey.DESTRA
	)
	assert_eq(in_a_row, Survey.TAVOLETTA_LARGA, "sinistra, centro, destra e i margini fanno il tablet")
	assert_true(Survey._room_for("schermo") < Survey.TAVOLETTA_LARGA, "il Consiglio a schermo intero tiene un margine")
	assert_true(Survey._height_for("schermo") > 0.0, "e promette un'altezza")
	assert_eq(Survey._height_for("sinistra"), 0.0, "una colonna che scorre non ne promette nessuna")
