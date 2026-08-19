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
const TableModel := preload("res://scripts/views/table_model.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")
const BoardSheet := preload("res://scripts/core/board_sheet.gd")

var session: RefCounted = null
var _tcp: TCPServer = TCPServer.new()
var _tokens: Dictionary = {}   # token -> seat
var _ios: Dictionary = {}      # seat -> ConsoleIO
var _peers: Dictionary = {}    # seat -> WebSocketPeer
var _lobby: Array = []         # WebSocketPeer in attesa di hello
var _mail: Dictionary = {}     # seat -> Array di messaggi da consegnare

# La vetrina sul filo (fase 3): l'iPad apre la pagina del tavolo nel browser
# e riceve il TableModel a ogni cambiamento del mondo. Il tavolo e' pubblico
# per costruzione (D-134): non serve un token per guardarlo.
var _tables: Array = []        # WebSocketPeer delle vetrine
var _table_clock: int = -1

# Il telefono che respira (fase 4): ogni messaggio di una console aggiorna
# il suo orologio, e la pagina manda un ping ogni pochi secondi - cosi' la
# vista tavolo puo' dire «la console di Aldric non risponde» invece di
# lasciare il dubbio al tavolo.
var _last_heard: Dictionary = {}  # seat -> msec dell'ultimo segno di vita

# La pagina in tasca: l'HTTP che serve console e tavolo (fase 3). Un solo
# file per pagina, servito con la porta del WebSocket gia' scritta dentro.
var _http: TCPServer = TCPServer.new()
var _browsing: Array = []      # StreamPeerTCP con una richiesta in corso
var _ws_port: int = 0


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
	_ws_port = port
	return out


## Apre anche la porta delle pagine (fase 3): `http://<ip>:<http_port>/?t=TOKEN`
## e' la console, `/tavolo` la vetrina. Ritorna false se la porta e' occupata.
func serve_pages(http_port: int) -> bool:
	return _http.listen(http_port) == OK


## L'indirizzo da scrivere grande sulla vista tavolo (e domani su un QR):
## il primo IPv4 vero della macchina, o il loopback se non ce n'e'.
static func local_address() -> String:
	for address in IP.get_local_addresses():
		var ip: String = str(address)
		if ip.contains(":") or ip.begins_with("127."):
			continue
		return ip
	return "127.0.0.1"


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
			# La vetrina non ha token: il tavolo e' pubblico per costruzione.
			if bool(message.get("table", false)):
				_tables.append(peer)
				peer.send_text(Protocol.encode(_table_message()))
				_lobby.erase(ws)
				break
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
			_last_heard[str(seat)] = Time.get_ticks_msec()
			var io: Variant = _ios.get(str(seat))
			if io != null:
				io.deliver(message)

	for ws in _tables.duplicate():
		var peer: WebSocketPeer = ws
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			_tables.erase(ws)
			continue
		while peer.get_available_packet_count() > 0:
			peer.get_packet()  # la vetrina non decide: quello che manda si ignora

	# Il mondo e' cambiato dall'ultima volta: la vetrina si aggiorna da sola.
	if not _tables.is_empty() and Protocol.clock(session) != _table_clock:
		var fresh: String = Protocol.encode(_table_message())
		for ws in _tables:
			if (ws as WebSocketPeer).get_ready_state() == WebSocketPeer.STATE_OPEN:
				(ws as WebSocketPeer).send_text(fresh)

	_serve_http()


func _table_message() -> Dictionary:
	_table_clock = Protocol.clock(session)
	return {"kind": "table", "clock": _table_clock, "model": TableModel.build(session)}


## Quanto tempo fa la console di un seggio ha dato segni di vita, in msec.
## -1 = mai vista. La vista tavolo lo traduce in «assente» o «non risponde
## da Ns» - la diagnosi onesta promessa dal dossier per le reti di casa.
func silence_of(seat: String) -> int:
	if not _peers.has(seat):
		return -1
	return Time.get_ticks_msec() - int(_last_heard.get(seat, 0))


func connected(seat: String) -> bool:
	return _peers.has(seat)


func close() -> void:
	for seat in _peers:
		(_peers[seat] as WebSocketPeer).close()
	for ws in _tables:
		(ws as WebSocketPeer).close()
	_peers.clear()
	_tables.clear()
	_lobby.clear()
	_browsing.clear()
	_tcp.stop()
	if _http.is_listening():
		_http.stop()


# --- le pagine (fase 3) -----------------------------------------------------

## Un server HTTP da stanza: una richiesta, una pagina, la porta si chiude.
## Serve solo i due file suoi - niente filesystem esposto, niente sorprese.
func _serve_http() -> void:
	if not _http.is_listening():
		return
	while _http.is_connection_available():
		_browsing.append(_http.take_connection())
	for stream in _browsing.duplicate():
		var tcp: StreamPeerTCP = stream
		tcp.poll()
		if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_browsing.erase(stream)
			continue
		if tcp.get_available_bytes() <= 0:
			continue
		var request: String = tcp.get_utf8_string(tcp.get_available_bytes())
		var line: String = request.get_slice("\r\n", 0)
		var path: String = line.get_slice(" ", 1)
		_respond(tcp, path)
		_browsing.erase(stream)


func _respond(tcp: StreamPeerTCP, path: String) -> void:
	# La faccia di una carta, dalla stessa sorgente della fustella (D-144).
	if path.begins_with("/carta/"):
		_respond_card(tcp, path)
		return
	# Il tabellone disegnato, dagli stessi piani del canvas (D-145).
	if path.begins_with("/mappa.svg"):
		_respond_svg(tcp, BoardSheet.board_svg(session), false)
		return
	var body: String = ""
	if path.begins_with("/tavolo"):
		body = _page("res://web/tavolo.html")
	elif path == "/" or path.begins_with("/?"):
		body = _page("res://web/console.html")
	if body == "":
		tcp.put_data("HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n".to_utf8_buffer())
		tcp.disconnect_from_host()
		return
	var payload: PackedByteArray = body.to_utf8_buffer()
	var head: String = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %d\r\nConnection: close\r\n\r\n" % payload.size()
	tcp.put_data(head.to_utf8_buffer())
	tcp.put_data(payload)
	tcp.disconnect_from_host()


## `/carta/<mazzo>/<id>.svg` — la carta, disegnata una volta sola in tutto il
## progetto: `PrintSheet.card_svg` e' la stessa funzione che impagina i fogli da
## fustellare e che l'app rasterizza per la mano sullo schermo (D-101, D-144).
## Il telefono la chiede e la mostra: nessuna immagine da impacchettare, nessuna
## faccia disegnata due volte, e una carta che cambia nei dati cambia in tutti e
## tre i posti insieme.
##
## Nessun token: le facce non sono segrete. Le carte esistono in copie e il
## titolo non e' mai stato un segreto — e' il fondamento della perquisizione
## strutturale (D-135); il segreto e' *quali copie tieni in mano*, e quello vive
## nello `state`, che il token lo chiede eccome.
func _respond_card(tcp: StreamPeerTCP, path: String) -> void:
	var trimmed: String = path.get_slice("?", 0).trim_suffix(".svg")
	var parts: PackedStringArray = trimmed.split("/", false)
	var body: String = ""
	if parts.size() == 3:
		var face: Dictionary = CardFace.of(str(parts[1]), str(parts[2]), session.data)
		if not face.is_empty():
			body = PrintSheet.card_svg(face)
	_respond_svg(tcp, body, true)


## Un SVG, o un 404 se non c'e' niente da disegnare. `forever` distingue le due
## specie: la faccia di una carta non cambia dentro una partita e si tiene in
## cache per sempre; il tabellone cambia a ogni mossa e non si tiene affatto.
func _respond_svg(tcp: StreamPeerTCP, body: String, forever: bool) -> void:
	if body == "":
		tcp.put_data(
			"HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n".to_utf8_buffer()
		)
		tcp.disconnect_from_host()
		return
	var payload: PackedByteArray = body.to_utf8_buffer()
	var head: String = (
		"HTTP/1.1 200 OK\r\nContent-Type: image/svg+xml; charset=utf-8\r\n"
		+ ("Cache-Control: max-age=31536000, immutable\r\n" if forever else "Cache-Control: no-store\r\n")
		+ "Content-Length: %d\r\nConnection: close\r\n\r\n"
	) % payload.size()
	tcp.put_data(head.to_utf8_buffer())
	tcp.put_data(payload)
	tcp.disconnect_from_host()


func _page(res_path: String) -> String:
	var handle: FileAccess = FileAccess.open(res_path, FileAccess.READ)
	if handle == null:
		return ""
	var text: String = handle.get_as_text()
	handle.close()
	return text.replace("__WS_PORT__", str(_ws_port))


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
