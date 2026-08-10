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
## session.run(), which performs its own setup - applying it twice would deal
## every opening hand a second time.
func new_session(seed_value: int = 4242, apply_setup: bool = true) -> RefCounted:
	if session != null:
		session.dispose()
	session = GameSession.new(data())
	if not session.setup("CHR_01", ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"], seed_value):
		_fail("setup fallito: %s" % session.last_error)
		return session
	if apply_setup:
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		session.world["act"] = 1
		session.world["round"] = 1
		session.world["phase"] = "ACTIONS"
	return session
