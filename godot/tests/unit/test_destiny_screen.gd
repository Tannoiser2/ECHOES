extends "res://tests/test_case.gd"
## Lo schermo dice quello che la carta dice (PZ-8, D-271).
##
## Da D-270 ogni Destino spedito ha una faccia fisica con le tre righe
## `reads` — la frase che un giocatore legge sul cartoncino. Il pannello del
## Destino le usa come righe dei gradini: la UI come tavolo, alla lettera.
## La logica sta in una funzione pura (`StatusPanel.rung_text`) proprio per
## poterla provare qui senza montare un albero di Control.

const StatusPanel := preload("res://ui/status_panel.gd")


## Su ogni Destino spedito, la riga del gradino e' la frase della carta.
func test_the_screen_reads_the_shipped_card() -> void:
	var loaded: RefCounted = data()
	for destiny_id in loaded.destinies:
		var destiny: Dictionary = loaded.destinies[str(destiny_id)]
		var face: Dictionary = destiny.get("physical", {}) as Dictionary
		for level in ["minimum", "victory", "triumph"]:
			assert_eq(
				StatusPanel.rung_text(destiny, str(level)),
				str((face["reads"] as Dictionary)[str(level)]),
				"%s/%s: lo schermo dice quello che la carta dice" % [str(destiny_id), str(level)]
			)


## Un Destino fabbricato senza faccia ripiega sull'etichetta digitale: le
## prove che si costruiscono un Destino al volo non devono rompere il pannello.
func test_a_faceless_destiny_falls_back_to_its_label() -> void:
	var bare: Dictionary = {"minimum": {"label": "La riga di ripiego"}}
	assert_eq(
		StatusPanel.rung_text(bare, "minimum"), "La riga di ripiego",
		"senza faccia parla l'etichetta"
	)
	assert_eq(StatusPanel.rung_text(bare, "victory"), "", "un gradino mai scritto resta muto")
