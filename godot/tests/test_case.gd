extends RefCounted
## Minimal assertion base for the ECHOES test suite.
##
## Deliberately not GUT: the whole suite has to run under `godot --headless`
## in CI with no addons and no editor import step, and the assertions it needs
## fit in one file. If the suite ever outgrows this, docs/DECISIONS.md D-008
## records the trade-off.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const TestTable := preload("res://tests/test_table.gd")

var failures: PackedStringArray = PackedStringArray()
var assertions: int = 0

## Set by new_session(); disposed automatically after each test so the runner
## does not leak a session (and its signal cycles) per case.
var session: RefCounted = null

var _current: String = ""


func set_current_test(name: String) -> void:
	_current = name


## Override to build shared fixtures.
func before_each() -> void:
	pass


func after_each() -> void:
	if session != null:
		session.dispose()
		session = null


# --- assertions ------------------------------------------------------------

func assert_true(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		_fail("%s (expected true)" % message)


func assert_false(value: bool, message: String) -> void:
	assertions += 1
	if value:
		_fail("%s (expected false)" % message)


func assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	assertions += 1
	if not _deep_equal(actual, expected):
		_fail("%s\n      atteso:  %s\n      ottenuto: %s" % [message, _show(expected), _show(actual)])


func assert_ne(actual: Variant, unexpected: Variant, message: String) -> void:
	assertions += 1
	if _deep_equal(actual, unexpected):
		_fail("%s (i due valori sono uguali: %s)" % [message, _show(actual)])


## Deep structural equality via the canonical JSON form, which is also what the
## save determinism criterion (§18.3) compares.
static func canonical(value: Variant) -> String:
	return JSON.stringify(value, "", true, false)


static func _deep_equal(a: Variant, b: Variant) -> bool:
	if typeof(a) in [TYPE_DICTIONARY, TYPE_ARRAY] or typeof(b) in [TYPE_DICTIONARY, TYPE_ARRAY]:
		return canonical(a) == canonical(b)
	return a == b


func _show(value: Variant) -> String:
	var text: String = canonical(value)
	return text if text.length() <= 400 else text.substr(0, 400) + "..."


func _fail(message: String) -> void:
	failures.append("%s: %s" % [_current, message])


# --- shared fixtures -------------------------------------------------------

## A loaded, validated DataSet. Cached per test object.
var _data: RefCounted = null


func data() -> RefCounted:
	if _data == null:
		_data = DataSet.new()
		if not _data.load_from("res://data"):
			_fail("i dati non passano la validazione: %s" % _data.describe_errors())
		_add_the_test_table(_data)
	return _data


## **Solo quello che c'e' nella scatola** (D-319).
##
## `data()` porta anche `CHR_TEST`, il banco. Va bene per provare il motore e
## **non** va bene per censire il contenuto: una prova che conta le saghe
## spedite conterebbe anche il banco, e dichiarerebbe una scatola piu' ricca di
## quella che si vende. Chi conta usa questo.
var _shipped_box: RefCounted = null


func shipped_data() -> RefCounted:
	if _shipped_box == null:
		_shipped_box = DataSet.new()
		if not _shipped_box.load_from("res://data"):
			_fail("i dati spediti non passano: %s" % _shipped_box.describe_errors())
	return _shipped_box


## Il banco che la suite si fabbrica, invece di prendere in prestito una
## Chronicle spedita: vedi `tests/test_table.gd` per il perche'.
func _add_the_test_table(into: RefCounted) -> void:
	if not TestTable.add_to(into):
		_fail("il tavolo di prova non si apre: %s" % TestTable.PATH)



## A fresh Chronicle I session at a fixed seed.
##
## `apply_setup` puts the table in its opening position (presence tokens, hands)
## so a unit test can act immediately. Pass false when the test is going to call
## await session.run(), which performs its own setup - applying it twice would deal
## every opening hand a second time.
func new_session(seed_value: int = 4242, apply_setup: bool = true) -> RefCounted:
	if session != null:
		session.dispose()
	session = GameSession.new(data())
	# **La biblioteca si spegne prima che si peschi** (D-207). Da quando anche
	# l'anno d'apertura pesca le sue domande, spegnerla dopo `setup()` non
	# basta: la pesca consuma l'RNG, quindi la prima sessione di un test
	# pescava e la seconda - trovando la dichiarazione gia' spenta - no. Due
	# esecuzioni dello stesso seme davano due partite diverse, ed e' cosi' che
	# si e' visto. Le prove unitarie giocano le quattro domande scritte a mano.
	(session.data.chronicles["CHR_TEST"] as Dictionary)["tension_pool"] = {}
	# E il sacchetto scritto a mano non resta appeso da un piano all'altro:
	# `apply_plan_overrides` scrive sulla definizione **condivisa**, quindi
	# senza questa riga la Chronicle spedita - che il sacchetto non lo scrive
	# piu' - se lo ritroverebbe addosso nella prova dopo.
	(session.data.chronicles["CHR_TEST"] as Dictionary).erase("drift_distribution")
	if not session.setup("CHR_TEST", ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"], seed_value):
		_fail("setup fallito: %s" % session.last_error)
		return session
	# Il Destino pescato (D-150) e' una variabile in piu' sul banco: una suite
	# che non la neutralizza misura la pesca invece del codice — dieci test
	# sono diventati rossi il giorno in cui il pool si e' acceso, tutti perche'
	# davano per scontato che una casa volesse quello che ha sempre voluto.
	# Qui ogni casa torna al Destino scritto sull'Entita'; chi vuole provare il
	# pool lo assegna a mano (test_destiny_pool).
	for entity_id in session.world["entities"]:
		var written: Variant = session.data.entities.get(str(entity_id))
		if written != null:
			session.world["entities"][str(entity_id)]["destiny_id"] = str(written["destiny_id"])
	# Le prove unitarie stanno sul §10 di sempre, e lo dichiarano: vedi
	# `play_classic()`. Chi vuole il lato nuovo dell'interruttore lo accende a
	# mano (test_card_actions), e che i dati spediti ce l'abbiano acceso lo prova
	# un test suo.
	play_classic()
	if apply_setup:
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		session.world["act"] = 1
		session.world["round"] = 1
		session.world["phase"] = "ACTIONS"
	return session


## Una sessione per un piano scriptato, con le dichiarazioni al posto giusto.
##
## `run_chronicle_sim` applica gli override **prima** di `setup()`; questa
## suite li applicava dopo, e fino a 0.1.174 non faceva differenza perche'
## nessun override toccava la pesca. Da D-207 due la toccano - le domande e il
## sacchetto - e applicarli dopo vuol dire due cose insieme: il piano gioca un
## anno diverso da quello che dichiara, e la **seconda** esecuzione dello
## stesso seme trova la definizione gia' riscritta dalla prima e ne gioca un
## terzo. E' la stessa distanza fra la prova e la spedizione che questa suite
## aveva gia' pagato una volta (D-188): qui si chiude prendendo la strada
## della sonda.
func new_session_for_plan(plan: Dictionary, seed_value: int) -> RefCounted:
	if session != null:
		session.dispose()
	session = GameSession.new(data())
	var chronicle_id: String = str(plan["chronicle_id"])
	(session.data.chronicles[chronicle_id] as Dictionary).erase("drift_distribution")
	GameSession.apply_plan_overrides(session.data, plan)
	if not session.setup(chronicle_id, plan["seats"], seed_value):
		_fail("setup fallito: %s" % session.last_error)
		return session
	for entity_id in session.world["entities"]:
		var written: Variant = session.data.entities.get(str(entity_id))
		if written != null:
			session.world["entities"][str(entity_id)]["destiny_id"] = str(written["destiny_id"])
	session.actions.set("_chronicle", session.data.chronicles[chronicle_id])
	return session


## Il §10 di sempre, per le prove che guardano **le azioni** e non l'economia.
##
## Da 0.1.156 CHR_01 gioca con le carte come unica moneta (D-188): prendere
## un'INFLUENZARE con un'Occasione non si puo' piu'. Trentasette prove usavano
## le azioni dirette **per mettere il mondo nella posizione da provare**, non per
## misurare l'economia, e restano vere: l'azione esiste ancora, cambia chi la
## pronuncia. Ogni sessione di prova nasce quindi dal lato classico
## dell'interruttore; il lato nuovo si accende a mano, e che i **dati spediti**
## ce l'abbiano acceso lo prova `test_card_actions`.
func play_classic() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	chronicle["actions_from_cards"] = false
	# Le due meta' si spengono insieme come si accendono insieme (D-184, D-185):
	# il rubinetto sopra ACQUISIRE non e' ne' il gioco vecchio ne' quello nuovo,
	# e misurarlo vuol dire misurare un terzo gioco che nessuno gioca.
	chronicle["hand_refill"] = {}
	# E il §10 di sempre e' anche la presa di parola in due tempi (D-191): si
	# prenota in un round, si riscuote in un altro.
	chronicle["claim_rules"] = {}
	# ...e il calore lo mette la Deriva a orologio, non i giocatori (D-192).
	chronicle["tension_tokens"] = {}
	# ...e si vince salendo tre gradini, non contando quattro obiettivi (D-198).
	#
	# Qui non basta spegnere la regola: `setup()` e' gia' passato, e ha gia'
	# pescato i nascosti sul seggio. Una dichiarazione spenta e tre obiettivi
	# scritti nel mondo sono **due meta' di due giochi diversi**, ed e' lo stesso
	# errore che D-184 aveva gia' pagato una volta col rubinetto. Si spengono
	# insieme, e allora la prova successiva parte davvero dal lato classico.
	chronicle["objectives"] = {}
	for entity_id in session.world["entities"]:
		(session.world["entities"][str(entity_id)] as Dictionary)["objectives"] = []
	# ...e le domande sono le quattro scritte a mano (D-207). Qui la
	# dichiarazione basta, perche' `new_session()` ha gia' spento la biblioteca
	# **prima** di `setup()`: se la spegnesse solo qui, la mano pescata
	# resterebbe sul tavolo e l'RNG sarebbe gia' stato consumato.
	chronicle["tension_pool"] = {}
	# ...e il Consiglio si apre a soglia, round per round, non a fine Atto
	# (D-214). E' l'ultima meta' dell'interruttore: con il Consiglio di chiusura
	# acceso il numero di Consigli di un anno e' un altro, e mezza suite
	# misurerebbe un terzo gioco.
	var rules: Dictionary = (chronicle.get("confluence_rules", {}) as Dictionary).duplicate()
	rules.erase("at_end_of_act")
	chronicle["confluence_rules"] = rules
	session.actions.set("_chronicle", chronicle)
