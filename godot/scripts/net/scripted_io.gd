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
static func pick(p_seed: int, ask_number: int, size: int) -> int:
	if size <= 0:
		return -1
	return (p_seed * 31 + ask_number * 7) % size


func say(_text: String) -> void:
	pass


func choose(_prompt: String, labels: Array, _subjects: Array = []) -> int:
	asked += 1
	return pick(seed_value, asked, labels.size())
