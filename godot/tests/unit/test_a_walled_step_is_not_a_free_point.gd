extends "res://tests/test_case.gd"
## Un segno mai scritto vale **due difetti opposti**, e per due versioni la
## misura dei segni li ha messi nella stessa lista
## ([D-346](../../docs/DECISIONS.md#d-346)).
##
## `MISURA_SEGNI.md` chiudeva con una tabella sola, intitolata «punti regalati»,
## e sotto ci finivano tutti i segni che il mondo non scrive mai. Meta' erano il
## contrario di un punto regalato: le clausole `state_tag_present` non diventano
## vere dall'apertura, **non diventano vere mai**. Quattro passi di Destino di
## Vaerax stavano li' dentro, letti come regali.
##
## Il documento non falliva: nessun cancello puo' accorgersi che una frase
## racconta il rovescio di meta' della sua tabella. Quindi la parte che decide
## sta in una funzione **pura** — `letture()` — e questa prova la interroga su un
## difetto piantato, uno per verso.

const Probe := preload("res://cli/run_world_marks_probe.gd")

## Il verso che regala: nessuno lo scrive, una clausola lo **teme**.
const REGALATO: String = "segno_temuto_e_mai_scritto"
## Il verso che mura: nessuno lo scrive, una clausola lo **vuole**.
const MURATO: String = "segno_voluto_e_mai_scritto"
## E quello che fa tutte e due le cose insieme, che e' il caso vero di
## `mine_sealed`: regala un passo a Lyra e ne mura uno a Vaerax.
const TUTTI_E_DUE: String = "segno_temuto_e_voluto"


func _tags(rows: Array) -> Array:
	var out: Array = []
	for row in rows:
		out.append(str((row as Array)[0]))
	return out


func test_the_two_defects_do_not_share_a_list() -> void:
	var letto: Dictionary = Probe.letture(
		{},
		{REGALATO: 1, TUTTI_E_DUE: 3},
		{MURATO: 1, TUTTI_E_DUE: 2},
		10,
	)
	var regalati: Array = _tags(letto["regalati"] as Array)
	var murate: Array = _tags(letto["murate"] as Array)

	assert_true(regalati.has(REGALATO), "chi teme un segno mai scritto ha un punto regalato")
	assert_false(
		murate.has(REGALATO),
		"e non e' una porta murata: la clausola che lo teme e' vera, non falsa"
	)

	assert_true(murate.has(MURATO), "chi vuole un segno mai scritto ha una porta murata")
	assert_false(
		regalati.has(MURATO),
		"e non e' un punto regalato: e' il difetto opposto, ed e' quello che la"
		+ " 0.1.310 stampava sotto il titolo sbagliato"
	)

	assert_true(
		regalati.has(TUTTI_E_DUE) and murate.has(TUTTI_E_DUE),
		"e lo stesso segno puo' stare in tutte e due: e' il caso di `mine_sealed`"
	)


## L'altra meta' della funzione, che il rifacimento poteva rompere in silenzio.
func test_a_sign_the_world_writes_is_in_no_list() -> void:
	var letto: Dictionary = Probe.letture(
		{"segno_scritto_e_guardato": 40, "segno_scritto_e_muto": 40},
		{"segno_scritto_e_guardato": 1},
		{},
		10,
	)
	assert_eq(_tags(letto["mute"] as Array), ["segno_scritto_e_muto"], "il segno muto e' uno solo")
	assert_true((letto["regalati"] as Array).is_empty(), "e niente e' regalato: il mondo scrive")
	assert_true((letto["murate"] as Array).is_empty(), "ne' murato, per la stessa ragione")


## E la soglia dei muti e' una soglia: sotto, il segno non e' «lavoro del
## motore», e' solo raro.
func test_a_rare_sign_is_not_engine_noise() -> void:
	var letto: Dictionary = Probe.letture({"segno_raro": 3}, {}, {}, 10)
	assert_true((letto["mute"] as Array).is_empty(), "tre volte in cento partite non e' rumore")


## La terza riparazione di ISSUES 102: **una clausola non e' un lettore.**
##
## Le colonne «temuto» e «voluto» contano solo i passi di Destini e Obiettivi.
## Un segno che nessun passo nomina, ma che una regola del segno interroga, non
## e' «lavoro del motore che al tavolo non conta niente»: e' una regola, e sta
## solo fuori dal punteggio. Prima di questa riga il documento ne dichiarava
## muti **venti**, e sedici non lo erano — fra cui `condition:guarded`, che da
## D-353 vieta di tramare.
func test_a_clause_is_not_a_reader() -> void:
	var scritti: Dictionary = {"letto_da_una_regola": 40, "muto_davvero": 40}
	var senza_lettori: Dictionary = Probe.letture(scritti, {}, {}, 10)
	assert_eq(
		_tags(senza_lettori["mute"] as Array).size(), 2,
		"senza sapere chi legge, tutt'e due sembrano muti: e' la misura di prima"
	)

	var con_lettori: Dictionary = Probe.letture(
		scritti, {}, {}, 10, {"letto_da_una_regola": ["tag_rule"]}
	)
	var muti: Array = _tags(con_lettori["mute"] as Array)
	assert_eq(
		muti, ["muto_davvero"],
		"chi ha una mano che lo legge esce dalla lista dei muti, anche senza clausole"
	)


## E un lettore non salva un segno dagli altri due difetti: chi lo **vuole** ha
## una porta murata comunque, che qualcuno lo legga o no.
func test_a_reader_does_not_unwall_a_step() -> void:
	var letto: Dictionary = Probe.letture(
		{}, {}, {"voluto_e_mai_scritto": 1}, 10, {"voluto_e_mai_scritto": ["tag_rule"]}
	)
	assert_eq(
		_tags(letto["murate"] as Array), ["voluto_e_mai_scritto"],
		"la porta resta murata: il mondo non lo scrive, e nessun lettore lo scrive al posto suo"
	)
