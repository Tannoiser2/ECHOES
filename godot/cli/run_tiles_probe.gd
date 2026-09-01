extends SceneTree
## **Tutte le pose possibili delle tessere, enumerate** (D-390, richiesta del
## committente: *«devi calcolare dopo aver deciso i varchi tutte le possibili
## combinazioni e capire quante combinazioni rendono tessere isolate»*).
##
##   godot --headless --path godot --script res://cli/run_tiles_probe.gd
##
## Duecento semi sono un campione. Le combinazioni vere sono
## **C(10,6) = 210 pescate x 6! = 720 ordini = 151.200 pose**, e questa sonda le
## fa tutte, chiamando **la posa del motore** — `WorldStateFactory._lay_the_tiles`
## — invece di riscriverla: una sonda che reimplementa la regola che sta provando
## prova la sua copia, non il gioco.
##
## Per ogni posa si guardano due cose diverse:
##
## 1. **le tessere posate**: sei, o meno? Una che non si attacca da nessuna
##    parte resta in mano.
## 2. **la connessione**: dalla prima si arriva a tutte? La posa la garantisce
##    per costruzione — si entra solo attraverso un varco — ma una promessa per
##    costruzione va verificata, non creduta.

const DataSet := preload("res://scripts/core/data_set.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")


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

	var pool: Array = []
	var chronicle: Dictionary = data.chronicles["CHR_00"]
	for region_id in ((chronicle.get("region_pool", {}) as Dictionary).get("candidates", []) as Array):
		pool.append(str(region_id))
	pool.sort()
	var quante: int = int((chronicle.get("region_pool", {}) as Dictionary).get("count", 6))

	_say("# ECHOES — tutte le pose delle tessere, enumerate")
	_say("")
	_say("<!-- FILE GENERATO — si rifa' con `tools/run_tiles_probe.sh`. -->")
	_say("")
	_say("La promessa del committente (D-390): *«deve essere calcolato in modo che")
	_say("ci sia sempre la possibilita' di muoversi in tutte e sei le tessere")
	_say("pescate, e che quindi non ci siano tessere isolate»*. Duecento semi sono")
	_say("un campione; qui ci sono **tutte** le pose che il gioco puo' produrre.")
	_say("")
	_say("```")
	_say("  %d tessere nel parco, %d pescate." % [pool.size(), quante])
	var combinazioni: Array = _combinations(pool, quante)
	_say("  Pescate possibili: %d" % combinazioni.size())

	var pose: int = 0
	var incomplete: int = 0
	var sconnesse: int = 0
	var peggiori: Dictionary = {}   # pescata -> quante pose lasciano fuori qualcuno
	var mai: Dictionary = {}        # tessera -> quante volte e' rimasta in mano
	var pescate_rotte: int = 0
	var archi_totali: int = 0
	var vicoli: int = 0
	var tessere_poste: int = 0

	for combo in combinazioni:
		var rotte_qui: int = 0
		for order in _permutations(combo as Array):
			pose += 1
			var world: Dictionary = {}
			var finta: Dictionary = {"regions": order}
			WorldStateFactory._lay_the_tiles(world, finta, data)
			var posate: Dictionary = world["map_positions"] as Dictionary
			var vicini: Dictionary = world["adjacency"] as Dictionary
			if posate.size() < quante:
				incomplete += 1
				rotte_qui += 1
				for tile in (order as Array):
					if not posate.has(str(tile)):
						mai[str(tile)] = int(mai.get(str(tile), 0)) + 1
			# La connessione, su quello che e' stato posato.
			var chiavi: Array = posate.keys()
			if not chiavi.is_empty():
				var visti: Dictionary = {}
				var coda: Array = [str(chiavi[0])]
				while not coda.is_empty():
					var qui: String = str(coda.pop_back())
					if visti.has(qui):
						continue
					visti[qui] = true
					for n in (vicini.get(qui, []) as Array):
						coda.append(str(n))
				if visti.size() < chiavi.size():
					sconnesse += 1
			for tile in posate:
				var grado: int = (vicini.get(str(tile), []) as Array).size()
				archi_totali += grado
				tessere_poste += 1
				if grado <= 1:
					vicoli += 1
		if rotte_qui > 0:
			pescate_rotte += 1
			peggiori[" · ".join(PackedStringArray(combo as Array))] = rotte_qui

	_say("  Ordini per pescata: %d" % (pose / maxi(1, combinazioni.size())))
	_say("  **Pose enumerate: %d**" % pose)
	_say("")
	_say("== LA DOMANDA ==")
	_say("  pose che lasciano fuori una tessera   %6d  (%.3f%%)" % [
		incomplete, 100.0 * float(incomplete) / float(maxi(1, pose))
	])
	_say("  pose che lasciano una tessera isolata %6d  (%.3f%%)" % [
		sconnesse, 100.0 * float(sconnesse) / float(maxi(1, pose))
	])
	_say("  pescate che si rompono in almeno un ordine  %d su %d" % [
		pescate_rotte, combinazioni.size()
	])
	_say("")
	_say("  E com'e' fatta la mappa, su tutte le pose:")
	_say("    confini per mappa      %.2f" % (float(archi_totali) / 2.0 / float(maxi(1, pose))))
	_say("    tessere con un vicino solo  %.1f%%" % (
		100.0 * float(vicoli) / float(maxi(1, tessere_poste))
	))
	if not mai.is_empty():
		_say("")
		_say("  Le tessere che restano in mano:")
		var chi: Array = mai.keys()
		chi.sort()
		for tile in chi:
			_say("    %-24s %d volte" % [str(tile), int(mai[tile])])
	if not peggiori.is_empty():
		_say("")
		_say("  Le pescate che si rompono, con quanti ordini su %d:" % (
			pose / maxi(1, combinazioni.size())
		))
		var quali: Array = peggiori.keys()
		quali.sort()
		for k in quali:
			_say("    %-70s %d" % [str(k), int(peggiori[k])])
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


## Le combinazioni di `quante` fra `pool`, in ordine.
func _combinations(pool: Array, quante: int) -> Array:
	var out: Array = []
	var indici: Array = []
	for i in range(quante):
		indici.append(i)
	while true:
		var combo: Array = []
		for i in indici:
			combo.append(str(pool[int(i)]))
		out.append(combo)
		var k: int = quante - 1
		while k >= 0 and int(indici[k]) == pool.size() - quante + k:
			k -= 1
		if k < 0:
			break
		indici[k] = int(indici[k]) + 1
		for j in range(k + 1, quante):
			indici[j] = int(indici[j - 1]) + 1
	return out


## Tutte le permutazioni di una pescata, in ordine (Heap iterativo).
func _permutations(combo: Array) -> Array:
	var out: Array = []
	var a: Array = combo.duplicate()
	var n: int = a.size()
	var c: Array = []
	for i in range(n):
		c.append(0)
	out.append(a.duplicate())
	var i: int = 0
	while i < n:
		if int(c[i]) < i:
			var j: int = 0 if i % 2 == 0 else int(c[i])
			var tmp: Variant = a[j]
			a[j] = a[i]
			a[i] = tmp
			out.append(a.duplicate())
			c[i] = int(c[i]) + 1
			i = 0
		else:
			c[i] = 0
			i += 1
	return out
