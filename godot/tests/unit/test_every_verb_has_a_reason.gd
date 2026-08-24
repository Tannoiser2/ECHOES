extends "res://tests/test_case.gd"
## Ogni verbo del gioco ha un obiettivo che lo chiede ([D-255](DECISIONS.md#d-255)).
##
## La sonda dei «passa» ha trovato che il 64,9% di chi non fa niente aveva
## quindici mosse legali e sei carte in mano: non gli mancava il permesso, gli
## mancava la ragione. E la ragione, in questo gioco, e' scritta in un posto
## solo — gli obiettivi che il seggio ha pescato, perche' l'anno si vince
## contandoli ([D-198](DECISIONS.md#d-198)).
##
## Contando le clausole si vedeva il buco a occhio nudo: su sedici obiettivi,
## **INFLUENZARE non compariva in nessuno** e **FORGIARE nemmeno**. Il gioco
## offriva sei verbi e ne premiava quattro, e i due muti erano proprio quelli
## che i seggi volevano dire piu' spesso.
##
## Questa prova tiene la riga di quel confine. Non misura niente — i numeri
## stanno in `run_asking_probe.gd` — ma il giorno che qualcuno riscrive un
## obiettivo e lascia un verbo senza nessuna clausola che lo chieda, va rossa
## prima che un tavolo ci passi sopra un anno intero.

## Quale clausola premia quale verbo. Un verbo assente da questa mappa e' un
## verbo che il mazzo degli obiettivi non sa chiedere.
const REASON_FOR: Dictionary = {
	"INFLUENZARE": ["tension_count", "tension_limit"],
	"TRAMARE": ["discovery_count"],
	"RIVENDICARE": ["control_count"],
	"MUOVERE": ["region_presence"],
	"FORGIARE": ["relation_state"],
}
## `leads_in` non nomina un verbo: dice «piu' di tutti» su una moneta, e la
## moneta la si prende col verbo che le corrisponde. Conta per quel verbo.
const LEADS_IN_MEANS: Dictionary = {
	"control": "RIVENDICARE",
	"presence": "MUOVERE",
}


func before_each() -> void:
	new_session()


## Una DataSet tutta sua: quella condivisa la riscrivono altre prove, e una
## prova sui **dati della scatola** non puo' misurare l'attrezzo di scena di
## qualcun altro.
func _shipped() -> RefCounted:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	return loaded


func test_no_verb_is_left_without_an_objective_that_asks_for_it() -> void:
	var asked: Dictionary = _verbs_asked(_shipped())
	for verb in REASON_FOR:
		assert_true(
			int(asked.get(str(verb), 0)) > 0,
			"almeno un obiettivo chiede %s" % [str(verb)]
		)


## E che il verbo trovato muto dalla sonda non torni muto: INFLUENZARE aveva
## zero clausole su quindici obiettivi mentre era il 79% delle intenzioni che
## la mano non sapeva dire.
func test_influencing_is_asked_by_name() -> void:
	var asked: Dictionary = _verbs_asked(_shipped())
	assert_true(
		int(asked.get("INFLUENZARE", 0)) > 0,
		"il verbo piu' desiderato del gioco ha un obiettivo che lo chiede"
	)


## Quante clausole chiedono ciascun verbo, in tutto il mazzo.
func _verbs_asked(loaded: RefCounted) -> Dictionary:
	var found: Dictionary = {}
	for objective_id in loaded.objectives:
		var objective: Dictionary = loaded.objectives[str(objective_id)]
		for condition in objective["conditions"]:
			_count(condition as Dictionary, found)
	return found


func _count(condition: Dictionary, found: Dictionary) -> void:
	var kind: String = str(condition.get("type", ""))
	for verb in REASON_FOR:
		if (REASON_FOR[str(verb)] as Array).has(kind):
			found[str(verb)] = int(found.get(str(verb), 0)) + 1
	if kind == "leads_in":
		var what: String = str(condition.get("what", ""))
		if LEADS_IN_MEANS.has(what):
			var verb: String = str(LEADS_IN_MEANS[what])
			found[verb] = int(found.get(verb, 0)) + 1
	for sub in condition.get("conditions", []):
		_count(sub as Dictionary, found)
