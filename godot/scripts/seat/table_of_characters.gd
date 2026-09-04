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
		# Senza la CONDITION (D-454) chi non litiga si astiene: non c'e' piu'
		# una via di mezzo con le carte in mano.
		return {"stance": "ABSTAIN", "clause_id": ""}

	## Tiene le carte in mano - una in meno di quante ne spenderebbe la policy.
	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		var wanted: Array = super.choose_commit(entity_id, context, limit, session)
		return wanted.slice(0, maxi(1, wanted.size() - 1))


## Blocca tutto quello che non lo aiuta, anche quando gli costa poco, e impegna
## tutto quello che ha. Non contratta: una proposta o e sua o e contro di lui.
class Aggressivo extends PolicyDecider:
	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		var declared: Dictionary = super.choose_stance(entity_id, context, session)
		if str(declared["stance"]) == "ABSTAIN":
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
		# Qualcosa d'altro, purché si possa fare: la famiglia sbagliata, un giro
		# a vuoto, una presenza messa dove non serviva.
		#
		# Quando le carte sono l'unica moneta (D-188) la distrazione cambia
		# forma: non si pesca la famiglia sbagliata, si **spende la carta
		# sbagliata** — una a caso fra quelle che la mano puo' giocare. Prima di
		# questa riga il distratto chiedeva un ACQUISIRE che non esiste piu', e
		# se lo vedeva rifiutare: 93 Occasioni buttate su 20 partite, e i suoi
		# NONE passati da 2 a 8.
		if _cards_are_the_coin(session):
			var plays: Array = hand_plays(entity_id, session)
			if plays.is_empty():
				return best
			return plays[session.rng.range_int(0, plays.size() - 1)]
		var families: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]
		var family: String = str(families[session.rng.range_int(0, families.size() - 1)])
		var other: Dictionary = {"template": "ACQUIRE", "params": {"family": family}}
		if session.actions.can_execute(entity_id, "ACQUIRE", other["params"]):
			return other
		return best


## Gioca per il Trionfo dal primo round, invece che per il gradino piu vicino.
## Spesso arriva a mani vuote; ogni tanto arriva dove gli altri non arrivano.
class Ostinato extends PolicyDecider:
	func _open_levels(
		entity_id: String, session: RefCounted, with_objectives: bool = true
	) -> Array:
		var destiny: Dictionary = _destiny(entity_id, session)
		if destiny.is_empty():
			return []
		var top: Array = destiny["triumph"]["conditions"]
		if not session.destinies.conditions.all_hold(top, {"self": entity_id}):
			return [top]
		return super._open_levels(entity_id, session, with_objectives)


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

	# La pedina del prezzo e la controproposta (D-267/D-268) nominano un seggio:
	# risponde il carattere che ci siede. Senza questi inoltri la guardia
	# `has_method` del controller saltava le due domande **in silenzio** - il
	# tavolo misto del cancello ha giocato la Fase A senza pedina, e i numeri
	# identici prima/dopo l'hanno detto. Un router che non inoltra e' un
	# cervello che non sa scegliere, e nessuno se ne accorge.
	# L'economia (D-280) nomina due seggi: il proponente che compra e il primo
	# del fronte avverso che sceglie il prezzo. Stessa ragione dell'inoltro qui
	# sopra, e stessa trappola se manca.
	func choose_benefits(
		entity_id: String, context: Dictionary, menu: Array, session: RefCounted
	) -> Array:
		return await _who(entity_id).choose_benefits(entity_id, context, menu, session)

	func choose_costs(
		entity_id: String, context: Dictionary, menu: Array, due: int, session: RefCounted
	) -> Array:
		return await _who(entity_id).choose_costs(entity_id, context, menu, due, session)

	func choose_cost_token(
		entity_id: String, context: Dictionary, menu: Array, session: RefCounted
	) -> String:
		return await _who(entity_id).choose_cost_token(entity_id, context, menu, session)

	func choose_opposition_token(
		entity_id: String, context: Dictionary, session: RefCounted
	) -> bool:
		return await _who(entity_id).choose_opposition_token(entity_id, context, session)

	func choose_counterclaim(
		entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted
	) -> Dictionary:
		return _who(entity_id).choose_counterclaim(entity_id, context, offer, session)
