extends SceneTree
## **La rosa esagonale contro il 3x2**, con i varchi spazzati tutti.
##
##   godot --headless --path godot --script res://cli/run_flower_probe.gd
##
## Domanda del committente: *«meglio la situazione attuale (6 tessere 3x2)
## oppure tessere esagonali con un esagono centrale e sei esagoni attorno?»* — e
## poi la precisazione che fa la sonda: *«gli esagoni non hanno tutti i lati con
## varchi, la capitale per esempio si, ma le montagne solo due o tre varchi e la
## sonda deve misurare se qualcuno tra le tante combinazioni rimane isolata»*.
##
## **I varchi esagonali non esistono come dato**, e la sonda non se li inventa:
## un numero misurato su varchi decisi da me misurerebbe la mia mano. Invece
## spazza **tutte le forme possibili** di una tessera — quante aperture e in che
## disposizione — e per ogni composizione di tessere dice se la mappa si rompe.
## La forma di una tessera, a meno della rotazione, e' una **collana**: su sei
## lati con almeno due varchi ce ne sono 12, su quattro 4. Due varchi vicini non
## sono due varchi opposti, e la sonda tiene le due cose separate.
##
## Per ogni composizione si misurano quattro cose diverse:
##
## 1. **esiste una posa buona?** — se no, nessuna delle tre strategie del
##    committente salva quella composizione: si cambiano i varchi e basta;
## 2. **la regola di oggi la trova?** — la posa del motore (accanto a una gia'
##    posata, ruotando, e chi non entra si mette da parte) su tanti ordini;
## 3. **la strategia A** — la tessera piu' aperta al centro della rosa;
## 4. **la A al rovescio** — la tessera piu' avara al centro: il peggio che una
##    regola di posizione fissa possa fare.
##
## Il 3x2 **non e' riscritto**: lo misura `WorldStateFactory._lay_the_tiles`,
## cioe' il motore vero, con Regioni finte che portano i varchi spazzati. La
## rosa invece la posa questa sonda, perche' il motore e' quadrato: e' la stessa
## regola, portata all'esagono, e sta scritta in `_lay_generic`.

const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const DataSet := preload("res://scripts/core/data_set.gd")

const QUARTERS: Array = ["N", "E", "S", "O"]
var _node_cap: int = 4000000


## Una scatola di dati finta: al motore della posa serve solo `regions`, e a
## ogni Regione solo `edges`. Cosi' i varchi spazzati entrano nel motore vero
## senza toccare i dati spediti.
class Stub extends RefCounted:
	var regions: Dictionary = {}


var _out: Array = []
var _nodes: int = 0
var _capped: bool = false


func _say(line: String = "") -> void:
	_out.append(line)
	print(line)


# ---------------------------------------------------------------- la geometria

## Le caselle di una mappa, e chi tocca chi da quale lato.
##   - `quadrata`: le sei caselle del 3x2, quattro lati (N E S O);
##   - `rosa`: un centro e sei petali, sei lati.
func _geometry(kind: String) -> Dictionary:
	var seats: Array = []
	var dirs: Array = []
	if kind == "quadrata":
		dirs = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
		for y in range(2):
			for x in range(3):
				seats.append(Vector2i(x, y))
	else:
		# Coordinate assiali: i sei passi in giro, in ordine, cosi' i petali
		# 1..6 sono consecutivi sull'anello e il 6 tocca l'1.
		dirs = [
			Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
			Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
		]
		seats.append(Vector2i(0, 0))
		for d in dirs:
			seats.append(d as Vector2i)
	var neighbours: Array = []
	for i in range(seats.size()):
		var mine: Array = []
		for j in range(seats.size()):
			if i == j:
				continue
			var step: Vector2i = (seats[j] as Vector2i) - (seats[i] as Vector2i)
			var side: int = dirs.find(step)
			if side >= 0:
				mine.append([j, side])
		neighbours.append(mine)
	# **L'ordine in cui la ricerca riempie le caselle**, e non e' un dettaglio:
	# si visitano prima le caselle che chiudono presto i loro vicini, cosi' una
	# tessera isolata si vede a profondita' due invece che a profondita' sei.
	var seat_order: Array = [0, 1, 3, 4, 2, 5] if kind == "quadrata" else [0, 1, 2, 3, 4, 5, 6]
	# **I lati che contano**, casella per casella: quelli che guardano un vicino.
	# Gli altri non toccano niente, e due rotazioni che aprono gli stessi lati
	# utili sono **la stessa posa**: e' il taglio che fa stare in piedi la
	# ricerca, perche' una tessera aperta su tutti i lati smette di avere sei
	# rotazioni e ne ha una.
	var faces: Array = []
	for i in range(seats.size()):
		var mine: Array = []
		for pair in (neighbours[i] as Array):
			mine.append(int((pair as Array)[1]))
		faces.append(mine)
	return {
		"kind": kind,
		"seats": seats,
		"seat_order": seat_order,
		"faces": faces,
		"sides": dirs.size(),
		"neighbours": neighbours,
		# Girare la rosa intera porta una posa buona in un'altra posa buona:
		# quindi la rotazione del centro si puo' fissare, e l'esistenza non
		# cambia. Il 3x2 non ha questa simmetria e si guarda tutto.
		"fix_first": kind == "rosa",
	}


## Le collane: le forme distinte di una tessera a `sides` lati con almeno
## `least` varchi, a meno della rotazione. Una tessera non si gira sottosopra —
## ha una faccia — quindi si contano le collane, non i braccialetti.
func _necklaces(sides: int, least: int) -> Array:
	var seen: Dictionary = {}
	var out: Array = []
	for mask in range(1 << sides):
		if _varchi(mask, sides) < least:
			continue
		var canon: int = mask
		for turn in range(sides):
			var rotated: int = 0
			for s in range(sides):
				if (mask >> s) & 1:
					rotated |= 1 << ((s + turn) % sides)
			canon = mini(canon, rotated)
		if seen.has(canon):
			continue
		seen[canon] = true
		out.append(canon)
	out.sort()
	return out


func _varchi(mask: int, sides: int) -> int:
	var count: int = 0
	for s in range(sides):
		if (mask >> s) & 1:
			count += 1
	return count


## Il lato `side` della tessera, girata di `turn`, porta un varco?
func _open(mask: int, turn: int, side: int, sides: int) -> bool:
	return ((mask >> (((side - turn) % sides + sides) % sides)) & 1) != 0


func _passage(geo: Dictionary, masks: Array, turns: Array, a: int, b: int, side: int) -> bool:
	var sides: int = int(geo["sides"])
	return _open(int(masks[a]), int(turns[a]), side, sides) \
		and _open(int(masks[b]), int(turns[b]), (side + sides / 2) % sides, sides)


# -------------------------------------------------------------- l'esistenza

## Esiste una posa di queste tessere senza nessuna isolata, e tutta d'un pezzo?
## `centre` e' l'indice della tessera che deve andare nella prima casella — il
## centro della rosa — oppure -1 se ognuna puo' stare dove vuole. Torna 1 si',
## 0 no, -1 se e' finito il tetto dei nodi.
##
## Una ricerca sola, non due: si sceglie **la tessera e la sua rotazione
## insieme**, casella per casella. Tenerle separate — prima tutti gli ordini,
## poi tutte le rotazioni — finiva il tetto dei nodi sulle composizioni avare,
## cioe' proprio quelle che interessano.
func _exists(geo: Dictionary, tiles: Array, centre: int) -> int:
	_nodes = 0
	_capped = false
	# **Dal piu' aperto al piu' avaro**: la ricerca prova per prima la tessera che
	# ha piu' probabilita' di tenere insieme la mappa, e sulle composizioni che
	# una posa buona ce l'hanno finisce al primo colpo. Sulle altre non cambia
	# niente — vanno esaurite comunque — ma quelle sono poche.
	var pool: Array = []
	for mask in tiles:
		pool.append(int(mask))
	pool.sort_custom(func(a, b): return _varchi(int(a), int(geo["sides"])) > _varchi(int(b), int(geo["sides"])))
	var taken: Array = []
	var masks: Array = []
	var turns: Array = []
	for i in range(pool.size()):
		taken.append(false)
		masks.append(-1)
		turns.append(-1)
	var forced: int = -1 if centre < 0 else int(tiles[centre])
	# **La scorciatoia che e' anche il risultato**: se nella prima casella va una
	# tessera aperta su tutti i lati, ogni vicino le si attacca ruotando un varco
	# verso di lei, e la mappa e' tutta d'un pezzo senza cercare niente. Sulla
	# rosa la prima casella e' il centro e i vicini sono **tutti e sei**: e' il
	# motivo per cui la strategia A del committente funziona.
	var full: int = (1 << int(geo["sides"])) - 1
	if ((forced < 0 and pool.has(full)) or forced == full) \
		and ((geo["faces"] as Array)[int((geo["seat_order"] as Array)[0])] as Array).size() \
			== (geo["seats"] as Array).size() - 1:
		return 1
	if _fill(geo, pool, taken, masks, turns, 0, forced):
		return 1
	return -1 if _capped else 0


func _fill(
	geo: Dictionary, pool: Array, taken: Array, masks: Array, turns: Array,
	depth: int, forced: int
) -> bool:
	_nodes += 1
	if _nodes > _node_cap:
		_capped = true
		return false
	var seat_order: Array = geo["seat_order"] as Array
	if depth >= seat_order.size():
		return _whole_map_ok(geo, masks, turns)
	var seat: int = int(seat_order[depth])
	var sides: int = int(geo["sides"])
	# Girare la rosa intera porta una posa buona in un'altra posa buona: la
	# rotazione del centro si puo' fissare senza perdere niente.
	var turn_options: int = 1 if (depth == 0 and bool(geo["fix_first"])) else sides
	var faces: Array = (geo["faces"] as Array)[seat] as Array
	var tried: Dictionary = {}
	for i in range(pool.size()):
		if bool(taken[i]):
			continue
		var mask: int = int(pool[i])
		if depth == 0 and forced >= 0 and mask != forced:
			continue
		for turn in range(turn_options):
			# **Due pose che aprono gli stessi lati utili sono una sola prova**:
			# la stessa forma girata in un altro modo che guarda i vicini
			# uguale, e la seconda copia di una forma gia' provata.
			var key: int = mask << 8
			for slot in range(faces.size()):
				if _open(mask, turn, int(faces[slot]), sides):
					key |= 1 << slot
			if tried.has(key):
				continue
			tried[key] = true
			# Nessun lato utile aperto: e' isolata gia' adesso, e non serve
			# scendere per scoprirlo alla fine.
			if (key & 255) == 0:
				continue
			masks[seat] = mask
			turns[seat] = turn
			taken[i] = true
			if _no_dead_seat(geo, masks, turns, seat) \
				and _fill(geo, pool, taken, masks, turns, depth + 1, forced):
				return true
			taken[i] = false
	masks[seat] = -1
	turns[seat] = -1
	return false


## Il taglio: una casella che ha **tutti** i vicini posati e nessun varco che
## combaci e' isolata per sempre, e il ramo muore qui. Si guardano solo la
## casella appena riempita e i suoi vicini: le altre non hanno cambiato stato.
func _no_dead_seat(geo: Dictionary, masks: Array, turns: Array, seat: int) -> bool:
	var neigh: Array = geo["neighbours"] as Array
	var watch: Array = [seat]
	for pair in (neigh[seat] as Array):
		watch.append(int((pair as Array)[0]))
	for j in watch:
		if int(masks[int(j)]) < 0:
			continue
		var complete: bool = true
		var links: int = 0
		for pair in (neigh[int(j)] as Array):
			var other: int = int((pair as Array)[0])
			if int(masks[other]) < 0:
				complete = false
				continue
			if _passage(geo, masks, turns, int(j), other, int((pair as Array)[1])):
				links += 1
		if complete and links == 0:
			return false
	return true


func _whole_map_ok(geo: Dictionary, masks: Array, turns: Array) -> bool:
	var neigh: Array = geo["neighbours"] as Array
	var links: Array = []
	for j in range(masks.size()):
		var mine: Array = []
		for pair in (neigh[j] as Array):
			var other: int = int((pair as Array)[0])
			if int(masks[other]) < 0:
				continue
			if _passage(geo, masks, turns, j, other, int((pair as Array)[1])):
				mine.append(other)
		if mine.is_empty():
			return false
		links.append(mine)
	# E tutta d'un pezzo, non due isole da tre.
	var seen: Dictionary = {0: true}
	var queue: Array = [0]
	while not queue.is_empty():
		var here: int = int(queue.pop_back())
		for other in (links[here] as Array):
			if seen.has(int(other)):
				continue
			seen[int(other)] = true
			queue.append(int(other))
	return seen.size() == masks.size()


# ------------------------------------------------------------------ la posa

## La regola del motore, portata all'esagono: la prima nella casella 0, le altre
## accanto a una gia' posata girandole finche' i varchi combaciano, dove
## attaccano **meglio**; chi non entra si mette da parte e si riprova.
func _lay_generic(geo: Dictionary, order: Array) -> Dictionary:
	var sides: int = int(geo["sides"])
	var neigh: Array = geo["neighbours"] as Array
	var places: int = (geo["seats"] as Array).size()
	var masks: Array = []
	var turns: Array = []
	for i in range(places):
		masks.append(-1)
		turns.append(0)
	masks[0] = int(order[0])
	var left: Array = order.slice(1)
	var placed: int = 1
	while not left.is_empty():
		var moved: bool = false
		for index in range(left.size()):
			var mask: int = int(left[index])
			var best_seat: int = -1
			var best_turn: int = 0
			var best_joins: int = 0
			for seat in range(places):
				if int(masks[seat]) >= 0:
					continue
				var touches: bool = false
				for pair in (neigh[seat] as Array):
					if int(masks[int((pair as Array)[0])]) >= 0:
						touches = true
						break
				if not touches:
					continue
				for turn in range(sides):
					var joins: int = 0
					for pair in (neigh[seat] as Array):
						var other: int = int((pair as Array)[0])
						if int(masks[other]) < 0:
							continue
						var side: int = int((pair as Array)[1])
						if _open(mask, turn, side, sides) \
							and _open(int(masks[other]), int(turns[other]),
								(side + sides / 2) % sides, sides):
							joins += 1
					if joins > best_joins:
						best_joins = joins
						best_seat = seat
						best_turn = turn
			if best_seat < 0:
				continue
			masks[best_seat] = mask
			turns[best_seat] = best_turn
			left.remove_at(index)
			placed += 1
			moved = true
			break
		if not moved:
			break
	return {"masks": masks, "turns": turns, "placed": placed}


## La posa e' buona? Tutte le tessere entrate, nessuna isolata, tutta d'un pezzo.
func _pose_ok(geo: Dictionary, laid: Dictionary) -> bool:
	if int(laid["placed"]) < (geo["seats"] as Array).size():
		return false
	return _whole_map_ok(geo, laid["masks"] as Array, laid["turns"] as Array)


## Il 3x2 col motore vero: le tessere diventano Regioni finte coi varchi dati.
func _lay_with_engine(order: Array) -> Dictionary:
	var stub: Stub = Stub.new()
	var ids: Array = []
	for i in range(order.size()):
		var id: String = "T%d" % i
		ids.append(id)
		var edges: Array = []
		for s in range(4):
			if (int(order[i]) >> s) & 1:
				edges.append(str(QUARTERS[s]))
		stub.regions[id] = {"edges": edges}
	var world: Dictionary = {}
	WorldStateFactory._lay_the_tiles(world, {"regions": ids}, stub)
	return world


## La mappa che il motore ha steso e' buona?
func _engine_pose_ok(world: Dictionary, quante: int) -> bool:
	var at: Dictionary = world["map_positions"] as Dictionary
	if at.size() < quante:
		return false
	var links: Dictionary = world["adjacency"] as Dictionary
	for tile in at:
		if (links.get(str(tile), []) as Array).is_empty():
			return false
	var keys: Array = at.keys()
	var seen: Dictionary = {str(keys[0]): true}
	var queue: Array = [str(keys[0])]
	while not queue.is_empty():
		var here: String = str(queue.pop_back())
		for other in (links.get(here, []) as Array):
			if seen.has(str(other)):
				continue
			seen[str(other)] = true
			queue.append(str(other))
	return seen.size() == at.size()


# ------------------------------------------------------------- i combinatori

## Le composizioni: i multinsiemi di `quante` forme fra `types`.
func _compositions(types: Array, quante: int) -> Array:
	var out: Array = []
	var pick: Array = []
	for i in range(quante):
		pick.append(0)
	while true:
		var one: Array = []
		for i in pick:
			one.append(int(types[int(i)]))
		out.append(one)
		var k: int = quante - 1
		while k >= 0 and int(pick[k]) == types.size() - 1:
			k -= 1
		if k < 0:
			break
		pick[k] = int(pick[k]) + 1
		for j in range(k + 1, quante):
			pick[j] = int(pick[k])
	return out


## L'ordine dopo questo, in ordine crescente. Falso quando e' l'ultimo. Sui
## doppioni salta gli ordini uguali da soli, che e' il punto.
func _next_permutation(a: Array) -> bool:
	var i: int = a.size() - 2
	while i >= 0 and int(a[i]) >= int(a[i + 1]):
		i -= 1
	if i < 0:
		return false
	var j: int = a.size() - 1
	while int(a[j]) <= int(a[i]):
		j -= 1
	var tmp: int = int(a[i])
	a[i] = int(a[j])
	a[j] = tmp
	var left: int = i + 1
	var right: int = a.size() - 1
	while left < right:
		tmp = int(a[left])
		a[left] = int(a[right])
		a[right] = tmp
		left += 1
		right -= 1
	return true


## Quanti ordini distinti ha questa composizione.
func _distinct_orders(tiles: Array) -> int:
	var counts: Dictionary = {}
	for mask in tiles:
		counts[int(mask)] = int(counts.get(int(mask), 0)) + 1
	var total: int = 1
	for i in range(2, tiles.size() + 1):
		total *= i
	for mask in counts:
		for i in range(2, int(counts[mask]) + 1):
			total /= i
	return total


# ------------------------------------------------------------------- il giro

func _initialize() -> void:
	var options: Dictionary = {"ordini": 48, "composizioni": 0}
	for arg in OS.get_cmdline_user_args():
		var text: String = str(arg)
		if text.begins_with("--ordini="):
			options["ordini"] = int(text.substr(9))
		if text.begins_with("--composizioni="):
			options["composizioni"] = int(text.substr(15))
		if text.begins_with("--tetto="):
			_node_cap = int(text.substr(8))
		if text.begins_with("--out="):
			options["out"] = text.substr(6)

	_say("# ECHOES — la rosa esagonale contro il 3x2, coi varchi spazzati tutti")
	_say("")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	_say("== I VARCHI CHE CI SONO OGGI ==")
	var pool: Array = []
	var chronicle: Dictionary = data.chronicles["CHR_00"]
	for region_id in ((chronicle.get("region_pool", {}) as Dictionary).get("candidates", []) as Array):
		pool.append(str(region_id))
	pool.sort()
	var aperte: int = 0
	for region_id in pool:
		var edges: Array = (data.regions[str(region_id)] as Dictionary).get("edges", []) as Array
		if edges.size() >= 4:
			aperte += 1
		_say("  %-22s %d varchi  (%s)" % [
			str(region_id), edges.size(), ", ".join(PackedStringArray(edges)),
		])
	_say("  **%d Regioni su %d sono aperte su tutti e quattro i lati.**" % [aperte, pool.size()])
	_say("  Cioe' oggi i varchi quasi non vincolano, e lo 0 isolate di")
	_say("  MISURA_TESSERE.md misura una mappa con un vincolo quasi spento.")
	_say("")

	var square: Dictionary = _geometry("quadrata")
	var rose: Dictionary = _geometry("rosa")
	if not _prova(square, rose):
		quit(3)
		return
	_say("== LE DUE GEOMETRIE ==")
	for geo in [square, rose]:
		var edges_total: int = 0
		var degrees: Array = []
		for mine in (geo["neighbours"] as Array):
			edges_total += (mine as Array).size()
			degrees.append((mine as Array).size())
		_say("  %-9s %d caselle, %d lati per tessera, %d confini, gradi %s" % [
			str(geo["kind"]), (geo["seats"] as Array).size(), int(geo["sides"]),
			edges_total / 2, str(degrees),
		])
	_say("")

	var square_forms: Array = _necklaces(4, 2)
	var rose_forms: Array = _necklaces(6, 2)
	_say("== LO SPAZIO DELLE FORME ==")
	_say("  Una forma e' la disposizione dei varchi a meno della rotazione.")
	_say("  quadrata: %d forme con almeno due varchi" % square_forms.size())
	for mask in square_forms:
		_say("    %s  %d varchi" % [_draw(int(mask), 4), _varchi(int(mask), 4)])
	_say("  rosa: %d forme con almeno due varchi" % rose_forms.size())
	for mask in rose_forms:
		_say("    %s  %d varchi" % [_draw(int(mask), 6), _varchi(int(mask), 6)])
	_say("")

	_sweep(square, square_forms, 6, 4, options, true)
	_sweep(rose, rose_forms, 7, 6, options, false)
	_families(data, pool)

	var testo: String = "\n".join(PackedStringArray(_out)) + "\n"
	var dove: String = str(options.get("out", ""))
	if dove != "":
		var handle: FileAccess = FileAccess.open(dove, FileAccess.WRITE)
		if handle != null:
			handle.store_string(testo)
			handle.close()
	quit(0)


## **La sonda si prova su casi fabbricati**, prima di credere a quello che dice.
## Regola di casa: una sonda che torna zero e' quasi sempre cieca lei, e qui il
## numero che conta — «quante composizioni non hanno nessuna posa buona» — e'
## proprio uno zero o quasi. Quindi cinque casi con la risposta calcolata a
## mano, tre che devono dare **si'** e due che devono dare **no**.
func _prova(square: Dictionary, rose: Dictionary) -> bool:
	var cases: Array = [
		# La rosa tutta aperta: ogni petalo gira un varco verso il centro.
		[rose, _same(63, 7), 1, "rosa tutte aperte su sei lati"],
		# Sette tessere con **due varchi opposti**. I tre lati che contano, per
		# un petalo, sono tre lati **di fila** — il centro sta in mezzo — e due
		# varchi opposti non ci stanno tutti e due dentro: un petalo o guarda il
		# centro o guarda l'anello, mai tutti e due. Il centro ne raggiunge due,
		# gli altri quattro restano a coppie staccate.
		[rose, _same(9, 7), 0, "rosa tutte a due varchi opposti"],
		# Il centro a cinque varchi e sei tessere con due varchi vicini: il
		# petalo che il centro non raggiunge si aggancia al vicino, che tiene un
		# varco per il centro e uno per lui. Questa **non** passa dalla
		# scorciatoia: la trova la ricerca.
		[rose, _one_and(31, 3, 6), 1, "rosa col centro a cinque varchi"],
		# Sei corridoi nel 3x2: due caselle di fianco si toccano solo se sono
		# tutte e due per il lungo, due sovrapposte solo se sono tutte e due per
		# l'alto, e una tessera non puo' essere le due cose insieme.
		[square, _same(5, 6), 0, "3x2 tutti corridoi opposti"],
		[square, _same(15, 6), 1, "3x2 tutte aperte su quattro lati"],
	]
	var good: bool = true
	_say("== LA SONDA SI PROVA SU CASI FABBRICATI ==")
	for one in cases:
		var geo: Dictionary = (one as Array)[0] as Dictionary
		var tiles: Array = (one as Array)[1] as Array
		var want: int = int((one as Array)[2])
		var got: int = _exists(geo, tiles, -1)
		if got != want:
			good = false
		_say("  %-4s %-44s attesa %d, avuta %d" % [
			"OK" if got == want else "ROTTO", str((one as Array)[3]), want, got,
		])
	_say("")
	return good


func _same(mask: int, quante: int) -> Array:
	var out: Array = []
	for i in range(quante):
		out.append(mask)
	return out


func _one_and(head: int, mask: int, quante: int) -> Array:
	var out: Array = [head]
	out.append_array(_same(mask, quante))
	return out


## I varchi disegnati, per leggerli: `##.#..`, un posto per lato.
func _draw(mask: int, sides: int) -> String:
	var out: String = ""
	for s in range(sides):
		out += "#" if ((mask >> s) & 1) else "."
	return out


func _sweep(
	geo: Dictionary, forms: Array, quante: int, sides: int,
	options: Dictionary, with_engine: bool
) -> void:
	var name: String = str(geo["kind"])
	var compositions: Array = _compositions(forms, quante)
	var total: int = compositions.size()
	if int(options.get("composizioni", 0)) > 0:
		compositions = compositions.slice(0, int(options["composizioni"]))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7000

	var per_min: Dictionary = {}     # minimo di varchi su una tessera -> conti
	var per_total: Dictionary = {}   # varchi aperti in tutto -> conti
	var no_pose: int = 0
	var rule_breaks: int = 0
	var always_fine: int = 0
	var undecided: int = 0
	var poses: int = 0
	var poses_broken: int = 0
	var a_fails: int = 0
	var a_worst_fails: int = 0
	var with_a_six: int = 0
	var a_six_fails: int = 0
	var started: int = Time.get_ticks_msec()

	for index in range(compositions.size()):
		if index % 2000 == 0 and index > 0:
			printerr("  %s %d/%d  (%d s)" % [
				name, index, compositions.size(), (Time.get_ticks_msec() - started) / 1000,
			])
		var tiles: Array = compositions[index] as Array
		var least: int = 99
		var sum: int = 0
		var most: int = 0
		var most_at: int = 0
		var least_at: int = 0
		for i in range(tiles.size()):
			var varchi: int = _varchi(int(tiles[i]), sides)
			sum += varchi
			if varchi < least:
				least = varchi
				least_at = i
			if varchi > most:
				most = varchi
				most_at = i
		if not per_min.has(least):
			per_min[least] = {"quante": 0, "senza_posa": 0, "regola_rompe": 0, "indecise": 0}
		if not per_total.has(sum):
			per_total[sum] = {"quante": 0, "senza_posa": 0, "regola_rompe": 0, "indecise": 0}
		var row: Dictionary = per_min[least] as Dictionary
		var row_total: Dictionary = per_total[sum] as Dictionary
		row["quante"] = int(row["quante"]) + 1
		row_total["quante"] = int(row_total["quante"]) + 1

		# **Tre domande, ma non sempre tre ricerche.** Se la piu' aperta al centro
		# tiene, allora una posa buona esiste e la ricerca libera non serve: e'
		# la stessa domanda con un vincolo in piu'.
		# -2 vuol dire **non chiesta**: sulla quadrata il centro non esiste, e
		# leggere qui un 1 di comodo spegnerebbe la ricerca libera senza dirlo.
		# E' successo: il 3x2 e' tornato «4 composizioni senza posa -> 0» in
		# silenzio, e a prenderlo e' stato il caso fabbricato dei sei corridoi.
		var a_ok: int = -2
		if name == "rosa":
			a_ok = _exists(geo, tiles, most_at)
			if a_ok != 1:
				a_fails += 1
			if most >= sides:
				with_a_six += 1
				if a_ok != 1:
					a_six_fails += 1
		# 1. esiste una posa buona?
		var exists: int = 1 if a_ok == 1 else _exists(geo, tiles, -1)
		if exists < 0:
			undecided += 1
			row["indecise"] = int(row["indecise"]) + 1
			row_total["indecise"] = int(row_total["indecise"]) + 1
		elif exists == 0:
			no_pose += 1
			row["senza_posa"] = int(row["senza_posa"]) + 1
			row_total["senza_posa"] = int(row_total["senza_posa"]) + 1

		# 2. la regola la trova? su tutti gli ordini distinti se sono pochi,
		#    altrimenti su `--ordini` ordini pescati col seme 7000.
		var orders: int = _distinct_orders(tiles)
		var broken_here: int = 0
		var tried: int = 0
		if orders <= int(options["ordini"]):
			var walk: Array = tiles.duplicate()
			walk.sort()
			while true:
				tried += 1
				if not _rule_ok(geo, walk, with_engine, quante):
					broken_here += 1
				if not _next_permutation(walk):
					break
		else:
			for i in range(int(options["ordini"])):
				var shuffled: Array = tiles.duplicate()
				for j in range(shuffled.size() - 1, 0, -1):
					var pick: int = rng.randi_range(0, j)
					var tmp: int = int(shuffled[j])
					shuffled[j] = int(shuffled[pick])
					shuffled[pick] = tmp
				tried += 1
				if not _rule_ok(geo, shuffled, with_engine, quante):
					broken_here += 1
		poses += tried
		poses_broken += broken_here
		if broken_here > 0:
			rule_breaks += 1
			row["regola_rompe"] = int(row["regola_rompe"]) + 1
			row_total["regola_rompe"] = int(row_total["regola_rompe"]) + 1
		elif exists == 1:
			always_fine += 1

		# 4. la posizione fissa peggiore: la piu' avara al centro.
		if name == "rosa":
			# La piu' avara al centro: se sono tutte uguali e' la stessa domanda
			# di prima, e la risposta si ricopia invece di ricercarla.
			var worst: int = a_ok if least == most else _exists(geo, tiles, least_at)
			if worst != 1:
				a_worst_fails += 1

	_say("== %s: %d composizioni enumerate (di %d) ==" % [
		name.to_upper(), compositions.size(), total,
	])
	_say("  la posa: %s" % ("il motore vero" if with_engine else "la stessa regola, portata all'esagono"))
	_say("  pose stese %d, rotte %d (%.2f%%)" % [
		poses, poses_broken, 100.0 * float(poses_broken) / float(maxi(1, poses)),
	])
	_say("  composizioni senza **nessuna** posa buona   %6d  (%.2f%%)" % [
		no_pose, 100.0 * float(no_pose) / float(maxi(1, compositions.size())),
	])
	_say("  composizioni che la regola rompe in almeno un ordine  %6d  (%.2f%%)" % [
		rule_breaks, 100.0 * float(rule_breaks) / float(maxi(1, compositions.size())),
	])
	_say("  composizioni che la regola non sbaglia mai  %6d  (%.2f%%)" % [
		always_fine, 100.0 * float(always_fine) / float(maxi(1, compositions.size())),
	])
	if undecided > 0:
		_say("  composizioni lasciate indecise dal tetto dei nodi  %d" % undecided)
	_say("")
	_say("  per **minimo di varchi** su una tessera:")
	_say("    min  composizioni  senza posa  la regola rompe")
	var keys: Array = per_min.keys()
	keys.sort()
	for key in keys:
		var row: Dictionary = per_min[key] as Dictionary
		_say("    %3d  %12d  %10d  %15d" % [
			int(key), int(row["quante"]), int(row["senza_posa"]), int(row["regola_rompe"]),
		])
	_say("")
	_say("  per **varchi aperti in tutto** (su %d lati stampati) — la colonna" % (quante * sides))
	_say("  che si confronta con la curva di D-393:")
	_say("    aperti  composizioni  senza posa  la regola rompe")
	var totals: Array = per_total.keys()
	totals.sort()
	for key in totals:
		var line: Dictionary = per_total[key] as Dictionary
		_say("    %6d  %12d  %10d  %15d" % [
			int(key), int(line["quante"]), int(line["senza_posa"]), int(line["regola_rompe"]),
		])
	if name == "rosa":
		_say("")
		_say("  == LE TRE STRATEGIE DEL COMMITTENTE ==")
		_say("  A  la tessera piu' aperta al centro: rompe %d composizioni su %d" % [
			a_fails, compositions.size(),
		])
		_say("     e dove al centro c'e' una tessera aperta su tutti e sei i lati")
		_say("     (%d composizioni su %d) rompe **%d**." % [
			with_a_six, compositions.size(), a_six_fails,
		])
		_say("  A' la tessera piu' avara al centro (il peggio di una posizione")
		_say("     fissa decisa senza guardare i varchi): rompe %d composizioni." % a_worst_fails)
		_say("  B  ruotare finche' non e' isolata: e' la riga «senza nessuna posa")
		_say("     buona» — %d composizioni non si salvano nemmeno ruotando." % no_pose)
		_say("  C  riposizionare a mano: sulla rosa **e' la stessa mossa di B**,")
		_say("     perche' il posto e la rotazione si scelgono insieme.")
	_say("")


func _rule_ok(geo: Dictionary, order: Array, with_engine: bool, quante: int) -> bool:
	if with_engine:
		return _engine_pose_ok(_lay_with_engine(order), quante)
	return _pose_ok(geo, _lay_generic(geo, order))


## Le sei famiglie di Asset: la rosa ne decide quattro tessere su sette dalle
## case che siedono, e il rimedio di D-313 — la tessera piu' inutile esce e
## entra quella che porta la famiglia che manca — su quelle quattro non si puo'
## applicare. Quindi si guarda quante mani di tessere le portano tutte da sole.
func _families(data: RefCounted, pool: Array) -> void:
	var families: Array = []
	for region_id in pool:
		for family in ((data.regions[str(region_id)] as Dictionary).get("asset_sources", []) as Array):
			if not families.has(str(family)):
				families.append(str(family))
	families.sort()
	_say("== LE SEI FAMIGLIE, E LA VARIETA' ==")
	_say("  famiglie nei dati: %s" % ", ".join(PackedStringArray(families)))
	for quante in [6, 7]:
		var all: Array = _subsets(pool, quante)
		var complete: int = 0
		for pick in all:
			var seen: Dictionary = {}
			for region_id in (pick as Array):
				for family in ((data.regions[str(region_id)] as Dictionary).get("asset_sources", []) as Array):
					seen[str(family)] = true
			if seen.size() >= families.size():
				complete += 1
		_say("  mani di %d tessere su %d: %d su %d portano tutte e sei le famiglie (%.1f%%)" % [
			quante, pool.size(), complete, all.size(),
			100.0 * float(complete) / float(maxi(1, all.size())),
		])
	_say("")


func _subsets(pool: Array, quante: int) -> Array:
	var out: Array = []
	var pick: Array = []
	for i in range(quante):
		pick.append(i)
	while true:
		var one: Array = []
		for i in pick:
			one.append(str(pool[int(i)]))
		out.append(one)
		var k: int = quante - 1
		while k >= 0 and int(pick[k]) == pool.size() - quante + k:
			k -= 1
		if k < 0:
			break
		pick[k] = int(pick[k]) + 1
		for j in range(k + 1, quante):
			pick[j] = int(pick[j - 1]) + 1
	return out
