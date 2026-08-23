extends "res://tests/test_case.gd"
## Un obiettivo di saga non puo' spegnersi per sempre (ISSUES 58, D-237).
##
## Dal 0.1.208 i tre coperti si pescano **una volta per saga** e poi si
## ereditano. La voce diceva il costo con precisione: *un obiettivo pescato a
## inizio saga puo' risultare **impossibile** nel mondo che la Chronicle 4 ha
## prodotto — un obiettivo che nomina una Regione svuotata, o una casa che non
## si siede piu'.* E offriva due strade: obiettivi che valgano in qualunque
## mondo, **oppure** una regola di sostituzione dichiarata.
##
## Il gioco ha gia' preso la prima: nessuno dei quindici nomina una Regione o
## una casa — sono tutti scritti su **quanto** e non su **dove**
## ([D-221](DECISIONS.md#d-221)). Cioe' la premessa della regola nuova era gia'
## vera; non era pero' **tenuta** da niente, e una premessa che nessuno sorveglia
## e' una premessa che scade.
##
## Questa e' quella guardia. Il giorno che qualcuno scrive «tieni la Valle
## Verde» fra gli obiettivi condivisi, questa prova va rossa **prima** che una
## saga scopra al quinto anno di inseguire un posto che non c'e' piu'.

func before_each() -> void:
	new_session()


## Una DataSet tutta sua, letta dai file.
##
## Quella condivisa la riscrivono altre prove — `chronicle["objectives"]`
## diventa un attrezzo di scena in tre posti — e una prova che legge i **dati
## della scatola** non puo' misurare l'attrezzo di scena di qualcun altro. Ha
## gia' detto il falso una volta, contando tre Chronicle su quattro.
func _shipped() -> RefCounted:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	return loaded


## Nessun obiettivo condiviso nomina una Regione o una casa.
func test_no_shared_objective_names_a_place_or_a_house() -> void:
	var loaded: RefCounted = _shipped()
	var checked: int = 0
	for objective_id in loaded.objectives:
		var objective: Dictionary = loaded.objectives[str(objective_id)] as Dictionary
		var named: Array = []
		_names_in(objective.get("conditions", []), named)
		assert_true(
			named.is_empty(),
			"l'obiettivo '%s' nomina %s: in una saga di dieci anni quel posto puo' non esserci piu'" % [
				str(objective_id), ", ".join(PackedStringArray(named)),
			]
		)
		checked += 1
	assert_true(checked >= 15, "e vale per tutti quelli della scatola: %d" % checked)


## Ogni identificatore di Regione o di casa dentro una condizione, a qualunque
## profondita'. `$self` non conta: e' chi legge la clausola, e c'e' sempre.
func _names_in(conditions: Array, into: Array) -> void:
	for entry in conditions:
		var condition: Dictionary = entry as Dictionary
		for key in condition:
			var value: Variant = condition[key]
			if typeof(value) == TYPE_STRING:
				var text: String = str(value)
				if key.ends_with("label") or key == "description":
					continue
				if text.begins_with("REG_") or text.begins_with("ENT_"):
					into.append(text)
			elif typeof(value) == TYPE_ARRAY and key in ["conditions", "all", "any"]:
				_names_in(value as Array, into)


## E la regola e' **dichiarata**, non implicita: la Chronicle dice quando si
## pescano i coperti, e senza dichiarazione si torna al comportamento di prima.
## E' l'idioma di casa — un'assenza vuol dire assenza — e qui serve a due cose:
## si spegne senza toccare il codice, e chi legge i dati sa che regola sta
## giocando senza doverlo dedurre.
func test_the_rule_is_written_in_the_data() -> void:
	var loaded: RefCounted = _shipped()
	var declared: int = 0
	for chronicle_id in loaded.chronicles:
		var rules: Dictionary = (
			loaded.chronicles[str(chronicle_id)] as Dictionary
		).get("objectives", {}) as Dictionary
		if rules.is_empty():
			continue
		assert_true(
			rules.has("drawn"),
			"la Chronicle '%s' dice quando pesca i coperti" % str(chronicle_id)
		)
		assert_eq(
			str(rules["drawn"]), "per_saga",
			"e le Chronicle della scatola li pescano una volta per saga (D-237)"
		)
		declared += 1
	assert_true(declared >= 4, "per ogni Chronicle che gioca a obiettivi: %d" % declared)


## I tre d'apertura restano gli stessi l'anno dopo.
##
## E' la regola in una riga, provata sul motore invece che sui dati: due anni
## incatenati, e i coperti del secondo sono quelli del primo. Senza questa prova
## la dichiarazione nei dati potrebbe essere vera e il codice ignorarla.
func test_the_three_survive_the_handover() -> void:
	var loaded: RefCounted = _shipped()
	# **Lo stesso tavolo nei due anni.** Una Chronicle pesca quattro case su
	# otto, e con due semi diversi il secondo anno seggono altre quattro: la
	# prova misurerebbe il ricambio invece della regola. Che il ricambio esista
	# e' vero e sta scritto a verbale (D-237) — ma e' un'altra domanda.
	var first: RefCounted = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_01", 4242)
	assert_true(first.setup("CHR_01", seats, 4242), "il primo anno si apre")
	for effect in first.factory_setup_effects():
		first.applier.apply(effect)

	var before: Dictionary = {}
	for entity_id in first.world["entities"]:
		before[str(entity_id)] = (
			(first.world["entities"][str(entity_id)] as Dictionary).get("objectives", []) as Array
		).duplicate()

	var second: RefCounted = GameSession.new(loaded)
	assert_true(second.setup("CHR_02", seats, 4343), "il secondo anno si apre")
	second.inherit_from(first.world, {})

	var carried: int = 0
	for entity_id in second.world["entities"]:
		var who: String = str(entity_id)
		if not before.has(who) or (before[who] as Array).is_empty():
			continue
		assert_eq(
			(second.world["entities"][who] as Dictionary).get("objectives", []), before[who],
			"i tre coperti di %s sono ancora quelli dell'apertura" % who
		)
		carried += 1
	assert_true(carried >= 3, "e succede per i seggi che erano gia' al tavolo: %d" % carried)
	first.dispose()
	second.dispose()
