extends RefCounted
## Il telaio dei segni con un dente (ISSUES 24, Fase 2 - D-104).
##
## Una tag_rule è un dato d'autore: un segno che, finché sta sul mondo, su una
## Regione, su un'Entità o su una relazione, piega una meccanica dichiarata.
## Questo helper è l'unico punto che sa leggere le regole; i quattro ganci nel
## motore (INFLUENCE, World Factor, movimento, relazioni) gli chiedono solo il
## risultato. Con zero regole attive ogni funzione restituisce il suo neutro,
## e il motore si comporta esattamente come prima: il telaio si misura vuoto,
## i denti si accendono uno alla volta.

const LEVEL_ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]


## Le regole attive di un tipo, nel loro ordine di id: deterministico come
## tutto il resto (§18.3).
static func active(data, kind: String, chronicle_id: String) -> Array:
	if data == null:
		return []
	var out: Array = []
	var ids: Array = data.tag_rules.keys()
	ids.sort()
	for id in ids:
		var rule: Dictionary = data.tag_rules[id]
		if not bool(rule.get("active", false)):
			continue
		if str(rule.get("kind", "")) != kind:
			continue
		var wanted: String = str(rule.get("chronicle_id", ""))
		if wanted != "" and wanted != chronicle_id:
			continue
		out.append(rule)
	return out


## I segni di una regola, il `when` e gli eventuali compositi (D-125): la
## regola morde solo se TUTTI sono presenti, letti con lo stesso contesto.
static func _signs_of(rule: Dictionary) -> Array:
	var out: Array = [rule["when"]]
	out.append_array(rule.get("when_also", []))
	return out


static func _all_present(world: Dictionary, rule: Dictionary, context: Dictionary) -> bool:
	for when in _signs_of(rule):
		if not _sign_present(world, when, context):
			return false
	return true


## ACTION_MODIFIER: di quanto il segno piega un'azione, e con che titoli.
## REGION vale se il segno sta su una Regione dove chi agisce ha presenza.
static func action_bonus(
	data, world: Dictionary, entity_id: String, template: String, tension_id: String
) -> Dictionary:
	var delta: int = 0
	var titles: Array = []
	for rule in active(data, "ACTION_MODIFIER", str(world.get("chronicle_id", ""))):
		if str(rule.get("template", "")) != template:
			continue
		var wanted_tension: String = str(rule.get("tension_id", ""))
		if wanted_tension != "" and wanted_tension != tension_id:
			continue
		if _all_present(world, rule, {"entity_id": entity_id}):
			delta += int(rule.get("delta", 0))
			titles.append(str(rule["title"]))
	return {"delta": delta, "titles": titles}


## COUNCIL_MODIFIER: di quanto i segni pesano sul World Factor del Consiglio.
## Al tavolo del Consiglio gli scope si leggono così: GLOBAL è il mondo,
## ENTITY è il proponente (la fama precede chi propone), REGION è una Regione
## qualsiasi che porti il segno (se da qualche parte si muore di fame, la fame
## siede al tavolo).
static func council_world_factor(
	data, world: Dictionary, tension_id: String, proponent_id: String
) -> Dictionary:
	var delta: int = 0
	var titles: Array = []
	for rule in active(data, "COUNCIL_MODIFIER", str(world.get("chronicle_id", ""))):
		var wanted_tension: String = str(rule.get("tension_id", ""))
		if wanted_tension != "" and wanted_tension != tension_id:
			continue
		var present: bool = true
		for when in _signs_of(rule):
			if str(when.get("scope", "")) == "REGION":
				present = _any_region_has(world, str(when.get("tag", "")))
			else:
				present = _sign_present(world, when, {"entity_id": proponent_id})
			if not present:
				break
		if present:
			delta += int(rule.get("world_factor_delta", 0))
			titles.append(str(rule["title"]))
	return {"delta": delta, "titles": titles}


## GATE: "" (nessuna porta), "BLOCK" o "ALLOW" per l'ingresso in una Regione.
## BLOCK vince su ALLOW: una porta sbarrata resta sbarrata. L'eccezione
## (D-125) è PASS: chi porta il segno di una regola PASS attraversa i BLOCK
## delle regole — la cacciata di D-067 resta più forte, finché una vita non
## decida altrimenti.
static func movement_gate(
	data, world: Dictionary, region_id: String, entity_id: String = ""
) -> String:
	var verdict: String = ""
	for rule in active(data, "GATE", str(world.get("chronicle_id", ""))):
		var movement: String = str(rule.get("movement", ""))
		if movement == "PASS":
			continue
		var when: Dictionary = rule["when"]
		if str(when.get("scope", "")) != "REGION":
			continue
		if not _region_has(world, region_id, str(when.get("tag", ""))):
			continue
		if movement == "BLOCK":
			verdict = "BLOCK"
			break
		if movement == "ALLOW" and verdict == "":
			verdict = "ALLOW"
	if verdict == "BLOCK" and entity_id != "":
		for rule in active(data, "GATE", str(world.get("chronicle_id", ""))):
			if str(rule.get("movement", "")) != "PASS":
				continue
			if _all_present(world, rule, {"entity_id": entity_id}):
				return ""
	return verdict


## La vita che decide altrimenti (D-130): un PASS con `passes_eviction`
## attraversa anche la cacciata di D-067 - la porta sbarrata dal Consiglio
## non tiene chi non ha piu' un centro. Restituisce il titolo della regola
## che apre, o "" se la cacciata tiene come sempre.
static func eviction_pass(data, world: Dictionary, entity_id: String) -> String:
	for rule in active(data, "GATE", str(world.get("chronicle_id", ""))):
		if str(rule.get("movement", "")) != "PASS":
			continue
		if not bool(rule.get("passes_eviction", false)):
			continue
		if _all_present(world, rule, {"entity_id": entity_id}):
			return str(rule["title"])
	return ""


## ACTION_GATE (ISSUES 25): finché il segno c'è, l'azione è vietata. Restituisce
## il titolo della regola che sbarra, o "" se la strada è libera. Vive dentro
## check(), quindi vale ovunque: la sedia automatica non la propone, il
## browser la mostra grigia, execute() la rifiuta - una volta sola.
static func action_gate(
	data, world: Dictionary, entity_id: String, template: String
) -> String:
	for rule in active(data, "ACTION_GATE", str(world.get("chronicle_id", ""))):
		if str(rule.get("template", "")) != template:
			continue
		if _all_present(world, rule, {"entity_id": entity_id}):
			return str(rule["title"])
	return ""


## ACTION_GRANT (D-125): la variante d'azione concessa a chi porta il segno.
## Restituisce il titolo della regola che concede, o "" se nessuna: il velo
## (SCHEME_VEIL) non è un'arte di tutti.
static func action_granted(
	data, world: Dictionary, entity_id: String, variant: String
) -> String:
	for rule in active(data, "ACTION_GRANT", str(world.get("chronicle_id", ""))):
		if str(rule.get("grants", "")) != variant:
			continue
		if _all_present(world, rule, {"entity_id": entity_id}):
			return str(rule["title"])
	return ""


## ACTION_DISCOUNT (D-131): chi porta il segno compie l'azione `template`
## senza scartare la carta che l'azione chiede - il CLAIM dell'egemone non
## paga l'Asset AUTHORITY, perche' la sua parola e' gia' autorita'.
## Restituisce il titolo della regola che sconta, o "" se si paga come tutti.
static func action_discount(
	data, world: Dictionary, entity_id: String, template: String
) -> String:
	for rule in active(data, "ACTION_DISCOUNT", str(world.get("chronicle_id", ""))):
		if str(rule.get("template", "")) != template:
			continue
		if _all_present(world, rule, {"entity_id": entity_id}):
			return str(rule["title"])
	return ""


## STANCE_MODIFIER (D-125): quanto vale in più il fronte `side` di questo
## seggio. Si paga con la presenza sul fronte: il chiamante lo applica solo a
## chi ha impegnato almeno una carta — un +1 dal nulla sarebbe un voto gratis.
static func stance_bonus(
	data, world: Dictionary, entity_id: String, side: String
) -> Dictionary:
	var delta: int = 0
	var titles: Array = []
	for rule in active(data, "STANCE_MODIFIER", str(world.get("chronicle_id", ""))):
		if str(rule.get("stance", "")) != side:
			continue
		if _all_present(world, rule, {"entity_id": entity_id}):
			delta += int(rule.get("stance_delta", 0))
			titles.append(str(rule["title"]))
	return {"delta": delta, "titles": titles}


## ACTION_RIPPLE (D-129): l'azione che sfoga su una domanda. Quando chi porta
## il segno compie `template` con successo, la Tensione indicata si muove —
## i forni producono, e il grano lo paga la valle. Il chiamante applica.
static func action_ripples(
	data, world: Dictionary, entity_id: String, template: String
) -> Array:
	var out: Array = []
	for rule in active(data, "ACTION_RIPPLE", str(world.get("chronicle_id", ""))):
		if str(rule.get("template", "")) != template:
			continue
		if not _all_present(world, rule, {"entity_id": entity_id}):
			continue
		out.append({
			"tension_id": str(rule.get("tension_id", "")),
			"delta": int(rule.get("ripple_delta", 0)),
			"title": str(rule["title"]),
		})
	return out


## DRAW_BIAS (ISSUES 25): la pesca piegata. Con un segno addosso, chi pesca da
## questa famiglia guarda le prime due carte e prende la peggiore (MALUS) o la
## migliore (BONUS). MALUS vince su BONUS: un mercato guasto resta guasto.
static func draw_bias(
	data, world: Dictionary, entity_id: String, family: String
) -> Dictionary:
	var out: Dictionary = {"bias": "", "title": ""}
	for rule in active(data, "DRAW_BIAS", str(world.get("chronicle_id", ""))):
		if str(rule.get("family", "")) != family:
			continue
		if not _all_present(world, rule, {"entity_id": entity_id}):
			continue
		var bias: String = str(rule.get("bias", ""))
		if bias == "MALUS":
			return {"bias": "MALUS", "title": str(rule["title"])}
		if bias == "BONUS" and out["bias"] == "":
			out = {"bias": "BONUS", "title": str(rule["title"])}
	return out


## HAND_LIMIT (ISSUES 25): di quanto i segni muovono il limite di mano di chi
## pesca - l'assedio stringe le mani di chi è dentro.
static func hand_limit_delta(data, world: Dictionary, entity_id: String) -> Dictionary:
	var delta: int = 0
	var titles: Array = []
	for rule in active(data, "HAND_LIMIT", str(world.get("chronicle_id", ""))):
		if _all_present(world, rule, {"entity_id": entity_id}):
			delta += int(rule.get("hand_limit_delta", 0))
			titles.append(str(rule["title"]))
	return {"delta": delta, "titles": titles}


## GRANT_ON_SET (ISSUES 25): le regole che consegnano una carta quando questo
## segno viene posato in questo scope - chi costruisce il canale riceve i
## Diritti dell'Acqua. La consegna vera la fa l'applier; qui solo la scelta.
static func grants_for(data, world: Dictionary, scope: String, tag: String) -> Array:
	var out: Array = []
	for rule in active(data, "GRANT_ON_SET", str(world.get("chronicle_id", ""))):
		var when: Dictionary = rule["when"]
		if str(when.get("scope", "")) == scope and str(when.get("tag", "")) == tag:
			out.append(rule)
	return out


## RELATION_FLOOR (ISSUES 25): il pavimento più alto fra le regole accese per
## questa coppia, o "" se nessuna morde. È il potere che il Legame di Sangue
## aspetta da D-113: un vincolo che non si sceglie, sotto cui non si scende.
static func relation_floor(data, world: Dictionary, relation_key: String) -> String:
	var floor_level: String = ""
	for rule in active(data, "RELATION_FLOOR", str(world.get("chronicle_id", ""))):
		if not _all_present(world, rule, {"relation_key": relation_key}):
			continue
		var level: String = str(rule.get("min_level", ""))
		if level == "":
			continue
		if floor_level == "" or LEVEL_ORDER.find(level) > LEVEL_ORDER.find(floor_level):
			floor_level = level
	return floor_level


static func raise_to_floor(level: String, floor_level: String) -> String:
	if floor_level == "":
		return level
	if LEVEL_ORDER.find(level) < LEVEL_ORDER.find(floor_level):
		return floor_level
	return level


## RELATION_CAP: il tetto più basso fra le regole accese per questa coppia,
## o "" se nessuna morde.
static func relation_cap(data, world: Dictionary, relation_key: String) -> String:
	var cap: String = ""
	for rule in active(data, "RELATION_CAP", str(world.get("chronicle_id", ""))):
		if not _all_present(world, rule, {"relation_key": relation_key}):
			continue
		var level: String = str(rule.get("max_level", ""))
		if level == "":
			continue
		if cap == "" or LEVEL_ORDER.find(level) < LEVEL_ORDER.find(cap):
			cap = level
	return cap


static func clamp_level(level: String, cap: String) -> String:
	if cap == "":
		return level
	if LEVEL_ORDER.find(level) > LEVEL_ORDER.find(cap):
		return cap
	return level


static func _sign_present(world: Dictionary, when: Dictionary, context: Dictionary) -> bool:
	var tag: String = str(when.get("tag", ""))
	match str(when.get("scope", "")):
		"GLOBAL":
			return (world.get("global_tags", []) as Array).has(tag)
		"ENTITY":
			# Nei ganci di relazione (D-131) il contesto porta la coppia, non
			# una casa sola: il segno morde se UN membro lo porta - il tetto
			# verso l'egemone vale per chiunque tratti con lei.
			var entity_id: String = str(context.get("entity_id", ""))
			if entity_id == "" and context.has("relation_key"):
				for member in str(context["relation_key"]).split("|"):
					var side: Variant = world.get("entities", {}).get(str(member))
					if side != null and (side["tags"] as Array).has(tag):
						return true
				return false
			var entity: Variant = world.get("entities", {}).get(entity_id)
			return entity != null and (entity["tags"] as Array).has(tag)
		"REGION":
			var entity_id: String = str(context.get("entity_id", ""))
			var holder: Variant = world.get("entities", {}).get(entity_id)
			if holder == null:
				return false
			for region_id in holder["presence"]:
				if _region_has(world, str(region_id), tag):
					return true
			return false
		"RELATION":
			var relation: Variant = world.get("relations", {}).get(str(context.get("relation_key", "")))
			return relation != null and (relation["tags"] as Array).has(tag)
	return false


static func _region_has(world: Dictionary, region_id: String, tag: String) -> bool:
	var region: Variant = world.get("regions", {}).get(region_id)
	return region != null and (region["tags"] as Array).has(tag)


static func _any_region_has(world: Dictionary, tag: String) -> bool:
	for region_id in world.get("regions", {}):
		if _region_has(world, str(region_id), tag):
			return true
	return false
