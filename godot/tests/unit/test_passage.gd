extends "res://tests/test_case.gd"
## Il varco che si chiude (D-166), §8 del catalogo — l'ultimo pezzo.
##
## E' l'unica cosa della mappa che cambia la **forma** del mondo invece di cosa
## ci sta sopra: fino a 0.1.132 le adiacenze erano l'unica cosa che non cambiava
## mai. Ed e' anche l'unica che puo' rendere un Destino impossibile, perche' una
## Regione irraggiungibile e' una clausola che nessuno potra' mai soddisfare.
## Per questo il taglio si **prova** e si annulla se spezza il mondo.

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return {"kind": "TEST", "id": "passage"}


## `apply()` restituisce l'Effect memorizzato, non il risultato della mutazione:
## il no-op sta scritto nell'`inverse_payload`, che e' cio' che servirebbe per
## disfarlo. Un taglio rifiutato non ha niente da disfare.
func _close(here: String, there: String) -> Dictionary:
	var stored: Dictionary = session.applier.apply(Effect.make(
		"CLOSE_PASSAGE", "region", here, {"region_id": there}, _source()
	))
	return stored.get("inverse_payload", {}) as Dictionary


## Chiudere un varco toglie l'arco da tutte e due le parti.
func test_closing_cuts_both_ways() -> void:
	assert_true(
		session.service.neighbours_of("REG_TERRE_NAHR").has("REG_MONTAGNE_ROSSE"),
		"si toccano, all'inizio"
	)
	_close("REG_TERRE_NAHR", "REG_MONTAGNE_ROSSE")
	assert_false(
		session.service.neighbours_of("REG_TERRE_NAHR").has("REG_MONTAGNE_ROSSE"),
		"la steppa non tocca piu' la montagna"
	)
	assert_false(
		session.service.neighbours_of("REG_MONTAGNE_ROSSE").has("REG_TERRE_NAHR"),
		"e la montagna non tocca piu' la steppa"
	)


## E si sente dove conta: da dove non si tocca piu', non si entra.
func test_a_closed_pass_is_a_move_you_cannot_make() -> void:
	# Vaerax sta sulla montagna; la steppa gli e' adiacente, quindi ci puo' andare.
	assert_true(
		session.service.can_move_to("ENT_VAERAX", "REG_TERRE_NAHR"),
		"con il passo aperto ci si arriva"
	)
	_close("REG_MONTAGNE_ROSSE", "REG_TERRE_NAHR")
	assert_false(
		session.service.can_move_to("ENT_VAERAX", "REG_TERRE_NAHR"),
		"col passo franato bisogna fare il giro"
	)


## La guardia: un taglio che isolerebbe una Regione **non avviene**.
func test_a_cut_that_would_break_the_world_is_refused() -> void:
	# Le Miniere hanno due archi: la montagna e la strada. Tolti tutti e due
	# resterebbero irraggiungibili — il secondo taglio va rifiutato.
	_close("REG_MINIERE_ANTICHE", "REG_STRADA_MERCANTI")
	assert_true(session.service.every_region_reachable(), "dopo il primo taglio si arriva ancora ovunque")

	var refused: Dictionary = _close("REG_MINIERE_ANTICHE", "REG_MONTAGNE_ROSSE")
	assert_true(bool(refused.get("noop", false)), "il secondo taglio non avviene")
	assert_true(
		session.service.neighbours_of("REG_MINIERE_ANTICHE").has("REG_MONTAGNE_ROSSE"),
		"l'arco e' ancora li'"
	)
	assert_true(session.service.every_region_reachable(), "e il mondo e' ancora intero")


## Riaprire rimette il vicino **al posto suo**, non in fondo: l'ordine dei
## vicini e' quello d'autore e il gioco lo legge (`$adjacent` ci pesca dentro).
func test_reopening_restores_the_authored_order() -> void:
	var before: Array = (session.service.neighbours_of("REG_MONTAGNE_ROSSE") as Array).duplicate()
	_close("REG_MONTAGNE_ROSSE", "REG_TERRE_NAHR")
	session.applier.apply(Effect.make(
		"OPEN_PASSAGE", "region", "REG_MONTAGNE_ROSSE", {"region_id": "REG_TERRE_NAHR"}, _source()
	))
	assert_eq(
		str(session.service.neighbours_of("REG_MONTAGNE_ROSSE")), str(before),
		"il mondo torna identico, non solo equivalente"
	)


## Un varco gia' chiuso non si chiude due volte, e uno gia' aperto non si riapre.
func test_closing_twice_does_nothing() -> void:
	_close("REG_TERRE_NAHR", "REG_MONTAGNE_ROSSE")
	var again: Dictionary = _close("REG_TERRE_NAHR", "REG_MONTAGNE_ROSSE")
	assert_true(bool(again.get("noop", false)), "il secondo giro non fa niente")
