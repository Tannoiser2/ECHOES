extends RefCounted
## **Dove una Pietra si puo' alzare** — la domanda scritta una volta sola.
##
## Le tre condizioni erano gia' nel motore, ma vivevano **dentro** l'Effetto che
## costruisce (`effect_applier._build_structure`, D-365) e li' si comportavano da
## no-op silenzioso: una frase d'autore che nomina la terra sbagliata non e' un
## errore, e' una frase che non aveva niente da dire in quel posto.
##
## Da [D-412](../../../docs/DECISIONS.md#d-412) le stesse tre condizioni servono
## a **un'altra domanda**: ACQUISIRE puo' alzare una Pietra, e li' un no-op
## silenzioso sarebbe il difetto peggiore di tutti — un'azione legale che non fa
## niente e non avvisa. Chi gioca deve sentirsi dire **perche'** non si puo',
## la sedia automatica non deve proporla, e l'app deve spegnere il bersaglio.
##
## Quindi la domanda sta qui, pura, e la fanno tutt'e due: l'Effetto per tacere,
## l'Azione per rifiutare a voce alta.
##
## Al tavolo e' una cosa sola: **prendi il segnalino della Pietra e guarda se ci
## sta.** Ci sta se la tessera e' della terra giusta, se ha ancora un posto
## libero, e se quella Pietra non c'e' gia'.


## Perche' quella Pietra non si puo' alzare li', o "" se si puo'.
##
## Non guarda **chi** la alza: la presenza, il costo, l'Opportunita' sono
## dell'azione, non della terra. Qui c'e' solo la domanda della mappa.
static func refusal(
	data: RefCounted, world: Dictionary, region_id: String, type_id: String
) -> String:
	var region: Variant = world["regions"].get(region_id)
	if region == null:
		return "regione sconosciuta '%s'" % region_id
	var definition: Variant = data.structure_types.get(type_id)
	if definition == null:
		return "Pietra sconosciuta '%s'" % type_id
	var definizione: Dictionary = definition as Dictionary
	var sheet: Dictionary = data.regions[region_id] as Dictionary

	for standing in (region["structures"] as Array):
		if str((standing as Dictionary).get("structure_type", "")) == type_id:
			return "%s c'e' gia' a %s" % [str(definizione["name"]), str(sheet["name"])]

	# **Le Pietre della terra non si alzano**: bosco, sorgente, passo, sito
	# antico — tutte `owned: false` — sono la tessera, non ci si costruiscono
	# sopra. Una regola che nel motore era implicita e che qui va detta, perche'
	# adesso c'e' qualcuno che potrebbe provarci.
	if not bool(definizione["owned"]):
		return "%s non si costruisce: e' la terra" % str(definizione["name"])

	# **La terra decide cosa ci si costruisce** (D-365, ISSUES 116).
	if not (definizione.get("biomes", []) as Array).has(str(sheet["biome"])):
		return "%s non sta in questa terra" % str(definizione["name"])

	# **E un posto pieno blocca** (D-365). Contano solo le Pietre di qualcuno:
	# quelle della terra non occupano un posto.
	if occupied_slots(data, region) >= int(sheet["build_slots"]):
		return "%s non ha piu' posto per una Pietra" % str(sheet["name"])
	return ""


## Quanti dei posti della tessera sono presi. Le Pietre della terra non contano.
static func occupied_slots(data: RefCounted, region: Dictionary) -> int:
	var taken: int = 0
	for standing in (region["structures"] as Array):
		var kind: Variant = data.structure_types.get(
			str((standing as Dictionary).get("structure_type", ""))
		)
		if kind != null and bool((kind as Dictionary)["owned"]):
			taken += 1
	return taken


## Le Pietre che qualcuno puo' alzare, in ordine di id. Sono le `owned`: le
## altre sono la tessera.
static func raisable(data: RefCounted) -> Array:
	var out: Array = []
	for type_id in data.structure_types:
		if bool((data.structure_types[type_id] as Dictionary)["owned"]):
			out.append(str(type_id))
	out.sort()
	return out
