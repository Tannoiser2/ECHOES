extends RefCounted
## **Un mucchio di carte diventa un menu, e le copie sono copie.**
##
## In scatola una carta ha piu' di una copia — `deck_copies`: 24 carte in
## quattro copie, 12 in due, 12 in una, **132 in tutto su 48 carte diverse** —
## quindi una mano con due «Giuramento» e' normale. E al tavolo quelle sono
## **due carte**: si posano tutt'e due.
##
## I menu invece contavano i **nomi**, e sbagliavano due volte:
##
## 1. **stampavano la stessa riga due volte.** Due «Giuramento — bonds, forza 1»
##    in fila non sono due scelte: sono una scelta che lo schermo non sa
##    distinguere (misurato: 116 menu su 1034, e 154 gruppi in cui non le
##    distingueva **niente**);
## 2. **e scelta la prima, la seconda copia spariva.** Il ciclo saltava l'id
##    gia' scelto, quindi la seconda copia non si poteva ne' coprire ne'
##    scartare ne' impegnare — mentre il Consiglio, che le carte le conta come
##    **multinsieme** da sempre (`ConfluenceController.commit`), l'avrebbe
##    accettata. La regola c'era; il menu la contraddiceva.
##
## Da qui la regola sta in un posto solo, perche' la fanno in sei: coprire,
## scartare, impegnare, riprendersi una carta dopo una sconfitta, e i due filtri
## con cui il motore controlla le risposte. Sei copie della stessa regola
## divergono in silenzio: e' la lezione 9 di casa.


## **Il mucchio meno quello che si e' gia' scelto**, contato come multinsieme:
## scegliere una copia di «Giuramento» non fa sparire l'altra.
static func left_after(pile: Array, chosen: Array) -> Array:
	var out: Array = []
	for asset_id in pile:
		out.append(str(asset_id))
	for asset_id in chosen:
		var index: int = out.find(str(asset_id))
		if index >= 0:
			out.remove_at(index)
	return out


## **Le voci del menu**: una per carta distinta, nell'ordine in cui la carta sta
## nel mucchio — quindi l'ordine che il mucchio ha scelto (la forza, la famiglia
## che serve) resta quello — con quante copie se ne hanno in mano.
static func folded(pile: Array) -> Array:
	var out: Array = []
	var where: Dictionary = {}
	for asset_id in pile:
		var id: String = str(asset_id)
		if where.has(id):
			var seen: Dictionary = out[int(where[id])] as Dictionary
			seen["copies"] = int(seen["copies"]) + 1
			continue
		where[id] = out.size()
		out.append({"asset": id, "copies": 1})
	return out


## Come si dice, in una voce, che ne hai piu' di una. **Vuoto per una sola**: un
## «(ne hai 1)» su ogni riga sarebbe rumore su ogni riga, e il rumore su ogni
## riga e' rumore che non si legge piu'.
static func copies_note(copies: int) -> String:
	return "" if copies <= 1 else "  (ne hai %d)" % copies


## Quante copie di questa carta ci sono nel mucchio.
static func copies_in(pile: Array, asset_id: String) -> int:
	var count: int = 0
	for other in pile:
		if str(other) == str(asset_id):
			count += 1
	return count


## **Il filtro con cui il motore controlla una risposta**: tiene le carte che
## nel mucchio ci sono davvero, **una per copia**, e non piu' di `most`. Un
## decisore che risponde con una carta che non ha, o con la stessa copia due
## volte, farebbe fallire l'Effetto in silenzio — e il motore non si fida di una
## risposta: la conta.
static func kept(asked: Array, pile: Array, most: int) -> Array:
	var out: Array = []
	var left: Array = []
	for asset_id in pile:
		left.append(str(asset_id))
	for asset_id in asked:
		if out.size() >= most:
			break
		var index: int = left.find(str(asset_id))
		if index < 0:
			continue
		left.remove_at(index)
		out.append(str(asset_id))
	return out
