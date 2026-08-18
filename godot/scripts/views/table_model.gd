extends RefCounted
## La vista TAVOLO come dati (voce 27, fase 1 — D-134).
##
## Il tavolo e' la vetrina: mappa, domande, Consigli chiusi, carte del mondo,
## verbale. **Niente segreti di seggio**: questo modello si costruisce col
## viewer pubblico ("") — una Tensione velata vale -1 (il dorso della carta),
## le mani non esistono, i Destini nemmeno. In fase 2 questo dizionario e' il
## messaggio `state` che l'host manda allo schermo grande: la disciplina dei
## segreti sul filo nasce qui, non nel trasporto.
##
## Solo lettura, come i pannelli: costruire il modello non muove il mondo.

const SignLabels := preload("res://scripts/core/sign_labels.gd")


static func build(session: RefCounted) -> Dictionary:
	var world: Dictionary = session.world
	var data: RefCounted = session.data
	var out: Dictionary = {
		"year": int(world.get("year", 0)),
		"act": int(world.get("act", 0)),
		"round": int(world.get("round", 0)),
		"phase": str(world.get("phase", "")),
		"tensions": [],
		"regions": [],
		"councils": [],
		"echoes_played": [],
		"verbale": [],
	}

	# Le domande, come le vede il tavolo: una velata mostra il dorso (-1),
	# anche se qualche seggio ne ha sbirciato il numero con lo SCHEME.
	var tension_ids: Array = (world["tensions"] as Dictionary).keys()
	tension_ids.sort()
	for tension_id in tension_ids:
		(out["tensions"] as Array).append({
			"title": str(data.tensions[str(tension_id)]["title"]),
			"domain": SignLabels.domain(str(data.tensions[str(tension_id)]["domain"])),
			"value": session.service.visible_tension_value(str(tension_id), ""),
			"threshold": int(data.tensions[str(tension_id)]["threshold"]),
			"open": session.service.is_tension_open(str(tension_id)),
		})

	# La mappa e' il mondo, e il mondo e' pubblico: padroni, segni, pedine.
	var region_ids: Array = (world["regions"] as Dictionary).keys()
	region_ids.sort()
	for region_id in region_ids:
		var region: Dictionary = world["regions"][str(region_id)]
		var holder: Variant = region.get("control", null)
		var marks: Array = []
		var tags: Array = (region.get("tags", []) as Array).duplicate()
		tags.sort()
		for tag in tags:
			marks.append(SignLabels.label(str(tag), data))
		var presences: Array = []
		for entity_id in world["turn_order"]:
			var count: int = session.service.presence_count(str(entity_id), str(region_id))
			if count > 0:
				presences.append({
					"name": session.service.name_of(str(entity_id)),
					"count": count,
				})
		(out["regions"] as Array).append({
			"name": str(data.regions[str(region_id)]["name"]),
			"holder": "" if holder == null else session.service.name_of(str(holder)),
			"marks": marks,
			"presences": presences,
		})

	# I Consigli gia' chiusi quest'anno: esito e proponente sono fatti del
	# tavolo (gli impegni si rivelano tutti insieme in seduta, D-014).
	for result in session.chronicle.confluence_results:
		(out["councils"] as Array).append({
			"tension": str(data.tensions[str(result["tension_id"])]["title"]),
			"outcome": str(result["outcome"]),
			"proponent": session.service.name_of(str(result["proponent"])),
		})

	# Le carte che il mondo ha calato: la faccia in tavola.
	for card_id in world["echo_deck"]["drawn"]:
		var card: Variant = data.echo_cards.get(str(card_id))
		if card != null:
			(out["echoes_played"] as Array).append(str(card["title"]))

	# Il verbale e' pubblico per contratto (game_log.gd): i segreti di seggio
	# passano da io.say e non lo toccano mai.
	for line in session.log.lines:
		(out["verbale"] as Array).append(str(line))
	return out


## L'ispezione (la C della seduta: tocchi che guardano, mai che decidono).
## Il dettaglio pubblico di una Regione per il pannello del tavolo.
static func region_detail(session: RefCounted, region_id: String) -> Dictionary:
	var model: Dictionary = build(session)
	var name: String = str(session.data.regions.get(region_id, {}).get("name", region_id))
	for region in model["regions"]:
		if str((region as Dictionary)["name"]) == name:
			return region
	return {}
