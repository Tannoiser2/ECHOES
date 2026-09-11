extends RefCounted
## Echo Check and the Truth register (§12.4, §16).
##
## An Echo is written when the table produced something worth remembering:
##   - a decision won in the wide band (D-488), whichever question won, or
##   - a decision won clearly where both fronts spent heavily (A + B >= 12), or
##   - a Failure that cost the opposition dearly (B >= 6) - a memorable defeat
##     is still history.
## A decision won by one or two - the narrow band - leaves no Echo.
##
## CREATE_ECHO and APPEND_TRUTH are irreversible Effects (§6.3).

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")

## **Quanto deve pesare un Consiglio perche' il mondo se lo ricordi.**
##
## `HEAVY_FRONT` e' una parte sola, e non si e' mosso: e' la porta del
## Fallimento costato caro, e sei e' ancora tanto per un fronte (la parte B
## media 5,5 gettoni). `HEAVY_TABLE` sono le **due parti insieme**, ed e'
## passato da 6 a 12 in D-488: sei era la soglia di quando i totali erano solo
## le carte impegnate, e da quando ci sono le pedine (D-471) A+B fa **12,7 di
## media** su cento anni. Misurata, quella porta lasciava passare **273 dei 274
## Consigli decisi da A**, e zero dei 166 decisi dalla B: una porta sempre
## aperta non e' una porta, ed e' per questo che le fasce «dicevano meno»
## (D-471). Dodici e' la mediana misurata, non un numero tondo.
const HEAVY_FRONT: int = 6
const HEAVY_TABLE: int = 12

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var log: RefCounted
## Set by ConfluenceController: the Truth register keeps the *filled* sentence,
## because a $slot left in the permanent record would be a bug nobody can undo.
var narrative: RefCounted = null
## Anche questo lo passa il ConfluenceController, e serve a una cosa sola: il
## **nome che la casa aveva quell'anno**. Fra due Chronicle passa un secolo e la
## persona cambia mentre la casa resta (D-045), quindi un verbale che scrive il
## nome deve scrivere quello di allora — e chi lo sa dire e' `name_of`, in un
## posto solo.
var service: RefCounted = null


func _init(p_world: Dictionary, p_data: RefCounted, p_applier: RefCounted, p_log: RefCounted) -> void:
	world = p_world
	data = p_data
	applier = p_applier
	log = p_log


## **Il Consiglio decide cosa il mondo ricordera'**, e questa e' la porta.
##
## Fino al 0.1.457 la porta guardava l'esito di **A**: un Decisivo entrava
## sempre, un Successo con le due parti che avevano speso, un Fallimento
## costato caro. La controdomanda che vince — **un Consiglio su tre**, misurato
## — non entrava mai, per nessun margine: `COUNTER` non e' un successo di A e
## non e' un Fallimento, e cadeva fuori da tutti e tre i rami. Da D-488 la
## porta guarda **chi ha vinto**: la fascia e' del vincitore, e per A non
## cambia niente perche' la fascia larga e il Decisivo sono lo stesso taglio.
func should_record(result: Dictionary) -> bool:
	var outcome: String = str(result["outcome"])
	var support: int = int(result["support_total"])
	var oppose: int = int(result["oppose_total"])
	var band: String = ConfluenceResolution.band_of(support, oppose, outcome)
	if band == ConfluenceResolution.WIDE:
		return true
	if band == ConfluenceResolution.CLEAR and support + oppose >= HEAVY_TABLE:
		return true
	# La fascia di misura non lascia storia: e' la decisione che passa per uno,
	# e la parola che le tocca — «passa, ma si paga» — lo dice da sempre.
	if outcome == ConfluenceResolution.FAILURE and oppose >= HEAVY_FRONT:
		return true
	return false


## Writes the Echo and its Truth record. Returns the Effects applied.
func record(context: Dictionary, result: Dictionary, effect_ids: Array, source: Dictionary) -> Array:
	var echo_id: String = Ids.echo_id(world["echo_log"].size() + 1)
	# **La proposta sta sulla carta** (D-462): letta dal template crudo, il
	# riassunto della proposta non si trovava per le carte senza copia — e
	# cinquantatre' su sessanta non ce l'avevano.
	var template: Dictionary = data.confluence_template_for(str(context["tension_id"]))
	var summary: String = _summary(template, context, result)

	# **E di chi e'** (ISSUES 136, punto 6). Fino a qui il ricordo portava chi
	# c'era (`participants`) e com'e' andata (`outcome`), e non chi **ha
	# ottenuto**: le case partecipano a quasi tutti i Consigli — 3,1 su 3,73
	# Echi l'anno — quindi «c'ero» non distingue nessuno, e il valutatore dei
	# Destini attaccava lo stesso Eco come prova a tutti quanti.
	#
	# Adesso il ricordo dice il lato che ha vinto, **la casa che l'ha guidato**,
	# chi stava con lei e chi le stava contro. Al tavolo e' la cosa piu' ovvia
	# del mondo — la Verita' la scrive qualcuno — e serve alla saga, che eredita
	# la Cronaca e fino a ieri non sapeva dire chi aveva ottenuto cosa.
	var side: String = str(result.get("winner", ""))
	var sides: Dictionary = context.get("sides", {}) as Dictionary
	var other: String = "" if side == "" else ("B" if side == "A" else "A")
	var echo: Dictionary = {
		"echo_id": echo_id,
		"title": str(template.get("echo_title_template", template["title"])),
		"summary": summary,
		"act": int(world["act"]),
		"round": int(world["round"]),
		"participants": (context["participants"] as Array).duplicate(),
		"effect_ids": effect_ids.duplicate(),
		"tension_id": str(context["tension_id"]),
		"outcome": str(result["outcome"]),
		"winning_side": side,
		"won_by": _leader_of(sides, side),
		"won_with": _seats_of(sides, side),
		"lost_by": _seats_of(sides, other),
	}

	var applied: Array = []
	var echo_effect: Dictionary = applier.apply(
		Effect.make("CREATE_ECHO", "echo", echo_id, echo, source)
	)
	if not echo_effect.is_empty():
		applied.append(echo_effect)

	var truth_id: String = Ids.truth_id(world["truth_log"].size() + 1)
	var truth: Dictionary = {
		"truth_id": truth_id,
		"text": "Anno %d, Atto %d: %s" % [int(world["year"]), int(world["act"]), summary],
		"act": int(world["act"]),
		"round": int(world["round"]),
		"echo_id": echo_id,
	}
	var truth_effect: Dictionary = applier.apply(
		Effect.make("APPEND_TRUTH", "truth", truth_id, truth, source)
	)
	if not truth_effect.is_empty():
		applied.append(truth_effect)

	log.bullet("Echo registrato [%s]: %s" % [echo_id, summary])
	log.bullet("Truth [%s] è ora immutabile." % truth_id)
	return applied


## Chi guidava quel lato, e chi ci stava. Vuoti quando non ha vinto nessuno:
## li' non c'e' una casa di cui dire il nome, e scriverne una sarebbe peggio che
## non scrivere niente.
func _leader_of(sides: Dictionary, side: String) -> String:
	if side == "":
		return ""
	return str((sides.get(side, {}) as Dictionary).get("leader", ""))


func _seats_of(sides: Dictionary, side: String) -> Array:
	if side == "":
		return []
	return ((sides.get(side, {}) as Dictionary).get("seats", []) as Array).duplicate()


## Il nome che la casa aveva **quell'anno**, o l'id se nessuno sa dirlo.
func _house(entity_id: String) -> String:
	if entity_id == "" or service == null:
		return entity_id
	return str(service.name_of(entity_id))


func _summary(template: Dictionary, context: Dictionary, result: Dictionary) -> String:
	# Il registro tiene la domanda che ha vinto, o che nessuna e' arrivata al
	# mucchio (D-467). Niente proposta, niente dado: da D-472 e' l'unico giro.
	var winner: String = str(result.get("winner", ""))
	var count: String = "A%d B%d, mucchio %d" % [
		int(result["support_total"]), int(result["oppose_total"]), int(result.get("pile", 0)),
	]
	if winner == "":
		return "%s: nessuna delle due domande arrivo' al mucchio (%s)." % [str(template["title"]), count]
	var question_id: String = str(((context["sides"] as Dictionary)[winner] as Dictionary).get("question_id", ""))
	var asked: String = str(template["title"])
	for entry in template.get("questions", []) as Array:
		if str((entry as Dictionary).get("id", "")) == question_id:
			asked = str((entry as Dictionary).get("text", ""))
	if narrative != null:
		asked = narrative.fill(asked, context.get("text_bindings", {}))
	# **E il ricordo porta il nome di chi l'ha ottenuta.** Una Verita' che dice
	# cosa il mondo ha deciso e non per mano di chi e' meta' verbale: la saga la
	# eredita e non sa a chi darne merito.
	var leader: String = _house(_leader_of(context.get("sides", {}) as Dictionary, winner))
	if leader == "":
		return "Il Consiglio rispose: %s (%s)." % [asked, count]
	return "Il Consiglio rispose: %s — l'ha ottenuta %s (%s)." % [asked, leader, count]
