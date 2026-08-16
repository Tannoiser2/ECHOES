extends RefCounted
## Le carte fisiche, sullo schermo (D-101).
##
## La GUI deve essere quanto di più vicino al gioco fisico: quello che sta in
## mano a un giocatore è **la carta stampata**, non un pannello che le
## somiglia. Questo helper rasterizza le stesse facce dei fogli di stampa
## (`PrintSheet.card_svg`, D-056) una volta per mazzo e le tiene in cache -
## la stessa disciplina della cronaca (D-086): un solo impaginatore, due
## superfici.

const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")

## Pixel per millimetro: a 3 una classica 63x88 esce 189x264, nitida anche
## ingrandita e leggera da tenere in cache per interi mazzi.
const SCALE: float = 3.0

static var _textures: Dictionary = {}
static var _built_decks: Dictionary = {}


## La texture della carta `id` del mazzo `deck`, o null se non esiste. Il
## mazzo si rasterizza intero alla prima richiesta: le facce vengono dallo
## stesso `deck_of` dell'export, quindi non possono divergere dalla stampa.
static func texture_for(deck: String, id: String, data: RefCounted) -> Texture2D:
	if not _built_decks.has(deck):
		_built_decks[deck] = true
		for face in CardFace.deck_of(deck, data):
			var image := Image.new()
			if image.load_svg_from_string(PrintSheet.card_svg(face), SCALE) == OK:
				_textures["%s/%s" % [deck, str(face["id"])]] = (
					ImageTexture.create_from_image(image)
				)
	return _textures.get("%s/%s" % [deck, id])
