extends RefCounted
## L'io copione (voce 27, fase 2 — D-135): risponde alle domande con una
## formula pura del seme e del numero di domanda. Non e' un giocatore: e' il
## gemello locale della console simulata — la stessa formula gira sul client
## della sonda del filo, ed e' cosi' che «la partita col filo» e «la partita
## senza» possono pretendersi identiche byte per byte.

var seed_value: int = 0
var asked: int = 0


func _init(p_seed: int) -> void:
	seed_value = p_seed


## La formula condivisa: client e copione la chiamano con lo stesso numero
## di domanda e ottengono lo stesso indice. Pura, senza RNG: il determinismo
## non deve dipendere da nessuno stato fuori dai suoi argomenti.
##
## L'hash butta i bit bassi apposta: la prima forma (`% size` su una
## combinazione lineare) aveva la parita' costante quando `ask_number`
## avanza di due - ed e' esattamente il passo del ciclo «scegli l'azione /
## La fai lo stesso?» del SeatDecider. Un copione che risponde «No, ci
## ripenso» a parita' costante puo' ripensarci per sempre: la sonda dei
## messaggi ci e' rimasta dentro quasi due ore prima del verbale.
static func pick(p_seed: int, ask_number: int, size: int) -> int:
	if size <= 0:
		return -1
	var mixed: int = p_seed * 2654435761 + ask_number * 40503
	return int((mixed >> 4) % size)


func say(_text: String) -> void:
	pass


func choose(_prompt: String, labels: Array, _subjects: Array = []) -> int:
	asked += 1
	return pick(seed_value, asked, labels.size())
