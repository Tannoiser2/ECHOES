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


## Returns {ok, error, template, effects, info}.
func execute(entity_id: String, request: Dictionary) -> Dictionary:
	var template: String = str(request.get("template", ""))
	if template == "PASS":
		log.bullet("%s passa." % _name(entity_id))
		return _ok(template, [], {"passed": true})
	if not TEMPLATES.has(template):
		return _error(template, "template sconosciuto '%s'" % template)

	var params: Dictionary = request.get("params", {})
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


# --- ACQUIRE ---------------------------------------------------------------

func _acquire(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var family: String = str(params.get("family", ""))
	if not world["decks"].has(family):
		return _error("ACQUIRE", "famiglia sconosciuta '%s'" % family)

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
	if not world["regions"].has(region_id):
		return _error("MOVE", "regione sconosciuta '%s'" % region_id)
	if not service.can_move_to(entity_id, region_id):
		return _error("MOVE", "'%s' non e adiacente alla presenza di %s" % [region_id, entity_id])

	var effects: Array = []
	var tokens: int = service.tokens_placed(entity_id)
	var moving_from: String = ""
	if tokens >= int(_chronicle["presence_tokens"]):
		moving_from = str(params.get("from_region_id", ""))
		if service.presence_count(entity_id, moving_from) <= 0:
			moving_from = _pick_source_region(entity_id, region_id)
		if moving_from == "":
			return _error("MOVE", "nessun token disponibile da spostare")
		var removed: Dictionary = applier.apply(
			Effect.make(
				"REMOVE_PRESENCE", "entity", entity_id, {"region_id": moving_from}, source
			)
		)
		if removed.is_empty():
			return _error("MOVE", applier.last_error)
		effects.append(removed)

	if service.region_free_slots(region_id) <= 0:
		# Put the token back before refusing, so a failed MOVE costs nothing.
		if not effects.is_empty():
			applier.undo_last(effects.size())
		return _error("MOVE", "'%s' non ha spazi di posizionamento liberi" % region_id)

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
	if not world["tensions"].has(tension_id):
		return _error("INFLUENCE", "tensione sconosciuta '%s'" % tension_id)
	var delta: int = int(params.get("delta", 1))
	if delta != 1 and delta != -1:
		return _error("INFLUENCE", "delta deve essere +1 o -1")
	# §10: a veiled Tension is out of reach until this Entity has uncovered it.
	if tensions.is_veiled(tension_id) and not service.knows_tension(entity_id, tension_id):
		return _error("INFLUENCE", "la Tensione '%s' e velata per %s" % [tension_id, entity_id])

	var domain: String = service.tension_domain(tension_id)
	var effects: Array = []
	var via: String = str(params.get("via", ""))
	var by_presence: bool = service.has_presence_in_domain(entity_id, domain)
	if via == "PRESENCE" and not by_presence:
		return _error("INFLUENCE", "nessuna presenza nel dominio %s" % domain)
	if via == "" and by_presence:
		via = "PRESENCE"

	if via != "PRESENCE":
		var families: Array = service.relevant_families(tension_id)
		var card: String = str(params.get("discard_asset_id", ""))
		if not service.hand(entity_id).has(card) or not families.has(Ids.asset_family(card)):
			card = service.first_asset_of_families(entity_id, families)
		if card == "":
			return _error(
				"INFLUENCE",
				"serve presenza nel dominio %s o 1 Asset di famiglia rilevante" % domain
			)
		effects.append_array(_discard(entity_id, card, source))
		via = "DISCARD"

	var applied: Dictionary = applier.apply(
		Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": delta}, source)
	)
	if applied.is_empty():
		return _error("INFLUENCE", applier.last_error)
	effects.append(applied)
	log.bullet(
		"%s influenza %s (%+d, via %s)."
		% [_name(entity_id), str(data.tensions[tension_id]["title"]), delta, via]
	)
	tensions.fire_omens(source)
	return _ok("INFLUENCE", effects, {"tension_id": tension_id, "delta": delta, "via": via})


# --- FORGE -----------------------------------------------------------------

func _forge(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var other: String = str(params.get("target_entity_id", ""))
	if not world["entities"].has(other) or other == entity_id:
		return _error("FORGE", "bersaglio non valido '%s'" % other)
	var direction: String = str(params.get("direction", "UP"))
	var current: String = service.relation_level(entity_id, other)
	var effects: Array = []

	if direction == "UP":
		# Going up needs the other player's agreement and a Bond spent (§10).
		if not bool(params.get("consent", false)):
			return _error("FORGE", "salire di un passo richiede il consenso di %s" % other)
		var card: String = str(params.get("discard_asset_id", ""))
		if not service.hand(entity_id).has(card) or Ids.asset_family(card) != "BONDS":
			card = service.first_asset_of_family(entity_id, "BONDS")
		if card == "":
			return _error("FORGE", "serve 1 Asset BONDS da scartare")
		var next_up: String = WorldStateService.shift_relation(current, 1)
		if next_up == current:
			return _error("FORGE", "la relazione e gia al massimo")
		effects.append_array(_discard(entity_id, card, source))
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

	if direction != "DOWN":
		return _error("FORGE", "direzione non valida '%s'" % direction)

	var next_down: String = WorldStateService.shift_relation(current, -1)
	if next_down == current:
		return _error("FORGE", "la relazione e gia al minimo")
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
			if not world["tensions"].has(tension_id):
				return _error("SCHEME", "tensione sconosciuta '%s'" % tension_id)
			if service.knows_tension(entity_id, tension_id):
				return _error("SCHEME", "%s conosce gia questa Tensione" % entity_id)
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
			if not world["regions"].has(region_id):
				return _error("SCHEME", "regione sconosciuta '%s'" % region_id)
			var secret: String = str(data.regions[region_id].get("private_information", ""))
			if secret == "":
				return _error("SCHEME", "'%s' non ha informazioni private" % region_id)
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
		if domain == "":
			return _error("CLAIM", "dominio mancante")
		if not service.claim_for_domain(entity_id, domain).is_empty():
			return _error("CLAIM", "%s ha gia un Claim su %s" % [entity_id, domain])
		var card: String = _pick_authority(entity_id, params)
		if card == "":
			return _error("CLAIM", "serve 1 Asset AUTHORITY da scartare")
		effects.append_array(_discard(entity_id, card, source))
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

	if mode != "FORCE":
		return _error("CLAIM", "modo sconosciuto '%s'" % mode)

	var tension_id: String = str(params.get("tension_id", ""))
	if not world["tensions"].has(tension_id):
		return _error("CLAIM", "tensione sconosciuta '%s'" % tension_id)
	var domain_of: String = service.tension_domain(tension_id)
	var claim: Dictionary = service.claim_for_domain(entity_id, domain_of)
	if claim.is_empty():
		return _error("CLAIM", "nessun Claim di %s sul dominio %s" % [entity_id, domain_of])
	# §10: the Claim has to have been laid down in an earlier round.
	if int(claim["act"]) == int(world["act"]) and int(claim["round"]) == int(world["round"]):
		return _error("CLAIM", "il Claim e stato creato in questo round")
	if tensions.value(tension_id) < 3:
		return _error("CLAIM", "la Tensione deve valere almeno 3 per essere forzata")
	if world.get("forced_confluence", null) != null:
		return _error("CLAIM", "una Confluence e gia stata forzata per questo round")
	var second: String = _pick_authority(entity_id, params)
	if second == "":
		return _error("CLAIM", "serve 1 ulteriore Asset AUTHORITY da scartare")

	effects.append_array(_discard(entity_id, second, source))
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
	return entity_id if entity == null else str(entity["name"])


func _region(region_id: String) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


func _ok(template: String, effects: Array, info: Dictionary) -> Dictionary:
	return {"ok": true, "error": "", "template": template, "effects": effects, "info": info}


func _error(template: String, message: String) -> Dictionary:
	return {"ok": false, "error": message, "template": template, "effects": [], "info": {}}
