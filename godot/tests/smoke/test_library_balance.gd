extends "res://tests/test_case.gd"
## Fase 4 della #25: la guardia di bilanciamento sugli anni-biblioteca.
##
## `test_balance.gd` sorveglia l'anno scritto; nessuno sorvegliava l'anno che
## la biblioteca pesca. E l'anno pescato e' quello con piu' modi di rompersi in
## silenzio: la mano delle Tensioni cambia a ogni seme, meta' delle domande
## passa dal Consiglio del proprio dominio, il mondo arriva gia' segnato
## dall'era prima, e da D-079 la pesca ascolta quei segni. Un anno-biblioteca
## che decide niente e' esattamente il fallimento che il §7 vuole vedere
## (D-047) - e non c'era un test che lo vedesse.
##
## La guardia gioca l'anno scritto, gli fa ereditare l'anno-biblioteca, e conta
## i Consigli del secondo. I limiti duri sono quelli del §7, gli stessi di
## `test_balance.gd`. La banda dichiarata e' piu' larga di quella dell'anno
## scritto - misurata alla nascita (0.1.34): mediana 4 dopo la corona e 5 dopo
## le citta', da 2 a 6 - perche' un anno pescato e' legittimamente piu' quieto
## di uno scritto per essere pieno: eredita conti gia' chiusi.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
# GameSession arriva da test_case.gd: ridichiararlo qui e' un errore di parsing.

const RUNS: int = 12
const FIRST_SEED: int = 500

## I limiti duri del §7, identici a test_balance.gd: sotto il pavimento l'anno
## non ha deciso niente, sopra il soffitto il tavolo non ha fatto altro.
const FLOOR: int = 2
const CEILING: int = 8

## La banda della mediana, dichiarata dalla misura di nascita e non dal
## desiderio: 4 (corona) e 5 (citta') su 12 semi ciascuna.
##
## Il soffitto sale a 7 con D-169, per la stessa ragione dell'anno scritto e
## nello stesso commit: aperta la Vittoria di Lyra, un seggio che per tre anni
## su quattro non aveva obiettivi ha ricominciato a proporre, e l'anno pescato
## si e' alzato con quello scritto — 12 anni della corona, mediana da 6 a 7.
## L'anno di libreria resta piu' largo di quello scritto perche' eredita conti
## gia' chiusi, ed e' l'unica cosa che questa banda ha sempre detto. Il
## pavimento non si e' mosso.
const BAND_LOW: int = 3
const BAND_HIGH: int = 7


func test_a_library_year_still_decides_things() -> void:
	# **Una coppia sola** (D-318): gli anni d'autore incatenati sono stati
	# cancellati, e la seconda coppia nominava CHR_03 e CHR_04. Resta il banco,
	# che la catena prima-eta' -> seconda-eta' ce l'ha per costruzione.
	for pair in [["CHR_TEST", "CHR_TEST_HEIR"]]:
		var counts: Array = []
		var outside: int = 0
		for i in range(RUNS):
			var seats: Array = (
				data().chronicles[str(pair[0])]["entities"] as Array
			).duplicate()
			var first: RefCounted = GameSession.new(data())
			first.setup(str(pair[0]), seats, FIRST_SEED + i)
			var report: Dictionary = await first.run(PolicyDecider.new(first.log))
			var second: RefCounted = GameSession.new(data())
			second.setup(str(pair[1]), seats, FIRST_SEED + i)
			second.inherit_from(first.world, report["destiny_results"])
			await second.run(PolicyDecider.new(second.log))
			var count: int = int(second.world["confluence_count"])
			counts.append(count)
			if count < FLOOR or count > CEILING:
				outside += 1
			first.dispose()
			second.dispose()

		counts.sort()
		var median: int = int(counts[counts.size() / 2])
		assert_true(
			median >= BAND_LOW and median <= BAND_HIGH,
			"%s dopo %s: mediana attesa %d-%d, misurata %d su %d anni: %s" % [
				str(pair[1]), str(pair[0]), BAND_LOW, BAND_HIGH, median, RUNS, str(counts)
			]
		)
		assert_true(
			outside * 10 <= RUNS,
			"%s: %d anni su %d fuori dai limiti duri %d-%d: %s" % [
				str(pair[1]), outside, RUNS, FLOOR, CEILING, str(counts)
			]
		)
