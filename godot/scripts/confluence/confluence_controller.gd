extends RefCounted
## The Confluence sequence A-K (§12.2).
##
## A state machine, not a script: open() runs A-C and opens the two sides,
## the table then takes sides, places pedine and commits (D-E), and resolve()
## runs G-K in one atomic pass. The same object drives a headless simulation
## and, in 0.1, the Confluence Board.
##
## **Un motore solo** (D-472): il Consiglio e' quello a due domande di D-467.
## Il giro di D-280 — proposta, acquisto coi gettoni, prezzo scelto dagli
## avversari, dado — e' uscito dal codice; le sue prove sono passate alla
## regola nuova o sono state tolte con verbale.
##
## Resolution order inside resolve() - fixed, and documented in
## docs/RULES_V0_2.md so a Strategy swap cannot quietly change it:
##   1. Resolution maths against the pile     (G)
##   2. Tension outcome (set to 1 / -2)        (H)
##   3. on_commit costs of the Assets spent    (H)
##   4. Base outcome of the winning question   (H)
##   5. The winning side's pedine              (H)
##   6. Asset disposition                      (I)
##   7. Echo Check                             (J)
##   8. Ripple                                 (K)

const Effect := preload("res://scripts/core/effect.gd")
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")
const Ids := preload("res://scripts/core/ids.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const ConsequenceCompiler := preload("res://scripts/chronicle/consequence_compiler.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")
const EchoRecorder := preload("res://scripts/chronicle/echo_recorder.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")
const NarrativeText := preload("res://scripts/chronicle/narrative_text.gd")
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

## **Tre posizioni, non quattro** (D-454). La CONDITION — «sono a favore, a una
## condizione», con una clausola dal template — e' uscita: sulla carta la
## condizione che un avversario pone e' il **costo** che sceglie (D-280,
## D-387), e due grammatiche per la stessa cosa erano una contraddizione.
const STANCES: Array = ["SUPPORT", "OPPOSE", "ABSTAIN"]

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
		"stances": {},
		"commits": {},
		"participants": [proponent],
		"step": "STANCE",
		"act": int(world["act"]),
		"round": int(world["round"]),
	}
	_open_the_sides(template, question_id)

	# **L'intestazione senza l'id** (ISSUES 63): `confluence_id` e'
	# «CNF_ANY_ANCIENT#3», e finiva in cima al verbale che sta sullo schermo. Il
	# numero serve — dice quale Consiglio dell'anno e' — l'id no.
	log.section("CONSIGLIO %d - %s" % [int(current["index"]) + 1, str(template["title"])])
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


## **Il Consiglio di questa carta**, domande e proposte comprese (0.1.272).
##
## Non si legge piu' `confluence_templates[...]` direttamente: quel dizionario
## ha ancora le domande di ripiego, e prenderle di li' vorrebbe dire chiedere
## al tavolo la domanda generica invece di quella stampata sulla carta.
## `confluence_template_for` fonde le due cose: la carta vince su quello che e'
## suo, il template tiene il resto.
func _template() -> Dictionary:
	return data.confluence_template_for(str(current["tension_id"]))


## §12.2 B: which questions the state of the Tension actually raises.
func available_questions() -> Array:
	if current.is_empty():
		return []
	var template: Dictionary = _template()
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
			log.bullet("B. Domanda scelta: %s" % say(str(question["text"])))
			_open_the_sides(_template(), question_id)
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


# --- D: Stance -------------------------------------------------------------

## §12.2 D: public, in turn order from the proponent's left.
func stance_order() -> Array:
	return service.stance_order(str(current["proponent"])) if is_open() else []


# --- D: le due parti, le caselle, il rilancio (D-467) -----------------------


## Le due parti: la domanda che il proponente ha preso e' la **A**, l'altra
## della carta e' la **B**. Ogni parte tiene chi la sostiene e le pedine che
## ha posato; il mucchio e' il valore rivelato del Tema quando il Consiglio si
## apre, ed e' la soglia del voto. Chi guida la B e' il primo che la prende.
func _open_the_sides(template: Dictionary, question_id: String) -> void:
	var other: String = ""
	for entry in template.get("questions", []) as Array:
		if str((entry as Dictionary).get("id", "")) != question_id:
			other = str((entry as Dictionary).get("id", ""))
			break
	var theme_id: String = str(
		(data.tensions.get(str(current["tension_id"]), {}) as Dictionary).get("theme", "")
	)
	current["sides"] = {
		"A": {
			"question_id": question_id, "leader": str(current["proponent"]),
			"seats": [str(current["proponent"])], "boxes": [],
		},
		"B": {"question_id": other, "leader": "", "seats": [], "boxes": []},
	}
	# **Il mucchio, e quanto il mondo segnato lo muove**
	# ([D-477](../../docs/DECISIONS.md#d-477)). I gettoni caduti sul Tema dicono
	# quanto la questione scotta; le ventun regole `COUNCIL_MODIFIER` dicono
	# quanto il mondo rende difficile deciderla. La fame sparsa in giro alza la
	# soglia di un Consiglio sulla Carestia; una citta' che parla forte la
	# abbassa.
	#
	# Non scende mai sotto zero: una soglia negativa vorrebbe dire che una parte
	# passa senza aver messo niente sul tavolo, e al tavolo quel gesto non
	# esiste.
	var heat: int = int((world.get("theme_heat", {}) as Dictionary).get(theme_id, 0))
	var world_says: Dictionary = TagRules.council_pile_shift(
		data, world, str(current["tension_id"]), str(current["proponent"]),
		narrative.focus_region(str(current["tension_id"]))
	)
	var shift: int = int(world_says.get("delta", 0))
	current["pile"] = maxi(heat + shift, 0)
	current["pile_shift"] = shift
	current["pile_shift_titles"] = (world_says.get("titles", []) as Array).duplicate()
	current["passed"] = {}
	log.bullet("B. Contro: %s" % say(_question_text(template, other)))
	if shift == 0:
		log.bullet("B. Il mucchio sulla domanda vale %d." % int(current["pile"]))
	else:
		log.bullet("B. Il mucchio sulla domanda vale %d: %d di gettoni, %s%d perche' %s." % [
			int(current["pile"]), heat, "+" if shift > 0 else "", shift,
			" e ".join(PackedStringArray(current["pile_shift_titles"])),
		])


func sides_open() -> bool:
	return is_open() and current.has("sides")


func side_of(entity_id: String) -> String:
	if not sides_open():
		return ""
	for side in ["A", "B"]:
		if ((current["sides"][side] as Dictionary)["seats"] as Array).has(entity_id):
			return side
	return ""


func side_question(side: String) -> String:
	if not sides_open():
		return ""
	return str((current["sides"].get(side, {}) as Dictionary).get("question_id", ""))


func side_leader(side: String) -> String:
	if not sides_open():
		return ""
	return str((current["sides"].get(side, {}) as Dictionary).get("leader", ""))


func side_seats(side: String) -> Array:
	if not sides_open():
		return []
	return ((current["sides"].get(side, {}) as Dictionary).get("seats", []) as Array).duplicate()


## Le pedine di una parte, per lista: gli id delle caselle.
func side_boxes(side: String, list_name: String) -> Array:
	var out: Array = []
	if not sides_open():
		return out
	for box in ((current["sides"].get(side, {}) as Dictionary).get("boxes", []) as Array):
		if str((box as Dictionary)["list"]) == list_name:
			out.append(str((box as Dictionary)["voice"]))
	return out


func pile() -> int:
	return int(current.get("pile", 0)) if is_open() else 0


## Di che parte e' la pedina su una casella, "" se la casella e' libera.
func box_side_of(voice_id: String) -> String:
	if not sides_open():
		return ""
	for side in ["A", "B"]:
		for box in ((current["sides"][side] as Dictionary)["boxes"] as Array):
			if str((box as Dictionary)["voice"]) == voice_id:
				return side
	return ""


## Chi ha posato la pedina su una casella, "" se nessuno.
func box_owner_of(voice_id: String) -> String:
	if not sides_open():
		return ""
	for side in ["A", "B"]:
		for box in ((current["sides"][side] as Dictionary)["boxes"] as Array):
			if str((box as Dictionary)["voice"]) == voice_id:
				return str((box as Dictionary)["by"])
	return ""


func _box_taken(voice_id: String) -> bool:
	for side in ["A", "B"]:
		for box in ((current["sides"][side] as Dictionary)["boxes"] as Array):
			if str((box as Dictionary)["voice"]) == voice_id:
				return true
	return false


## **Le caselle libere di una parte**: benefici e costi della carta che
## servono la sua domanda (`for`), che qui farebbero qualcosa (D-306), e su cui
## nessuno ha ancora posato. Ogni voce porta `list` per dire da che lista
## viene.
func box_menu(side: String) -> Array:
	var out: Array = []
	if not sides_open():
		return out
	var question_id: String = side_question(side)
	if question_id == "":
		return out
	for list_name in ["benefits", "costs"]:
		for voice in live_voices(list_name):
			var marked: Array = (voice as Dictionary).get("for", []) as Array
			if not marked.has(question_id):
				continue
			if _box_taken(str((voice as Dictionary)["id"])):
				continue
			var entry: Dictionary = (voice as Dictionary).duplicate()
			entry["list"] = list_name
			out.append(entry)
	return out


## **Prendere posizione** (D-467 §3): un seggio entra in una parte, una volta.
## Per il tavolo e' la posizione di sempre — chi sta con A sostiene, chi sta
## con B si oppone — cosi' sonde, tabellone e obiettivi leggono quello che
## leggevano. Il primo che prende la B la guida: e' lui che «propone l'altra
## domanda».
func join_side(entity_id: String, side: String) -> bool:
	last_error = ""
	if not sides_open():
		last_error = "il Consiglio non ha due parti"
		return false
	if side != "A" and side != "B":
		last_error = "parte sconosciuta '%s'" % side
		return false
	if side_of(entity_id) != "":
		last_error = "%s ha gia' preso posizione" % _name(entity_id)
		return false
	if entity_id == str(current["proponent"]):
		last_error = "chi propone sta con la sua domanda"
		return false
	if side_question(side) == "":
		last_error = "la parte %s non ha una domanda" % side
		return false
	var part: Dictionary = current["sides"][side] as Dictionary
	(part["seats"] as Array).append(entity_id)
	if side == "B" and str(part["leader"]) == "":
		part["leader"] = entity_id
		log.bullet("D. %s prende l'altra domanda: %s" % [
			_name(entity_id), say(_question_text(_template(), str(part["question_id"]))),
		])
	# Per il tavolo e' la posizione di sempre: chi sta con A sostiene, chi
	# sta con B si oppone — sonde, tabellone e obiettivi leggono quello.
	var stance: String = "SUPPORT" if side == "A" else "OPPOSE"
	(current["stances"] as Dictionary)[entity_id] = {"stance": stance}
	if not (current["participants"] as Array).has(entity_id):
		(current["participants"] as Array).append(entity_id)
	log.bullet("D. %s: %s" % [_name(entity_id), stance])
	return true


## **Posare una pedina** sulla casella libera della propria parte.
func place_box(entity_id: String, voice_id: String) -> bool:
	last_error = ""
	var side: String = side_of(entity_id)
	if side == "":
		last_error = "%s non ha preso posizione" % _name(entity_id)
		return false
	for entry in box_menu(side):
		if str((entry as Dictionary)["id"]) != voice_id:
			continue
		var part: Dictionary = current["sides"][side] as Dictionary
		(part["boxes"] as Array).append({
			"by": entity_id, "voice": voice_id, "list": str((entry as Dictionary)["list"]),
		})
		if not (current["participants"] as Array).has(entity_id):
			current["participants"].append(entity_id)
		log.bullet("D. %s posa per %s — %s: %s" % [
			_name(entity_id), side,
			"beneficio" if str((entry as Dictionary)["list"]) == "benefits" else "costo",
			_voice_text(str((entry as Dictionary)["list"]), voice_id),
		])
		return true
	last_error = "«%s» non e' una casella libera della parte %s" % [voice_id, side]
	return false


func pass_turn(entity_id: String) -> void:
	if not sides_open():
		return
	(current["passed"] as Dictionary)[entity_id] = true
	log.bullet("D. %s passa." % _name(entity_id))


func has_passed(entity_id: String) -> bool:
	return sides_open() and bool((current["passed"] as Dictionary).get(entity_id, false))


## **Il prezzo si conta per parte, al voto** (D-467 §3): una parte puo' avere
## al massimo un beneficio in piu' dei suoi costi. Se i benefici scoperti
## avanzano, si tolgono gli ultimi posati, e si dice.
##
## **E il gettone del RIVENDICARE compra quello di troppo** ([D-476](../../docs/DECISIONS.md#d-476),
## parola del committente: *«il Rivendicare dovrebbe sempre dare i gettoni con
## cui comprare benefici e costi»*). La faccia RIVENDICARE conia il gettone da
## [D-387](../../docs/DECISIONS.md#d-387), e da [D-472](../../docs/DECISIONS.md#d-472)
## non aveva piu' dove spendersi: il Consiglio a due domande conta il prezzo
## per parte, e il gettone non entrava da nessuna parte.
##
## Il cambio non e' «una pedina, un gettone», ed e' una misura e non un gusto:
## il RIVENDICARE conia **2,21 gettoni l'anno su tutto il tavolo** contro
## **34,56 pedine posate** (`run_claim_probe`, 100 anni). A quel prezzo un
## gettone dovrebbe comprare quindici pedine perche' il tavolo resti pieno:
## far pagare ogni pedina non e' un'economia, e' un Consiglio spento. Il
## gettone fa la cosa che il tetto non permette — **ne alza il bordo di uno**,
## che e' l'aritmetica di [D-280](../../docs/DECISIONS.md#d-280) (*«una
## Cicatrice ne compra uno oltre il limite»*) col gettone al posto della
## Cicatrice.
##
## Si spende **da se'**: nessuno preferirebbe perdere il beneficio tenendosi il
## gettone, e al tavolo e' il gesto di posare la moneta per non ritirare la
## pedina. Lo spende chi ha posato la pedina di troppo; se lui non ne ha, ne
## cerca uno chiunque altro stia dalla sua parte — la parte e' una, e la moneta
## di chi la sostiene vale per lei.
func settle_prices(source: Dictionary = {}) -> Array:
	var removed: Array = []
	if not sides_open():
		return removed
	for side in ["A", "B"]:
		var part: Dictionary = current["sides"][side] as Dictionary
		var boxes: Array = part["boxes"] as Array
		while true:
			var benefits: int = 0
			var costs: int = 0
			for box in boxes:
				match str((box as Dictionary)["list"]):
					"benefits":
						benefits += 1
					# **La pedina gia' comprata col gettone non conta da
					# nessuna parte.** Contarla fra i costi — che e' quello che
					# faceva la prima stesura, perche' il ramo era un `else` —
					# alzava il tetto di **due** invece che di uno: con tre
					# benefici e una moneta restavano tutti e tre. Un gettone
					# compra una pedina, non un lasciapassare.
					"benefits_paid":
						pass
					_:
						costs += 1
			if benefits <= costs + 1:
				break
			for i in range(boxes.size() - 1, -1, -1):
				if str((boxes[i] as Dictionary)["list"]) != "benefits":
					continue
				var gone: Dictionary = boxes[i] as Dictionary
				var paid: String = _spend_a_claim_token(side, str(gone["by"]), source)
				if paid != "":
					# Comprata: la pedina resta, e il tetto di questa parte
					# sale di uno. Si segna sulla pedina, cosi' il conto non
					# la guarda piu' e il giro non si ripete su di lei.
					gone["list"] = "benefits_paid"
					log.bullet("D. %s spende un gettone di rivendicazione: la pedina su «%s» resta." % [
						_name(paid), _voice_text("benefits", str(gone["voice"])),
					])
					break
				boxes.remove_at(i)
				removed.append(str(gone["voice"]))
				log.bullet("D. La parte %s ha piu' benefici che costi: la pedina di %s su «%s» si toglie." % [
					side, _name(str(gone["by"])), _voice_text("benefits", str(gone["voice"])),
				])
				break
	# Le pedine comprate tornano benefici: il segno serviva solo al conto.
	for side in ["A", "B"]:
		for box in ((current["sides"][side] as Dictionary)["boxes"] as Array):
			if str((box as Dictionary)["list"]) == "benefits_paid":
				(box as Dictionary)["list"] = "benefits"
	return removed


## Chi, da questa parte, paga un gettone di rivendicazione per tenere la pedina.
## Prima chi l'ha posata, poi chiunque altro sostenga la stessa parte, in ordine
## di seggio perche' il risultato non dipenda dall'ordine di un Dictionary.
## Torna l'id di chi ha pagato, o "" se da questa parte non c'e' una moneta.
func _spend_a_claim_token(side: String, placed_by: String, source: Dictionary) -> String:
	var payers: Array = [placed_by]
	for entity_id in (current["sides"][side] as Dictionary).get("seats", []) as Array:
		if not payers.has(str(entity_id)):
			payers.append(str(entity_id))
	var leader: String = side_leader(side)
	if leader != "" and not payers.has(leader):
		payers.append(leader)
	for entity_id in payers:
		var entity: Variant = (world["entities"] as Dictionary).get(str(entity_id))
		if entity == null or int((entity as Dictionary).get("claim_tokens", 0)) <= 0:
			continue
		var spent: Dictionary = applier.apply(Effect.make(
			"SPEND_CLAIM_TOKEN", "entity", str(entity_id), {},
			source if not source.is_empty() else Effect.source(
				"confluence", str(current.get("confluence_id", "")), str(entity_id),
				int(world["act"]), int(world["round"]), int(world["effect_sequence"])
			)
		))
		if spent.is_empty():
			continue
		return str(entity_id)
	return ""


## Cosa ha dichiarato un seggio in questo Consiglio, o "ABSTAIN" se non ha
## dichiarato niente. Il proponente sostiene sempre la sua proposta.
func stance_of(entity_id: String) -> String:
	if current.is_empty():
		return "ABSTAIN"
	if entity_id == str(current["proponent"]):
		return "SUPPORT"
	return str(
		(current["stances"] as Dictionary).get(entity_id, {}).get("stance", "ABSTAIN")
	)


## Le caselle di una lista che possono davvero fare qualcosa, adesso (D-306):
## e' quello che il tabellone spegne, e da cui `box_menu` toglie le prese.
func live_voices(list_name: String) -> Array:
	var out: Array = []
	if current.is_empty():
		return out
	var context: Dictionary = effect_context()
	var theme_id: String = str(
		(data.tensions.get(str(current["tension_id"]), {}) as Dictionary).get("theme", "")
	)
	for voice in (card_face().get(list_name, []) as Array):
		if CouncilEconomy.voice_bites(
			voice as Dictionary, list_name, context, world, theme_id, data
		):
			out.append(voice)
	return out


## La faccia fisica della carta in dibattito, o {} se non ne ha una.
func card_face() -> Dictionary:
	if current.is_empty():
		return {}
	var definition: Variant = data.tensions.get(str(current["tension_id"]))
	if definition == null:
		return {}
	return (definition as Dictionary).get("physical", {}) as Dictionary


## Una voce della carta, per id.
func _voice(list_name: String, voice_id: String) -> Dictionary:
	for voice in (card_face().get(list_name, []) as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			return voice as Dictionary
	return {}


## Come si legge al tavolo una voce: la parola stampata sulla carta.
func _voice_text(list_name: String, voice_id: String) -> String:
	var voice: Dictionary = _voice(list_name, voice_id)
	return str(voice.get("text", voice_id))


# --- E: Commit -------------------------------------------------------------

func max_commit_for(entity_id: String) -> int:
	if entity_id == str(current["proponent"]):
		return int(_chronicle["max_commit_assets"])
	var stance: String = str(current["stances"].get(entity_id, {}).get("stance", "ABSTAIN"))
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
	var template: Dictionary = _template()
	var tension_id: String = str(current["tension_id"])
	var source: Dictionary = Effect.source(
		"confluence",
		str(current["confluence_id"]),
		str(current["proponent"]),
		int(world["act"]),
		int(world["round"]),
		int(world["effect_sequence"])
	)

	# **Senza dado** (D-467): il mondo ha gia' parlato col mucchio, che e' la
	# soglia del voto. Il dente dei segni sul dado (ISSUES 24) non ha piu' un
	# dado su cui pesare, e resta scritto come voce aperta in D-472.

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

	# G. Resolution.
	var result: Dictionary = ConfluenceResolution.resolve(
		str(current["proponent"]),
		current["stances"],
		current["commits"],
		data.assets,
		service.relevant_families(tension_id),
		support_bonus,
		oppose_bonus
	)
	# **Il voto a tre esiti, contro il mucchio** (D-467): A e' chi sostiene la
	# domanda del proponente, B chi ha preso l'altra.
	#
	# **Le pedine pesano** (D-471, taratura scritta): una parte vale le sue
	# carte **piu' le pedine che ha posato**, benefici e costi. Con le sole
	# carte — due per seggio, tetto della Chronicle — una parte di due non
	# arrivava a un mucchio da sei, e quattro Consigli su dieci non decidevano
	# niente (D-470). Posare un costo e' sostenere: al tavolo si conta «carte
	# e pedine della tua parte».
	var a_pedine: int = side_boxes("A", "benefits").size() + side_boxes("A", "costs").size()
	var b_pedine: int = side_boxes("B", "benefits").size() + side_boxes("B", "costs").size()
	result["cards_a"] = int(result["support_total"])
	result["cards_b"] = int(result["oppose_total"])
	result["pedine_a"] = a_pedine
	result["pedine_b"] = b_pedine
	result["support_total"] = int(result["support_total"]) + a_pedine
	result["oppose_total"] = int(result["oppose_total"]) + b_pedine
	result["pile"] = pile()
	result["outcome"] = ConfluenceResolution.two_sides_outcome(
		int(result["support_total"]), int(result["oppose_total"]), pile()
	)
	result["margin"] = int(result["support_total"]) - int(result["oppose_total"])
	result["winner"] = ConfluenceResolution.winner_of(str(result["outcome"]))
	# **La fascia e' del vincitore** (D-488): quanto nettamente ha vinto chi ha
	# vinto, sul suo margine e non su quello di A. E' quello che decide se il
	# mondo se lo ricorda.
	result["band"] = ConfluenceResolution.band_of(
		int(result["support_total"]), int(result["oppose_total"]), str(result["outcome"])
	)
	result["sides"] = (current["sides"] as Dictionary).duplicate(true)
	_log_commitments()
	log.bullet("G. A=%d (carte %d, pedine %d) B=%d (carte %d, pedine %d) contro il mucchio %d -> %s" % [
		int(result["support_total"]), int(result["cards_a"]), int(result["pedine_a"]),
		int(result["oppose_total"]), int(result["cards_b"]), int(result["pedine_b"]),
		pile(), str(result["outcome"]),
	])
	for title in stance_titles:
		log.bullet("  Il segno pesa sul fronte: %s." % str(title))
	if silence_bonus > 0 and table_is_silent:
		log.bullet("  Il tavolo tace: il silenzio avvantaggia il proponente (+%d)." % silence_bonus)

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

	# H.3-H.5 Outcome consequences.
	var consequence_ids: Array = []
	if str(result["winner"]) != "":
		# **L'esito di base della domanda che ha vinto** (D-467, D-469): le
		# Conseguenze scritte sulla domanda, a prescindere dalle pedine. Se
		# vince la B, le sue frasi parlano di chi la guida.
		var winner: String = str(result["winner"])
		consequence_ids.append_array(_question_base(template, side_question(winner)))
		if winner == "B":
			context = context.duplicate()
			context["proponent"] = side_leader("B")
		# **Il di piu' di una vittoria netta** (D-488). Il pool `decisive_bonus`
		# stava nei dodici template, nello schema e nel flusso disegnato, e non
		# lo leggeva **nessuno**: misurato, `CNS_DECISIVE_RENOWN` usciva zero
		# volte in cento anni. E' la stessa forma che il pool `failure` aveva
		# fino al 0.1.285 (D-323), trovata due volte nello stesso posto. Ne
		# porta una sola, come il prezzo (D-267), e va a **chi ha vinto**:
		# quando vince la B, il `$proponent` e' gia' chi la guida.
		if str(result.get("band", "")) == ConfluenceResolution.WIDE:
			var when_it_wins: Array = (
				(template.get("consequence_pools", {}) as Dictionary).get("decisive_bonus", []) as Array
			)
			if not when_it_wins.is_empty():
				consequence_ids.append(str(when_it_wins[0]))
	elif outcome == ConfluenceResolution.FAILURE:
		# **Una domanda caduta lascia il segno che quella domanda lascia**
		# (D-323, [ISSUES 95](../../docs/ISSUES.md)). Fino a 0.1.285 il pool
		# `failure` non lo leggeva nessuno: un Consiglio che falliva lasciava al
		# mondo soltanto `question_unresolved`, e undici Conseguenze scritte —
		# proprio quelle che sporcano il mondo — non uscivano mai. Da qui il
		# regalo piu' grosso del punteggio: `state_tag_absent` era gratis perche'
		# quando il tavolo non sa decidere il mondo non si sporca.
		#
		# Il pool ne porta **una sola**, come per il prezzo (D-267): al tavolo la
		# scheda del Consiglio ha una riga sola sotto "se cade", e quella si
		# legge. Non e' la stessa per tutti: la fame che nessuno risolve svuota
		# il posto, una terra che nessuno assegna resta contesa, una domanda
		# sull'Antico che nessuno chiude diventa una voce che corre, un conto che
		# nessuno salda chiude la strada.
		var when_it_falls: Array = (
			(template.get("consequence_pools", {}) as Dictionary).get("failure", []) as Array
		)
		if not when_it_falls.is_empty():
			consequence_ids.append(when_it_falls[0])
		# **Nessuna delle due passa: sono respinte tutt'e due** (D-475, parola
		# del committente: *«le 16 conseguenze tornano come esito, io non vorrei
		# perderle»*). Sono le sedici che stavano sulla proposta contraria,
		# uscita coi Consigli di D-280 e coi dati in D-474: il loro posto e'
		# qui, e solo qui.
		#
		# **Solo qui, e non quando una delle due passa**, ed e' una correzione
		# fatta in corsa contro la misura. Il primo giro le applicava anche alla
		# domanda perdente di un Consiglio riuscito — *«dire di no e' una
		# decisione»* — e sembrava giusto finche' i numeri non hanno detto due
		# cose: la mediana dei Consigli su un tavolo a quattro domande e' scesa
		# **da 5 a 3**, perche' ogni Consiglio raffreddava due questioni invece
		# di una; e soprattutto *Il Drago Abbattuto* (TEN_AWAKENING −6) arrivava
		# **senza che nessuno lo avesse proposto**. Queste sedici erano l'esito
		# di una proposta che il tavolo votava: regalarle a chi perde e' un'altra
		# cosa. Se una delle due passa, il tavolo **ha deciso**, e il mondo
		# prende quello che ha deciso. Se non passa nessuna, allora si', sono
		# state respinte tutt'e due.
		for side in ["A", "B"]:
			for consequence_id in _question_refused(template, side_question(side)):
				if not consequence_ids.has(consequence_id):
					consequence_ids.append(consequence_id)
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
		# La pedina del rivendicante non sta qui (D-304): sta sulla carta, sulle
		# caselle che il proponente ha comprato. La frase d'autore resta del
		# proponente, che e' chi ha portato la proposta al tavolo.
		log.bullet("H. Conseguenza - %s:" % str(consequence.get("title", consequence_id)))
		var first_effect: int = applied.size()
		for effect in compiler.compile(str(consequence_id), context, source):
			_apply(applied, effect)
			_bar_return(applied, effect, source)
		_apply_scar(applied, str(consequence_id), source)
		_narrate_applied(applied, first_effect)

	# **L'economia della carta, per ultima** (D-280, ordine deciso da D-305).
	#
	# Se la proposta passa si applicano **tutti i benefici comprati e tutti i
	# costi posati** — la riga in fondo alla carta, «applica tutti i benefici e
	# tutti i costi (incluse le cicatrici)». Se cade, scattano gli **effetti
	# stampati**: il mondo non sopporta l'indecisione, e quelli non li sceglie
	# nessuno.
	#
	# **Va per ultima perche' e' quella che il tavolo ha scelto.** Fino a
	# 0.1.266 la carta si spendeva prima, e la frase d'autore ci passava sopra:
	# misurato, **62 volte in 40 anni** — 38 riassegnazioni di controllo e 24
	# segni tolti — e in silenzio, senza che il verbale dicesse che una casella
	# comprata e pagata era stata cancellata. Adesso la frase racconta, e poi la
	# carta lascia il segno: quello che il proponente ha comprato, il
	# rivendicante ha rivendicato e gli avversari hanno fatto pagare resta.
	_spend_the_card(applied, outcome, source)

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
		# **Il segno della domanda caduta lo scrive il motore, non il malus**
		# (D-278). Fin qui lo scriveva CNS_FAILURE_SPIRAL, cioe' una voce fra
		# le tante: da quando lo sfogo lo sceglie il fronte avverso fra le due
		# scritte sulla carta, farlo dipendere da quella scelta vorrebbe dire
		# che il mondo si ricorda della caduta **solo se l'avversario ha
		# scelto la voce giusta**. Che una proposta sia caduta e' un fatto del
		# tavolo, e resta sul tavolo comunque; il malus e' quello che si paga
		# in piu'.
		if not (world["global_tags"] as Array).has("question_unresolved"):
			_apply(applied, Effect.make(
				"SET_GLOBAL_TAG", "world", "WORLD",
				{"tag": "question_unresolved"}, source
			))
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
		# Vale come posta la domanda che ha vinto (D-467).
		_mark_asked(tension_id, side_question(str(result["winner"])))

	result["echo_created"] = echo_created
	result["confluence_id"] = str(current["confluence_id"])
	result["tension_id"] = tension_id
	result["proponent"] = str(current["proponent"])
	result["question_id"] = str(current["question_id"])
	result["winning_question_id"] = (
		side_question(str(result["winner"])) if str(result["winner"]) != "" else ""
	)
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


## L'economia della carta, applicata (D-280).
##
## Passa: i benefici comprati dal proponente **e** i costi che il fronte
## avverso ha scelto — insieme, come dice la carta. Cade: gli effetti stampati
## in fondo, che non sceglie nessuno.
##
## Ogni voce parla col suo testo prima di lasciare il segno: al tavolo si legge
## la riga e si posa la pedina, e il verbale deve poter essere riletto come si
## rilegge una partita vera.
func _spend_the_card(applied: Array, outcome: String, source: Dictionary) -> void:
	var face: Dictionary = card_face()
	if face.is_empty():
		return
	var theme_id: String = str(
		(data.tensions.get(str(current["tension_id"]), {}) as Dictionary).get("theme", "")
	)
	var context: Dictionary = effect_context()
	var spent: Array = []
	# **Le pedine della parte che ha vinto, benefici e costi insieme** (D-467
	# §4); se non passa nessuna, gli effetti stampati. Le pedine dell'altra
	# parte si tolgono e non fanno niente. Se vince la B, le sue caselle
	# parlano di chi la guida.
	var winner: String = ConfluenceResolution.winner_of(outcome)
	if winner == "":
		for voice in (face.get("failure", []) as Array):
			spent.append(["failure", voice as Dictionary])
	else:
		if winner == "B":
			context = context.duplicate()
			context["proponent"] = side_leader("B")
		for list_name in ["benefits", "costs"]:
			for voice_id in side_boxes(winner, list_name):
				spent.append([list_name, _voice(list_name, str(voice_id))])
	for entry in spent:
		var kind: String = str((entry as Array)[0])
		var voice: Dictionary = (entry as Array)[1] as Dictionary
		if voice.is_empty():
			continue
		var effects: Array = CouncilEconomy.effects_for(
			voice, kind, context, world, theme_id, source
		)
		if effects.is_empty():
			continue
		log.bullet("H. %s %s" % [
			"Beneficio:" if kind == "benefits" else (
				"Prezzo:" if kind == "costs" else "Il mondo non aspetta:"
			),
			str(voice.get("text", "")),
		])
		# **E cosa ha lasciato sul mondo** (D-292). La Conseguenza d'autore
		# narrava ogni suo Effetto, la voce della carta no: il verbale diceva
		# «Beneficio: costruisci un Granaio» e poi taceva su cosa fosse
		# successo davvero. Meta' del Consiglio scriveva in silenzio — e una
		# sonda che contava gli Effetti narrati leggeva zero per la carta e
		# 443 per la frase d'autore, che era falso.
		var first_effect: int = applied.size()
		for effect in effects:
			_apply(applied, effect)
		_narrate_applied(applied, first_effect)
		# **E se non ha lasciato niente, si dice** (D-306, regola di D-030:
		# detto invece che taciuto). Il menu offre solo caselle vive, ma fra
		# l'acquisto e la risoluzione passa la frase d'autore, che puo' aver
		# fatto lei la stessa cosa: allora il proponente ha pagato per un
		# lavoro gia' fatto. Misurato: 46 acquisti su 193, e prima non lo
		# diceva nessuno (ISSUES 87).
		if kind == "benefits" and not _anything_landed(applied, first_effect):
			log.bullet("  ...e non lascia niente: era gia' cosi'.")


## Qualcosa e' davvero cambiato nel mondo da `first` in poi? Un Effetto marcato
## no-op ha attraversato il motore senza spostare niente (D-306).
func _anything_landed(applied: Array, first: int) -> bool:
	for i in range(first, applied.size()):
		if not bool((applied[i] as Dictionary).get("inverse_payload", {}).get("noop", false)):
			return true
	return false


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


## L'esito di base scritto sulla domanda (D-469): gli id delle Conseguenze.
func _question_base(template: Dictionary, question_id: String) -> Array:
	for entry in template.get("questions", []) as Array:
		if str((entry as Dictionary).get("id", "")) == question_id:
			return ((entry as Dictionary).get("base", []) as Array).duplicate()
	return []


## **Cosa resta al mondo se il tavolo respinge questa domanda** (D-475): gli id
## delle Conseguenze scritte sulla domanda accanto al suo esito di base. Una
## domanda che non lo scrive, respinta, non lascia niente — e sono le piu'.
func _question_refused(template: Dictionary, question_id: String) -> Array:
	for entry in template.get("questions", []) as Array:
		if str((entry as Dictionary).get("id", "")) == question_id:
			return ((entry as Dictionary).get("refused", []) as Array).duplicate()
	return []


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
