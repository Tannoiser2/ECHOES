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
const TagRules := preload("res://scripts/world/tag_rules.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const TEMPLATES: Array = [
	"ACQUIRE", "MOVE", "INFLUENCE", "FORGE", "SCHEME", "CLAIM", "PLAY_ECHO", "PLAY_CARD"
]

## Le sei azioni di §10: quelle che una carta puo' mettere in mano, e quelle che
## `actions_from_cards` toglie dal tavolo quando la mano diventa l'unica moneta.
const CARD_KINDS: Array = ["ACQUIRE", "MOVE", "INFLUENCE", "FORGE", "SCHEME", "CLAIM"]

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var rng: RefCounted
var log: RefCounted
var service: RefCounted
var tensions: RefCounted
## ISSUES 23 (D-118): calare una carta del Narratore e' un'azione, ma la carta
## parla nel ChronicleController (funzione, effetti, presagi). GameSession
## aggancia qui `play_narrator_card`; l'eleggibilita' si giudica in check().
var play_card: Callable = Callable()
var _eligibility: RefCounted

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
	_eligibility = ConditionEvaluator.new(p_world, p_data)
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
	# ISSUES 25: un segno può vietare un'azione. Il divieto vive qui perché qui
	# vive ogni precondizione: la sedia automatica non la propone, il browser
	# la spegne, execute() la rifiuta - scritta una volta sola.
	var gate: String = TagRules.action_gate(data, world, entity_id, template)
	if gate != "":
		return "il segno lo vieta: %s" % gate
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
		"PLAY_ECHO":
			return _check_play_echo(entity_id, params)
		"PLAY_CARD":
			return _check_play_card(entity_id, params)
	return "template non implementato"


func can_execute(entity_id: String, template: String, params: Dictionary) -> bool:
	return check(entity_id, template, params) == ""


## Returns {ok, error, template, effects, info}.
func execute(entity_id: String, request: Dictionary) -> Dictionary:
	var template: String = str(request.get("template", ""))
	var params: Dictionary = request.get("params", {})

	# ISSUES 47: quando la Chronicle dichiara che le azioni si fanno con le carte,
	# le sei di §10 non si prendono piu' con un'Opportunita' - si giocano dalla
	# mano, e quella carta smette di poter votare.
	#
	# Il divieto vive **qui e non in `check()`** (corretto in D-188): `check()`
	# risponde a «questa azione sarebbe legale?», ed e' la domanda che una sedia
	# si fa *prima* di sapere con quale carta la dira'. Metterlo nel check
	# spegneva anche quella domanda, e i seggi smettevano di volere qualcosa:
	# misurato, il 90% delle Occasioni restava muto.
	if bool(_chronicle.get("actions_from_cards", false)) and CARD_KINDS.has(template):
		return _error(
			template,
			"qui le azioni si fanno con le carte: gioca una carta che porti %s" % template
		)

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
	var outcome: Dictionary = {}
	match template:
		"ACQUIRE":
			outcome = _acquire(entity_id, params, source)
		"MOVE":
			outcome = _move(entity_id, params, source)
		"INFLUENCE":
			outcome = _influence(entity_id, params, source)
		"FORGE":
			outcome = _forge(entity_id, params, source)
		"SCHEME":
			outcome = _scheme(entity_id, params, source)
		"CLAIM":
			outcome = _claim(entity_id, params, source)
		"PLAY_ECHO":
			outcome = _play_echo(entity_id, params, source)
		"PLAY_CARD":
			outcome = _play_asset_card(entity_id, params, source)
		_:
			return _error(template, "template non implementato")

	# ISSUES 49 (D-192): **il calore lo pescano i giocatori.** Ogni azione
	# riuscita pesca un gettone dal sacchetto e lo posa su una domanda: il mondo
	# si scalda perche' qualcuno ha fatto qualcosa, non perche' e' passato il
	# tempo. Il sacchetto e' quello della Deriva (D-047), che il committente ha
	# gia' tarato; a rubinetto spento non succede niente.
	if bool(outcome.get("ok", false)):
		_draw_heat(source, outcome)

	# ACTION_RIPPLE (D-129): l'azione che sfoga su una domanda. Dopo un'azione
	# riuscita, i segni di chi ha agito possono muovere una Tensione - i forni
	# producono, e il grano lo paga la valle. Ogni sfogo si firma a verbale.
	if bool(outcome.get("ok", false)):
		var rippled: bool = false
		for ripple in TagRules.action_ripples(data, world, entity_id, template):
			var applied: Dictionary = applier.apply(Effect.make(
				"ADJUST_TENSION", "tension", str(ripple["tension_id"]),
				{"delta": int(ripple["delta"])}, source
			))
			if applied.is_empty():
				continue
			(outcome.get("effects", []) as Array).append(applied)
			rippled = true
			var tension: Variant = data.tensions.get(str(ripple["tension_id"]))
			log.bullet("  Il segno sfoga: %s — %s %+d." % [
				str(ripple["title"]),
				str(ripple["tension_id"]) if tension == null else str(tension["title"]),
				int(ripple["delta"]),
			])
		if rippled:
			tensions.fire_omens(source)
	return outcome


## Il gettone che l'azione fa scendere (D-192). Quale domanda si scalda lo decide
## il sacchetto — la stessa distribuzione della Deriva, quindi la stessa
## personalita' del mondo — e il seme, quindi la partita resta rigiocabile.
##
## Vive solo se la Chronicle dichiara `tension_tokens`. Senza, non succede
## niente e il calore lo mette la Deriva come sempre.
func _draw_heat(source: Dictionary, outcome: Dictionary) -> void:
	var rules: Dictionary = _chronicle.get("tension_tokens", {}) as Dictionary
	if rules.is_empty():
		return
	var per_action: int = int(rules.get("per_action", 1))
	if per_action <= 0:
		return
	# Il sacchetto e' la **traccia della Deriva gia' mescolata** (`drift_track`),
	# non la distribuzione scritta nella Chronicle: le due coincidono per una
	# Chronicle d'autore, ma una Chronicle di libreria pesca le proprie domande
	# da un pool e la distribuzione scritta **non c'e'**. Leggendo quella, il
	# sacchetto restava vuoto, la Deriva era spenta, e l'anno di libreria non si
	# scaldava mai: mediana 2 Consigli contro i 3-7 attesi. L'ha trovato un test.
	var bag: Array = world.get("drift_track", []) as Array
	if bag.is_empty():
		return
	# Il gettone porta **una firma sua**, non quella dell'azione: il calore e'
	# del mondo, non della mano che ha agito. Riusare la firma dell'azione
	# faceva contare un gettone come un INFLUENZARE — e il tetto di §10 saltava.
	# L'ha trovato un test che ricostruisce i conti dal registro degli Effetti.
	var mine: Dictionary = Effect.source(
		"system",
		"TENSION_TOKEN",
		str(source.get("actor", "")),
		int(world["act"]),
		int(world["round"]),
		int(world["effect_sequence"])
	)
	# **Il valore del gettone** (ISSUES 49 fase 3). Senza `covered` vale 1 e il
	# mucchio si conta a occhio, quindi coprirlo non nasconderebbe niente:
	# coprire ha senso solo se il valore varia. Il sacchetto dei valori e'
	# dichiarato dalla Chronicle e mescolato dallo stesso seme di tutto il resto.
	var values: Array = rules.get("covered", []) as Array
	var covered: bool = not values.is_empty()

	for _i in range(per_action):
		var tension_id: String = str(bag[rng.range_int(0, bag.size() - 1)])
		if not (world["tensions"] as Dictionary).has(tension_id):
			continue
		var worth: int = 1
		if covered:
			worth = int(values[rng.range_int(0, values.size() - 1)])
		var applied: Dictionary = applier.apply(Effect.make(
			"ADJUST_TENSION", "tension", tension_id, {"delta": worth}, mine
		))
		# Un gettone che vale zero non muove niente e l'applicatore lo rifiuta:
		# ma **e' sceso lo stesso**, quindi conta per il cancello e si vede
		# cadere. E' il gettone bianco, ed e' meta' del punto di coprire.
		if not applied.is_empty():
			(outcome.get("effects", []) as Array).append(applied)
		elif worth != 0:
			continue
		# **Il mondo non cambia in silenzio** (D-030). Il gettone si vede
		# cadere: senza questa riga una persona giocava una carta e una domanda
		# si scaldava senza che niente lo dicesse — la Deriva lo ha sempre
		# detto, e il sacchetto che la sostituisce deve dirlo uguale.
		#
		# Coperto, si vede **cadere** e non **quanto vale**: e' il gesto che sta
		# sul tavolo, e il numero si gira al Consiglio.
		var tension: Variant = data.tensions.get(tension_id)
		var title: String = tension_id if tension == null \
			else str((tension as Dictionary)["title"])
		if covered:
			log.bullet("  Un gettone coperto cade su %s." % title)
		else:
			log.bullet("  Il gettone cade su %s: sale di 1." % title)
		# Il cancello del tavolo conta **i gettoni**, non le domande (D-203):
		# quando ne sono scesi abbastanza si apre un Consiglio, e quale domanda
		# si dibatte lo decide il mucchio piu' alto — non la soglia di ciascuna.
		world["tokens_in_bag"] = int(world.get("tokens_in_bag", 0)) + 1
	tensions.fire_omens(mine)


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
	# §10: a veiled Tension is out of reach until this Entity has uncovered it —
	# a meno che il velo copra la sola soglia (D-187), e allora la domanda si
	# spinge come ogni altra, senza sapere quando esplodera'.
	if tensions.out_of_reach(tension_id, service.knows_tension(entity_id, tension_id)):
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
		"REGION":
			var region_id: String = str(params.get("region_id", ""))
			if not world["regions"].has(region_id):
				return "regione sconosciuta '%s'" % region_id
			if str(data.regions[region_id].get("private_information", "")) == "":
				return "'%s' non ha informazioni private" % region_id
			return ""
		"VEIL":
			# Il velo (D-125): l'arte inversa dello scouting - chiudere un
			# numero al tavolo. Non e' di tutti: la concede un segno.
			var veiled_id: String = str(params.get("tension_id", ""))
			if not world["tensions"].has(veiled_id):
				return "tensione sconosciuta '%s'" % veiled_id
			if TagRules.action_granted(data, world, entity_id, "SCHEME_VEIL") == "":
				return "il velo non e un'arte di questa casa"
			if tensions.is_veiled(veiled_id):
				return "'%s' e gia velata" % veiled_id
			return ""
	return "modo sconosciuto '%s'" % params.get("mode", "")


## §10 e' materia del committente, quindi la deroga sta nella Chronicle e non nel
## codice (D-191). `same_round_when_ready` acceso, prendere la parola su una
## domanda gia' matura e' **un'azione sola**; spento, il gioco e' quello di §10 —
## si prenota in un round e si riscuote in un altro.
func _claim_in_one_move() -> bool:
	return bool(
		(_chronicle.get("claim_rules", {}) as Dictionary).get("same_round_when_ready", false)
	)


## Quanto deve valere una domanda per essere «matura». §10 dice 3.
func _claim_ready_at() -> int:
	return int((_chronicle.get("claim_rules", {}) as Dictionary).get("ready_at", 3))


func _check_claim(entity_id: String, params: Dictionary) -> String:
	var mode: String = str(params.get("mode", "CREATE"))
	if mode == "CREATE":
		var domain: String = str(params.get("domain", ""))
		if domain == "":
			return "dominio mancante"
		if not service.claim_for_domain(entity_id, domain).is_empty():
			return "%s ha gia un Claim su %s" % [entity_id, domain]
		if _pick_authority(entity_id, params) == "" \
				and TagRules.action_discount(data, world, entity_id, "CLAIM") == "":
			return "serve 1 Asset AUTHORITY da scartare"
		return ""
	if mode != "FORCE":
		return "modo sconosciuto '%s'" % mode

	var tension_id: String = str(params.get("tension_id", ""))
	if not world["tensions"].has(tension_id):
		return "tensione sconosciuta '%s'" % tension_id
	if tensions.value(tension_id) < _claim_ready_at():
		return "la Tensione deve valere almeno %d per essere forzata" % _claim_ready_at()
	var claim: Dictionary = service.claim_for_domain(entity_id, service.tension_domain(tension_id))
	# ISSUES 37 (D-191): **non si prenota una domanda che e' gia' matura.** Se la
	# Tensione ha gia' raggiunto la maturita', prendere la parola e' un'azione
	# sola; la prenotazione resta per il caso vero — la domanda che *non* e'
	# ancora matura e che ci si vuole accaparrare prima che lo diventi.
	if claim.is_empty():
		if not _claim_in_one_move():
			return "nessun Claim di %s sul dominio %s" % [
				entity_id, service.tension_domain(tension_id)
			]
	elif int(claim["act"]) == int(world["act"]) and int(claim["round"]) == int(world["round"]) \
			and not _claim_in_one_move():
		# §10: the Claim has to have been laid down in an earlier round.
		return "il Claim e stato creato in questo round"
	if world.get("forced_confluence", null) != null:
		return "una Confluence e gia stata forzata per questo round"
	if _pick_authority(entity_id, params) == "" \
			and TagRules.action_discount(data, world, entity_id, "CLAIM") == "":
		return "serve 1 ulteriore Asset AUTHORITY da scartare"
	return ""


## Calare l'Eco di una carta (D-359). **Non c'e' piu' un mazzo del Narratore**:
## l'Eco e' il terzo blocco stampato sulla carta Asset che hai in mano - la sua
## versione potenziata. Si cala al posto di un'Azione normale, e le quattro
## guardie sono:
##
##   1. la carta e' in mano (e' una carta Asset, non un mazzo a parte);
##   2. l'Atto lo permette: la famiglia drammatica dell'Eco deve stare nel
##      pool dell'Atto corrente - e' la forma in tre atti, che prima faceva il
##      sacchetto e adesso fa questo cancello;
##   3. i segni che l'Eco nomina stanno sul tavolo (D-030 letto a segni, non
##      piu' col nome della questione dell'anno: strada 1 del committente);
##   4. c'e' una seconda carta con cui pagare la parola (D-118) - la potenziata
##      costa la carta **piu'** un'altra scartata.
func _check_play_echo(entity_id: String, params: Dictionary) -> String:
	var asset_id: String = str(params.get("asset_card_id", ""))
	if not service.hand(entity_id).has(asset_id):
		return "'%s' non e nella mano di %s" % [asset_id, entity_id]
	var asset: Variant = data.assets.get(asset_id)
	if asset == null:
		return "carta sconosciuta '%s'" % asset_id
	var card_id: String = str((asset as Dictionary).get("echo_id", ""))
	var card: Variant = data.echo_cards.get(card_id)
	if card == null:
		return "'%s' non porta un Eco" % asset_id
	if not _families_open_by(int(world["act"])).has(str((card as Dictionary)["dramatic_family"])):
		return "l'Eco di '%s' non si cala in questo Atto" % asset_id
	if service.hand_size(entity_id) < 2:
		return "l'Eco costa la carta piu un'altra scartata, e la mano non basta"
	if not _eligibility.all_hold((card as Dictionary).get("eligibility", []), {}):
		return "il mondo non porta i segni di '%s'" % str((card as Dictionary)["title"])
	if (card as Dictionary).get("forces_confluence_on", null) != null \
			and world.get("forced_confluence", null) != null:
		return "il tavolo ha gia un Consiglio prescritto per questo round"
	return ""


func _play_echo(entity_id: String, params: Dictionary, source: Dictionary) -> Dictionary:
	var asset_id: String = str(params.get("asset_card_id", ""))
	var card_id: String = str((data.assets[asset_id] as Dictionary)["echo_id"])
	var effects: Array = []
	# La carta calata se ne va per prima: e' lei che parla, non un pezzo di un
	# mazzo a parte. Poi il prezzo della parola (D-118), che nella versione
	# potenziata resta - una seconda carta, la piu' debole se nessuno sceglie.
	effects.append_array(_discard(entity_id, asset_id, source))
	var price: String = str(params.get("discard_asset_id", ""))
	if not service.hand(entity_id).has(price):
		price = _worst_of(service.hand(entity_id))
	if price != "":
		effects.append_array(_discard(entity_id, price, source))
		log.bullet("%s paga la parola: scarta %s." % [_name(entity_id), _title(price)])
	var applied: Array = play_card.call(entity_id, card_id, source)
	effects.append_array(applied)
	return _ok("PLAY_ECHO", effects, {"echo_card_id": card_id, "asset_card_id": asset_id})


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
## La pesca del rubinetto (ISSUES 47, D-185). Non e' un'azione: e' il mondo che
## a inizio Atto da' le carte in base alla mappa, e passa di qui per una ragione
## sola — cosi' la pesca piegata dai segni (`DRAW_BIAS`, D-116) e il rimescolo
## degli scarti valgono anche per lei, invece di essere riscritti altrove.
func draw_for_refill(entity_id: String, family: String, source: Dictionary) -> String:
	if not (world["decks"] as Dictionary).has(family):
		return ""
	var effects: Array = []
	var card: String = _draw_one(family, entity_id, source, effects)
	return card


func _draw_one(family: String, entity_id: String, source: Dictionary, effects: Array) -> String:
	var deck: Dictionary = world["decks"][family]
	var payload: Dictionary = {"source": "DECK"}
	var pile: Array = deck["draw"]
	if pile.is_empty():
		if (deck["discard"] as Array).is_empty():
			return ""
		var reshuffled: Array = rng.shuffle(deck["discard"])
		payload["reshuffle"] = reshuffled
		pile = reshuffled
		log.bullet("Il mazzo %s viene rimescolato dagli scarti." % family)
	var top: String = str(pile[0])
	# ISSUES 25: la pesca piegata. Col segno addosso si guardano le prime due
	# carte e si prende la peggiore (MALUS) o la migliore (BONUS); l'altra
	# resta dov'era. Deterministico: l'indice viaggia nell'Effect.
	if pile.size() >= 2:
		var bias: Dictionary = TagRules.draw_bias(data, world, entity_id, family)
		if str(bias["bias"]) != "":
			var gap: int = _strength(str(pile[1])) - _strength(str(pile[0]))
			var wants_second: bool = gap > 0 if str(bias["bias"]) == "BONUS" else gap < 0
			if wants_second:
				payload["deck_index"] = 1
				top = str(pile[1])
			log.bullet("Il segno pesa: %s." % str(bias["title"]))
	payload["asset_id"] = top
	var applied: Dictionary = applier.apply(
		Effect.make("GRANT_ASSET", "entity", entity_id, payload, source)
	)
	if applied.is_empty():
		return ""
	effects.append(applied)
	return top


## §9: hand limit 7; the eighth Asset forces a discard. ISSUES 25: un segno
## può muovere il limite (l'assedio stringe le mani di chi è dentro), mai
## sotto una carta.
func _enforce_hand_limit(entity_id: String, params: Dictionary, source: Dictionary) -> Array:
	var squeeze: Dictionary = TagRules.hand_limit_delta(data, world, entity_id)
	var limit: int = maxi(1, int(_chronicle["hand_limit"]) + int(squeeze["delta"]))
	if int(squeeze["delta"]) != 0 and service.hand_size(entity_id) > limit:
		log.bullet(
			"Il segno pesa: %s." % ", ".join(PackedStringArray(squeeze["titles"]))
		)
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

	# ISSUES 24: un segno con un dente può pesare sull'azione. Il bonus
	# allarga la grandezza nel verso scelto, mai il contrario, e ogni regola
	# che morde si firma a verbale.
	var bite: Dictionary = TagRules.action_bonus(data, world, entity_id, "INFLUENCE", tension_id)
	if int(bite["delta"]) != 0:
		delta += int(bite["delta"]) if delta > 0 else -int(bite["delta"])
		for title in bite["titles"]:
			log.bullet("  Il segno pesa: %s." % str(title))

	var spent: String = ""
	if via != "PRESENCE":
		spent = _pick_relevant_asset(entity_id, tension_id, params)
		effects.append_array(_discard(entity_id, spent, source))
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
	# ISSUES 22 (fase 4): se la via e' lo scarto, la carta spesa si nomina.
	if spent == "":
		log.bullet(
			"%s influenza %s (%+d, via %s)."
			% [_name(entity_id), str(data.tensions[tension_id]["title"]), delta, via]
		)
	else:
		log.bullet(
			"%s scarta %s e influenza %s (%+d)."
			% [_name(entity_id), _title(spent), str(data.tensions[tension_id]["title"]), delta]
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
		"VEIL":
			# Il velo (D-125): il numero torna coperto per il tavolo, e chi
			# aveva mandato spie non sa piu' - il dogma riscrive il saputo.
			# Chi vela, invece, sa cosa ha coperto: il suo `knows` resta.
			var veiled_id: String = str(params.get("tension_id", ""))
			effects.append(
				applier.apply(
					Effect.make(
						"SET_TENSION_VISIBILITY",
						"tension",
						veiled_id,
						{"visibility": "VEILED"},
						source
					)
				)
			)
			var known_tag: String = Ids.knows_tension_tag(veiled_id)
			for other_id in world["turn_order"]:
				if str(other_id) == entity_id:
					continue
				if not (world["entities"][str(other_id)]["tags"] as Array).has(known_tag):
					continue
				effects.append(
					applier.apply(
						Effect.make(
							"REMOVE_ENTITY_TAG", "entity", str(other_id),
							{"tag": known_tag}, source
						)
					)
				)
			effects.append(
				applier.apply(
					Effect.make(
						"SET_ENTITY_TAG", "entity", entity_id, {"tag": known_tag}, source
					)
				)
			)
			# Cosa copre il velo lo dice la Chronicle (D-187): il numero intero,
			# oppure la sola soglia. Il registro non promette piu' di quanto sia
			# stato coperto davvero.
			log.bullet(
				(
					"%s cala il velo: di %s non si sa piu' quando esplodera'."
					if tensions.hides_threshold_only()
					else "%s cala il velo: %s non ha piu' un numero sul tavolo."
				) % [_name(entity_id), str(data.tensions[veiled_id]["title"])]
			)
			return _ok("SCHEME", effects, {"tension_id": veiled_id, "veiled": true})
	return _error("SCHEME", "modo sconosciuto '%s'" % mode)


## Le famiglie che possono parlare **da quest'Atto in poi** (D-359).
##
## `act_echo_pools` dice dove una famiglia *comincia*: pressione dall'Atto 1,
## rottura e svolta dal 2, risoluzione dal 3. La prima stesura leggeva il pool
## come un elenco chiuso — solo quelle famiglie, in quell'Atto — e misurato
## costava caro: **382 Echi fermi in mano per l'Atto**, piu' di quanti ne
## fermassero i segni. Era anche una regola sbagliata: una pressione al terzo
## Atto e' perfettamente drammatica, una risoluzione al primo no.
##
## La forma in tre atti e' che **le cose diventano possibili**, non che smettano
## di esserlo.
func _families_open_by(act: int) -> Array:
	var out: Array = []
	for earlier in range(1, act + 1):
		for family in _act_echo_families(earlier):
			if not out.has(str(family)):
				out.append(str(family))
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
		# D-131: la parola dell'egemone e' gia' autorita' - col segno dello
		# sconto il CLAIM non scarta niente, carta in mano o no.
		var waived: String = TagRules.action_discount(data, world, entity_id, "CLAIM")
		var price: String = "" if waived != "" else _pick_authority(entity_id, params)
		effects.append_array(_discard(entity_id, price, source))
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
		# ISSUES 22 (fase 4): la carta spesa si nomina - uno scarto muto era uno
		# dei silenzi che la sonda della visibilita' ha trovato. E anche lo
		# sconto si nomina (D-131): un diritto gratis e' un fatto del tavolo.
		if price == "":
			log.bullet("%s rivendica il dominio %s per parola propria - %s." % [
				_name(entity_id), domain, waived
			])
		else:
			log.bullet("%s scarta %s e rivendica il dominio %s." % [
				_name(entity_id), _title(price), domain
			])
		return _ok("CLAIM", effects, {"claim_id": claim_id, "domain": domain})

	var tension_id: String = str(params.get("tension_id", ""))
	var claim: Dictionary = service.claim_for_domain(entity_id, service.tension_domain(tension_id))
	var forced_waiver: String = TagRules.action_discount(data, world, entity_id, "CLAIM")
	var second: String = "" if forced_waiver != "" else _pick_authority(entity_id, params)
	effects.append_array(_discard(entity_id, second, source))
	# Senza prenotazione non c'e' niente da consumare: la parola si e' presa in
	# un colpo su una domanda gia' matura (D-191).
	if not claim.is_empty():
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
	if second == "":
		log.bullet(
			"%s consuma il proprio Claim e forza una Confluence su %s - %s."
			% [_name(entity_id), str(data.tensions[tension_id]["title"]), forced_waiver]
		)
	else:
		log.bullet(
			"%s consuma il proprio Claim, scarta %s, e forza una Confluence su %s."
			% [_name(entity_id), _title(second), str(data.tensions[tension_id]["title"])]
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

## --- PLAY_CARD: l'azione che sta sulla carta (ISSUES 47) --------------------
##
## «Ogni carta ha una azione di gioco, un valore per il consiglio, e effetti
## specifici della carta»: il valore e gli effetti c'erano gia' (`strength` e
## `on_commit_effects`), l'azione e' `card_action`. Giocarla la **consuma**, ed
## e' li' che sta il gioco - quella carta non votera' piu'.
##
## Il telaio non duplica nessuna regola: legge la `card_action`, fonde i suoi
## parametri con quelli che chi la gioca ha scelto, e passa dal medesimo
## `check()` e dal medesimo eseguore dell'azione corrispondente. Una carta non
## puo' fare cio' che l'azione non permetterebbe.
func _card_request(entity_id: String, params: Dictionary) -> Dictionary:
	var asset_id: String = str(params.get("asset_id", ""))
	if asset_id == "":
		return {"error": "manca la carta da giocare"}
	if not (service.hand(entity_id) as Array).has(asset_id):
		return {"error": "'%s' non e in mano a %s" % [asset_id, entity_id]}
	var card: Variant = data.assets.get(asset_id)
	if card == null:
		return {"error": "carta sconosciuta '%s'" % asset_id}
	var action: Dictionary = (card as Dictionary).get("card_action", {}) as Dictionary
	if action.is_empty():
		return {"error": "«%s» non porta nessuna azione" % str((card as Dictionary)["title"])}
	# **La faccia e' la verita'** (D-283, passo 1 del brief del Punto Zero).
	#
	# Una carta stampa **due** Azioni, e fino a qui il motore ne conosceva una:
	# quella dichiarata in `card_action.kind`. L'altra era testo. Adesso chi
	# gioca dice **quale delle due sta calando** — `face_action` e' l'indice
	# dell'Azione stampata — e il verbo viene da li'. Senza indice si ricade
	# sul verbo dichiarato, che e' quello che fanno i salvataggi vecchi e le
	# prove scritte prima di questa decisione.
	var face_actions: Array = (
		((card as Dictionary).get("physical", {}) as Dictionary).get("actions", []) as Array
	)
	var chosen: int = int(params.get("face_action", -1))
	var kind: String = ""
	if chosen >= 0 and chosen < face_actions.size():
		kind = str((face_actions[chosen] as Dictionary).get("template", ""))
		if kind == "":
			return {"error": "quell'Azione della carta il motore non la sa ancora eseguire"}
	if kind == "":
		kind = str(action.get("kind", ""))
	# I parametri della carta vengono prima; quelli di chi la gioca riempiono
	# solo cio' che la carta lascia aperto. `face_action` dice **quale Azione**,
	# non e' un parametro del verbo: non deve arrivare al resolver.
	var merged: Dictionary = {}
	for key in params:
		if key != "asset_id" and key != "face_action" and key != "mark_region_id":
			merged[key] = params[key]
	for key in (action.get("params", {}) as Dictionary):
		merged[key] = (action["params"] as Dictionary)[key]
	# **La carta e' la propria spesa** (D-188). Tre delle sei azioni chiedono di
	# scartare un Asset — INFLUENZARE senza presenza, RIVENDICARE, FORGIARE in
	# su — e senza questa riga giocare una carta per farle ne costerebbe due:
	# quella giocata piu' quella scartata. Qui il conto torna: la carta paga se
	# stessa, e resta vero che una carta spesa non votera' piu'.
	if not merged.has("discard_asset_id"):
		merged["discard_asset_id"] = asset_id
	return {
		"kind": kind, "params": merged, "asset_id": asset_id, "face_action": chosen,
		# **Dove cadono i segni stampati** (D-284). Il verbo puo' non nominare
		# nessuna Regione — INFLUENZARE parla a una domanda, FORGIARE a una casa
		# — ma la carta il posto lo dice lo stesso: il bersaglio a segni sta
		# sulla faccia, e al tavolo ci si punta il dito.
		"mark_region_id": str(params.get("mark_region_id", "")),
	}


func _check_play_card(entity_id: String, params: Dictionary) -> String:
	var request: Dictionary = _card_request(entity_id, params)
	if request.has("error"):
		return str(request["error"])
	# La stessa domanda che si farebbe all'azione, perche' e' la stessa azione.
	var gate: String = TagRules.action_gate(data, world, entity_id, str(request["kind"]))
	if gate != "":
		return "il segno lo vieta: %s" % gate
	# Il bersaglio a segni, eseguito (D-274): la faccia fisica dice DOVE la
	# carta arriva, e da qui il motore la legge — la sim gioca lo stesso gioco
	# del tavolo.
	var reach: String = _check_physical_target(
		str(params.get("asset_id", "")), str(request["kind"]), request["params"] as Dictionary
	)
	if reach != "":
		return reach
	# E il posto dove cadranno i segni stampati, se chi cala l'ha nominato, deve
	# essere uno che la carta raggiunge: la stessa promessa, per la stessa
	# ragione (D-284).
	var mark: String = str(request.get("mark_region_id", ""))
	if mark != "":
		var refused: String = why_not_reached(
			str(params.get("asset_id", "")), mark, "non lascia segni li'"
		)
		if refused != "":
			return refused
	match str(request["kind"]):
		"ACQUIRE":
			return _check_acquire(entity_id, request["params"])
		"MOVE":
			return _check_move(entity_id, request["params"])
		"INFLUENCE":
			return _check_influence(entity_id, request["params"])
		"FORGE":
			return _check_forge(entity_id, request["params"])
		"SCHEME":
			return _check_scheme(entity_id, request["params"])
		"CLAIM":
			return _check_claim(entity_id, request["params"])
	return "la carta porta un'azione che non esiste"


## Il bersaglio a segni, eseguito (D-274 — il primo pezzo di faccia fisica
## dopo la Risonanza che il motore esegue, ISSUES 69). La faccia della carta
## dice DOVE la carta arriva; qui vale per i verbi che nominano una Regione —
## MUOVERE, e TRAMARE su una Regione. Il luogo scelto deve portare uno dei
## segni del bersaglio, e nessuno dei vietati. Contano i segni **vivi**, come
## al tavolo: quelli stampati sulla tessera piu' quelli posati durante l'anno.
## Una carta senza `any_tag` va ovunque, come la sua faccia dice. Le facce a
## bersaglio ENTITY/TENSION restano dichiarate e non eseguite (ISSUES 69).
func _check_physical_target(asset_id: String, kind: String, params: Dictionary) -> String:
	var card: Variant = data.assets.get(asset_id)
	if card == null:
		return ""
	var target: Dictionary = (
		((card as Dictionary).get("physical", {}) as Dictionary).get("target", {}) as Dictionary
	)
	if str(target.get("scope", "")) != "REGION":
		return ""
	var aims_at_region: bool = (
		kind == "MOVE" or (kind == "SCHEME" and str(params.get("mode", "")) == "REGION")
	)
	if not aims_at_region:
		return ""
	var region_id: String = str(params.get("region_id", ""))
	if (world["regions"] as Dictionary).get(region_id) == null:
		return ""  # la regione sconosciuta la dice gia' il check del verbo
	return why_not_reached(asset_id, region_id, "non arriva li'")


## **La carta arriva li'?** Il bersaglio a segni, letto su una Regione sola
## (D-274). Estratto perche' adesso lo chiedono in tre: il controllo del verbo,
## il posto dove cadono i segni stampati (D-284) e il menu che quei posti li
## offre.
func card_reaches(asset_id: String, region_id: String) -> bool:
	return why_not_reached(asset_id, region_id, "") == ""


## Perche' non ci arriva, detto com'e' giusto dirlo: **un segno vietato e un
## segno mancante sono due rifiuti diversi**, e chi legge deve poterli
## distinguere. Torna "" quando la carta ci arriva.
func why_not_reached(asset_id: String, region_id: String, doing: String) -> String:
	var card: Variant = data.assets.get(asset_id)
	if card == null:
		return "carta sconosciuta"
	var target: Dictionary = (
		((card as Dictionary).get("physical", {}) as Dictionary).get("target", {}) as Dictionary
	)
	var region: Variant = (world["regions"] as Dictionary).get(region_id)
	if region == null:
		return "luogo sconosciuto"
	var alive: Array = (region as Dictionary).get("tags", []) as Array
	var title: String = str((card as Dictionary).get("title", asset_id))
	var place: String = str(data.regions.get(region_id, {}).get("name", region_id))
	var said: String = doing if doing != "" else "non arriva li'"
	for tag in target.get("forbidden_tag", []):
		if alive.has(str(tag)):
			return "«%s» %s: %s porta un segno che la carta vieta" % [title, said, place]
	var wanted: Array = target.get("any_tag", []) as Array
	if wanted.is_empty():
		return ""
	for tag in wanted:
		if alive.has(str(tag)):
			return ""
	return "«%s» %s: il bersaglio si dice a segni, e %s non ne porta nessuno" % [
		title, said, place
	]


## **I posti dove i segni di questa meta' possono cadere**, o vuoto se non serve
## sceglierne uno — la meta' non posa segni di Regione, oppure il verbo la
## Regione la nomina gia' (D-284).
##
## Sta qui e non nei due cervelli perche' la domanda e' una sola — *dove finisce
## quello che la carta dice di lasciare* — e due copie sono due posti dove
## smettere di essere d'accordo.
func places_for_face(asset_id: String, face_action: int) -> Array:
	var card: Variant = data.assets.get(asset_id)
	if card == null or face_action < 0:
		return []
	var printed: Array = (
		((card as Dictionary).get("physical", {}) as Dictionary).get("actions", []) as Array
	)
	if face_action >= printed.size():
		return []
	var face: Dictionary = printed[face_action] as Dictionary
	var wants_a_place: bool = false
	for field in ["puts_tag", "clears_tag"]:
		for tag in face.get(field, []):
			var known: Variant = data.tags.get(str(tag))
			if known == null:
				continue
			var scopes: Array = (known as Dictionary).get("scope", []) as Array
			if scopes.has("REGION") and not scopes.has("GLOBAL"):
				wants_a_place = true
	if not wants_a_place:
		return []
	return places_for_card(asset_id)


## **I posti che la carta raggiunge adesso**, in ordine di tavolo. Sono le
## Regioni dove i suoi segni stampati possono cadere: il bersaglio e' sulla
## faccia, e al tavolo si punta il dito li' (D-284).
func places_for_card(asset_id: String) -> Array:
	var out: Array = []
	var card: Variant = data.assets.get(asset_id)
	if card == null:
		return out
	var target: Dictionary = (
		((card as Dictionary).get("physical", {}) as Dictionary).get("target", {}) as Dictionary
	)
	if str(target.get("scope", "")) != "REGION":
		return out
	for region_id in world["regions"]:
		if card_reaches(asset_id, str(region_id)):
			out.append(str(region_id))
	return out


func _play_asset_card(
	entity_id: String, params: Dictionary, source: Dictionary
) -> Dictionary:
	var request: Dictionary = _card_request(entity_id, params)
	if request.has("error"):
		return _error("PLAY_CARD", str(request["error"]))
	var kind: String = str(request["kind"])
	var inner: Dictionary = request["params"]
	var outcome: Dictionary = {}
	match kind:
		"ACQUIRE":
			outcome = _acquire(entity_id, inner, source)
		"MOVE":
			outcome = _move(entity_id, inner, source)
		"INFLUENCE":
			outcome = _influence(entity_id, inner, source)
		"FORGE":
			outcome = _forge(entity_id, inner, source)
		"SCHEME":
			outcome = _scheme(entity_id, inner, source)
		"CLAIM":
			outcome = _claim(entity_id, inner, source)
		_:
			return _error("PLAY_CARD", "la carta porta un'azione che non esiste")
	if not bool(outcome.get("ok", false)):
		return outcome
	# **I segni stampati sull'Azione, posati** (D-283). Fino a qui `puts_tag` e
	# `clears_tag` erano inchiostro: 71 occorrenze su 33 segni diversi, e il
	# motore non ne eseguiva nessuna. Sono la ragione per cui le due Azioni di
	# una carta sono due scelte diverse — 29 carte su 48 stampano **lo stesso
	# verbo** due volte, e senza i segni le due meta' farebbero la stessa cosa.
	var where: Dictionary = inner.duplicate()
	if str(where.get("region_id", "")) == "":
		where["region_id"] = str(request.get("mark_region_id", ""))
	var marked: Array = _face_signs(
		entity_id, str(request["asset_id"]), int(request.get("face_action", -1)),
		where, source
	)
	if not marked.is_empty():
		var was: Array = outcome.get("effects", []) as Array
		was.append_array(marked)
		outcome["effects"] = was
	# La carta si spende: e' questo che rende la mano una scelta e non una
	# scorta. Se l'azione l'ha gia' consumata come proprio scarto (D-188) qui
	# non c'e' piu' niente da spendere, e spenderla due volte sarebbe un Effetto
	# senza inverso.
	var spent: Array = []
	if (service.hand(entity_id) as Array).has(str(request["asset_id"])):
		spent = _discard(entity_id, str(request["asset_id"]), source)
	var effects: Array = (outcome.get("effects", []) as Array).duplicate()
	effects.append_array(spent)
	log.bullet("%s gioca «%s» per %s." % [
		_name(entity_id), _title(str(request["asset_id"])), kind
	])
	# **La Risonanza** ([D-257](DECISIONS.md#d-257)): il mondo risponde, e non si
	# sceglie. E' la regola che il committente ha messo al centro della direzione
	# fisica — *ogni Azione ha una reazione* — ed e' l'unica riga di questo file
	# che il tavolo puo' leggere sulla carta invece che dedurla.
	effects.append_array(_resonance(entity_id, str(request["asset_id"]), inner, source, effects))
	var info: Dictionary = (outcome.get("info", {}) as Dictionary).duplicate()
	info["asset_id"] = str(request["asset_id"])
	info["kind"] = kind
	return _ok("PLAY_CARD", effects, info)


## La reazione del mondo alla carta appena giocata.
##
## Sulla carta c'e' scritto **quale Tema si scalda**; qui si traduce in quello
## che il mondo sa fare: sale la questione **piu' calda di quel Tema fra quelle
## in gioco**. Non tutte — alzarle tutte sarebbe una carta che apre tre Consigli
## — e non una a caso: la piu' vicina alla soglia, perche' il Calore che si
## sente e' quello che avvicina una decisione.
##
## Una Cronaca che non ha nessuna questione di quel Tema non scalda niente, e va
## bene: e' la stessa regola degli `on_commit_effects` da [D-106](#d-106) — il
## mestiere della carta parla solo dove ha di che parlare.
## **I segni che l'Azione stampata posa e toglie** (D-283, passo 1 del brief).
##
## Ogni segno va dove il dizionario dice che vive (D-259): GLOBAL sul mondo,
## REGION sulla Regione che l'azione ha nominato, ENTITY sulla casa che ha
## nominato. **Un segno che non trova il proprio soggetto non si posa altrove**
## — si conta e basta: metterlo dove capita sarebbe scrivere sul tavolo una
## cosa che al tavolo nessuno saprebbe dove mettere. Quanti restano fuori lo
## dice `run_mark_probe.gd`, ed e' il lavoro della fase dopo.
func _face_signs(
	entity_id: String, asset_id: String, face_action: int,
	played: Dictionary, source: Dictionary
) -> Array:
	if face_action < 0:
		return []
	var card: Variant = data.assets.get(asset_id)
	if card == null:
		return []
	var printed: Array = (
		((card as Dictionary).get("physical", {}) as Dictionary).get("actions", []) as Array
	)
	if face_action >= printed.size():
		return []
	var face: Dictionary = printed[face_action] as Dictionary
	var region_id: String = str(played.get("region_id", ""))
	var other_id: String = str(played.get("target_entity_id", ""))
	# **Il segno stampato si firma**, come la Risonanza (D-030): la sorgente
	# dice `face_action` e nomina la carta, cosi' il verbale — e la sonda —
	# distinguono cio' che ha scritto **l'Azione stampata** da cio' che ha
	# scritto il verbo. Senza la firma la prima stesura della sonda contava
	# insieme i due, e diceva 242 dove i segni della faccia erano 114.
	var mine: Dictionary = Effect.source(
		"face_action", asset_id, entity_id,
		int(source.get("act", 0)), int(source.get("round", 0)),
		int(world["effect_sequence"])
	)
	var applied: Array = []
	for pair in [["puts_tag", true], ["clears_tag", false]]:
		var field: String = str((pair as Array)[0])
		var puts: bool = bool((pair as Array)[1])
		for tag in face.get(field, []):
			var effect: Dictionary = _sign_effect(
				str(tag), puts, entity_id, region_id, other_id, mine
			)
			if effect.is_empty():
				continue
			applier.apply(effect)
			applied.append(effect)
	return applied


## L'Effetto di un segno, scelto dall'ambito che il dizionario gli da'. Vuoto
## quando quel segno non ha, in questa mossa, un soggetto su cui stare.
func _sign_effect(
	tag: String, puts: bool, entity_id: String, region_id: String,
	other_id: String, source: Dictionary
) -> Dictionary:
	var known: Variant = data.tags.get(tag)
	var scopes: Array = [] if known == null else (known as Dictionary).get("scope", []) as Array
	if scopes.has("GLOBAL"):
		return Effect.make(
			"SET_GLOBAL_TAG" if puts else "REMOVE_GLOBAL_TAG",
			"global", "", {"tag": tag}, source
		)
	if scopes.has("REGION"):
		if region_id == "":
			return {}
		return Effect.make(
			"SET_REGION_TAG" if puts else "REMOVE_REGION_TAG",
			"region", region_id, {"tag": tag}, source
		)
	if scopes.has("ENTITY"):
		# La casa nominata dall'azione se c'e'; altrimenti chi ha giocato, che
		# e' l'unica altra casa che quella mossa sta toccando di sicuro.
		var who: String = other_id if other_id != "" else entity_id
		return Effect.make(
			"SET_ENTITY_TAG" if puts else "REMOVE_ENTITY_TAG",
			"entity", who, {"tag": tag}, source
		)
	return {}


func _resonance(
	entity_id: String, asset_id: String, played: Dictionary, source: Dictionary,
	done: Array
) -> Array:
	var card: Variant = data.assets.get(asset_id)
	if card == null:
		return []
	var face: Dictionary = (card as Dictionary).get("physical", {}) as Dictionary
	var echo: Dictionary = face.get("resonance", {}) as Dictionary
	if echo.is_empty():
		return []
	# **La Risonanza si firma.** La sorgente di un'azione dice «ACT_PLAY_CARD» e
	# nient'altro: chi legge il verbale non sa distinguere quello che il
	# giocatore ha scelto da quello che il mondo ha risposto, e la prima stesura
	# della sonda ha contato **zero Risonanze su venti anni** mentre avvenivano —
	# muta invece che rossa, la stessa trappola di D-254. Una reazione che non si
	# puo' nominare non e' nemmeno raccontabile, e questo gioco vuole raccontarsi.
	var mine: Dictionary = Effect.source(
		"resonance", asset_id, entity_id,
		int(source.get("act", 0)), int(source.get("round", 0)),
		int(world["effect_sequence"])
	)
	var target_region: String = str(played.get("region_id", ""))
	var heat: int = int(echo.get("heat", 1))
	# La parte aggravata: se il bersaglio porta gia' il segno che la carta teme,
	# la reazione e' peggiore, e lascia qualcosa.
	var aggravated: bool = false
	var watched: String = str(echo.get("if_target_tag", ""))
	if watched != "" and _carries(played, entity_id, watched):
		aggravated = true
		heat += int(echo.get("extra_heat", 0))
	var effects: Array = []
	# **Il mazzetto del Tema si scalda per primo** (D-261, decisione del
	# committente): la Risonanza fa cadere sul mazzetto del suo Tema un gettone
	# **coperto** — puo' valere 0, 1 o 2, pescato dal sacchetto che la
	# Chronicle dichiara — e il Calore scritto sulla carta dice **quanti**
	# gettoni cadono, aggravata compresa. Il tavolo vede i gettoni cadere, non
	# quanto valgono: si girano a fine Atto, e il mazzetto piu' alto apre il
	# Consiglio. Il ponte sulle Tensioni qui sotto resta: finche' le Domande
	# vivono sulle questioni, il Calore deve anche avvicinarle. Cadra' quando
	# le Domande fisiche si pescheranno dal Tema (ISSUES 69), non prima.
	var theme_id: String = str(echo.get("theme", ""))
	if theme_id != "" and heat > 0:
		var bag: Array = (_chronicle.get("theme_tokens", {}) as Dictionary).get("covered", []) as Array
		for _i in range(heat):
			# Senza sacchetto il gettone vale 1 in chiaro: coprire ha senso
			# solo se il valore varia — la stessa regola di `tension_tokens`.
			#
			# **Il sacchetto dei Temi ha un dado suo** (lezione di D-150): se
			# pescasse dal caso condiviso, accendere i mazzetti riscriverebbe
			# ogni storia a seme fisso — mazzi, deriva e domande comprese. Il
			# dado deriva dal seme e dalla sequenza degli Effetti, cosi' e'
			# riproducibile anche riprendendo un salvataggio a meta' anno.
			var worth: int = 1
			if not bag.is_empty():
				var draw: RefCounted = RngService.new(
					int(world["rng_seed"]) * 43 + int(world["effect_sequence"]) * 7 + 19
				)
				worth = int(bag[draw.range_int(0, bag.size() - 1)])
			var dropped: Dictionary = applier.apply(Effect.make(
				"ADJUST_THEME_HEAT", "theme", theme_id, {"delta": worth}, mine
			))
			if not dropped.is_empty():
				effects.append(dropped)
			# Anche il gettone bianco **e' caduto**: il mazzetto lo mostra, e
			# mezzo senso di coprire sta proprio li'.
			world["theme_tokens"] = world.get("theme_tokens", {}) as Dictionary
			world["theme_tokens"][theme_id] = int((world["theme_tokens"] as Dictionary).get(theme_id, 0)) + 1
			if not bag.is_empty():
				log.bullet("  Un gettone coperto cade sul mazzetto di %s." % _theme_title(theme_id))
		# **La carta si gira a due segnalini** (D-261): quando il mazzetto
		# raggiunge il conto dichiarato, la prima carta si scopre e il tavolo
		# sa quale Tensione si va scaldando li'. Una volta girata resta il
		# fronte del Tema: i gettoni dopo non girano altro.
		if tensions.theme_front(theme_id) == "" \
				and tensions.theme_token_count(theme_id) >= tensions.reveal_at():
			tensions.flip_theme_front(theme_id)
	# **SI ACCENDE QUANDO** (D-330): la questione che prende il Calore e' quella
	# che **quel gesto** riguarda, non piu' quella piu' vicina alla soglia. La
	# regola sta stampata sulla faccia della Tensione, e si legge al tavolo
	# guardando cosa e' appena successo alla mappa. Il ponte resta come ripiego
	# dichiarato: se nessuna questione del Tema riconosce il gesto, il Calore
	# torna alla piu' vicina alla soglia, che e' il comportamento di D-261.
	# **Si scaldano tutte** (D-332, decisione del committente): *«un evento puo'
	# avere conseguenze su piu' temi»*. Ogni questione la cui faccia riconosce il
	# gesto prende il Calore, non piu' solo la piu' matura fra loro. Nessuna che
	# lo riconosca: torna il ponte, per una sola.
	var woken: Array = _tensions_that_wake(done)
	if woken.is_empty():
		var fallback: String = _hottest_of_theme(theme_id)
		if fallback != "":
			woken = [fallback]
	if heat > 0:
		for tension_id in woken:
			var applied: Dictionary = applier.apply(Effect.make(
				"ADJUST_TENSION", "tension", str(tension_id), {"delta": heat}, mine
			))
			effects.append(applied)
	if aggravated and target_region != "" and str(echo.get("extra_tag", "")) != "":
		var marked: Dictionary = applier.apply(Effect.make(
			"SET_REGION_TAG", "region", target_region,
			{"tag": str(echo["extra_tag"])}, mine
		))
		effects.append(marked)
	if not effects.is_empty():
		log.bullet("Il mondo risponde: %s" % str(echo.get("text", "")))
	return effects


## La questione piu' vicina alla soglia, fra quelle di questo Tema che stanno in
## gioco **e non hanno ancora chiesto**. A parita' vince la prima in ordine di
## id, perche' un pareggio sciolto dall'ordine di un Dictionary non e'
## riproducibile.
##
## **La Risonanza avvicina, non decide.** Non tocca una questione gia' arrivata
## alla soglia — quella non si scalda, si risponde — e non le da' mai il punto
## che la apre: il Consiglio lo convoca qualcuno, con un'azione che ha scelto.
##
## E' una regola di disegno, non una limatura per far tornare un numero — e va
## detto perche' **il numero non e' tornato**: col tavolo uniforme l'anno peggiore
## dei cento passa da otto Consigli a nove lo stesso, con o senza questa riga.
## Resta perche' senza di lei la reazione del mondo sarebbe il modo piu'
## economico di convocare un Consiglio, cioe' l'esatto contrario di una reazione.
## Il nove e' scritto in [D-257](DECISIONS.md#d-257): e' il prezzo dichiarato di
## un mondo che risponde.
## **La questione che quel gesto sveglia** (D-330, la casella «SI ACCENDE
## QUANDO» disegnata dal committente).
##
## Fino a qui il Calore andava alla questione piu' vicina alla soglia del Tema:
## un ponte che il codice dichiarava provvisorio gia' in D-261. Adesso ogni
## Tensione stampa **cosa la accende** — un segno posato, una Pietra costruita,
## un controllo cambiato, una Presenza tolta — e il Calore va a quella che il
## gesto appena fatto riguarda davvero.
##
## **La regola guarda il gesto, non il Tema della carta** (D-331). La prima
## stesura cercava solo fra le questioni del Tema che la carta scalda, e la
## carta disegnata dal committente non lo chiede: dice *«questa Tensione riceve
## Calore quando **una carta** aggiunge #conteso...»*, senza nominare il Tema di
## chi la gioca. Col filtro, tre carte su quaranta — la Banda Armata, le Braccia
## per il Raccolto, il Pedaggio — non erano riconosciute da **nessuna** questione
## del loro Tema mentre lo erano da sei, due e cinque di altri: il loro gesto
## non veniva mai letto da chi lo riguardava.
##
## **E si scaldano tutte** (D-332, decisione del committente): *«un evento puo'
## avere conseguenze su piu' tempi»*. Fino alla 0.1.294 fra le questioni che
## riconoscevano il gesto ne vinceva una sola, la piu' vicina alla soglia — e la
## faccia della carta prometteva una cosa che il motore manteneva solo se quella
## questione era la piu' matura. Adesso la promessa e' intera: se c'e' scritto
## che ti accendi quando succede questo, ti accendi.
##
## Il Tema della carta continua a decidere **su quale mazzetto cadono i
## gettoni**, cioe' quale Consiglio si apre: quello e' l'eco del gesto, e sta
## sulla carta che hai in mano. Qui si decide **quale domanda e' matura**, e
## quello lo dice il mondo.
##
## Nessuna che riconosca il gesto: torna vuoto e il chiamante ricade sul ponte,
## per una sola questione.
func _tensions_that_wake(done: Array) -> Array:
	var out: Array = []
	if done.is_empty():
		return out
	var ids: Array = (world["tensions"] as Dictionary).keys()
	ids.sort()
	for tension_id in ids:
		var definition: Variant = data.tensions.get(str(tension_id))
		if definition == null:
			continue
		var card: Dictionary = definition as Dictionary
		var rules: Array = card.get("heats_when", []) as Array
		if rules.is_empty():
			continue
		var wakes: bool = false
		for rule in rules:
			if _rule_matches(rule as Dictionary, done):
				wakes = true
				break
		if not wakes:
			continue
		# La soglia si guarda come nel ponte, e adesso **per ognuna**: una
		# questione gia' a un passo non si spinge oltre con una Risonanza
		# (D-257, «la Risonanza avvicina, non decide»). E' la riga che impedisce
		# a «si scaldano tutte» di aprire Consigli da sola.
		if int(card["threshold"]) - tensions.value(str(tension_id)) <= 1:
			continue
		out.append(str(tension_id))
	return out


## Una riga di «SI ACCENDE QUANDO» contro quello che l'Azione ha fatto.
##
## I verbi sono chiusi apposta, e sono quelli che si vedono sul tavolo: un segno
## posato o tolto, una Pietra costruita, il controllo che cambia, una Presenza
## che arriva o che se ne va. `on_region_with` e' il filtro del luogo — «su una
## Regione con #campo o #granaio» — e senza di lui la riga vale ovunque.
##
## **`adds_presence` e' arrivato dopo, e per una misura** (D-335). Contando cosa
## le Azioni fanno davvero in vent'anni, il gesto piu' frequente sulla mappa e'
## portare una Presenza in una Regione — **175 volte**, contro le 58 di toglierla
## e le 6 di posare un segno di Regione — e non c'era nessun verbo che lo
## nominasse. Le righe potevano guardare solo quello che quasi non succede.
func _rule_matches(rule: Dictionary, done: Array) -> bool:
	var puts: Array = rule.get("puts_tag", []) as Array
	var clears: Array = rule.get("clears_tag", []) as Array
	var builds: Array = rule.get("builds", []) as Array
	var control: bool = bool(rule.get("takes_control", false))
	var leaves: bool = bool(rule.get("removes_presence", false))
	var arrives: bool = bool(rule.get("adds_presence", false))
	if puts.is_empty() and clears.is_empty() and builds.is_empty() \
			and not control and not leaves and not arrives:
		return false
	var where: Array = rule.get("on_region_with", []) as Array
	for entry in done:
		var effect: Dictionary = entry as Dictionary
		var kind: String = str(effect.get("type", ""))
		var payload: Dictionary = effect.get("payload", {}) as Dictionary
		var target: Dictionary = effect.get("target", {}) as Dictionary
		var hit: bool = false
		match kind:
			"SET_REGION_TAG", "SET_GLOBAL_TAG", "SET_ENTITY_TAG", "ADD_SCAR":
				hit = puts.has(str(payload.get("tag", "")))
			"REMOVE_REGION_TAG", "REMOVE_GLOBAL_TAG", "REMOVE_ENTITY_TAG", "REMOVE_SCAR":
				hit = clears.has(str(payload.get("tag", "")))
			"BUILD_STRUCTURE":
				hit = builds.has(str(payload.get("structure_type", "")))
			"SET_CONTROL":
				hit = control
			"REMOVE_PRESENCE":
				hit = leaves
			"ADD_PRESENCE":
				hit = arrives
		if not hit:
			continue
		if where.is_empty():
			return true
		# Il filtro del luogo guarda la Regione che l'Effetto ha toccato — e
		# **una Presenza non ha come bersaglio la Regione, ha la casata** (D-335):
		# il posto sta nel payload, sotto `region_id`. Finche' questa riga
		# guardava solo il bersaglio, ogni riga di Presenza con un filtro di luogo
		# era muta per costruzione, compresa la quarta riga de «I Recinti» —
		# *«toglie una Presenza da una terra da coltivo»* — che il committente ha
		# disegnato a mano e che non poteva accendersi mai.
		var region_id: String = str(payload.get("region_id", ""))
		if region_id == "":
			if str(target.get("kind", "")) != "region":
				continue
			region_id = str(target.get("id", ""))
		var region: Dictionary = (world["regions"] as Dictionary).get(
			region_id, {}
		) as Dictionary
		for tag in where:
			if (region.get("tags", []) as Array).has(str(tag)):
				return true
	return false


func _hottest_of_theme(theme_id: String) -> String:
	if theme_id == "":
		return ""
	var ids: Array = (world["tensions"] as Dictionary).keys()
	ids.sort()
	var best: String = ""
	var best_gap: int = 1 << 30
	for tension_id in ids:
		var definition: Variant = data.tensions.get(str(tension_id))
		if definition == null:
			continue
		if str((definition as Dictionary).get("theme", "")) != theme_id:
			continue
		var gap: int = int((definition as Dictionary)["threshold"]) - tensions.value(str(tension_id))
		if gap <= 1:
			continue
		if gap < best_gap:
			best_gap = gap
			best = str(tension_id)
	return best


## Se il bersaglio porta quel segno — **e bersaglio vuol dire quello che l'azione
## ha davvero toccato** ([D-258](DECISIONS.md#d-258)).
##
## La prima stesura cercava solo in una Regione, e delle sei azioni **soltanto
## MUOVERE e TRAMARE portano una Regione nei parametri**: per le altre quattro il
## posto dove cercare era vuoto, e la meta' aggravata di quelle carte non poteva
## scattare nemmeno una volta. Misurato: **0 su 163 Risonanze**. Non erano segni
## rari, era una domanda fatta al vuoto.
##
## Quindi si guarda dove il verbo arriva: la Regione se ne nomina una, l'altra
## casa se ne nomina una, chi gioca, e **il mondo** — perche' «se la questione e'
## gia' rimasta aperta una volta» e' una cosa che una carta puo' legittimamente
## temere, e non sta scritta ne' su una Regione ne' su una casa.
func _carries(played: Dictionary, entity_id: String, tag: String) -> bool:
	var region_id: String = str(played.get("region_id", ""))
	if region_id != "":
		var region: Dictionary = (world["regions"] as Dictionary).get(region_id, {}) as Dictionary
		if (region.get("tags", []) as Array).has(tag):
			return true
		for scar in world["scars"]:
			var record: Dictionary = scar as Dictionary
			if str(record.get("region_id", "")) == region_id and str(record.get("tag", "")) == tag:
				return true
	var other_id: String = str(played.get("target_entity_id", ""))
	if other_id != "":
		var other: Dictionary = (world["entities"] as Dictionary).get(other_id, {}) as Dictionary
		if (other.get("tags", []) as Array).has(tag):
			return true
	var seat: Dictionary = (world["entities"] as Dictionary).get(entity_id, {}) as Dictionary
	if (seat.get("tags", []) as Array).has(tag):
		return true
	return (world.get("global_tags", []) as Array).has(tag)


func _discard(entity_id: String, asset_id: String, source: Dictionary) -> Array:
	if asset_id == "":
		return []
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


func _theme_title(theme_id: String) -> String:
	var theme: Variant = data.themes.get(theme_id)
	return theme_id if theme == null else str((theme as Dictionary)["title"])


func _region(region_id: String) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


func _ok(template: String, effects: Array, info: Dictionary) -> Dictionary:
	return {"ok": true, "error": "", "template": template, "effects": effects, "info": info}


func _error(template: String, message: String) -> Dictionary:
	return {"ok": false, "error": message, "template": template, "effects": [], "info": {}}
