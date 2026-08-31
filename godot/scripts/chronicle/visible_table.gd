extends RefCounted
## Il tavolo visibile (PZ-6, D-269): quello che a fine Chronicle si legge
## **guardando il tavolo**, e niente altro.
##
## La roadmap chiede che la Chronicle successiva nasca dai segni visibili e
## che si possa rimontare il tavolo leggendo solo quello che c'e' sopra. Questa
## e' la lista, ed e' una lista **chiusa**: ogni voce corrisponde a un pezzo
## fisico che resta sul tavolo o sul foglio della saga a partita finita. La
## prova `test_visible_handover.gd` la tiene onesta - se l'eredita' legge un
## campo che non sta qui, la prova va rossa, e la scelta e' due volte sola:
## o il campo diventa un pezzo fisico dichiarato in
## docs/PROCEDURA_FINE_CHRONICLE.md, o il motore smette di leggerlo.
##
## Quello che NON passa - ed e' il punto: l'ordine dei mazzi (si rimescola),
## le mani (si ridanno), la memoria dei bot (`voted_together`), le domande
## gia' poste (`questions_asked` e' dell'anno), i diritti pendenti
## (`forced_confluence`), i gettoni e i registri interni del motore.


## I campi che ogni seggio lascia leggibili: sulla carta del casato (nome,
## generazione, vita, ere a mani vuote), sul foglio della saga (punteggio,
## obiettivi coperti), i segni vivi addosso — e **le pedine sulla mappa**: la
## presenza e' del casato, posata sulle tessere, e si conta guardando.
const ENTITY_FIELDS: Array = [
	"name", "destiny_id", "generation", "incarnation", "barren", "active",
	"tags", "saga_score", "objectives", "presence",
]

## I campi che ogni tessera lascia leggibili: i segni, chi la tiene, le
## pietre col loro grado e il loro padrone.
const REGION_FIELDS: Array = ["tags", "control", "structures"]

## I campi che ogni carta Tensione in gioco lascia leggibili: il segnalino
## del valore, la faccia (palese o coperta), i presagi gia' scattati e
## quante volte e' stata decisa - il conto delle decisioni sta nel diario.
const TENSION_FIELDS: Array = [
	"current_value", "visibility", "fired_omens", "resolved_count",
]


## Il mondo ridotto a quello che il tavolo mostra. E' l'input della prova:
## se `inherit_from` su questo produce lo stesso mondo che sul mondo intero,
## la procedura fisica basta davvero.
static func read(world: Dictionary) -> Dictionary:
	var out: Dictionary = {
		"year": int(world.get("year", 0)),
		"chronicles_played": int(world.get("chronicles_played", 0)),
		"global_tags": (world.get("global_tags", []) as Array).duplicate(true),
		"scars": (world.get("scars", []) as Array).duplicate(true),
		"echo_log": (world.get("echo_log", []) as Array).duplicate(true),
		# Le carte Eco calate stanno scoperte sul tavolo: sono visibili per
		# definizione, e l'era dopo le eredita (D-358).
		"echo_played": (world.get("echo_played", []) as Array).duplicate(true),
		"truth_log": (world.get("truth_log", []) as Array).duplicate(true),
		"relations": (world.get("relations", {}) as Dictionary).duplicate(true),
		"regions": {},
		"entities": {},
		"tensions": {},
	}
	for region_id in world.get("regions", {}):
		var region: Dictionary = world["regions"][str(region_id)]
		var seen: Dictionary = {}
		for field in REGION_FIELDS:
			if region.has(str(field)):
				seen[str(field)] = _copy(region[str(field)])
		out["regions"][str(region_id)] = seen
	for entity_id in world.get("entities", {}):
		var entity: Dictionary = world["entities"][str(entity_id)]
		var seen: Dictionary = {}
		for field in ENTITY_FIELDS:
			if entity.has(str(field)):
				seen[str(field)] = _copy(entity[str(field)])
		out["entities"][str(entity_id)] = seen
	for tension_id in world.get("tensions", {}):
		var tension: Dictionary = world["tensions"][str(tension_id)]
		var seen: Dictionary = {"id": str(tension_id)}
		for field in TENSION_FIELDS:
			if tension.has(str(field)):
				seen[str(field)] = _copy(tension[str(field)])
		out["tensions"][str(tension_id)] = seen
	return out


static func _copy(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
