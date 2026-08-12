extends RefCounted
## The six mechanical action templates (§10).
##
## One Action Opportunity buys exactly one of these. Every cost and every result
## is expressed as an Effect; the resolver never touches the world directly.
##
## Optional parameters are auto-resolved deterministically (best card, first
## legal region) so a scripted plan can stay terse, but *legality* is never
## assumed: an illegal request is refused with a reason.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")

const TEMPLATES: Array = ["ACQUIRE", "MOVE", "INFLUENCE", "FORGE", "SCHEME", "CLAIM"]

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var rng: RefCounted
var log: RefCounted
var service: RefCounted
var tensions: RefCounted

var _chronicle: Dictionary


func _init(
	p_world: Dictionary,
	p_data: RefCounted,
	p_applier: RefCounted,
	p_rng: RefCounted,
	p_log: RefCounted,
	p_tensions: RefCounted
) -> void:
	world = p_world
	data = p_data
	applier = p_applier
	rng = p_rng
	log = p_log
	tensions = p_tensions
	service = WorldStateService.new(p_world, p_data)
	_chronicle = data.chronicles[world["chronicle_id"]]


## Why this action would be refused, or "" if it is legal. Pure: touches nothing.
##
## execute() calls this first, so a precondition is written down exactly once.
## The 0.1 Action Dialog uses it to grey out illegal targets and the CLI policy
## uses it to avoid proposing an action it cannot take (§19.3).
func check(entity_id: String, template: String, params: Dictionary) -> String:
	if template == "PASS":
		return ""
	if not TEMPLATES.has(template):
		return "template sconosciuto '%s'" % template
	if not world["entities"].has(entity_id):
		return "entita sconosciuta '%s'" % entity_id
	match template:
		"ACQUIRE":
			return _check_acquire(entity_id, params)
		"MOVE":
			return _check_move(entity_id, params)
		"INFLUENCE":
			return _check_influence(entity_id, params)
		"FORGE":
			return _check_forge(entity_id, params)
		"SCHEME":
			return _check_scheme(entity_id, params)
		"CLAIM":
			return _check_claim(entity_id, params)
	return "template non implementato"


func can_execute(entity_id: String, template: String, params: Dictionary) -> bool:
	return check(entity_id, template, params) == ""


## Returns {ok, error, template, effects, info}.
func execute(entity_id: String, request: Dictionary) -> Dictionary:
	var template: String = str(request.get("template", ""))
	var params: Dictionary = request.get("params", {})

	var refusal: String = check(entity_id, template, params)
	if refusal != "":
		return _error(template, refusal)

	if template == "PASS":
		log.bullet("%s passa." % _name(entity_id))
		return _ok(template, [], {"passed": true})

	var source: Dictionary = Effect.source(
		"action",
		"ACT_%s" % template,
		entity_id,
		int(world["act"]),
		int(world["round"]),
		int(world["effect_sequence"])
	)
	match template:
		"ACQUIRE":
			return _acquire(entity_id, params, source)
		"MOVE":
			return _move(entity_id, params, source)
		"INFLUENCE":
			return _influence(entity_id, params, source)
		"FORGE":
			return _forge(entity_id, params, source)
		"SCHEME":
			return _scheme(entity_id, params, source)
		"CLAIM":
			return _claim(entity_id, params, source)
	return _error(template, "template non implementato")


# --- preconditions ---------------------------------------------------------

func _check_acquire(entity_id: String, params: Dictionary) -> String:
	var family: String = str(params.get("family", ""))
	if not world["decks"].has(family):
		return "famiglia sconosciuta '%s'" % family
	var deck: Dictionary = world["decks"][family]
	if (deck["draw"] as Array).is_empty() and (deck["discard"] as Array).is_empty():
		return "il mazzo %s e vuoto e non ha scarti" % family
	return ""


func _check_move(entity_id: String, params: Dictionary) -> String:
	var region_id: String = str(params.get("region_id", ""))
	if not world["regions"].has(region_id):
		return "regione sconosciuta '%s'" % region_id
	if not service.can_move_to(entity_id, region_id):
		return "'%s' non e adiacente alla presenza di %s" % [region_id, entity_id]
	if service.region_free_slots(region_id) <= 0:
		return "'%s' non ha spazi di posizionamento liberi" % region_id
	if service.tokens_placed(entity_id) >= int(_chronicle["presence_tokens"]):
		# All three tokens are down, so this has to be a relocation.
		var from_region: String = str(params.get("from_region_id", ""))
		if service.presence_count(entity_id, from_region) <= 0:
			from_region = _pick_source_region(entity_id, region_id)
		if from_region == "":
			return "nessun token disponibile da spostare"
	return ""


func _check_influence(entity_id: String, params: Dictionary) -> String:
	var tension_id: String = str(params.get("tension_id", ""))
	if not world["tensions"].has(tension_id):
		return "tensione sconosciuta '%s'" % tension_id
	var delta: int = int(params.get("delta", 1))
	if delta != 1 and delta != -1:
		return "delta deve essere +1 o -1"
	# §10: a veiled Tension is out of reach until this Entity has uncovered it.
	if tensions.is_veiled(tension_id) and not service.knows_tension(entity_id, tension_id):
		return "la Tensione '%s' e velata per %s" % [tension_id, entity_id]

	# §10 as tuned in DECISIONS D-021: how often one Entity may lean on the
	# Tensions in a single round.
	var rules: Dictionary = _chronicle.get("influence_rules", {})
	if rules.has("max_per_entity_per_round"):
		var cap: int = int(rules["max_per_entity_per_round"])
		if int(world.get("influence_used", {}).get(entity_id, 0)) >= cap:
			return "%s ha gia usato INFLUENCE %d volta/e in questo round" % [entity_id, cap]
	# A second bound, on the question rather than the person: the world only
	# moves so fast, whatever the table wants (D-023).
	if rules.has("max_per_tension_per_round"):
		var tension_cap: int = int(rules["max_per_tension_per_round"])
		if int(world.get("influence_used_by_tension", {}).get(tension_id, 0)) >= tension_cap:
			return "questa Tensione e gia stata mossa %d volte in questo round" % tension_cap

	var domain: String = service.tension_domain(tension_id)
	var by_presence: bool = service.has_presence_in_domain(entity_id, domain)
	# The free presence route may only cover some directions: inflaming a
	# question can be easier than calming one.
	var directions: Array = rules.get("presence_directions", ["UP", "DOWN"])
	if by_presence and not directions.has("UP" if delta > 0 else "DOWN"):
		by_presence = false

	if str(params.get("via", "")) == "PRESENCE":
		if not by_presence:
			return "la presenza nel dominio %s non copre questa direzione" % domain
		return ""
	if by_presence:
		return ""
	if _pick_relevant_asset(entity_id, tension_id, params) == "":
		return "serve presenza utile nel dominio %s o 1 Asset di famiglia rilevante" % domain
	return ""


## Which route INFLUENCE will actually take, given the rules in force.
func _influence_uses_presence(entity_id: String, tension_id: String, delta: int) -> bool:
	if not service.has_presence_in_domain(entity_id, service.tension_domain(tension_id)):
		return false
	var directions: Array = _chronicle.get("influence_rules", {}).get(
		"presence_directions", ["UP", "DOWN"]
	)
	return directions.has("UP" if delta > 0 else "DOWN")


func _check_forge(entity_id: String, params: Dictionary) -> String:
	var other: String = str(params.get("target_entity_id", ""))
	if not world["entities"].has(other) or other == entity_id:
		return "bersaglio non valido '%s'" % other
	var direction: String = str(params.get("direction", "UP"))
	var current: String = service.relation_level(entity_id, other)
	if direction == "UP":
		if not bool(params.get("consent", false)):
			return "salire di un passo richiede il consenso di %s" % other
		if WorldStateService.shift_relation(current, 1) == current:
			return "la relazione e gia al massimo"
		if _pick_bond(entity_id, params) == "":
			return "serve 1 Asset BONDS da scartare"
		return ""
	if direction != "DOWN":
		return "direzione non valida '%s'" % direction
	if WorldStateService.shift_relation(current, -1) == current:
		return "la relazione e gia al minimo"
	return ""


func _check_scheme(entity_id: String, params: Dictionary) -> String:
	match str(params.get("mode", "TENSION")):
		"TENSION":
			var tension_id: String = str(params.get("tension_id", ""))
			if not world["tensions"].has(tension_id):
				return "tensione sconosciuta '%s'" % tension_id
			if service.knows_tension(entity_id, tension_id):
				return "%s conosce gia questa Tensione" % entity_id
			return ""
		"ECHO_DECK":
			return ""
		"REGION":
			var region_id: String = str(params.get("region_id", ""))
			if not world["regions"].has(region_id):
				return "regione sconosciuta '%s'" % region_id
			if str(data.regions[region_id].get("private_information", "")) == "":
				return "'%s' non ha informazioni private" % region_id
			return ""
	return "modo sconosciuto '%s'" % params.get("mode", "")


func _check_claim(entity_id: String, params: Dictionary) -> String:
	var mode: String = str(params.get("mode", "CREATE"))
	if mode == "CREATE":
		var domain: String = str(params.get("domain", ""))
		if domain == "":
			return "dominio mancante"
		if not service.claim_for_domain(entity_id, domain).is_empty():
			return "%s ha gia un Claim su %s" % [entity_id, domain]
		if _pick_authority(entity_id, params) == "":
			return "serve 1 Asset AUTHORITY da scartare"
		return ""
	if mode != "FORCE":
		return "modo sconosciuto '%s'" % mode

	var tension_id: String = str(params.get("tension_id", ""))
	if not world["tensions"].has(tension_id):
		return "tensione sconosciuta '%s'" % tension_id
	var claim: Dictionary = service.claim_for_domain(entity_id, service.tension_domain(tension_id))
	if claim.is_empty():
		return "nessun Claim di %s sul dominio %s" % [entity_id, service.tension_domain(tension_id)]
	# §10: the Claim has to have been laid down in an earlier round.
	if int(claim["act"]) == int(world["act"]) and int(claim["round"]) == int(world["round"]):
		return "il Claim e stato creato in questo round"
	if tensions.value(tension_id) < 3:
		return "la Tensione deve valere almeno 3 per essere forzata"
	if world.get("forced_confluence", null) != null:
		return "una Confluence e gia stata forzata per questo round"
	if _pick_authority(entity_id, params) == "":
		return "serve 1 ulteriore Asset AUTHORITY da scartare"
	return ""


# --- ACQUIRE ---------------------------------------------------------------

func _acquire(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var family: String = str(params.get("family", ""))
	# A source Region for that family turns the draw into draw-2-keep-1 (§10).
	var doubled: bool = _has_source_for(entity_id, family)
	var drawn: Array = []
	var effects: Array = []
	var count: int = 2 if doubled else 1
	for _i in range(count):
		var card: String = _draw_one(family, entity_id, source, effects)
		if card == "":
			break
		drawn.append(card)
	if drawn.is_empty():
		return _error("ACQUIRE", "il mazzo %s e vuoto e non ha scarti" % family)

	if drawn.size() > 1:
		# Work by index, not by value: two copies of the same card are a normal
		# draw, and comparing ids would find no "other one" to put back.
		var keep_index: int = _best_index(drawn)
		var wanted: String = str(params.get("keep_asset_id", ""))
		if wanted != "" and drawn.has(wanted):
			keep_index = drawn.find(wanted)
		var discarded: Array = []
		for i in range(drawn.size()):
			if i == keep_index:
				continue
			effects.append_array(_discard(entity_id, str(drawn[i]), source))
			discarded.append(_title(str(drawn[i])))
		log.bullet(
			"%s acquisisce %s dalla famiglia %s (pesca doppia, scarta %s)."
			% [
				_name(entity_id),
				_title(str(drawn[keep_index])),
				family,
				", ".join(PackedStringArray(discarded)),
			]
		)
	else:
		log.bullet(
			"%s acquisisce %s dalla famiglia %s." % [_name(entity_id), _title(drawn[0]), family]
		)

	effects.append_array(_enforce_hand_limit(entity_id, params, source))
	return _ok("ACQUIRE", effects, {"drawn": drawn})


func _has_source_for(entity_id: String, family: String) -> bool:
	for region_id in service.regions_with_presence(entity_id):
		if (data.regions[region_id]["asset_sources"] as Array).has(family):
			return true
	return false


## Draw the top card of a family deck, reshuffling the discard pile in with the
## seeded RNG when the pile runs out (§9). The reshuffled order travels inside
## the Effect so the applier stays free of randomness.
func _draw_one(family: String, entity_id: String, source: Dictionary, effects: Array) -> String:
	var deck: Dictionary = world["decks"][family]
	var payload: Dictionary = {"source": "DECK"}
	var top: String = ""
	if (deck["draw"] as Array).is_empty():
		if (deck["discard"] as Array).is_empty():
			return ""
		var reshuffled: Array = rng.shuffle(deck["discard"])
		payload["reshuffle"] = reshuffled
		top = str(reshuffled[0])
		log.bullet("Il mazzo %s viene rimescolato dagli scarti." % family)
	else:
		top = str(deck["draw"][0])
	payload["asset_id"] = top
	var applied: Dictionary = applier.apply(
		Effect.make("GRANT_ASSET", "entity", entity_id, payload, source)
	)
	if applied.is_empty():
		return ""
	effects.append(applied)
	return top


## §9: hand limit 7; the eighth Asset forces a discard.
func _enforce_hand_limit(entity_id: String, params: Dictionary, source: Dictionary) -> Array:
	var limit: int = int(_chronicle["hand_limit"])
	var effects: Array = []
	while service.hand_size(entity_id) > limit:
		var choice: String = str(params.get("discard_asset_id", ""))
		if not service.hand(entity_id).has(choice):
			choice = _worst_of(service.hand(entity_id))
		effects.append_array(_discard(entity_id, choice, source))
		log.bullet("%s supera il limite di mano e scarta %s." % [_name(entity_id), _title(choice)])
	return effects


# --- MOVE ------------------------------------------------------------------

func _move(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var region_id: String = str(params.get("region_id", ""))
	var effects: Array = []
	var tokens: int = service.tokens_placed(entity_id)
	var moving_from: String = ""
	if tokens >= int(_chronicle["presence_tokens"]):
		moving_from = str(params.get("from_region_id", ""))
		if service.presence_count(entity_id, moving_from) <= 0:
			moving_from = _pick_source_region(entity_id, region_id)
		var removed: Dictionary = applier.apply(
			Effect.make(
				"REMOVE_PRESENCE", "entity", entity_id, {"region_id": moving_from}, source
			)
		)
		if removed.is_empty():
			return _error("MOVE", applier.last_error)
		effects.append(removed)

	var added: Dictionary = applier.apply(
		Effect.make("ADD_PRESENCE", "entity", entity_id, {"region_id": region_id}, source)
	)
	if added.is_empty():
		return _error("MOVE", applier.last_error)
	effects.append(added)
	if moving_from == "":
		log.bullet("%s pone un token presenza in %s." % [_name(entity_id), _region(region_id)])
	else:
		log.bullet(
			"%s sposta un token da %s a %s."
			% [_name(entity_id), _region(moving_from), _region(region_id)]
		)
	return _ok("MOVE", effects, {"region_id": region_id, "from": moving_from})


func _pick_source_region(entity_id: String, destination: String) -> String:
	for region_id in service.regions_with_presence(entity_id):
		if region_id != destination:
			return str(region_id)
	return ""


# --- INFLUENCE -------------------------------------------------------------

func _influence(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var tension_id: String = str(params.get("tension_id", ""))
	var delta: int = int(params.get("delta", 1))
	var domain: String = service.tension_domain(tension_id)
	var effects: Array = []
	var via: String = str(params.get("via", ""))
	if via == "" and _influence_uses_presence(entity_id, tension_id, delta):
		via = "PRESENCE"

	if via != "PRESENCE":
		effects.append_array(
			_discard(entity_id, _pick_relevant_asset(entity_id, tension_id, params), source)
		)
		via = "DISCARD"

	var applied: Dictionary = applier.apply(
		Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": delta}, source)
	)
	if applied.is_empty():
		return _error("INFLUENCE", applier.last_error)
	effects.append(applied)
	if not world.has("influence_used"):
		world["influence_used"] = {}
	if not world.has("influence_used_by_tension"):
		world["influence_used_by_tension"] = {}
	world["influence_used"][entity_id] = int(world["influence_used"].get(entity_id, 0)) + 1
	world["influence_used_by_tension"][tension_id] = (
		int(world["influence_used_by_tension"].get(tension_id, 0)) + 1
	)
	log.bullet(
		"%s influenza %s (%+d, via %s)."
		% [_name(entity_id), str(data.tensions[tension_id]["title"]), delta, via]
	)

	var displaced: String = ""
	if delta < 0:
		displaced = _displace_pressure(entity_id, tension_id, effects, source)

	tensions.fire_omens(source)
	return _ok(
		"INFLUENCE",
		effects,
		{"tension_id": tension_id, "delta": delta, "via": via, "displaced_to": displaced}
	)


## §11 / D-029: pressure is displaced, not removed.
##
## Pushing a question down raises one of the questions it is linked to. You do
## not make a crisis go away, you choose which one to have instead - and without
## this a table that only ever pushes down keeps the whole Chronicle silent,
## which is measured, not supposed (O-9).
##
## The weight lands on the linked Tension currently *lowest*, so suppression
## spreads pressure across the board rather than piling it in one place. Ties go
## to the Chronicle's own Tension order, so the same board always displaces the
## same way. The Effect keeps the acting Entity as its source: this is your doing.
func _displace_pressure(
	entity_id: String, tension_id: String, effects: Array, source: Dictionary
) -> String:
	var amount: int = int(
		(_chronicle.get("influence_rules", {}) as Dictionary).get("displacement_on_decrease", 0)
	)
	if amount <= 0:
		return ""

	var target: String = ""
	var lowest: int = -1
	for linked_id in data.tensions[tension_id].get("linked_tensions", []):
		var id: String = str(linked_id)
		# A linked Tension the Chronicle never drew has nowhere to take the
		# weight, so it is skipped rather than conjured into play (D-028).
		if not world["tensions"].has(id):
			continue
		var value: int = tensions.value(id)
		if lowest < 0 or value < lowest:
			target = id
			lowest = value
	if target == "":
		return ""

	# Its own source id, still carrying the acting Entity: this is your doing and
	# the log has to say so, but it is not a second INFLUENCE action and anything
	# counting actions from the log must be able to tell them apart.
	var displaced_source: Dictionary = Effect.source(
		"action",
		"ACT_INFLUENCE_DISPLACED",
		entity_id,
		int(source.get("act", 0)),
		int(source.get("round", 0)),
		int(world["effect_sequence"])
	)
	var applied: Dictionary = applier.apply(
		Effect.make("ADJUST_TENSION", "tension", target, {"delta": amount}, displaced_source)
	)
	if applied.is_empty():
		return ""
	effects.append(applied)
	log.bullet(
		"  ...ma il peso si sposta: %s sale di %d."
		% [str(data.tensions[target]["title"]), amount]
	)
	return target


# --- FORGE -----------------------------------------------------------------

func _forge(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var other: String = str(params.get("target_entity_id", ""))
	var direction: String = str(params.get("direction", "UP"))
	var current: String = service.relation_level(entity_id, other)
	var effects: Array = []

	if direction == "UP":
		# Going up needs the other player's agreement and a Bond spent (§10).
		var next_up: String = WorldStateService.shift_relation(current, 1)
		effects.append_array(_discard(entity_id, _pick_bond(entity_id, params), source))
		effects.append(
			applier.apply(
				Effect.make(
					"SET_RELATION",
					"relation",
					Ids.relation_key(entity_id, other),
					{"level": next_up},
					source
				)
			)
		)
		log.bullet(
			"%s e %s salgono a %s." % [_name(entity_id), _name(other), next_up]
		)
		return _ok("FORGE", effects, {"level": next_up})

	var next_down: String = WorldStateService.shift_relation(current, -1)
	effects.append(
		applier.apply(
			Effect.make(
				"SET_RELATION",
				"relation",
				Ids.relation_key(entity_id, other),
				{"level": next_down},
				source
			)
		)
	)
	# Breaking a relation is unilateral and free, but it happens in public.
	log.bullet(
		"%s rompe verso %s: la relazione scende a %s."
		% [_name(entity_id), _name(other), next_down]
	)
	return _ok("FORGE", effects, {"level": next_down})


# --- SCHEME ----------------------------------------------------------------

func _scheme(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var mode: String = str(params.get("mode", "TENSION"))
	var effects: Array = []
	match mode:
		"TENSION":
			var tension_id: String = str(params.get("tension_id", ""))
			effects.append(
				applier.apply(
					Effect.make(
						"SET_ENTITY_TAG",
						"entity",
						entity_id,
						{"tag": Ids.knows_tension_tag(tension_id)},
						source
					)
				)
			)
			# Uncovering something the world was hiding is itself a Discovery.
			if tensions.is_veiled(tension_id):
				effects.append(
					applier.apply(
						Effect.make(
							"SET_ENTITY_TAG",
							"entity",
							entity_id,
							{"tag": "discovery:%s" % tension_id},
							source
						)
					)
				)
			log.bullet("%s trama in silenzio: qualcosa di velato ora ha un numero." % _name(entity_id))
			return _ok(
				"SCHEME",
				effects,
				{"private": true, "tension_id": tension_id, "value": tensions.value(tension_id)}
			)
		"ECHO_DECK":
			var peek: Array = _peek_echo_deck(2)
			effects.append(
				applier.apply(
					Effect.make(
						"SET_ENTITY_TAG",
						"entity",
						entity_id,
						{"tag": "scouted_echo:A%d" % int(world["act"])},
						source
					)
				)
			)
			log.bullet("%s guarda le prime carte del mazzo Echo dell'Atto." % _name(entity_id))
			return _ok("SCHEME", effects, {"private": true, "echo_peek": peek})
		"REGION":
			var region_id: String = str(params.get("region_id", ""))
			var secret: String = str(data.regions[region_id].get("private_information", ""))
			effects.append(
				applier.apply(
					Effect.make(
						"SET_ENTITY_TAG",
						"entity",
						entity_id,
						{"tag": "knows_region:%s" % region_id},
						source
					)
				)
			)
			log.bullet("%s indaga su %s." % [_name(entity_id), _region(region_id)])
			return _ok("SCHEME", effects, {"private": true, "region_secret": secret})
	return _error("SCHEME", "modo sconosciuto '%s'" % mode)


func _peek_echo_deck(count: int) -> Array:
	var families: Array = _act_echo_families(int(world["act"]))
	var out: Array = []
	for card_id in world["echo_deck"]["draw"]:
		if out.size() >= count:
			break
		var card: Variant = data.echo_cards.get(str(card_id))
		if card != null and families.has(str(card["dramatic_family"])):
			out.append(str(card_id))
	return out


func _act_echo_families(act: int) -> Array:
	for pool in _chronicle["act_echo_pools"]:
		if int(pool["act"]) == act:
			return pool["families"]
	return []


# --- CLAIM -----------------------------------------------------------------

func _claim(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var mode: String = str(params.get("mode", "CREATE"))
	var effects: Array = []

	if mode == "CREATE":
		var domain: String = str(params.get("domain", ""))
		effects.append_array(_discard(entity_id, _pick_authority(entity_id, params), source))
		var claim_id: String = Ids.claim_id(int(world["effect_sequence"]) + 1)
		effects.append(
			applier.apply(
				Effect.make(
					"CREATE_CLAIM",
					"claim",
					claim_id,
					{
						"claim_id": claim_id,
						"entity_id": entity_id,
						"domain": domain,
						"act": int(world["act"]),
						"round": int(world["round"]),
					},
					source
				)
			)
		)
		log.bullet("%s rivendica il dominio %s." % [_name(entity_id), domain])
		return _ok("CLAIM", effects, {"claim_id": claim_id, "domain": domain})

	var tension_id: String = str(params.get("tension_id", ""))
	var claim: Dictionary = service.claim_for_domain(entity_id, service.tension_domain(tension_id))
	effects.append_array(_discard(entity_id, _pick_authority(entity_id, params), source))
	effects.append(
		applier.apply(
			Effect.make(
				"CONSUME_CLAIM",
				"claim",
				str(claim["claim_id"]),
				{"claim_id": str(claim["claim_id"])},
				source
			)
		)
	)
	world["forced_confluence"] = {"tension_id": tension_id, "entity_id": entity_id}
	log.bullet(
		"%s consuma il proprio Claim e forza una Confluence su %s."
		% [_name(entity_id), str(data.tensions[tension_id]["title"])]
	)
	return _ok("CLAIM", effects, {"forced": tension_id})


## Deterministic default choices, shared by check() and the handlers so a legal
## check and the execution that follows it always pick the same card.
func _pick_relevant_asset(entity_id: String, tension_id: String, params: Dictionary) -> String:
	var families: Array = service.relevant_families(tension_id)
	var card: String = str(params.get("discard_asset_id", ""))
	if service.hand(entity_id).has(card) and families.has(Ids.asset_family(card)):
		return card
	return service.first_asset_of_families(entity_id, families)


func _pick_bond(entity_id: String, params: Dictionary) -> String:
	var card: String = str(params.get("discard_asset_id", ""))
	if service.hand(entity_id).has(card) and Ids.asset_family(card) == "BONDS":
		return card
	return service.first_asset_of_family(entity_id, "BONDS")


func _pick_authority(entity_id: String, params: Dictionary) -> String:
	var card: String = str(params.get("discard_asset_id", ""))
	if service.hand(entity_id).has(card) and Ids.asset_family(card) == "AUTHORITY":
		return card
	return service.first_asset_of_family(entity_id, "AUTHORITY")


# --- helpers ---------------------------------------------------------------

func _discard(entity_id: String, asset_id: String, source: Dictionary) -> Array:
	var applied: Dictionary = applier.apply(
		Effect.make(
			"REMOVE_ASSET",
			"entity",
			entity_id,
			{"asset_id": asset_id, "destination": "DISCARD"},
			source
		)
	)
	return [] if applied.is_empty() else [applied]


func _best_index(asset_ids: Array) -> int:
	var best: int = 0
	for i in range(asset_ids.size()):
		if _strength(str(asset_ids[i])) > _strength(str(asset_ids[best])):
			best = i
	return best


func _worst_of(asset_ids: Array) -> String:
	var worst: String = str(asset_ids[0])
	for asset_id in asset_ids:
		if _strength(str(asset_id)) < _strength(worst):
			worst = str(asset_id)
	return worst


func _strength(asset_id: String) -> int:
	var asset: Variant = data.assets.get(asset_id)
	return 0 if asset == null else int(asset["strength"])


func _title(asset_id: String) -> String:
	var asset: Variant = data.assets.get(asset_id)
	return asset_id if asset == null else str(asset["title"])


func _name(entity_id: String) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(service.name_of(entity_id))


func _region(region_id: String) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


func _ok(template: String, effects: Array, info: Dictionary) -> Dictionary:
	return {"ok": true, "error": "", "template": template, "effects": effects, "info": info}


func _error(template: String, message: String) -> Dictionary:
	return {"ok": false, "error": message, "template": template, "effects": [], "info": {}}
