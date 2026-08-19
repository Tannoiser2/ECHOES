extends RefCounted
## Il QR della stanza (voce 27, la B della seduta — D-137).
##
## Un encoder QR minimo e verificato: modo byte, correzione M, versioni 1-4
## (fino a 64 caratteri — un `http://192.168.100.100:8123/?t=a3f29b1c` sta
## comodo in versione 3). Serve a una cosa sola: mettere sullo schermo della
## stanza il codice che un telefono inquadra invece di digitare.
##
## Perche' scritto a mano e non preso da una libreria: il progetto non tira
## dipendenze per una schermata, e un QR sbagliato non si vede a occhio — si
## vede quando quattro persone sono sedute e nessuna riesce a entrare. Per
## questo l'encoder ha il suo oracolo: `tools/gen_qr_fixture.py` genera le
## matrici attese con `segno` (implementazione indipendente, non mia) e
## `test_qr_code.gd` le confronta modulo per modulo, per ogni maschera.
##
## Fuori dalla portata: versioni oltre la 4, modi numerico/alfanumerico,
## livelli di correzione diversi da M. Se il testo non ci sta, `matrix()`
## torna vuoto e chi disegna mostra l'indirizzo scritto — la stanza ha
## sempre avuto quella strada, il QR e' la comodita' sopra.

## Per versione, a livello M: dati totali, ec per blocco, numero di blocchi.
const SPECS: Array = [
	{"version": 1, "data": 16, "ec": 10, "blocks": 1},
	{"version": 2, "data": 28, "ec": 16, "blocks": 1},
	{"version": 3, "data": 44, "ec": 26, "blocks": 1},
	{"version": 4, "data": 64, "ec": 18, "blocks": 2},
]

## I centri dei pattern d'allineamento, per versione.
const ALIGNMENT: Dictionary = {1: [], 2: [6, 18], 3: [6, 22], 4: [6, 26]}

## I bit di correzione nel formato: M vale 00.
const FORMAT_EC_M: int = 0

static var _exp_table: PackedInt32Array = PackedInt32Array()
static var _log_table: PackedInt32Array = PackedInt32Array()


## La matrice del QR per `text`: righe di booleani (true = modulo nero), o
## un array vuoto se il testo non entra nelle versioni supportate. La
## maschera si sceglie da sola col punteggio di penalita' dello standard.
static func matrix(text: String) -> Array:
	var best: Array = []
	var best_penalty: int = -1
	for mask in range(8):
		var candidate: Array = matrix_with_mask(text, mask)
		if candidate.is_empty():
			return []
		var score: int = _penalty(candidate)
		if best_penalty < 0 or score < best_penalty:
			best_penalty = score
			best = candidate
	return best


## La stessa matrice con una maschera imposta: e' la porta da cui entra la
## verifica contro l'oracolo, maschera per maschera.
static func matrix_with_mask(text: String, mask: int) -> Array:
	var bytes: PackedByteArray = text.to_utf8_buffer()
	var spec: Dictionary = _spec_for(bytes.size())
	if spec.is_empty():
		return []
	var codewords: PackedByteArray = _codewords(bytes, spec)
	var size: int = 17 + 4 * int(spec["version"])
	var modules: Array = []
	var reserved: Array = []
	for row in range(size):
		var line: Array = []
		var taken: Array = []
		for column in range(size):
			line.append(false)
			taken.append(false)
		modules.append(line)
		reserved.append(taken)

	_place_finders(modules, reserved, size)
	_place_alignment(modules, reserved, int(spec["version"]))
	_place_timing(modules, reserved, size)
	_reserve_format(reserved, size)
	# Il modulo scuro: sempre acceso, appena sopra il finder in basso a
	# sinistra (standard §8.9).
	modules[size - 8][8] = true
	reserved[size - 8][8] = true

	_place_data(modules, reserved, codewords, size)
	_apply_mask(modules, reserved, mask, size)
	_place_format(modules, mask, size)
	return modules


static func _spec_for(length: int) -> Dictionary:
	for spec in SPECS:
		if length <= int((spec as Dictionary)["data"]) - 2:
			return spec
	return {}


## Il flusso di bit: indicatore di modo, lunghezza, dati, terminatore, e il
## riempimento alternato dello standard. Poi i blocchi, la loro correzione
## Reed-Solomon, e l'interfoliazione.
static func _codewords(bytes: PackedByteArray, spec: Dictionary) -> PackedByteArray:
	var bits: Array = []
	_push_bits(bits, 4, 4)                    # 0100: modo byte
	_push_bits(bits, bytes.size(), 8)         # lunghezza (versioni 1-9)
	for value in bytes:
		_push_bits(bits, int(value), 8)
	var capacity: int = int(spec["data"]) * 8
	for _i in range(mini(4, capacity - bits.size())):
		bits.append(0)
	while bits.size() % 8 != 0:
		bits.append(0)
	var data: PackedByteArray = PackedByteArray()
	for index in range(0, bits.size(), 8):
		var value: int = 0
		for offset in range(8):
			value = (value << 1) | int(bits[index + offset])
		data.append(value)
	# I codeword di riempimento si alternano a partire da 0xEC — contati da
	# quando comincia il riempimento, non dalla posizione nel messaggio: con
	# la parita' della posizione la versione 1 tornava per caso e la 3 no.
	var padding: Array = [0xEC, 0x11]
	var pad_index: int = 0
	while data.size() < int(spec["data"]):
		data.append(int(padding[pad_index % 2]))
		pad_index += 1

	var blocks: int = int(spec["blocks"])
	var per_block: int = int(spec["data"]) / blocks
	var ec_count: int = int(spec["ec"])
	var data_blocks: Array = []
	var ec_blocks: Array = []
	for index in range(blocks):
		var chunk: PackedByteArray = data.slice(index * per_block, (index + 1) * per_block)
		data_blocks.append(chunk)
		ec_blocks.append(_reed_solomon(chunk, ec_count))

	var out: PackedByteArray = PackedByteArray()
	for position in range(per_block):
		for index in range(blocks):
			out.append(int((data_blocks[index] as PackedByteArray)[position]))
	for position in range(ec_count):
		for index in range(blocks):
			out.append(int((ec_blocks[index] as PackedByteArray)[position]))
	return out


static func _push_bits(bits: Array, value: int, count: int) -> void:
	for index in range(count - 1, -1, -1):
		bits.append((value >> index) & 1)


# --- Reed-Solomon su GF(256) ------------------------------------------------

static func _build_tables() -> void:
	if not _exp_table.is_empty():
		return
	_exp_table.resize(512)
	_log_table.resize(256)
	var value: int = 1
	for index in range(255):
		_exp_table[index] = value
		_log_table[value] = index
		value = value << 1
		if value >= 256:
			value = value ^ 0x11D
	for index in range(255, 512):
		_exp_table[index] = _exp_table[index - 255]


static func _multiply(left: int, right: int) -> int:
	if left == 0 or right == 0:
		return 0
	return int(_exp_table[int(_log_table[left]) + int(_log_table[right])])


## Il polinomio generatore, con il coefficiente di grado massimo in testa:
## e' l'ordine in cui la divisione qui sotto lo legge, e invertirlo produce
## una correzione d'errore plausibile e sbagliata (la prima stesura lo
## faceva, e solo l'oracolo se n'e' accorto).
static func _generator(degree: int) -> PackedByteArray:
	var poly: PackedByteArray = PackedByteArray([1])
	for index in range(degree):
		var next: PackedByteArray = PackedByteArray()
		next.resize(poly.size() + 1)
		for position in range(next.size()):
			next[position] = 0
		for position in range(poly.size()):
			# moltiplicare per (x + α^index): la parte in x sale di grado,
			# la parte costante moltiplica il coefficiente.
			next[position] = int(next[position]) ^ int(poly[position])
			next[position + 1] = int(next[position + 1]) ^ _multiply(
				int(poly[position]), int(_exp_table[index])
			)
		poly = next
	return poly


static func _reed_solomon(data: PackedByteArray, count: int) -> PackedByteArray:
	_build_tables()
	var poly: PackedByteArray = _generator(count)
	var remainder: PackedByteArray = PackedByteArray()
	remainder.resize(count)
	for index in range(count):
		remainder[index] = 0
	for value in data:
		var factor: int = int(value) ^ int(remainder[0])
		for index in range(count - 1):
			remainder[index] = remainder[index + 1]
		remainder[count - 1] = 0
		for index in range(count):
			remainder[index] = int(remainder[index]) ^ _multiply(int(poly[index + 1]), factor)
	return remainder


# --- i disegni fissi --------------------------------------------------------

static func _place_finders(modules: Array, reserved: Array, size: int) -> void:
	for corner in [Vector2i(0, 0), Vector2i(size - 7, 0), Vector2i(0, size - 7)]:
		for row in range(-1, 8):
			for column in range(-1, 8):
				var y: int = corner.y + row
				var x: int = corner.x + column
				if y < 0 or y >= size or x < 0 or x >= size:
					continue
				var inside: bool = row >= 0 and row <= 6 and column >= 0 and column <= 6
				var ring: bool = row == 0 or row == 6 or column == 0 or column == 6
				var core: bool = row >= 2 and row <= 4 and column >= 2 and column <= 4
				modules[y][x] = inside and (ring or core)
				reserved[y][x] = true


static func _place_alignment(modules: Array, reserved: Array, version: int) -> void:
	var centers: Array = ALIGNMENT[version]
	for row_center in centers:
		for column_center in centers:
			# I tre angoli sono gia' occupati dai finder.
			if reserved[int(row_center)][int(column_center)]:
				continue
			for row in range(-2, 3):
				for column in range(-2, 3):
					var y: int = int(row_center) + row
					var x: int = int(column_center) + column
					var edge: bool = absi(row) == 2 or absi(column) == 2
					modules[y][x] = edge or (row == 0 and column == 0)
					reserved[y][x] = true


static func _place_timing(modules: Array, reserved: Array, size: int) -> void:
	for index in range(8, size - 8):
		var on: bool = index % 2 == 0
		if not reserved[6][index]:
			modules[6][index] = on
			reserved[6][index] = true
		if not reserved[index][6]:
			modules[index][6] = on
			reserved[index][6] = true


static func _reserve_format(reserved: Array, size: int) -> void:
	for index in range(9):
		if not reserved[8][index]:
			reserved[8][index] = true
		if not reserved[index][8]:
			reserved[index][8] = true
	for index in range(8):
		reserved[8][size - 1 - index] = true
		reserved[size - 1 - index][8] = true


## Il serpente dei dati: dal basso a destra, a colonne doppie, saltando la
## colonna 6 (quella del timing verticale).
static func _place_data(
	modules: Array, reserved: Array, codewords: PackedByteArray, size: int
) -> void:
	var bit: int = 0
	var total: int = codewords.size() * 8
	var column: int = size - 1
	var upward: bool = true
	while column > 0:
		if column == 6:
			column -= 1
		for step in range(size):
			var row: int = (size - 1 - step) if upward else step
			for offset in range(2):
				var x: int = column - offset
				if reserved[row][x]:
					continue
				var on: bool = false
				if bit < total:
					on = ((int(codewords[bit / 8]) >> (7 - (bit % 8))) & 1) == 1
				modules[row][x] = on
				bit += 1
		column -= 2
		upward = not upward


static func _mask_hits(mask: int, row: int, column: int) -> bool:
	match mask:
		0: return (row + column) % 2 == 0
		1: return row % 2 == 0
		2: return column % 3 == 0
		3: return (row + column) % 3 == 0
		4: return ((row / 2) + (column / 3)) % 2 == 0
		5: return ((row * column) % 2) + ((row * column) % 3) == 0
		6: return (((row * column) % 2) + ((row * column) % 3)) % 2 == 0
		7: return (((row + column) % 2) + ((row * column) % 3)) % 2 == 0
	return false


static func _apply_mask(modules: Array, reserved: Array, mask: int, size: int) -> void:
	for row in range(size):
		for column in range(size):
			if reserved[row][column]:
				continue
			if _mask_hits(mask, row, column):
				modules[row][column] = not modules[row][column]


## I 15 bit di formato: livello + maschera, BCH(15,5), XOR 0x5412, scritti
## due volte. Le posizioni sono elencate una per una, dal bit piu' alto al
## piu' basso: le due copie non si specchiano, e a memoria si sbagliano —
## queste vengono lette dall'oracolo (la prima stesura le aveva scambiate).
static func _place_format(modules: Array, mask: int, size: int) -> void:
	var value: int = (FORMAT_EC_M << 3) | mask
	var remainder: int = value << 10
	while _bit_length(remainder) >= 11:
		remainder = remainder ^ (0x537 << (_bit_length(remainder) - 11))
	var bits: int = ((value << 10) | remainder) ^ 0x5412

	var first: Array = [
		[8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 7], [8, 8],
		[7, 8], [5, 8], [4, 8], [3, 8], [2, 8], [1, 8], [0, 8],
	]
	var second: Array = []
	for index in range(7):
		second.append([size - 1 - index, 8])
	for index in range(8):
		second.append([8, size - 8 + index])

	for index in range(15):
		var on: bool = ((bits >> (14 - index)) & 1) == 1
		modules[int(first[index][0])][int(first[index][1])] = on
		modules[int(second[index][0])][int(second[index][1])] = on


static func _bit_length(value: int) -> int:
	var count: int = 0
	while value > 0:
		count += 1
		value = value >> 1
	return count


# --- il punteggio che sceglie la maschera -----------------------------------

static func _penalty(modules: Array) -> int:
	var size: int = modules.size()
	var score: int = 0

	# Regola 1: file di cinque o piu' moduli uguali, in riga e in colonna.
	for line in range(size):
		for horizontal in [true, false]:
			var run: int = 1
			for index in range(1, size):
				var current: bool = modules[line][index] if horizontal else modules[index][line]
				var previous: bool = modules[line][index - 1] if horizontal else modules[index - 1][line]
				if current == previous:
					run += 1
					continue
				if run >= 5:
					score += 3 + (run - 5)
				run = 1
			if run >= 5:
				score += 3 + (run - 5)

	# Regola 2: ogni blocco 2x2 dello stesso colore.
	for row in range(size - 1):
		for column in range(size - 1):
			var value: bool = modules[row][column]
			if (modules[row][column + 1] == value
					and modules[row + 1][column] == value
					and modules[row + 1][column + 1] == value):
				score += 3

	# Regola 3: il motivo che imita un finder.
	var wanted: Array = [true, false, true, true, true, false, true]
	for row in range(size):
		for column in range(size):
			for horizontal in [true, false]:
				if not _pattern_at(modules, row, column, wanted, horizontal, size):
					continue
				if _clear_run(modules, row, column, horizontal, size, -4):
					score += 40
				if _clear_run(modules, row, column, horizontal, size, 7):
					score += 40

	# Regola 4: lo sbilanciamento fra chiaro e scuro.
	var dark: int = 0
	for row in range(size):
		for column in range(size):
			if modules[row][column]:
				dark += 1
	var percent: int = (dark * 100) / (size * size)
	score += 10 * (absi(percent - 50) / 5)
	return score


static func _pattern_at(
	modules: Array, row: int, column: int, wanted: Array, horizontal: bool, size: int
) -> bool:
	for index in range(wanted.size()):
		var y: int = row if horizontal else row + index
		var x: int = column + index if horizontal else column
		if y >= size or x >= size:
			return false
		if modules[y][x] != bool(wanted[index]):
			return false
	return true


## Quattro moduli chiari di fila, prima o dopo il motivo: e' quello che fa
## scattare la penalita' piena.
static func _clear_run(
	modules: Array, row: int, column: int, horizontal: bool, size: int, from: int
) -> bool:
	for index in range(from, from + 4):
		var y: int = row if horizontal else row + index
		var x: int = column + index if horizontal else column
		if y < 0 or x < 0 or y >= size or x >= size:
			return false
		if modules[y][x]:
			return false
	return true
