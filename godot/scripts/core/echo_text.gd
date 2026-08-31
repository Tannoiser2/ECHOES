extends RefCounted
## Cosa fa l'Eco di una carta, in due righe, prima di calarlo.
##
## Le carte Asset lo dicono da 0.1.x: accanto a ogni opzione di impegno c'e'
## quanto vale qui e cosa costa al mondo (`asset_text.gd`, D-042). Le carte del
## Narratore no: si sceglievano dal solo titolo — «Cala la carta del Narratore:
## Mancanza» — e il titolo e' bellissimo e non dice niente. Il committente lo ha
## detto giocando: «le frasi sono belle ma non si capiscono e alla fine non
## hanno effetti sul gioco». Gli effetti c'erano; era la carta a essere muta.
##
## Come per gli Asset, il riassunto si costruisce **dai campi che il motore
## legge davvero**, cosi' una carta non puo' dire una cosa e farne un'altra.

const EffectText := preload("res://scripts/core/effect_text.gd")

## Le famiglie drammatiche, in una parola che dica al tavolo che tono ha la
## carta senza spiegare la teoria di Propp.
const FAMILIES: Dictionary = {
	"PRESSURE": "stringe",
	"RUPTURE": "rompe",
	"TURN": "svolta",
	"RESOLUTION": "chiude",
}


## Le righe di cosa succede se la cali adesso: un Effect per riga, piu'
## l'eventuale Consiglio che la carta apre. `data` serve a nominare Regioni,
## Tensioni e case invece dei loro identificativi.
static func effect_lines(card: Dictionary, data: RefCounted) -> Array:
	var out: Array = []
	for hook in card.get("effect_hooks", []):
		var entry: Dictionary = hook as Dictionary
		if str(entry.get("kind", "")) == "CONSEQUENCE":
			var consequence: Variant = data.consequences.get(str(entry.get("consequence_id", "")))
			out.append(
				"scrive «%s»" % str(consequence["title"]) if consequence != null
				else "scrive una Conseguenza"
			)
			continue
		var spec: Dictionary = entry.get("effect", {}) as Dictionary
		# **La questione d'autore, detta per nome** (D-359). Il bersaglio e'
		# `$tension`, che al tavolo risolve alla questione dichiarata se e'
		# aperta e altrimenti a quella che c'e': un identificativo, qui, non si
		# puo' stampare. Ma la carta sa di cosa parla — sta in
		# `bindings.focus_tension` — e dirlo per nome, con la riserva, e' piu'
		# onesto che dire «una Tensione».
		var focus: String = str((entry.get("bindings", {}) as Dictionary).get("focus_tension", ""))
		var said: String = ""
		if focus != "" and str((spec.get("target", {}) as Dictionary).get("id", "")) == "$tension":
			var named: Dictionary = spec.duplicate(true)
			(named["target"] as Dictionary)["id"] = focus
			said = EffectText.say(named, data)
			if said != "":
				said += ", o la domanda che il tavolo ha aperto"
		else:
			said = EffectText.say(spec, data)
		if said != "" and not out.has(said):
			out.append(said)
	var forced: Variant = card.get("forces_confluence_on", null)
	if forced != null and str(forced) != "":
		var tension: Variant = data.tensions.get(str(forced))
		out.append(
			"apre subito un Consiglio su %s" % str(tension["title"]) if tension != null
			else "apre subito un Consiglio"
		)
	return out


## Il riassunto meccanico su una riga, per stare accanto a un'opzione.
static func note(card: Dictionary, data: RefCounted) -> String:
	var lines: Array = effect_lines(card, data)
	if lines.is_empty():
		return "non cambia niente da sola"
	return " · ".join(PackedStringArray(lines))


## L'etichetta intera di una scelta: il titolo, che tono ha, e cosa fa.
static func label(card: Dictionary, data: RefCounted) -> String:
	var family: String = str(card.get("dramatic_family", ""))
	var tone: String = str(FAMILIES.get(family, family.to_lower()))
	return "Cala l'Eco di questa carta: %s — %s\n%s" % [
		str(card["title"]), tone, note(card, data),
	]


## Tutto quello che la carta direbbe se avesse spazio: titolo, tono, effetti, e
## la frase che le ha scritto il suo autore.
static func tooltip(card: Dictionary, data: RefCounted) -> String:
	var lines: Array = [label(card, data)]
	var description: String = str(card.get("description", ""))
	if description != "":
		lines.append("")
		lines.append(description)
	return "\n".join(PackedStringArray(lines))
