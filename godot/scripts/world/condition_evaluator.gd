extends RefCounted
## The reusable WorldState predicates of §14.
##
## Shared by DestinyEvaluator, Confluence question/proposition eligibility and
## Echo card eligibility, so "what counts as true" is defined exactly once.

const Ids := preload("res://scripts/core/ids.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")

const RELATION_ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]
## Tags that mean "these two gave each other their word".
const PROMISE_TAGS: Array = ["PROMISE", "PACT"]

var world: Dictionary
var data: RefCounted
var service: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted) -> void:
	world = p_world
	data = p_data
	service = WorldStateService.new(p_world, p_data)


## True only if every condition holds. An empty list is always true.
func all_hold(conditions: Array, context: Dictionary = {}) -> bool:
	for condition in conditions:
		if not holds(condition, context):
			return false
	return true


func holds(condition: Dictionary, context: Dictionary = {}) -> bool:
	var condition_type: String = str(condition.get("type", ""))
	var entity_id: String = _resolve(str(condition.get("entity_id", "")), context)
	match condition_type:
		"any_of":
			# Every other condition list in the data is an AND. Propp's grammar
			# needs an OR - a Return follows a Separation *or* a Loss - and
			# nesting is the least invasive way to say so (D-031).
			for sub in condition.get("conditions", []):
				if holds(sub, context):
					return true
			return false
		"some_of":
			# «Almeno K su N». `any_of` e' il caso K=1; questo e' il caso
			# generale, e serve a un Destino che vuole dire «tre di queste
			# cinque cose, e scegli tu quali» invece di elencare una lista che
			# va soddisfatta per intero (D-161).
			var needed: int = int(condition.get("min", 1))
			var met: int = 0
			for sub in condition.get("conditions", []):
				if holds(sub, context):
					met += 1
					if met >= needed:
						return true
			return false
		"echo_function_played":
			# «E' gia' successa una cosa di questo genere?» — e la risposta sta
			# sul tavolo, non in un segno nascosto (D-358).
			#
			# Prima questa domanda si faceva con `state_tag_present` su un
			# `function:` che il motore scriveva sul mondo giocando la carta, e
			# che `effect_text` nascondeva apposta al giocatore. Cambiava chi
			# poteva uscire l'anno dopo, e al tavolo non si vedeva: viveva solo
			# nell'app. Adesso si guarda **la pila delle carte Eco gia' giocate**,
			# che e' scoperta e porta la funzione stampata su ognuna.
			return _echo_function_on_the_table(str(condition.get("function", "")))
		"structure_count":
			# Quante strutture, con i filtri che la clausola dichiara: tipo,
			# famiglia, grado minimo, Regione, e `anyone` per contare anche
			# quelle degli altri. Con `min: 1` chiede che ci sia, con `max: 0`
			# che non ci sia — come ogni altro conteggio del vocabolario.
			return _within(_structures_held(entity_id, condition), condition)
		"scar_count":
			# Le cicatrici erano gia' leggibili come tag di Regione, e **nessun
			# Destino le usava**. Con un tipo proprio si scrive quello che si
			# intende: una casa che vuole che la sua terra resti segnata
			# (`min: 1`), o una che vuole che il segno non ci sia mai stato
			# (`max: 0`) — D-161.
			return _within(_scars_on_the_map(condition), condition)
		"control_count":
			return _within(service.control_count(entity_id), condition)
		"leads_in":
			# **Piu' di chiunque altro** (D-221).
			#
			# Ogni altra condizione del vocabolario conta roba propria: due case
			# possono soddisfarla tutte e due, e allora l'obiettivo non le mette
			# l'una contro l'altra — ci giocano accanto. Su dodici obiettivi
			# **uno solo** era conteso, e il tavolo era quattro solitari.
			#
			# Questa condizione e' vera per **un seggio alla volta**, per
			# costruzione: chiede di stare davanti a tutti gli altri di almeno
			# `by`. Un obiettivo che la usa non si puo' spartire, e due case che
			# lo pescano devono togliersi qualcosa a vicenda.
			return _leads(entity_id, condition)
		"state_tag_present":
			return _has_tag(condition, context)
		"state_tag_absent":
			return not _has_tag(condition, context)
		"asset_threshold":
			var count: int = 0
			if condition.has("family"):
				count = service.count_family_in_hand(entity_id, str(condition["family"]))
			else:
				count = service.hand_size(entity_id)
			return _within(count, condition)
		"entity_alive":
			var entity: Variant = world["entities"].get(entity_id)
			return entity != null and bool(entity["active"])
		"relation_state":
			return _relation_holds(condition, context)
		"tension_limit":
			# A domain-bound Council does not know which Tension it serves until
			# it opens, so its conditions say $tension (D-028).
			var tension_id: String = _resolve(str(condition.get("tension_id", "")), context)
			if not world["tensions"].has(tension_id):
				return false
			return _within(service.tension_value(tension_id), condition)
		"tension_count":
			# **Quante Tensioni stanno sotto (o sopra) un valore** (D-255).
			#
			# `tension_limit` nomina una Tensione, e un obiettivo condiviso non
			# puo' nominarne nessuna: la Chronicle pesca il suo mazzo da un pool
			# e quella Tensione li' potrebbe non esserci. Il risultato misurato
			# e' che INFLUENZARE — il verbo che i seggi vogliono dire nel 79%
			# delle intenzioni mute (D-254) — **non compariva in nessuna
			# clausola di nessun obiettivo**: il gioco chiedeva di costruire, di
			# sapere e di tenere terra, mai di tenere giu' il mondo.
			#
			# Questa clausola conta senza nominare, e per questo si puo'
			# scrivere una volta per tutte le Chronicle. Ed e' l'unica del
			# vocabolario che il mondo **peggiora da solo**: le Tensioni salgono
			# per conto loro, quindi tenerne tre basse per un anno intero non e'
			# una cosa che capita — e' una cosa che si fa.
			return _within(_tensions_past(condition), condition)
		"discovery_count":
			return _within(_discovery_count(entity_id), condition)
		"region_presence":
			# Coi segni la riga chiede **una terra cosi' dove il conto torna**,
			# non la somma su tutte: «presidiata, non solo abitata» vuol dire
			# due pedine nello stesso posto, e sommarne una qua e una la'
			# direbbe un'altra cosa (D-327).
			if not (condition.get("any_tag", []) as Array).is_empty():
				for place in _places_with(condition):
					if _within(service.presence_count(entity_id, str(place)), condition):
						return true
				return false
			var region_id: String = _resolve(str(condition.get("region_id", "")), context)
			return _within(service.presence_count(entity_id, region_id), condition)
		"promise_kept":
			return _promise_state(condition, context) == "KEPT"
		"promise_broken":
			return _promise_state(condition, context) == "BROKEN"
	push_warning("ConditionEvaluator: unknown condition type '%s'" % condition_type)
	return false


## Human-readable line for the Chronicle End screen and the Destiny evidence log.
func describe(condition: Dictionary, context: Dictionary = {}) -> String:
	var label: String = str(condition.get("label", condition.get("type", "?")))
	return "%s %s" % ["[x]" if holds(condition, context) else "[ ]", label]


## Le righe di prova per una clausola: una per quelle semplici, una **piu' una
## per strada** per quelle che offrono una scelta.
##
## «Tre di queste cinque» non si legge se non si vede quali sono le cinque e
## quali tre hai preso. E' lo stesso difetto che il committente ha trovato nelle
## carte — «le frasi sono belle e non si capisce cosa fanno» — applicato al
## foglio che conta di piu', quello che dice come e' finito l'anno.
## Le strade di una scelta che non hanno retto, come dati. Su una clausola
## semplice non c'e' niente da aprire, e la lista e' vuota.
func open_roads(condition: Dictionary, context: Dictionary = {}) -> Array:
	var kind: String = str(condition.get("type", ""))
	if kind != "some_of" and kind != "any_of":
		return []
	var out: Array = []
	for sub in condition.get("conditions", []):
		if not holds(sub as Dictionary, context):
			out.append((sub as Dictionary).duplicate(true))
	return out


func describe_all(condition: Dictionary, context: Dictionary = {}) -> Array:
	var lines: Array = [describe(condition, context)]
	var kind: String = str(condition.get("type", ""))
	if kind == "some_of" or kind == "any_of":
		for sub in condition.get("conditions", []):
			lines.append("  %s" % describe(sub as Dictionary, context))
	return lines


func _within(value: int, condition: Dictionary) -> bool:
	if condition.has("min") and value < int(condition["min"]):
		return false
	if condition.has("max") and value > int(condition["max"]):
		return false
	# A bare condition with neither bound asks only "is there any at all".
	if not condition.has("min") and not condition.has("max"):
		return value > 0
	return true


func _has_tag(condition: Dictionary, context: Dictionary) -> bool:
	var tag: String = _resolve(str(condition.get("tag", "")), context)
	match str(condition.get("scope", "GLOBAL")):
		"GLOBAL":
			return (world["global_tags"] as Array).has(tag)
		"REGION":
			# **Per segni** (D-327): vero se **una** terra che porta uno di
			# quei segni ha il tag. Con `state_tag_absent` diventa quindi
			# «nessuna di quelle terre ce l'ha», che e' la lettura giusta:
			# al tavolo si guardano le tessere col segno e si controlla.
			if not (condition.get("any_tag", []) as Array).is_empty():
				for place in _places_with(condition):
					if service.region_has_tag(str(place), tag):
						return true
				return false
			var region_id: String = _resolve(str(condition.get("region_id", "")), context)
			# **`$any` e `$rival`: da qualche parte, e non importa dove** —
			# l'argomento di D-255 applicato alle Regioni invece che alle case.
			#
			# Un Destino e' scritto per la sua casa e sa nominare la sua terra.
			# Un obiettivo condiviso no: lo pesca chiunque, in una Chronicle
			# qualunque, e da D-265 **la mappa si pesca** — nominare una
			# Regione lo renderebbe muto meta' delle volte. Senza queste due
			# forme nessun obiettivo del mazzo puo' chiedere un segno di
			# Regione, e i segni di Regione temuti restano temuti da tutti e
			# voluti da nessuno (D-315).
			#
			# `$any` guarda tutta la mappa. `$rival` guarda **solo le terre che
			# tiene un altro**: e' la forma che non si puo' soddisfare da soli,
			# perche' il segno va posato in casa d'altri.
			if region_id == "$any":
				for candidate in world["regions"]:
					if service.region_has_tag(str(candidate), tag):
						return true
				return false
			if region_id == "$rival":
				var me: String = _resolve("$self", context)
				for candidate in world["regions"]:
					var holder: String = str(
						(world["regions"][candidate] as Dictionary).get("control", "")
					)
					if holder == "" or holder == me:
						continue
					if service.region_has_tag(str(candidate), tag):
						return true
				return false
			return service.region_has_tag(region_id, tag)
		"ENTITY":
			var entity_id: String = _resolve(str(condition.get("entity_id", "")), context)
			var entity: Variant = world["entities"].get(entity_id)
			return entity != null and (entity["tags"] as Array).has(tag)
	return false


func _relation_holds(condition: Dictionary, context: Dictionary) -> bool:
	var a: String = _resolve(str(condition.get("entity_id", "")), context)
	var b: String = _resolve(str(condition.get("other_entity_id", "")), context)
	var wanted: int = RELATION_ORDER.find(str(condition.get("level", "NEUTRAL")))
	# **`$any`: con qualcuno, e non importa con chi** (D-255).
	#
	# Ogni clausola di relazione del progetto nomina l'altro, perche' un Destino
	# scritto per una casa sa chi sono i suoi rivali. Un obiettivo condiviso non
	# lo sa: lo pesca chiunque, e nominare qualcuno lo renderebbe muto per tutti
	# gli altri. Senza questa forma **FORGIARE non ha una sola clausola che lo
	# chieda**, in nessun obiettivo del mazzo.
	if b == "$any" or b == "":
		for other in (world["entities"] as Dictionary).keys():
			var other_id: String = str(other)
			if other_id == a:
				continue
			if not bool((world["entities"][other_id] as Dictionary)["active"]):
				continue
			var level: int = RELATION_ORDER.find(service.relation_level(a, other_id))
			if bool(condition.get("at_least", true)):
				if level >= wanted:
					return true
			elif level == wanted:
				return true
		return false
	var actual: int = RELATION_ORDER.find(service.relation_level(a, b))
	if bool(condition.get("at_least", true)):
		return actual >= wanted
	return actual == wanted


## A Discovery is anything the Entity has learned that the world can point at:
## a 'discovery:' tag, however it was earned (SCHEME on a veiled Tension, a
## Consequence, an Echo card).
func _discovery_count(entity_id: String) -> int:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return 0
	var count: int = 0
	for tag in entity["tags"]:
		if str(tag).begins_with("discovery:"):
			count += 1
	return count


## A promise is KEPT while the pair still carries a PROMISE/PACT tag and has not
## fallen to open hostility; it is BROKEN when the tag is gone or the relation
## has collapsed, or when a VENDETTA has been declared.
func _promise_state(condition: Dictionary, context: Dictionary) -> String:
	var a: String = _resolve(str(condition.get("entity_id", "")), context)
	var b: String = _resolve(str(condition.get("other_entity_id", "")), context)
	var tags: Array = service.relation_tags(a, b)
	var hostile: bool = service.relation_rank(a, b) < RELATION_ORDER.find("NEUTRAL")
	var promised: bool = false
	for tag in PROMISE_TAGS:
		if tags.has(tag):
			promised = true
	if tags.has("VENDETTA"):
		return "BROKEN"
	if promised:
		return "BROKEN" if hostile else "KEPT"
	return "NONE"


## Conditions may reference the running Confluence through $proponent, $tension
## and friends, the same way Consequence effect specs do.
## La funzione di una carta Eco gia' calata. Si legge dalla pila delle carte
## **calate**, scoperte sul tavolo, e ognuna porta la sua funzione stampata.
## Non da `echo_deck.drawn`: quella e' la pila uscita dal mazzo e comprende le
## carte ancora in mano — una carta in mano non e' successa.
func _echo_function_on_the_table(function_id: String) -> bool:
	if function_id == "":
		return false
	for card_id in (world.get("echo_played", []) as Array):
		var card: Variant = data.echo_cards.get(str(card_id))
		if card == null:
			continue
		if str((card as Dictionary).get("function_id", "")) == function_id:
			return true
	return false


func _resolve(value: String, context: Dictionary) -> String:
	if value.begins_with("$") and context.has(value.substr(1)):
		return str(context[value.substr(1)])
	return value


## Quante strutture contano per questa clausola. I filtri sono tutti facoltativi
## e si sommano: il tipo, la famiglia, il grado **minimo**, la Regione, e
## `anyone` per contare anche quelle degli altri.
##
## «Un castello a Eredan» e' tipo + grado + Regione con `min: 1`. «E nessuno ha
## alzato una reggia sulla montagna» e' grado 3 + Regione + `anyone` con
## `max: 0`. Lo stesso conto dice tutte e due le cose.
## Quanto vale la metrica dichiarata, per un seggio. Le tre monete che si
## possono contendere sulla mappa e in mano: le pietre, le Regioni, le carte.
func _lead_value(entity_id: String, condition: Dictionary) -> int:
	match str(condition.get("what", "control")):
		"structures":
			return _structures_held(entity_id, condition)
		"presence":
			var standing: int = 0
			for region_id in world["regions"]:
				standing += service.presence_count(entity_id, str(region_id))
			return standing
		"hand":
			return service.hand_size(entity_id)
		_:
			return service.control_count(entity_id)


## Davanti a **tutti** gli altri, di almeno `by`. A parita' non conta: per stare
## davanti bisogna superare, come per togliere una Regione a chi la tiene
## ([D-158](DECISIONS.md#d-158)) — e a zero non si guida niente, altrimenti
## quattro case a zero pietre sarebbero tutte in testa.
func _leads(entity_id: String, condition: Dictionary) -> bool:
	var by: int = int(condition.get("by", 1))
	var mine: int = _lead_value(entity_id, condition)
	if mine <= 0:
		return false
	for other in service.active_entities():
		if str(other) == entity_id:
			continue
		if mine - _lead_value(str(other), condition) < by:
			return false
	return true


func _structures_held(entity_id: String, condition: Dictionary) -> int:
	var wanted_type: String = str(condition.get("structure_type", ""))
	var family: String = str(condition.get("structure_family", ""))
	var least: int = int(condition.get("grade", 1))
	var anyone: bool = bool(condition.get("anyone", false))
	var only_here: String = str(condition.get("region_id", ""))
	var count: int = 0
	for region_id in world["regions"]:
		if only_here != "" and str(region_id) != only_here:
			continue
		for structure in (world["regions"][region_id] as Dictionary).get("structures", []):
			var record: Dictionary = structure as Dictionary
			if not anyone and str(record.get("owner", "")) != entity_id:
				continue
			if int(record["grade"]) < least:
				continue
			if wanted_type != "" and str(record["structure_type"]) != wanted_type:
				continue
			if family != "" and not _is_family(str(record["structure_type"]), family):
				continue
			count += 1
	return count


## Quante cicatrici stanno sulla mappa. Senza `region_id`, ovunque; senza `tag`,
## una qualsiasi.
## Quante Tensioni stanno da una parte della soglia dichiarata.
##
## `at_or_below` conta quelle tenute giu', `at_or_above` quelle lasciate salire.
## Senza nessuna delle due la clausola conterebbe tutte le Tensioni del tavolo,
## che e' un numero che non dipende da nessuno: si dichiara sempre.
func _tensions_past(condition: Dictionary) -> int:
	var count: int = 0
	for tension_id in world["tensions"]:
		var value: int = service.tension_value(str(tension_id))
		if condition.has("at_or_below") and value > int(condition["at_or_below"]):
			continue
		if condition.has("at_or_above") and value < int(condition["at_or_above"]):
			continue
		count += 1
	return count


## **Le terre che portano uno di questi segni** ([D-327](DECISIONS.md#d-327)).
##
## Una clausola che nomina una Regione per nome muore quando quella Regione non
## esce dalla pesca: misurato in [D-326](DECISIONS.md#d-326), succedeva al
## **43.1%** delle righe. Le Azioni avevano gia' risolto la stessa cosa nello
## stesso modo (D-273): non «Eredan» ma «una terra che porta questo segno», e il
## validatore controlla che i segni scelti stiano su abbastanza tessere del parco
## perche' su **ogni** mappa pescata ce ne sia almeno una.
##
## Al tavolo: si guardano le tessere con quel segno stampato, e si guarda li'.
func _places_with(condition: Dictionary) -> Array:
	var wanted: Array = condition.get("any_tag", []) as Array
	var out: Array = []
	if wanted.is_empty():
		return out
	for region_id in world["regions"]:
		for tag in wanted:
			if service.region_has_tag(str(region_id), str(tag)):
				out.append(str(region_id))
				break
	return out


func _scars_on_the_map(condition: Dictionary) -> int:
	var wanted_tag: String = str(condition.get("tag", ""))
	var only_here: String = str(condition.get("region_id", ""))
	# Coi segni si contano le Cicatrici **su tutte le terre cosi'** (D-327):
	# `max: 0` diventa «nessuna di quelle terre porta un segno», `min: 1`
	# «almeno una lo porta». E' la stessa lettura di `$any`, ristretta alle
	# tessere che portano il segno stampato.
	var places: Array = _places_with(condition)
	var by_sign: bool = not (condition.get("any_tag", []) as Array).is_empty()
	var count: int = 0
	for scar in world["scars"]:
		var record: Dictionary = scar as Dictionary
		var where: String = str(record.get("region_id", ""))
		if by_sign:
			if not places.has(where):
				continue
		elif only_here != "" and where != only_here:
			continue
		if wanted_tag != "" and str(record.get("tag", "")) != wanted_tag:
			continue
		count += 1
	return count


func _is_family(structure_type: String, family: String) -> bool:
	var definition: Variant = data.structure_types.get(structure_type)
	return definition != null and str(definition["family"]) == family
