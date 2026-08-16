extends RefCounted
## Portarsi via la cronaca (D-062).
##
## Il log e' gia' tutto sullo schermo, nella colonna di sinistra, e finche' si
## gioca al computer basta selezionarlo. Su un tablet no: una partita finita si
## puo' solo fotografare, ed e' cosi' che e' arrivata l'ultima segnalazione -
## uno screenshot di un registro delle Truth.
##
## Quello che serve e' un file. Due strade, perche' i due posti in cui questo
## gioco gira non si somigliano:
##
##   - **nel browser** il file va consegnato a chi guarda, e l'unico modo e'
##     `JavaScriptBridge.download_buffer` - la stessa cosa che fa un link di
##     download, fatta dal motore;
##   - **altrove** si scrive in `user://`, e chi ha premuto deve sapere dove,
##     altrimenti ha salvato qualcosa che non sa ritrovare.
##
## In tutt'e due i casi la funzione torna una riga da mostrare a chi ha premuto.
## Una cosa che accade in silenzio non e' distinguibile da una che non accade.

## L'intestazione: senza il seme un log non si puo' rigiocare, e un log che non
## si puo' rigiocare e' un racconto, non una prova.
static func header(chronicle_title: String, year: int, seed_value: int, stamp: String) -> String:
	var lines: Array = ["# ECHOES — cronaca della sessione"]
	if chronicle_title != "":
		lines.append("# %s, anno %d" % [chronicle_title, year])
	if seed_value >= 0:
		lines.append("# seme %d" % seed_value)
	if stamp != "":
		lines.append("# %s" % stamp)
	lines.append("")
	return "\n".join(PackedStringArray(lines)) + "\n"


## Il nome del file. Solo lettere, numeri e trattini: passa per un filesystem,
## per una cartella Download e per un allegato senza che nessuno dei tre debba
## indovinare cosa fare con uno spazio.
static func file_name(chronicle_id: String, seed_value: int) -> String:
	var slug: String = chronicle_id.to_lower().replace("_", "-")
	if slug == "":
		slug = "sessione"
	if seed_value < 0:
		return "echoes-%s.txt" % slug
	return "echoes-%s-%d.txt" % [slug, seed_value]


## Scrive, e torna la riga da dire a chi ha premuto. Vuota solo se non c'e'
## niente da scrivere: un log vuoto non e' un errore, e' una sessione appena
## cominciata. Il MIME e' un parametro perche' per questa via passa anche il
## salvataggio (voce 12, D-092), che e' JSON e non testo.
static func deliver(
	text: String, name: String, mime: String = "text/plain;charset=utf-8"
) -> String:
	if text.strip_edges() == "":
		return ""
	var bytes: PackedByteArray = text.to_utf8_buffer()
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(bytes, name, mime)
		return "Scaricato: %s" % name
	var path: String = "user://%s" % name
	var handle: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if handle == null:
		return "Non sono riuscito a scrivere %s" % path
	handle.store_buffer(bytes)
	handle.close()
	return "Scritto in %s" % ProjectSettings.globalize_path(path)
