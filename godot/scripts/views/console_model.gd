extends RefCounted
## La vista CONSOLE come dati (voce 27, fase 1 — D-134).
##
## La console e' il telefono di UN seggio: il suo pannello, la sua mano, il
## suo Destino, le domande che gli arrivano. Tutto qui dentro e' cio' che quel
## seggio ha diritto di leggere — la regola dei pixel (§11.1) applicata ai
## dati prima che al disegno. In fase 2 questo dizionario e' il messaggio
## `state` che l'host manda a quella console e a nessun'altra: il filtro sta
## nella costruzione, non nel trasporto.
##
## Solo lettura: costruire il modello non muove il mondo.

const SignLabels := preload("res://scripts/core/sign_labels.gd")
const Ids := preload("res://scripts/core/ids.gd")


static func build(session: RefCounted, seat_id: String) -> Dictionary:
	var world: Dictionary = session.world
	var data: RefCounted = session.data
	var seat: Variant = world["entities"].get(seat_id)
	if seat == null:
		return {}
	var out: Dictionary = {
		"name": session.service.name_of(seat_id),
		"generation": int((seat as Dictionary).get("generation", 0)),
		"year": int(world.get("year", 0)),
		"act": int(world.get("act", 0)),
		"round": int(world.get("round", 0)),
		"tensions": [],
		"hand": [],
		"echo_hand": [],
		"destiny": {},
		"relations": [],
		"signs": [],
		"rights": [],
	}

	# Le domande come le vede QUESTO seggio: una velata che ha sbirciato con
	# lo SCHEME mostra il numero — e' il vantaggio che la console protegge.
	var tension_ids: Array = (world["tensions"] as Dictionary).keys()
	tension_ids.sort()
	for tension_id in tension_ids:
		(out["tensions"] as Array).append({
			"title": str(data.tensions[str(tension_id)]["title"]),
			"value": session.service.visible_tension_value(str(tension_id), seat_id),
			# La soglia la vede chi ha girato la carta con lo SCOPRIRE, o
			# nessuno: -1 e' il dorso (D-187).
			"threshold": session.service.visible_tension_threshold(str(tension_id), seat_id),
		})

	# La mano: titoli, famiglie e l'id con cui la console chiede la faccia
	# (D-144). Mai fuori da questa console: *quali* copie tieni e' il segreto,
	# e la perquisizione lo prova carta per carta su questo campo.
	for asset_id in session.service.hand(seat_id):
		var asset: Variant = data.assets.get(str(asset_id))
		if asset != null:
			(out["hand"] as Array).append({
				"id": str(asset_id),
				"title": str(asset["title"]),
				"family": str(asset["family"]),
			})
	for card_id in (seat as Dictionary).get("echo_hand", []):
		var card: Variant = data.echo_cards.get(str(card_id))
		if card != null:
			(out["echo_hand"] as Array).append({
				"id": str(card_id),
				"title": str(card["title"]),
			})

	# I quattro obiettivi, se la Chronicle li dichiara (D-198): il palese per
	# primo, poi i tre che ha pescato e che nessun altro conosce. E' la stessa
	# casella `destiny` — chi legge il modello guarda `rungs` e trova quattro
	# righe invece di tre — perche' la scala **e'** quella, quando la regola e'
	# accesa: il pannello non deve sapere che regola sta girando.
	var taken: Array = session.destinies.objectives_of(seat_id)
	if not taken.is_empty():
		var lines: Array = []
		for entry in taken:
			var record: Dictionary = entry as Dictionary
			lines.append({
				"label": "%s%s" % [
					"" if bool(record["public"]) else "(coperto) ", str(record["label"])
				],
				"holds": bool(record["met"]),
			})
		out["destiny"] = {
			"title": "I tuoi quattro obiettivi",
			"rungs": lines,
		}

	# La scala del Destino, coi gradini gia' spuntati (D-101: la vede solo
	# chi la giura). Non si legge quando gli obiettivi hanno preso il suo posto.
	var destiny: Variant = data.destinies.get(session.service.destiny_of(seat_id))
	if destiny != null and taken.is_empty():
		var rungs: Array = []
		for level in ["minimum", "victory", "triumph"]:
			rungs.append({
				"label": str((destiny as Dictionary)[level]["label"]),
				"holds": session.destinies.conditions.all_hold(
					(destiny as Dictionary)[level]["conditions"], {"self": seat_id}
				),
			})
		out["destiny"] = {
			"title": str((destiny as Dictionary)["title"]),
			"rungs": rungs,
		}

	# I rapporti del seggio, i suoi segni, i Diritti (questi ultimi sono
	# pubblici: la console li mostra per comodita', col proprio evidenziato).
	for other in world["turn_order"]:
		if str(other) == seat_id:
			continue
		(out["relations"] as Array).append({
			"name": session.service.name_of(str(other)),
			"level": session.service.relation_level(seat_id, str(other)),
		})
	var tags: Array = ((seat as Dictionary)["tags"] as Array).duplicate()
	tags.sort()
	for tag in tags:
		(out["signs"] as Array).append(SignLabels.label(str(tag), data))
	for claim in world.get("claims", []):
		(out["rights"] as Array).append({
			"holder": session.service.name_of(str((claim as Dictionary).get("entity_id", ""))),
			"domain": SignLabels.domain(str((claim as Dictionary).get("domain", ""))),
			"mine": str((claim as Dictionary).get("entity_id", "")) == seat_id,
		})
	return out
