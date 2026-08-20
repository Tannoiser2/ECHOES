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

## Stop stockpiling and start acting once the hand is this full.
const COMFORTABLE_HAND: int = 4
## A Tension this close to its threshold is worth spending an action on.
const DANGER_MARGIN: int = 2

var log: RefCounted


func _init(p_log: RefCounted = null) -> void:
	log = p_log


# --- goals -----------------------------------------------------------------

## Every condition in the Entity's Destiny, across all three levels.
func _conditions(entity_id: String, session: RefCounted) -> Array:
	var destiny: Dictionary = _destiny(entity_id, session)
	if destiny.is_empty():
		return []
	var out: Array = []
	for level in ["minimum", "victory", "triumph"]:
		out.append_array(_flat(destiny[level]["conditions"]))
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
func _open_levels(entity_id: String, session: RefCounted) -> Array:
	var destiny: Dictionary = _destiny(entity_id, session)
	if destiny.is_empty():
		return []
	var out: Array = []
	for level in ["minimum", "victory", "triumph"]:
		var conditions: Array = destiny[level]["conditions"]
		# Il livello si giudica sulla lista vera e si gioca su quella appiattita.
		if not session.destinies.conditions.all_hold(conditions, {"self": entity_id}):
			out.append(_flat(conditions))
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
func _nearest_demanding(entity_id: String, session: RefCounted, wants: Callable) -> Dictionary:
	var fallback: Dictionary = {}
	for conditions in _open_levels(entity_id, session):
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
	return _nearest_demanding(
		entity_id,
		session,
		func(live: Array) -> Dictionary: return _goals_of(entity_id, session, live)
	)


## What one rung of the ladder asks of the Tensions.
func _goals_of(entity_id: String, session: RefCounted, live: Array) -> Dictionary:
	var goals: Dictionary = {}
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
	return goals


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
func _claim_the_word(entity_id: String, session: RefCounted) -> Dictionary:
	for tension_id in _tensions_needing_the_word(entity_id, session):
		var id: String = str(tension_id)
		var value: int = session.tensions.value(id)
		var threshold: int = session.tensions.threshold(id)
		if value < threshold - 2 * DANGER_MARGIN:
			continue  # la domanda non si e' ancora scaldata
		# Si forza in un round che sarebbe rimasto muto: un Claim forzato ha la
		# precedenza sul trigger a soglia (§7) e manda in coda il Consiglio di
		# qualcun altro - misurato, e' il seggio dalla soglia piu' bassa a
		# pagarlo, ogni volta (D-069). Cosi' il Consiglio forzato si aggiunge
		# all'anno invece di rubare il posto a quello che stava arrivando.
		if value >= threshold - DANGER_MARGIN \
				and session.service.hand_size(entity_id) >= COMFORTABLE_HAND \
				and (session.tensions.tensions_at_threshold() as Array).is_empty():
			var force: Dictionary = {"mode": "FORCE", "tension_id": id}
			if session.actions.can_execute(entity_id, "CLAIM", force):
				return {"template": "CLAIM", "params": force}
		var domain: String = session.service.tension_domain(id)
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


## L'alleanza che conviene (D-171).
##
## Fino a qui un seggio stringeva un legame **solo** se una clausola del suo
## Destino nominava quella relazione — `_relations_of` legge esattamente quelle
## tre. Mai perche' gli tornava utile. E dal D-139 tornare utile e' una cosa
## misurabile: un alleato che sostiene il proponente porta **+1** sul fronte del
## Consiglio, +2 se BOUND, col tetto a 2 e almeno due carte impegnate.
##
## **Con chi conviene non e' «chi vuole i miei stessi segni».** La prima forma
## scritta contava i segni voluti in comune, e non ha sparato una volta: fra gli
## otto Destini del gioco **non esiste una coppia che voglia lo stesso segno
## nello stesso verso**. Ogni sovrapposizione e' un'opposizione — Aldric contro
## Nahr sulla corona spezzata, Lyra contro Vaerax sulle Miniere sigillate — e il
## resto e' indifferenza. Il contenuto e' scritto come una rete di contrasti, e
## un'alleanza costruita sugli obiettivi comuni non ha niente su cui mordere.
##
## Conviene invece **a chi aspetta lo stesso Consiglio**. `_needed_confluences`
## dice gia' quali Tensioni un seggio ha bisogno che arrivino al voto, perche'
## la sola cosa che chiude una sua clausola sta dietro quella domanda. Due
## seggi che aspettano la stessa domanda staranno sullo stesso fronte quando si
## apre, e li' il legame vale il peso in piu'. Chi mi si oppone su un segno resta
## fuori comunque, per quanti Consigli condividiamo.
##
## Si paga: salire di un grado costa una carta BONDS e un'Occasione. Per questo
## sta **dopo** tutto quello che il Destino chiede esplicitamente e dietro la
## stessa soglia di mano dello steering — un seggio che brucia l'ultima carta
## per un'amicizia non sta giocando bene, sta solo facendo amicizia.
##
## **Dichiarato**: leggere il Destino altrui e' piu' di quello che un giocatore
## vero sa. Al tavolo l'informazione arriva da come gli altri votano, non dalla
## loro carta. E' una semplificazione del bot, non una regola del gioco, e va
## rifatta quando i seggi impareranno a dedurre invece che a sbirciare.
func _ally_of_convenience(entity_id: String, session: RefCounted) -> Dictionary:
	# Chi non ha piu' niente da vincere non ha niente da comprare.
	var open_levels: Array = _open_levels(entity_id, session)
	if open_levels.is_empty():
		return {}
	var mine_waiting: Array = _needed_confluences(entity_id, session, open_levels[0] as Array)
	if mine_waiting.is_empty():
		return {}
	var mine_tags: Dictionary = _tag_goals(entity_id, session)
	var best: String = ""
	var best_score: int = 0
	for other in _sorted((session.world["entities"] as Dictionary).keys()):
		var other_id: String = str(other)
		if other_id == entity_id:
			continue
		if not bool((session.world["entities"][other_id] as Dictionary)["active"]):
			continue
		var their_levels: Array = _open_levels(other_id, session)
		if their_levels.is_empty():
			continue
		# Un contrasto dichiarato su un segno chiude la porta, e non si riapre
		# contando le domande in comune: e' quello che il Destino dice di volere.
		var their_tags: Dictionary = _tag_goals(other_id, session)
		var opposed: bool = false
		for tag in mine_tags:
			if their_tags.has(tag) and int(their_tags[tag]) != int(mine_tags[tag]):
				opposed = true
				break
		if opposed:
			continue
		var score: int = 0
		for tension_id in _needed_confluences(other_id, session, their_levels[0] as Array):
			if mine_waiting.has(tension_id):
				score += 1
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

func choose_action(entity_id: String, _ao_index: int, session: RefCounted) -> Dictionary:
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

	# 6. Otherwise prepare: stock the family that will matter.
	var acquire: Dictionary = _acquire(entity_id, session)
	if not acquire.is_empty():
		return acquire

	var steer_anyway: Dictionary = _steer(entity_id, session)
	if not steer_anyway.is_empty():
		return steer_anyway
	return {"template": "PASS", "params": {}}


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
		if wants_discovery or _tension_goals(entity_id, session).has(str(tension_id)):
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
		var threshold: int = session.tensions.threshold(id)
		if direction < 0 and value < threshold - DANGER_MARGIN:
			continue  # not urgent yet
		if direction > 0 and value >= threshold:
			continue  # already there
		if session.tensions.is_veiled(id) and not session.service.knows_tension(entity_id, id):
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
	var closeness: int = session.tensions.value(tension_id) - session.tensions.threshold(tension_id)
	if session.tensions.is_veiled(tension_id) and not session.service.knows_tension(entity_id, tension_id):
		closeness -= 4
	return closeness + (3 if goals.has(tension_id) else 0)


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
		elif str(new_owner) == "$proponent":
			if entity_id == proponent_id:
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
	var act: int = int(session.world["act"])
	for effect in session.world["effect_log"]:
		var src: Dictionary = effect.get("source", {})
		if str(src.get("id", "")) == "ACT_PLAY_ECHO" \
				and str(src.get("actor", "")) == entity_id \
				and int(src.get("act", 0)) == act:
			return {}
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
	for card_id in session.world["entities"][entity_id].get("echo_hand", []):
		var params: Dictionary = {"echo_card_id": str(card_id)}
		if not session.actions.can_execute(entity_id, "PLAY_ECHO", params):
			continue
		var score: int = 0
		for hook in session.data.echo_cards[str(card_id)].get("effect_hooks", []):
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
