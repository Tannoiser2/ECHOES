extends "res://tests/test_case.gd"
## Il cervello insegue **quello per cui si vince** ([D-222](DECISIONS.md#d-222)).
##
## Da D-198 la partita si vince contando quattro obiettivi. Fino alla 0.1.189 il
## `PolicyDecider` — il cervello che gioca il cancello — non li leggeva mai:
## `grep -c "objective"` su quel file dava **zero**. Inseguiva le condizioni del
## Destino, e il punteggio ne contava un'altra.
##
## Non è una prova di bilanciamento: è una prova che le due cose **si guardano**.
## Un numero di equilibrio si può ritarare; questa distanza no — finché c'è,
## ogni misura sugli obiettivi dice cosa capita a un seggio che non li persegue.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func before_each() -> void:
	new_session()


## Le clausole che il cervello dice di volere contengono quelle degli obiettivi
## che ha in mano. È l'unico punto da guardare: nove posti del decider leggono
## di qui, quindi da qui l'obiettivo entra in ogni scelta.
func test_the_wanted_conditions_include_the_objectives_in_hand() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	chronicle["objectives"] = {"hidden": 3, "public_from": "victory"}
	session.actions.set("_chronicle", chronicle)
	# Un obiettivo che il seggio non ha ancora preso, e che nessun Destino
	# nomina: se compare fra i moventi, ci è arrivato da qui.
	var seat: Dictionary = session.world["entities"]["ENT_ALDRIC"] as Dictionary
	seat["objectives"] = ["OBJ_A_LEARNED_HOUSE"]

	var decider: RefCounted = PolicyDecider.new(session.log)
	var wanted: Array = decider._conditions("ENT_ALDRIC", session)
	var found: bool = false
	for condition in wanted:
		if str((condition as Dictionary).get("type", "")) == "discovery_count":
			found = true
	assert_true(found, "l'obiettivo in mano è fra le cose che il cervello vuole")


## E un obiettivo **già preso** non è più un movente: è un punto in cassaforte,
## e giocarci contro toglierebbe azioni a quelli che mancano.
func test_an_objective_already_taken_stops_being_a_reason() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	chronicle["objectives"] = {"hidden": 3, "public_from": "victory"}
	session.actions.set("_chronicle", chronicle)
	var seat: Dictionary = session.world["entities"]["ENT_ALDRIC"] as Dictionary
	# «Le Mani Piene» chiede cinque carte in mano: gliele si danno.
	seat["objectives"] = ["OBJ_FULL_HANDS"]
	var decider: RefCounted = PolicyDecider.new(session.log)

	var hand: Array = seat["hand"] as Array
	while hand.size() < 5:
		hand.append("AST_FORCE_LEVY")
	var wanted: Array = decider._conditions("ENT_ALDRIC", session)
	var still_asking: bool = false
	for condition in wanted:
		var kind: String = str((condition as Dictionary).get("type", ""))
		if kind == "asset_threshold" and not (condition as Dictionary).has("family"):
			still_asking = true
	assert_false(still_asking, "un obiettivo già vero non è più una ragione per agire")


## E senza obiettivi in mano il cervello resta quello di prima: il Destino da
## solo. La regola vale in tutte e due le direzioni, o sarebbe un'aggiunta che
## rompe il lato classico dell'interruttore.
func test_without_objectives_the_brain_is_the_one_from_before() -> void:
	var seat: Dictionary = session.world["entities"]["ENT_ALDRIC"] as Dictionary
	seat["objectives"] = []
	var decider: RefCounted = PolicyDecider.new(session.log)
	var wanted: Array = decider._conditions("ENT_ALDRIC", session)
	assert_false(wanted.is_empty(), "il Destino resta")
	for condition in wanted:
		assert_true(
			(condition as Dictionary).has("type"),
			"e sono clausole vere, non residui"
		)
