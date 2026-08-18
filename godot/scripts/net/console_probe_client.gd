extends RefCounted
## La console simulata (voce 27, fase 2 — D-135): il telefono finto della
## sonda del filo. Si presenta col suo token, e risponde a ogni `choose` con
## la stessa formula pura dell'io copione (`scripted_io.pick`) — e' questo
## che permette di confrontare la partita col filo e quella senza, byte per
## byte: le decisioni sono identiche per costruzione, il filo deve solo non
## rompere niente.

const Protocol := preload("res://scripts/net/console_protocol.gd")
const ScriptedIO := preload("res://scripts/net/scripted_io.gd")

var ws: WebSocketPeer = WebSocketPeer.new()
var token: String = ""
var seed_value: int = 0
var greeted: bool = false
var answered: int = 0
var received: int = 0


func _init(url: String, p_token: String, p_seed: int) -> void:
	token = p_token
	seed_value = p_seed
	var err: int = ws.connect_to_url(url)
	assert(err == OK, "la console non raggiunge %s (%d)" % [url, err])


func poll() -> void:
	ws.poll()
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	if not greeted:
		ws.send_text(Protocol.encode({"kind": "hello", "token": token}))
		greeted = true
	while ws.get_available_packet_count() > 0:
		var message: Dictionary = Protocol.decode(ws.get_packet().get_string_from_utf8())
		received += 1
		if str(message.get("kind", "")) != "choose":
			continue
		var ask_id: int = int(message.get("ask_id", 0))
		var size: int = (message.get("labels", []) as Array).size()
		ws.send_text(Protocol.encode(
			Protocol.chosen_message(ask_id, ScriptedIO.pick(seed_value, ask_id, size))
		))
		answered += 1


func close() -> void:
	ws.close()
