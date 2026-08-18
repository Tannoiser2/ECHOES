extends RefCounted
## L'io remoto (voce 27, fase 2 — D-135): la meta' attiva del telefono.
##
## Implementa il contratto di D-038 — `say(text)` e `choose(prompt, labels,
## subjects) -> int`, awaitable — parlando a un filo qualsiasi: ogni uscita e'
## un segnale `outgoing(message)`, ogni risposta entra da `deliver(message)`.
## Chi possiede il filo (l'host WebSocket, un loopback di test, la sonda) si
## collega al segnale e consegna i `chosen`: questo file non sa cosa sia un
## socket, ed e' per questo che si prova in headless.
##
## Prima di ogni domanda parte uno `state` fresco: la console disegna il
## mondo com'e' nel momento in cui deve scegliere. Una risposta con un
## `ask_id` vecchio si scarta (il telefono che risponde in ritardo non
## risponde per la domanda dopo); la domanda in sospeso resta leggibile per
## il rientro (fase 4: il telefono riavviato se la vede riproporre).

const Protocol := preload("res://scripts/net/console_protocol.gd")

signal outgoing(message: Dictionary)
signal _answered(index: int)

var session: RefCounted = null
var seat_id: String = ""
var _ask_seq: int = 0
var _pending: Dictionary = {}


func _init(p_session: RefCounted, p_seat: String) -> void:
	session = p_session
	seat_id = p_seat


func say(text: String) -> void:
	outgoing.emit(Protocol.say_message(session, text))


func choose(prompt: String, labels: Array, subjects: Array = []) -> int:
	_ask_seq += 1
	outgoing.emit(Protocol.state_message(session, seat_id))
	_pending = Protocol.choose_message(session, _ask_seq, prompt, labels, subjects)
	outgoing.emit(_pending)
	var index: int = await _answered
	return index


## La domanda in sospeso, o {} se il seggio non deve niente a nessuno.
## E' quello che l'host rimanda a una console che rientra.
func pending() -> Dictionary:
	return _pending.duplicate(true)


## Dal filo: un messaggio del telefono. Solo i `chosen` contano, e solo se
## rispondono alla domanda aperta - tutto il resto e' rumore da scartare.
func deliver(message: Dictionary) -> void:
	if str(message.get("kind", "")) != "chosen":
		return
	if _pending.is_empty():
		return
	if int(message.get("ask_id", -1)) != int(_pending.get("ask_id", -2)):
		return
	var limit: int = (_pending.get("labels", []) as Array).size()
	var index: int = int(message.get("index", -1))
	_pending = {}
	_answered.emit(-1 if index < 0 or index >= limit else index)
