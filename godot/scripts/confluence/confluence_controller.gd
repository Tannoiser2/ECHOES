extends RefCounted
## The Confluence sequence A-K (§12.2).
##
## A state machine, not a script: open() runs A-C, the table then declares
## stances (D) and commits (E), and resolve() runs F-K in one atomic pass. The
## same object drives a headless simulation and, in 0.1, the Confluence Board.
##
## Resolution order inside resolve() - fixed, and documented in
## docs/RULES_V0_2.md so a Strategy swap cannot quietly change it:
##   1. World Factor roll                      (F)
##   2. Resolution maths                       (G)
##   3. Tension outcome (set to 1 / -2)        (H)
##   4. on_commit costs of the Assets spent    (H)
##   5. Outcome Consequences                   (H)
##   6. Cost / Decisive-bonus Consequence      (H)
##   7. Qualified Condition clause             (H)
##   8. Asset disposition                      (I)
##   9. Echo Check                             (J)
##  10. Ripple                                 (K)

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const ConsequenceCompiler := preload("res://scripts/chronicle/consequence_compiler.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")
const EchoRecorder := preload("res://scripts/chronicle/echo_recorder.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")
const NarrativeText := preload("res://scripts/chronicle/narrative_text.gd")
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

const STANCES: Array = ["SUPPORT", "OPPOSE", "CONDITION", "ABSTAIN"]

signal step_changed(step: String, context: Dictionary)

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var rng: RefCounted
var log: RefCounted
var tensions: RefCounted

var service: RefCounted
var conditions: RefCounted
var compiler: RefCounted
var recorder: RefCounted
var narrative: RefCounted

var current: Dictionary = {}
var last_error: String = ""

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
	conditions = ConditionEvaluator.new(p_world, p_data)
	compiler = ConsequenceCompiler.new(p_data, p_world)
	narrative = NarrativeText.new(p_world, p_data, service)
	recorder = EchoRecorder.new(p_world, p_data, p_applier, p_log)
	recorder.narrative = narrative
	_chronicle = data.chronicles[world["chronicle_id"]]


func is_open() -> bool:
	return not current.is_empty()


# --- A, B, C ---------------------------------------------------------------

## Steps A (Trigger), B (Question) and the proponent half of C.
## `trigger` is {kind: THRESHOLD|CLAIM|ECHO_CARD, entity_id: ""}.
func open(tension_id: String, trigger: Dictionary) -> Dictionary:
	last_error = ""
	var template: Dictionary = data.confluence_template_for(tension_id)
	if template.is_empty():
		last_error = "nessun template di Confluence per '%s'" % tension_id
		return {}

	var index: int = int(world["confluence_count"])
	var proponent: String = str(trigger.get("entity_id", ""))
	if proponent == "" or not world["entities"].has(proponent):
		proponent = service.determine_proponent(tension_id, narrative.focus_region(tension_id))

	var question_id: String = _select_question(template, proponent, tension_id)
	if question_id == "":
		last_error = "nessuna domanda valida nel template '%s'" % template["id"]
		return {}

	current = {
		"confluence_id": "%s#%d" % [str(template["id"]), index + 1],
		"index": index,
		"template_id": str(template["id"]),
		"tension_id": tension_id,
		"trigger": trigger.duplicate(true),
		"question_id": question_id,
		"proponent": proponent,
		# Resolved once, at A, so every sentence in this Confluence names the same
		# Region and the same rival even if the world moves underneath it (H).
		"text_bindings": narrative.bindings_for(tension_id, proponent),
		# Fissata qui per la stessa ragione del testo: il peso di chi sta nella
		# Regione di cui si discute (D-154) si misura sulla Regione dichiarata
		# ad A, non su quella che il mondo avra' a G.
		"focus_region": narrative.focus_region(tension_id),
		"proposition_id": "",
		"stances": {},
		"commits": {},
		"world_factor": 0,
		"die": 0,
		"participants": [proponent],
		"step": "PROPOSITION",
		"act": int(world["act"]),
		"round": int(world["round"]),
	}

	log.section("CONFLUENCE %s - %s" % [current["confluence_id"], str(template["title"])])
	log.bullet("A. Trigger: %s su %s" % [str(trigger.get("kind", "THRESHOLD")), _tension_name(tension_id)])
	log.bullet("B. Domanda: %s" % say(_question_text(template, question_id)))
	# Chi ha aperto questo Consiglio si fara da parte al prossimo sulla stessa
	# domanda, se ci sara qualcun altro nella Regione di cui si discute (D-051).
	if not world.has("last_proponent"):
		world["last_proponent"] = {}
	world["last_proponent"][tension_id] = proponent
	log.bullet("C. Proponente: %s" % _name(proponent))
	step_changed.emit("QUESTION", current)
	return current


## §12.2 B: which questions the state of the Tension actually raises.
func available_questions() -> Array:
	if current.is_empty():
		return []
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	return _eligible_questions(template, str(current["proponent"]), str(current["tension_id"]))


## Step B: the proponent may pick any question the Tension has opened. Defaults
## to the sharpest one; a scripted plan or the 0.1 UI can pick another.
func set_question(question_id: String) -> bool:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return false
	for question in available_questions():
		if str(question["id"]) == question_id:
			current["question_id"] = question_id
			current["proposition_id"] = ""
			log.bullet("B. Domanda scelta: %s" % say(str(question["text"])))
			return true
	last_error = "domanda '%s' non disponibile" % question_id
	return false


## §12.2 B. Le domande che lo stato della Tensione apre davvero, **meno quelle
## che questa Chronicle ha gia' messo ai voti** finche' ne resta una nuova
## (D-061).
##
## Senza questo filtro il Debito della seconda saga poneva 94 volte su 94 la
## stessa domanda in quaranta Chronicle, e la meta' delle proposte scritte non
## veniva mai votata da nessuno: contenuto che esiste nei dati e non esiste al
## tavolo (D-035). Il filtro cade quando tutto e' stato chiesto - un Consiglio
## che ha esaurito le sue domande torna alla piu' affilata, come prima.
func _eligible_questions(template: Dictionary, proponent: String, tension_id: String) -> Array:
	var context: Dictionary = {"proponent": proponent, "tension": tension_id}
	var out: Array = []
	for question in template["questions"]:
		if conditions.all_hold(question["eligibility"], context):
			out.append(question)
	var asked: Array = _asked(tension_id)
	if asked.is_empty():
		return out
	var fresh: Array = []
	for question in out:
		if not asked.has(str((question as Dictionary)["id"])):
			fresh.append(question)
	# Niente ripiego sulle domande gia' poste: alla frequenza dei Consigli di
	# oggi il ripiego rimetteva ai voti la stessa domanda nello stesso anno -
	# la saga dell'812 ha nominato due eredi nel 1827 (D-077). Una domanda
	# decisa resta decisa: se non ne restano, il Consiglio non si apre, come
	# gia' accade quando mancano le proposte (D-061).
	return fresh


## Se questa Tensione ha ancora una domanda mai posta quest'anno. I trigger lo
## chiedono prima di aprire - e la policy prima di spendere un Claim - cosi' un
## Consiglio senza niente di nuovo da decidere non si apre e non spreca niente
## (D-077). L'eleggibilita' qui non conta: e' lo stato del mondo a deciderla al
## momento dell'apertura, l'esaurimento invece e' definitivo per l'anno.
func has_fresh_question(tension_id: String) -> bool:
	var template: Dictionary = data.confluence_template_for(tension_id)
	if template.is_empty():
		return false
	var asked: Array = _asked(tension_id)
	for question in template["questions"]:
		if not asked.has(str((question as Dictionary)["id"])):
			return true
	return false


## La prova vera: **questa domanda si aprirebbe adesso?**
##
## `has_fresh_question` risponde a una domanda piu' debole — «resta un quesito
## mai posto?» — e le due cose divergono, perche' un quesito puo' essere fresco
## e **non idoneo**: il template lo apre solo se la Tensione e' abbastanza alta o
## se il mondo porta un certo segno. Finche' il Consiglio si apriva a soglia la
## differenza non si vedeva, perche' arrivare a soglia rendeva idoneo quasi
## tutto; col Consiglio di fine Atto (D-214) si e' vista subito: su cento anni,
## tre chiudevano con meno di un Consiglio per Atto, e uno ne rifiutava otto di
## fila sullo stesso template.
func can_open(tension_id: String) -> bool:
	var template: Dictionary = data.confluence_template_for(tension_id)
	if template.is_empty():
		return false
	var proponent: String = service.determine_proponent(
		tension_id, narrative.focus_region(tension_id)
	)
	return _select_question(template, proponent, tension_id) != ""


func _asked(tension_id: String) -> Array:
	return (world.get("questions_asked", {}) as Dictionary).get(tension_id, []) as Array


func _mark_asked(tension_id: String, question_id: String) -> void:
	if question_id == "":
		return
	if not world.has("questions_asked"):
		world["questions_asked"] = {}
	var asked: Array = (world["questions_asked"] as Dictionary).get(tension_id, [])
	if not asked.has(question_id):
		asked.append(question_id)
	world["questions_asked"][tension_id] = asked


func _select_question(template: Dictionary, proponent: String, tension_id: String) -> String:
	# Deterministic default: the *last* eligible question in definition order.
	# Later questions are the sharper ones, gated on a hotter Tension, so a
	# Tension at breaking point asks the harder question by default.
	var eligible: Array = _eligible_questions(template, proponent, tension_id)
	if eligible.is_empty():
		return ""
	return str(eligible[eligible.size() - 1]["id"])


## Propositions the proponent may legally choose (C).
func available_propositions() -> Array:
	if current.is_empty():
		return []
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	var context: Dictionary = effect_context()
	var out: Array = []
	for proposition in template["propositions"]:
		if str(proposition["question_id"]) != str(current["question_id"]):
			continue
		if conditions.all_hold(proposition["eligibility"], context):
			out.append(proposition)
	return out


## Step C: the proponent picks one of the structured options (appendix A9 -
## free text returns with the Narrative Model in 0.4).
func set_proposition(proposition_id: String) -> bool:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return false
	for proposition in available_propositions():
		if str(proposition["id"]) == proposition_id:
			current["proposition_id"] = proposition_id
			current["step"] = "STANCE"
			log.bullet("C. Proposta: %s" % say(str(proposition["text"])))
			step_changed.emit("PROPOSITION", current)
			return true
	last_error = "proposta '%s' non disponibile" % proposition_id
	return false


# --- D: Stance -------------------------------------------------------------

## §12.2 D: public, in turn order from the proponent's left.
func stance_order() -> Array:
	return service.stance_order(str(current["proponent"])) if is_open() else []


func declare_stance(entity_id: String, stance: String, clause_id: String = "") -> bool:
	last_error = ""
	if current.is_empty() or str(current["step"]) not in ["STANCE", "COMMIT"]:
		last_error = "non e il momento di dichiarare una posizione"
		return false
	if entity_id == str(current["proponent"]):
		last_error = "il proponente non dichiara una posizione"
		return false
	if not STANCES.has(stance):
		last_error = "posizione non valida '%s'" % stance
		return false

	var record: Dictionary = {"stance": stance}
	if stance == "CONDITION":
		var clause: Dictionary = _find_clause(clause_id)
		if clause.is_empty():
			last_error = "clausola '%s' non presente nel template" % clause_id
			return false
		record["clause_id"] = clause_id
		log.bullet("D. %s: Condition - %s" % [_name(entity_id), say(str(clause["text"]))])
	else:
		log.bullet("D. %s: %s" % [_name(entity_id), stance])

	current["stances"][entity_id] = record
	if stance != "ABSTAIN" and not (current["participants"] as Array).has(entity_id):
		current["participants"].append(entity_id)
	return true


func _find_clause(clause_id: String) -> Dictionary:
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	for clause in template["condition_clauses"]:
		if str(clause["id"]) == clause_id:
			return clause
	return {}


# --- D-bis: la pedina del prezzo (PZ-5, D-267) ------------------------------

## Il menu del prezzo: fra quali voci il fronte avverso puo' scegliere. Sono i
## pool del template - il costo se la proposta passa pagando, lo sfogo se cade.
func price_menu() -> Dictionary:
	if current.is_empty():
		return {"cost": [], "failure": []}
	var pools: Dictionary = (
		data.confluence_templates[str(current["template_id"])]["consequence_pools"]
	)
	return {
		"cost": (pools["cost"] as Array).duplicate(),
		"failure": (pools["failure"] as Array).duplicate(),
	}


## Chi parla per il fronte avverso: il primo seggio, nell'ordine delle
## dichiarazioni, che ha detto OPPOSE. E' informazione pubblica - la pedina si
## posa a posizioni dichiarate e **prima** degli impegni, che restano segreti:
## sceglierla su chi ha impegnato di piu' rivelerebbe gli impegni.
func first_opposer() -> String:
	if current.is_empty():
		return ""
	for entity_id in stance_order():
		if str((current["stances"] as Dictionary).get(str(entity_id), {}).get("stance", "")) == "OPPOSE":
			return str(entity_id)
	return ""


## La pedina del prezzo (D-267, parola del committente: «scegliendo dagli
## avversari i malus»): il fronte avverso dichiara prima del dado quale voce
## del menu paghera' chi vince - il costo se la proposta passa con un costo,
## lo sfogo se cade. Senza pedina decide il mondo: la prima voce del pool.
func place_price(entity_id: String, cost_id: String, failure_id: String) -> bool:
	last_error = ""
	if current.is_empty() or str(current["step"]) not in ["STANCE", "COMMIT"]:
		last_error = "non e' il momento di posare la pedina del prezzo"
		return false
	if entity_id == "" or entity_id != first_opposer():
		last_error = "la pedina del prezzo spetta al primo seggio del fronte avverso"
		return false
	var menu: Dictionary = price_menu()
	if cost_id != "" and not (menu["cost"] as Array).has(cost_id):
		last_error = "'%s' non e' nel menu del costo" % cost_id
		return false
	if failure_id != "" and not (menu["failure"] as Array).has(failure_id):
		last_error = "'%s' non e' nel menu dello sfogo" % failure_id
		return false
	current["price_pedina"] = {"by": entity_id, "cost": cost_id, "failure": failure_id}
	var said: PackedStringArray = PackedStringArray()
	if cost_id != "":
		said.append("se passa con un costo, %s" % _consequence_title(cost_id))
	if failure_id != "":
		said.append("se cade, %s" % _consequence_title(failure_id))
	if not said.is_empty():
		log.bullet("D. La pedina del prezzo - %s: %s." % [
			_name(entity_id), "; ".join(said)
		])
	return true


## Una voce sola dal pool (D-267): quella della pedina, o la prima. Il mondo
## decide solo quando il fronte avverso non ha posato niente.
func _priced(pool: Array, chosen: String) -> String:
	if pool.is_empty():
		return ""
	if chosen != "" and pool.has(chosen):
		return chosen
	return str(pool[0])


func _consequence_title(consequence_id: String) -> String:
	return str((data.consequences.get(consequence_id, {}) as Dictionary).get("title", consequence_id))


# --- E: Commit -------------------------------------------------------------

func max_commit_for(entity_id: String) -> int:
	if entity_id == str(current["proponent"]):
		return int(_chronicle["max_commit_assets"])
	var stance: String = str(current["stances"].get(entity_id, {}).get("stance", "ABSTAIN"))
	if stance == "CONDITION":
		return int(_chronicle["max_condition_commit_assets"])
	if stance == "ABSTAIN":
		return 0
	return int(_chronicle["max_commit_assets"])


## §12.2 E: secret in hotseat, revealed simultaneously. The engine takes the
## commits one at a time and only reveals them in the log at resolve().
func commit(entity_id: String, asset_ids: Array) -> bool:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return false
	var limit: int = max_commit_for(entity_id)
	if asset_ids.size() > limit:
		last_error = "%s puo impegnare al massimo %d Asset" % [entity_id, limit]
		return false

	# Multiset check: the same card cannot be spent twice.
	var available: Array = service.hand(entity_id)
	for asset_id in asset_ids:
		var index: int = available.find(str(asset_id))
		if index < 0:
			last_error = "%s non ha '%s' in mano" % [entity_id, asset_id]
			return false
		available.remove_at(index)

	current["commits"][entity_id] = asset_ids.duplicate()
	if not asset_ids.is_empty() and not (current["participants"] as Array).has(entity_id):
		current["participants"].append(entity_id)
	current["step"] = "RESOLVE"
	return true


# --- F to K ----------------------------------------------------------------

## `recovery` maps an opposing entity id to the Asset it keeps on a Failure.
func resolve(recovery: Dictionary = {}) -> Dictionary:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return {}
	if str(current["proposition_id"]) == "":
		last_error = "nessuna proposta scelta"
		return {}

	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	var tension_id: String = str(current["tension_id"])
	var source: Dictionary = Effect.source(
		"confluence",
		str(current["confluence_id"]),
		str(current["proponent"]),
		int(world["act"]),
		int(world["round"]),
		int(world["effect_sequence"])
	)

	# F. World Factor.
	var die: int = rng.roll_d6()
	var factor: int = ConfluenceResolution.world_factor(die)
	# ISSUES 24: i segni con un dente pesano sul mondo prima che sul tavolo.
	# Il dado resta il dado; è il World Factor che un mondo segnato piega.
	var bite: Dictionary = TagRules.council_world_factor(
		data, world, tension_id, str(current["proponent"])
	)
	factor += int(bite["delta"])
	current["die"] = die
	current["world_factor"] = factor

	# I fronti che valgono di più (D-125): il segno rinforza il fronte di chi
	# lo porta, ma solo se quel seggio ha messo almeno una carta sul tavolo -
	# un +1 dal nulla sarebbe un voto gratis. Il proponente sostiene sempre.
	var support_bonus: int = 0
	var oppose_bonus: int = 0
	var stance_titles: Array = []
	var fronts: Dictionary = {str(current["proponent"]): "SUPPORT"}
	for entity_id in current["stances"]:
		if str(entity_id) == str(current["proponent"]):
			continue
		fronts[str(entity_id)] = str(current["stances"][entity_id].get("stance", "ABSTAIN"))
	for entity_id in fronts:
		var seat: String = str(entity_id)
		var side: String = str(fronts[seat])
		if side != "SUPPORT" and side != "OPPOSE":
			continue
		if (current["commits"].get(seat, []) as Array).is_empty():
			continue
		var lean: Dictionary = TagRules.stance_bonus(data, world, seat, side)
		if int(lean["delta"]) != 0:
			if side == "SUPPORT":
				support_bonus += int(lean["delta"])
			else:
				oppose_bonus += int(lean["delta"])
			stance_titles.append_array(lean["titles"])

		# Il peso del legame (D-139): un alleato che ti sostiene e ci mette
		# del proprio parla piu' forte di uno sconosciuto.
		var bond: int = _bond_weight(seat, side)
		if bond > 0:
			support_bonus += bond
			stance_titles.append("%s parla da alleato (+%d)" % [_name(seat), bond])

		# Il peso della terra (D-154): chi la Regione a fuoco la tiene, o ci sta
		# in forze, parla piu' forte di chi ne discute da fuori.
		var ground: Dictionary = _focus_weight(seat, side)
		if int(ground["delta"]) > 0:
			if side == "SUPPORT":
				support_bonus += int(ground["delta"])
			else:
				oppose_bonus += int(ground["delta"])
			stance_titles.append(
				"%s %s (+%d)" % [_name(seat), str(ground["why"]), int(ground["delta"])]
			)

	# La regola anti-passivita' (PZ-5, D-267): se ogni seggio non proponente si
	# astiene, il silenzio avvantaggia chi propone. Un Consiglio dove nessuno
	# parla non e' neutro: la roadmap chiedeva che «se tutti si astengono,
	# succede qualcosa comunque», e delle tre vie (vantaggio al proponente,
	# Cicatrice automatica, Tema che resta caldo) questa e' quella che si legge
	# in un gesto solo al tavolo: silenzio-assenso. Numero nei dati, reversibile.
	var silence_bonus: int = int(
		(_chronicle.get("confluence_rules", {}) as Dictionary).get("silence_support_bonus", 0)
	)
	var table_is_silent: bool = true
	for entity_id in current["stances"]:
		if str(entity_id) == str(current["proponent"]):
			continue
		if str(current["stances"][entity_id].get("stance", "ABSTAIN")) != "ABSTAIN":
			table_is_silent = false
			break
	if silence_bonus > 0 and table_is_silent:
		support_bonus += silence_bonus

	# La soglia della Condition che si sposta (D-125), mai sotto 1.
	var condition_entities: Array = []
	for entity_id in current["stances"]:
		if str(current["stances"][entity_id].get("stance", "")) == "CONDITION":
			condition_entities.append(str(entity_id))
	var shifted: Dictionary = TagRules.condition_threshold_delta(data, world, condition_entities)
	var threshold: int = maxi(
		1, int(_chronicle["condition_qualified_threshold"]) + int(shifted["delta"])
	)

	# G. Resolution.
	var result: Dictionary = ConfluenceResolution.resolve(
		str(current["proponent"]),
		current["stances"],
		current["commits"],
		data.assets,
		service.relevant_families(tension_id),
		factor,
		threshold,
		support_bonus,
		oppose_bonus
	)
	_log_commitments()
	log.bullet("F. World Factor: 1d6 = %d -> %+d" % [die, factor])
	for title in bite["titles"]:
		log.bullet("  Il segno pesa sul Consiglio: %s." % str(title))
	for title in stance_titles:
		log.bullet("  Il segno pesa sul fronte: %s." % str(title))
	if silence_bonus > 0 and table_is_silent:
		log.bullet("  Il tavolo tace: il silenzio avvantaggia il proponente (+%d)." % silence_bonus)
	for title in shifted["titles"]:
		log.bullet("  Il segno sposta la soglia della Condition: %s." % str(title))
	# A qualified Condition is part of the margin (D-055), so it is part of the one
	# line a player reads to check the arithmetic - and an unqualified one is shown
	# too, crossed out of the sum, because "you spent two cards for nothing" is
	# exactly the thing that has to be visible.
	var condition: String = ""
	if int(result["condition_total"]) > 0:
		condition = (
			" C=%d" % int(result["condition_total"]) if bool(result["condition_qualified"])
			else " C=%d non qualificata" % int(result["condition_total"])
		)
	log.bullet(
		"G. S=%d%s O=%d W=%+d -> M=%d -> %s"
		% [
			int(result["support_total"]),
			condition,
			int(result["oppose_total"]),
			factor,
			int(result["margin"]),
			str(result["outcome"]),
		]
	)

	var applied: Array = []
	var outcome: String = str(result["outcome"])
	var context: Dictionary = effect_context()

	# H.1 The Tension itself. Failure drops it and leaves the question alive
	# (appendix A6); any success settles it to 1. Quanto il fallimento sfoga
	# e' una regola della Chronicle (default -2, la lettera dell'appendice):
	# e' la rendita del blocco - una proposta affondata compra quiete - e la
	# seconda leva della 0.2 la misura prima di scriverla (D-098).
	var before: int = tensions.value(tension_id)
	var failure_delta: int = int(
		(_chronicle.get("confluence_rules", {}) as Dictionary).get("failure_delta", -2)
	)
	var delta: int = failure_delta if outcome == ConfluenceResolution.FAILURE else 1 - before
	_apply(applied, Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": delta}, source))
	# ISSUES 22 (fase 4): il placarsi - o lo sfogo - della questione decisa era
	# l'unico effetto del Consiglio senza una riga sua: si leggeva solo nello
	# stato di fine round. La sonda della visibilita' l'ha trovato; adesso parla.
	if not applied.is_empty():
		var settled: String = EffectNarrator.narrate(applied[applied.size() - 1], data)
		if settled != "":
			log.bullet("H. %s" % settled)

	# H.2 What the committed cards cost their owners.
	for entity_id in current["commits"]:
		for asset_id in current["commits"][entity_id]:
			var asset: Variant = data.assets.get(str(asset_id))
			if asset == null:
				continue
			var first_hook: int = applied.size()
			for spec in asset.get("on_commit_effects", []):
				var hook_context: Dictionary = context.duplicate()
				hook_context["actor"] = str(entity_id)
				_apply(applied, compiler.compile_spec(spec, hook_context, source))
			# ISSUES 26 / D-106: una carta con un mestiere lo dichiara al
			# tavolo. Il titolo apre, le frasi del narratore dicono cosa ha
			# fatto davvero; una carta che non ha mosso nulla non parla.
			var spoken: Array = []
			for i in range(first_hook, applied.size()):
				var said: String = EffectNarrator.narrate(applied[i], data)
				if said != "":
					spoken.append(said)
			if not spoken.is_empty():
				log.bullet("H. La carta parla - %s (%s):" % [
					str(asset["title"]), _name(str(entity_id))
				])
				for said in spoken:
					log.bullet("  %s" % said)

	# H.3-H.5 Outcome consequences. Dal pool del prezzo scatta **una voce sola**
	# (D-267): quella su cui il fronte avverso ha posato la pedina, o la prima
	# se nessuno ha parlato. Fino a 0.1.228 scattava il pool intero - con una
	# voce sola era la stessa cosa, e il pool era quasi sempre una voce sola.
	var pedina: Dictionary = current.get("price_pedina", {})
	var consequence_ids: Array = []
	if ConfluenceResolution.is_success(outcome):
		consequence_ids.append_array(_proposition()["success_consequences"])
		if outcome == ConfluenceResolution.SUCCESS_WITH_COST:
			var cost_id: String = _priced(
				template["consequence_pools"]["cost"], str(pedina.get("cost", ""))
			)
			if cost_id != "":
				consequence_ids.append(cost_id)
				if cost_id == str(pedina.get("cost", "")):
					log.bullet("H. Il costo e' quello della pedina del fronte avverso.")
		elif outcome == ConfluenceResolution.DECISIVE:
			consequence_ids.append_array(template["consequence_pools"]["decisive_bonus"])
	else:
		var failure_id: String = _priced(
			template["consequence_pools"]["failure"], str(pedina.get("failure", ""))
		)
		if failure_id != "":
			consequence_ids.append(failure_id)
			if failure_id == str(pedina.get("failure", "")):
				log.bullet("H. Lo sfogo e' quello della pedina del fronte avverso.")
	# ISSUES 22 (Fase 1): the Consequence speaks with its title, and every
	# Effect it lands gets its own spoken line — the crown losing the Valle
	# Verde must be a sentence at the table, not a silent SET_CONTROL.
	for consequence_id in consequence_ids:
		var consequence: Dictionary = data.consequences.get(str(consequence_id), {})
		# Una Conseguenza che parla di una casa precisa si salta quando quella
		# casa non siede (D-213): abbattere il drago non e' un evento del mondo
		# se il drago non e' al tavolo. Detto invece che taciuto, perche' D-030
		# vale anche per cio' che **non** succede.
		var needs: String = str(consequence.get("requires_entity", ""))
		if needs != "" and not (world["entities"] as Dictionary).has(needs):
			log.bullet(
				"H. %s non accade: parla di una casa che quest'anno non e' al tavolo."
				% str(consequence.get("title", consequence_id))
			)
			continue
		# La forma adattiva dello stesso requisito (D-262): non una casa
		# precisa, ma **chi porta un segno** — cosi' la Conseguenza viaggia su
		# qualunque tavolo. Stessa regola di D-213: detto invece che taciuto.
		var needs_tag: String = str(consequence.get("requires_entity_tag", ""))
		if needs_tag != "" and not _someone_carries(needs_tag):
			log.bullet(
				"H. %s non accade: nessuna casa al tavolo porta il segno che chiede."
				% str(consequence.get("title", consequence_id))
			)
			continue
		log.bullet("H. Conseguenza - %s:" % str(consequence.get("title", consequence_id)))
		var first_effect: int = applied.size()
		for effect in compiler.compile(str(consequence_id), context, source):
			_apply(applied, effect)
			_bar_return(applied, effect, source)
		_apply_scar(applied, str(consequence_id), source)
		_narrate_applied(applied, first_effect)

	# H.6 A qualified Condition rides along with any successful outcome (§12.3).
	if bool(result["condition_qualified"]) and ConfluenceResolution.is_success(outcome):
		for entity_id in current["stances"]:
			var stance: Dictionary = current["stances"][entity_id]
			if str(stance.get("stance", "")) != "CONDITION":
				continue
			var clause: Dictionary = _find_clause(str(stance.get("clause_id", "")))
			if clause.is_empty():
				continue
			log.bullet("H. Clausola qualificata: %s" % say(str(clause["text"])))
			var first_clause_effect: int = applied.size()
			# Chi ha posto la condizione (D-213). Una clausola che nominava una
			# casa per nome — «e allora Lyra ha il registro» — funzionava finche'
			# quella casa era sempre al tavolo; col tavolo pescato parlava di
			# un'assente, e l'Effetto cadeva in un push_error. E' anche piu'
			# giusto cosi': quello che la condizione ottiene lo ottiene chi
			# l'ha chiesto.
			var clause_context: Dictionary = context.duplicate()
			clause_context["conditioner"] = str(entity_id)
			for spec in clause["effects"]:
				_apply(applied, compiler.compile_spec(spec, clause_context, source))
			_narrate_applied(applied, first_clause_effect)

	# I. Asset disposition.
	_dispose_assets(applied, result, outcome, recovery, source)

	# J. Echo Check.
	var echo_created: bool = false
	if recorder.should_record(result):
		var effect_ids: Array = []
		for effect in applied:
			effect_ids.append(str(effect["effect_id"]))
		applied.append_array(recorder.record(current, result, effect_ids, source))
		echo_created = true
	else:
		log.bullet("J. Nessun Echo: la questione non ha lasciato un segno storico.")

	# K. Ripple: the closed Confluence pushes pressure onto its linked Tensions.
	for target in template["ripple"]["targets"]:
		_apply(
			applied,
			Effect.make(
				"ADJUST_TENSION",
				"tension",
				str(target),
				{"delta": int(template["ripple"]["delta"])},
				source
			)
		)
		log.bullet("K. Ripple: %s +%d" % [_tension_name(str(target)), int(template["ripple"]["delta"])])
	tensions.fire_omens(source)

	world["tensions"][tension_id]["resolved_count"] = (
		int(world["tensions"][tension_id]["resolved_count"]) + 1
	)
	world["confluence_count"] = int(world["confluence_count"]) + 1
	# Il sacchetto riparte da vuoto (D-203): il cancello del tavolo conta i
	# gettoni **da un Consiglio all'altro**, non da inizio anno. Senza questo
	# azzeramento il primo Consiglio aprirebbe tutti quelli successivi di fila,
	# perche' il conto resterebbe sempre sopra il cancello.
	world["tokens_in_bag"] = 0
	_record_who_stood_together()
	world["forced_confluence"] = null
	# La spirale del fallimento si chiude ri-decidendo (D-094). Quando una
	# proposta cade, CNS_FAILURE_SPIRAL scrive `question_unresolved` sul mondo
	# e D-077 tiene la domanda sul tavolo proprio perche' possa tornare ai
	# voti. Fin qui pero' nessun successo toglieva mai quel segno: il registro
	# restava in colpa anche a questione decisa. Adesso il mondo tiene il
	# conto delle questioni cadute in quest'era, e quando l'ultima viene
	# decisa la spirale si chiude. Il segno ereditato da un'era prima invece
	# resta: quello lo scioglie solo la via del riprendere (P_RETAKE_QUESTION),
	# perche' un conto di un'altra generazione non si chiude per caso.
	if not world.has("open_failures"):
		world["open_failures"] = []
	if outcome == ConfluenceResolution.FAILURE:
		if not (world["open_failures"] as Array).has(tension_id):
			(world["open_failures"] as Array).append(tension_id)
	elif (world["open_failures"] as Array).has(tension_id):
		(world["open_failures"] as Array).erase(tension_id)
		if (world["open_failures"] as Array).is_empty() \
				and (world["global_tags"] as Array).has("question_unresolved"):
			_apply(applied, Effect.make(
				"REMOVE_GLOBAL_TAG", "world", "WORLD",
				{"tag": "question_unresolved", "optional": true}, source
			))
			log.bullet("H. La domanda caduta è stata ripresa e decisa: la spirale si chiude.")

	# Segnata **qui** e non all'apertura: una domanda vale come posta quando e'
	# stata messa ai voti davvero. Una Confluence annullata perche' nessuna
	# proposta era disponibile non consuma niente (D-061). E nemmeno una che
	# il tavolo ha bocciato: respingere una proposta non e' decidere la
	# questione, e la domanda resta sul tavolo - quello che non torna mai e'
	# ridecidere una cosa decisa (D-077).
	if outcome != ConfluenceResolution.FAILURE:
		_mark_asked(tension_id, str(current["question_id"]))

	result["echo_created"] = echo_created
	result["confluence_id"] = str(current["confluence_id"])
	result["tension_id"] = tension_id
	result["proponent"] = str(current["proponent"])
	result["proposition_id"] = str(current["proposition_id"])
	result["question_id"] = str(current["question_id"])
	# What actually landed, by id. The log has printed this line since 0.0; the
	# result carries it too so a front-end can show the table what it just did
	# without re-deriving which pool applied - which would be the resolution
	# order restated somewhere it could quietly fall out of step.
	result["consequence_ids"] = consequence_ids.duplicate()
	result["effect_ids"] = applied.map(func(e: Dictionary) -> String: return str(e["effect_id"]))
	current["step"] = "CLOSED"
	current["result"] = result
	step_changed.emit("RESOLVED", current)
	current = {}
	return result


## §12.3: on Failure the proponent loses everything committed and each opposer
## keeps one card of their choice. On any success everything is discarded unless
## the card's own rule says otherwise.
func _dispose_assets(
	applied: Array, result: Dictionary, outcome: String, recovery: Dictionary, source: Dictionary
) -> void:
	var failure: bool = outcome == ConfluenceResolution.FAILURE
	# La regola scritta e' che chi si oppone si riprende una carta (D-013).
	# Toglierla e' la prima leva provata contro l'Oppose come strategia
	# dominante, e sta nei dati per essere reversibile come i cap su INFLUENCE.
	var recovers: bool = bool(
		(_chronicle.get("confluence_rules", {}) as Dictionary).get(
			"opposer_recovers_on_failure", true
		)
	)
	for entity_id in current["commits"]:
		var committed: Array = current["commits"][entity_id]
		var kept: String = ""
		if recovers and failure and _stance_of(str(entity_id)) == "OPPOSE" and not committed.is_empty():
			kept = str(recovery.get(entity_id, ""))
			if not committed.has(kept) or _retain_rule(kept) == "ALWAYS_DISCARD":
				kept = _default_recovery(committed)
		for asset_id in committed:
			if str(asset_id) == kept:
				kept = ""  # only one copy is recovered
				continue
			if _keeps_card(str(asset_id), failure):
				continue
			_apply(
				applied,
				Effect.make(
					"REMOVE_ASSET",
					"entity",
					str(entity_id),
					{"asset_id": str(asset_id), "destination": "DISCARD"},
					source
				)
			)
	log.bullet("I. Gli Asset impegnati sono stati risolti secondo le loro regole.")


func _keeps_card(asset_id: String, failure: bool) -> bool:
	match _retain_rule(asset_id):
		"RETAIN":
			return true
		"RETAIN_ON_SUCCESS":
			return not failure
	return false


func _retain_rule(asset_id: String) -> String:
	var asset: Variant = data.assets.get(asset_id)
	return "DISCARD" if asset == null else str(asset["discard_or_retain_rule"])


func _default_recovery(committed: Array) -> String:
	# Deterministic fallback: the strongest card that is allowed to come back.
	var best: String = ""
	var best_strength: int = -1
	for asset_id in committed:
		if _retain_rule(str(asset_id)) == "ALWAYS_DISCARD":
			continue
		var asset: Variant = data.assets.get(str(asset_id))
		var strength: int = 0 if asset == null else int(asset["strength"])
		if strength > best_strength or (strength == best_strength and str(asset_id) < best):
			best = str(asset_id)
			best_strength = strength
	return best


func _apply_scar(applied: Array, consequence_id: String, source: Dictionary) -> void:
	if not compiler.creates_scar(consequence_id):
		return
	var consequence: Dictionary = data.consequences[consequence_id]
	var scar: Dictionary = consequence.get("scar", {})
	if scar.is_empty():
		push_warning("ConfluenceController: '%s' creates_scar without a scar block" % consequence_id)
		return
	var scar_id: String = Ids.scar_id(world["scars"].size() + 1)
	_apply(
		applied,
		Effect.make(
			"ADD_SCAR",
			"scar",
			scar_id,
			{
				"scar_id": scar_id,
				# The scar block is authored data like any other, so it may name
				# $region_focus rather than a Region that has to exist for ever.
				"region_id": compiler.substitute_string(str(scar["region_id"]), effect_context()),
				"tag": str(scar["tag"]),
				"description": say(str(scar["description"])),
			},
			source
		)
	)
	log.bullet("Scar: %s" % str(scar["description"]))


## Qualcuno al tavolo porta questo segno? Vale il segno vivo sull'Entita' in
## gioco, quindi anche uno guadagnato in partita (D-262).
func _someone_carries(tag: String) -> bool:
	for entity_id in world["entities"]:
		var entity: Dictionary = world["entities"][str(entity_id)]
		if (entity.get("tags", []) as Array).has(tag):
			return true
	return false


func _apply(applied: Array, effect: Dictionary) -> void:
	if effect.is_empty():
		return
	var stored: Dictionary = applier.apply(effect)
	if stored.is_empty():
		push_error("ConfluenceController: %s" % applier.last_error)
		return
	applied.append(stored)


## One spoken line for every Effect landed since `first` (ISSUES 22, Fase 1).
## The narrator keeps quiet on no-ops and bookkeeping, so a silent block just
## produces no lines.
func _narrate_applied(applied: Array, first: int) -> void:
	for i in range(first, applied.size()):
		var said: String = EffectNarrator.narrate(applied[i], data)
		if said != "":
			log.bullet("  %s" % said)


## Un Consiglio che ti caccia non ti caccia per un giro: la Regione resta
## sbarrata per la vittima fino alla fine dell'atto (D-067), e `can_move_to` lo
## legge. Vale solo per la presenza tolta a qualcun altro - un costo che ci si
## infligge da soli, come la Partenza del proponente, non chiude nessuna porta -
## e solo se c'era davvero qualcuno da cacciare: l'`optional` andato a vuoto
## resta un no-op da cima a fondo.
func _bar_return(applied: Array, effect: Dictionary, source: Dictionary) -> void:
	if str(effect.get("type", "")) != "REMOVE_PRESENCE":
		return
	var victim: String = str(effect["target"]["id"])
	if victim == str(current["proponent"]):
		return
	if applied.is_empty():
		return
	# L'ultimo Effect registrato e' questa rimozione solo se l'applier l'ha
	# accettata; un rifiuto non lascia niente da sbarrare.
	var stored: Dictionary = applied[applied.size() - 1]
	if str(stored.get("type", "")) != "REMOVE_PRESENCE":
		return
	if str(stored["target"]["id"]) != victim:
		return
	if bool(stored.get("inverse_payload", {}).get("noop", false)):
		return
	var region_id: String = str(stored["payload"].get("region_id", ""))
	_apply(applied, Effect.make(
		"SET_ENTITY_TAG", "entity", victim, {"tag": "evicted:%s" % region_id}, source
	))
	log.bullet("H. %s e stato cacciato: %s resta sbarrata per lui fino a fine atto." % [
		_name(victim), str(data.regions.get(region_id, {}).get("name", region_id))
	])
	# D-130: il seggio ricorda di essere stato sradicato. Il primo segno e' un
	# fatto; il secondo nello stesso anno e' una natura - ed e' quello che la
	# successione legge per far nascere una vita senza centro. I tag d'entita'
	# non si ereditano fra le ere: il conto riparte da solo a ogni Chronicle.
	var memory: Array = world["entities"][victim]["tags"]
	if not memory.has("uprooted"):
		_apply(applied, Effect.make(
			"SET_ENTITY_TAG", "entity", victim, {"tag": "uprooted"}, source
		))
	elif not memory.has("twice_uprooted"):
		_apply(applied, Effect.make(
			"SET_ENTITY_TAG", "entity", victim, {"tag": "twice_uprooted"}, source
		))
		log.bullet("H. Due volte sradicato in un anno: %s non ha piu' un centro da difendere." % _name(victim))


## Chi e' stato dalla stessa parte, e chi dalla parte opposta (D-172).
##
## E' la **memoria dei bot**, non un fatto del mondo. `_ally_of_convenience`
## nasceva leggendo il Destino degli altri per capire con chi convenisse
## allearsi, e un giocatore vero quel Destino non lo vede: al tavolo si capisce
## chi ti e' vicino **da come vota**. Questo registro e' quello che chiunque
## sieda al Consiglio puo' vedere con i propri occhi, e niente di piu'.
##
## Contatore diretto come `confluence_count` e `resolved_count`: non e' una
## mutazione che qualcuno possa voler annullare, e non passa dagli Effetti.
## Contano solo i fronti dichiarati - chi si astiene non dice niente su nessuno.
func _record_who_stood_together() -> void:
	var fronts: Dictionary = {str(current["proponent"]): "SUPPORT"}
	for entity_id in current["stances"]:
		if str(entity_id) == str(current["proponent"]):
			continue
		fronts[str(entity_id)] = str(
			(current["stances"][entity_id] as Dictionary).get("stance", "ABSTAIN")
		)
	var seats: Array = fronts.keys()
	seats.sort()
	var memory: Dictionary = world["voted_together"]
	for i in range(seats.size()):
		var a: String = str(seats[i])
		if fronts[a] != "SUPPORT" and fronts[a] != "OPPOSE":
			continue
		for j in range(i + 1, seats.size()):
			var b: String = str(seats[j])
			if fronts[b] != "SUPPORT" and fronts[b] != "OPPOSE":
				continue
			var key: String = Ids.relation_key(a, b)
			memory[key] = int(memory.get(key, 0)) + (1 if fronts[a] == fronts[b] else -1)


## Quanto pesa un'alleanza al Consiglio (D-139): un alleato che ti sostiene
## parla piu' forte di uno sconosciuto. La distanza sopra NEUTRAL e' la forza -
## ALLY un passo, BOUND due - con un tetto per seggio, perche' senza, due
## legami stretti deciderebbero il Consiglio da soli. Il fronte OPPOSE non
## prende niente: la firma tiene `side` per rifiutarlo esplicitamente.
##
## **Pesa solo il legame caldo, e solo su chi sostiene.** La prima stesura era
## simmetrica (il nemico che ti osteggia pesa come l'alleato che ti sostiene) e
## sembrava piu' onesta; misurata sui 100 semi ha detto il contrario, perche'
## il tavolo di partenza *ha ostilita' e non ha alleanze*: i fallimenti sono
## passati da 185 a 210 e un seggio si e' bloccato su un livello solo. Un dente
## simmetrico su un mondo asimmetrico pesa da un lato solo.
##
## Cosi' invece il bonus non esiste finche' qualcuno non costruisce un'alleanza
## - ed e' la seconda cosa, dopo le promesse di D-051, che rende il FORGE verso
## l'alto degno di un'Opportunita' d'azione.
func _bond_weight(seat: String, side: String) -> int:
	var rules: Dictionary = (_chronicle.get("confluence_rules", {}) as Dictionary).get(
		"alliance_weight", {}
	)
	if rules.is_empty() or side != "SUPPORT":
		return 0
	var proponent: String = str(current["proponent"])
	if seat == proponent:
		return 0
	var order: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]
	var step: int = order.find(service.relation_level(seat, proponent)) - 2
	if step <= 0:
		return 0
	# E l'alleanza si paga: un alleato che aiuta senza metterci del proprio e'
	# un bonus passivo, uno che impegna carte e' una scelta al tavolo.
	var spent: int = (current["commits"].get(seat, []) as Array).size()
	if spent < int(rules.get("commits_at_least", 1)):
		return 0
	return mini(step * int(rules.get("per_step", 1)), int(rules.get("max", 2)))


## Quanto pesa la terra al Consiglio (D-154). Fino a 0.1.118 il controllo non
## faceva niente dentro l'anno: era una casella del Destino con una tassa
## attaccata (la sovraestensione), e nessuno aveva una ragione, nell'anno in
## corso, per andarsi a prendere una Regione. Da qui in poi la Regione **di cui
## si discute** da' voce a chi ci sta:
##
## - **il titolo**, a chi ne e' il padrone: quello che il Destino gia' contava
##   a fine anno adesso si sente anche al tavolo;
## - **la maggioranza**, a chi ci ha strettamente piu' pedine di chiunque altro
##   - a parita' non la prende nessuno, perche' una maggioranza contesa non e'
##   una maggioranza.
##
## I due si sommano fino al tetto: chi la tiene *e* ci sta dentro parla per
## primo, che e' il punto - un titolo senza nessuno sopra vale meno di un
## titolo presidiato, ed e' la stessa idea di `lapse_without_presence` detta
## dentro l'anno invece che fra un anno e l'altro.
##
## Vale su tutti e due i fronti dichiarati nei dati: stare in un posto e' neutro
## rispetto al lato, e «e' terra mia e dico di no» pesa quanto «e' terra mia e
## dico di si'». E come ogni altro peso, conta solo se quel seggio ha messo
## almeno una carta sul tavolo.
func _focus_weight(seat: String, side: String) -> Dictionary:
	var none: Dictionary = {"delta": 0, "why": ""}
	var rules: Dictionary = (_chronicle.get("confluence_rules", {}) as Dictionary).get(
		"focus_weight", {}
	)
	if rules.is_empty():
		return none
	var sides: Array = rules.get("sides", ["SUPPORT", "OPPOSE"])
	if not sides.has(side):
		return none
	# Il proponente e' gia' pagato dalla terra: e' *per* la presenza nel dominio
	# che sta li' a proporre. Dargli anche il peso vuol dire pagarlo due volte
	# per lo stesso investimento, e la misura lo dice forte - col proponente
	# dentro i Consigli passano troppo (FAIL 164) e un seggio si blocca. Il peso
	# serve a chi la terra ce l'ha e il Consiglio non l'ha chiamato: e' la voce
	# di «non si decide di casa mia senza di me».
	if not bool(rules.get("includes_proponent", true)) and seat == str(current["proponent"]):
		return none
	var region_id: String = str(current.get("focus_region", ""))
	if region_id == "" or not (world["regions"] as Dictionary).has(region_id):
		return none
	if (current["commits"].get(seat, []) as Array).size() < int(rules.get("commits_at_least", 1)):
		return none

	var delta: int = 0
	var reasons: Array = []
	if str((world["regions"] as Dictionary)[region_id].get("control", "")) == seat:
		var titled: int = int(rules.get("control", 0))
		if titled > 0:
			delta += titled
			reasons.append("la tiene")

	var mine: int = service.presence_count(seat, region_id)
	if mine > 0:
		var alone: bool = true
		for other in world["turn_order"]:
			if str(other) == seat:
				continue
			if service.presence_count(str(other), region_id) >= mine:
				alone = false
				break
		if alone:
			var most: int = int(rules.get("majority", 0))
			if most > 0:
				delta += most
				reasons.append("ci sta in forze")
	if delta <= 0:
		return none
	return {
		"delta": mini(delta, int(rules.get("max", 2))),
		"why": "%s %s" % [" e ".join(PackedStringArray(reasons)), _region_name(region_id)],
	}


func _region_name(region_id: String) -> String:
	var region: Variant = data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


func _log_commitments() -> void:
	log.bullet("E. Rivelazione simultanea degli impegni:")
	for entity_id in world["turn_order"]:
		if not current["commits"].has(entity_id):
			continue
		var committed: Array = current["commits"][entity_id]
		var titles: Array = []
		for asset_id in committed:
			titles.append(_asset_title(str(asset_id)))
		log.line(
			"      %s (%s): %s"
			% [
				_name(str(entity_id)),
				_stance_of(str(entity_id)),
				"nessun Asset" if titles.is_empty() else ", ".join(PackedStringArray(titles)),
			]
		)


func _stance_of(entity_id: String) -> String:
	if entity_id == str(current["proponent"]):
		return "PROPONENT"
	return str(current["stances"].get(entity_id, {}).get("stance", "ABSTAIN"))


func _proposition() -> Dictionary:
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	for proposition in template["propositions"]:
		if str(proposition["id"]) == str(current["proposition_id"]):
			return proposition
	return {}


## The slots an authored Effect may name, resolved to *ids* against the world as
## it stands right now.
##
## Public, because a decider has to be able to score a proposition before voting
## on it, and it can only do that if it resolves $region_focus the same way K
## will. Reading these bindings off a second table would let the policy's idea of
## the proposition drift from the Effects the Council actually applies - which is
## how the table ended up abstaining on 96% of propositions (D-034).
func effect_context() -> Dictionary:
	if current.is_empty():
		return {}
	return {
		"proponent": str(current["proponent"]),
		"tension": str(current["tension_id"]),
		"confluence": str(current["confluence_id"]),
		# The Region this Tension is about right now, so a Consequence can say
		# "the place we are arguing over" instead of naming one for ever. Same
		# rule that picks $the_region for the narrative text.
		"region_focus": narrative.focus_region(str(current["tension_id"])),
		# And the seat it is being asked against, and the seat of power - the two
		# other things a Consequence usually means when it names a proper noun.
		"rival": narrative.rival_id(
			narrative.focus_region(str(current["tension_id"])), str(current["proponent"])
		),
		"capital": narrative.capital_region(),
		"adjacent": narrative.adjacent_to(narrative.focus_region(str(current["tension_id"]))),
		"rival_seat": narrative.seat_of(
			narrative.rival_id(
				narrative.focus_region(str(current["tension_id"])), str(current["proponent"])
			),
			narrative.focus_region(str(current["tension_id"]))
		),
	}


## Fill the $slots of an authored sentence from the running Confluence. The
## 0.1 Confluence Board calls this too: what the table reads and what the log
## records have to be the same string.
func say(text: String) -> String:
	return narrative.fill(text, current.get("text_bindings", {}))


func _question_text(template: Dictionary, question_id: String) -> String:
	for question in template["questions"]:
		if str(question["id"]) == question_id:
			return str(question["text"])
	return question_id


func _tension_name(tension_id: String) -> String:
	return str(data.tensions[tension_id]["title"])


func _asset_title(asset_id: String) -> String:
	var asset: Variant = data.assets.get(asset_id)
	return asset_id if asset == null else str(asset["title"])


func _name(entity_id: String) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(service.name_of(entity_id))
