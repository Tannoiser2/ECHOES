extends RefCounted
## Act / round / AO progression (§7).
##
## Chronicle I is 3 Acts x 3 rounds, 2 Action Opportunities per player per
## round, a Drift at the end of every round and at most one Confluence opened
## per round. Every one of those numbers comes from the Chronicle data, not from
## here.
##
## The controller never decides anything itself: it asks a `decider` object.
## The CLI harness supplies a scripted decider; the 0.1 hotseat UI will supply
## an interactive one. That is what makes the same rules playable headless.

const Effect := preload("res://scripts/core/effect.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")
const HousePowerRules := preload("res://scripts/world/house_power_rules.gd")
const HandRhythm := preload("res://scripts/world/hand_rhythm.gd")
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")

signal phase_changed(act: int, round: int, phase: String)
signal confluence_resolved(result: Dictionary)
var session: RefCounted
var world: Dictionary
var data: RefCounted
var log: RefCounted

var illegal_actions: int = 0
var confluence_results: Array = []

var _chronicle: Dictionary
var _conditions: RefCounted


func _init(p_session: RefCounted) -> void:
	session = p_session
	world = p_session.world
	data = p_session.data
	log = p_session.log
	_chronicle = data.chronicles[world["chronicle_id"]]
	_conditions = ConditionEvaluator.new(world, data)


## Play the whole Chronicle. Returns a run report.
##
## A coroutine, and only because of one thing: a decider may need to *wait*.
## A CLI decider answers immediately and this never suspends - `await` on a
## synchronous call returns straight away, so the headless runs are unchanged
## down to the byte. A decider driven by a mouse cannot answer immediately, and
## without this the browser would have to freeze the whole Chronicle to ask a
## question (D-038).
func run(decider: Object) -> Dictionary:
	# A restored world is one that has already been dealt: setting it up again
	# would deal every opening hand a second time. `act` is 0 only before the
	# first round of a fresh Chronicle, which is exactly the test (D-052).
	if int(world["act"]) == 0:
		setup()
		for act in range(1, int(_chronicle["acts"]) + 1):
			await play_act(act, decider)
		return chronicle_end()

	# Where to pick up. The world carries the round it was *in*, and the phase
	# says whether that round finished: anything past ACTIONS means it did, so
	# the next one is where to stand. Getting this off by one replays a round -
	# the same actions twice, the same Drift twice - and the year comes out
	# different from the one that was never interrupted.
	var from_act: int = int(world["act"])
	var phase: String = str(world["phase"])
	var from_round: int = int(world["round"]) + (0 if phase == "ACTIONS" else 1)
	var rounds: int = int(_chronicle["rounds_per_act"])

	# Un salvataggio preso fra le azioni e il Consiglio - DRIFT o THRESHOLD_CHECK
	# - ha il round quasi finito: le azioni sono spese, ma la domanda del round
	# non e' ancora stata posta. Riprendere dal round dopo la salterebbe, e
	# rigiocare il round rifarebbe le azioni due volte. Il buco e' rimasto
	# invisibile finche' nessun Consiglio si apriva cosi' presto nell'anno: e'
	# stata la policy che forza i Consigli col Claim (D-069) a scoprirlo. Si
	# riprende esattamente da li': l'eventuale Drift dovuto, il Consiglio dovuto,
	# e poi il resto dell'anno.
	if phase == "DRIFT" or phase == "THRESHOLD_CHECK":
		log.section("SI RIPRENDE - Atto %d, round %d, alla soglia" % [from_act, int(world["round"])])
		if phase == "DRIFT":
			session.tensions.apply_drift()
			_apply_overextension(from_act, int(world["round"]))
		_set_phase(from_act, int(world["round"]), "THRESHOLD_CHECK")
		await _end_of_round_confluence(decider)
		for tension_id in world["tensions"]:
			log.bullet(session.tensions.public_status(str(tension_id)))
		if from_round > rounds:
			await end_of_act(from_act, decider)
			from_act += 1
			from_round = 1
	# And if that round is off the end of the Act, the Act's own ending has not
	# happened yet: the Council that closes the Act runs there, and skipping it
	# would lose it.
	elif from_round > rounds:
		log.section("SI RIPRENDE - fine dell'Atto %d" % from_act)
		await end_of_act(from_act, decider)
		from_act += 1
		from_round = 1
	else:
		log.section("SI RIPRENDE - Atto %d, round %d" % [from_act, from_round])

	for act in range(from_act, int(_chronicle["acts"]) + 1):
		await play_act(act, decider, from_round if act == from_act else 1)
	return chronicle_end()


## Le righe che il mondo dice all'apertura, una per domanda in gioco (D-207).
##
## `opening_text` e' la cornice - l'anno, e cosa vale comunque - e le domande
## si raccontano da sole, perche' **quali domande siano non si sa finche' non
## sono pescate**. Prima di 0.1.175 l'apertura era un paragrafo scritto a mano
## che nominava quattro domande, e dava la Carestia per certa: darle la
## biblioteca senza spezzarlo avrebbe fatto leggere al tavolo un anno che non
## stava giocando. Una domanda senza riga tace invece di mentire.
func opening_question_lines() -> Array:
	var out: Array = []
	for tension_id in world["tensions"]:
		var definition: Dictionary = session.data.tensions[str(tension_id)]
		var line: String = str(definition.get("opening_line", ""))
		if line != "":
			out.append(line)
	return out


func setup() -> void:
	_set_phase(0, 0, "SETUP")
	log.section("CHRONICLE %s - %s" % [str(_chronicle["id"]), str(_chronicle["title"])])
	log.line(str(_chronicle["opening_text"]))
	for line in opening_question_lines():
		log.line(str(line))
	log.line("")
	for effect in session.factory_setup_effects():
		session.applier.apply(effect)
	var inherited: Array = session.inheritance_effects()
	if not inherited.is_empty():
		log.section("EREDITA DELLA CHRONICLE PRECEDENTE")
		for effect in inherited:
			session.applier.apply(effect)
		for scar in world["scars"]:
			log.bullet(str(scar["description"]))
	log.section("SITUAZIONE INIZIALE")
	for entity_id in world["turn_order"]:
		log.bullet(
			"%s - mano: %d, presenza: %s"
			% [
				_name(str(entity_id)),
				session.service.hand_size(str(entity_id)),
				# **Col nome del luogo, non col suo id** (ISSUES 63): il verbale sta
				# sullo schermo accanto alle domande, e una riga che dice
				# «presenza: REG_MINIERE_ANTICHE» e' un id sotto gli occhi di chi
				# gioca come lo sarebbe su un bottone.
				", ".join(PackedStringArray(_place_names(
					session.service.regions_with_presence(str(entity_id))
				))),
			]
		)
	for tension_id in world["tensions"]:
		log.bullet(session.tensions.public_status(str(tension_id)))


func play_act(act: int, decider: Object, from_round: int = 1) -> void:
	log.section("ATTO %d" % act)
	# Solo all'apertura vera dell'atto: una ripresa a meta' atto (`from_round` > 1)
	# ha gia' avuto il suo giro di stagione, e rifarlo cambierebbe la partita.
	if from_round == 1:
		_lift_evictions(act)
		_recharge_house_power(act)
		_refill_hands(act)
	for round_number in range(from_round, int(_chronicle["rounds_per_act"]) + 1):
		await play_round(act, round_number, decider)
	await end_of_act(act, decider)


## **Si pesca dal proprio mazzetto** (D-499, ISSUES 136).
##
## Il mazzetto e' il **pozzo** di ogni casa — parola del committente: *«i
## mazzetti rimangono separati e fanno da pozzo quando si pescano nuove
## carte»* — e a inizio Atto se ne pescano `draw_per_act`, uguali per tutti.
##
## **Quando il pozzo finisce si rimescola lo scarto**, che e' quello che rende
## il mazzetto un mazzo e non una scorta: le carte giocate tornano, e quelle
## acquisite durante l'anno le trovi gli Atti dopo. Se non c'e' piu' niente
## nemmeno nello scarto, si pesca quello che c'e' e si va avanti: una casa senza
## carte e' il difetto che questa regola viene a togliere, non uno da rifare
## qui in silenzio.
##
## Il tetto della mano resta quello della Chronicle: pescare oltre il tetto
## vorrebbe dire scartare subito, e al tavolo nessuno pesca per buttare.
func _draw_from_personal_deck(act: int) -> void:
	var rules: Dictionary = _chronicle.get("personal_decks", {}) as Dictionary
	var wanted: int = int(rules.get("draw_per_act", 0))
	if wanted <= 0:
		return
	var hand_cap: int = int(_chronicle.get("hand_limit", 0))
	for entity_id in session.service.active_entities():
		var id: String = str(entity_id)
		var deck: Dictionary = (world.get("personal_decks", {}) as Dictionary).get(id, {}) as Dictionary
		if deck.is_empty():
			continue
		var room: int = wanted
		if hand_cap > 0:
			room = mini(wanted, maxi(0, hand_cap - (session.service.hand(id) as Array).size()))
		var drawn: int = 0
		for _i in range(room):
			var payload: Dictionary = _top_of_deck(deck, id)
			if payload.is_empty():
				break
			payload["source"] = "PERSONAL_DECK"
			var effect: Dictionary = Effect.make(
				"GRANT_ASSET", "entity", id, payload, {"kind": "act_start", "act": act}
			)
			if not (session.applier.apply(effect) as Dictionary).is_empty():
				drawn += 1
		if drawn > 0:
			log.bullet("%s pesca %d carte dal suo mazzetto." % [
				str(data.entities.get(id, {}).get("name", id)), drawn,
			])


## Quale carta e' in cima al pozzo, **senza toglierla**: la toglie l'Effect, che
## e' l'unico che puo' mutare il mondo (effect-sourcing). Toglierla qui la faceva
## sparire prima che l'applier la trovasse, e la pesca falliva alla prima carta.
##
## Il rimescolo lo calcola questa funzione, col seme, e lo **porta nel payload**:
## e' la stessa strada di `_draw_one` nel resolver, e per la stessa ragione —
## l'applier verifica, non sceglie.
func _top_of_deck(deck: Dictionary, entity_id: String) -> Dictionary:
	var draw: Array = deck.get("draw", []) as Array
	var payload: Dictionary = {}
	if draw.is_empty():
		var discard: Array = deck.get("discard", []) as Array
		if discard.is_empty():
			return {}
		var reshuffled: Array = session.rng.shuffle(discard)
		payload["reshuffle"] = reshuffled
		draw = reshuffled
		log.bullet("Il mazzetto di %s viene rimescolato dagli scarti." % str(
			data.entities.get(entity_id, {}).get("name", entity_id)
		))
	if draw.is_empty():
		return {}
	payload["asset_id"] = str(draw[0])
	return payload


## La stagione gira e le porte si riaprono: i tag `evicted:` messi dai Consigli
## dell'atto precedente (D-067) si tolgono qui, con un Effect come ogni altra
## mutazione. All'Atto 1 non c'e' niente da togliere e il giro e' un no-op.
func _lift_evictions(act: int) -> void:
	for entity_id in world["turn_order"]:
		var tags: Array = (world["entities"][str(entity_id)]["tags"] as Array).duplicate()
		for tag in tags:
			if not str(tag).begins_with("evicted:"):
				continue
			var source: Dictionary = Effect.source(
				"system", "SEASON_TURNS", "", act, 1, int(world["effect_sequence"])
			)
			session.applier.apply(Effect.make(
				"REMOVE_ENTITY_TAG", "entity", str(entity_id), {"tag": str(tag)}, source
			))
			log.bullet("La stagione gira: %s puo tornare dov'era stato cacciato." % _name(str(entity_id)))


## **Il tarocco si rimette diritto** (D-503, ISSUES 136 punto 4). Il potere
## della casa non si accumula: quello non speso nell'Atto che chiude non si
## porta appresso, e quello speso torna. Un Effect per volta, come ogni altra
## mutazione, cosi' il verbale dice chi l'ha ripreso e disfare l'Atto lo
## rimette speso.
##
## All'Atto 1 il giro e' un **no-op**: il tarocco lo posa diritto il setup, che
## e' come la carta arriva sul tavolo. E dove la Chronicle non dichiara il
## potere non esce nessun Effect.
func _recharge_house_power(act: int) -> void:
	var per_act: int = HousePowerRules.per_act(_chronicle)
	if per_act <= 0:
		return
	for entity_id in world["turn_order"]:
		var id: String = str(entity_id)
		var left: int = int((world["entities"][id] as Dictionary).get("house_power", 0))
		for _i in range(per_act - left):
			var source: Dictionary = Effect.source(
				"system", "ACT_OPENS", "", act, 1, int(world["effect_sequence"])
			)
			session.applier.apply(Effect.make(
				"GRANT_HOUSE_POWER", "entity", id, {}, source
			))
		if per_act - left > 0:
			log.bullet("%s rimette diritto il tarocco: il potere della casa torna." % _name(id))


## **La mano torna a essere quella che la Chronicle dichiara** (D-504).
##
## Due mezzi giri in uno, e servono tutti e due: si **pesca** quello che manca
## dal proprio pozzo, e si **scarta** quello che sta sopra — perche' ACQUISIRE
## mette una carta in mano dentro il turno, e senza il pareggio quella carta
## regalerebbe una mano piu' grande per sempre. Il tetto della Chronicle
## (`hand_limit`) resta quello che vale **dentro** il turno; questo e' il
## livello a cui il turno **comincia**.
##
## Dove il ritmo per turno non e' dichiarato, il giro e' un no-op e vale quello
## per Atto.
func _level_the_hands(act: int, round_number: int, decider: Object) -> void:
	var target: int = HandRhythm.hand_target(_chronicle)
	if target <= 0:
		return
	for entity_id in session.service.active_entities():
		var id: String = str(entity_id)
		var deck: Dictionary = (
			world.get("personal_decks", {}) as Dictionary
		).get(id, {}) as Dictionary
		var drawn: int = 0
		while session.service.hand_size(id) < target and not deck.is_empty():
			var payload: Dictionary = _top_of_deck(deck, id)
			if payload.is_empty():
				# **Pozzo e scarto vuoti tutti e due**: si gioca con quello che
				# c'e'. Una casa senza carte e' il difetto che questa regola
				# viene a togliere, non uno da rifare qui in silenzio.
				break
			payload["source"] = "PERSONAL_DECK"
			var effect: Dictionary = Effect.make(
				"GRANT_ASSET", "entity", id, payload,
				{"kind": "round_start", "act": act, "round": round_number}
			)
			if (session.applier.apply(effect) as Dictionary).is_empty():
				break
			drawn += 1
		var over: int = session.service.hand_size(id) - target
		var dropped: int = 0
		while over > 0:
			var extra: Array = await _ask_discards(decider, id, 1)
			if extra.is_empty():
				extra = [str((session.service.ranked_by_strength(
					session.service.hand(id)
				) as Array).back())]
			for asset_id in extra:
				_own_discard(id, str(asset_id), act, round_number)
				dropped += 1
				over -= 1
		if drawn > 0 or dropped > 0:
			log.bullet("%s pareggia la mano a %d: pesca %d, scarta %d." % [
				_name(id), target, drawn, dropped,
			])


## **La carta coperta, e il resto che si tiene o si butta** (D-504).
##
## L'ordine e' quello del tavolo: prima si copre — e la coperta esce dalla mano,
## quindi non la si puo' piu' scartare per sbaglio — e poi si decide cosa fare
## di quello che resta. Chi scarta non perde niente: la mano torna a cinque al
## turno dopo, quindi **scartare e' pescare**, e tenere e' una scommessa su una
## carta precisa.
func _cover_and_churn(act: int, round_number: int, decider: Object) -> void:
	if HandRhythm.cover_per_round(_chronicle) <= 0:
		return
	for entity_id in session.service.active_entities():
		var id: String = str(entity_id)
		# **Quante ne copre questa casa lo dice la mappa** (D-505): il numero
		# della Chronicle e' il pavimento, il resto se l'e' guadagnato. E il
		# tetto vero e' quello che le resta in mano — coprire tutto e' legale,
		# e vuol dire non tenere niente per il turno dopo.
		var earned: int = HandRhythm.cover_for(_chronicle, session.service, id)
		var wanted: int = mini(earned, session.service.hand_size(id))
		var chosen: Array = []
		if wanted > 0:
			chosen = await _ask_cover(decider, id, wanted)
			if chosen.is_empty():
				# **Senza una scelta si copre la piu' forte**: chi copre non sa
				# di cosa si parlera', e la forza nuda e' l'unica cosa che una
				# carta vale in ogni Consiglio.
				chosen = (session.service.ranked_by_strength(
					session.service.hand(id)
				) as Array).slice(0, wanted)
		var covered: int = 0
		for asset_id in chosen:
			var applied: Dictionary = session.applier.apply(Effect.make(
				"COVER_ASSET", "entity", id, {"asset_id": str(asset_id)},
				Effect.source(
					"system", "ROUND_ENDS", id, act, round_number,
					int(world["effect_sequence"])
				)
			))
			if not applied.is_empty():
				covered += 1
		if covered > 0:
			# **Quale carta non si dice**, nemmeno nel verbale: e' coperta, ed
			# e' il punto della regola. **Quante** invece si', col perche': il
			# numero lo ha guadagnato sulla mappa, e un numero senza ragione e'
			# un numero che nessuno controlla.
			log.bullet("%s mette da parte %s (%s)." % [
				_name(id),
				"1 carta coperta" if covered == 1 else "%d carte coperte" % covered,
				" · ".join(PackedStringArray(
					HandRhythm.cover_reasons(_chronicle, session.service, id)
				)),
			])
		var churn: Array = await _ask_discards(decider, id, session.service.hand_size(id))
		for asset_id in churn:
			_own_discard(id, str(asset_id), act, round_number)
		if not churn.is_empty():
			log.bullet("%s scarta %s: al turno prossimo ne pesca altrettante." % [
				_name(id),
				"1 carta" if churn.size() == 1 else "%d carte" % churn.size(),
			])


## Quali carte coprire, chieste a chi siede. Un decisore che non sa rispondere
## lascia scegliere al motore: e' la stessa strada di `choose_raise`.
func _ask_cover(decider: Object, entity_id: String, how_many: int) -> Array:
	if how_many <= 0 or not decider.has_method("choose_cover"):
		return []
	var asked: Array = await decider.choose_cover(entity_id, how_many, session) as Array
	# **Quello che torna si filtra**, come per gli scarti: un decisore che
	# rispondesse con piu' carte del dovuto, o con una che non ha in mano, ne
	# coprirebbe di piu' o farebbe fallire l'Effetto in silenzio. Il motore non
	# si fida di una risposta: la controlla.
	var out: Array = []
	var hand: Array = session.service.hand(entity_id)
	for asset_id in asked:
		if out.size() >= how_many:
			break
		if hand.has(str(asset_id)) and not out.has(str(asset_id)):
			out.append(str(asset_id))
	return out


## E quali buttare. Chi non risponde non butta niente: tenere e' il ripiego
## innocuo, scartare no.
func _ask_discards(decider: Object, entity_id: String, most: int) -> Array:
	if most <= 0 or not decider.has_method("choose_discards"):
		return []
	var asked: Array = await decider.choose_discards(entity_id, most, session) as Array
	var out: Array = []
	var hand: Array = session.service.hand(entity_id)
	for asset_id in asked:
		if out.size() >= most:
			break
		if hand.has(str(asset_id)) and not out.has(str(asset_id)):
			out.append(str(asset_id))
	return out


## La carta buttata torna nel **proprio** scarto, e da li' nel proprio mazzetto
## al rimescolo (D-499): e' quello che rende «scartare» un investimento invece
## di una perdita.
func _own_discard(entity_id: String, asset_id: String, act: int, round_number: int) -> void:
	session.applier.apply(Effect.make(
		"REMOVE_ASSET", "entity", entity_id,
		{"asset_id": asset_id, "destination": "OWN_DISCARD"},
		Effect.source(
			"system", "ROUND_ENDS", entity_id, act, round_number,
			int(world["effect_sequence"])
		)
	))


func play_round(act: int, round_number: int, decider: Object) -> void:
	_set_phase(act, round_number, "ACTIONS")
	# The INFLUENCE allowance is per round and does not carry over (D-021).
	world["influence_used"] = {}
	world["influence_used_by_tension"] = {}
	log.section("Atto %d - Round %d" % [act, round_number])

	# **La mano si pareggia prima di giocare** (D-504): a inizio turno e'
	# esattamente quella che la Chronicle dichiara, e sopra o sotto si aggiusta.
	await _level_the_hands(act, round_number, decider)

	var opportunities: int = int(_chronicle["action_opportunities_per_round"])
	for entity_id in session.service.active_entities():
		world["entities"][entity_id]["ao_remaining"] = opportunities
		for ao_index in range(opportunities):
			var request: Variant = await decider.choose_action(str(entity_id), ao_index, session)
			if request == null:
				request = {"template": "PASS", "params": {}}
			var outcome: Dictionary = session.actions.execute(str(entity_id), request)
			if not outcome["ok"]:
				illegal_actions += 1
				log.bullet(
					"AZIONE RIFIUTATA - %s %s: %s"
					% [_name(str(entity_id)), str(request.get("template", "?")), str(outcome["error"])]
				)
			# AO are spent whether or not the attempt succeeded; they do not
			# carry over between rounds (§7).
			world["entities"][entity_id]["ao_remaining"] = opportunities - ao_index - 1

	# **E a fine turno si copre** (D-504), prima che qualunque Consiglio si
	# apra: la carta che si mette da parte e' la sola che il Consiglio potra'
	# impegnare, e va scelta **senza sapere** di cosa si parlera'. Sta qui e non
	# dopo la Deriva per quello: la Deriva puo' far esplodere una domanda, e
	# coprire dopo vorrebbe dire coprire sapendo.
	await _cover_and_churn(act, round_number, decider)

	_set_phase(act, round_number, "DRIFT")
	session.tensions.apply_drift()
	# Il conto delle forze prima della sovraestensione: chi tiene cosa si decide
	# adesso, e la fatica si paga su quello che si tiene davvero (D-158).
	_recount_control(act, round_number)
	_apply_overextension(act, round_number)

	_set_phase(act, round_number, "THRESHOLD_CHECK")
	await _end_of_round_confluence(decider)

	for tension_id in world["tensions"]:
		log.bullet(session.tensions.public_status(str(tension_id)))


## La contesa del controllo (D-158). Fino a 0.1.124 il padrone di una Regione
## era **scritto**: una Conseguenza metteva un nome, e quel nome restava finche'
## un'altra Conseguenza non lo cambiava. Da qui, se la Chronicle dichiara
## `control_rules.contested`, il padrone e' **contato**: chi somma di piu' fra
## pietre e pedine, ogni fine round.
##
## Il committente l'ha chiesto cosi': «se una entita' ha un castello (che magari
## vale 3) ma un'altra ha un esercito che occupa la regione (che vale 4) la
## regione viene controllata da chi ha di piu'».
##
## Tre cose che questo cambia, e che vanno dette perche' si vedono al tavolo:
##
## - **una Regione si perde senza che nessuno la prenda**: basta andarsene;
## - **il Consiglio non consegna piu' un possesso definitivo**. Una Conseguenza
##   che scrive un nome vale finche' quel nome regge il conto — il Consiglio
##   da' un titolo, tenerlo e' un'altra cosa;
## - **`lapse_without_presence` diventa un caso particolare**: chi non ha
##   niente li' somma zero, e zero non tiene niente.
##
## Il passaggio resta un `SET_CONTROL` come tutti gli altri: stesso Effect,
## stesso inverso, stessa riga nel registro. Cambia chi lo decide, non come si
## scrive.
func _recount_control(act: int, round_number: int) -> void:
	if not session.service.contest_is_on():
		return
	for region_id in world["regions"]:
		var region: Dictionary = world["regions"][str(region_id)]
		var before: Variant = region.get("control", null)
		var after: Variant = session.service.rightful_holder(str(region_id))
		if str(before if before != null else "") == str(after if after != null else ""):
			continue
		var source: Dictionary = Effect.source(
			"system", "CONTEST", "", act, round_number, int(world["effect_sequence"])
		)
		session.applier.apply(Effect.make(
			"SET_CONTROL", "region", str(region_id), {"entity_id": after}, source
		))
		if after == null:
			log.bullet(
				"%s non risponde piu' a nessuno: %s non ha piu' la forza per tenerla."
				% [_region_name(str(region_id)), _name(str(before))]
			)
		else:
			log.bullet(
				"%s risponde a %s (%d contro %d)."
				% [
					_region_name(str(region_id)),
					_name(str(after)),
					session.service.control_strength(str(after), str(region_id)),
					_runner_up(str(region_id), str(after)),
				]
			)


## La forza del secondo, per poter dire «tre contro due» invece di «tre».
func _runner_up(region_id: String, winner: String) -> int:
	var best: int = 0
	for entity_id in world["turn_order"]:
		if str(entity_id) == winner:
			continue
		best = maxi(best, session.service.control_strength(str(entity_id), region_id))
	return best


func _region_name(region_id: String) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


## D-027: holding is not free. Every Region an Entity controls beyond
## `max_stable_control` raises the Tension of that Region's own domain, once per
## round - the empire generates its own crises rather than being punished for
## existing. Nothing here targets a player: it targets the situation, and it
## reads at the table as "you hold the road as well? then the road question is
## yours to answer".
##
## Deterministic: Regions are taken in the Chronicle's own order, so the same
## board always strains in the same place.
func _apply_overextension(act: int, round_number: int) -> void:
	var rules: Dictionary = _chronicle.get("control_rules", {})
	if not rules.has("max_stable_control"):
		return
	var limit: int = int(rules["max_stable_control"])
	var delta: int = int(rules.get("overextension_delta", 1))
	if delta <= 0:
		return

	for entity_id in world["turn_order"]:
		var held: Array = []
		for region_id in world["regions"]:
			var control: Variant = world["regions"][str(region_id)].get("control", null)
			if control != null and str(control) == str(entity_id):
				held.append(str(region_id))
		if held.size() <= limit:
			continue

		for index in range(limit, held.size()):
			var tension_id: String = _tension_for_region(held[index])
			if tension_id == "":
				continue
			var source: Dictionary = Effect.source(
				"system", "OVEREXTENSION", str(entity_id), act, round_number,
				int(world["effect_sequence"])
			)
			session.applier.apply(
				Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": delta}, source)
			)
			log.bullet(
				"%s tiene piu di quanto puo reggere: %s sale di %d."
				% [_name(str(entity_id)), str(data.tensions[tension_id]["title"]), delta]
			)


## The Tension whose domain this Region belongs to. A Region may sit in more than
## one domain; the Chronicle's Tension order decides, so the result is stable.
func _tension_for_region(region_id: String) -> String:
	for tension_id in world["tensions"]:
		var domain: String = str(data.tensions[str(tension_id)]["domain"])
		if session.service.region_has_tag(region_id, "domain:%s" % domain):
			return str(tension_id)
	return ""


## §7 and §12.1: a forced Claim takes precedence over threshold triggers, and
## only one Confluence opens per round. Anything else at threshold queues up.
func _end_of_round_confluence(decider: Object) -> void:
	# Una Tensione a soglia con le domande esaurite non ha niente di nuovo da
	# decidere: si salta, invece di aprire un Consiglio che ridirebbe una cosa
	# gia' detta (D-077).
	var ready: Array = session.tensions.tensions_at_threshold().filter(
		func(id: Variant) -> bool: return session.confluence.has_fresh_question(str(id))
	)
	var forced: Variant = world.get("forced_confluence", null)
	var tension_id: String = ""
	var trigger: Dictionary = {}

	# Col Consiglio a fine Atto (D-214) il round non ne apre piu' nessuno da
	# solo: restano i forzati da RIVENDICARE, che sono il modo di portare al
	# tavolo una **seconda** domanda. Il numero di Consigli smette di essere
	# un'incognita del sistema — sono almeno quanti sono gli Atti — e i gettoni
	# smettono di dire *se* si parla per dire soltanto *di cosa*.
	if _council_at_end_of_act():
		# **Il diritto rivendicato si spende a fine Atto** (D-261): il round
		# non apre piu' nemmeno i forzati. Chi ha consumato un RIVENDICARE
		# tiene il suo secondo dibattito per quando i mazzetti si girano, e
		# la questione sara' il secondo mazzetto piu' alto — non quella che
		# ha nominato, che resta solo come ripiego.
		world["confluence_queue"] = []
		return

	if forced != null:
		tension_id = str(forced["tension_id"])
		trigger = {"kind": "CLAIM", "entity_id": str(forced["entity_id"])}
	elif not ready.is_empty():
		tension_id = str(ready[0])
		trigger = {"kind": "THRESHOLD", "entity_id": ""}
	else:
		tension_id = _bring_the_year_to_a_head()
		if tension_id != "":
			trigger = {"kind": "THRESHOLD", "entity_id": ""}

	world["confluence_queue"] = ready.filter(
		func(id: Variant) -> bool: return str(id) != tension_id
	)
	if tension_id == "":
		return
	if not world["confluence_queue"].is_empty():
		log.bullet(
			"In coda per i round successivi: %s"
			% ", ".join(PackedStringArray(world["confluence_queue"]))
		)
	_set_phase(int(world["act"]), int(world["round"]), "CONFLUENCE")
	await run_confluence(tension_id, trigger, decider)


## The floor under a Chronicle: the year does not close with nothing decided
## (D-047).
##
## A ten-Chronicle saga produced three years with **zero** Councils. The cause is
## arithmetic, not luck: the world's Drift deals one chip per round across every
## question in play - nine chips over four questions - while the smallest gap
## between a question's opening value and its threshold is three. The world can
## therefore be one chip short of *all four at once*, and in the silent years it
## was, every time. Every Council in the game needs a seat to push, and a table
## with nothing left to play for pushes nothing.
##
## That is a hole in the rules, not a quiet year: a Chronicle with no Council is
## a Chronicle in which nobody played. So when the last round arrives and the
## year is still short of the Councils the Chronicle guarantees, the question
## that came closest is brought to a head. The push is an Effect like any other,
## so the log says who did it - the world - and it inverts like everything else.
##
## The floor is checked at the close of each Act, against a quota that grows with
## the Act - `floor * act / acts`, rounded down. Only one Council opens per round
## (§7), so a floor of two checked once at the very end could only ever deliver
## one: the year has to be owed its Councils on a schedule, or the guarantee is
## not one. With three Acts and a floor of two that is nothing owed after Act I,
## one after Act II, two after Act III - which leaves the first two thirds of a
## Chronicle exactly as they were.
##
## `minimum_confluences: 0` turns the floor off; a Chronicle that wants to be
## able to end in silence is allowed to say so.
func _bring_the_year_to_a_head() -> String:
	var floor_count: int = int(_chronicle.get("minimum_confluences", 0))
	if floor_count <= 0:
		return ""
	if int(world["round"]) < int(_chronicle["rounds_per_act"]):
		return ""
	var owed: int = floor_count * int(world["act"]) / int(_chronicle["acts"])
	if int(world["confluence_count"]) >= owed:
		return ""

	# **Col cancello del tavolo il pavimento riempie il sacchetto, non spinge una
	# domanda** (D-203). Sotto il cancello un Consiglio si apre a **gettoni**: la
	# soglia della singola Tensione non apre piu' niente, quindi portarne una al
	# proprio numero non produce nessun Consiglio — e se la domanda piu' vicina
	# era gia' sopra la sua soglia (cosa normale, coi gettoni che alzano i
	# valori) il pavimento usciva zitto senza fare niente.
	#
	# Era un difetto latente da D-203, e l'ha scoperto la fase 3: i mucchi
	# coperti alzano un po' i valori, piu' domande si trovano sopra soglia, e il
	# pavimento smetteva di scattare abbastanza spesso da far scendere un anno a
	# un Consiglio solo. L'ha trovato `test_year_end_floor`.
	var gate: int = session.tensions.table_gate()
	if gate > 0:
		var hottest: String = session.tensions.hottest_pile()
		if hottest == "" or not session.confluence.has_fresh_question(hottest):
			return ""
		var missing: int = gate - int(world.get("tokens_in_bag", 0))
		if missing > 0:
			# Le parentesi non sono decorazione: in GDScript `%` lega piu'
			# stretto di `+`, quindi senza formatterebbe solo l'ultimo pezzo
			# (D-195, e la pagina d'aiuto che errava a ogni apertura).
			log.bullet(
				("L'anno non si chiude con la domanda ancora aperta: %s trova "
				+ "i gettoni che le mancano.") % str(data.tensions[hottest]["title"])
			)
			var gate_source: Dictionary = Effect.source(
				"system", "YEAR_END", "", int(world["act"]), int(world["round"]), 0
			)
			# **I gettoni cadono davvero.** Alzare `tokens_in_bag` e basta
			# aprirebbe un Consiglio che il registro non sa spiegare, ed e'
			# l'unico posto del motore in cui il verbale smetterebbe di
			# raccontare il tavolo. Cadono come Effetti, uno per volta,
			# reversibili come tutto il resto.
			for _i in range(missing):
				session.applier.apply(Effect.make(
					"ADJUST_TENSION", "tension", hottest, {"delta": 1}, gate_source
				))
				world["tokens_in_bag"] = int(world.get("tokens_in_bag", 0)) + 1
			session.tensions.fire_omens(gate_source)
		return hottest

	# The question that came closest, ties broken by the Chronicle's own order -
	# the same rule `tensions_at_threshold` uses, so a forced Council and a
	# threshold one never disagree about which question was the loudest.
	var closest: String = ""
	var smallest_gap: int = 0
	for tension_id in world["tensions"]:
		var id: String = str(tension_id)
		# Il pavimento non forza una domanda gia' decisa: una Tensione con le
		# domande esaurite non e' una domanda aperta (D-077).
		if not session.confluence.has_fresh_question(id):
			continue
		var gap: int = session.tensions.threshold(id) - session.tensions.value(id)
		if closest == "" or gap < smallest_gap:
			closest = id
			smallest_gap = gap
	if closest == "" or smallest_gap <= 0:
		return ""

	log.bullet(
		"L'anno non si chiude con la domanda ancora aperta: %s arriva al punto."
		% str(data.tensions[closest]["title"])
	)
	var source: Dictionary = Effect.source(
		"system", "YEAR_END", "", int(world["act"]), int(world["round"]), 0
	)
	session.applier.apply(
		Effect.make("ADJUST_TENSION", "tension", closest, {"delta": smallest_gap}, source)
	)
	session.tensions.fire_omens(source)
	return closest


## Drive one Confluence through A-K with the decider answering B, D, E.
func run_confluence(tension_id: String, trigger: Dictionary, decider: Object) -> Dictionary:
	# §6.3: a snapshot before every Confluence is what makes undo possible past
	# the irreversible CREATE_ECHO / APPEND_TRUTH that may follow.
	session.take_snapshot("pre-confluence")

	var controller: RefCounted = session.confluence
	var context: Dictionary = controller.open(tension_id, trigger)
	if context.is_empty():
		log.bullet("Confluence non aperta: %s" % controller.last_error)
		return {}

	var questions: Array = controller.available_questions()
	if questions.size() > 1:
		var question_id: String = str(await decider.choose_question(context, questions, session))
		if question_id != "" and question_id != str(context["question_id"]):
			if not controller.set_question(question_id):
				log.bullet("Domanda non valida (%s): si mantiene quella di default." % controller.last_error)
				illegal_actions += 1

	# **Il giro a due domande** (D-467 §3). A ha scelto la sua domanda e posa
	# una pedina su un beneficio libero, gratis. Poi ogni seggio, nell'ordine
	# di sempre, **prende posizione** — con A o con l'altra domanda — e posa
	# una pedina su una casella libera della sua parte, beneficio o costo: al
	# primo giro si posa, non si passa, se c'e' dove. Poi si rilancia a giro,
	# e chi non ha piu' niente da posare passa; quando tutti passano, il
	# prezzo si conta per parte e si vota. Un cervello che non sa scegliere
	# (has_method) prende la prima casella e passa al secondo giro: nessun
	# tavolo si ferma perche' un decisore e' vecchio. E' l'unico giro del
	# Consiglio da D-472: quello di D-280 e' uscito dal codice.
	var proponent: String = str(context["proponent"])
	var first: Array = []
	for entry in controller.box_menu("A"):
		if str((entry as Dictionary)["list"]) == "benefits":
			first.append(entry)
	if first.is_empty():
		log.bullet("D. %s non ha un beneficio libero da posare: propone a mani vuote." % _name(proponent))
	else:
		var picked: String = await _pick_box(decider, proponent, context, first, "A")
		if not controller.place_box(proponent, picked):
			log.bullet("Pedina rifiutata (%s): si posa la prima." % controller.last_error)
			illegal_actions += 1
			controller.place_box(proponent, str((first[0] as Dictionary)["id"]))

	for entity_id in controller.stance_order():
		var seat: String = str(entity_id)
		var offer: Dictionary = {"A": controller.box_menu("A"), "B": controller.box_menu("B")}
		if (offer["A"] as Array).is_empty() and (offer["B"] as Array).is_empty():
			controller.pass_turn(seat)
			continue
		var choice: Dictionary = await _pick_side(decider, seat, context, offer)
		var side: String = str(choice.get("side", ""))
		if not offer.has(side) or (offer[side] as Array).is_empty():
			side = "A" if not (offer["A"] as Array).is_empty() else "B"
		if not controller.join_side(seat, side):
			log.bullet("Posizione rifiutata (%s): %s si astiene." % [controller.last_error, _name(seat)])
			illegal_actions += 1
			controller.pass_turn(seat)
			continue
		var voice_id: String = str(choice.get("voice_id", ""))
		if not controller.place_box(seat, voice_id):
			if voice_id != "":
				log.bullet("Pedina rifiutata (%s): si posa la prima." % controller.last_error)
				illegal_actions += 1
			controller.place_box(seat, str(((offer[side] as Array)[0] as Dictionary)["id"]))

	var order: Array = [proponent]
	order.append_array(controller.stance_order())
	var rounds: int = 0
	while rounds < 12:
		rounds += 1
		var moved: bool = false
		for entity_id in order:
			var seat: String = str(entity_id)
			var side: String = controller.side_of(seat)
			if side == "" or controller.has_passed(seat):
				continue
			var menu: Array = controller.box_menu(side)
			if menu.is_empty():
				controller.pass_turn(seat)
				continue
			var raise: String = await _pick_raise(decider, seat, context, menu)
			if raise == "":
				controller.pass_turn(seat)
			elif controller.place_box(seat, raise):
				moved = true
			else:
				log.bullet("Rilancio rifiutato (%s): %s passa." % [controller.last_error, _name(seat)])
				illegal_actions += 1
				controller.pass_turn(seat)
		if not moved:
			break
	controller.settle_prices()
	return await _close_the_council(controller, context, decider)


func _pick_box(decider: Object, entity_id: String, context: Dictionary, menu: Array, side: String) -> String:
	if decider.has_method("choose_box"):
		var picked: String = str(await decider.choose_box(entity_id, context, menu, side, session))
		if picked != "":
			return picked
	return "" if menu.is_empty() else str((menu[0] as Dictionary)["id"])


func _pick_side(decider: Object, entity_id: String, context: Dictionary, offer: Dictionary) -> Dictionary:
	if decider.has_method("choose_side"):
		var choice: Dictionary = await decider.choose_side(entity_id, context, offer, session)
		if choice.has("side"):
			return choice
	var side: String = "A" if not (offer["A"] as Array).is_empty() else "B"
	return {"side": side, "voice_id": str(((offer[side] as Array)[0] as Dictionary)["id"])}


func _pick_raise(decider: Object, entity_id: String, context: Dictionary, menu: Array) -> String:
	if decider.has_method("choose_raise"):
		return str(await decider.choose_raise(entity_id, context, menu, session))
	return ""


## Gli impegni, il recupero, la risoluzione e i punti del dibattito.
func _close_the_council(controller: RefCounted, context: Dictionary, decider: Object) -> Dictionary:
	for entity_id in world["turn_order"]:
		var limit: int = controller.max_commit_for(str(entity_id))
		if limit <= 0:
			continue
		var committed: Array = await decider.choose_commit(str(entity_id), context, limit, session)
		if not controller.commit(str(entity_id), committed):
			log.bullet("Impegno rifiutato (%s): %s impegna 0 Asset." % [controller.last_error, _name(str(entity_id))])
			illegal_actions += 1
			controller.commit(str(entity_id), [])

	var recovery: Dictionary = await decider.choose_recovery(context, session)
	# Chi ha detto cosa e con quante carte, letto **prima** di `resolve()`, che
	# svuota `current` (D-455): i punti del dibattito si contano su questo.
	var debate_proponent: String = str(controller.current["proponent"])
	var debate_stances: Dictionary = (controller.current["stances"] as Dictionary).duplicate(true)
	var debate_commits: Dictionary = (controller.current["commits"] as Dictionary).duplicate(true)
	var result: Dictionary = controller.resolve(recovery)
	if not result.is_empty():
		result["debate_points"] = _score_the_debate(
			result, debate_proponent, debate_stances, debate_commits
		)
		confluence_results.append(result)
		confluence_resolved.emit(result)
	return result


## **L'astensione ha un prezzo** (D-455, parola del committente: *«chi non
## gioca carte, oltre a fare un favore a chi le gioca, potrebbe perdere punti
## vittoria se perde un dibattito, oppure potrebbero guadagnarle chi li
## vince»*). Due numeri nella Chronicle, `confluence_rules.debate_points`:
## `winners_gain`, quanti punti di campagna prende chi sta sul fronte che ha
## vinto **con almeno una carta impegnata**; `silent_lose`, quanti ne perde chi
## non propone e non impegna niente. Zero e zero, e il Consiglio e' quello di
## prima. Il punteggio di campagna e' un'eccezione dichiarata all'effect-
## sourcing, come a fine anno: qui si scrive e si dice, non si registra.
func _score_the_debate(
	result: Dictionary, proponent: String, stances: Dictionary, commits: Dictionary
) -> Dictionary:
	var rules: Dictionary = (
		(_chronicle.get("confluence_rules", {}) as Dictionary).get("debate_points", {}) as Dictionary
	)
	var winners_gain: int = int(rules.get("winners_gain", 0))
	var silent_lose: int = int(rules.get("silent_lose", 0))
	var deltas: Dictionary = {}
	if winners_gain <= 0 and silent_lose <= 0:
		return deltas
	var won: bool = ConfluenceResolution.is_success(str(result["outcome"]))
	# A due domande vince una parte, e la parte e' un fronte (D-467): A e'
	# «sostiene», B e' «si oppone»; se non passa nessuna non vince nessuno.
	var winning_front: String = "SUPPORT" if won else "OPPOSE"
	if result.has("winner"):
		var side_won: String = str(result["winner"])
		winning_front = "SUPPORT" if side_won == "A" else ("OPPOSE" if side_won == "B" else "")
	for entity_id in world["turn_order"]:
		var seat: String = str(entity_id)
		var cards: int = (commits.get(seat, []) as Array).size()
		var side: String = (
			"SUPPORT" if seat == proponent
			else str((stances.get(seat, {}) as Dictionary).get("stance", "ABSTAIN"))
		)
		var delta: int = 0
		if winners_gain > 0 and cards > 0 and winning_front != "" and side == winning_front:
			delta += winners_gain
		if silent_lose > 0 and seat != proponent and cards == 0:
			delta -= silent_lose
		if delta == 0:
			continue
		var who: Dictionary = world["entities"][seat] as Dictionary
		who["saga_score"] = int(who.get("saga_score", 0)) + delta
		deltas[seat] = delta
		log.bullet("Punti del dibattito: %s %+d — %s." % [
			_name(seat), delta,
			"ha vinto con le carte in mano" if delta > 0 else "non ha giocato carte",
		])
	return deltas


## Il sipario di un Atto: si chiude col suo Consiglio (D-214).
##
## La fase si chiama ancora `ACT_ECHO` e la parola regge: quello che chiude un
## Atto e' **l'Eco che il Consiglio lascia** — il ricordo, non la carta. Le
## carte Eco se ne sono andate in [D-500], e con loro il contatore di quante
## ne fossero state calate nell'Atto.
func end_of_act(act: int, decider: Object) -> void:
	_set_phase(act, int(_chronicle["rounds_per_act"]), "ACT_ECHO")
	await _council_closing_the_act(act, decider)


## Il Consiglio di fine Atto (D-214).
##
## *«Il consiglio si puo' aprire alla fine di ogni atto in automatico e la
## domanda con piu' valore sara' quella dibattuta, cosi' e' sicuro che almeno
## tre consigli ci saranno sempre.»*
##
## Quale domanda: **il mucchio piu' alto**, che e' esattamente cio' che i
## gettoni coperti costruiscono per tutto l'Atto ([D-210](DECISIONS.md#d-210)) —
## si girano, si contano, e vince chi ha scaldato di piu'. Se quel mucchio ha
## gia' detto tutto quello che sapeva dire, si scende al successivo invece di
## riaprire una domanda gia' chiusa (D-077).
func _council_closing_the_act(act: int, decider: Object) -> void:
	if not _council_at_end_of_act():
		return
	# **I mazzetti si girano** (D-261, parola del committente): a fine Atto i
	# gettoni coperti scoprono il loro valore, il mazzetto piu' alto porta al
	# Consiglio la sua carta girata, e chi ha guadagnato un secondo dibattito
	# con RIVENDICARE apre il secondo mazzetto. Il mucchio piu' alto delle
	# questioni resta come ripiego dichiarato per l'Atto in cui nessuna
	# Risonanza ha scaldato niente: un tavolo freddo non e' un tavolo senza
	# domande.
	_reveal_the_piles(act)
	# Il diritto rivendicato si legge **prima** del primo Consiglio: risolvere
	# una Confluence azzera `forced_confluence` (e' la sua consumazione, da
	# prima di questa decisione), quindi leggerlo dopo lo trovava sempre vuoto
	# — cento anni a tre Consigli esatti, e il playtest l'ha detto subito.
	var forced: Variant = world.get("forced_confluence", null)
	world["forced_confluence"] = null
	var first_theme: String = ""
	var tension_id: String = _front_of_hottest_theme("")
	if tension_id != "":
		first_theme = str(data.tensions[tension_id].get("theme", ""))
	else:
		tension_id = _hottest_with_something_to_say()
	if tension_id == "":
		log.bullet(
			"L'Atto %d si chiude senza Consiglio: nessuna domanda ha ancora qualcosa di nuovo da decidere."
			% act
		)
	else:
		log.section("IL CONSIGLIO DI FINE ATTO %d" % act)
		_set_phase(act, int(_chronicle["rounds_per_act"]), "CONFLUENCE")
		# La controproposta del RIVENDICARE dentro il primo Consiglio (D-268) e'
		# uscita con D-472: a due domande la controproposta **e'** la parte B,
		# e il diritto rivendicato apre il secondo dibattito, come in D-261.
		await run_confluence(tension_id, {"kind": "THRESHOLD", "entity_id": ""}, decider)
	await _second_council_of_the_act(act, first_theme, forced, decider)
	_spend_the_piles(act)


## Il secondo dibattito (D-261): chi ha consumato un RIVENDICARE durante
## l'Atto non sceglie piu' lui la questione — apre **il secondo mazzetto piu'
## alto**, restando proponente. Se i mazzetti non offrono niente, si ripiega
## sulla questione che aveva nominato, se ha ancora qualcosa da chiedere: il
## diritto guadagnato non evapora in silenzio (ISSUES 53).
func _second_council_of_the_act(act: int, first_theme: String, forced: Variant, decider: Object) -> void:
	if forced == null:
		return
	var claimant: String = str((forced as Dictionary).get("entity_id", ""))
	var tension_id: String = _front_of_hottest_theme(first_theme)
	if tension_id == "":
		var named: String = str((forced as Dictionary).get("tension_id", ""))
		if named != "" and session.confluence.can_open(named):
			tension_id = named
	if tension_id == "":
		log.bullet("Il secondo dibattito rivendicato da %s non trova una questione aperta: il diritto si spegne, e resta scritto." % _name(claimant))
		return
	log.section("IL SECONDO CONSIGLIO DELL'ATTO %d" % act)
	_set_phase(act, int(_chronicle["rounds_per_act"]), "CONFLUENCE")
	await run_confluence(tension_id, {"kind": "CLAIM", "entity_id": claimant}, decider)


func _council_at_end_of_act() -> bool:
	return bool(
		(_chronicle.get("confluence_rules", {}) as Dictionary).get("at_end_of_act", false)
	)


## La rivelazione (D-261): i gettoni coperti si girano, e per la prima volta
## l'Atto dice quanto valeva ogni mazzetto. E' il momento del tavolo — si
## racconta anche quando non cambia niente, perche' girare due gettoni bianchi
## e' una storia («tanto fumo, niente fuoco»).
func _reveal_the_piles(_act: int) -> void:
	var track: Dictionary = world.get("theme_heat", {}) as Dictionary
	var counts: Dictionary = world.get("theme_tokens", {}) as Dictionary
	var said: PackedStringArray = PackedStringArray()
	for theme_id in data.themes:
		var fallen: int = int(counts.get(str(theme_id), 0))
		if fallen <= 0:
			continue
		said.append("%s vale %d (%d gettoni)" % [
			str(data.themes[str(theme_id)]["title"]),
			int(track.get(str(theme_id), 0)), fallen,
		])
	if said.is_empty():
		return
	log.bullet("I mazzetti si girano: %s." % "; ".join(said))


## La carta girata del mazzetto piu' alto (D-261). Si scorrono i Temi dal
## valore rivelato piu' alto in giu' — a parita' l'ordine del dato, che e'
## l'ordine stampato — saltando `exclude` (il Tema gia' dibattuto dal primo
## Consiglio). Per ogni Tema caldo si prende **la sua carta girata**; se non
## s'e' ancora girata (valore alto con pochi gettoni), la gira la rivelazione
## stessa; se la girata ha gia' detto tutto, si gira la prossima. Un Tema il
## cui mazzetto si esaurisce lascia il posto al successivo. I Temi a zero non
## scelgono niente: sotto il freddo decide il mucchio, e la regola vecchia
## resta scritta come ripiego.
func _front_of_hottest_theme(exclude: String) -> String:
	var track: Dictionary = world.get("theme_heat", {}) as Dictionary
	var order: Array = data.themes.keys()
	var ranked: Array = order.duplicate()
	ranked.sort_custom(func(a: String, b: String) -> bool:
		var heat_a: int = int(track.get(a, 0))
		var heat_b: int = int(track.get(b, 0))
		if heat_a == heat_b:
			return order.find(a) < order.find(b)
		return heat_a > heat_b
	)
	for theme_id in ranked:
		if str(theme_id) == exclude:
			continue
		if int(track.get(str(theme_id), 0)) <= 0:
			break
		var tension_id: String = _front_that_can_open(str(theme_id))
		if tension_id != "":
			return tension_id
	return ""


## Il fronte del Tema che si aprirebbe adesso: la carta girata se ha ancora
## qualcosa da chiedere, altrimenti si gira la prossima finche' il mazzetto ne
## ha. `can_open` e non `has_fresh_question`, per la stessa ragione scritta in
## `_hottest_with_something_to_say`.
func _front_that_can_open(theme_id: String) -> String:
	var front: String = session.tensions.theme_front(theme_id)
	if front != "" and session.confluence.can_open(front):
		return front
	while true:
		front = session.tensions.flip_theme_front(theme_id)
		if front == "":
			return ""
		if session.confluence.can_open(front):
			return front
	return ""


## I mazzetti si spendono (D-261): dopo i Consigli dell'Atto ogni Tema torna
## freddo — valori a zero per Effect, gettoni via dal tavolo — e l'Atto nuovo
## ricomincia a contare. Le carte girate **restano girate**: una questione
## scoperta non si copre piu'. Quanto del Calore non speso dovrebbe invece
## sopravvivere all'Atto e' taratura d'autore (ROADMAP §4.1).
func _spend_the_piles(act: int) -> void:
	var track: Dictionary = world.get("theme_heat", {}) as Dictionary
	var counts: Dictionary = world.get("theme_tokens", {}) as Dictionary
	var source: Dictionary = Effect.source(
		"system", "ACT_END", "", act, int(world["round"]), 0
	)
	var kept: Dictionary = world.get("theme_heat_kept", {}) as Dictionary
	for theme_id in data.themes:
		var heat: int = int(track.get(str(theme_id), 0))
		if heat > 0:
			session.applier.apply(Effect.make(
				"ADJUST_THEME_HEAT", "theme", str(theme_id), {"delta": -heat}, source
			))
		# **Quello che il Consiglio ha scaldato resta** (D-486): la pedina
		# posata sulla casella «il Tema di questa domanda si scalda» e' un
		# costo, e un costo cancellato due minuti dopo non e' un costo. Il
		# Calore segnato da quella casella torna sul tavolo appena i mucchi
		# sono spenti, e il registro si azzera: vale per l'Atto dopo, una
		# volta sola.
		var saved: int = int(kept.get(str(theme_id), 0))
		if saved > 0:
			session.applier.apply(Effect.make(
				"ADJUST_THEME_HEAT", "theme", str(theme_id), {"delta": saved}, source
			))
			session.applier.apply(Effect.make(
				"KEEP_THEME_HEAT", "theme", str(theme_id), {"delta": -saved}, source
			))
			# Il nome del Tema, mai il suo id: un verbale che dice THM_POTERE
			# e' un verbale che nessuno legge al tavolo (D-463).
			var theme: Variant = data.themes.get(str(theme_id))
			log.bullet("  Il Consiglio ha lasciato %d di Calore su %s: l'Atto nuovo comincia caldo." % [
				saved,
				str(theme_id) if theme == null else str((theme as Dictionary).get("title", theme_id)),
			])
		counts[str(theme_id)] = 0


## Il mucchio piu' alto fra quelli che hanno ancora una domanda fresca. In
## ordine di altezza, a parita' l'ordine in cui le domande sono state pescate -
## la stessa regola di `tensions_at_threshold`, cosi' un Consiglio forzato e uno
## di fine Atto scelgono allo stesso modo.
func _hottest_with_something_to_say() -> String:
	var order: Array = (world["tensions"] as Dictionary).keys()
	var ranked: Array = order.duplicate()
	ranked.sort_custom(func(a: String, b: String) -> bool:
		var value_a: int = session.tensions.value(a)
		var value_b: int = session.tensions.value(b)
		if value_a == value_b:
			return order.find(a) < order.find(b)
		return value_a > value_b
	)
	for tension_id in ranked:
		# `can_open` e non `has_fresh_question`: la seconda dice se resta un
		# quesito mai posto, la prima se ce n'e' uno che **si aprirebbe adesso**.
		# Scegliere sulla seconda faceva rifiutare l'apertura e perdere il
		# Consiglio dell'Atto, invece di scendere al mucchio successivo.
		if session.confluence.can_open(str(tension_id)):
			return str(tension_id)
	return ""


## Il rubinetto della mano (ISSUES 47, D-185): a inizio Atto la mappa da' le
## carte.
##
## «La presenza nelle regioni deve essere fondamentale nella pesca delle carte,
## tipo due presenze due carte.» Quante ne pesca un seggio lo dicono le sue
## pedine; **di che famiglia** lo dice la Regione dove stanno, perche' ogni
## Regione dichiara le proprie `asset_sources`. La mappa smette di essere un
## punteggio e diventa il rubinetto.
##
## I tre freni sono nella Chronicle e non nel codice, perche' sono taratura:
## il **pavimento** (`floor`) tiene in gioco chi resta senza pedine; il **tetto
## per Atto** (`cap`) limita quante se ne pescano in un colpo; il **tetto sulla
## mano** (`hand_cap`) e' il vero freno alla divergenza che D-183 ha misurato —
## piu' presenza da' piu' carte, piu' carte danno piu' presenza. D-185 ha
## misurato che il solo `cap` **non frena**: le carte non spese restano in mano
## e lo scarto cresce lo stesso.
##
## Vive solo se la Chronicle dichiara `hand_refill`. Senza, non succede niente.
func _refill_hands(act: int) -> void:
	# **Il mazzetto personale, quando la Chronicle ce l'ha** (D-499, ISSUES 136).
	#
	# Il rubinetto qui sotto pesca **in base alla mappa**: due carte per pedina,
	# una per Regione tenuta, fra un pavimento di 2 e un tetto di 6. Misurato,
	# da' circa **quattro** carte per Atto contro un fabbisogno di **3,92** — si
	# sta esattamente al limite, senza margine, ed e' per questo che una
	# Occasione su cinque non ha altro che «passa».
	#
	# Il mazzetto lo sostituisce con un numero **fisso e uguale per tutti**,
	# come il committente ha chiesto: cambia **cosa** peschi, non quanto.
	if HandRhythm.hand_target(_chronicle) > 0:
		# **Il ritmo e' del turno, non dell'Atto** (D-504): la mano si pareggia
		# all'inizio di ogni turno, quindi qui non c'e' niente da pescare.
		return
	if not (_chronicle.get("personal_decks", {}) as Dictionary).is_empty():
		_draw_from_personal_deck(act)
		return
	var rules: Dictionary = _chronicle.get("hand_refill", {}) as Dictionary
	if rules.is_empty():
		return
	var per_token: int = int(rules.get("per_token", 1))
	var floor_cards: int = int(rules.get("floor", 1))
	var cap: int = int(rules.get("cap", 3))
	var hand_cap: int = int(rules.get("hand_cap", 0))
	var per_control: int = int(rules.get("per_control", 0))
	for entity_id in session.service.active_entities():
		var presence: Array = (
			(world["entities"] as Dictionary)[str(entity_id)] as Dictionary
		).get("presence", []) as Array
		# Le famiglie che la mappa gli offre, una per gettone: la stessa Regione
		# due volte offre due volte le sue.
		var offered: Array = []
		for region_id in presence:
			for family in (data.regions[str(region_id)] as Dictionary).get(
				"asset_sources", []
			):
				offered.append(str(family))
		# Quello che **tiene**, non solo dove sta (D-220). Il rubinetto contava
		# le pedine e basta, quindi il possesso di una Regione non pagava piu'
		# che starci dentro: la maggioranza era un numero nella contesa e niente
		# altro, e alzare una pietra non cambiava una carta in mano a nessuno.
		var held_regions: int = session.service.control_count(str(entity_id)) if per_control > 0 else 0
		var wanted: int = clampi(
			presence.size() * per_token + held_regions * per_control, floor_cards, cap
		)
		# Il tetto sulla **mano**, non sulla pesca: D-185 ha misurato che un
		# tetto per Atto non frena niente, perche' le carte non spese restano
		# in mano e lo scarto si accumula lo stesso. Chi ha ancora carte pesca
		# meno; chi le ha spese pesca pieno.
		#
		# E il tetto **sale con quello che si tiene**: senza, il possesso non si
		# vedrebbe comunque — chiunque converge alla stessa mano piena, e la
		# presenza decide soltanto quanto in fretta. Misurato: col tetto fisso,
		# chi aveva cinque pedine pescava **meno** di chi ne aveva tre.
		if hand_cap > 0:
			var held: int = (
				(world["entities"] as Dictionary)[str(entity_id)] as Dictionary
			)["hand"].size()
			wanted = mini(wanted, hand_cap + held_regions * per_control - held)
		if wanted <= 0:
			continue
		var source: Dictionary = Effect.source(
			"system", "HAND_REFILL", str(entity_id), act, 1, int(world["effect_sequence"])
		)
		var drawn: Array = []
		for _i in range(wanted):
			# Senza pedine la mappa non offre niente e il pavimento pesca dove
			# il mazzo e' piu' pieno: chi e' a terra non sceglie, ma pesca.
			var family: String = (
				str(offered[drawn.size() % offered.size()]) if not offered.is_empty()
				else _fullest_deck()
			)
			var card: String = session.actions.draw_for_refill(
				str(entity_id), family, source
			)
			if card == "":
				continue
			drawn.append(card)
		if not drawn.is_empty():
			log.bullet("%s pesca %d carte da dove tiene le pedine." % [
				_name(str(entity_id)), drawn.size()
			])


## Il mazzo con piu' carte, per il pavimento di chi non ha piu' mappa.
func _fullest_deck() -> String:
	var best: String = ""
	var most: int = -1
	var families: Array = (world["decks"] as Dictionary).keys()
	families.sort()
	for family in families:
		var pile: int = ((world["decks"][str(family)] as Dictionary)["draw"] as Array).size()
		if pile > most:
			most = pile
			best = str(family)
	return best


func chronicle_end() -> Dictionary:
	_set_phase(int(_chronicle["acts"]), int(_chronicle["rounds_per_act"]), "CHRONICLE_END")
	log.section("FINE DELLA CHRONICLE")
	for tension_id in world["tensions"]:
		log.bullet(
			"%s: valore finale %d" % [
				str(data.tensions[tension_id]["title"]),
				session.tensions.value(str(tension_id)),
			]
		)
	log.bullet("Confluence risolte: %d" % int(world["confluence_count"]))
	log.bullet("Echo registrati: %d" % (world["echo_log"] as Array).size())
	log.bullet("Truth immutabili: %d" % (world["truth_log"] as Array).size())

	log.section("DESTINY")
	var results: Dictionary = session.destinies.evaluate_all()
	# Il consuntivo degli obiettivi si congela **qui**, insieme ai livelli
	# (D-217). `objectives_of` ricalcola dal mondo corrente, e subito sotto
	# `_settle_structures` alza una pietra a chi ha ottenuto quello che voleva:
	# chi chiedesse gli obiettivi dopo `run()` leggerebbe un tavolo di un
	# istante piu' tardi di quello che ha deciso l'anno. Il libro mastro lo
	# faceva, e diceva che «Pietra sopra Pietra» si avvera nel 27% dei casi
	# quando in partita non si avvera mai.
	var objectives_taken: Dictionary = {}
	for entity_id in world["turn_order"]:
		objectives_taken[str(entity_id)] = session.destinies.objectives_of(str(entity_id))
	for entity_id in world["turn_order"]:
		if results.has(entity_id):
			log.bullet(session.destinies.describe(results[entity_id]))

	if not (world["truth_log"] as Array).is_empty():
		log.section("REGISTRO DELLE VERITÀ")
		for truth in world["truth_log"]:
			log.bullet(str(truth["text"]))

	# La scala che si muove col Destino (D-159): chi ha trionfato alza una
	# pietra, chi non e' arrivato al Minimo ne perde una. Dopo la valutazione,
	# perche' e' l'esito a decidere.
	_settle_structures(results)
	_score_the_saga(results, log)

	session.destiny_results = results
	return {
		"chronicle_id": str(_chronicle["id"]),
		"confluences": confluence_results,
		"destiny_results": results,
		"illegal_actions": illegal_actions,
		"echoes": (world["echo_log"] as Array).size(),
		"truths": (world["truth_log"] as Array).size(),
		"objectives": objectives_taken,
	}


## Il vincitore della saga (D-180), su richiesta del committente.
##
## «Per vincere la saga ci vuole un contatore di vittorie nelle singole partite.
## Dare un valore ai livelli di vittoria che si sommano alla fine della saga
## decretando il vincitore.»
##
## La Chronicle resta senza punteggio — nessuna classifica dentro l'anno, come
## e' sempre stato — ed e' la **campagna** ad averne uno: ogni anno chiuso somma
## al seggio il valore del suo livello, e il totale attraversa le ere insieme
## alla mappa.
##
## Vive solo se la Chronicle dichiara `saga_scoring`. Senza, non succede niente
## e nemmeno una riga finisce a verbale.
func _score_the_saga(results: Dictionary, log: RefCounted) -> void:
	var rules: Dictionary = _chronicle.get("saga_scoring", {}) as Dictionary
	if rules.is_empty():
		return
	var value_of: Dictionary = {
		"NONE": int(rules.get("none", -1)),
		"MINIMUM": int(rules.get("minimum", 1)),
		"VICTORY": int(rules.get("victory", 3)),
		"TRIUMPH": int(rules.get("triumph", 6)),
	}
	var standing: Array = []
	for entity_id in world["turn_order"]:
		if not results.has(entity_id):
			continue
		var level: String = str((results[entity_id] as Dictionary).get("level", "NONE"))
		if level == "":
			level = "NONE"
		var gained: int = int(value_of.get(level, 0))
		# Con gli obiettivi, due successi parziali che il livello confonde
		# possono valere numeri diversi (D-198): se la Chronicle scrive
		# `objectives.saga_points`, il conto vince sulla scala dei livelli.
		var points: Array = (
			(_chronicle.get("objectives", {}) as Dictionary).get("saga_points", []) as Array
		)
		if not points.is_empty() and (results[entity_id] as Dictionary).has("objectives_met"):
			var met: int = int((results[entity_id] as Dictionary)["objectives_met"])
			gained = int(points[mini(met, points.size() - 1)])
		var seat: Dictionary = world["entities"][str(entity_id)] as Dictionary
		seat["saga_score"] = int(seat.get("saga_score", 0)) + gained
		standing.append([int(seat["saga_score"]), gained, str(entity_id), str(seat["name"])])
	if standing.is_empty():
		return
	standing.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
	log.section("LA SAGA")
	for row in standing:
		var gained: int = int((row as Array)[1])
		log.bullet("%s: %d punti (%s%d quest'anno)" % [
			str((row as Array)[3]), int((row as Array)[0]),
			"+" if gained >= 0 else "", gained,
		])
	# Quando una campagna puo' dire di avere un vincitore (D-181). Il committente
	# l'ha fissata a dieci Chronicle: prima di allora il conto si tiene ma nessuno
	# ha vinto, perche' una manciata di anni non e' una campagna. La soglia apre
	# la porta e non la chiude - da li' in poi il tavolo smette quando vuole.
	var played: int = int(world.get("chronicles_played", 1))
	var needed: int = int(rules.get("decides_after", 10))
	if played < needed:
		log.bullet("La campagna non e' ancora decisa: %d %s su %d." % [
			played, "anno giocato" if played == 1 else "anni giocati", needed,
		])
		return
	# **L'Eredita'** (D-385): a saga decisa, e non prima, i gradini si sommano
	# alle leggende che portano il nome di ciascuna casa.
	var final_standing: Array = []
	var said_legacy: bool = false
	for row in standing:
		var seat_id: String = str((row as Array)[2])
		var bonus: int = legacy_points(world, data, seat_id)
		if bonus > 0:
			if not said_legacy:
				log.bullet("L'Eredita' (%d per leggenda):" % LEGACY_PER_LEGEND)
				said_legacy = true
			log.bullet("  %s: +%d — %s" % [
				str((row as Array)[3]), bonus,
				", ".join(PackedStringArray(legends_named_after(world, data, seat_id))),
			])
		final_standing.append([
			int((row as Array)[0]) + bonus, bonus, seat_id, str((row as Array)[3]),
		])
	final_standing.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
	var leaders: Array = []
	for row in final_standing:
		if int((row as Array)[0]) == int((final_standing[0] as Array)[0]):
			leaders.append(str((row as Array)[3]))
	if leaders.size() > 1:
		log.bullet("Dopo %d anni la campagna e' in parita' fra %s: si va avanti." % [
			played, " e ".join(PackedStringArray(leaders)),
		])
	else:
		log.bullet("Dopo %d anni la campagna la vince %s, con %d punti." % [
			played, str((final_standing[0] as Array)[3]),
			int((final_standing[0] as Array)[0]),
		])


## **L'Eredita'** (D-385 — ISSUES 84, la seconda delle tre strade di D-299,
## scelta dal committente): *«a fine saga, +3 per ogni leggenda che porta il tuo
## nome»*.
##
## Una leggenda porta il nome di una casa quando racconta uno dei segni che
## quella casa aveva dichiarato di voler lasciare — i `wants` del suo profilo
## strategico. Le leggende non le scrive nessun giocatore: le fabbrica **il
## tempo**, al salto d'era, trasformando in `legend:<fatto>` i fatti che
## sbiadiscono (D-075). E' la frase del committente — *«il mondo parla ancora la
## lingua che quell'Entita' voleva lasciare?»* — letta su un dato che esiste
## gia', senza inventarne uno.
##
## **Perche' e' un bonus e non un gradino**, e per questo si conta a parte
## invece di finire dentro `saga_score`: la soglia che decide la campagna apre
## la porta e non la chiude (D-181), quindi una saga puo' continuare oltre.
## Sommarlo al totale lo pagherebbe una seconda volta l'anno dopo, e una terza
## quello dopo ancora — cioe' premierebbe la durata, che e' esattamente quello
## che il committente ha scritto di non volere (D-299).
const LEGACY_PER_LEGEND: int = 3


## Quanto vale l'Eredita' di una casa, a fine saga.
static func legacy_points(world_state: Dictionary, data_set: RefCounted, entity_id: String) -> int:
	return legends_named_after(world_state, data_set, entity_id).size() * LEGACY_PER_LEGEND


## Le leggende che portano il nome di una casa, per nome. Solo i fatti globali:
## `legend:` lo scrive **solo** la sbiadita del salto d'era, e lo scrive li'.
static func legends_named_after(
	world_state: Dictionary, data_set: RefCounted, entity_id: String
) -> Array:
	var profile: Variant = (data_set.entity_profiles as Dictionary).get(entity_id)
	if profile == null:
		return []
	var facts: Array = world_state.get("global_tags", [])
	var found: Array = []
	for voice in ((profile as Dictionary).get("wants", []) as Array):
		var tag: String = str((voice as Dictionary).get("tag", ""))
		if tag != "" and facts.has("legend:%s" % tag) and not found.has(tag):
			found.append(tag)
	found.sort()
	return found


## Il grado che si muove con l'esito (D-159), §7.3 della seduta sulla terra.
##
## «Il cambio puo' dipendere da come vanno le cose: se la reggia appartiene
## all'entita' che ha perso va in rovina, se invece trionfa diventa una reggia.»
##
## A fine Chronicle, e solo se la Chronicle dichiara `structure_rules`:
##
## - chi ha raggiunto un livello fra quelli di `rise_on` **alza di un grado la
##   sua struttura piu' alta** — una casa che vince costruisce sopra quello che
##   ha gia', non altrove: e' cosi' che nasce una capitale;
## - chi si e' fermato a un livello di `fall_on` **perde un grado sulla piu'
##   bassa** — si perdono prima i margini, come gia' fa il controllo che decade
##   dove non c'e' nessuno. Sotto il primo grado la struttura non scende: **va
##   in rovina**, e la rovina lascia una cicatrice.
##
## Deterministico: le Regioni si guardano nell'ordine della Chronicle, quindi a
## parita' di grado vince sempre la stessa.
func _settle_structures(results: Dictionary) -> void:
	var rules: Dictionary = _chronicle.get("structure_rules", {})
	if rules.is_empty():
		return
	var rise_on: Array = rules.get("rise_on", [])
	var fall_on: Array = rules.get("fall_on", [])
	for entity_id in world["turn_order"]:
		var seat: String = str(entity_id)
		var result: Variant = results.get(seat)
		if result == null:
			continue
		var level: String = str((result as Dictionary)["level"])
		if rise_on.has(level):
			_raise_one(seat)
		elif fall_on.has(level):
			_lower_one(seat)


## La piu' alta che puo' ancora salire.
func _raise_one(seat: String) -> void:
	var found: Dictionary = _pick_structure(seat, true)
	if found.is_empty():
		return
	var definition: Dictionary = data.structure_types[str(found["structure_type"])]
	var grade: int = int(found["grade"]) + 1
	session.applier.apply(Effect.make(
		"SET_STRUCTURE_GRADE", "region", str(found["region_id"]),
		{"structure_type": str(found["structure_type"]), "grade": grade},
		Effect.source("system", "DESTINY_RISE", seat, 0, 0, int(world["effect_sequence"]))
	))
	log.bullet(
		"%s ha ottenuto quello che voleva, e %s adesso e' %s."
		% [
			_name(seat),
			_region_name(str(found["region_id"])),
			str(((definition["grades"] as Array)[grade - 1] as Dictionary)["name"]).to_lower(),
		]
	)


## La piu' bassa. Sotto il primo grado non si scende: si cade.
func _lower_one(seat: String) -> void:
	var found: Dictionary = _pick_structure(seat, false)
	if found.is_empty():
		return
	var type_id: String = str(found["structure_type"])
	var region_id: String = str(found["region_id"])
	var definition: Dictionary = data.structure_types[type_id]
	var source: Dictionary = Effect.source(
		"system", "DESTINY_FALL", seat, 0, 0, int(world["effect_sequence"])
	)
	if int(found["grade"]) > 1:
		session.applier.apply(Effect.make(
			"SET_STRUCTURE_GRADE", "region", region_id,
			{"structure_type": type_id, "grade": int(found["grade"]) - 1}, source
		))
		log.bullet(
			"%s non ha ottenuto niente, e %s in %s ha perso un piano."
			% [_name(seat), str(definition["name"]).to_lower(), _region_name(region_id)]
		)
		return

	session.applier.apply(Effect.make(
		"RAZE_STRUCTURE", "region", region_id, {"structure_type": type_id}, source
	))
	var ruin: Dictionary = definition.get("ruin", {})
	if not ruin.is_empty() and str(ruin.get("scar", "")) != "":
		session.applier.apply(Effect.make(
			"ADD_SCAR", "scar", "SCAR_RUIN_%s_%s" % [type_id, region_id],
			{
				"scar_id": "SCAR_RUIN_%s_%s" % [type_id, region_id],
				"region_id": region_id,
				"tag": str(ruin["scar"]),
				"description": str(ruin.get("description", "")),
			},
			source
		))
	log.bullet(
		"%s non ha ottenuto niente, e %s in %s e' andata in %s."
		% [
			_name(seat), str(definition["name"]).to_lower(), _region_name(region_id),
			str(ruin.get("name", "rovina")).to_lower(),
		]
	)


## La struttura di quel seggio da muovere: la piu' alta che puo' salire, o la
## piu' bassa che puo' scendere. Vuoto se non ne ha nessuna.
func _pick_structure(seat: String, rising: bool) -> Dictionary:
	var best: Dictionary = {}
	for region_id in world["regions"]:
		for structure in (world["regions"][str(region_id)] as Dictionary).get("structures", []):
			var record: Dictionary = structure as Dictionary
			if str(record.get("owner", "")) != seat:
				continue
			var definition: Variant = data.structure_types.get(str(record["structure_type"]))
			if definition == null or not bool(definition["owned"]):
				continue
			var grade: int = int(record["grade"])
			if rising and grade >= (definition["grades"] as Array).size():
				continue
			if best.is_empty() or (grade > int(best["grade"]) if rising else grade < int(best["grade"])):
				best = {
					"region_id": str(region_id),
					"structure_type": str(record["structure_type"]),
					"grade": grade,
				}
	return best


func _set_phase(act: int, round_number: int, phase: String) -> void:
	world["act"] = act
	world["round"] = round_number
	world["phase"] = phase
	phase_changed.emit(act, round_number, phase)


func _name(entity_id: String) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(session.service.name_of(entity_id))


## I nomi dei luoghi come si leggono al tavolo (ISSUES 63): una Regione che il
## verbale chiama col suo id e' un id sotto gli occhi di chi gioca.
func _place_names(region_ids: Array) -> Array:
	var out: Array = []
	for region_id in region_ids:
		var region: Variant = data.regions.get(str(region_id))
		out.append(str(region_id) if region == null else str((region as Dictionary)["name"]))
	return out
