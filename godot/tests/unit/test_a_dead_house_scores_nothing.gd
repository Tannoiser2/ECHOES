extends "res://tests/test_case.gd"
## **Una casa spenta non segna** (D-316).
##
## La regola c'era gia', ma scritta **diciassette volte**: una clausola
## `entity_alive` nel Minimo di diciassette Destini su ventitre'. Funzionava,
## perche' i livelli sono cumulativi e cadere sul Minimo spegne anche Vittoria
## e Trionfo. Ma costava due cose: **mezza riga del Minimo stampato** spesa a
## dire «e non sei morto», che al tavolo non e' un obiettivo ma il presupposto
## per averne uno; e nella misura di D-314 quelle clausole risultavano centrate
## 113 volte su 113 e **contese mai** — la voce piu' grossa fra i punti che
## nessuno doveva giocarsi.
##
## Adesso la regola sta in un posto solo e vale per **tutti e ventitre'** i
## Destini, non per diciassette. Qui si prova che vale davvero, e — cosa che
## importa di piu' — che vale **anche sui sei Destini che la clausola non
## l'avevano mai avuta**.



func before_each() -> void:
	new_session()


func _first_seat() -> String:
	for entity_id in session.world["turn_order"]:
		return str(entity_id)
	return ""


## Il caso che deve dare **non-NONE**: senza, un NONE costante passerebbe e la
## prova non proverebbe niente.
func test_a_living_house_still_climbs() -> void:
	var seat: String = _first_seat()
	assert_false(seat.is_empty(), "c'e' un seggio al tavolo")
	var destiny_id: String = str(
		(session.world["entities"][seat] as Dictionary)["destiny_id"]
	)
	var alive: Dictionary = session.destinies.evaluate(destiny_id, seat)
	assert_true(
		bool((session.world["entities"][seat] as Dictionary)["active"]),
		"il seggio e' vivo"
	)
	assert_ne(str(alive["level"]), "", "un seggio vivo riceve un livello")


## E il caso vero: spegnere la casa, e il Destino si chiude.
func test_a_dead_house_reaches_nothing() -> void:
	var seat: String = _first_seat()
	var entity: Dictionary = session.world["entities"][seat] as Dictionary
	var destiny_id: String = str(entity["destiny_id"])
	entity["active"] = false
	var dead: Dictionary = session.destinies.evaluate(destiny_id, seat)
	assert_eq(str(dead["level"]), "NONE", "una casa spenta non arriva da nessuna parte")
	for name in ["MINIMUM", "VICTORY", "TRIUMPH"]:
		assert_false(
			bool((dead["levels"] as Dictionary)[str(name)]),
			"e nemmeno %s le viene riconosciuto" % [name]
		)
	assert_false(
		(dead["evidence"] as Array).is_empty(),
		"il verbale dice perche' il Destino si e' chiuso"
	)


## La cosa che il taglio ha **guadagnato**: i Destini che non avevano la
## clausola adesso sono coperti anche loro. Prima una casa spenta che portava
## `DST_CENERE` poteva arrivare al Minimo da morta.
func test_the_gate_now_covers_every_destiny_at_the_table() -> void:
	var checked: int = 0
	for destiny_id in session.data.destinies:
		var destiny: Dictionary = session.data.destinies[str(destiny_id)]
		# Il cancello guarda **la casa del Destino**, non chi lo passa alla
		# funzione: il Destino e' di quella casa, e si chiude con lei. I
		# Destini condivisibili (`$self`) si risolvono su chi li giura.
		var owner: String = str(destiny["entity_id"])
		if owner == "$self":
			owner = _first_seat()
		var entity: Variant = session.world["entities"].get(owner)
		if entity == null:
			continue  # una casa di un'altra Chronicle: non siede a questo tavolo
		var was: bool = bool((entity as Dictionary)["active"])
		(entity as Dictionary)["active"] = false
		var out: Dictionary = session.destinies.evaluate(str(destiny_id), owner)
		(entity as Dictionary)["active"] = was
		assert_eq(str(out["level"]), "NONE", "%s: da morti non si sale" % [destiny_id])
		checked += 1
	# La prova non deve poter smettere di provare in silenzio se un giorno
	# i dati cambiano casa.
	assert_true(checked >= 8, "provati almeno gli otto Destini del tavolo (%d)" % [checked])


## E la ragione per cui il taglio era sicuro: **nessun Minimo e' rimasto vuoto**.
## Un livello senza clausole si avvera da solo, e sarebbe stato un regalo piu'
## grosso di quello tolto.
func test_no_level_was_left_empty() -> void:
	for destiny_id in session.data.destinies:
		var destiny: Dictionary = session.data.destinies[str(destiny_id)]
		for level in ["minimum", "victory", "triumph"]:
			if level == "triumph":
				continue
			assert_false(
				(destiny[level]["conditions"] as Array).is_empty(),
				"%s/%s chiede ancora qualcosa" % [destiny_id, level]
			)


## E che la clausola sia sparita davvero da tutti i Destini: se ne resta una,
## la regola e' scritta in due posti e i due posti divergeranno.
func test_the_clause_is_gone_from_every_destiny() -> void:
	var left: Array = []
	for destiny_id in session.data.destinies:
		var destiny: Dictionary = session.data.destinies[str(destiny_id)]
		for level in ["minimum", "victory", "triumph"]:
			for condition in (destiny[level]["conditions"] as Array):
				if str((condition as Dictionary).get("type", "")) == "entity_alive":
					left.append("%s/%s" % [destiny_id, level])
	assert_eq(left.size(), 0, "nessun Destino dice piu' «e sei vivo»: %s" % [str(left)])
