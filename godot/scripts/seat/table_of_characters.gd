extends RefCounted
## Quattro modi diversi di stare allo stesso tavolo (D-053).
##
## `PolicyDecider` gioca il proprio Destino nel modo migliore che sa, e a ogni
## seggio ce n'e uno identico. E' l'attrezzo giusto per misurare le regole e
## quello sbagliato per misurare una partita: la D-051 ha misurato quattro giri
## di modifiche al contenuto e ha visto spostarsi *quali* seggi vincevano e mai
## la forma della distribuzione, e ha concluso - senza poterlo dimostrare - che
## la causa fosse l'ottimizzatore e non le clausole.
##
## Questo e il modo di provarlo. Ogni carattere e la stessa policy con una cosa
## diversa: nessuno di loro bara, tutti passano dagli stessi controlli di
## legalita, e nessuno sa niente che un giocatore non saprebbe. Se un tavolo
## misto produce una distribuzione dove quattro ottimizzatori producevano 40/40,
## l'ipotesi regge. Se non la produce, era il contenuto, e la D-051 aveva torto.
##
## Deterministico: le scelte non ovvie passano dall'RNG della sessione, quindi
## stesso seme, stessa partita.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const NAMES: Array = ["prudente", "aggressivo", "distratto", "ostinato"]


## Chi si siede dove, per una partita. Una permutazione dei quattro caratteri
## scelta dal seme, cosi ogni seggio nell'arco di cento partite viene giocato da
## ognuno di loro all'incirca lo stesso numero di volte - che e l'unico modo di
## separare "questo Destino e difficile" da "questo giocatore e cauto".
static func deal(seats: Array, rng: RefCounted, log: RefCounted) -> RefCounted:
	var order: Array = rng.shuffle(NAMES.duplicate())
	var players: Dictionary = {}
	var who: Dictionary = {}
	for i in range(seats.size()):
		var character: String = str(order[i % order.size()])
		players[str(seats[i])] = make(character, log)
		who[str(seats[i])] = character
	return Table.new(players, who)


static func make(character: String, log: RefCounted) -> RefCounted:
	match character:
		"prudente": return Prudente.new(log)
		"aggressivo": return Aggressivo.new(log)
		"distratto": return Distratto.new(log)
		"ostinato": return Ostinato.new(log)
	return PolicyDecider.new(log)


## Non alza la voce. Non si oppone quasi mai - una condizione, semmai - e tiene
## le carte in mano invece di spenderle: al Consiglio ne impegna il minimo.
##
## E' il giocatore che al tavolo dice "va bene" per non litigare, e che a fine
## anno ha una mano bellissima e niente di deciso.
class Prudente extends PolicyDecider:
	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		var declared: Dictionary = super.choose_stance(entity_id, context, session)
		if str(declared["stance"]) != "OPPOSE":
			return declared
		var clause: String = _best_clause(entity_id, context, session)
		return (
			{"stance": "CONDITION", "clause_id": clause} if clause != ""
			else {"stance": "ABSTAIN", "clause_id": ""}
		)

	## Tiene le carte in mano - una in meno di quante ne spenderebbe la policy -
	## tranne quando sta ponendo una condizione. Una condizione che non si
	## qualifica non vale niente, quindi chi negozia paga il prezzo del negoziato:
	## e' la differenza fra essere cauti e non aver capito la regola.
	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		var wanted: Array = super.choose_commit(entity_id, context, limit, session)
		var stance: String = str(
			session.confluence.current.get("stances", {}).get(entity_id, {}).get("stance", "")
		)
		if stance == "CONDITION":
			return wanted
		return wanted.slice(0, maxi(1, wanted.size() - 1))


## Blocca tutto quello che non lo aiuta, anche quando gli costa poco, e impegna
## tutto quello che ha. Non contratta: una proposta o e sua o e contro di lui.
class Aggressivo extends PolicyDecider:
	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		var declared: Dictionary = super.choose_stance(entity_id, context, session)
		if str(declared["stance"]) == "CONDITION" or str(declared["stance"]) == "ABSTAIN":
			var proposition: Dictionary = _current_proposition(context, session)
			if not proposition.is_empty():
				var score: int = _score_proposition(
					proposition, entity_id, str(context["proponent"]), session
				)
				if score <= 0:
					return {"stance": "OPPOSE", "clause_id": ""}
		return declared

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		return session.service.ranked_hand_for_tension(
			entity_id, str(context["tension_id"])
		).slice(0, limit)


## Ogni tanto fa un'altra cosa. Non sbaglia le regole - chiede sempre qualcosa di
## legale - ma non prende sempre la mossa migliore, che e il modo in cui gioca
## chiunque non stia contando.
##
## Un giro su quattro, e il giro lo decide l'RNG della sessione: la partita resta
## rigiocabile dal seme.
class Distratto extends PolicyDecider:
	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		var best: Dictionary = super.choose_action(entity_id, ao_index, session)
		if session.rng.range_int(0, 3) != 0:
			return best
		# Qualcosa d'altro, purche si possa fare: la famiglia sbagliata, un giro
		# a vuoto, una presenza messa dove non serviva.
		var families: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]
		var family: String = str(families[session.rng.range_int(0, families.size() - 1)])
		var other: Dictionary = {"template": "ACQUIRE", "params": {"family": family}}
		if session.actions.can_execute(entity_id, "ACQUIRE", other["params"]):
			return other
		return best


## Gioca per il Trionfo dal primo round, invece che per il gradino piu vicino.
## Spesso arriva a mani vuote; ogni tanto arriva dove gli altri non arrivano.
class Ostinato extends PolicyDecider:
	func _open_levels(entity_id: String, session: RefCounted) -> Array:
		var destiny: Dictionary = _destiny(entity_id, session)
		if destiny.is_empty():
			return []
		var top: Array = destiny["triumph"]["conditions"]
		if not session.destinies.conditions.all_hold(top, {}):
			return [top]
		return super._open_levels(entity_id, session)


## Il tavolo vero e proprio: il controller chiede a *un* decider, e questo gira
## la domanda al carattere seduto in quel seggio. Le domande che non nominano un
## seggio - la scelta della domanda e della proposta - vanno al proponente, che
## e chi le sta facendo.
class Table extends RefCounted:
	var seats: Dictionary = {}
	var names: Dictionary = {}

	func _init(p_seats: Dictionary, p_names: Dictionary) -> void:
		seats = p_seats
		names = p_names

	func _who(entity_id: String) -> RefCounted:
		return seats[entity_id]

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		return _who(entity_id).choose_action(entity_id, ao_index, session)

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return _who(str(context["proponent"])).choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		return _who(str(context["proponent"])).choose_proposition(context, options, session)

	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		return _who(entity_id).choose_stance(entity_id, context, session)

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		return _who(entity_id).choose_commit(entity_id, context, limit, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return _who(str(context["proponent"])).choose_recovery(context, session)
