extends "res://tests/test_case.gd"
## **Un anno intero, senza mai leggere un id** (ISSUES 63).
##
## Il committente, aprendo l'app: *«carte che spiegano esattamente cosa fanno e
## non tag o testi tecnici»*. E il criterio della voce: *«una persona puo'
## giocare un anno intero senza che nessuno le spieghi cosa fanno i bottoni.»*
##
## `test_a_turn_can_be_played` guarda **un turno**, `test_a_council_can_be_played`
## guarda **le dieci domande del Consiglio**, uno scatto per volta. Nessuna delle
## due guarda **l'anno intero**: fra un passo provato e l'altro ci stanno tutte
## le volte in cui il motore parla senza che nessuno controlli come.
##
## Qui si gioca una Chronicle intera con una persona al tavolo, e si tiene il
## conto di **tutto quello che le e' passato sotto gli occhi**: ogni domanda,
## ogni risposta possibile, **e il verbale dell'anno**, che sullo schermo sta
## accanto alle domande. Poi si chiede una cosa sola: **c'e' un id, li' dentro?**
##
## Il verbale c'e' perche' la prima stesura non ce l'aveva, e la frase che ne
## avevo tratto era piu' larga della misura: le domande erano pulite, il verbale
## no — otto righe su 584, «presenza: REG_MINIERE_ANTICHE» e «CONFLUENCE
## CNF_ANY_ANCIENT#3».
##
## Non e' una prova sullo schermo: e' una prova su **cosa il gioco sa dire**. Lo
## schermo puo' disegnarlo bene o male, ma se quello che arriva e' `TEN_FAMINE`
## non c'e' disegno che lo salvi.

const SeatDecider := preload("res://scripts/seat/seat_decider.gd")

## Le teste degli id che al tavolo non si leggono mai. Sono i prefissi veri dei
## dati, non un elenco a naso: se ne nasce uno nuovo, il dizionario dei segni lo
## dichiara e questa lista va allungata.
const IDS: Array = [
	"AST_", "TEN_", "CNF_", "CNS_", "DST_", "ECH_", "OBJ_", "REG_", "STR_",
	"THM_", "TGR_", "ENT_", "INC_",
]

## Quello che una persona ha davanti, senza uno schermo in mezzo.
##
## Non decide niente — risponde sempre la prima cosa legale, che e' quello che
## fa un tavolo che tira dritto — e **scrive tutto**: la domanda e ogni risposta
## possibile. E' il verbale di cosa il gioco ha messo sotto gli occhi di
## qualcuno in un anno intero.
class Orecchio extends RefCounted:
	var detto: Array = []
	var domande: int = 0

	func say(text: String) -> void:
		detto.append(str(text))

	func choose(prompt: String, labels: Array, _subjects: Array = []) -> int:
		domande += 1
		detto.append(str(prompt))
		for label in labels:
			detto.append(str(label))
		return 0


func before_each() -> void:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	session = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(session.setup("CHR_00", seats, 4242), "e l'anno si apre")


## **L'anno arriva in fondo, e non dice mai un id.**
##
## Una sola prova, perche' e' una sola domanda — ma tocca ogni passo che l'anno
## fa davvero fare, non quelli che ho pensato io di provare.
func test_a_whole_year_never_shows_an_id() -> void:
	var seat: String = str(session.world["turn_order"][0])
	var orecchio: Orecchio = Orecchio.new()
	var decider: RefCounted = SeatDecider.new([seat], session.log)
	decider.io = orecchio

	var report: Dictionary = await session.run(decider)
	assert_false(report.is_empty(), "l'anno arriva in fondo")

	# **Uno zero qui sarebbe la prova cieca, non un anno muto**: se nessuno ha
	# chiesto niente, non si e' misurato niente. E' la regola di casa, e in
	# questo progetto ha gia' morso sei volte.
	assert_true(
		orecchio.domande > 10,
		"e a quella persona e' stato chiesto qualcosa di vero: %d domande" % orecchio.domande
	)

	# **E il verbale conta quanto le domande.** La prima stesura guardava solo
	# quello che il decider mette davanti, e la frase che ne ho tratto — «un anno
	# intero senza mai un id» — era **piu' larga della misura**: il verbale sta
	# sullo schermo accanto alle domande, e una riga che dice «presenza:
	# REG_MINIERE_ANTICHE» e' un id sotto gli occhi di chi gioca esattamente come
	# lo sarebbe su un bottone. Erano otto righe su 584.
	var righe: Array = orecchio.detto.duplicate()
	for riga in session.log.lines:
		righe.append(str(riga))

	var colpevoli: Array = []
	for riga in righe:
		for id in IDS:
			if str(riga).contains(str(id)) and not colpevoli.has(str(riga)):
				colpevoli.append(str(riga))
	assert_true(
		colpevoli.is_empty(),
		"nessuna riga porta un id, su %d righe (%d domande + %d di verbale): %s" % [
			righe.size(), orecchio.detto.size(), session.log.lines.size(),
			" | ".join(PackedStringArray(colpevoli.slice(0, mini(6, colpevoli.size())))),
		]
	)
