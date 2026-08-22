extends RefCounted
## Minimal assertion base for the ECHOES test suite.
##
## Deliberately not GUT: the whole suite has to run under `godot --headless`
## in CI with no addons and no editor import step, and the assertions it needs
## fit in one file. If the suite ever outgrows this, docs/DECISIONS.md D-008
## records the trade-off.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")

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
	return _data


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
	if not session.setup("CHR_01", ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"], seed_value):
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
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
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
	session.actions.set("_chronicle", chronicle)
