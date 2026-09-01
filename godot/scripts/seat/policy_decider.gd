extends RefCounted
## A player that actually plays to win, for balance measurement.
##
## The ScriptedDecider replays authored plans and its filler deliberately never
## touches the Tensions. That is right for regression tests and useless for
## balance: it cannot tell us what happens when four people all pursue their own
## Destiny at once.
##
## This decider derives its goals straight from the Entity's Destiny conditions -
## no hand-written per-Entity AI - and plays them: it scouts what it needs to
## know, occupies the Regions its Destiny names, stocks the Assets that will be
## relevant, and steers the Tensions it cares about when they get close to the
## edge. In a Confluence it scores every proposition against its own Destiny and
## supports, opposes or abstains accordingly.
##
## Deterministic, but not RNG-free: it breaks a tie between equally useful
## propositions with the session RNG, because always taking the first option on
## the list left two thirds of the authored propositions unplayable. Same seed,
## same run.

const Ids := preload("res://scripts/core/ids.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")

## Stop stockpiling and start acting once the hand is this full.
const COMFORTABLE_HAND: int = 4
## A Tension this close to its threshold is worth spending an action on.
const DANGER_MARGIN: int = 2
## Quanto pesa, nella bilancia del cervello, un segno che il profilo strategico
## nomina (D-289). Piccolo di proposito: e' una preferenza, non un ordine — la
## legalita', il bersaglio a segni e il Destino restano davanti.
const PROFILE_WEIGHT: int = 3

var log: RefCounted


func _init(p_log: RefCounted = null) -> void:
	log = p_log


# --- goals -----------------------------------------------------------------

## Every condition in the Entity's Destiny, across all three levels — **e gli
## obiettivi che ha in mano** (D-222).
##
## Fino alla 0.1.189 questa funzione tornava soltanto il Destino, e la parola
## «objective» non compariva **nemmeno una volta** in tutto questo file. Ma da
## [D-198](DECISIONS.md#d-198) la partita si vince **contando quattro
## obiettivi**, non salendo i gradini del Destino: il cervello inseguiva una
## cosa e il punteggio ne contava un'altra.
##
## Si e' visto aggiungendo tre obiettivi contesi ([D-221](DECISIONS.md#d-221)) e
## non vedendo muovere niente: il gioco offriva la lotta e nessuno la
## combatteva. Questa e' la riga che glielo fa vedere, ed e' l'unico punto da
## toccare — nove posti leggono di qui, quindi da qui l'obiettivo entra nella
## scelta dell'azione, delle Regioni, delle carte e del voto al Consiglio.
##
## Il Destino **resta**: e' ancora lui a dire il livello, e una casa che vuole
## quello che ha sempre voluto e' quello che la fa somigliare a se stessa.
func _conditions(entity_id: String, session: RefCounted) -> Array:
	var out: Array = []
	var destiny: Dictionary = _destiny(entity_id, session)
	if not destiny.is_empty():
		for level in ["minimum", "victory", "triumph"]:
			out.append_array(_flat(destiny[level]["conditions"]))
	out.append_array(_objective_conditions(entity_id, session))
	return out


## Le clausole degli obiettivi che il seggio ha pescato, quelle **non ancora
## prese**. Un obiettivo gia' vero non e' piu' un movente: e' un punto in
## cassaforte, e giocarci contro toglierebbe azioni a quelli che mancano.
func _objective_conditions(entity_id: String, session: RefCounted) -> Array:
	var seat: Dictionary = (session.world["entities"] as Dictionary).get(
		entity_id, {}
	) as Dictionary
	var out: Array = []
	for objective_id in seat.get("objectives", []):
		var objective: Variant = session.data.objectives.get(str(objective_id))
		if objective == null:
			continue
		var conditions: Array = (objective as Dictionary)["conditions"]
		if session.destinies.conditions.all_hold(conditions, {"self": entity_id}):
			continue
		out.append_array(_flat(conditions))
	return out


## Le clausole annidate, portate in superficie **per la sola lettura degli
## obiettivi**.
##
## Un seggio legge il proprio Destino per sapere cosa vuole: quali Tensioni
## tenere su, quali giu', quali segni gli servono. Quella lettura guarda il tipo
## della clausola — `tension_limit`, `state_tag_present` — e una clausola dentro
## una scelta ha per tipo `some_of`, quindi non la vede nessuno.
##
## E' esattamente il buco di D-066, che aveva trovato **l'80% dei seggi a
## valutare una proposta zero**: non indifferenza scritta, indifferenza del
## codice. D-167 ha spostato meta' delle clausole dentro le scelte dei Trionfi e
## l'avrebbe riaperto in silenzio, se la suite non avesse tenuto due test su
## quella lettura.
##
## Attenzione a dove **non** si appiattisce: se un livello e' soddisfatto lo
## decide `all_hold` sulla lista vera, perche' «tre di queste cinque» e' vero
## anche quando due sono false, e appiattito diventerebbe una AND.
func _flat(conditions: Array) -> Array:
	var out: Array = []
	for condition in conditions:
		var kind: String = str((condition as Dictionary).get("type", ""))
		if kind == "some_of" or kind == "any_of":
			out.append_array(_flat((condition as Dictionary)["conditions"]))
		else:
			out.append(condition)
	return out


func _destiny(entity_id: String, session: RefCounted) -> Dictionary:
	var definition: Variant = session.data.entities.get(entity_id)
	if definition == null:
		return {}
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(entity_id))
	return {} if destiny == null else destiny


## The rungs of the ladder this Entity has not secured yet, lowest first.
##
## A player plays for the nearest thing they have not got - Minimum before
## Victory, Victory before Triumph - which is why this is a list in order and not
## a pile. Everything already held is dropped: there is nothing to play for in a
## clause that is already true.
func _open_levels(
	entity_id: String, session: RefCounted, with_objectives: bool = true
) -> Array:
	var destiny: Dictionary = _destiny(entity_id, session)
	if destiny.is_empty():
		return []
	var out: Array = []
	for level in ["minimum", "victory", "triumph"]:
		var conditions: Array = destiny[level]["conditions"]
		# Il livello si giudica sulla lista vera e si gioca su quella appiattita.
		if not session.destinies.conditions.all_hold(conditions, {"self": entity_id}):
			out.append(_flat(conditions))
	# **E in fondo alla scala, gli obiettivi** ([D-255](DECISIONS.md#d-255)).
	#
	# D-222 aveva messo gli obiettivi dentro `_conditions()` — nove letture
	# passano di li' — e la nota diceva «da qui l'obiettivo entra nella scelta
	# dell'azione». Non era vero: la scelta dell'azione non legge `_conditions`,
	# legge **questa** funzione, e questa funzione tornava soltanto i gradini del
	# Destino. Gli obiettivi entravano nel voto al Consiglio e nella scelta delle
	# carte, e restavano fuori dall'unico posto che decide se un seggio si alza.
	#
	# Stanno in fondo e non in cima perche' il Destino e' cio' che rende una casa
	# se stessa: si gioca il primo gradino che chiede qualcosa, e se non chiede
	# niente si va oltre — che e' il contratto di `_nearest_demanding` da D-047.
	# Prima di questa riga, «si va oltre» finiva nel vuoto.
	var wanted: Array = _objective_conditions(entity_id, session)
	if with_objectives and not wanted.is_empty():
		out.append(wanted)
	# Everything already holds: defend the whole ladder.
	return [_conditions(entity_id, session)] if out.is_empty() else out


## The conditions that actually matter right now (D-047).
##
## This used to be the lowest rung and nothing else, on the reasoning that a
## player sitting on Minimum plays for Victory rather than for a Triumph clause
## they cannot get to. It is right about the order and wrong about the stopping:
## a rung whose remaining clauses are all *negative* - "the mine is not sealed",
## "the road is still open" - asks nothing of anybody, and a seat focused on it
## stops playing. Lyra reached that rung in round two and spent the other eight
## rounds drawing cards she never used.
##
## So the rule is: play the nearest rung that gives you something to do, and if
## it gives you nothing, reach past it. `wants` is the test - it takes a rung and
## returns what that rung asks for.
func _nearest_demanding(
	entity_id: String, session: RefCounted, wants: Callable, ladder: Array = []
) -> Dictionary:
	var fallback: Dictionary = {}
	for conditions in (ladder if not ladder.is_empty() else _open_levels(entity_id, session)):
		var asked: Dictionary = wants.call(conditions as Array)
		if not asked.is_empty():
			return asked
		if fallback.is_empty():
			fallback = asked
	return fallback


## Tension goals: tension_id -> desired direction (-1 wants it low, +1 high).
##
## Two sources, and they are what makes the table fight:
##   - a `tension_limit` with a max says "keep this one down";
##   - a condition that can only be satisfied by a Confluence Consequence says
##     "I need that Confluence to actually happen", which means pushing the
##     Tension that opens it *up* to its threshold.
func _tension_goals(entity_id: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = _nearest_demanding(
		entity_id,
		session,
		func(live: Array) -> Dictionary: return _goals_of(entity_id, session, live),
		_open_levels(entity_id, session, false)
	)
	# **Un obiettivo non convoca il mondo** ([D-255](DECISIONS.md#d-255)).
	#
	# Gli obiettivi entrano nella scala per far muovere, rivendicare e forgiare,
	# e per quelli la scala basta. Sulle Tensioni no: `_needed_confluences`
	# spinge in alto **qualunque** questione il cui Consiglio potrebbe produrre
	# la Conseguenza che serve, e un obiettivo privato che apre Consigli cambia
	# la forma dell'anno per tutti. Misurato: la Chronicle 4 passava a nove
	# Consigli in due anni su dodici, sopra il limite duro di otto.
	#
	# Quindi dagli obiettivi si leggono le Tensioni **nominate**, non quelle
	# dedotte: `tension_count` dice «tienine due alte» e si obbedisce; una
	# clausola sulle pietre non diventa una convocazione.
	var from_objectives: Dictionary = _goals_of(
		entity_id, session, _objective_conditions(entity_id, session), false
	)
	for tension_id in from_objectives:
		if not goals.has(str(tension_id)):
			goals[str(tension_id)] = int(from_objectives[str(tension_id)])
	return goals


## What one rung of the ladder asks of the Tensions.
func _goals_of(
	entity_id: String, session: RefCounted, live: Array, may_convene: bool = true
) -> Dictionary:
	var goals: Dictionary = {}
	if may_convene:
		for tension_id in _needed_confluences(entity_id, session, live):
			goals[str(tension_id)] = 1

	for condition in live:
		if str(condition.get("type", "")) != "tension_limit":
			continue
		var tension_id: String = str(condition.get("tension_id", ""))
		if not session.world["tensions"].has(tension_id):
			continue
		if session.destinies.conditions.holds(condition, {}):
			continue  # already satisfied, no need to spend an action on it
		if condition.has("max"):
			goals[tension_id] = -1
		elif condition.has("min"):
			goals[tension_id] = 1

	# **La clausola che non nomina nessuno** ([D-255](DECISIONS.md#d-255)).
	#
	# `tension_limit` dice *quale* questione, e un obiettivo del mazzo comune non
	# lo puo' sapere. `tension_count` dice soltanto **quante**, e sta al seggio
	# scegliere su quali spendere le Occasioni: le piu' vicine al traguardo, che
	# sono anche le piu' economiche.
	#
	# Senza questa lettura la clausola sarebbe muta due volte: il dato la
	# chiede, il punteggio la conta a fine anno, e nessuno al tavolo si alza per
	# prenderla. E' il difetto misurato in D-254 riprodotto in piccolo — mosse
	# legali, e nessuna che serva.
	for condition in live:
		if str(condition.get("type", "")) != "tension_count":
			continue
		if session.destinies.conditions.holds(condition, {}):
			continue
		for tension_id in _tensions_to_shift(condition, session):
			var wanted: int = int((tension_id as Array)[1])
			var id: String = str((tension_id as Array)[0])
			if not goals.has(id):
				goals[id] = wanted
	return goals


## Quali questioni muovere, e da che parte, perche' una `tension_count` diventi
## vera — le piu' vicine alla soglia per prime.
##
## Ne nomina **esattamente quante ne mancano**, non una di piu'.
##
## La prima stesura ne nominava una di scorta, per non lasciare il piano in mano
## a chi spinge dall'altra parte. Misurato: la Chronicle 4 passava da otto
## Consigli a nove in due anni su dodici, cioe' fuori dal limite duro che il
## committente ha messo alla forma dell'anno. La scorta la paga il tavolo.
func _tensions_to_shift(condition: Dictionary, session: RefCounted) -> Array:
	var above: bool = condition.has("at_or_above")
	var bar: int = int(condition.get("at_or_above", condition.get("at_or_below", 0)))
	var direction: int = 1 if above else -1
	var missing: Array = []   # [id, valore] di quelle che non contano ancora
	var counted: int = 0
	for tension_id in _sorted(session.world["tensions"].keys()):
		var id: String = str(tension_id)
		var value: int = session.tensions.value(id)
		var inside: bool = value >= bar if above else value <= bar
		if inside:
			counted += 1
		else:
			missing.append([id, value])
	# Se la clausola chiede un tetto invece di un minimo, il verso si rovescia:
	# «non piu' di due alte» si serve abbassando quelle alte.
	if condition.has("max") and not condition.has("min"):
		var over: Array = []
		if counted <= int(condition["max"]):
			return []
		for tension_id in _sorted(session.world["tensions"].keys()):
			var id: String = str(tension_id)
			var value: int = session.tensions.value(id)
			var inside: bool = value >= bar if above else value <= bar
			if inside:
				over.append([id, -direction])
		return over
	var short: int = int(condition.get("min", 1)) - counted
	if short <= 0:
		return []
	# Le piu' vicine per prime: salendo, la piu' alta fra quelle basse; scendendo,
	# la piu' bassa fra quelle alte.
	missing.sort_custom(func(a: Variant, b: Variant) -> bool:
		if direction > 0:
			return int((a as Array)[1]) > int((b as Array)[1])
		return int((a as Array)[1]) < int((b as Array)[1])
	)
	var out: Array = []
	for entry in missing:
		out.append([str((entry as Array)[0]), direction])
		if out.size() >= short:
			break
	return out


## Which Tensions this Entity needs to bring to a head, because the only thing
## that can satisfy one of its live conditions is a Consequence that lives behind
## a Confluence. Derived from the data, not hard-coded per Entity.
func _needed_confluences(entity_id: String, session: RefCounted, live: Array) -> Array:
	var wanted: Array = []
	for condition in live:
		if session.destinies.conditions.holds(condition, {}):
			continue
		for consequence_id in _consequences_satisfying(condition, entity_id, session):
			for tension_id in _tensions_offering(str(consequence_id), session):
				if not wanted.has(str(tension_id)):
					wanted.append(str(tension_id))
	wanted.sort()
	return wanted


## Consequences whose Effects would make `condition` true.
func _consequences_satisfying(condition: Dictionary, entity_id: String, session: RefCounted) -> Array:
	var kind: String = str(condition.get("type", ""))
	var out: Array = []
	for consequence in session.data.consequences.values():
		for effect in consequence["effects"]:
			var payload: Dictionary = effect.get("payload", {})
			var effect_type: String = str(effect["type"])
			match kind:
				"state_tag_present":
					if effect_type.begins_with("SET_") and str(payload.get("tag", "")) == str(condition.get("tag", "")):
						out.append(str(consequence["id"]))
				"state_tag_absent":
					# Il ramo che disfa (D-085): una clausola di assenza si
					# soddisfa anche con la Conseguenza che RIMUOVE il tag -
					# senza questo, «le gallerie non sono murate» non aveva
					# nessun Consiglio da inseguire quando lo erano gia'.
					if effect_type.begins_with("REMOVE_") and str(payload.get("tag", "")) == str(condition.get("tag", "")):
						out.append(str(consequence["id"]))
				"control_count":
					# Control only ever changes hands through a Confluence, and
					# only in favour of the proponent.
					if effect_type == "SET_CONTROL" and str(payload.get("entity_id", "")) == "$proponent":
						out.append(str(consequence["id"]))
				"discovery_count":
					if effect_type == "SET_ENTITY_TAG" and str(payload.get("tag", "")).begins_with("discovery:"):
						out.append(str(consequence["id"]))
	return out


## Which Tensions can produce that Consequence, through a proposition of their
## own Confluence template.
##
## Solo i template che QUESTA Chronicle elenca: la biblioteca ne porta anche
## per altre ere - la proposta che legge una leggenda sta in un template che il
## primo anno non apre mai - e una policy che pianificasse contro l'intera
## biblioteca inseguirebbe Consigli che quest'anno non esistono (D-076).
func _tensions_offering(consequence_id: String, session: RefCounted) -> Array:
	var listed: Array = (
		session.data.chronicles[str(session.world["chronicle_id"])]
		.get("confluence_templates", [])
	)
	var out: Array = []
	for template in session.data.confluence_templates.values():
		if not listed.has(str(template["id"])):
			continue
		var offers: bool = false
		for proposition in template["propositions"]:
			if (proposition["success_consequences"] as Array).has(consequence_id):
				offers = true
		if not offers:
			continue
		# A Council bound to a whole domain serves every Tension of that domain
		# in play, not one named Tension (D-028).
		if template.has("tension_id"):
			if session.world["tensions"].has(str(template["tension_id"])):
				out.append(str(template["tension_id"]))
			continue
		for tension_id in session.world["tensions"]:
			if str(session.data.tensions[str(tension_id)]["domain"]) == str(template["applies_to_domain"]):
				if not out.has(str(tension_id)):
					out.append(str(tension_id))
	return out


## Il diritto di proporre (issue #22, D-069).
##
## Le Tensioni del gradino vivo che il seggio deve portare a soglia
## (`_needed_confluences`) e su cui, quando il Consiglio si aprisse da solo, la
## parola andrebbe a qualcun altro: il proponente lo decide il posto (D-036), e
## il posto e' di chi vuole l'esito ovvio (D-063). La regola del proponente e'
## pubblica, quindi chiederselo non e' barare: e' contare come conta chiunque
## abbia letto il regolamento.
func _tensions_needing_the_word(entity_id: String, session: RefCounted) -> Array:
	for conditions in _open_levels(entity_id, session):
		var needed: Array = _needed_confluences(entity_id, session, conditions as Array)
		if needed.is_empty():
			continue
		var out: Array = []
		for tension_id in needed:
			var id: String = str(tension_id)
			if not session.world["tensions"].has(id):
				continue
			# Un Claim su una domanda gia' decisa e' una carta bruciata: se il
			# Consiglio non ha piu' niente di nuovo da chiedere, non si forza
			# (D-077).
			if not session.confluence.has_fresh_question(id):
				continue
			# Ho gia' parlato per ultimo su questa domanda: la parola ruota
			# (D-051), e chi la richiede appena finito di usarla monopolizza i
			# Consigli e affama chi li aspettava per posizione (D-069).
			if str((session.world.get("last_proponent", {}) as Dictionary).get(id, "")) == entity_id:
				continue
			var focus: String = session.confluence.narrative.focus_region(id)
			if session.service.determine_proponent(id, focus) == entity_id:
				continue  # la parola l'avrei comunque
			out.append(id)
		return out
	return []


## CLAIM e' l'azione scritta apposta per spostare la parola (§11) e la policy
## non l'ha mai giocata: il modello di giocatore competente usava cinque azioni
## su sei, e le proposte scritte per i seggi senza parola risultavano contenuto
## morto (D-063). Due tempi, come da regola: prenotare il dominio con un Asset
## AUTHORITY, poi - in un round successivo - forzare il Consiglio e parlare per
## primi.
##
## Con moderazione, e la moderazione e' misurata: la prima stesura forzava ogni
## Consiglio che il Destino volesse, appena legale, e ha prodotto un tavolo che
## litigava a vuoto - fallimenti 219 -> 339, mediana dei Consigli fuori dalla
## banda del §7, due seggi bloccati (D-069). Prendersi la parola su una domanda
## che non scotta e' un Consiglio che il tavolo non voleva, e si perde ai voti.
## Quindi: si prenota quando la domanda si sta scaldando, si forza quando
## stava comunque per porsi - cosi' il Consiglio forzato *sostituisce* quello a
## soglia invece di aggiungersi - e con una mano con cui giocarselo.
## La deroga a §10 la dichiara la Chronicle (D-191), non il codice.
func _claim_in_one_move(session: RefCounted) -> bool:
	var chronicle: Dictionary = session.data.chronicles[
		str(session.world["chronicle_id"])
	] as Dictionary
	return bool(
		(chronicle.get("claim_rules", {}) as Dictionary).get("same_round_when_ready", false)
	)


func _claim_ready_at(session: RefCounted) -> int:
	var chronicle: Dictionary = session.data.chronicles[
		str(session.world["chronicle_id"])
	] as Dictionary
	return int((chronicle.get("claim_rules", {}) as Dictionary).get("ready_at", 3))


func _claim_the_word(entity_id: String, session: RefCounted) -> Dictionary:
	for tension_id in _tensions_needing_the_word(entity_id, session):
		var id: String = str(tension_id)
		var value: int = session.tensions.value(id)
		var threshold: int = _assumed_threshold(id, entity_id, session)
		if value < threshold - 2 * DANGER_MARGIN:
			continue  # la domanda non si e' ancora scaldata
		# Si forza in un round che sarebbe rimasto muto: un Claim forzato ha la
		# precedenza sul trigger a soglia (§7) e manda in coda il Consiglio di
		# qualcun altro - misurato, e' il seggio dalla soglia piu' bassa a
		# pagarlo, ogni volta (D-069). Cosi' il Consiglio forzato si aggiunge
		# all'anno invece di rubare il posto a quello che stava arrivando.
		# Col colpo solo (D-191) la cautela di D-069 non serve piu': non c'e'
		# nessuna prenotazione da proteggere, e strappare una domanda matura e'
		# esattamente cio' che il committente vuole che un giocatore possa fare
		# — «l'innesco lo apre un giocatore».
		var ready: bool = (
			value >= _claim_ready_at(session) if _claim_in_one_move(session)
			else (
				value >= threshold - DANGER_MARGIN
				and session.service.hand_size(entity_id) >= COMFORTABLE_HAND
				and (session.tensions.tensions_at_threshold() as Array).is_empty()
			)
		)
		if ready:
			var force: Dictionary = {"mode": "FORCE", "tension_id": id}
			if session.actions.can_execute(entity_id, "CLAIM", force):
				return {"template": "CLAIM", "params": force}
		var domain: String = session.service.tension_domain(id)
		# **Non si prenota cio' che e' gia' maturo** (D-191). Quando la Chronicle
		# concede la presa di parola in un colpo, una domanda gia' a maturita' o
		# si strappa adesso o si lascia stare: prenotarla e' bruciare una carta
		# per comprare un diritto che si ha gia'. Misurato, era la sola ragione
		# per cui la deroga a §10 non mordeva - 85 prenotazioni morte su 98.
		# **Non si prenota cio' che e' gia' maturo** (D-191): su una domanda a
		# maturita' il diritto di parlare ce l'hanno tutti, e comprarlo con una
		# carta AUTORITA' e' spenderla per niente.
		if _claim_in_one_move(session) and value >= _claim_ready_at(session):
			continue
		# Si prenota solo con in mano anche la carta per riscuotere: senza
		# questo, meta' dei Claim creati non veniva mai forzata - 124 creati e
		# 45 forzati in 40 Chronicle - e ogni prenotazione a vuoto e' una carta
		# AUTHORITY e un'azione bruciate (D-069).
		if session.service.count_family_in_hand(entity_id, "AUTHORITY") < 2:
			continue
		if session.service.claim_for_domain(entity_id, domain).is_empty():
			var create: Dictionary = {"mode": "CREATE", "domain": domain}
			if session.actions.can_execute(entity_id, "CLAIM", create):
				return {"template": "CLAIM", "params": create}
	return {}


## Relation goals: `other_entity_id` -> +1 to warm it, -1 to sour it (D-051).
##
## `promise_kept` and `promise_broken` have been in the evaluator since 0.0 and
## no Destiny used them - an open line on the 0.1 roadmap. Wiring them in showed
## why the line stayed open: **the policy has never once played FORGE**, so a
## relation never moves, so a promise is kept for free and can never be broken.
## The relation graph was scenery, which is exactly what O-14 recorded and
## nobody had followed up.
##
## A promise is a relation carrying a PACT or PROMISE tag: kept while the two are
## not hostile, broken when they are. So the seat that needs it kept warms it
## when it slips, and the seat that needs it broken sours it - which is the first
## thing in the game that makes FORGE worth an Action Opportunity.
func _relation_goals(entity_id: String, session: RefCounted) -> Dictionary:
	return _nearest_demanding(
		entity_id,
		session,
		func(live: Array) -> Dictionary: return _relations_of(entity_id, session, live)
	)


func _relations_of(entity_id: String, session: RefCounted, live: Array) -> Dictionary:
	var goals: Dictionary = {}
	for condition in live:
		var kind: String = str(condition.get("type", ""))
		if kind != "promise_kept" and kind != "promise_broken" and kind != "relation_state":
			continue
		if str(condition.get("entity_id", "")) != entity_id:
			continue
		var other: String = str(condition.get("other_entity_id", ""))
		if not session.world["entities"].has(other):
			continue
		if session.destinies.conditions.holds(condition, {}):
			continue  # already true; FORGE has nothing to add
		goals[other] = -1 if kind == "promise_broken" else 1
	return goals


## Move a relation the Destiny has an opinion about. Souring one needs nothing
## but the action; warming one needs the other seat's consent and a BONDS card,
## which is why a promise is easier to break than to hold - and why the seat that
## needs it kept has to spend on it before it slips.
func _forge(entity_id: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = _relation_goals(entity_id, session)
	for other in _sorted(goals.keys()):
		var direction: String = "UP" if int(goals[other]) > 0 else "DOWN"
		var request: Dictionary = {
			"target_entity_id": str(other),
			"direction": direction,
			"consent": direction == "UP",
		}
		if session.actions.can_execute(entity_id, "FORGE", request):
			return {"template": "FORGE", "params": request}
	return {}


## Global and entity tags this Destiny wants present (+1) or absent (-1).
func _tag_goals(entity_id: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = {}
	for condition in _conditions(entity_id, session):
		var kind: String = str(condition.get("type", ""))
		if kind == "state_tag_present":
			goals[str(condition.get("tag", ""))] = 1
		elif kind == "state_tag_absent":
			goals[str(condition.get("tag", ""))] = -1
	return goals


## L'alleanza che conviene (D-171), decisa su quello che si e' visto (D-172).
##
## Fino a D-171 un seggio stringeva un legame **solo** se una clausola del suo
## Destino nominava quella relazione. Mai perche' gli tornava utile — e dal
## D-139 tornare utile e' misurabile: un alleato che sostiene il proponente
## porta **+1** sul fronte, +2 se BOUND, col tetto a 2 e almeno due carte
## impegnate.
##
## **Con chi conviene non e' «chi vuole i miei stessi segni».** La prima forma
## contava gli obiettivi in comune e non ha sparato una volta: fra gli otto
## Destini del gioco non esiste una coppia che voglia lo stesso segno nello
## stesso verso. Ogni sovrapposizione e' un'opposizione, il resto e'
## indifferenza — il contenuto e' una rete di contrasti (D-171).
##
## E non e' nemmeno «chi aspetta le mie stesse domande», che funzionava ma
## **leggeva il Destino altrui**: un giocatore vero quella carta non la vede.
## Al tavolo si capisce chi ti e' vicino **da come vota**, e `voted_together`
## tiene esattamente quel registro — chi e' finito sul tuo fronte meno chi ti
## e' finito contro. E' quello che chiunque sieda al Consiglio vede con i propri
## occhi, e niente di piu': si sbaglia, si aggiorna, e non sa niente prima che
## il primo Consiglio si sia chiuso.
##
## Si paga: salire di un grado costa una carta BONDS e un'Occasione. Per questo
## sta dietro tutto quello che il Destino chiede esplicitamente e dietro la
## soglia di mano dello steering.
func _ally_of_convenience(entity_id: String, session: RefCounted) -> Dictionary:
	# Chi non ha piu' niente da vincere non ha niente da comprare.
	if _open_levels(entity_id, session).is_empty():
		return {}
	var memory: Dictionary = session.world.get("voted_together", {})
	if memory.is_empty():
		return {}   # nessun Consiglio chiuso: non si sa ancora niente di nessuno
	var best: String = ""
	var best_score: int = 0
	for other in _sorted((session.world["entities"] as Dictionary).keys()):
		var other_id: String = str(other)
		if other_id == entity_id:
			continue
		if not bool((session.world["entities"][other_id] as Dictionary)["active"]):
			continue
		var score: int = int(memory.get(Ids.relation_key(entity_id, other_id), 0))
		if score > best_score:
			best_score = score
			best = other_id
	if best == "":
		return {}
	var request: Dictionary = {
		"target_entity_id": best,
		"direction": "UP",
		"consent": true,
	}
	if not session.actions.can_execute(entity_id, "FORGE", request):
		return {}
	return {"template": "FORGE", "params": request}


# --- ordinary actions ------------------------------------------------------

## ISSUES 47: quando le carte sono l'unica moneta, l'intenzione del seggio resta
## quella di sempre — cambia **chi puo' pronunciarla**. Il cervello sceglie cosa
## vuole fare; questo strato cerca in mano la carta che lo dice.
func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
	var intent: Dictionary = _choose_intent(entity_id, ao_index, session)
	if not _cards_are_the_coin(session):
		return intent
	var play: Dictionary = _as_card_play(entity_id, intent, session)
	if str(play.get("template", "PASS")) != "PASS":
		return play
	return _rather_than_nothing(entity_id, session)


## **Un'Occasione non si butta** (D-285, passo 4 del brief del Punto Zero).
##
## Misurato: si passava l'**82%** dei turni, e due terzi di quei passa erano
## «mosse legali, nessuna che gli servisse» — con in mano sette carte e quindici
## mosse legali in media. Il ripiego `_whatever_the_hand_allows` c'era gia', ma
## non veniva mai provato: quando `_choose_intent` diceva PASS, `_as_card_play`
## tornava indietro alla prima riga. Il cervello non era senza mosse: era senza
## fame.
##
## **Ma non si svuota la mano.** Al tavolo una carta calata e' una carta che al
## Consiglio non vota, e tenerne da parte e' una scelta vera, non pigrizia:
## il mondo ricorda solo i Consigli in cui qualcuno ha messo peso
## (`EchoRecorder.should_record`), quindi una mano svuotata sulla mappa e' un
## anno che lascia meno scritto. La riserva e' **quello che il Consiglio puo'
## accettare, piu' una** (`max_commit_assets + 1`, quattro carte in CHR_01):
## sopra si gioca la piu' debole che la mano permette, sotto si tiene. Un turno
## vuoto con nove carte in mano non e' prudenza, e' silenzio.
##
## **Taratura d'autore, misurata su 100 semi a tavolo misto** — la riserva e'
## il quadrante fra le Azioni e la memoria del mondo:
##
##   riserva  ·  passa  ·  Verita' scritte  ·  Consigli
##      —        82,1%        295              3,67     (prima di questa regola)
##      3        37,3%        227              3,75
##      4        42,1%        256              3,80     <- scelta
##      5        47,2%        252              3,81
func _rather_than_nothing(entity_id: String, session: RefCounted) -> Dictionary:
	var chronicle: Dictionary = session.data.chronicles[
		str(session.world["chronicle_id"])
	] as Dictionary
	var reserve: int = int(chronicle.get("max_commit_assets", 3)) + 1
	if session.service.hand_size(entity_id) <= reserve:
		return {"template": "PASS", "params": {}}
	var plays: Array = hand_plays(entity_id, session)
	return plays[0] if not plays.is_empty() else {"template": "PASS", "params": {}}


func _cards_are_the_coin(session: RefCounted) -> bool:
	var chronicle: Dictionary = session.data.chronicles[
		str(session.world["chronicle_id"])
	] as Dictionary
	return bool(chronicle.get("actions_from_cards", false))


func _choose_intent(entity_id: String, _ao_index: int, session: RefCounted) -> Dictionary:
	var service: RefCounted = session.service

	# 1. Knowledge first: a veiled Tension you cannot see is one you cannot act
	#    on, and for some Destinies the Discovery is the goal itself.
	var scout: Dictionary = _scout(entity_id, session)
	if not scout.is_empty():
		return scout

	# 2. Stand where your Destiny says you must stand.
	var move: Dictionary = _claim_required_region(entity_id, session)
	if not move.is_empty():
		return move

	# 3. La parola, quando il posto la darebbe a qualcun altro (issue #22):
	#    prenotare il dominio o forzare il Consiglio che il Destino aspetta.
	var word: Dictionary = _claim_the_word(entity_id, session)
	if not word.is_empty():
		return word

	# 4. A promise your Destiny is standing on, when it has moved off where you
	#    need it. Before the stockpiling: a pact that has soured is not repaired
	#    by drawing cards.
	var forge: Dictionary = _forge(entity_id, session)
	if not forge.is_empty():
		return forge

	# 4b. La carta del Narratore (ISSUES 23, D-118): se una carta in mano e'
	#     pronta per la storia e le risorse reggono il prezzo, si cala. Prima
	#     dello steering: un atto che resta muto e' un'occasione persa.
	var narrated: Dictionary = _play_narrator(entity_id, session)
	if not narrated.is_empty():
		return narrated

	# 4c. L'alleanza che conviene (D-171): con chi aspetta le stesse domande,
	#     perche' quando si aprono il suo voto pesa sul mio fronte. Dietro la
	#     soglia di mano, come lo steering — si compra con quello che avanza.
	#
	#     Sta qui e non piu' in basso perche' **piu' in basso non spara mai**:
	#     le voci prima trovano sempre qualcosa da fare. E' l'unica posizione in
	#     cui questa regola esiste, e il suo prezzo e' misurato in D-171.
	if service.hand_size(entity_id) >= COMFORTABLE_HAND:
		var ally: Dictionary = _ally_of_convenience(entity_id, session)
		if not ally.is_empty():
			return ally

	# 5. Steer a Tension that is about to decide something, in the direction
	#    your Destiny needs - but only once you have something to spend.
	if service.hand_size(entity_id) >= COMFORTABLE_HAND:
		var steer: Dictionary = _steer(entity_id, session)
		if not steer.is_empty():
			return steer

	# 6. Otherwise prepare: stock the family that will matter. Quando le carte
	#    sono l'unica moneta la scorta non si fa piu' con un'Occasione — la fa
	#    il rubinetto — e questo ramo tacerebbe comunque: nessuna carta porta
	#    ACQUISIRE. Saltarlo lascia parlare lo steering, che una carta ce l'ha.
	if not _cards_are_the_coin(session):
		var acquire: Dictionary = _acquire(entity_id, session)
		if not acquire.is_empty():
			return acquire

	var steer_anyway: Dictionary = _steer(entity_id, session)
	if not steer_anyway.is_empty():
		return steer_anyway
	return {"template": "PASS", "params": {}}



## L'intenzione diventa una carta. La regola di spesa e' quella che il
## committente ha chiesto — «un bilanciamento di come usare le cose che la carta
## ti permette di fare» — e qui prende la forma piu' semplice che si possa
## misurare: **si spende la piu' debole che sa fare quella cosa**, perche' la
## forte serve al voto. Se in mano non c'e' niente che dica quell'intenzione, si
## fa quello che la mano permette invece di passare: un'Occasione muta e' persa.
func _as_card_play(
	entity_id: String, intent: Dictionary, session: RefCounted
) -> Dictionary:
	var template: String = str(intent.get("template", "PASS"))
	# PASS non costa carte, e la carta del Narratore e' un mazzo a parte.
	if template == "PASS" or template == "PLAY_ECHO" or template == "PLAY_CARD":
		return intent
	# La prima intenzione e' quella buona; le altre sono le seconde scelte dello
	# stesso cervello. Senza questa fila un'intenzione che la mano non sa dire
	# faceva passare il turno: misurato, **496 Occasioni mute su 720**.
	var wishes: Array = [intent]
	for other in [
		_steer(entity_id, session),
		_widen_the_tap(entity_id, session),
		_forge(entity_id, session),
		_claim_required_region(entity_id, session),
		_scout(entity_id, session),
	]:
		if not (other as Dictionary).is_empty():
			wishes.append(other)
	for wish in wishes:
		var kind: String = str((wish as Dictionary).get("template", ""))
		if kind == "PASS" or kind == "PLAY_ECHO" or kind == "PLAY_CARD":
			continue
		var wanted: Dictionary = (wish as Dictionary).get("params", {}) as Dictionary
		var card: Dictionary = _card_that_says(entity_id, kind, wanted, session)
		if card.is_empty():
			continue
		var params: Dictionary = wanted.duplicate()
		params["asset_id"] = str(card["asset_id"])
		params["face_action"] = int(card["face_action"])
		if str(card.get("mark_region_id", "")) != "":
			params["mark_region_id"] = str(card["mark_region_id"])
		return {"template": "PLAY_CARD", "params": params}
	var fallback: Dictionary = _whatever_the_hand_allows(entity_id, session)
	return fallback if not fallback.is_empty() else {"template": "PASS", "params": {}}


## La presenza e' il rubinetto (D-185): un gettone in piu' su una Regione che
## offre una famiglia che non si raggiunge e' una carta in piu' ogni Atto, e di
## un tipo che prima non usciva. Questa e' la sola voce nuova che il cervello ha
## imparato con le carte, ed e' la conseguenza diretta della regola.
func _widen_the_tap(entity_id: String, session: RefCounted) -> Dictionary:
	var reachable: Dictionary = {}
	var presence: Array = (
		(session.world["entities"] as Dictionary)[entity_id] as Dictionary
	).get("presence", []) as Array
	# **Solo col gettone di riserva.** Con tre pedine gia' sul tavolo MUOVERE
	# sposta invece di aggiungere, e allargare il rubinetto vorrebbe dire
	# togliere una pedina da dove sta: misurato, Re Aldric si portava via da solo
	# la presenza a Eredan che il suo Minimo chiede, e i suoi NONE passavano da 0
	# a 8 su 50 partite. Una casa non abbandona il posto in cui vive per una
	# carta in piu'.
	var chronicle: Dictionary = session.data.chronicles[
		str(session.world["chronicle_id"])
	] as Dictionary
	if presence.size() >= int(chronicle.get("presence_tokens", 3)):
		return {}
	for region_id in presence:
		for family in (session.data.regions[str(region_id)] as Dictionary).get(
			"asset_sources", []
		):
			reachable[str(family)] = true
	var best: String = ""
	var best_gain: int = 0
	for region_id in _sorted(session.world["regions"].keys()):
		if session.service.region_free_slots(str(region_id)) <= 0:
			continue
		if not session.service.can_move_to(entity_id, str(region_id)):
			continue
		# Il bersaglio a segni si esegue (D-274): da quando il motore legge la
		# faccia, una Regione dove nessuna carta MUOVERE in mano arriva non e'
		# un rubinetto — e' un desiderio muto. La coppia luogo+carta si sceglie
		# insieme, com'e' al tavolo: prima si guarda la carta, poi la mappa.
		if _card_that_says(entity_id, "MOVE", {"region_id": str(region_id)}, session).is_empty():
			continue
		var gain: int = 0
		for family in (session.data.regions[str(region_id)] as Dictionary).get(
			"asset_sources", []
		):
			if not reachable.has(str(family)):
				gain += 1
		if gain > best_gain:
			best_gain = gain
			best = str(region_id)
	if best == "":
		return {}
	return {"template": "MOVE", "params": {"region_id": best}}


## La mano, dalla carta piu' debole alla piu' forte: si spende quella che costa
## meno al Consiglio.
func _hand_weakest_first(entity_id: String, session: RefCounted) -> Array:
	var hand: Array = (session.service.hand(entity_id) as Array).duplicate()
	hand.sort_custom(func(a: String, b: String) -> bool:
		var left: Variant = session.data.assets.get(str(a))
		var right: Variant = session.data.assets.get(str(b))
		var ls: int = 0 if left == null else int(left["strength"])
		var rs: int = 0 if right == null else int(right["strength"])
		if ls == rs:
			return str(a) < str(b)
		return ls < rs
	)
	return hand


## La carta che dice quell'intenzione, **e quale delle sue Azioni stampate**
## (D-283). Vuoto se la mano non ne ha nessuna.
func _card_that_says(
	entity_id: String, kind: String, wanted: Dictionary, session: RefCounted
) -> Dictionary:
	for asset_id in _hand_weakest_first(entity_id, session):
		var card: Variant = session.data.assets.get(str(asset_id))
		if card == null:
			continue
		var action: Dictionary = (card as Dictionary).get("card_action", {}) as Dictionary
		if action.is_empty():
			continue
		# Cio' che la carta fissa non si contratta: se dice -1 e il seggio
		# voleva +1, quella carta non dice quell'intenzione.
		var fixed: Dictionary = action.get("params", {}) as Dictionary
		var clashes: bool = false
		for key in fixed:
			if wanted.has(key) and str(wanted[key]) != str(fixed[key]):
				clashes = true
				break
		if clashes:
			continue
		var best: int = -1
		var best_place: String = ""
		var best_score: int = 0
		for index in _printed_actions(card as Dictionary, kind):
			var params: Dictionary = wanted.duplicate()
			params["asset_id"] = str(asset_id)
			params["face_action"] = int(index)
			if not session.actions.can_execute(entity_id, "PLAY_CARD", params):
				continue
			# **Dove cadono i segni** (D-284): se questa meta' posa segni di
			# Regione e il verbo non ne nomina nessuna, il posto lo si sceglie
			# fra quelli che la carta raggiunge — ed e' una scelta vera, perche'
			# posare una condizione su casa d'altri non e' come posarla a casa
			# propria.
			var places: Array = _places_needed(
				card as Dictionary, int(index), wanted, session, str(asset_id)
			)
			for place in places:
				var here: Dictionary = wanted.duplicate()
				if str(place) != "":
					here["region_id"] = str(place)
				var score: int = _face_score(
					card as Dictionary, int(index), entity_id, here, session
				)
				if best < 0 or score > best_score:
					best = int(index)
					best_place = str(place)
					best_score = score
		if best >= 0:
			return {
				"asset_id": str(asset_id), "face_action": best,
				"mark_region_id": best_place,
			}
	return {}


## I posti fra cui scegliere per i segni di questa meta': `[""]` quando non
## serve sceglierne uno — il verbo ha gia' nominato la Regione, oppure i segni
## stampati non ne vogliono una.
func _places_needed(
	card: Dictionary, index: int, wanted: Dictionary, session: RefCounted, asset_id: String
) -> Array:
	if str(wanted.get("region_id", "")) != "":
		return [""]
	var places: Array = session.actions.places_for_face(asset_id, index)
	return [""] if places.is_empty() else places


## Gli indici delle Azioni stampate che usano quel verbo.
static func _printed_actions(card: Dictionary, kind: String) -> Array:
	var out: Array = []
	var printed: Array = (card.get("physical", {}) as Dictionary).get("actions", []) as Array
	for index in range(printed.size()):
		if str((printed[index] as Dictionary).get("template", "")) == kind:
			out.append(index)
	return out


## **Quale delle due meta' conviene** (D-283, taratura d'autore dichiarata).
##
## Ventinove carte su quarantotto stampano lo stesso verbo due volte: le due
## meta' si distinguono solo per i **segni** che posano, ed e' quindi sui segni
## che si sceglie. La regola e' piccola e situazionale, come quella
## dell'economia del Consiglio (D-280): un segno che cade su casa mia o sulla
## mia terra pesa contro, uno che cade altrove pesa a favore, e a parita' vince
## la prima meta' — che e' quella che la carta stampa per prima.
func _face_score(
	card: Dictionary, index: int, entity_id: String, wanted: Dictionary,
	session: RefCounted
) -> int:
	var printed: Array = (card.get("physical", {}) as Dictionary).get("actions", []) as Array
	var face: Dictionary = printed[index] as Dictionary
	var region_id: String = str(wanted.get("region_id", ""))
	var mine: bool = false
	if region_id != "":
		var region: Dictionary = (session.world["regions"] as Dictionary).get(
			region_id, {}
		) as Dictionary
		mine = str(region.get("control", "")) == entity_id
	var score: int = 0
	for tag in face.get("puts_tag", []):
		var known: Variant = session.data.tags.get(str(tag))
		if known == null:
			continue
		var category: String = str((known as Dictionary).get("category", ""))
		var scopes: Array = (known as Dictionary).get("scope", []) as Array
		# Una condizione e' un peso: sulla mia terra pesa contro di me, su
		# quella di un altro pesa a suo carico.
		if category == "STATE":
			score += -2 if (mine or scopes.has("ENTITY")) else 2
		else:
			score += 1
		score += profile_weight(entity_id, str(tag), true, session)
	for tag in face.get("clears_tag", []):
		var known: Variant = session.data.tags.get(str(tag))
		if known == null:
			continue
		# Togliere un peso vale se il peso sta a casa mia.
		score += 2 if mine else 1
		score += profile_weight(entity_id, str(tag), false, session)
	return score


## **Quanto conta questo segno per chi sta giocando** (D-289).
##
## Il profilo strategico (D-288) dice cosa una casa vuole lasciare nel mondo,
## cosa non vuole vederci, e cosa vuole impedire a un'altra. Fino a qui era un
## dato che leggevano solo il validatore e la misura: una strategia dichiarata e
## mai giocata. Qui diventa una **preferenza** — non una regola nuova, un peso
## in piu' nella stessa bilancia che sceglieva gia' fra due meta' di una carta.
##
## `posa` distingue le due direzioni: posare un segno voluto vale, toglierlo
## costa; posare un segno temuto costa, toglierlo vale. E il **sabotaggio**
## conta al contrario: mettere sul tavolo un segno che un rivale ha dichiarato
## di voler impedire — o togliergli quello che vuole — e' un buon affare.
##
## Vale zero per le case senza profilo: la scatola ne ha otto e i profili sono
## quattro, e una casa senza strategia dichiarata gioca come prima.
func profile_weight(
	entity_id: String, tag: String, posa: bool, session: RefCounted
) -> int:
	var profiles: Dictionary = session.data.get("entity_profiles")
	if profiles == null or profiles.is_empty():
		return 0
	var weight: int = 0
	var mine: Variant = profiles.get(entity_id)
	if mine != null:
		for voice in (mine as Dictionary).get("wants", []) as Array:
			if str((voice as Dictionary).get("tag", "")) == tag:
				weight += PROFILE_WEIGHT if posa else -PROFILE_WEIGHT
		for voice in (mine as Dictionary).get("fears", []) as Array:
			if str((voice as Dictionary).get("tag", "")) == tag:
				weight += -PROFILE_WEIGHT if posa else PROFILE_WEIGHT
	# Quello che gli altri hanno dichiarato: il loro desiderio e' la mia
	# occasione di negarlo, e il loro timore la mia arma.
	for other_id in profiles:
		if str(other_id) == entity_id:
			continue
		var other: Dictionary = profiles[str(other_id)] as Dictionary
		for voice in other.get("denies", []) as Array:
			var denial: Dictionary = voice as Dictionary
			if str(denial.get("to", "")) != entity_id:
				continue
			# Un rivale ha dichiarato di volermi impedire proprio questo: se
			# riesco a posarlo lo stesso, vale doppio.
			if str(denial.get("tag", "")) == tag and posa:
				weight += PROFILE_WEIGHT
	return weight


## Nessuna carta per quell'intenzione: si guarda cosa la mano sa fare comunque.
## Una INFLUENZARE si gioca **solo nel verso che il Destino vuole** — spingere
## una domanda dalla parte sbagliata e' peggio che passare; le altre azioni si
## giocano se sono legali.
func _whatever_the_hand_allows(entity_id: String, session: RefCounted) -> Dictionary:
	var plays: Array = hand_plays(entity_id, session)
	return plays[0] if not plays.is_empty() else {}


## **Tutte le mosse che la mano permette adesso**, dalla carta piu' debole alla
## piu' forte (D-285).
##
## Fino a qui questa lista guardava **il solo verbo dichiarato** di ogni carta e
## **un solo bersaglio** per verbo: una mano di sette carte produceva quasi
## sempre zero voci, e il cervello passava con quindici mosse legali sul tavolo.
## Adesso guarda le Azioni stampate (D-283) e, per ognuna, i bersagli che quel
## verbo accetta: e' il conto di quello che al tavolo si potrebbe davvero fare.
##
## Non e' un elenco di **buone** mosse: e' l'elenco di quelle possibili, in un
## ordine che mette per prima la carta che costa meno perdere. Il cervello prende
## la prima; il **distratto** ne pesca una a caso, ed e' cosi' che «fa un'altra
## cosa» senza mai chiedere una mossa illegale.
func hand_plays(entity_id: String, session: RefCounted) -> Array:
	var out: Array = []
	var goals: Dictionary = _tension_goals(entity_id, session)
	for asset_id in _hand_weakest_first(entity_id, session):
		var card: Variant = session.data.assets.get(str(asset_id))
		if card == null:
			continue
		var fixed: Dictionary = (
			((card as Dictionary).get("card_action", {}) as Dictionary).get("params", {})
			as Dictionary
		)
		var printed: Array = (
			((card as Dictionary).get("physical", {}) as Dictionary).get("actions", []) as Array
		)
		for index in range(printed.size()):
			var kind: String = str((printed[index] as Dictionary).get("template", ""))
			if kind == "" or kind == "ACQUIRE":
				continue
			for wanted in _targets_for(entity_id, kind, fixed, goals, session):
				var params: Dictionary = (wanted as Dictionary).duplicate()
				params["asset_id"] = str(asset_id)
				params["face_action"] = int(index)
				var place: String = _best_place(
					card as Dictionary, int(index), params, session, entity_id, str(asset_id)
				)
				if place != "":
					params["mark_region_id"] = place
				if session.actions.can_execute(entity_id, "PLAY_CARD", params):
					out.append({"template": "PLAY_CARD", "params": params})
	return out


## I bersagli che quel verbo accetta adesso, come parametri gia' pronti. Le
## regole li filtrano dopo — qui si propone, non si giudica — con **due
## eccezioni dichiarate**, che sono mosse in cui il cervello farebbe male a se
## stesso e che quindi non si propongono mai:
##
##  - INFLUENZARE si offre **solo nel verso che il Destino vuole**: spingere una
##    domanda dalla parte sbagliata e' peggio che non fare niente;
##  - FORGIARE si offre **solo in su**: rompere un patto per noia e' un prezzo,
##    non un ripiego.
func _targets_for(
	entity_id: String, kind: String, fixed: Dictionary, goals: Dictionary,
	session: RefCounted
) -> Array:
	var out: Array = []
	match kind:
		"MOVE":
			for region_id in session.world["regions"]:
				out.append({"region_id": str(region_id)})
		"INFLUENCE":
			var delta: int = int(fixed.get("delta", 1))
			for tension_id in _sorted(goals.keys()):
				if int(goals[str(tension_id)]) == delta:
					out.append({"tension_id": str(tension_id)})
		"SCHEME":
			for tension_id in session.world["tensions"]:
				out.append({"mode": "TENSION", "tension_id": str(tension_id)})
			for region_id in session.world["regions"]:
				out.append({"mode": "REGION", "region_id": str(region_id)})
		"CLAIM":
			var seen: Dictionary = {}
			for tension_id in session.world["tensions"]:
				var domain: String = str(session.service.tension_domain(str(tension_id)))
				if domain == "" or seen.has(domain):
					continue
				seen[domain] = true
				out.append({"mode": "CREATE", "domain": domain})
		"FORGE":
			for other in session.world["turn_order"]:
				if str(other) == entity_id:
					continue
				out.append({
					"target_entity_id": str(other), "direction": "UP", "consent": true,
				})
	return out


## Il posto migliore dove far cadere i segni di questa meta', o "" se non serve
## sceglierne uno (D-284).
func _best_place(
	card: Dictionary, index: int, params: Dictionary, session: RefCounted,
	entity_id: String, asset_id: String
) -> String:
	var best_place: String = ""
	var best_score: int = 0
	for place in _places_needed(card, index, params, session, asset_id):
		if str(place) == "":
			continue
		var here: Dictionary = params.duplicate()
		here["region_id"] = str(place)
		var score: int = _face_score(card, index, entity_id, here, session)
		if best_place == "" or score > best_score:
			best_place = str(place)
			best_score = score
	return best_place


func _scout(entity_id: String, session: RefCounted) -> Dictionary:
	var wants_discovery: bool = false
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) == "discovery_count":
			wants_discovery = true
	for tension_id in _sorted(session.world["tensions"].keys()):
		if not session.tensions.is_veiled(str(tension_id)):
			continue
		if session.service.knows_tension(entity_id, str(tension_id)):
			continue
		# Scout it if the Destiny needs Discoveries, or if this is a Tension the
		# Entity has an opinion about and currently cannot touch.
		#
		# Quando il velo copre la sola soglia (D-187) la seconda meta' non vale
		# piu': il numero si vede gia' e sulla domanda si agisce lo stesso, quindi
		# scoprire e' un lusso — resta solo per chi il Destino manda a scoprire.
		# Senza questa riga il cervello chiedeva SCOPRIRE per meta' delle
		# Occasioni, e con otto carte su quarantotto che sanno dirlo, passava.
		var worth_it: bool = wants_discovery or (
			not session.tensions.hides_threshold_only()
			and _tension_goals(entity_id, session).has(str(tension_id))
		)
		if worth_it:
			return {
				"template": "SCHEME",
				"params": {"mode": "TENSION", "tension_id": str(tension_id)},
			}
	return {}


func _claim_required_region(entity_id: String, session: RefCounted) -> Dictionary:
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) != "region_presence":
			continue
		if str(condition.get("entity_id", "")) != entity_id:
			continue
		var region_id: String = str(condition.get("region_id", ""))
		var needed: int = int(condition.get("min", 1))
		if session.service.presence_count(entity_id, region_id) >= needed:
			continue
		if not session.service.can_move_to(entity_id, region_id):
			continue
		if session.service.region_free_slots(region_id) <= 0:
			continue
		return {"template": "MOVE", "params": {"region_id": region_id}}
	return {}


## Push a Tension the Destiny cares about, when it is near enough to its
## threshold for the push to change what happens this round.
func _steer(entity_id: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = _tension_goals(entity_id, session)
	for tension_id in _sorted(goals.keys()):
		var id: String = str(tension_id)
		var direction: int = int(goals[id])
		var value: int = session.tensions.value(id)
		# Quando il velo copre la sola soglia (D-187) il seggio spinge lo stesso,
		# ma decide su una soglia **supposta**: sa dov'e' il segnalino, non dove
		# sia il traguardo.
		var threshold: int = _assumed_threshold(id, entity_id, session)
		if direction < 0 and value < threshold - DANGER_MARGIN:
			continue  # not urgent yet
		if direction > 0 and value >= threshold:
			continue  # already there
		if session.tensions.out_of_reach(id, session.service.knows_tension(entity_id, id)):
			continue
		if not _can_influence(entity_id, id, direction, session):
			continue
		return {
			"template": "INFLUENCE",
			"params": {"tension_id": id, "delta": direction},
		}
	return {}


func _can_influence(entity_id: String, tension_id: String, direction: int, session: RefCounted) -> bool:
	var request: Dictionary = {
		"tension_id": tension_id,
		"delta": direction,
	}
	return session.actions.can_execute(entity_id, "INFLUENCE", request)


## Stock the family that is relevant to whichever Tension is closest to going
## off, preferring a Region this Entity can draw double from.
func _acquire(entity_id: String, session: RefCounted) -> Dictionary:
	var wanted: Array = _relevant_families_by_urgency(entity_id, session)
	# Chi ha bisogno della parola ha bisogno di AUTHORITY: una carta per
	# prenotare il dominio e una per forzare il Consiglio (§11, issue #22). Ma
	# solo per completare una coppia gia' cominciata: inseguire AUTHORITY da
	# zero, per un seggio le cui Regioni non ne producono, e' una mano peggiore
	# a ogni Consiglio - misurato, e' costato al seggio del controllo le due
	# Vittorie che lo tenevano sbloccato (D-069).
	if session.service.count_family_in_hand(entity_id, "AUTHORITY") == 1 \
			and not _tensions_needing_the_word(entity_id, session).is_empty():
		wanted = wanted.filter(func(family: Variant) -> bool: return str(family) != "AUTHORITY")
		wanted.push_front("AUTHORITY")
	var sourced: Array = []
	for region_id in session.service.regions_with_presence(entity_id):
		for family in session.data.regions[region_id]["asset_sources"]:
			if not sourced.has(str(family)):
				sourced.append(str(family))

	for family in wanted:
		if sourced.has(str(family)) and _deck_has_cards(str(family), session):
			return {"template": "ACQUIRE", "params": {"family": str(family)}}
	for family in wanted:
		if _deck_has_cards(str(family), session):
			return {"template": "ACQUIRE", "params": {"family": str(family)}}
	for family in sourced:
		if _deck_has_cards(str(family), session):
			return {"template": "ACQUIRE", "params": {"family": str(family)}}
	return {}


func _relevant_families_by_urgency(entity_id: String, session: RefCounted) -> Array:
	var goals: Dictionary = _tension_goals(entity_id, session)
	var ranked: Array = _sorted(session.world["tensions"].keys())
	ranked.sort_custom(func(a: Variant, b: Variant) -> bool:
		var urgency_a: int = _urgency(str(a), entity_id, goals, session)
		var urgency_b: int = _urgency(str(b), entity_id, goals, session)
		if urgency_a == urgency_b:
			return str(a) < str(b)
		return urgency_a > urgency_b
	)
	var families: Array = []
	for tension_id in ranked:
		for family in session.service.relevant_families(str(tension_id)):
			if not families.has(str(family)):
				families.append(str(family))
	return families


func _urgency(tension_id: String, entity_id: String, goals: Dictionary, session: RefCounted) -> int:
	# A Tension you have an opinion about, and that is close to going off, is the
	# one worth holding cards for.
	var closeness: int = (
		session.tensions.value(tension_id) - _assumed_threshold(tension_id, entity_id, session)
	)
	if session.tensions.is_veiled(tension_id) and not session.service.knows_tension(entity_id, tension_id):
		# Un numero che non si vede vale poco (-4); una soglia che non si vede
		# lascia comunque leggere il segnalino, e l'incertezza costa meno (-1).
		closeness -= 1 if session.tensions.hides_threshold_only() else 4
	return closeness + (3 if goals.has(tension_id) else 0)


## La soglia su cui questo seggio decide: quella vera se puo' vederla, quella
## tipica della Chronicle se il velo la copre (D-187).
##
## Col cancello del tavolo (D-203) non c'e' nessuna soglia da raggiungere: quello
## che decide e' **essere il mucchio piu' alto**. La distanza da battere e'
## quindi l'altezza del piu' alto, e per lui stesso e' zero — cosi' «quanto sono
## vicino» continua a voler dire quello che ha sempre voluto dire, misurato sulla
## regola che c'e' adesso. Senza questa riga il seggio si misurava su un numero
## che non succede mai, e ha smesso di prenotare: 27 rivendicazioni aperte
## diventate 18, e le morte dal 41% al 67%.
func _assumed_threshold(tension_id: String, entity_id: String, session: RefCounted) -> int:
	if session.tensions.table_gate() > 0:
		var tallest: String = session.tensions.hottest_pile()
		return 0 if tallest == "" else session.tensions.value(tallest)
	var known: int = session.service.visible_tension_threshold(tension_id, entity_id)
	return known if known >= 0 else session.tensions.typical_threshold()


func _deck_has_cards(family: String, session: RefCounted) -> bool:
	var deck: Variant = session.world["decks"].get(family)
	if deck == null:
		return false
	return not (deck["draw"] as Array).is_empty() or not (deck["discard"] as Array).is_empty()


# --- Confluence ------------------------------------------------------------

## Pick the question that opens the door you actually want to walk through.
##
## This returned "" until D-035, which meant the policy declined to choose and
## `_select_question`'s default - the *last* eligible question - won every time.
## A Council only opens when its Tension is at threshold, and every second
## question is gated on a Tension at threshold, so the second question was always
## eligible and **the first question of every template was never asked once in
## forty Chronicles**. Its propositions could not be voted, and their Consequences
## could not fire: that is the whole of O-8.
##
## A question is worth what the best proposition behind it is worth. Ties break
## on the session RNG, for the same reason they do in `choose_proposition`.
func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	var best_score: int = -999
	var tied: Array = []
	for question in options:
		var score: int = _best_proposition_score(str(question["id"]), context, session)
		if score > best_score:
			best_score = score
			tied = [str(question["id"])]
		elif score == best_score:
			tied.append(str(question["id"]))
	if tied.is_empty():
		return ""
	if tied.size() == 1:
		return str(tied[0])
	return str(tied[session.rng.range_int(0, tied.size() - 1)])


## The best a proponent can do with a question: the highest-scoring proposition
## that is actually legal behind it. Eligibility is checked the same way the
## Council checks it, so the policy never picks a question it cannot use.
func _best_proposition_score(question_id: String, context: Dictionary, session: RefCounted) -> int:
	var template: Variant = session.data.confluence_templates.get(str(context["template_id"]))
	if template == null:
		return -999
	var proponent: String = str(context["proponent"])
	var bindings: Dictionary = session.confluence.effect_context()
	var best: int = -999
	for proposition in template["propositions"]:
		if str(proposition["question_id"]) != question_id:
			continue
		if not session.confluence.conditions.all_hold(proposition["eligibility"], bindings):
			continue
		best = maxi(best, _score_proposition(proposition, proponent, proponent, session))
	return best


## Pick the proposition whose world changes serve this Destiny best.
## Pick what serves your Destiny best - and when nothing does, do not always pick
## the first thing on the list.
##
## Most propositions score 0 against most Destinies, so taking `options[0]` on a
## tie meant twelve of the eighteen authored propositions were never chosen once
## in forty Chronicles, and their Consequences never fired. That is the measuring
## instrument being wrong, not the rules - the same lesson as D-021. The tie is
## broken with the session RNG, so it stays deterministic per seed.
func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	var best_score: int = -999
	var tied: Array = []
	for option in options:
		var score: int = _score_proposition(option, proponent, proponent, session)
		if score > best_score:
			best_score = score
			tied = [str(option["id"])]
		elif score == best_score:
			tied.append(str(option["id"]))
	if tied.size() == 1:
		return str(tied[0])
	return str(tied[session.rng.range_int(0, tied.size() - 1)])


## How much a proposition's consequences help (+) or hurt (-) `entity_id`.
##
## Reads the Consequence Effects against that Entity's own Destiny conditions:
## a tag it needs, a Region it must stand in, a Region it must control. This is
## what turns "the throne requisitions the grain" into "and it clears my people
## out of the Valley, which is half my Victory" - and therefore into a fight.
func _score_proposition(
	proposition: Dictionary, entity_id: String, proponent_id: String, session: RefCounted
) -> int:
	var goals: Dictionary = _tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	var score: int = 0
	for consequence_id in proposition["success_consequences"]:
		var consequence: Variant = session.data.consequences.get(str(consequence_id))
		if consequence == null:
			continue
		for effect in consequence["effects"]:
			score += _score_effect(effect, entity_id, proponent_id, goals, session, bindings)
	return score


## Resolve an authored `$slot` to the id it will actually carry at K.
##
## The Council fixes its bindings at A, before a single stance is declared, so a
## decider voting at D can resolve $region_focus to exactly the Region the
## Consequence will hit. It uses the Council's own table rather than a copy, so
## the two cannot drift.
func _resolve(value: Variant, bindings: Dictionary, session: RefCounted) -> String:
	var text: String = str(value)
	if not text.begins_with("$"):
		return text
	var key: String = text.substr(1)
	if bindings.has(key):
		return str(bindings[key])
	# `$region_with:<tag>` names a kind of place; only the compiler can answer it.
	if bindings.is_empty():
		return text
	return str(session.confluence.compiler.substitute_string(text, bindings))


func _score_effect(
	effect: Dictionary,
	entity_id: String,
	proponent_id: String,
	goals: Dictionary,
	session: RefCounted,
	bindings: Dictionary
) -> int:
	var payload: Dictionary = effect.get("payload", {})
	var effect_type: String = str(effect["type"])
	var target_id: String = _resolve(effect["target"]["id"], bindings, session)
	var score: int = 0

	# A tag your Destiny wants present, or wants gone.
	var tag: String = str(payload.get("tag", ""))
	if tag != "" and goals.has(tag):
		var sets_it: bool = effect_type.begins_with("SET_")
		score += int(goals[tag]) * (1 if sets_it else -1) * 2

	# Being pushed out of - or planted in - a Region your Destiny names. The
	# target is always a $slot in the authored data ($rival, $proponent), so this
	# only ever fires once the slot is resolved.
	if effect_type == "REMOVE_PRESENCE" and target_id == entity_id:
		if _needs_presence(entity_id, _resolve(payload.get("region_id", ""), bindings, session), session):
			score -= 3
	if effect_type == "ADD_PRESENCE" and target_id == entity_id:
		if _needs_presence(entity_id, _resolve(payload.get("region_id", ""), bindings, session), session):
			score += 3

	# A Tension your Destiny puts a ceiling or a floor on. This is the commonest
	# Effect in the whole Consequence set and the commonest clause in the whole
	# Destiny set, and until D-034 the two never met: a proposition that shoved
	# the Famine up by two scored exactly zero against a Destiny whose Victory
	# says the Famine must stay under three.
	if effect_type == "ADJUST_TENSION":
		score += _score_tension_move(
			target_id, int(payload.get("delta", 0)), entity_id, session
		)

	# A Discovery, for a Destiny that counts Discoveries. They are granted to the
	# proponent; someone else learning something costs you nothing.
	if effect_type == "SET_ENTITY_TAG" and str(payload.get("tag", "")).begins_with("discovery:"):
		if target_id == entity_id and _wants_discoveries(entity_id, session):
			score += 2

	# Un rapporto che si muove, per chi ha un Destino che nomina qualcuno.
	if effect_type == "SET_RELATION":
		score += _score_relation_move(target_id, payload, entity_id, session)

	# La propria morte (D-127): un Effect che ti spegne vale piu' di qualunque
	# clausola - il drago si difende con tutto quello che ha, o la caccia
	# diventerebbe una passeggiata nelle sim. La morte altrui resta zero: non
	# e' un obiettivo di nessun Destino, e non deve diventarlo per sbaglio.
	if effect_type == "SET_ENTITY_ACTIVE" and not bool(payload.get("active", true)):
		if target_id == entity_id:
			score -= 6

	# Control changing hands, for whoever counts Regions.
	if effect_type == "SET_CONTROL" and _counts_control(entity_id, session):
		if not session.world["regions"].has(target_id):
			return score
		var new_owner: Variant = payload.get("entity_id", null)
		var holds_it_now: bool = (
			str(session.world["regions"][target_id].get("control", "")) == entity_id
		)
		if new_owner == null:
			if holds_it_now:
				score -= 3  # the title is being taken off you
		else:
			# **A chi va, davvero.** La frase d'autore porta ancora il segnaposto
			# `$proponent`; la voce della carta no — `CouncilEconomy.effects_for`
			# ha gia' risolto il nome prima che il cervello la guardi. Finche'
			# qui si confrontava solo col segnaposto, ogni CAMBIA CONTROLLO
			# stampato su una carta valeva **zero per chiunque**: il proponente
			# non lo vedeva quando comprava, e il rivendicante non lo vedeva
			# quando decideva se posarci la pedina (D-304, misurato: le voci
			# rivendicate erano zero, e mine == theirs su ogni carta).
			var goes_to: String = str(new_owner)
			if goes_to == "$proponent":
				goes_to = proponent_id
			if goes_to == entity_id:
				score += 2
			elif holds_it_now:
				score -= 3  # handed to someone else, out of your hands
			else:
				# La corsa: chi conta le Regioni conta anche quelle degli altri.
				# Senza questo ramo, un seggio con una clausola control_count
				# guardava una Regione cambiare mano verso un terzo e non aveva
				# niente da dire - un'obiezione, non un no (D-070).
				score -= 1
	return score


## What a push on a Tension is worth to this Entity's `tension_limit` clauses.
##
## Breaking a clause that currently holds is worth blocking outright; merely
## moving in the wrong direction inside the band is worth a clause, not a no.
## Symmetrically for a move that repairs a limit already broken.
func _score_tension_move(
	tension_id: String, delta: int, entity_id: String, session: RefCounted
) -> int:
	if delta == 0 or not session.world["tensions"].has(tension_id):
		return 0
	var score: int = 0
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) != "tension_limit":
			continue
		if str(condition.get("tension_id", "")) != tension_id:
			continue
		var value: int = session.tensions.value(tension_id)
		var after: int = value + delta
		if condition.has("max"):
			var ceiling: int = int(condition["max"])
			if value <= ceiling and after > ceiling:
				score -= 2  # this is what breaks the clause
			elif value > ceiling and after <= ceiling:
				score += 2  # this is what repairs it
			elif delta > 0:
				score -= 1
			else:
				score += 1
		if condition.has("min"):
			var floor_value: int = int(condition["min"])
			if value >= floor_value and after < floor_value:
				score -= 2
			elif value < floor_value and after >= floor_value:
				score += 2
			# Il ramo che mancava. `max` aveva il suo ripiego dentro la banda e
			# `min` no, quindi una clausola «questa domanda resti calda» era cieca
			# a tutto quello che non le passava sopra la soglia: chi ha bisogno
			# che una questione bruci non aveva niente da dire finche' non gliela
			# spegnevano del tutto (D-066).
			elif delta < 0:
				score -= 1
			else:
				score += 1
	return score


## Cosa vale, per questa Entita', un rapporto che si muove.
##
## `SET_RELATION` era l'unico Effect che nessun punteggio guardava: letto 126
## volte su 40 Chronicle e **mai** pesato una sola. Forgiare - muovere di un
## passo il rapporto con un altro giocatore - e' una delle sei azioni del gioco,
## e per chi decide non esisteva ([D-066](../../../docs/DECISIONS.md#d-066)).
##
## Stessa forma di `_score_tension_move`, e per la stessa ragione: rompere una
## clausola che regge vale un no; muoversi nella direzione sbagliata restando
## dentro la banda vale un'obiezione.
func _score_relation_move(
	pair: String, payload: Dictionary, entity_id: String, session: RefCounted
) -> int:
	var halves: PackedStringArray = pair.split("|")
	if halves.size() != 2:
		return 0
	var a: String = str(halves[0])
	var b: String = str(halves[1])
	# Un rapporto fra altri due non e' affar mio, come una Scoperta di qualcun
	# altro. Il tavolo ha quattro seggi: quasi meta' dei rapporti non mi tocca.
	if entity_id != a and entity_id != b:
		return 0
	var other: String = b if entity_id == a else a
	var level: String = str(payload.get("level", ""))
	if level == "":
		return _score_relation_tag(payload, entity_id, other, session)
	var after: int = WorldStateService.RELATION_ORDER.find(level)
	if after < 0:
		return 0
	var before: int = session.service.relation_rank(entity_id, other)
	var score: int = 0
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) != "relation_state":
			continue
		if not _names_pair(condition, entity_id, other):
			continue
		var wanted: int = WorldStateService.RELATION_ORDER.find(
			str(condition.get("level", "NEUTRAL"))
		)
		if wanted < 0:
			continue
		var held: bool = _relation_satisfied(before, wanted, condition)
		var holds_after: bool = _relation_satisfied(after, wanted, condition)
		if held and not holds_after:
			score -= 2
		elif holds_after and not held:
			score += 2
		elif after < before:
			score -= 1
		elif after > before:
			score += 1
	return score


## Un tag sul rapporto - `PACT` - non e' un livello: e' quello che le clausole
## `promise_kept` e `promise_broken` guardano. Prendere un impegno con chi il tuo
## Destino nomina vale; scioglierlo costa.
func _score_relation_tag(
	payload: Dictionary, entity_id: String, other: String, session: RefCounted
) -> int:
	var added: String = str(payload.get("add_tag", ""))
	var removed: String = str(payload.get("remove_tag", ""))
	if added == "" and removed == "":
		return 0
	for condition in _conditions(entity_id, session):
		var kind: String = str(condition.get("type", ""))
		if kind != "promise_kept" and kind != "promise_broken":
			continue
		if not _names_pair(condition, entity_id, other):
			continue
		var wants_promise: bool = kind == "promise_kept"
		if added != "":
			return 2 if wants_promise else -2
		return -2 if wants_promise else 2
	return 0


## Se una clausola parla proprio di questa coppia. `$slot` compresi: un Destino
## che nomina `$rival` parla di chiunque il mondo abbia messo in quel posto.
func _names_pair(condition: Dictionary, entity_id: String, other: String) -> bool:
	var named: Array = [
		str(condition.get("entity_id", "")), str(condition.get("other_entity_id", ""))
	]
	return named.has(entity_id) and named.has(other)


func _relation_satisfied(rank: int, wanted: int, condition: Dictionary) -> bool:
	if bool(condition.get("at_least", true)):
		return rank >= wanted
	return rank == wanted


func _wants_discoveries(entity_id: String, session: RefCounted) -> bool:
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) == "discovery_count":
			return true
	return false


func _needs_presence(entity_id: String, region_id: String, session: RefCounted) -> bool:
	if region_id == "":
		return false
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) != "region_presence":
			continue
		if str(condition.get("entity_id", "")) != entity_id:
			continue
		if str(condition.get("region_id", "")) == region_id:
			return true
	return false


func _counts_control(entity_id: String, session: RefCounted) -> bool:
	for condition in _conditions(entity_id, session):
		if str(condition.get("type", "")) == "control_count":
			return true
	return false


## Support what helps you, block what hurts you, sit out what does neither.
func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
	var proposition: Dictionary = _current_proposition(context, session)
	if proposition.is_empty():
		return {"stance": "ABSTAIN", "clause_id": ""}
	var score: int = _score_proposition(proposition, entity_id, str(context["proponent"]), session)
	if score > 0:
		return {"stance": "SUPPORT", "clause_id": ""}
	# Something that really costs you is worth blocking. A clause is the answer
	# to a mild dislike, not to losing half your Destiny.
	if score <= -2:
		return {"stance": "OPPOSE", "clause_id": ""}
	if score < 0:
		var clause: String = _best_clause(entity_id, context, session)
		if clause != "":
			return {"stance": "CONDITION", "clause_id": clause}
		return {"stance": "OPPOSE", "clause_id": ""}
	return {"stance": "ABSTAIN", "clause_id": ""}


func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
	if limit <= 0:
		return []
	var proposition: Dictionary = _current_proposition(context, session)
	var stake: int = 1
	if not proposition.is_empty():
		stake = absi(_score_proposition(proposition, entity_id, str(context["proponent"]), session))
	if entity_id == str(context["proponent"]):
		stake = maxi(stake, 2)
	var wanted: int = clampi(stake, 0, limit)
	if wanted <= 0:
		return []
	var ranked: Array = session.service.ranked_hand_for_tension(
		entity_id, str(context["tension_id"])
	)
	return ranked.slice(0, wanted)


func choose_recovery(_context: Dictionary, _session: RefCounted) -> Dictionary:
	return {}


## **L'economia del Consiglio, giocata dal cervello** (D-387).
##
## Comprare non e' gratis: il primo beneficio lo e', ogni altro costa **un
## gettone di rivendicazione** — una moneta che si guadagna un turno prima,
## giocando una carta Asset dalla sua faccia RIVENDICARE. Quindi il conto e'
## cambiato, ed e' piu' semplice di prima: *questo beneficio in piu' vale il
## gettone che mi costa?* Il prezzo che gli avversari sceglieranno non entra
## piu' nel conto, perche' non e' piu' il prezzo di quello che compro — e'
## quello che loro decidono di pagare per farmelo pagare.
func choose_benefits(
	entity_id: String, context: Dictionary, menu: Array, session: RefCounted
) -> Array:
	if menu.is_empty():
		return []
	var goals: Dictionary = _tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	var ranked: Array = []
	for voice in menu:
		ranked.append({
			"id": str((voice as Dictionary)["id"]),
			"score": _voice_score(
				voice as Dictionary, "benefits", entity_id, entity_id, goals, session, bindings
			),
		})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["score"]) > int(b["score"])
	)
	# **Il tetto lo dicono i gettoni** (D-387): il primo beneficio e' gratis,
	# e oltre quello si arriva fin dove la borsa arriva. Il tetto di tre resta,
	# perche' sono le pedine che stanno sulla carta.
	var ceiling: int = mini(ranked.size(), session.confluence.benefit_ceiling())
	var bought: Array = [str((ranked[0] as Dictionary)["id"])]
	for i in range(1, ceiling):
		var entry: Dictionary = ranked[i] as Dictionary
		# **Un gettone si spende per qualcosa che serve.** Non c'e' piu' un
		# prezzo da pareggiare: c'e' una moneta da non buttare. Una casella che
		# non porta niente a chi propone non vale il gettone, e il gettone
		# aspetta il Consiglio dopo.
		if int(entry["score"]) <= 0:
			break
		bought.append(str(entry["id"]))
	return bought


## **Un avversario decide se pagare per far pagare** (D-387).
##
## La domanda non e' piu' *«quale prezzo, fra quelli dovuti»* — non e' piu'
## dovuto niente. E': *ho un gettone, e c'e' un costo che fa abbastanza male al
## proponente da valere la spesa?* Se no, ci si astiene, e la proposta passa
## gratis: e' la cosa che prima non poteva succedere.
func choose_cost_token(
	entity_id: String, context: Dictionary, menu: Array, session: RefCounted
) -> String:
	if menu.is_empty() or session.confluence.claim_tokens(entity_id) <= 0:
		return ""
	var chosen: Array = choose_costs(entity_id, context, menu, 1, session)
	if chosen.is_empty():
		return ""
	# Un costo che al proponente non toglie niente non vale un gettone: si
	# spende per fare male, non per posare una pedina.
	var proponent: String = str(context.get("proponent", ""))
	var voice: Dictionary = session.confluence._voice("costs", str(chosen[0]))
	if voice.is_empty():
		return ""
	var score: int = _voice_score(
		voice, "costs", proponent, proponent, _tag_goals(proponent, session), session,
		session.confluence.effect_context()
	)
	return "" if score >= 0 else str(chosen[0])


## **E il prezzo lo sceglie chi lo subisce**: fra i costi stampati, il fronte
## avverso posa quelli che pesano di piu' **al proponente**. Non e' cattiveria:
## e' l'unica lettura che rende la scelta una scelta.
func choose_costs(
	entity_id: String, context: Dictionary, menu: Array, due: int, session: RefCounted
) -> Array:
	if due <= 0 or menu.is_empty():
		return []
	var proponent: String = str(context.get("proponent", ""))
	var goals: Dictionary = _tag_goals(proponent, session)
	var bindings: Dictionary = session.confluence.effect_context()
	var ranked: Array = []
	for voice_id in menu:
		var voice: Dictionary = session.confluence._voice("costs", str(voice_id))
		if voice.is_empty():
			continue
		ranked.append({
			"id": str(voice_id),
			"score": _voice_score(
				voice, "costs", proponent, proponent, goals, session, bindings
			),
		})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["score"]) < int(b["score"])
	)
	var chosen: Array = []
	for entry in ranked:
		if chosen.size() >= due:
			break
		chosen.append(str((entry as Dictionary)["id"]))
	return chosen


## Quanto vale una voce della carta per un seggio: si costruiscono i suoi
## Effetti col vocabolario (D-280) e si leggono con lo stesso metro delle
## Conseguenze. Cosi' il cervello non ha una seconda tabella di valori da
## tenere allineata: ne ha una sola, e vale per tutto quello che tocca il mondo.
func _voice_score(
	voice: Dictionary, kind: String, entity_id: String, proponent_id: String,
	goals: Dictionary, session: RefCounted, bindings: Dictionary
) -> int:
	var theme_id: String = str((session.data.tensions.get(
		str(session.confluence.current.get("tension_id", "")), {}
	) as Dictionary).get("theme", ""))
	var effects: Array = CouncilEconomy.effects_for(
		voice, kind, bindings, session.world, theme_id, {}
	)
	var score: int = CouncilEconomy.intrinsic_value(
		voice, kind, bindings, session.world, theme_id
	)
	for effect in effects:
		score += _score_effect(effect, entity_id, proponent_id, goals, session, bindings)
		# **E quello che questa casa ha dichiarato di volere lasciare** (D-289):
		# e' al Consiglio che la dichiarazione conta di piu', perche' li' si
		# compra. La misura dice che di sedici cose volute il Consiglio ne sa
		# dare quattro (D-288): questa riga fa in modo che, quando una di
		# quelle quattro e' sul tavolo, il proponente la veda.
		var payload: Dictionary = (effect as Dictionary).get("payload", {}) as Dictionary
		var tag: String = str(payload.get("tag", ""))
		if tag != "":
			var puts: bool = not str((effect as Dictionary).get("type", "")).begins_with("REMOVE")
			score += profile_weight(entity_id, tag, puts, session)
	return score


## Quanto valgono, per questo seggio, gli Effect di una Conseguenza: la stessa
## lettura di _score_proposition, voce per voce.
func _consequence_score(
	consequence_id: String,
	entity_id: String,
	proponent_id: String,
	goals: Dictionary,
	session: RefCounted,
	bindings: Dictionary
) -> int:
	var consequence: Variant = session.data.consequences.get(str(consequence_id))
	if consequence == null:
		return 0
	var score: int = 0
	for effect in consequence["effects"]:
		score += _score_effect(effect, entity_id, proponent_id, goals, session, bindings)
	return score


## La controproposta del RIVENDICARE (D-268): spendere il diritto qui - sulla
## pedina del prezzo o su una casella comprata sulla carta (D-304) - oppure
## tenerselo per il secondo dibattito. Si rivendica il beneficio se, parlando
## di te invece che del proponente, serve il tuo Destino; si prende la pedina se sposta il
## prezzo a tuo favore piu' di quanto farebbe il fronte avverso da solo;
## altrimenti niente: il secondo dibattito vale l'azione che e' costato.
func choose_counterclaim(
	entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted
) -> Dictionary:
	var goals: Dictionary = _tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	var proponent: String = str(context["proponent"])
	# La voce rivendicata parla di te: si valuta con te al posto del proponente,
	# e vale il **guadagno** del dirottamento, non la voce in se'.
	var redirected: Dictionary = bindings.duplicate()
	redirected["proponent"] = entity_id
	var best_benefit: String = ""
	var benefit_gain: int = 0
	for voice_id in (offer.get("benefits", []) as Array):
		# **Le caselle comprate sulla carta** (D-304), non le Conseguenze del
		# template: si rivendica quello che sta sul tavolo, e la pedina si posa
		# su una pedina gia' posata.
		var voice: Dictionary = session.confluence._voice("benefits", str(voice_id))
		if voice.is_empty():
			continue
		var mine: int = _voice_score(
			voice, "benefits", entity_id, entity_id, goals, session, redirected
		)
		var theirs: int = _voice_score(
			voice, "benefits", entity_id, proponent, goals, session, bindings
		)
		if mine - theirs > benefit_gain:
			benefit_gain = mine - theirs
			best_benefit = str(voice_id)
	# **Prendersi la scelta del prezzo** (D-268, riscritta da D-387) vale
	# adesso quanto il danno che quel costo fa al proponente — tutto intero,
	# perche' senza la controproposta quel costo non ci sarebbe: il prezzo non
	# e' piu' dovuto, se lo compra chi lo vuole spendendo un gettone, e questa
	# e' la strada che lo posa **senza spenderne uno**.
	var price: Dictionary = offer.get("price", {})
	var costs: Array = price.get("cost", []) as Array
	var mine_costs: Array = choose_costs(entity_id, context, costs, 1, session)
	var price_gain: int = 0
	if not mine_costs.is_empty():
		var mine_voice: Dictionary = session.confluence._voice("costs", str(mine_costs[0]))
		price_gain = -_voice_score(
			mine_voice, "costs", entity_id, proponent, goals, session, bindings
		)
	if benefit_gain > 0 and benefit_gain >= price_gain:
		return {"mode": "benefit", "voice_id": best_benefit}
	if price_gain > 0:
		return {
			"mode": "price",
			"cost": "" if mine_costs.is_empty() else str(mine_costs[0]),
			"failure": "" if mine_costs.size() < 2 else str(mine_costs[1]),
		}
	return {}
func _price_gain(
	pool: Array,
	entity_id: String,
	proponent: String,
	goals: Dictionary,
	session: RefCounted,
	bindings: Dictionary
) -> int:
	if pool.size() <= 1:
		return 0
	var best: int = -999
	for consequence_id in pool:
		best = maxi(best, _consequence_score(
			str(consequence_id), entity_id, proponent, goals, session, bindings
		))
	return best - _consequence_score(
		str(pool[0]), entity_id, proponent, goals, session, bindings
	)


func _current_proposition(context: Dictionary, session: RefCounted) -> Dictionary:
	var template: Variant = session.data.confluence_templates.get(str(context["template_id"]))
	if template == null:
		return {}
	for proposition in template["propositions"]:
		if str(proposition["id"]) == str(context.get("proposition_id", "")):
			return proposition
	return {}


## La clausola e' la meta' negoziale del Consiglio (§12.3), e fino alla 0.1.27
## la policy prendeva sempre la prima della lista: la sonda delle posizioni ha
## contato **zero** scelte della seconda clausola di ogni template, in tutt'e
## due le saghe - meta' del contenuto negoziale era morto (D-035, D-070). Si
## sceglie quella i cui Effect servono meglio il proprio Destino; a parita'
## decide l'RNG di sessione, per la stessa ragione di choose_proposition.
func _best_clause(entity_id: String, context: Dictionary, session: RefCounted) -> String:
	var template: Variant = session.data.confluence_templates.get(str(context["template_id"]))
	if template == null or (template["condition_clauses"] as Array).is_empty():
		return ""
	var goals: Dictionary = _tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	var proponent: String = str(context.get("proponent", ""))
	var best_score: int = -999
	var tied: Array = []
	for clause in template["condition_clauses"]:
		var score: int = 0
		for effect in clause["effects"]:
			score += _score_effect(effect, entity_id, proponent, goals, session, bindings)
		if score > best_score:
			best_score = score
			tied = [str(clause["id"])]
		elif score == best_score:
			tied.append(str(clause["id"]))
	if tied.size() == 1:
		return str(tied[0])
	return str(tied[session.rng.range_int(0, tied.size() - 1)])


## La carta del Narratore (ISSUES 23, D-118): la prima carta in mano che la
## storia accetta, quando le risorse reggono il prezzo (una carta Asset). Il
## resolver rifiuta da solo quelle non eleggibili: qui si chiede, non si giudica.
##
## Al massimo UNA per atto a seggio: senza questo freno la sedia svuotava la
## mano appena poteva - 17 carte a cronaca contro le 3 di prima - e i Consigli
## scendevano sotto la banda del §7 (le azioni finivano tutte nel Narratore).
## Il conto si legge dal registro degli Effect, non da una memoria della sedia:
## una partita ripresa dal salvataggio deve rifare le stesse scelte (§18.3).
func _play_narrator(entity_id: String, session: RefCounted) -> Dictionary:
	if session.service.hand_size(entity_id) < COMFORTABLE_HAND:
		return {}
	# **Via il tetto di una calata per Atto** (D-360, scelta del committente).
	# Serviva quando l'Eco arrivava da un mazzo del Narratore e calarne due di
	# fila voleva dire raccontare la storia da soli. Adesso l'Eco e' un'opzione
	# della carta che si ha in mano, come le sue due Azioni: chi ne cala due in
	# un Atto ha speso due carte per farlo, e quello e' gia' il freno.
	# Non basta che la storia accetti la carta: deve servire a chi la cala.
	# Senza questo filtro le sedie calavano qualunque cosa fosse eleggibile e
	# Kessa restava piantata al Minimo (46/50): le carte altrui le scaldavano
	# le questioni contro. Il punteggio e' lo stesso delle clausole negoziali.
	#
	# ISSUES 23 fase 2: i binding sono quelli con cui la carta verra' davvero
	# compilata (chi cala e' il proponente), non quelli del Consiglio aperto -
	# fuori da un Consiglio sono vuoti, e un hook scritto su un $slot pesava
	# zero per costruzione. E le Conseguenze agganciate contano come contano
	# in una proposta: sono la parte pesante della carta.
	var goals: Dictionary = _tag_goals(entity_id, session)
	# D-359: non c'e' piu' una mano del Narratore da scorrere. Si guardano le
	# carte Asset che il seggio ha in mano, e di ognuna la sua versione
	# potenziata - l'Eco stampato sulla stessa faccia.
	for asset_id in session.service.hand(entity_id):
		var params: Dictionary = {"asset_card_id": str(asset_id)}
		if not session.actions.can_execute(entity_id, "PLAY_ECHO", params):
			continue
		var card_id: String = str((session.data.assets[str(asset_id)] as Dictionary)["echo_id"])
		var score: int = 0
		for hook in session.data.echo_cards[card_id].get("effect_hooks", []):
			var bindings: Dictionary = session.chronicle.card_bindings(hook, entity_id)
			if str(hook.get("kind", "")) == "EFFECT":
				score += _score_effect(hook["effect"], entity_id, entity_id, goals, session, bindings)
			elif str(hook.get("kind", "")) == "CONSEQUENCE":
				var consequence: Variant = session.data.consequences.get(
					str(hook.get("consequence_id", ""))
				)
				if consequence == null:
					continue
				for effect in consequence["effects"]:
					score += _score_effect(effect, entity_id, entity_id, goals, session, bindings)
		if score > 0:
			return {"template": "PLAY_ECHO", "params": params}
	return {}


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out
