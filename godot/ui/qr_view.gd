extends Control
## Il QR disegnato (voce 27, D-137): un quadrato di moduli, niente immagini
## da caricare. `show_text(url)` e basta.
##
## Il margine chiaro non e' decorazione: senza i quattro moduli di quiete
## attorno, molte fotocamere non agganciano il codice. Per lo stesso motivo
## il fondo e' bianco pieno anche su un tema scuro — un QR in negativo si
## legge male, e questo deve funzionare al primo tentativo con quattro
## persone che aspettano.

const QrCode := preload("res://scripts/net/qr_code.gd")
const QUIET: int = 4

var _matrix: Array = []


func show_text(text: String) -> void:
	_matrix = QrCode.matrix(text)
	queue_redraw()


## Se il testo non entrava nelle versioni supportate non c'e' niente da
## disegnare, e chi ci sta sopra mostra l'indirizzo scritto.
func has_code() -> bool:
	return not _matrix.is_empty()


func _draw() -> void:
	if _matrix.is_empty():
		return
	var modules: int = _matrix.size() + QUIET * 2
	var side: float = minf(size.x, size.y)
	var step: float = floorf(side / float(modules))
	if step < 1.0:
		step = 1.0
	var origin: Vector2 = ((size - Vector2(step, step) * modules) * 0.5).floor()
	draw_rect(Rect2(origin, Vector2(step, step) * modules), Color.WHITE)
	for row in range(_matrix.size()):
		for column in range(_matrix[row].size()):
			if not bool(_matrix[row][column]):
				continue
			draw_rect(
				Rect2(
					origin + Vector2(column + QUIET, row + QUIET) * step,
					Vector2(step, step)
				),
				Color.BLACK
			)
