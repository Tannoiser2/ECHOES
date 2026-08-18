extends RefCounted
## L'host del tavolo (voce 27, fase 2 — D-135): il computer che ospita la
## partita e tiene un filo WebSocket per ogni console.
##
## L'host possiede gli io remoti (`ConsoleIO`, uno per seggio umano) e il
## loro accoppiamento: un telefono si presenta con `{"kind":"hello",
## "token":...}` e il token dice CHI e' — chi inquadra il QR di un seggio e'
## quel seggio (B della seduta). I messaggi verso una console assente si
## mettono in posta e si consegnano al rientro, insieme alla domanda in
## sospeso: la partita non aspetta mai un socket, aspetta una risposta.
##
## Niente HTTP qui: la pagina della console e' materia della fase 3. Questo
## file muove dizionari su un filo, e tutto cio' che i dizionari contengono
## e' gia' passato dal filtro dei modelli (D-134) — la perquisizione di
## `console_protocol.audit` lo prova.

const Protocol := preload("res://scripts/net/console_protocol.gd")
const ConsoleIO := preload("res://scripts/net/console_io.gd")

var session: RefCounted = null
var _tcp: TCPServer = TCPServer.new()
var _tokens: Dictionary = {}   # token -> seat
var _ios: Dictionary = {}      # seat -> ConsoleIO
var _peers: Dictionary = {}    # seat -> WebSocketPeer
var _lobby: Array = []         # WebSocketPeer in attesa di hello
var _mail: Dictionary = {}     # seat -> Array di messaggi da consegnare


func _init(p_session: RefCounted) -> void:
	session = p_session


## Apre la stanza: un io e un token per ogni seggio umano. Ritorna
## {seat: token} — quello che la vista tavolo trasforma in QR. `token_seed`
## rende i token riproducibili nelle sonde; a una partita vera si passa un
## seme qualsiasi (l'identita' sta nel possesso del token, non nella sua
## imprevedibilita' verso il motore: il gioco non lo legge mai).
func open(port: int, seats: Array, token_seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = token_seed
	var out: Dictionary = {}
	for seat in seats:
		var token: String = "%04x%04x" % [rng.randi() % 65536, rng.randi() % 65536]
		_tokens[token] = str(seat)
		out[str(seat)] = token
		var io: RefCounted = ConsoleIO.new(session, str(seat))
		io.outgoing.connect(_send.bind(str(seat)))
		_ios[str(seat)] = io
		_mail[str(seat)] = []
	var err: int = _tcp.listen(port)
	assert(err == OK, "la porta %d non si apre (%d)" % [port, err])
	return out


func io_for(seat: String) -> RefCounted:
	return _ios.get(seat)


## Rigenera il token di un seggio a partita in corso (B della seduta): il
## vecchio smette di valere e il telefono che lo teneva viene scollegato.
func reissue(seat: String, token_seed: int) -> String:
	for token in _tokens.keys():
		if str(_tokens[token]) == seat:
			_tokens.erase(token)
	var rng := RandomNumberGenerator.new()
	rng.seed = token_seed
	var fresh: String = "%04x%04x" % [rng.randi() % 65536, rng.randi() % 65536]
	_tokens[fresh] = seat
	if _peers.has(seat):
		(_peers[seat] as WebSocketPeer).close()
		_peers.erase(seat)
	return fresh


## Un giro di manovella: accetta chi bussa, legge chi parla, consegna la
## posta di chi rientra. Da chiamare a ogni frame (o a ogni giro della sonda).
func poll() -> void:
	while _tcp.is_connection_available():
		var ws := WebSocketPeer.new()
		ws.accept_stream(_tcp.take_connection())
		_lobby.append(ws)

	for ws in _lobby.duplicate():
		var peer: WebSocketPeer = ws
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			_lobby.erase(ws)
			continue
		while peer.get_available_packet_count() > 0:
			var message: Dictionary = Protocol.decode(
				peer.get_packet().get_string_from_utf8()
			)
			if str(message.get("kind", "")) != "hello":
				continue
			var seat: String = str(_tokens.get(str(message.get("token", "")), ""))
			if seat == "":
				peer.close()
				break
			_bind(seat, peer)
			_lobby.erase(ws)
			break

	for seat in _peers.keys():
		var peer: WebSocketPeer = _peers[seat]
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			_peers.erase(seat)
			continue
		while peer.get_available_packet_count() > 0:
			var message: Dictionary = Protocol.decode(
				peer.get_packet().get_string_from_utf8()
			)
			var io: Variant = _ios.get(str(seat))
			if io != null:
				io.deliver(message)


func close() -> void:
	for seat in _peers:
		(_peers[seat] as WebSocketPeer).close()
	_peers.clear()
	_lobby.clear()
	_tcp.stop()


func _send(message: Dictionary, seat: String) -> void:
	var peer: Variant = _peers.get(seat)
	if peer != null and (peer as WebSocketPeer).get_ready_state() == WebSocketPeer.STATE_OPEN:
		(peer as WebSocketPeer).send_text(Protocol.encode(message))
		return
	# La console non c'e': il messaggio aspetta in posta. La domanda aperta
	# non serve tenerla qui - l'io la ricorda (pending) e il rientro la
	# ripropone fresca.
	(_mail[seat] as Array).append(message)


## Il rientro (fase 4 in miniatura, gia' qui perche' il filo lo regala): al
## telefono che si presenta col token giusto arrivano la posta arretrata,
## uno stato fresco, e la domanda in sospeso se il suo seggio ne deve una.
func _bind(seat: String, peer: WebSocketPeer) -> void:
	_peers[seat] = peer
	for message in _mail[seat]:
		peer.send_text(Protocol.encode(message))
	(_mail[seat] as Array).clear()
	peer.send_text(Protocol.encode(Protocol.state_message(session, seat)))
	var io: Variant = _ios.get(seat)
	if io != null and not (io.pending() as Dictionary).is_empty():
		peer.send_text(Protocol.encode(io.pending()))
