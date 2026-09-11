extends RefCounted
## **Il potere di una casa** — la domanda scritta una volta sola.
##
## Il tarocco della Casata stampa `SA FARE  acquisire 3 · muovere 2 ·
## influenzare 4 · forgiare 2 · tramare 1 · rivendicare 4`, e resta in vista
## tutta la partita. Fino a [D-503](../../../docs/DECISIONS.md#d-503) quei
## numeri li leggevano **tre posti, e nessuno era una regola**: la faccia che li
## stampa, la scheda che la documenta, e l'eredita' alla successione.
## Quarantotto numeri su otto carte che non facevano niente — parola del
## committente in [ISSUES 136](../../../docs/ISSUES.md#136): *«anche il potere
## di una entita' mi deve permettere di fare qualcosa»*.
##
## Adesso il numero **piu' alto** dice qual e' il potere della casa: quel verbo
## si gioca **senza carta**, un tot di volte per Atto. A parita' di numero i
## verbi migliori sono piu' d'uno, e sceglie chi gioca.
##
## La domanda sta qui, pura, perche' la fanno in **quattro**: il motore per
## rifiutare a voce alta, il menu di una persona per offrire la voce, il cervello
## per dirla quando la mano non porta quel verbo, e la faccia della carta per
## stamparla. Scritta quattro volte diverge in silenzio, ed e' la lezione 9 di
## casa.
##
## Al tavolo e' una cosa sola: **guarda il numero piu' alto sul tuo tarocco.**
## Quel verbo lo dici senza carta, una volta per Atto; poi ruoti la carta, e la
## rimetti diritta quando l'Atto dopo si apre.


## Quante volte per Atto, letto dalla Chronicle. Zero — e il potere non esiste —
## dove `house_power` non e' dichiarato.
static func per_act(chronicle: Dictionary) -> int:
	return int((chronicle.get("house_power", {}) as Dictionary).get("per_act", 0))


## I verbi che questa casa sa fare meglio, in ordine, fra quelli che il potere
## puo' aprire. La lista dei verbi ammessi la passa chi chiama — sono le Azioni
## che una carta potrebbe portare — cosi' questa regola non tiene una seconda
## copia di quell'elenco.
static func best_verbs(definition: Dictionary, allowed: Array) -> Array:
	var values: Dictionary = definition.get("action_values", {}) as Dictionary
	var best: int = 0
	for verb in values:
		if allowed.has(str(verb)):
			best = maxi(best, int(values[verb]))
	if best <= 0:
		return []
	var out: Array = []
	for verb in values:
		if allowed.has(str(verb)) and int(values[verb]) == best:
			out.append(str(verb))
	out.sort()
	return out
