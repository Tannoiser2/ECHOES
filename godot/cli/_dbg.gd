extends SceneTree
const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
func _initialize() -> void:
	var data: RefCounted = DataSet.new()
	data.load_from("res://data")
	var s: RefCounted = GameSession.new(data)
	print("setup: ", s.setup("CHR_TEST", ["ENT_ALDRIC","ENT_NAHR","ENT_LYRA","ENT_VAERAX"], 9100))
	print("tensioni in gioco: ", (s.world["tensions"] as Dictionary).keys())
	var theme_id: String = str(data.tensions["TEN_FAMINE"].get("theme",""))
	if not s.world.has("theme_heat"): s.world["theme_heat"] = {}
	(s.world["theme_heat"] as Dictionary)[theme_id] = 99
	var ctx: Dictionary = s.confluence.open("TEN_FAMINE", {"kind":"THRESHOLD"})
	print("context vuoto? ", ctx.is_empty(), "  errore: ", s.confluence.last_error)
	print("sides_open: ", s.confluence.sides_open(), " mucchio: ", s.confluence.pile())
	var r: Dictionary = s.confluence.resolve()
	print("resolve chiavi: ", r.keys())
	print("errore: ", s.confluence.last_error)
	quit(0)
