extends RefCounted
## Dove sta l'arte vera, quando c'e' (ISSUES 5).
##
## Il segnaposto procedurale e il brief esistono dalla 0.1.18, e in mezzo mancava
## la cosa piu' semplice: **un posto dove mettere l'immagine**. Niente nel codice
## caricava un file per una `art_prompt_key`, quindi un'illustrazione consegnata
## restava un file in una cartella.
##
## La convenzione e' una sola riga: la chiave con i punti al posto delle barre,
## sotto `res://art/`, in PNG.
##
##   asset.force.levy   ->  res://art/asset/force/levy.png
##   region.eredan      ->  res://art/region/eredan.png
##   map.board          ->  res://art/map/board.png
##
## Niente manifesto, niente indice da tenere allineato: il nome del file **e'**
## la chiave. Un file in piu' si vede, un file che manca non rompe niente - chi
## chiede un'immagine che non c'e' riceve `null` e disegna il segnaposto.
##
## Due strade per arrivare all'immagine, e servono tutt'e due:
##
## 1. **i byte del PNG**, letti e decodificati a runtime. Un file appena copiato
##    nella cartella funziona subito - senza aprire l'editor, senza reimportare -
##    ed e' cosi' che funziona nei test, nella CLI e mentre si lavora.
## 2. **la risorsa importata**, se il file grezzo non c'e'. In un build esportato
##    Godot impacchetta la texture importata e *non* il PNG originale: la prima
##    strada li' non trova niente, e senza la seconda il quadro sparirebbe
##    esattamente nel posto in cui si gioca davvero.
##
## Il primo tentativo che riesce vince. Chi chiama non sa quale sia stato.

## La radice. Parametrizzata solo perche' i test puntano a una cartella di
## prova - il gioco non la cambia mai.
const ROOT: String = "res://art"

## La chiave del tabellone dipinto. Non e' in nessun dato perche' non appartiene
## a una Regione ne' a una Chronicle: e' la mappa, che le due saghe condividono.
const BOARD: String = "map.board"

## Le texture gia' costruite, per non rileggere e ridecodificare un PNG a ogni
## `_draw()`. Le immagini di questo gioco sono poche e grandi: e' esattamente il
## caso in cui una cache serve.
static var _cache: Dictionary = {}


static func path_for(key: String, root: String = ROOT) -> String:
	return "%s/%s.png" % [root, key.replace(".", "/")]


static func has(key: String, root: String = ROOT) -> bool:
	if key == "":
		return false
	var path: String = path_for(key, root)
	return FileAccess.file_exists(path) or ResourceLoader.exists(path)


## L'immagine, o `null` se non c'e'. Un PNG illeggibile e' trattato come
## assente: un'immagine rotta non deve impedire di giocare, deve solo far
## ricomparire il segnaposto.
static func image(key: String, root: String = ROOT) -> Image:
	if key == "" or not FileAccess.file_exists(path_for(key, root)):
		return null
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path_for(key, root))
	if bytes.is_empty():
		return null
	var loaded := Image.new()
	if loaded.load_png_from_buffer(bytes) != OK:
		push_warning("art: %s non e un PNG leggibile" % path_for(key, root))
		return null
	return loaded


static func texture(key: String, root: String = ROOT) -> Texture2D:
	if _cache.has(key):
		return _cache[key]
	var made: Texture2D = null
	var loaded: Image = image(key, root)
	if loaded != null:
		made = ImageTexture.create_from_image(loaded)
	else:
		# Nel pacchetto esportato il PNG non c'e': c'e' la texture importata.
		var path: String = path_for(key, root)
		if key != "" and ResourceLoader.exists(path):
			var resource: Resource = ResourceLoader.load(path)
			if resource is Texture2D:
				made = resource
	_cache[key] = made
	return made


## Il PNG come `data:` URI, per il foglio di stampa.
##
## Un SVG che punta a un file esterno e' due file che si perdono uno senza
## l'altro; incorporato resta un file solo, che e' la ragione per cui l'export
## usa SVG. E resta deterministico: gli stessi byte danno la stessa stringa.
## Serve i byte veri, quindi vale solo dove il PNG grezzo c'e' - cioe' nel
## progetto, che e' l'unico posto da cui si lancia un export di stampa.
static func data_uri(key: String, root: String = ROOT) -> String:
	if key == "" or not FileAccess.file_exists(path_for(key, root)):
		return ""
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path_for(key, root))
	if bytes.is_empty():
		return ""
	return "data:image/png;base64,%s" % Marshalls.raw_to_base64(bytes)


## Solo per i test: la cache e' statica e sopravviverebbe fra un caso e l'altro.
static func forget() -> void:
	_cache.clear()
