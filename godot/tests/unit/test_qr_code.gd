extends "res://tests/test_case.gd"
## Il QR della stanza, contro un oracolo indipendente (voce 27 — D-137).
##
## L'encoder e' scritto a mano; un QR sbagliato non si vede a occhio, si vede
## quando nessuno riesce a entrare. Quindi ogni matrice si confronta con
## quella che `qrcode` produce per lo stesso testo — le attese sono congelate
## in `tests/fixtures/qr_golden.json` da `tools/gen_qr_fixture.py`, cosi' la
## suite non dipende dalla libreria. (Gli oracoli interrogati sono stati due:
## il perche' si e' scelto questo e' scritto nel generatore.)
##
## Il confronto e' per maschera, non solo sulla migliore: sono due difetti
## diversi (i dati piazzati male, la maschera scelta male) e vanno separati.

const QrCode := preload("res://scripts/net/qr_code.gd")
const GOLDEN: String = "res://tests/fixtures/qr_golden.json"


func _golden() -> Dictionary:
	var handle: FileAccess = FileAccess.open(GOLDEN, FileAccess.READ)
	assert_true(handle != null, "la fixture dell'oracolo si legge")
	if handle == null:
		return {}
	var parsed: Variant = JSON.parse_string(handle.get_as_text())
	handle.close()
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _rows_of(modules: Array) -> Array:
	var out: Array = []
	for line in modules:
		var text: String = ""
		for module in line:
			text += "1" if bool(module) else "0"
		out.append(text)
	return out


## Modulo per modulo, maschera per maschera: il disegno del QR, la sua
## correzione d'errore e i bit di formato sono tutti dentro questo confronto.
func test_every_mask_matches_the_oracle() -> void:
	var golden: Dictionary = _golden()
	var compared: int = 0
	for key in golden:
		var parts: PackedStringArray = str(key).rsplit("|", true, 1)
		if parts[1] == "best":
			continue
		var expected: Array = (golden[key] as Dictionary)["rows"]
		var got: Array = _rows_of(QrCode.matrix_with_mask(str(parts[0]), int(parts[1])))
		assert_eq(
			got.size(), expected.size(),
			"«%s» maschera %s: la matrice ha il lato giusto" % [str(parts[0]), parts[1]]
		)
		var same: bool = got == expected
		assert_true(
			same, "«%s» maschera %s: ogni modulo come l'oracolo" % [str(parts[0]), parts[1]]
		)
		if not same and got.size() == expected.size():
			for index in range(got.size()):
				if str(got[index]) != str(expected[index]):
					print("    riga %d attesa %s" % [index, str(expected[index])])
					print("    riga %d ottenuta %s" % [index, str(got[index])])
					break
		compared += 1
	assert_true(compared >= 32, "confrontate tutte le maschere di ogni testo: %d" % compared)


## La maschera che l'encoder sceglie da solo. **Quale** sia non e' un
## invariante fra implementazioni: sullo stesso testo qrcode ha scelto la 7,
## segno la 1 e questo encoder la 2 — il punteggio di penalita' e' un
## euristica, e le tre lo pesano diversamente. Tutte e otto le maschere
## producono un QR valido (sopra si prova che sono identiche all'oracolo),
## quindi qui si prova quello che deve valere davvero: la strada automatica
## sceglie *una delle otto verificate*, senza inventarne una nona — e' cosi'
## che si prende una maschera applicata due volte o un formato dimenticato.
func test_the_chosen_matrix_is_one_of_the_verified_eight() -> void:
	var golden: Dictionary = _golden()
	var checked: int = 0
	for key in golden:
		var parts: PackedStringArray = str(key).rsplit("|", true, 1)
		if parts[1] != "best":
			continue
		var text: String = str(parts[0])
		var chosen: Array = _rows_of(QrCode.matrix(text))
		var found: int = -1
		for mask in range(8):
			if chosen == (golden["%s|%d" % [text, mask]] as Dictionary)["rows"]:
				found = mask
		assert_true(
			found >= 0,
			"«%s»: la matrice scelta e' una delle otto dell'oracolo" % text
		)
		assert_eq(
			int((golden[key] as Dictionary)["version"]), (chosen.size() - 17) / 4,
			"«%s»: e della versione che l'oracolo dichiara" % text
		)
		checked += 1
	assert_true(checked >= 5, "provata la scelta su ogni testo: %d" % checked)


## Il testo che non ci sta non produce un QR storto: non ne produce nessuno,
## e la stanza mostra l'indirizzo scritto (la strada che ha sempre avuto).
func test_a_text_too_long_makes_no_code() -> void:
	var short: Array = QrCode.matrix("http://192.168.1.37:8123/?t=a3f29b1c")
	assert_eq(short.size(), 29, "l'indirizzo di una stanza sta in versione 3")
	var long_text: String = "x".repeat(200)
	assert_true(QrCode.matrix(long_text).is_empty(), "oltre la portata, nessun codice")
	assert_true(
		QrCode.matrix_with_mask(long_text, 0).is_empty(), "nemmeno con la maschera imposta"
	)


## Il riquadro che la stanza disegna: il codice del seggio e' quello del
## suo indirizzo, e un indirizzo fuori portata non produce un quadrato
## qualsiasi — non produce niente, e resta l'indirizzo scritto.
func test_the_room_draws_the_address_it_shows() -> void:
	var view: Control = preload("res://ui/qr_view.gd").new()
	var url: String = "http://192.168.1.37:8123/?t=a3f29b1c"
	view.show_text(url)
	assert_true(view.has_code(), "l'indirizzo di un seggio diventa un codice")
	assert_eq(
		_rows_of(view._matrix), _rows_of(QrCode.matrix(url)),
		"e il codice disegnato e' quello di quell'indirizzo"
	)
	view.show_text("x".repeat(200))
	assert_false(view.has_code(), "quello che non ci sta non diventa un quadrato storto")
	view.free()
