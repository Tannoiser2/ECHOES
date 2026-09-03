extends "res://tests/test_case.gd"
## **La cosa meno peggio** (ISSUES 128, D-424).
##
## Il cervello ha due frasi scritte dentro: *«spingere una domanda dalla parte
## sbagliata e' peggio che non fare niente»* e *«rompere un patto per noia e' un
## prezzo, non un ripiego»*. Sono vere, e sono vere **finche' stare fermi si
## puo'**: al tavolo una persona con una mano e un turno da spendere gioca la
## cosa che le costa meno, anche quando le costa.
##
## Misurato: delle carte mute in mano, l'87,6% lo era per una di quelle due — non
## per le regole del tavolo.
##
## Questa prova tiene fermi i due versi della regola, e il secondo conta quanto
## il primo: **nel giro normale il cervello resta prudente**. Un interruttore che
## restasse acceso cambierebbe tutte le partite invece del solo turno vuoto, e
## non si vedrebbe da nessun numero se non molto piu' tardi.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


## **I desideri si fabbricano, non si cercano** (regola di casa).
##
## `_targets_for` prende i desideri come parametro, e la prima stesura di questa
## prova li chiedeva al Destino del seggio su CHR_TEST — che non ne ha. Le due
## prove passavano su zero bersagli contro zero, cioe' **non provavano niente**:
## quattordicesima volta in questo progetto che un numero fermo era chi guardava.
##
## Qui se ne costruiscono due: una domanda che il Destino vuole **salire** e una
## che vuole **scendere**. Cosi' si misura la regola, non quale Destino e' uscito.
func _two_wishes() -> Dictionary:
	var tensions: Array = session.world["tensions"].keys()
	assert_true(tensions.size() >= 2, "sul tavolo ci sono almeno due domande")
	return {str(tensions[0]): 1, str(tensions[1]): -1}


## **Nel giro normale INFLUENZARE si offre solo nel verso che il Destino vuole.**
func test_the_normal_pass_stays_prudent() -> void:
	var brain: RefCounted = PolicyDecider.new(session.log)
	var goals: Dictionary = _two_wishes()

	var wanted: Array = brain._targets_for(SEAT, "INFLUENCE", {"delta": 1}, goals, session)
	assert_eq(wanted.size(), 1, "una sola delle due domande vuole salire")
	for target in wanted:
		var tension_id: String = str((target as Dictionary)["tension_id"])
		assert_eq(
			int(goals[tension_id]), 1,
			"«%s» si offre solo dove il Destino vuole salire" % tension_id
		)


## **E quando non c'e' niente di meglio, anche il verso storto.** Senza questa
## meta' la regola non esisterebbe: e' tutto qui il cambiamento.
func test_with_nothing_better_the_wrong_way_opens() -> void:
	var brain: RefCounted = PolicyDecider.new(session.log)
	var goals: Dictionary = _two_wishes()
	var prudent: int = brain._targets_for(SEAT, "INFLUENCE", {"delta": 1}, goals, session).size()

	brain._no_better_move = true
	var desperate: Array = brain._targets_for(SEAT, "INFLUENCE", {"delta": 1}, goals, session)
	brain._no_better_move = false

	assert_true(
		desperate.size() > prudent,
		"con l'interruttore alzato ci sono piu' bersagli: %d contro %d" % [
			desperate.size(), prudent
		]
	)
	# E fra i nuovi c'e' almeno una domanda che il Destino vorrebbe **scendere**:
	# e' la mossa che fa male, ed e' quella che si deve poter fare.
	var wrong_way: int = 0
	for target in desperate:
		if int(goals[str((target as Dictionary)["tension_id"])]) != 1:
			wrong_way += 1
	assert_true(wrong_way > 0, "e almeno una va nel verso che il Destino non vuole")


## **E FORGIARE puo' scendere, ma solo li'.** L'altra delle due frasi.
func test_forging_downward_only_when_there_is_nothing_else() -> void:
	var brain: RefCounted = PolicyDecider.new(session.log)
	var goals: Dictionary = _two_wishes()

	for target in brain._targets_for(SEAT, "FORGE", {}, goals, session):
		assert_eq(
			str((target as Dictionary)["direction"]), "UP",
			"nel giro normale si forgia solo in su"
		)

	brain._no_better_move = true
	var desperate: Array = brain._targets_for(SEAT, "FORGE", {}, goals, session)
	brain._no_better_move = false

	var down: int = 0
	for target in desperate:
		if str((target as Dictionary).get("direction", "")) == "DOWN":
			down += 1
	assert_true(down > 0, "e quando non resta altro si puo' rompere un patto")


## **L'interruttore si riabbassa sempre.** E' la prova che vale le altre: se
## restasse alzato, il cervello smetterebbe di essere prudente **in tutte** le
## partite invece che nel solo turno vuoto — e la differenza si vedrebbe solo
## molto piu' tardi, in un numero che nessuno starebbe guardando.
func test_the_switch_falls_back_down() -> void:
	var brain: RefCounted = PolicyDecider.new(session.log)
	assert_false(brain._no_better_move, "parte abbassato")
	# Il ripiego lo alza e lo riabbassa da solo: si chiama e si guarda dopo.
	brain._rather_than_nothing(SEAT, session)
	assert_false(brain._no_better_move, "e dopo il ripiego e' di nuovo abbassato")
