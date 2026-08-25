extends RefCounted
## Chi siede, e chi lo gioca (D-279).
##
## La scelta si fa **sulla soglia**, davanti alla copertina, prima che la sala
## apra: quattro seggi, e per ognuno una persona o un bot. Da qui in poi la
## partita non chiede piu' niente — niente «quale seggio prendi», niente «che
## mondo»: il mondo si pesca, come le tessere.
##
## Statico e non un autoload: due schermate devono passarsi tre righe di
## scelta, e un singleton nel `project.godot` per tre righe sarebbe una
## dipendenza in piu' per tutti.

## I seggi giocati da una persona a questo schermo. Vuoto = guardano tutti le
## policy, che e' un modo legittimo di aprire l'app (D-147).
static var humans: Array = []

## Vero quando la soglia ha davvero scelto: distingue «nessuna persona» da
## «non e' ancora passato di li'», e la sala apre da sola solo nel primo caso.
static var chosen: bool = false


static func take(seats: Array) -> void:
	humans = seats.duplicate()
	chosen = true


static func forget() -> void:
	humans = []
	chosen = false
