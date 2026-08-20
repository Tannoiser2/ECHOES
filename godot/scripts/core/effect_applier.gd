extends RefCounted
## The single point of mutation for the WorldState (spec v0.2 §2.11, §6.3).
##
## No other system writes to the world dictionary. Systems build Effects, hand
## them here, and the applier records the exact inverse alongside each one so
## Developer Mode can walk the log backwards.
##
## Irreversibility: CREATE_ECHO and APPEND_TRUTH write history and cannot be
## undone. undo() refuses to step past one and tells the caller to restore the
## pre-Confluence snapshot instead.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

signal effect_applied(effect: Dictionary)

var world: Dictionary
var last_error: String = ""
## Optional: lets the applier tell "this Tension was not drawn for this
## Chronicle" (a no-op) from "this Tension does not exist" (a typo). Without it
## every unknown id is a failure, which is the old, stricter behaviour.
var data: RefCounted = null


func _init(p_world: Dictionary, p_data: RefCounted = null) -> void:
	world = p_world
	data = p_data


## Apply one Effect. Returns the stored Effect (with effect_id and inverse
## filled in) or an empty Dictionary on failure, with last_error set.
func apply(effect: Dictionary) -> Dictionary:
	last_error = ""
	var effect_type: String = str(effect.get("type", ""))
	if not Effect.is_known_type(effect_type):
		last_error = "unknown EffectType '%s'" % effect_type
		return {}

	var stored: Dictionary = effect.duplicate(true)
	var sequence: int = int(world.get("effect_sequence", 0)) + 1
	stored["effect_id"] = Ids.effect_id(sequence)

	var inverse: Variant = _mutate(
		effect_type, stored.get("target", {}), stored.get("payload", {})
	)
	if inverse == null:
		return {}

	stored["reversible"] = Effect.is_reversible(effect_type)
	if stored["reversible"]:
		stored["inverse_type"] = Effect.INVERSE_TYPE[effect_type]
		stored["inverse_payload"] = inverse
	else:
		stored.erase("inverse_type")
		stored.erase("inverse_payload")

	world["effect_sequence"] = sequence
	world["effect_log"].append(stored)
	effect_applied.emit(stored)
	# ISSUES 25: un segno appena posato può consegnare una carta (GRANT_ON_SET).
	# La consegna è un Effect a sé, applicato qui sotto: entra nel log con il
	# suo inverso, quindi undo e salvataggi la vedono come tutto il resto. Un
	# GRANT_ASSET non posa segni, perciò la ricorsione muore al primo passo.
	if TAG_SETTERS.has(effect_type) and not bool((inverse as Dictionary).get("noop", false)):
		_grant_on_set(effect_type, stored)
	return stored


const TAG_SETTERS: Dictionary = {
	"SET_GLOBAL_TAG": "GLOBAL", "SET_REGION_TAG": "REGION", "SET_ENTITY_TAG": "ENTITY",
}


## Il segno che consegna (ISSUES 25): per ogni regola GRANT_ON_SET accesa sul
## segno appena posato, la carta dichiarata passa a chi spetta - se è ancora
## nel mazzo o negli scarti. Una carta già in una mano non si strappa.
func _grant_on_set(effect_type: String, stored: Dictionary) -> void:
	var tag: String = str((stored["payload"] as Dictionary).get("tag", ""))
	for rule in TagRules.active(
		data, "GRANT_ON_SET", str(world.get("chronicle_id", ""))
	):
		var when: Dictionary = rule["when"]
		if str(when.get("scope", "")) != str(TAG_SETTERS[effect_type]):
			continue
		if str(when.get("tag", "")) != tag:
			continue
		var grant: Dictionary = rule.get("grant", {})
		var receiver: String = ""
		if str(grant.get("give_to", "ACTOR")) == "TARGET":
			receiver = str((stored["target"] as Dictionary).get("id", ""))
		else:
			receiver = str((stored["source"] as Dictionary).get("actor", ""))
		var entity: Variant = world["entities"].get(receiver)
		if entity == null:
			continue
		var asset_id: String = str(grant.get("asset_id", ""))
		if (entity["hand"] as Array).has(asset_id):
			continue
		var deck: Variant = world.get("decks", {}).get(Ids.asset_family(asset_id))
		if deck == null:
			continue
		var payload: Dictionary = {"asset_id": asset_id}
		var at: int = (deck["draw"] as Array).find(asset_id)
		if at >= 0:
			payload["source"] = "DECK"
			if at > 0:
				payload["deck_index"] = at
		elif (deck["discard"] as Array).has(asset_id):
			payload["source"] = "DISCARD"
		else:
			continue
		apply(Effect.make("GRANT_ASSET", "entity", receiver, payload, stored["source"]))


## Apply a batch, stopping at the first failure. Returns the Effects applied.
func apply_many(effects: Array) -> Array:
	var applied: Array = []
	for effect in effects:
		var stored: Dictionary = apply(effect)
		if stored.is_empty():
			return applied
		applied.append(stored)
	return applied


## Walk the log backwards, reverting `count` Effects. Developer Mode only.
func undo_last(count: int = 1) -> bool:
	last_error = ""
	for _i in range(count):
		var log: Array = world["effect_log"]
		if log.is_empty():
			last_error = "effect_log is empty"
			return false
		var effect: Dictionary = log[log.size() - 1]
		if not bool(effect.get("reversible", false)):
			last_error = (
				"%s (%s) is irreversible; restore the pre-Confluence snapshot instead"
				% [effect.get("effect_id", "?"), effect.get("type", "?")]
			)
			return false
		var result: Variant = _mutate(
			str(effect["inverse_type"]), effect["target"], effect["inverse_payload"]
		)
		if result == null:
			return false
		log.pop_back()
		world["effect_sequence"] = int(world["effect_sequence"]) - 1
	return true


## Revert everything applied after `effect_id` (that Effect itself is kept).
func undo_after(effect_id: String) -> bool:
	var log: Array = world["effect_log"]
	var index: int = -1
	for i in range(log.size()):
		if str(log[i]["effect_id"]) == effect_id:
			index = i
			break
	if index < 0:
		last_error = "no Effect with id '%s'" % effect_id
		return false
	return undo_last(log.size() - index - 1)


# ---------------------------------------------------------------------------
# Mutation handlers. Each returns the payload that undoes it, or null on error.
# ---------------------------------------------------------------------------

func _mutate(effect_type: String, target: Dictionary, payload: Dictionary) -> Variant:
	# A no-op Effect (e.g. tagging something that was already tagged) inverts to
	# another no-op, so undo leaves the pre-existing state alone.
	if bool(payload.get("noop", false)):
		return {"noop": true}

	match effect_type:
		"ADJUST_TENSION":
			return _adjust_tension(target, payload)
		"SET_TENSION_VISIBILITY":
			return _set_tension_visibility(target, payload)
		"ADD_PRESENCE":
			return _add_presence(target, payload)
		"REMOVE_PRESENCE":
			return _remove_presence(target, payload)
		"SET_CONTROL":
			return _set_control(target, payload)
		"SET_REGION_TAG":
			return _set_tag(_region_tags(target), payload, "SET_REGION_TAG")
		"REMOVE_REGION_TAG":
			return _remove_tag(_region_tags(target), payload, "REMOVE_REGION_TAG")
		"SET_GLOBAL_TAG":
			return _set_tag(world["global_tags"], payload, "SET_GLOBAL_TAG")
		"REMOVE_GLOBAL_TAG":
			return _remove_tag(world["global_tags"], payload, "REMOVE_GLOBAL_TAG")
		"SET_ENTITY_TAG":
			return _set_tag(_entity_tags(target), payload, "SET_ENTITY_TAG")
		"REMOVE_ENTITY_TAG":
			return _remove_tag(_entity_tags(target), payload, "REMOVE_ENTITY_TAG")
		"SET_RELATION":
			return _set_relation(target, payload)
		"GRANT_ASSET":
			return _grant_asset(target, payload)
		"REMOVE_ASSET":
			return _remove_asset(target, payload)
		"TRANSFER_ASSET":
			return _transfer_asset(payload)
		"CREATE_CLAIM":
			return _create_claim(payload)
		"CONSUME_CLAIM":
			return _consume_claim(payload)
		"ADD_SCAR":
			return _add_scar(payload)
		"REMOVE_SCAR":
			return _remove_scar(payload)
		"SET_ENTITY_ACTIVE":
			return _set_entity_active(target, payload)
		"BUILD_STRUCTURE":
			return _build_structure(target, payload)
		"RAZE_STRUCTURE":
			return _raze_structure(target, payload)
		"SET_STRUCTURE_GRADE":
			return _set_structure_grade(target, payload)
		"CREATE_ECHO":
			world["echo_log"].append(payload.duplicate(true))
			return {}
		"APPEND_TRUTH":
			world["truth_log"].append(payload.duplicate(true))
			return {}
	return _fail("no handler for EffectType '%s'" % effect_type)


func _adjust_tension(target: Dictionary, payload: Dictionary) -> Variant:
	var tension_id: String = str(target.get("id", ""))
	var tension: Variant = world["tensions"].get(tension_id)
	if tension == null:
		# Library content references Tensions that a given Chronicle may not have
		# drawn (D-028). A Ripple onto a question nobody is asking this year is a
		# no-op; an id that is not a Tension at all is still a failure.
		if data != null and data.tensions.has(tension_id):
			return {"delta": 0, "noop": true}
		return _fail("unknown tension '%s'" % tension_id)
	var before: int = int(tension["current_value"])
	# Tensions never go below zero; the inverse records the delta that was
	# actually applied so a clamped adjustment still round-trips exactly.
	var after: int = maxi(0, before + int(payload.get("delta", 0)))
	tension["current_value"] = after
	return {"delta": before - after}


func _set_tension_visibility(target: Dictionary, payload: Dictionary) -> Variant:
	var tension_id: String = str(target.get("id", ""))
	var tension: Variant = world["tensions"].get(tension_id)
	if tension == null:
		# Same rule as _adjust_tension: not drawn this Chronicle is a no-op,
		# not a Tension at all is a failure (D-028).
		if data != null and data.tensions.has(tension_id):
			return {"noop": true}
		return _fail("unknown tension '%s'" % tension_id)
	var visibility: String = str(payload.get("visibility", ""))
	if not ["OPEN", "VEILED", "SECRET"].has(visibility):
		return _fail("invalid visibility '%s'" % visibility)
	var before: String = str(tension["visibility"])
	tension["visibility"] = visibility
	# Svelare una questione gia' aperta non muove niente: marcato no-op, cosi'
	# il narratore non annuncia due volte la stessa rivelazione (ISSUES 22).
	if before == visibility:
		return {"visibility": before, "noop": true}
	return {"visibility": before}


func _add_presence(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var region_id: String = str(payload.get("region_id", ""))
	if not world["regions"].has(region_id):
		return _fail("unknown region '%s'" % region_id)
	entity["presence"].append(region_id)
	return {"region_id": region_id}


func _remove_presence(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var region_id: String = str(payload.get("region_id", ""))
	var index: int = entity["presence"].find(region_id)
	if index < 0:
		# A Consequence may say "clear them out of the Valley" without knowing
		# whether anyone is camped there. Marked optional, that is a no-op rather
		# than a failure - same shape as tagging something already tagged.
		if bool(payload.get("optional", false)):
			return {"region_id": region_id, "noop": true}
		return _fail("'%s' has no presence token in '%s'" % [target.get("id"), region_id])
	entity["presence"].remove_at(index)
	return {"region_id": region_id}


func _set_control(target: Dictionary, payload: Dictionary) -> Variant:
	var region: Variant = world["regions"].get(str(target.get("id", "")))
	if region == null:
		return _fail("unknown region '%s'" % target.get("id", ""))
	var before: Variant = region["control"]
	var next: Variant = payload.get("entity_id", null)
	if next != null and not world["entities"].has(str(next)):
		return _fail("unknown entity '%s'" % next)
	region["control"] = next
	# Un controllo che non cambia mano non e' un passaggio: marcato no-op,
	# cosi' nessuna riga annuncia un trono che non si e' mosso (ISSUES 22).
	if str(before) == str(next) or (before == null and next == null):
		return {"entity_id": before, "noop": true}
	return {"entity_id": before}


## La terra che si costruisce (D-157). Una struttura vive **dentro** una Regione:
## il bersaglio resta la Regione, e il payload dice quale tipo, con che grado e
## di chi e'. Una Regione ne porta al massimo una per tipo — un secondo castello
## nello stesso posto non e' un castello piu' grande, e' un errore di chi scrive
## i dati.
##
## Il segno `structure:` del grado si posa insieme all'oggetto, cosi' le regole
## dei segni gia' scritte continuano a leggerlo: **l'oggetto e' la verita', il
## tag e' derivato**.
func _build_structure(target: Dictionary, payload: Dictionary) -> Variant:
	var region: Variant = world["regions"].get(str(target.get("id", "")))
	if region == null:
		return _fail("unknown region '%s'" % target.get("id", ""))
	var type_id: String = str(payload.get("structure_type", ""))
	var definition: Variant = data.structure_types.get(type_id)
	if definition == null:
		return _fail("unknown structure type '%s'" % type_id)
	if _structure_at(region, type_id) >= 0:
		return {"noop": true}

	var grade: int = clampi(
		int(payload.get("grade", 1)), 1, (definition["grades"] as Array).size()
	)
	var owner: Variant = payload.get("owner", null)
	if bool(definition["owned"]) and owner != null and not world["entities"].has(str(owner)):
		return _fail("unknown entity '%s'" % owner)
	if not bool(definition["owned"]):
		owner = null

	(region["structures"] as Array).append({
		"structure_type": type_id, "grade": grade, "owner": owner,
	})
	_apply_grade_tag(region, definition, 0, grade)
	return {"structure_type": type_id}


func _raze_structure(target: Dictionary, payload: Dictionary) -> Variant:
	var region: Variant = world["regions"].get(str(target.get("id", "")))
	if region == null:
		return _fail("unknown region '%s'" % target.get("id", ""))
	var type_id: String = str(payload.get("structure_type", ""))
	var index: int = _structure_at(region, type_id)
	if index < 0:
		return {"noop": true}
	var gone: Dictionary = (region["structures"] as Array)[index]
	var definition: Dictionary = data.structure_types[type_id]
	_apply_grade_tag(region, definition, int(gone["grade"]), 0)
	(region["structures"] as Array).remove_at(index)
	# L'inverso di un abbattimento e' rialzarla **com'era**: grado e padrone
	# vengono da quello che c'era, non dai valori di partenza.
	return {
		"structure_type": type_id, "grade": int(gone["grade"]), "owner": gone.get("owner", null),
	}


func _set_structure_grade(target: Dictionary, payload: Dictionary) -> Variant:
	var region: Variant = world["regions"].get(str(target.get("id", "")))
	if region == null:
		return _fail("unknown region '%s'" % target.get("id", ""))
	var type_id: String = str(payload.get("structure_type", ""))
	var index: int = _structure_at(region, type_id)
	if index < 0:
		# Una Conseguenza scritta a mano nomina `$region_focus`, e la Regione a
		# fuoco cambia di anno in anno: diradare un bosco dove non c'e' un bosco
		# non e' un errore di dati, e' una frase che non aveva niente da dire.
		# Marcata `optional`, e' un no-op — la stessa convenzione di
		# REMOVE_PRESENCE e REMOVE_REGION_TAG.
		if bool(payload.get("optional", false)):
			return {"noop": true}
		return _fail("no '%s' in region '%s'" % [type_id, target.get("id", "")])
	var definition: Dictionary = data.structure_types[type_id]
	var structure: Dictionary = (region["structures"] as Array)[index]
	var before: int = int(structure["grade"])
	var after: int = clampi(
		int(payload.get("grade", before)), 1, (definition["grades"] as Array).size()
	)
	if after == before:
		return {"structure_type": type_id, "grade": before, "noop": true}
	structure["grade"] = after
	_apply_grade_tag(region, definition, before, after)
	return {"structure_type": type_id, "grade": before}


## Dove sta quel tipo dentro la Regione, o -1.
func _structure_at(region: Dictionary, type_id: String) -> int:
	var structures: Array = region.get("structures", [])
	for i in range(structures.size()):
		if str((structures[i] as Dictionary)["structure_type"]) == type_id:
			return i
	return -1


## Il segno del grado, tolto quello di prima. Grado 0 vuol dire «non c'e'».
func _apply_grade_tag(
	region: Dictionary, definition: Dictionary, before: int, after: int
) -> void:
	var grades: Array = definition["grades"]
	var tags: Array = region["tags"]
	if before > 0:
		var old_tag: String = str((grades[before - 1] as Dictionary).get("tag", ""))
		if old_tag != "":
			tags.erase(old_tag)
	if after > 0:
		var new_tag: String = str((grades[after - 1] as Dictionary).get("tag", ""))
		if new_tag != "" and not tags.has(new_tag):
			tags.append(new_tag)


func _set_relation(target: Dictionary, payload: Dictionary) -> Variant:
	var key: String = str(target.get("id", ""))
	# Una relazione con se stessi non esiste: quando una carta parla di
	# "$actor|$rival" e a giocarla e' proprio il rivale, l'effetto e' un no-op,
	# non un errore (D-113).
	var halves: PackedStringArray = key.split("|")
	if halves.size() == 2 and halves[0] == halves[1]:
		return {"noop": true}
	var relation: Variant = world["relations"].get(key)
	if relation == null:
		return _fail("unknown relation '%s'" % key)
	var before: Dictionary = {
		"level": str(relation["level"]),
		"tags": (relation["tags"] as Array).duplicate(),
	}
	# I tag prima del livello, e non per estetica: l'inverso di una
	# SET_RELATION riporta tags e livello di prima, e il clamp del livello
	# deve leggere i tag GIA' ripristinati - sennò il pavimento appena tolto
	# (PACT, BLOOD) blocca l'undo sotto di sé e il round-trip mente
	# (ISSUES 24, trovato dalla guardia dei round-trip con TGR_PACT_FLOOR).
	# Per la stessa moneta, in avanti: un segno scritto nello stesso effetto
	# vale subito anche per il livello che l'effetto dichiara.
	if payload.has("tags"):
		relation["tags"] = (payload["tags"] as Array).duplicate()
	if payload.has("add_tag") and not relation["tags"].has(payload["add_tag"]):
		relation["tags"].append(payload["add_tag"])
	if payload.has("remove_tag"):
		var tag_index: int = relation["tags"].find(payload["remove_tag"])
		if tag_index >= 0:
			relation["tags"].remove_at(tag_index)
	if payload.has("level"):
		var level: String = str(payload["level"])
		if not ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"].has(level):
			return _fail("invalid relation level '%s'" % level)
		# ISSUES 24: un segno può mettere un tetto alla relazione - un
		# giuramento spezzato non si supera alzando le spalle. Il tetto
		# clampa le salite; scendere resta sempre possibile.
		# ISSUES 25: e un segno può mettere un pavimento - il sangue non si
		# sceglie: sotto il pavimento non si scende, nemmeno litigando.
		# Se tetto e pavimento si contraddicono, vince il tetto: la ferita
		# scritta pesa più del vincolo di nascita.
		relation["level"] = TagRules.clamp_level(
			TagRules.raise_to_floor(level, TagRules.relation_floor(data, world, key)),
			TagRules.relation_cap(data, world, key)
		)
	return before


func _grant_asset(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var asset_id: String = str(payload.get("asset_id", ""))
	var family: String = Ids.asset_family(asset_id)
	var deck: Variant = world.get("decks", {}).get(family)
	var deck_before: Variant = null
	if deck != null:
		deck_before = {
			"draw": (deck["draw"] as Array).duplicate(),
			"discard": (deck["discard"] as Array).duplicate(),
		}

	var touched_deck: bool = false
	if payload.has("deck_restore"):
		if deck == null:
			return _fail("no deck for family '%s'" % family)
		deck["draw"] = (payload["deck_restore"]["draw"] as Array).duplicate()
		deck["discard"] = (payload["deck_restore"]["discard"] as Array).duplicate()
		touched_deck = true
	else:
		match str(payload.get("source", "VOID")):
			"DECK":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				# The reshuffle order is computed by the drawing system with the
				# seeded RNG and carried here, so the applier stays pure.
				if payload.has("reshuffle"):
					deck["draw"] = (payload["reshuffle"] as Array).duplicate()
					deck["discard"] = []
				# deck_index arriva dalla pesca piegata (ISSUES 25) o da una
				# consegna GRANT_ON_SET: la carta non è in cima, ma è sempre
				# quella dichiarata - l'applier verifica, non sceglie.
				var deck_index: int = int(payload.get("deck_index", 0))
				if deck_index < 0 or deck_index >= (deck["draw"] as Array).size():
					return _fail("family deck '%s' has no card at %d" % [family, deck_index])
				if str(deck["draw"][deck_index]) != asset_id:
					return _fail(
						"deck '%s' at %d is '%s', expected '%s'"
						% [family, deck_index, deck["draw"][deck_index], asset_id]
					)
				(deck["draw"] as Array).remove_at(deck_index)
				touched_deck = true
			"DISCARD":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				var discard_index: int = (deck["discard"] as Array).rfind(asset_id)
				if discard_index < 0:
					return _fail("'%s' is not in the '%s' discard" % [asset_id, family])
				(deck["discard"] as Array).remove_at(discard_index)
				touched_deck = true
			"VOID":
				pass
			var unknown:
				return _fail("invalid GRANT_ASSET source '%s'" % unknown)

	# hand_index is set when this GRANT is undoing a REMOVE: the card has to go
	# back where it was, or the round-trip would silently reorder the hand.
	if payload.has("hand_index"):
		(entity["hand"] as Array).insert(
			clampi(int(payload["hand_index"]), 0, (entity["hand"] as Array).size()), asset_id
		)
	else:
		entity["hand"].append(asset_id)
	var inverse: Dictionary = {"asset_id": asset_id, "destination": "VOID"}
	if touched_deck:
		inverse["deck_restore"] = deck_before
	return inverse


func _remove_asset(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var asset_id: String = str(payload.get("asset_id", ""))
	var hand_index: int = entity["hand"].find(asset_id)
	if hand_index < 0:
		return _fail("'%s' does not hold '%s'" % [target.get("id"), asset_id])
	entity["hand"].remove_at(hand_index)

	var family: String = Ids.asset_family(asset_id)
	var deck: Variant = world.get("decks", {}).get(family)
	var deck_before: Variant = null
	if deck != null:
		deck_before = {
			"draw": (deck["draw"] as Array).duplicate(),
			"discard": (deck["discard"] as Array).duplicate(),
		}

	var touched_deck: bool = false
	if payload.has("deck_restore"):
		if deck == null:
			return _fail("no deck for family '%s'" % family)
		deck["draw"] = (payload["deck_restore"]["draw"] as Array).duplicate()
		deck["discard"] = (payload["deck_restore"]["discard"] as Array).duplicate()
		touched_deck = true
	else:
		match str(payload.get("destination", "DISCARD")):
			"DISCARD":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				(deck["discard"] as Array).append(asset_id)
				touched_deck = true
			"DECK_TOP":
				if deck == null:
					return _fail("no deck for family '%s'" % family)
				(deck["draw"] as Array).push_front(asset_id)
				touched_deck = true
			"VOID":
				pass
			var unknown:
				return _fail("invalid REMOVE_ASSET destination '%s'" % unknown)

	var inverse: Dictionary = {"asset_id": asset_id, "source": "VOID", "hand_index": hand_index}
	if touched_deck:
		inverse["deck_restore"] = deck_before
	return inverse


func _transfer_asset(payload: Dictionary) -> Variant:
	var from_id: String = str(payload.get("from", ""))
	var to_id: String = str(payload.get("to", ""))
	var asset_id: String = str(payload.get("asset_id", ""))
	var giver: Variant = world["entities"].get(from_id)
	var taker: Variant = world["entities"].get(to_id)
	if giver == null or taker == null:
		return _fail("TRANSFER_ASSET between unknown entities '%s' -> '%s'" % [from_id, to_id])
	var index: int = giver["hand"].find(asset_id)
	if index < 0:
		return _fail("'%s' does not hold '%s'" % [from_id, asset_id])
	giver["hand"].remove_at(index)
	# Same reasoning as GRANT_ASSET: the reverse transfer has to put the card
	# back at the position it left, not at the end of the hand.
	if payload.has("hand_index"):
		(taker["hand"] as Array).insert(
			clampi(int(payload["hand_index"]), 0, (taker["hand"] as Array).size()), asset_id
		)
	else:
		taker["hand"].append(asset_id)
	return {"asset_id": asset_id, "from": to_id, "to": from_id, "hand_index": index}


func _create_claim(payload: Dictionary) -> Variant:
	var claim_id: String = str(payload.get("claim_id", ""))
	for claim in world["claims"]:
		if str(claim["claim_id"]) == claim_id:
			return _fail("claim '%s' already exists" % claim_id)
	world["claims"].append({
		"claim_id": claim_id,
		"entity_id": str(payload.get("entity_id", "")),
		"domain": str(payload.get("domain", "")),
		"act": int(payload.get("act", 0)),
		"round": int(payload.get("round", 0)),
	})
	return {"claim_id": claim_id}


func _consume_claim(payload: Dictionary) -> Variant:
	var claim_id: String = str(payload.get("claim_id", ""))
	var claims: Array = world["claims"]
	for i in range(claims.size()):
		if str(claims[i]["claim_id"]) == claim_id:
			var record: Dictionary = (claims[i] as Dictionary).duplicate(true)
			claims.remove_at(i)
			return record
	return _fail("no claim '%s'" % claim_id)


func _add_scar(payload: Dictionary) -> Variant:
	var region_id: String = str(payload.get("region_id", ""))
	var region: Variant = world["regions"].get(region_id)
	if region == null:
		return _fail("unknown region '%s'" % region_id)
	var record: Dictionary = {
		"scar_id": str(payload.get("scar_id", "")),
		"region_id": region_id,
		"tag": str(payload.get("tag", "")),
		"description": str(payload.get("description", "")),
	}
	if payload.has("echo_id"):
		record["echo_id"] = str(payload["echo_id"])
	world["scars"].append(record)
	# A Scar marks the map (§16). If the tag was already there for another
	# reason, undoing this Scar must not strip it.
	var tag_pre_existed: bool = region["tags"].has(record["tag"])
	if not tag_pre_existed:
		region["tags"].append(record["tag"])
	return {"scar_id": record["scar_id"], "keep_region_tag": tag_pre_existed}


func _remove_scar(payload: Dictionary) -> Variant:
	var scar_id: String = str(payload.get("scar_id", ""))
	var scars: Array = world["scars"]
	for i in range(scars.size()):
		if str(scars[i]["scar_id"]) == scar_id:
			var record: Dictionary = (scars[i] as Dictionary).duplicate(true)
			scars.remove_at(i)
			if not bool(payload.get("keep_region_tag", false)):
				var region: Variant = world["regions"].get(str(record["region_id"]))
				if region != null:
					var tag_index: int = region["tags"].find(str(record["tag"]))
					if tag_index >= 0:
						region["tags"].remove_at(tag_index)
			else:
				record["keep_region_tag"] = true
			return record
	return _fail("no scar '%s'" % scar_id)


func _set_entity_active(target: Dictionary, payload: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return _fail("unknown entity '%s'" % target.get("id", ""))
	var before: bool = bool(entity["active"])
	entity["active"] = bool(payload.get("active", true))
	return {"active": before}


# --- tag helpers -----------------------------------------------------------

func _set_tag(tags: Variant, payload: Dictionary, label: String) -> Variant:
	if tags == null:
		return _fail("%s: target not found" % label)
	var tag: String = str(payload.get("tag", ""))
	if tag == "":
		return _fail("%s: empty tag" % label)
	if (tags as Array).has(tag):
		return {"tag": tag, "noop": true}
	# `tag_index` only ever arrives on an inverse: putting the tag back where it
	# was is what makes undo byte-identical. Appending instead reorders the list
	# and the save stops matching, which is how this was found.
	var at: int = int(payload.get("tag_index", -1))
	if at >= 0 and at <= (tags as Array).size():
		(tags as Array).insert(at, tag)
	else:
		(tags as Array).append(tag)
	return {"tag": tag}


func _remove_tag(tags: Variant, payload: Dictionary, label: String) -> Variant:
	if tags == null:
		return _fail("%s: target not found" % label)
	var tag: String = str(payload.get("tag", ""))
	var index: int = (tags as Array).find(tag)
	if index < 0:
		# A Consequence may clear a condition that was never set. Marked
		# optional, that is a no-op rather than a failure.
		return {"tag": tag, "noop": true}
	(tags as Array).remove_at(index)
	return {"tag": tag, "tag_index": index}


func _region_tags(target: Dictionary) -> Variant:
	var region: Variant = world["regions"].get(str(target.get("id", "")))
	if region == null:
		return null
	return region["tags"]


func _entity_tags(target: Dictionary) -> Variant:
	var entity: Variant = world["entities"].get(str(target.get("id", "")))
	if entity == null:
		return null
	return entity["tags"]


func _fail(message: String) -> Variant:
	last_error = message
	push_error("EffectApplier: %s" % message)
	return null
