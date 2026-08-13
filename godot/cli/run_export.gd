extends SceneTree
## L'export: dai JSON ai fogli da stampare e al brief per chi disegna (§25.15).
##
##   godot --headless --path godot --script res://cli/run_export.gd -- \
##       --out=out/export [--bible=docs/ART_BIBLE.md] [--proof]
##
## Due cose escono da qui, e sono le due cose che servono per portare il gioco
## fuori dallo schermo:
##
## - **i fogli**, A4 in scala 1:1, con i segni di taglio, il mazzo intero
##   comprese le copie (48 facce Asset sono 132 carte, D-040). Con `--proof`
##   una copia sola per faccia, che e' quello che si guarda per correggere.
## - **il brief d'arte**: ogni `art_prompt_key` in uso, con il MASTER PROMPT
##   giusto gia' composto col soggetto che i dati conoscono. Il brief non
##   ricopia la ART_BIBLE: la legge. Se il file non c'e', lo dice e mette il
##   rimando.
##
## Deterministico: nessun RNG, ordine per id, testo puro. Due export dello stesso
## dato escono identici byte per byte, e la CI puo' confrontarli (§18.3).

const DataSet := preload("res://scripts/core/data_set.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const PrintSheet := preload("res://scripts/core/print_sheet.gd")
const ArtBible := preload("res://scripts/core/art_bible.gd")

const LABELS: Dictionary = CardFace.DECK_LABELS


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var out_dir: String = str(options.get("out", "out/export"))
	var proof: bool = options.has("proof")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	if not _make_dir("%s/fogli" % out_dir):
		printerr("non riesco a scrivere in %s" % out_dir)
		quit(4)
		return

	print("EXPORT%s -> %s" % ["  (proof: una copia per faccia)" if proof else "", out_dir])
	print("")
	print("  %-16s %6s %6s %7s" % ["mazzo", "facce", "carte", "fogli"])

	var written: Array = []
	var index: Array = []
	for deck in CardFace.DECKS + CardFace.TILES:
		var faces: Array = CardFace.deck_of(str(deck), data)
		if faces.is_empty():
			continue
		var to_print: Array = faces if proof else PrintSheet.expand(faces)
		var shape: String = str((faces[0] as Dictionary)["shape"])
		var pages: Array = PrintSheet.paginate(to_print, shape)
		for number in range(pages.size()):
			var path: String = "%s/fogli/%s_%02d.svg" % [out_dir, str(deck), number + 1]
			var svg: String = PrintSheet.page_svg(
				pages[number], shape, str(LABELS.get(str(deck), str(deck))),
				number + 1, pages.size()
			)
			if not _write(path, svg):
				printerr("non riesco a scrivere %s" % path)
				quit(4)
				return
			written.append(path)
		print("  %-16s %6d %6d %7d" % [
			str(LABELS.get(str(deck), str(deck))), faces.size(), to_print.size(), pages.size()
		])
		index.append({"deck": str(deck), "faces": faces, "pages": pages.size(), "cards": to_print.size()})

	var bible: RefCounted = ArtBible.new()
	bible.read(str(options.get("bible", "docs/ART_BIBLE.md")))
	var brief_path: String = "%s/brief_arte.md" % out_dir
	_write(brief_path, bible.brief(data))
	_write("%s/README.md" % out_dir, _readme(index, proof, bible))

	print("")
	print("  %d fogli, piu' brief_arte.md e README.md" % written.size())
	var missing: Array = bible.keys_without_prompt(data)
	if not missing.is_empty():
		# Non e' un errore dell'export: e' un buco nella ART_BIBLE, e questo e' il
		# primo strumento che passa in rassegna ogni chiave e puo' accorgersene.
		print("")
		print("  ATTENZIONE: %d chiavi d'arte non hanno un MASTER PROMPT (%s)" % [
			missing.size(), ", ".join(PackedStringArray(missing.slice(0, 3)))
		])
	quit(0)


func _readme(index: Array, proof: bool, bible: RefCounted) -> String:
	var lines: Array = [
		"# ECHOES — export di stampa",
		"",
		"Generato da `cli/run_export.gd` dai JSON di `godot/data`. Non si modifica a",
		"mano: si rigenera. Ogni foglio e' A4 in **scala 1:1** — si stampa al 100%,",
		"senza «adatta alla pagina», altrimenti i segni di taglio mentono.",
		"",
		"Carte 63x88 mm, tre per tre. Tessere Regione 80x80 mm, due per tre.",
		"",
		"| mazzo | facce | carte | fogli |",
		"|---|---|---|---|",
	]
	for entry in index:
		lines.append("| %s | %d | %d | %d |" % [
			str(LABELS.get(str((entry as Dictionary)["deck"]), "")),
			((entry as Dictionary)["faces"] as Array).size(),
			int((entry as Dictionary)["cards"]), int((entry as Dictionary)["pages"]),
		])
	lines.append("")
	if proof:
		lines.append("Export **proof**: una copia per faccia, per correggere. Il mazzo vero si")
		lines.append("genera senza `--proof`.")
	else:
		lines.append("Le copie sono quelle del mazzo (`deck_copies`): una carta comune esce")
		lines.append("quattro volte, una rara una sola.")
	lines.append("")
	lines.append("Le carte Destino sono segrete: si stampano e si consegnano coperte.")
	lines.append("")
	lines.append("L'arte e' **segnaposto**: ogni immagine mostra in chiaro la propria")
	lines.append("`art_prompt_key` e lascia libero il terzo basso, che e' dove andra' il")
	lines.append("testo quando l'illustrazione vera arrivera'. I prompt da mandare a chi")
	lines.append("disegna sono in `brief_arte.md`%s." % (
		"" if bible.available() else " (ART_BIBLE non trovata: rimandi soltanto)"
	))
	return "\n".join(PackedStringArray(lines)) + "\n"


func _make_dir(path: String) -> bool:
	return DirAccess.make_dir_recursive_absolute(path) == OK


func _write(path: String, text: String) -> bool:
	var handle: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if handle == null:
		return false
	handle.store_string(text)
	handle.close()
	return true


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		text = text.substr(2)
		var split: int = text.find("=")
		if split < 0:
			options[text] = true
		else:
			options[text.substr(0, split)] = text.substr(split + 1)
	return options
