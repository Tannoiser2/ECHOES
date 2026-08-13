extends RefCounted
## Il segnaposto d'arte, che e' un segnaposto e lo dice (ART_BIBLE, §21).
##
## Fino all'arte definitiva ogni pezzo mostra un'immagine procedurale. La
## ART_BIBLE chiedeva che mostrasse in chiaro il proprio id e la propria
## `art_prompt_key`, «cosi' una carta sbagliata si riconosce a colpo d'occhio
## durante il playtest», e fino alla 0.1.17 non esisteva: l'unico file grafico
## del repository era `icon.svg`.
##
## Un rettangolo grigio avrebbe soddisfatto la lettera. Questo fa due cose in
## piu', ed e' il motivo per cui vale la pena scriverlo:
##
## 1. **e' diverso per ogni chiave**, in modo deterministico. Cinquanta carte
##    tutte uguali sono cinquanta carte che non si distinguono sul tavolo, e un
##    playtest su segnaposto identici non insegna niente sull'impaginato.
## 2. **rispetta il vincolo di composizione** che vale per l'arte vera: il
##    soggetto sta nei due terzi alti, il terzo basso resta calmo per l'overlay
##    di testo (ART_BIBLE, regola invalicabile 2). Se un'illustrazione vera
##    arrivera' con la composizione sbagliata, si vedra' subito, perche' il
##    segnaposto la mostrava giusta.
##
## Deterministico e senza RNG di sessione: la stessa chiave da' la stessa
## immagine su ogni macchina e a ogni export. Non tocca `RngService` proprio
## perche' non deve entrare nel flusso di estrazioni della partita.

## Frazione dell'altezza che il soggetto **non** invade: l'area di respiro.
const CALM: float = 0.34

## FNV-1a a 32 bit sui byte della chiave. Scritto a mano invece di usare
## `String.hash()` perche' quello e' un dettaglio del motore e questo finisce
## dentro file che devono restare identici fra versioni di Godot.
static func fingerprint(key: String) -> int:
	var hash_value: int = 0x811c9dc5
	for byte in key.to_utf8_buffer():
		hash_value = (hash_value ^ int(byte)) & 0xffffffff
		hash_value = (hash_value * 0x01000193) & 0xffffffff
	return hash_value


## Un piano di disegno: forme normalizzate in 0..1 sul rettangolo dell'immagine.
## Chi disegna moltiplica per le proprie dimensioni e non sa altro.
##
## `accent` e' l'accento della famiglia, cioe' l'unico colore saturo permesso
## dalla ART_BIBLE: il segnaposto usa quello e due terre, e nient'altro.
static func plan(key: String, accent: String) -> Dictionary:
	var state: int = fingerprint(key)
	var horizon: float = 0.42 + 0.16 * _unit(state)
	state = _step(state)

	var count: int = 3 + (state % 3)
	state = _step(state)

	var shapes: Array = []
	for i in range(count):
		var width: float = 0.10 + 0.16 * _unit(state)
		state = _step(state)
		var height: float = 0.12 + 0.34 * _unit(state)
		state = _step(state)
		# Distribuite sulla larghezza invece che a caso: tre sagome ammucchiate
		# sono un errore di composizione, non una variazione.
		var centre: float = (float(i) + 0.5) / float(count) + 0.10 * (_unit(state) - 0.5)
		state = _step(state)
		var kind: String = ["block", "spire", "disc"][state % 3]
		state = _step(state)
		shapes.append({
			"kind": kind,
			"x": clampf(centre - width * 0.5, 0.02, 0.98 - width),
			"y": clampf(horizon - height, 0.04, 1.0),
			"w": width,
			"h": height,
			"tone": (state % 2),
		})
		state = _step(state)

	return {
		"key": key,
		"accent": accent,
		"horizon": horizon,
		"calm": 1.0 - CALM,
		"shapes": shapes,
		"ground": "#1b1712",
		"sky": "#2a231b",
	}


static func _step(state: int) -> int:
	# LCG di Numerical Recipes, mascherato a 32 bit: serve una sequenza ripetibile
	# e non una buona sequenza.
	return (state * 1664525 + 1013904223) & 0xffffffff


static func _unit(state: int) -> float:
	return float(state % 10000) / 10000.0


## Il segnaposto come frammento SVG, posizionato dove gli si dice.
##
## Scritto qui e non dentro il foglio di stampa perche' l'anteprima dentro l'app
## disegna lo stesso piano con `_draw()`: se le due immagini divergessero,
## l'anteprima smetterebbe di essere un'anteprima.
static func svg(key: String, accent: String, x: float, y: float, w: float, h: float) -> String:
	var drawing: Dictionary = plan(key, accent)
	var out: Array = []
	out.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="%s"/>' % [
		x, y, w, h, str(drawing["sky"])
	])
	var horizon: float = y + h * float(drawing["horizon"])
	for shape in drawing["shapes"]:
		var item: Dictionary = shape
		var sx: float = x + w * float(item["x"])
		var sy: float = y + h * float(item["y"])
		var sw: float = w * float(item["w"])
		var sh: float = h * float(item["h"])
		var tone: String = accent if int(item["tone"]) == 1 else "#3a332a"
		match str(item["kind"]):
			"spire":
				out.append('<polygon points="%.2f,%.2f %.2f,%.2f %.2f,%.2f" fill="%s"/>' % [
					sx, sy + sh, sx + sw * 0.5, sy, sx + sw, sy + sh, tone
				])
			"disc":
				out.append('<circle cx="%.2f" cy="%.2f" r="%.2f" fill="%s"/>' % [
					sx + sw * 0.5, sy + sh * 0.5, minf(sw, sh) * 0.5, tone
				])
			_:
				out.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="%s"/>' % [
					sx, sy, sw, sh, tone
				])
	out.append('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="%s"/>' % [
		x, horizon, w, y + h - horizon, str(drawing["ground"])
	])
	# La fascia calma, segnata: e' quella che l'arte vera dovra' lasciare libera.
	out.append(
		'<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="none" stroke="%s"'
		% [x, y + h * float(drawing["calm"]), w, h * CALM, "#4a4237"]
		+ ' stroke-width="0.2" stroke-dasharray="1.4 1.4"/>'
	)
	# E la chiave, in chiaro: e' il motivo per cui questo segnaposto esiste.
	out.append(
		'<text x="%.2f" y="%.2f" font-family="monospace" font-size="1.8" fill="#6b6355">%s</text>'
		% [x + 1.4, y + h - 1.6, escape(key)]
	)
	return "\n".join(PackedStringArray(out))


static func escape(text: String) -> String:
	return (
		text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
			.replace('"', "&quot;")
	)
