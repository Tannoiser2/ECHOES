extends RefCounted
## What a seat can see and what it may do - without saying how it is shown.
##
## The ChronicleController has never known who its players are - it asks a
## duck-typed `decider` and applies whatever comes back. Four of those exist for
## machines: ScriptedDecider replays authored plans, PolicyDecider plays to win,
## SuppressorDecider only ever calms things down, and the stance probe borrows
## PolicyDecider to read its mind. This is the base of the ones a person drives,
## and the first that decides nothing itself.
##
## It holds the two things both front-ends need and neither should own twice:
## the board as one seat sees it, and the list of actions the rules will
## actually accept. `cli/human_decider.gd` renders those to a terminal,
## `ui/ui_decider.gd` to buttons in a browser. Two implementations of "what may
## I do right now" would be two implementations to keep in agreement (D-038).
##
## Seats not listed as human fall through to `fallback`, so one person can sit
## down against three policies.
##
## How a choice is *shown* is injected, not inherited: `io` is any object with
## `say(text)` and `choose(prompt, labels) -> int`. A terminal implements it with
## stdout and stdin, the browser screen with a panel and buttons, and a test
## leaves it null - which makes every choice defer to the policy, exactly what a
## seat nobody is watching should do.
##
## Injected rather than subclassed for a concrete reason, found by loading the
## exported build in a real browser: `extends "res://path.gd"` does not resolve
## in an exported project, while `preload` does. That is why this whole codebase
## uses `const X := preload(...)` and no `class_name`, and the rule holds here.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const AssetText := preload("res://scripts/core/asset_text.gd")
const EchoText := preload("res://scripts/core/echo_text.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")
const CouncilText := preload("res://scripts/core/council_text.gd")
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")

## Entity ids a person is playing.
var humans: Dictionary = {}
var fallback: RefCounted
var log: RefCounted


func _init(p_humans: Array, p_log: RefCounted = null) -> void:
	for entity_id in p_humans:
		humans[str(entity_id)] = true
	log = p_log
	fallback = PolicyDecider.new(p_log)


func _is_human(entity_id: String) -> bool:
	return humans.has(entity_id)


# --- reading a person -------------------------------------------------------

## Anything with `say(text)` and `choose(prompt, labels) -> int`. Null means
## nobody is watching this seat.
var io: Object = null

## Piu' console, un decider (voce 27 fase 2 — D-135): `ios[seat]` e' l'io del
## telefono di quel seggio; `io` resta il ripiego condiviso (il terminale,
## l'hotseat, la console di riserva sullo schermo grande). Ogni ingresso
## pubblico dichiara a chi sta parlando prima di dire o chiedere: e' cosi'
## che l'avviso di un Destino finisce sul telefono giusto e su nessun altro.
var ios: Dictionary = {}
var _speaking_to: String = ""


func _io_now() -> Object:
	return ios.get(_speaking_to, io)


func _say(text: String) -> void:
	var ear: Object = _io_now()
	if ear != null:
		ear.say(text)


## Se l'io dall'altra parte disegna da se' il pannello del seggio. Chi lo fa
## non ha bisogno della versione a caratteri; chi tace risponde di no, che e'
## la risposta giusta per il terminale e per lo schermo del tavolo.
func _reads_own_state() -> bool:
	var ear: Object = _io_now()
	return ear != null and ear.has_method("shows_state") and bool(ear.shows_state())


## Offer the choices and wait for one. Returns the chosen index, or -1 for
## "you decide", which hands this single choice back to the policy without
## taking the player out of their game.
##
## A coroutine: a mouse cannot answer on the same frame it was asked, and
## `ChronicleController.run()` is awaitable precisely so this can suspend the
## Chronicle in place instead of freezing it (D-038).
##
## `subjects[i]` says what choice `i` is *about* - `{"region": "REG_X"}` and
## nothing else so far - so a front-end that draws the world can put the choice
## where the thing is, instead of in a list beside it. It is a fact about the
## choice, not an instruction about the screen: the terminal ignores it, and no
## front-end may infer legality from it, because the entry only exists at all if
## the rules already accepted it (D-039).
func _choose(prompt: String, entries: Array, subjects: Array = []) -> int:
	var ear: Object = _io_now()
	if entries.is_empty() or ear == null:
		return -1
	var labels: Array = []
	for entry in entries:
		labels.append(str(entry))
	var picked: int = await ear.choose(prompt, labels, subjects)
	if picked < 0 or picked >= entries.size():
		return -1
	return picked


# --- the turn ---------------------------------------------------------------

func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
	if not _is_human(entity_id):
		return fallback.choose_action(entity_id, ao_index, session)
	_speaking_to = entity_id

	_say("")
	# Il pannello a caratteri e' per chi non ha un pannello. Il terminale e lo
	# schermo del tavolo lo leggono; la console del telefono no: lei riceve gia'
	# lo `state` strutturato (D-134) e disegna domande, mano, Destino e rapporti
	# a sezioni. Mandarglielo lo stesso significa dire due volte le stesse cose,
	# la seconda peggio, in cima allo schermo piu' piccolo che abbiamo (D-143).
	if not _reads_own_state():
		_say(_board(entity_id, session))
	var options: Array = _action_options(entity_id, session)
	var labels: Array = []
	var subjects: Array = []
	for option in options:
		labels.append(str(option["label"]))
		subjects.append(option.get("subject", {}))
	labels.append("Passa")
	subjects.append({})
	# ISSUES 21: al tavolo fisico un compagno ti farebbe notare che stai
	# spegnendo la tua stessa spunta. L'app fa altrettanto: se la mossa scelta
	# spegne una clausola accesa del proprio Destino, una riga di avviso e la
	# scelta di ripensarci. Un cartello, non un consigliere.
	while true:
		var choice: int = await _choose(
			"%s, azione %d:" % [_name(entity_id, session), ao_index + 1], labels, subjects
		)
		if choice < 0:
			return fallback.choose_action(entity_id, ao_index, session)
		if choice >= options.size():
			return {"template": "PASS", "params": {}}
		var request: Dictionary = {
			"template": str(options[choice]["template"]),
			"params": options[choice]["params"],
		}
		var dying: Array = _clauses_this_switches_off(entity_id, request, session)
		if dying.is_empty():
			return request
		_say("  ⚠ Questa mossa spegne: %s" % ", ".join(PackedStringArray(dying)))
		var confirmed: int = await _choose(
			"  La fai lo stesso?", ["Sì, la faccio", "No, ci ripenso"]
		)
		if confirmed != 1:
			return request
	return {"template": "PASS", "params": {}}


## ISSUES 21: le clausole del proprio Destino, oggi accese, che questa azione
## spegnerebbe. L'anteprima è una sessione ricostruita dal salvataggio — stesso
## mondo, stesso dado, quindi la previsione è esatta — su cui l'azione viene
## eseguita davvero e poi buttata via: nessun ramo di regole duplicato da
## tenere allineato. Solo il posto proprio e solo clausole già vere: chi vuole
## sapere cosa conviene ha il tavolo, non un consigliere.
func _clauses_this_switches_off(
	entity_id: String, request: Dictionary, session: RefCounted
) -> Array:
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(entity_id))
	if destiny == null:
		return []
	var lit: Array = []
	for level in ["minimum", "victory", "triumph"]:
		for condition in destiny[level]["conditions"]:
			if session.destinies.conditions.holds(condition, {"self": entity_id}):
				lit.append(condition)
	if lit.is_empty():
		return []
	var preview: RefCounted = GameSession.new(session.data)
	if not preview.restore(session.to_save("anteprima")):
		return []
	var dying: Array = []
	var outcome: Dictionary = preview.actions.execute(entity_id, request)
	if bool(outcome.get("ok", false)):
		for condition in lit:
			if preview.destinies.conditions.holds(condition, {"self": entity_id}):
				continue
			var said: String = "«%s»" % str(condition.get("label", ""))
			if not dying.has(said):
				dying.append(said)
	preview.dispose()
	return dying


## Every legal action, already checked against the rules, so a person is never
## offered something the resolver will refuse. This is the part a Confluence
## Board would draw as buttons in 0.1; the legality query is the same.
func _action_options(entity_id: String, session: RefCounted) -> Array:
	var out: Array = []
	var service: RefCounted = session.service

	# D-359: l'Eco e' il terzo blocco della carta Asset che hai in mano - la sua
	# versione potenziata. Si offre accanto alle Azioni normali della stessa
	# carta, cosi' la scelta si vede: la stessa carta, o la sua parola.
	for asset_id in service.hand(entity_id):
		var request: Dictionary = {"asset_card_id": str(asset_id)}
		if session.actions.can_execute(entity_id, "PLAY_ECHO", request):
			var echo_id: String = str(
				(session.data.assets[str(asset_id)] as Dictionary)["echo_id"]
			)
			# Il titolo da solo non dice niente: che tono ha e cosa fa stanno
			# accanto, come per le carte Asset (EchoText).
			out.append({
				"label": EchoText.label(
					session.data.echo_cards[echo_id] as Dictionary, session.data
				),
				"template": "PLAY_ECHO", "params": request,
			})

	for family in ["AUTHORITY", "FORCE", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]:
		var request: Dictionary = {"family": family}
		if session.actions.can_execute(entity_id, "ACQUIRE", request):
			out.append({
				"label": "Acquisisci una carta %s" % family,
				"template": "ACQUIRE", "params": request,
			})

	for region_id in _sorted(session.world["regions"].keys()):
		var request: Dictionary = {"region_id": str(region_id)}
		if session.actions.can_execute(entity_id, "MOVE", request):
			out.append({
				"label": "Metti una presenza in %s" % _region(str(region_id), session),
				"template": "MOVE", "params": request,
				# The one choice that has a place on a map: a front-end that draws
				# one can offer it there instead of as a line of text.
				"subject": {"region": str(region_id)},
			})

	for tension_id in _sorted(session.world["tensions"].keys()):
		for delta in [1, -1]:
			var request: Dictionary = {
				"tension_id": str(tension_id), "delta": delta, "via": "PRESENCE",
			}
			if not session.actions.can_execute(entity_id, "INFLUENCE", request):
				continue
			out.append({
				"label": "%s %s (%s)" % [
					"Alza" if delta > 0 else "Abbassa",
					_tension(str(tension_id), session),
					_tension_reading(str(tension_id), entity_id, session),
				],
				"template": "INFLUENCE", "params": request,
				# Di cosa parla: la domanda. Un front-end che disegna la traccia
				# puo' offrirla li' invece che in una riga di testo (D-231).
				"subject": {"tension": str(tension_id)},
			})

	for tension_id in _sorted(session.world["tensions"].keys()):
		# Only what is actually hidden from you. An open Tension already shows its
		# number, and offering to scout it is offering a wasted Action Opportunity.
		if not session.tensions.is_veiled(str(tension_id)):
			continue
		if service.knows_tension(entity_id, str(tension_id)):
			continue
		var request: Dictionary = {"mode": "TENSION", "tension_id": str(tension_id)}
		if session.actions.can_execute(entity_id, "SCHEME", request):
			# **Cosa si scopre lo dice la regola, non l'abitudine** (D-194).
			# Da D-187 il velo copre la **soglia** e lascia il numero in chiaro:
			# offrire «scopri il numero» di una domanda il cui numero e' sul
			# tavolo e' invitare qualcuno a buttare un'Occasione per sapere una
			# cosa che sa gia'.
			out.append({
				"label": (
					"Scopri a quanto esplode %s"
					if session.tensions.hides_threshold_only()
					else "Scopri il numero di %s"
				) % _tension(str(tension_id), session),
				"template": "SCHEME", "params": request,
				"subject": {"tension": str(tension_id)},
			})

	# Il velo (D-125): l'arte inversa, per chi ha il segno che la concede.
	# Il resolver rifiuta da solo chi non ce l'ha: qui si offre, non si giudica.
	for tension_id in _sorted(session.world["tensions"].keys()):
		var veil: Dictionary = {"mode": "VEIL", "tension_id": str(tension_id)}
		if session.actions.can_execute(entity_id, "SCHEME", veil):
			out.append({
				"label": (
					"Copri la soglia di %s"
					if session.tensions.hides_threshold_only()
					else "Cala il velo su %s"
				) % _tension(str(tension_id), session),
				"template": "SCHEME", "params": veil,
				"subject": {"tension": str(tension_id)},
			})

	for other_id in session.world["turn_order"]:
		if str(other_id) == entity_id:
			continue
		for direction in ["UP", "DOWN"]:
			var request: Dictionary = {
				"target_entity_id": str(other_id), "direction": direction,
			}
			if not session.actions.can_execute(entity_id, "FORGE", request):
				continue
			out.append({
				"label": "%s i rapporti con %s (ora %s)" % [
					"Avvicina" if direction == "UP" else "Rompi",
					_name(str(other_id), session),
					service.relation_level(entity_id, str(other_id)),
				],
				"template": "FORGE", "params": request,
				# Di chi parla: l'altra casa. Sta nella colonna dei rapporti, ed
				# e' li' che una carta che forgia deve poter cadere (D-231).
				"subject": {"entity": str(other_id)},
			})
	return _through_the_hand(entity_id, out, session)


## **Quando le carte sono l'unica moneta, il menu deve offrire le carte** (D-194).
##
## Le sei azioni di §10 restano il vocabolario del gioco, e questo elenco le
## costruisce come sempre: sono cio' che un seggio *puo' voler fare*. Ma se la
## Chronicle dice che si fanno con le carte, ognuna va offerta **una volta per
## ogni carta in mano che sa dirla** — e quelle che nessuna carta sa dire non si
## offrono affatto.
##
## Senza questo, l'interfaccia umana e' rimasta al gioco di prima: proponeva
## «Acquisisci una carta AUTORITA'» e il resolver la rifiutava un istante dopo,
## perche' D-188 ha spostato il divieto da `check()` a `execute()`. I bot erano
## passati alle carte, le mani no.
func _through_the_hand(entity_id: String, offers: Array, session: RefCounted) -> Array:
	var chronicle: Dictionary = session.data.chronicles[
		str(session.world["chronicle_id"])
	] as Dictionary
	if not bool(chronicle.get("actions_from_cards", false)):
		return offers
	var hand: Array = session.service.hand(entity_id)
	var out: Array = []
	for offer in offers:
		var template: String = str((offer as Dictionary)["template"])
		# Le carte del Narratore sono un mazzo a parte, e PASS non costa niente.
		if template == "PLAY_ECHO" or template == "PASS":
			out.append(offer)
			continue
		for asset_id in hand:
			var card: Variant = session.data.assets.get(str(asset_id))
			if card == null:
				continue
			# **Le due Azioni stampate, tutte e due** (D-283, passo 1 del brief
			# del Punto Zero). Fino a qui una carta si poteva calare solo col
			# verbo dichiarato in `card_action.kind`, e la seconda Azione della
			# faccia — che in 37 carte su 48 porta gia' un verbo eseguibile —
			# non veniva offerta mai: era stampata su un cartoncino che il
			# motore non girava. Adesso i verbi di una carta sono **quelli
			# stampati sulla sua faccia**, e ogni Azione che combacia col verbo
			# in corso diventa una voce sua, col suo nome.
			var printed: Array = (
				((card as Dictionary).get("physical", {}) as Dictionary).get("actions", [])
				as Array
			)
			for index in range(printed.size()):
				var face: Dictionary = printed[index] as Dictionary
				if str(face.get("template", "")) != template:
					continue
				var params: Dictionary = (
					(offer as Dictionary)["params"] as Dictionary
				).duplicate()
				params["asset_id"] = str(asset_id)
				params["face_action"] = index
				if not session.actions.can_execute(entity_id, "PLAY_CARD", params):
					continue
				# **E dove cadono i segni stampati** (D-284). Se questa meta'
				# posa segni di Regione e il verbo non ne nomina nessuna, il
				# posto e' una scelta vera — posare una condizione a casa
				# d'altri non e' come posarla a casa propria — e diventa una
				# voce per ogni luogo che la carta raggiunge. Sullo schermo si
				# accendono sulla mappa: si tocca la carta, si tocca il posto.
				var places: Array = [""]
				if str(params.get("region_id", "")) == "":
					var reachable: Array = session.actions.places_for_face(
						str(asset_id), index
					)
					if not reachable.is_empty():
						places = reachable
				for place in places:
					var here: Dictionary = params.duplicate()
					var where: String = str(place)
					if where != "":
						here["mark_region_id"] = where
					out.append({
						"label": "«%s» — %s%s" % [
							str((card as Dictionary)["title"]),
							str(face.get("label", (offer as Dictionary)["label"])),
							"" if where == ""
							else " · a %s" % _region(where, session),
						],
						"template": "PLAY_CARD", "params": here,
					# **Di cosa parla la scelta, e con che carta** (D-230). Il
					# bersaglio dell'offerta si perdeva qui: una MUOVERE nata
					# con `{"region": ...}` usciva avvolta in una carta e senza
					# piu' un posto, quindi lo schermo non poteva offrirla sulla
					# mappa e restava un bottone. `asset_id` viaggia accanto
					# perche' un front-end che disegna le carte deve sapere
					# **quale** carta porta quale scelta: e' quello che rende
					# possibile prenderla e lasciarla cadere invece di leggerne
					# il nome in una lista.
						"subject": _subject_with_card(
							offer as Dictionary, str(asset_id), index, where
						),
					})
	return out


## Il bersaglio di un'offerta, con dentro la carta che la porta **e il verbo
## che la carta userebbe** (D-279).
##
## Il verbo si perdeva qui, e senza di lui lo schermo non poteva legare
## un'offerta alle **due Azioni stampate sulla carta**: la mano mostrava carte
## che nessuno sapeva come usare, perche' l'unica cosa scritta accanto era
## l'etichetta grezza del motore. Con il verbo, «Chiamare la leva» e «Tenerli
## a casa» diventano i due bottoni che sono al tavolo.
static func _subject_with_card(
	offer: Dictionary, asset_id: String, face_action: int = -1, place: String = ""
) -> Dictionary:
	var subject: Dictionary = (offer.get("subject", {}) as Dictionary).duplicate()
	subject["asset"] = asset_id
	subject["verb"] = str(offer.get("template", ""))
	# **Quale delle due Azioni** (D-283): col solo verbo, due Azioni stampate
	# che usano lo stesso verbo finivano nello stesso mucchio sulla scheda della
	# carta, e chi guardava non sapeva quale stesse scegliendo.
	if face_action >= 0:
		subject["face_action"] = face_action
	# Il posto dei segni **e' un posto sullo schermo** (D-284, con D-230): una
	# scelta che nomina una Regione si accende sulla mappa, e la carta ci si
	# posa sopra. Senza questa riga la scelta sarebbe una riga di testo per un
	# luogo che sta disegnato due centimetri piu' in la'.
	if place != "" and str(subject.get("region", "")) == "":
		subject["region"] = place
	return subject


# --- the Council ------------------------------------------------------------

func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	if not _is_human(proponent):
		return fallback.choose_question(context, options, session)
	_speaking_to = proponent
	_say("")
	_say("  %s apre il Consiglio su %s." % [
		_name(proponent, session), _tension(str(context["tension_id"]), session),
	])
	var labels: Array = []
	for question in options:
		labels.append(session.confluence.say(str(question["text"])))
	var choice: int = await _choose("  Quale domanda poni?", labels)
	if choice < 0:
		return fallback.choose_question(context, options, session)
	return str(options[choice]["id"])


func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	if not _is_human(proponent):
		return fallback.choose_proposition(context, options, session)
	_speaking_to = proponent
	# **Cosa lascia al mondo**, non solo cosa dice (ISSUES 62/63, D-233).
	#
	# Fino a qui la proposta era una riga sola: la frase d'autore. Cosa scriveva
	# sulla mappa se passava stava in `success_consequences`, cioe' in un file che
	# chi gioca non apre. Si sceglieva fra tre frasi belle senza sapere quale
	# alzava una torre e quale lasciava una cicatrice — ed e' **la decisione
	# centrale del gioco**.
	#
	# La riga la scrive `CouncilText`, lo stesso posto che scrive la scheda: con
	# la voce del Consiglio i buchi li riempie la partita, sulla scheda si
	# spiegano. Due letture, una sorgente.
	# **La scheda della carta, non il template grezzo** (D-310, D-378): le
	# Domande e le Proposte stanno sulla carta Tensione, e quel dizionario
	# tiene ancora quelle di ripiego. Leggerlo di li' faceva sparire la riga
	# «se passa» — chi propone vedeva la frase e non cosa lasciava al mondo,
	# che e' proprio quello che D-233 aveva messo li'.
	var template: Dictionary = session.data.confluence_template_for(
		str(context["tension_id"])
	)
	var voice: Callable = Callable(session.confluence, "say")
	var labels: Array = []
	for proposition in options:
		var said: Dictionary = CouncilText.proposition(
			template, str(proposition["id"]), session.data, voice
		)
		labels.append(_proposition_label(said, session.confluence.say(str(proposition["text"]))))
	var choice: int = await _choose("  Cosa proponi?", labels)
	if choice < 0:
		return fallback.choose_proposition(context, options, session)
	return str(options[choice]["id"])


## Una proposta come si legge prima di sceglierla: la frase, e sotto cosa resta
## al mondo se passa. Se una proposta non lascia niente lo **dice**, invece di
## tacere: il silenzio si legge come «non lo so», e qui e' un fatto.
static func _proposition_label(said: Dictionary, fallback_text: String) -> String:
	if said.is_empty():
		return fallback_text
	var leaves: Array = []
	for record in said["consequences"]:
		var line: String = str((record as Dictionary)["leaves"])
		if line != "" and not leaves.has(line):
			leaves.append(line)
	if leaves.is_empty():
		return "%s\nNon lascia segni sul mondo." % str(said["text"])
	return "%s\nSe passa: %s" % [str(said["text"]), " · ".join(PackedStringArray(leaves))]


func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
	if not _is_human(entity_id):
		return fallback.choose_stance(entity_id, context, session)
	_speaking_to = entity_id
	# **La scheda della carta, non il template grezzo** (D-310, D-378): le
	# Domande e le Proposte stanno sulla carta Tensione, e quel dizionario
	# tiene ancora quelle di ripiego. Leggerlo di li' faceva sparire la riga
	# «se passa» — chi propone vedeva la frase e non cosa lasciava al mondo,
	# che e' proprio quello che D-233 aveva messo li'.
	var template: Dictionary = session.data.confluence_template_for(
		str(context["tension_id"])
	)
	var clauses: Array = template["condition_clauses"]

	var labels: Array = ["Sostieni", "Opponiti", "Astieniti"]
	var clause_ids: Array = []
	# Anche una clausola lascia qualcosa dietro, e anche quello stava solo nel
	# database: si sceglieva di qualificare senza sapere cosa si scriveva.
	var said_clauses: Array = CouncilText.clauses(
		template, session.data, Callable(session.confluence, "say")
	)
	for i in range(clauses.size()):
		var clause: Dictionary = clauses[i] as Dictionary
		clause_ids.append(str(clause["id"]))
		var leaves: String = "" if i >= said_clauses.size() else str(
			(said_clauses[i] as Dictionary)["leaves"]
		)
		labels.append("Sostieni a condizione che: %s%s" % [
			session.confluence.say(str(clause["text"])),
			"" if leaves == "" else "\nSe qualificata: %s" % leaves,
		])
	var choice: int = await _choose("  %s, cosa dici?" % _name(entity_id, session), labels)
	if choice < 0:
		return fallback.choose_stance(entity_id, context, session)
	match choice:
		0: return {"stance": "SUPPORT", "clause_id": ""}
		1: return {"stance": "OPPOSE", "clause_id": ""}
		2: return {"stance": "ABSTAIN", "clause_id": ""}
	return {"stance": "CONDITION", "clause_id": str(clause_ids[choice - 3])}
## **Il proponente compra** (D-280): posa le pedine sui benefici della carta,
## sapendo che ogni beneficio oltre il primo lo fara' pagare — e che a scegliere
## la moneta saranno gli altri.
func choose_benefits(
	entity_id: String, context: Dictionary, menu: Array, session: RefCounted
) -> Array:
	if not _is_human(entity_id):
		return fallback.choose_benefits(entity_id, context, menu, session)
	_speaking_to = entity_id
	var bought: Array = []
	# **Il tetto lo dicono i gettoni** (D-387): il primo e' gratis, ogni altro
	# costa un gettone di rivendicazione.
	var ceiling: int = session.confluence.benefit_ceiling()
	while bought.size() < ceiling:
		var labels: Array = []
		var ids: Array = []
		for voice in menu:
			var voice_id: String = str((voice as Dictionary)["id"])
			if bought.has(voice_id):
				continue
			ids.append(voice_id)
			labels.append(str((voice as Dictionary)["text"]))
		if ids.is_empty():
			break
		labels.append("Basta cosi'")
		var picked: int = await _choose(
			"  %s, cosa ottieni? (ne hai %d; %s)" % [
				_name(entity_id, session), bought.size(),
				"il primo e' gratis" if bought.is_empty()
					else "il prossimo costa un gettone, ne hai %d"
						% session.confluence.claim_tokens(entity_id),
			],
			labels
		)
		if picked < 0:
			# **Chi non risponde gioca come la policy** (patto di casa, provato
			# da test_hotseat): un tavolo muto deve fare la partita identica.
			# Fermarsi qui con quello che si era gia' preso la farebbe diversa.
			return fallback.choose_benefits(entity_id, context, menu, session)
		if picked >= ids.size():
			break
		bought.append(str(ids[picked]))
	return bought


## **E gli avversari scelgono in che moneta paga** (D-280): il primo seggio del
## fronte avverso posa `due` pedine sui costi stampati. A posizioni dichiarate
## e prima degli impegni, che restano segreti (D-267).
## **E si decide se pagare per far pagare** (D-387): un gettone di
## rivendicazione posa una pedina su un costo. Chi non ne ha, o non vuole, si
## astiene — e la proposta passa senza prezzo.
func choose_cost_token(
	entity_id: String, context: Dictionary, menu: Array, session: RefCounted
) -> String:
	if not _is_human(entity_id):
		return await fallback.choose_cost_token(entity_id, context, menu, session)
	_speaking_to = entity_id
	if session.confluence.claim_tokens(entity_id) <= 0 or menu.is_empty():
		return ""
	var labels: Array = ["Astieniti: non spendere il gettone"]
	var ids: Array = []
	for voice_id in menu:
		ids.append(str(voice_id))
		labels.append(str(session.confluence.price_voice_text("costs", str(voice_id))))
	var picked: int = await _choose(
		"  %s, hai %d gettone/i: vuoi far pagare la proposta?" % [
			_name(entity_id, session), session.confluence.claim_tokens(entity_id)
		],
		labels
	)
	if picked <= 0:
		return ""
	return str(ids[picked - 1])


func choose_costs(
	entity_id: String, context: Dictionary, menu: Array, due: int, session: RefCounted
) -> Array:
	if not _is_human(entity_id):
		return fallback.choose_costs(entity_id, context, menu, due, session)
	_speaking_to = entity_id
	var chosen: Array = []
	while chosen.size() < due:
		var labels: Array = []
		var ids: Array = []
		for voice_id in menu:
			if chosen.has(str(voice_id)):
				continue
			ids.append(str(voice_id))
			labels.append(str(session.confluence.price_voice_text("costs", str(voice_id))))
		if ids.is_empty():
			break
		var picked: int = await _choose(
			"  %s, la proposta passa pagando: scegli il prezzo (%d di %d)" % [
				_name(entity_id, session), chosen.size() + 1, due
			],
			labels
		)
		if picked < 0:
			return fallback.choose_costs(entity_id, context, menu, due, session)
		if picked >= ids.size():
			break
		chosen.append(str(ids[picked]))
	return chosen


## La controproposta del RIVENDICARE (D-268): il diritto guadagnato nell'Atto
## si puo' spendere qui - sulla pedina del prezzo o su una casella comprata
## sulla carta (D-304) - o tenere per il secondo dibattito.
func choose_counterclaim(
	entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted
) -> Dictionary:
	if not _is_human(entity_id):
		return fallback.choose_counterclaim(entity_id, context, offer, session)
	_speaking_to = entity_id
	var labels: Array = [
		"Tieni il diritto: aprirai il secondo dibattito",
		"Prendi la pedina del prezzo: scegli tu costo e sfogo",
	]
	# **Le caselle comprate sulla carta** (D-304): si rivendica una delle voci
	# che il proponente ha appena posato, non una frase di un altro elenco.
	var benefits: Array = offer.get("benefits", []) as Array
	for voice_id in benefits:
		labels.append("Rivendica «%s»: se la proposta passa, quella voce parla di te" % [
			session.confluence._voice_text("benefits", str(voice_id)),
		])
	var picked: int = await _choose(
		"  %s, hai un RIVENDICARE da spendere: controproposta?" % _name(entity_id, session),
		labels
	)
	if picked < 0:
		return fallback.choose_counterclaim(entity_id, context, offer, session)
	if picked == 0:
		return {}
	if picked == 1:
		# Prendersi la scelta del prezzo (D-268, riscritta da D-280): il
		# rivendicante decide **quali costi** paghera' chi vince, scavalcando
		# il primo OPPOSE. Ne sceglie quanti la proposta ne costa.
		var menu: Array = (offer.get("price", {}) as Dictionary).get("cost", []) as Array
		# Ne sceglie fino a due, che sono le pedine di costo che stanno sulla
		# carta (D-387): il diritto pagato col turno le posa senza gettoni.
		var chosen: Array = await choose_costs(
			entity_id, context, menu, CouncilEconomy.MAX_COSTS, session
		)
		return {
			"mode": "price",
			"cost": "" if chosen.is_empty() else str(chosen[0]),
			"failure": "" if chosen.size() < 2 else str(chosen[1]),
		}
	return {"mode": "benefit", "voice_id": str(benefits[picked - 2])}


## Commit one card at a time until the limit or "basta". The terminal could take
## a whole line of numbers and the browser cannot, so this is the shape both can
## drive - and it reads closer to what committing is: you put one thing down,
## then decide whether to put another.
func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
	_speaking_to = entity_id
	if not _is_human(entity_id):
		return fallback.choose_commit(entity_id, context, limit, session)
	var ranked: Array = session.service.ranked_hand_for_tension(
		entity_id, str(context["tension_id"])
	)
	if ranked.is_empty():
		return []
	var relevant: Array = session.service.relevant_families(str(context["tension_id"]))

	var chosen: Array = []
	while chosen.size() < limit:
		var remaining: Array = []
		var labels: Array = []
		for asset_id in ranked:
			if chosen.has(asset_id):
				continue
			var asset: Dictionary = session.data.assets[str(asset_id)]
			remaining.append(asset_id)
			# What it is worth *here*, and what it does on the way out. Choosing
			# what to put down without either is choosing blind, and a quarter of
			# the library now does something to the world when committed (D-042).
			labels.append("%s — %s, vale %d\n%s" % [
				str(asset["title"]), str(asset["family"]).to_lower(),
				AssetText.value_on(asset, relevant),
				# **Coi dati**, se no il nome della domanda resta l'id: la riga
				# diceva «costa: TEN_FAMINE scende» invece di «La Carestia
				# scende», ed e' proprio il difetto che il committente chiama
				# «tag o testi tecnici» (ISSUES 63). `note()` sa tradurre da
				# sola: bisogna solo darle il catalogo.
				AssetText.note(asset, session.data),
			])
		if remaining.is_empty():
			break
		labels.append("Non impegno altro")
		var picked: int = await _choose(
			"  %s impegna (%d di %d):" % [_name(entity_id, session), chosen.size(), limit],
			labels
		)
		if picked < 0:
			# "You decide" on an empty hand-so-far means the whole commit.
			return fallback.choose_commit(entity_id, context, limit, session) if chosen.is_empty() else chosen
		if picked >= remaining.size():
			break
		chosen.append(remaining[picked])
	return chosen


## §12.3: if the proposal falls, whoever opposed it keeps **one** of the cards
## they put down. This is the last decision the rules give a player, and until
## 0.1.5 it was the only one nobody was ever asked - the engine picked the
## strongest recoverable card and moved on.
##
## It is asked *before* the roll, because that is when the rules ask it: the
## controller collects the recovery alongside the commits and only uses it if
## the Council actually falls. So the question is a real one - you are naming
## what you would save from a defeat that has not happened yet.
##
## Asked only when there is something to decide: a seat that did not oppose has
## no recovery, and one card left standing is not a choice.
func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
	var recovery: Dictionary = fallback.choose_recovery(context, session)
	for entity_id in humans:
		var seat: String = str(entity_id)
		_speaking_to = seat
		var stance: Dictionary = (context.get("stances", {}) as Dictionary).get(seat, {})
		if str(stance.get("stance", "")) != "OPPOSE":
			continue
		var options: Array = []
		var labels: Array = []
		for asset_id in (context.get("commits", {}) as Dictionary).get(seat, []):
			var asset: Variant = session.data.assets.get(str(asset_id))
			# ALWAYS_DISCARD never comes back, whoever wins: offering it would be
			# offering a choice the resolver is about to ignore.
			if asset == null or str(asset["discard_or_retain_rule"]) == "ALWAYS_DISCARD":
				continue
			options.append(str(asset_id))
			labels.append("%s — %s, forza %d" % [
				str(asset["title"]), str(asset["family"]).to_lower(), int(asset["strength"]),
			])
		if options.size() < 2:
			continue
		var choice: int = await _choose(
			"  %s, se la proposta cade quale carta ti riprendi?" % _name(seat, session), labels
		)
		if choice >= 0:
			recovery[seat] = str(options[choice])
	return recovery


# --- what a player needs to see --------------------------------------------

## The board, from one seat. Everything here is already public to that seat -
## a veiled Tension shows a number only to someone who has scouted it (§11.1).
func _board(entity_id: String, session: RefCounted) -> String:
	var world: Dictionary = session.world
	var lines: Array = []
	lines.append("+-- ATTO %d, ROUND %d %s" % [
		int(world["act"]), int(world["round"]), "-".repeat(40),
	])

	var questions: Array = []
	for tension_id in _sorted(world["tensions"].keys()):
		questions.append("%s %s" % [
			_tension(str(tension_id), session),
			_tension_reading(str(tension_id), entity_id, session),
		])
	lines.append("| Le domande dell'anno: %s" % ", ".join(PackedStringArray(questions)))

	var places: Array = []
	for region_id in _sorted(world["regions"].keys()):
		var mine: int = session.service.presence_count(entity_id, str(region_id))
		var control: Variant = world["regions"][str(region_id)].get("control", null)
		# ISSUES 22 (fase 2): la mappa non nasconde. Nella partita 15308 la
		# Valle Verde - contesa e senza controllore - non e' mai apparsa qui
		# per due atti. Una Regione segnata si vede anche senza presidi.
		var signs: Array = []
		for tag in world["regions"][str(region_id)]["tags"]:
			for prefix in ["condition:", "scar:", "structure:", "settlement:"]:
				if str(tag).begins_with(prefix):
					signs.append(SignLabels.label(str(tag), session.data))
					break
		if mine == 0 and control == null and signs.is_empty():
			continue
		var mark: String = ""
		if mine > 0:
			mark += "1 tuo" if mine == 1 else "%d tuoi" % mine
		if control != null:
			mark += "%s%s" % ["/" if mark != "" else "", _name(str(control), session)]
		if not signs.is_empty():
			mark += "%s%s" % ["; " if mark != "" else "", ", ".join(PackedStringArray(signs))]
		places.append("%s (%s)" % [_region(str(region_id), session), mark])
	lines.append("| Sulla mappa: %s" % ", ".join(PackedStringArray(places)))

	var cards: Array = []
	for asset_id in session.service.hand(entity_id):
		cards.append(str(session.data.assets[str(asset_id)]["title"]))
	lines.append("| In mano: %s" % ("niente" if cards.is_empty() else ", ".join(PackedStringArray(cards))))
	lines.append("| %s" % _destiny_line(entity_id, session))
	return "\n".join(PackedStringArray(lines))


## The Destiny as a ladder, marking which rung holds right now. A player cannot
## steer towards a goal they cannot read.
func _destiny_line(entity_id: String, session: RefCounted) -> String:
	var definition: Variant = session.data.entities.get(entity_id)
	if definition == null:
		return ""
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(entity_id))
	if destiny == null:
		return ""
	var rungs: Array = []
	for level in ["minimum", "victory", "triumph"]:
		var holds: bool = session.destinies.conditions.all_hold(destiny[level]["conditions"], {"self": entity_id})
		rungs.append("%s %s" % ["[x]" if holds else "[ ]", str(destiny[level]["label"])])
	return "Il tuo Destino: %s" % "  ".join(PackedStringArray(rungs))


func _tension_reading(tension_id: String, viewer_id: String, session: RefCounted) -> String:
	var value: int = session.service.visible_tension_value(tension_id, viewer_id)
	if value < 0:
		return "(velata)"
	# Col cancello del tavolo non c'e' nessun numero da raggiungere (D-203):
	# scrivere «4/?» farebbe cercare una soglia che non esiste. Quello che conta
	# e' l'altezza del mucchio, e se e' il piu' alto.
	if session.tensions.table_gate() > 0:
		# **Coperto, nemmeno il seggio vede il punteggio** (ISSUES 49 fase 3).
		# Questa e' la scheda che una persona ha in mano: se qui il numero
		# restasse scritto, coprire il verbale pubblico sarebbe teatro.
		if session.tensions.piles_are_covered():
			var pile: int = session.tensions.tokens_on(tension_id)
			return "%d %s coperti" % [pile, "gettone" if pile == 1 else "gettoni"]
		return "%d%s" % [
			value, " ← il più alto" if session.tensions.hottest_pile() == tension_id else ""
		]
	var threshold: int = session.service.visible_tension_threshold(tension_id, viewer_id)
	# La soglia coperta si dice con un punto interrogativo, non con un numero
	# inventato: al tavolo vero e' la carta girata a faccia in giu' (D-187).
	if threshold < 0:
		return "%d/?" % value
	return "%d/%d" % [value, threshold]


func _name(entity_id: String, session: RefCounted) -> String:
	var entity: Variant = session.data.entities.get(entity_id)
	return entity_id if entity == null else str(session.service.name_of(entity_id))


func _region(region_id: String, session: RefCounted) -> String:
	var region: Variant = session.data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


func _tension(tension_id: String, session: RefCounted) -> String:
	var tension: Variant = session.data.tensions.get(tension_id)
	return tension_id if tension == null else str(tension["title"])


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out
