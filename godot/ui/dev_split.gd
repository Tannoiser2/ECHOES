extends Control
## Il cavalletto della fase 1 (voce 27 — D-134): le due viste dallo stesso
## mondo, affiancate. Non e' un modo di gioco: e' lo strumento con cui si
## guarda che il tavolo mostri il tavolo e la console mostri il seggio,
## prima che in mezzo ci sia una rete.
##
##   godot --path godot res://ui/dev_split.tscn
##
## Gioca una Chronicle in automatico (stessi semi delle sonde) e poi affianca
## la vetrina e la console del primo seggio. Clic su una Regione: l'ispezione.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const TableView := preload("res://ui/table_view.gd")
const ConsoleView := preload("res://ui/console_view.gd")

const CHRONICLE: String = "CHR_00"
const SEED: int = 7000


func _ready() -> void:
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		var sorry := Label.new()
		sorry.text = "I dati non si caricano: %s" % ", ".join(PackedStringArray(data.errors))
		add_child(sorry)
		return
	var session: RefCounted = GameSession.new(data)
	var seats: Array = (data.chronicles[CHRONICLE]["entities"] as Array).duplicate()
	session.setup(CHRONICLE, seats, SEED)
	await session.run(PolicyDecider.new(session.log))

	var split := HSplitContainer.new()
	split.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(split)

	var table: Control = TableView.new()
	table.custom_minimum_size = Vector2(760, 0)
	split.add_child(table)
	var console: Control = ConsoleView.new()
	console.custom_minimum_size = Vector2(360, 0)
	split.add_child(console)

	table.render(session)
	var seat: String = str(session.world["turn_order"][0])
	console.render(session, seat)
	console.say("La console di %s: quello che vedi qui non sta sul tavolo." % session.service.name_of(seat))
