extends SceneTree
## **Tutte le rose possibili, stese dal motore** (D-390, riscritta da D-510).
##
##   godot --headless --path godot --script res://cli/run_tiles_probe.gd
##
## Richiesta del committente, e resta la stessa: *«devi calcolare dopo aver
## deciso i varchi tutte le possibili combinazioni e capire quante combinazioni
## rendono tessere isolate»*.
##
## Quello che e' cambiato e' quante sono. Con le tessere quadrate che si
## posavano girandole (D-390) le pose erano **C(10,6) = 210 pescate x 720
## ordini = 151.200**, e questa sonda le faceva tutte in quattro minuti. Con la
## rosa esagonale (D-510) le caselle sono sette e fisse, la tessera non si gira,
## e l'ordine di pesca non conta: le rose possibili sono **il prodotto delle
## candidate di ogni casella**, e si contano in un secondo.
##
## La sonda le enumera **chiamando la posa del motore** — `_lay_the_rose` — e
## non riscrivendola: una sonda che reimplementa la regola che sta provando
## prova la sua copia, non il gioco. Per ogni rosa si guardano tre cose:
##
## 1. **le caselle riempite**: sette, o meno?
## 2. **la connessione**: dalla capitale si arriva ovunque? Due petali stanno
##    **dietro** una vicina, e ci si deve arrivare lo stesso.
## 3. **le strade morte**: un varco che guarda un muro. Il posto fisso le rende
##    impossibili per costruzione, e qui si verifica invece di crederci.
##
## La stessa promessa la sorveglia anche `validate_physical`, dal lato dei dati.
## Questa la guarda dal lato del **motore**: sono due strade diverse verso lo
## stesso numero, ed e' voluto.

const DataSet := preload("res://scripts/core/data_set.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")

const CASELLE: Array = ["C", "P1", "P2", "P3", "P4", "P5", "P6"]

var _out: Array = []


func _say(line: String = "") -> void:
	_out.append(line)


func _initialize() -> void:
	var options: Dictionary = {}
	for arg in OS.get_cmdline_user_args():
		var text: String = str(arg)
		if text.begins_with("--out="):
			options["out"] = text.substr(6)
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Le candidate di ogni casella, dal dato. Il parco non si ricopia qui: una
	# tessera nuova in scatola deve comparire in questo documento da sola.
	var per_casella: Dictionary = {}
	var chronicle: Dictionary = data.chronicles["CHR_00"]
	for region_id in ((chronicle.get("region_pool", {}) as Dictionary).get("candidates", []) as Array):
		var slot: String = str((data.regions[str(region_id)] as Dictionary).get("map_slot", ""))
		if not per_casella.has(slot):
			per_casella[slot] = []
		(per_casella[slot] as Array).append(str(region_id))
	for slot in per_casella:
		(per_casella[slot] as Array).sort()

	_say("# ECHOES — tutte le rose possibili, enumerate")
	_say("")
	_say("<!-- FILE GENERATO — si rifa' con `tools/run_tiles_probe.sh`. -->")
	_say("")
	_say("La promessa del committente (D-390): *«deve essere calcolato in modo che")
	_say("ci sia sempre la possibilita' di muoversi in tutte le tessere pescate, e")
	_say("che quindi non ci siano tessere isolate»*. Non si campiona: si enumera.")
	_say("Con la rosa (D-510) le rose possibili sono poche abbastanza da guardarle")
	_say("**tutte**, e questa sonda le stende **col motore**.")
	_say("")
	_say("```")
	var rose: Array = _every_rose(per_casella)
	_say("  %d caselle, %d tessere nel parco." % [CASELLE.size(), data.regions.size()])
	for slot in CASELLE:
		var quali: Array = (per_casella.get(str(slot), []) as Array)
		_say("    %-3s %d candidat%s: %s" % [
			str(slot), quali.size(), "a" if quali.size() == 1 else "e",
			" · ".join(PackedStringArray(quali)),
		])
	_say("  **Rose possibili: %d**" % rose.size())
	_say("")

	var incomplete: int = 0
	var sconnesse: int = 0
	var morte: int = 0
	var archi_totali: int = 0
	var vicoli: int = 0
	var tessere_poste: int = 0
	var dietro_conta: Dictionary = {}

	for rosa in rose:
		var world: Dictionary = {}
		WorldStateFactory._lay_the_rose(world, {"regions": rosa}, data)
		var posate: Dictionary = world["map_positions"] as Dictionary
		var vicini: Dictionary = world["adjacency"] as Dictionary
		if posate.size() < CASELLE.size():
			incomplete += 1

		# La connessione si guarda **dalla capitale**, che e' il posto da cui una
		# persona guarda il tavolo.
		var capitale: String = ""
		for region_id in (rosa as Array):
			if str((data.regions[str(region_id)] as Dictionary).get("map_slot", "")) == "C":
				capitale = str(region_id)
		var visti: Dictionary = {}
		if capitale != "":
			var coda: Array = [capitale]
			while not coda.is_empty():
				var qui: String = str(coda.pop_back())
				if visti.has(qui):
					continue
				visti[qui] = true
				for n in (vicini.get(qui, []) as Array):
					coda.append(str(n))
		if visti.size() < posate.size():
			sconnesse += 1

		# Le strade morte: un varco stampato che non trova il suo gemello.
		for region_id in (rosa as Array):
			var aperti: int = ((data.regions[str(region_id)] as Dictionary).get("edges", []) as Array).size()
			var usati: int = (vicini.get(str(region_id), []) as Array).size()
			morte += maxi(0, aperti - usati)

		for tile in posate:
			var grado: int = (vicini.get(str(tile), []) as Array).size()
			archi_totali += grado
			tessere_poste += 1
			if grado <= 1:
				vicoli += 1
		# Chi sta **dietro** una vicina: non tocca la capitale.
		if capitale != "":
			for region_id in (rosa as Array):
				if str(region_id) == capitale:
					continue
				if not (vicini.get(capitale, []) as Array).has(str(region_id)):
					dietro_conta[str(region_id)] = int(dietro_conta.get(str(region_id), 0)) + 1

	_say("== LA DOMANDA ==")
	_say("  rose che lasciano una casella vuota   %6d  (%.3f%%)" % [
		incomplete, 100.0 * float(incomplete) / float(maxi(1, rose.size()))
	])
	_say("  rose che lasciano una tessera isolata %6d  (%.3f%%)" % [
		sconnesse, 100.0 * float(sconnesse) / float(maxi(1, rose.size()))
	])
	_say("  varchi che guardano un muro           %6d  (strade morte)" % morte)
	_say("")
	_say("  E com'e' fatta la rosa, su tutte:")
	_say("    confini per mappa      %.2f" % (
		float(archi_totali) / 2.0 / float(maxi(1, rose.size()))
	))
	_say("    tessere con un vicino solo  %.1f%%" % (
		100.0 * float(vicoli) / float(maxi(1, tessere_poste))
	))
	if not dietro_conta.is_empty():
		_say("")
		_say("  Le tessere che stanno **dietro** una vicina (non toccano la capitale):")
		var chi: Array = dietro_conta.keys()
		chi.sort()
		for tile in chi:
			_say("    %-24s in %d rose su %d" % [str(tile), int(dietro_conta[tile]), rose.size()])
	_say("```")
	var testo: String = "\n".join(PackedStringArray(_out)) + "\n"
	var dove: String = str(options.get("out", ""))
	if dove == "":
		print(testo)
	else:
		var handle: FileAccess = FileAccess.open(dove, FileAccess.WRITE)
		if handle == null:
			printerr("non si scrive su %s" % dove)
			quit(3)
			return
		handle.store_string(testo)
		handle.close()
	quit(0)


## Tutte le rose: una candidata per casella, in ordine stabile.
func _every_rose(per_casella: Dictionary) -> Array:
	var out: Array = [[]]
	for slot in CASELLE:
		var quali: Array = (per_casella.get(str(slot), []) as Array)
		if quali.is_empty():
			continue
		var next: Array = []
		for parziale in out:
			for region_id in quali:
				var copia: Array = (parziale as Array).duplicate()
				copia.append(str(region_id))
				next.append(copia)
		out = next
	return out
