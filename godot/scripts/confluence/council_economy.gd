extends RefCounted
## L'economia del Consiglio (D-280), presa dalla carta del committente.
##
## > *«Non dovevano esserci dei benefici che il proponente poteva scegliere, e
## > dei costi che il proponente o gli altri giocatori dovevano scegliere?
## > Questi Benefici e Costi dovevano essere collegati alla mappa tramite i Tag
## > di Edifici, cicatrici e condizioni.»*
##
## E' il cuore, e ha tre pezzi:
##
## 1. **Un vocabolario chiuso di verbi**, non frasi d'autore. Gli stessi su
##    ogni carta — come le caselle di un tabellone. Quello che cambia da carta
##    a carta e' la Domanda, i segni che chiede sul tavolo, e i **parametri**:
##    quale condizione lascia, quale Pietra alza, quale Cicatrice incide.
## 2. **Un'economia**: *un beneficio e' gratis; ogni beneficio in piu' costa un
##    costo.* Massimo tre benefici, massimo due costi — e il tetto non si
##    sfonda: la Cicatrice e' un costo come gli altri (D-303).
## 3. **Due mani**: il proponente compra i benefici, **gli avversari scelgono in
##    che moneta paga** (parola del committente, scelta fra tre). Lui sa
##    *quanto* paga; non sa *in cosa*.
##
## I verbi stanno qui e non nei dati perche' ognuno **produce Effetti**: e'
## codice, e il codice si prova. La carta li nomina e li parametrizza; questo
## modulo li esegue.
##
## **Ogni casella risponde a tre domande** (D-366): *cosa fa* — il verbo —,
## *su chi* — il campo `chi` —, e *dove* — il campo `dove`. Fino alla 0.1.312
## esisteva solo la prima: ogni casella agiva sul posto di cui si stava
## discutendo e per conto di chi proponeva, e basta. Misurato: dei 46 Effetti
## distinti che un Consiglio applica, **25 avevano il verbo giusto e un posto
## che la casella non sapeva dire** — una Regione confinante, la capitale, la
## sede del rivale, una Regione col segno, una domanda chiamata per nome. Non
## era un muro: era un campo che mancava.

const Effect := preload("res://scripts/core/effect.gd")

## Quante pedine stanno sulla carta, se la carta non dice altro.
const MAX_BENEFITS: int = 3
const MAX_COSTS: int = 2

## **Quanti benefici sono gratis** (D-417, ISSUES 122 + 125, parola del
## committente: *«due acquisti liberi»*).
##
## Era **uno**, ed era la [D-280](../../../docs/DECISIONS.md#d-280) alla lettera.
## Misurato, con un solo acquisto libero il numero di caselle **vive** per
## Consiglio era **uno**: le altre ventitre' esistevano per quando la prima non
## si poteva comprare, e i benefici comprati per Consiglio erano scesi a 1,22.
## Un menu di ventiquattro voci di cui se ne sceglie una non e' un menu: e' una
## voce con ventitre' ripieghi.
const FREE_BENEFITS: int = 2

## Il tetto del Calore, per sapere se SCALDA TEMA ha ancora spazio (D-306).
## E' lo stesso numero di `EffectApplier.HEAT_MAX`, e la prova lo verifica.
const MAX_HEAT: int = 6

## **Dove** la pedina punta (D-366). Un vocabolario chiuso come quello dei
## verbi: sulla casella c'e' un'icona, e l'icona dice il posto. `needs` e' il
## parametro che il posto chiede alla carta — «una Regione col segno» senza il
## segno non e' un posto.
##
## Il posto si risolve **su quello che il Consiglio gia' calcola**
## (`ConfluenceController.effect_context`): `region_focus`, `adjacent`,
## `capital`, `rival_seat`, `tension`. Nessuna chiave nuova nel contesto, e
## nessuna seconda tabella che possa scostarsi dalla prima.
const PLACES: Dictionary = {
	"FOCUS": {"label": "dove si discute", "needs": [], "on": ["region", "tension", "world", "theme", "house", "relation", "road"]},
	"ADJACENT": {"label": "in una Regione confinante", "needs": [], "on": ["region", "road"]},
	"CAPITAL": {"label": "nella capitale", "needs": [], "on": ["region", "road"]},
	"RIVAL_SEAT": {"label": "nella sede del rivale", "needs": [], "on": ["region", "road"]},
	"REGION_WITH": {"label": "in una Regione col segno", "needs": ["place_tag"], "on": ["region", "road"]},
	"QUESTION": {"label": "sulla domanda chiamata per nome", "needs": ["question"], "on": ["tension"]},
}

## **Su chi** la casella parla. Il proponente e' il caso normale, ed e' il
## valore che una carta senza `chi` ha sempre avuto: nessuna carta di oggi
## cambia comportamento.
const HOUSES: Dictionary = {
	"PROPONENT": {"label": "chi propone", "needs": []},
	"RIVAL": {"label": "il rivale", "needs": []},
	"HOUSE_WITH": {"label": "la casa che porta il segno", "needs": ["who_tag"]},
	"NOBODY": {"label": "nessuno", "needs": []},
}

## Il vocabolario. `needs` dice quali parametri la voce deve portare sulla
## carta: una voce senza il suo parametro non e' giocabile, e il validatore la
## rifiuta prima che il tavolo se ne accorga. `on` dice **su che genere di cosa**
## la casella agisce, ed e' quello che decide quali `dove` accetta.
const BENEFIT_VERBS: Dictionary = {
	"REOPEN": {"label": "RIAPRI", "needs": [], "on": "region"},
	"CLEAR_CONDITION": {"label": "RIMUOVI CONDIZIONE", "needs": [], "on": "region"},
	"BUILD_STONE": {"label": "COSTRUISCI PIETRA", "needs": ["structure"], "on": "region"},
	"TAKE_CONTROL": {"label": "CAMBIA CONTROLLO", "needs": [], "on": "region"},
	"COOL_THEME": {"label": "RAFFREDDA TEMA", "needs": [], "on": "theme"},
	# **Il verbo che mancava** (D-308, ISSUES 76 strada a).
	#
	# «Le Azioni cambiano il mondo. Il Consiglio decide cosa il mondo
	# ricordera'» — e' la direzione scritta in testa al progetto, e il
	# vocabolario del beneficio non aveva il verbo che quella frase nomina.
	# Riaprire, ripulire, costruire, cambiare controllo, raffreddare: cinque
	# verbi che spostano cose, **nessuno che scriva un fatto**.
	#
	# Misurato: dei segni che le otto case dichiarano di voler lasciare nel
	# mondo, un Consiglio ne sapeva dare **sette** — e tutti e sette erano
	# Pietre. Tutto il resto — `succession_by_law`, `charter_written`,
	# `debt_forgiven`, `knowledge_shared` — e' una **memoria**, categoria
	# MEMORY e ambito GLOBAL, e solo una frase d'autore la sapeva scrivere.
	# Cioe': il Consiglio sapeva **infliggere** quello che le case temono e
	# non sapeva **dare** quello che vogliono.
	"REMEMBER": {"label": "IL MONDO RICORDA", "needs": ["tag"], "on": "world"},
	# **La casella che muove una domanda** (D-343, ISSUES 89).
	#
	# La misura di D-342: dei 27 Effetti che nessuna casella sapeva dire,
	# `ADJUST_TENSION` da solo vale **90 applicazioni su 336** — un quarto di
	# tutto quello che un Consiglio fa. Ed e' l'Effetto che il committente non
	# riusciva a leggere sulla scheda: *«La Carestia +1 non so cosa intende»*.
	#
	# **RAFFREDDA TEMA non e' questa casella.** Quella muove il Calore di un
	# **Tema** (`ADJUST_THEME_HEAT`); questa muove la traccia di una **domanda**
	# (`ADJUST_TENSION`). Sul tavolo sono due piste diverse, e fino a qui il
	# Consiglio sapeva muovere solo la prima.
	"COOL_QUESTION": {"label": "ABBASSA LA DOMANDA", "needs": [], "on": "tension"},
	# --- Le caselle scritte in D-366 -------------------------------------
	#
	# Le otto che la misura chiedeva, dalla piu' usata alla piu' rara. Non
	# sono invenzioni: ognuna e' il nome di quello che una Conseguenza
	# d'autore gia' faceva senza che il tavolo lo potesse posare con una
	# pedina.
	#
	# **POSA UN SEGNO SU UNA CASATA**, 44 applicazioni: e' la seconda cosa che
	# un Consiglio fa piu' spesso dopo scrivere una memoria, ed era invisibile.
	# Un titolo, una fama, una scoperta: cose che si portano addosso e che
	# viaggiano con la casa da una Regione all'altra.
	"MARK_HOUSE": {"label": "POSA UN SEGNO SU UNA CASATA", "needs": ["tag"], "on": "house"},
	"UNMARK_HOUSE": {"label": "TOGLI UN SEGNO A UNA CASATA", "needs": ["tag"], "on": "house"},
	# **MUOVI UN RAPPORTO**, 11: il filo fra due case. Il Consiglio e' il posto
	# dove i patti si stringono e si rompono, e non aveva la casella per dirlo.
	"BIND_HOUSES": {"label": "MUOVI UN RAPPORTO", "needs": ["level"], "on": "relation"},
	# **UNA PRESENZA ENTRA**, 10 insieme al suo rovescio: una pedina che arriva
	# senza che nessuno abbia fatto MUOVERE. E' quello che un Consiglio decide
	# quando manda o richiama qualcuno.
	"MOVE_IN": {"label": "UNA PRESENZA ENTRA", "needs": [], "on": "region"},
	"MOVE_OUT": {"label": "UNA PRESENZA SE NE VA", "needs": [], "on": "region"},
	# **UNA PIETRA SALE**, 9 col suo rovescio: la Pietra c'e' gia', e il
	# Consiglio decide se cresce. Diverso da COSTRUISCI PIETRA, che ne alza una
	# che non c'e'.
	"RAISE_STONE": {"label": "UNA PIETRA SALE", "needs": ["structure"], "on": "region"},
	# **IL MONDO DIMENTICA**, 3: il rovescio esatto di IL MONDO RICORDA, e
	# senza di lui una memoria posata non si poteva piu' togliere in Consiglio.
	"FORGET": {"label": "IL MONDO DIMENTICA", "needs": ["tag"], "on": "world"},
	# **UNA DOMANDA VELATA SI SCOPRE**, 2: il segnalino girato a faccia in su.
	"UNVEIL_QUESTION": {"label": "UNA DOMANDA VELATA SI SCOPRE", "needs": [], "on": "tension"},
}
const COST_VERBS: Dictionary = {
	"ADD_CONDITION": {"label": "AGGIUNGI CONDIZIONE", "needs": ["tag"], "on": "region"},
	"TOLL": {"label": "PEDAGGIO", "needs": [], "on": "region"},
	"YIELD_CONTROL": {"label": "CEDI CONTROLLO", "needs": [], "on": "region"},
	"HEAT_THEME": {"label": "SCALDA TEMA", "needs": [], "on": "theme"},
	"TAKE_DEBT": {"label": "PRENDI DEBITO", "needs": [], "on": "region"},
	"SCAR": {"label": "CICATRICE", "needs": ["tag"], "on": "region"},
	# Il rovescio di ABBASSA LA DOMANDA (D-343): 41 delle 90 applicazioni
	# **alzano** una domanda, ed erano il prezzo che una proposta faceva pagare
	# al mondo senza che nessuna casella lo sapesse dire.
	"HEAT_QUESTION": {"label": "ALZA LA DOMANDA", "needs": [], "on": "tension"},
	# --- E le stesse caselle, dall'altra parte del tavolo (D-366) ---------
	#
	# **Sei caselle stanno nelle due liste**, e non e' una svista: con `chi` e
	# `dove` la stessa casella cambia segno secondo dove punta la pedina. «Il
	# rivale perde la corona» e' un beneficio; «chi propone porta addosso il
	# tradimento» e' un prezzo — stesso verbo, casa diversa. Quello che decide
	# non e' il verbo, e' il bersaglio, ed e' esattamente quello che il tavolo
	# vede guardando dov'e' posata la pedina.
	"MARK_HOUSE": {"label": "POSA UN SEGNO SU UNA CASATA", "needs": ["tag"], "on": "house"},
	"UNMARK_HOUSE": {"label": "TOGLI UN SEGNO A UNA CASATA", "needs": ["tag"], "on": "house"},
	"BIND_HOUSES": {"label": "MUOVI UN RAPPORTO", "needs": ["level"], "on": "relation"},
	"MOVE_IN": {"label": "UNA PRESENZA ENTRA", "needs": [], "on": "region"},
	"MOVE_OUT": {"label": "UNA PRESENZA SE NE VA", "needs": [], "on": "region"},
	"FORGET": {"label": "IL MONDO DIMENTICA", "needs": ["tag"], "on": "world"},
	"UNVEIL_QUESTION": {"label": "UNA DOMANDA VELATA SI SCOPRE", "needs": [], "on": "tension"},
	# **UNA PIETRA SCENDE**: il rovescio di UNA PIETRA SALE, e sta solo qui —
	# una Pietra che scende non e' mai un beneficio per chi la possiede.
	"LOWER_STONE": {"label": "UNA PIETRA SCENDE", "needs": ["structure"], "on": "region"},
	# **CHIUDI LA STRADA**, 1: una frana, un blocco, un ponte tagliato. Il
	# motore rifiuta da solo la chiusura che isolerebbe una Regione, quindi la
	# casella non puo' spezzare la mappa.
	"SEAL_ROAD": {"label": "CHIUDI LA STRADA", "needs": [], "on": "road"},
	# **UNA CASATA LASCIA IL TAVOLO**, 1: la piu' rara e la piu' grossa.
	"LEAVE_TABLE": {"label": "UNA CASATA LASCIA IL TAVOLO", "needs": [], "on": "house"},
}

## Il segno che il pedaggio lascia sulla tessera, e quello del debito: due
## parole del dizionario, non due invenzioni di questo modulo.
const TOLL_TAG: String = "structure:tollgate"
const DEBT_TAG: String = "condition:indebted"
const CLOSED_TAG: String = "condition:cut_off"

## I livelli di un rapporto, nell'ordine in cui stanno sulla pista. E' la stessa
## lista che `EffectApplier._set_relation` accetta, e la prova lo verifica.
const RELATION_LEVELS: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]


## **Il prezzo di un carrello di benefici.** Uno e' gratis; ogni altro costa un
## costo. Il tetto e' tre, e non si sfonda: **la Cicatrice non compra niente**
## (D-303, parola del committente: *«io a questo punto toglierei la cicatrice,
## la lascerei come effetto malus o passivo»*). Resta uno dei sei costi, che e'
## quello che al tavolo era gia' — misurato, si posava 17 volte in 40 anni
## **come prezzo**, e mai come moneta d'acquisto: il quarto beneficio valeva
## uno e costava quattro (D-302), e nessun seggio sano lo comprava.
static func tokens_due(benefits: int) -> int:
	return maxi(0, benefits - FREE_BENEFITS)


## **Quanti benefici puo' comprare chi ha quei gettoni** (D-387, ISSUES 122).
##
## Il primo e' gratis; ogni altro vuole **un gettone di rivendicazione** —
## preso giocando una carta Asset dalla sua faccia RIVENDICARE. Il tetto resta
## tre, che sono le pedine che stanno sulla carta.
##
## **Perche' e' cambiata la moneta.** Fino a D-386 il secondo beneficio si
## pagava con un costo, e il costo lo sceglievano gli avversari: sembrava
## un'economia, ma il proponente non spendeva niente di suo — quindi prendeva
## sempre e solo **quello che valeva di piu'**, e le altre ventitre' caselle
## esistevano per quando la prima non si poteva comprare (ISSUES 122, misurato
## su cento saghe in quattro mosse consecutive). Adesso il secondo beneficio
## costa una cosa che il proponente **ha dovuto guadagnarsi un turno prima**, e
## il costo non e' piu' il suo prezzo: e' quello che gli avversari decidono di
## fargli pagare, spendendo a loro volta.
static func benefits_affordable(tokens: int) -> int:
	return mini(MAX_BENEFITS, FREE_BENEFITS + maxi(0, tokens))


# --- dove e su chi ---------------------------------------------------------

## La voce del vocabolario, da qualunque delle due liste venga.
static func entry(verb: String) -> Dictionary:
	if BENEFIT_VERBS.has(verb):
		return BENEFIT_VERBS[verb] as Dictionary
	if COST_VERBS.has(verb):
		return COST_VERBS[verb] as Dictionary
	return {}


## Su che genere di cosa agisce questa casella: e' quello che decide quali
## `dove` puo' portare.
static func acts_on(verb: String) -> String:
	return str(entry(verb).get("on", "region"))


## I `dove` che una casella accetta. Una casella che agisce su una casa o sul
## mondo ha un posto solo — *dove si discute* — perche' il suo bersaglio lo dice
## `chi`, non `dove`: due campi che dicono la stessa cosa sarebbero due modi di
## sbagliarla.
static func places_for(verb: String) -> Array:
	var on: String = acts_on(verb)
	var out: Array = []
	for place in PLACES:
		if ((PLACES[place] as Dictionary)["on"] as Array).has(on):
			out.append(str(place))
	return out


## **La Regione di cui parla questa casella.** Senza `dove` e' quella di cui si
## discute, che e' come il Consiglio ha sempre funzionato.
static func region_of(voice: Dictionary, context: Dictionary, world: Dictionary) -> String:
	match str(voice.get("dove", "FOCUS")):
		"ADJACENT":
			return str(context.get("adjacent", ""))
		"CAPITAL":
			return str(context.get("capital", ""))
		"RIVAL_SEAT":
			return str(context.get("rival_seat", ""))
		"REGION_WITH":
			return _region_with(world, str(voice.get("place_tag", "")), str(context.get("region_focus", "")))
	return str(context.get("region_focus", ""))


## L'altro capo della strada che CHIUDI LA STRADA taglia. Di suo e' il posto di
## cui si discute: la casella chiude **una** via che esce da qui.
static func other_region_of(voice: Dictionary, context: Dictionary, world: Dictionary) -> String:
	var second: Dictionary = {
		"dove": str(voice.get("verso", "FOCUS")),
		"place_tag": str(voice.get("verso_tag", "")),
	}
	return region_of(second, context, world)


## **La domanda di cui parla questa casella.** Senza `dove` e' quella in
## discussione; con `dove: QUESTION` e' quella che la carta chiama per nome —
## ma solo se e' al tavolo in questa Cronaca. Una domanda che non e' uscita non
## si muove, e la casella ricade su quella che c'e': e' la stessa regola con cui
## `$tension` si lega sulle carte Asset (D-362), e per la stessa ragione — una
## pedina posata su un segnalino che non esiste non e' una scelta, e' un buco.
static func question_of(voice: Dictionary, context: Dictionary, world: Dictionary) -> String:
	if str(voice.get("dove", "FOCUS")) == "QUESTION":
		var named: String = str(voice.get("question", ""))
		if named != "" and (world.get("tensions", {}) as Dictionary).has(named):
			return named
	return str(context.get("tension", ""))


## **La casa di cui parla questa casella.** Senza `chi` e' chi propone, che e'
## come il Consiglio ha sempre funzionato — e resta cosi' anche quando la voce
## e' rivendicata, perche' la rivendicazione riscrive `proponent` nel contesto e
## non la carta (D-304).
static func house_of(voice: Dictionary, context: Dictionary, world: Dictionary) -> String:
	match str(voice.get("chi", "PROPONENT")):
		"RIVAL":
			return str(context.get("rival", ""))
		"HOUSE_WITH":
			return _house_with(world, str(voice.get("who_tag", "")))
		"NOBODY":
			return ""
	return str(context.get("proponent", ""))


## Questo Tema e' quello col rombo piu' avanti? E' il Tema su cui si aprira' il
## prossimo Consiglio, e al tavolo si legge guardando la pista.
static func _is_hottest(world: Dictionary, theme_id: String) -> bool:
	if theme_id == "":
		return false
	var themes: Dictionary = world.get("theme_heat", {}) as Dictionary
	if not themes.has(theme_id):
		return false
	var mio: int = int(themes[theme_id])
	if mio <= 0:
		return false
	for altro in themes:
		if int(themes[altro]) > mio:
			return false
	return true


## Quanto e' alta una domanda adesso. Zero se il tavolo non ce l'ha in gioco.
static func _question_heat(world: Dictionary, tension_id: String) -> int:
	var tensions: Dictionary = world.get("tensions", {}) as Dictionary
	if tension_id == "" or not tensions.has(tension_id):
		return 0
	return int((tensions[tension_id] as Dictionary).get("current_value", 0))


## La prima Regione dell'ordine della Cronaca che porta il segno, preferendo una
## che non sia gia' quella di cui si discute — cosi' «una Regione col granaio»
## non e' un modo lungo di dire «qui». E' la stessa regola di
## `ConsequenceCompiler._resolve_region_with`, e per la stessa ragione: senza
## nessuna che lo porti, si ricade sul posto in discussione, perche' un Effetto
## con un buco e' peggio di uno puntato un po' storto.
static func _region_with(world: Dictionary, tag: String, avoid: String) -> String:
	if tag == "":
		return avoid
	var fallback: String = ""
	for region_id in (world.get("regions", {}) as Dictionary):
		var id: String = str(region_id)
		if not (((world["regions"] as Dictionary)[id] as Dictionary).get("tags", []) as Array).has(tag):
			continue
		if id != avoid:
			return id
		fallback = id
	return fallback if fallback != "" else avoid


## La prima casa seduta che porta il segno addosso. Nessuna lo porta: torna
## vuoto, e la casella non morde — il mondo non parla di chi non siede (D-213).
static func _house_with(world: Dictionary, tag: String) -> String:
	if tag == "":
		return ""
	for entity_id in (world.get("turn_order", []) as Array):
		var house: Variant = (world.get("entities", {}) as Dictionary).get(str(entity_id))
		if house == null:
			continue
		if ((house as Dictionary).get("tags", []) as Array).has(tag):
			return str(entity_id)
	return ""


## **Questa casella puo' fare qualcosa, qui e adesso?** (D-306)
##
## Misurato su 40 anni: **il 44% dei benefici comprati non lasciava niente** —
## 52 volte «Riapri l'accesso» su un luogo che non era chiuso, 24 volte «Cambia
## controllo» verso chi il luogo lo teneva gia', 23 volte una Pietra che stava
## gia' li' ed era gia' sua. E 21 costi su 92 non mordevano. Il proponente
## pagava un prezzo per una casella morta, o gli avversari gli imponevano un
## prezzo che non era un prezzo.
##
## Al tavolo non succede: **nessuno posa una pedina su «Riapri l'accesso» se il
## luogo non e' chiuso**. Si guarda la mappa e si vede. Questa funzione e' quel
## colpo d'occhio, e il menu si costruisce con lei — la stessa regola che il
## validatore gia' impone alle carte, dove una scelta finta e' un difetto.
static func voice_bites(
	voice: Dictionary, verb_kind: String, context: Dictionary,
	world: Dictionary, theme_id: String, data = null
) -> bool:
	var verb: String = str(voice.get("verb", ""))
	var region: String = region_of(voice, context, world)
	var proponent: String = str(context.get("proponent", ""))
	var house: String = house_of(voice, context, world)
	match verb:
		"REOPEN":
			return _region_has(world, region, CLOSED_TAG)
		"CLEAR_CONDITION":
			var named: String = str(voice.get("tag", ""))
			if named != "":
				return _region_has(world, region, named)
			return _a_condition_on(world, region) != ""
		"BUILD_STONE":
			# O si alza, o passa di mano (D-305). Morde a meno che non stia gia'
			# li' **e** non ci sia niente da passare: o perche' e' gia' sua, o
			# perche' quel tipo di Pietra **non ha un padrone** — una strada, un
			# ponte. Su quelle SET_STRUCTURE_OWNER non fa niente, e offrirle
			# sarebbe una scelta finta (D-307: misurato, 20 acquisti a vuoto su
			# 26 erano questo).
			var stone: String = str(voice.get("structure", ""))
			if region == "" or stone == "":
				return false
			if not _stone_stands(world, region, stone):
				return true
			if data != null and not _stone_is_owned(data, stone):
				return false
			return _stone_owner(world, region, stone) != house
		"TAKE_CONTROL":
			return region != "" and house != "" and _control_of(world, region) != house
		"COOL_THEME":
			return _heat_of(world, theme_id) > 0
		# Una domanda gia' a zero non si abbassa, e una gia' al limite non si
		# alza: al tavolo il segnalino e' in fondo alla traccia e si vede.
		"COOL_QUESTION":
			return _question_value(world, question_of(voice, context, world)) > 0
		"HEAT_QUESTION":
			# E una domanda gia' in cima alla sua traccia non si alza: e' la
			# stessa regola di SCALDA TEMA, che si ferma al tetto del Calore.
			# La cima e' la soglia stampata sulla carta, cioe' l'ultima tacca
			# della traccia dei valori (D-097).
			var asked: String = question_of(voice, context, world)
			var now: int = _question_value(world, asked)
			if now < 0:
				return false
			return now < _question_top(asked, data)
		"REMEMBER":
			# Un fatto che il mondo ricorda gia' non si ricorda due volte.
			var fact: String = str(voice.get("tag", ""))
			return fact != "" and not ((world.get("global_tags", []) as Array).has(fact))
		"FORGET":
			# E uno che il mondo non ricorda non si dimentica.
			var forgotten: String = str(voice.get("tag", ""))
			return forgotten != "" and (world.get("global_tags", []) as Array).has(forgotten)
		"MARK_HOUSE":
			var mark: String = str(voice.get("tag", ""))
			return house != "" and mark != "" and not _house_has(world, house, mark)
		"UNMARK_HOUSE":
			var worn: String = str(voice.get("tag", ""))
			return house != "" and worn != "" and _house_has(world, house, worn)
		"BIND_HOUSES":
			# Un rapporto con se stessi non esiste, e uno gia' al livello
			# chiesto non si muove: sono i due no-op che il motore fa in
			# silenzio, e offrirli sarebbe una scelta finta.
			var level: String = str(voice.get("level", ""))
			if proponent == "" or house == "" or proponent == house or level == "":
				return false
			return _relation_level(world, proponent, house) != level
		"MOVE_IN":
			# Entra chi non c'e' gia', e solo se ha ancora una pedina in mano:
			# il tetto delle presenze e' lo stesso che l'azione MUOVERE
			# rispetta (D-223), e una pedina che non c'e' non si posa.
			if house == "" or region == "":
				return false
			if _stands_in(world, house, region):
				return false
			return _tokens_left(world, house, data) > 0
		"MOVE_OUT":
			return house != "" and region != "" and _stands_in(world, house, region)
		"RAISE_STONE", "LOWER_STONE":
			var raised: String = str(voice.get("structure", ""))
			if region == "" or raised == "":
				return false
			var grade: int = _stone_grade(world, region, raised)
			if grade < 0:
				return false
			if verb == "LOWER_STONE":
				return grade > 1
			return grade < _stone_grades(data, raised)
		"UNVEIL_QUESTION":
			# Una domanda gia' scoperta non si scopre, e una che non e' uscita
			# in questa Cronaca non e' sul tavolo da girare.
			var veiled: Variant = (world.get("tensions", {}) as Dictionary).get(
				question_of(voice, context, world)
			)
			if veiled == null:
				return false
			return str((veiled as Dictionary).get("visibility", "OPEN")) != "OPEN"
		"SEAL_ROAD":
			# Si chiude una strada che c'e'. Se chiuderla isolerebbe una
			# Regione il motore la riapre da solo, ma quella e' l'ultima rete:
			# la casella non si offre nemmeno se la strada non esiste.
			var there: String = other_region_of(voice, context, world)
			if region == "" or there == "" or region == there:
				return false
			return ((world.get("adjacency", {}) as Dictionary).get(region, []) as Array).has(there)
		"LEAVE_TABLE":
			if house == "":
				return false
			var leaving: Variant = (world.get("entities", {}) as Dictionary).get(house)
			return leaving != null and bool((leaving as Dictionary).get("active", true))
		"ADD_CONDITION":
			return not _region_has(world, region, str(voice.get("tag", "")))
		"TOLL":
			return not _region_has(world, region, TOLL_TAG)
		"YIELD_CONTROL":
			# Cedere morde se c'e' qualcosa da cedere, e se non lo si sta
			# cedendo a chi lo tiene gia'. Di suo si cede al rivale: e' la casa
			# che la vecchia versione nominava direttamente.
			if region == "":
				return false
			var to_whom: String = _yield_target(voice, context, world)
			return _control_of(world, region) != to_whom
		"HEAT_THEME":
			return theme_id != "" and _heat_of(world, theme_id) < MAX_HEAT
		"TAKE_DEBT":
			return not _region_has(world, region, DEBT_TAG)
		"SCAR":
			return region != ""
	return false


## A chi va quello che si cede. Di suo il rivale della questione — e se non c'e'
## rivale, la terra: un posto che nessuno tiene e' un fatto del tavolo.
static func _yield_target(voice: Dictionary, context: Dictionary, world: Dictionary) -> String:
	if voice.has("chi"):
		return house_of(voice, context, world)
	return str(context.get("rival", ""))


## Il Calore di un Tema, o -1 se il Tema non c'e'.
static func _heat_of(world: Dictionary, theme_id: String) -> int:
	if theme_id == "":
		return -1
	var themes: Dictionary = world.get("theme_heat", {}) as Dictionary
	if not themes.has(theme_id):
		return -1
	return int(themes[theme_id])


## Chi tiene questo luogo, o "" se non lo tiene nessuno.
##
## `control` vale **null** quando il luogo e' di nessuno, e `str(null)` in
## GDScript non e' la stringa vuota: e' `"<null>"`. Passarci sopra farebbe
## mordere CEDI CONTROLLO su un luogo che non c'e' niente da cedere.
static func _control_of(world: Dictionary, region_id: String) -> String:
	var region: Variant = (world.get("regions", {}) as Dictionary).get(region_id)
	if region == null:
		return ""
	var held: Variant = (region as Dictionary).get("control", null)
	return "" if held == null else str(held)


static func _region_has(world: Dictionary, region_id: String, tag: String) -> bool:
	if region_id == "" or tag == "":
		return false
	var region: Variant = (world.get("regions", {}) as Dictionary).get(region_id)
	if region == null:
		return false
	return ((region as Dictionary).get("tags", []) as Array).has(tag)


## Questa casa porta questo segno addosso?
static func _house_has(world: Dictionary, entity_id: String, tag: String) -> bool:
	var house: Variant = (world.get("entities", {}) as Dictionary).get(entity_id)
	if house == null:
		return false
	return ((house as Dictionary).get("tags", []) as Array).has(tag)


## Questa casa ha una pedina in questa Regione?
static func _stands_in(world: Dictionary, entity_id: String, region_id: String) -> bool:
	var house: Variant = (world.get("entities", {}) as Dictionary).get(entity_id)
	if house == null:
		return false
	return ((house as Dictionary).get("presence", []) as Array).has(region_id)


## Quante pedine di presenza le restano in mano. Senza il set dei dati non c'e'
## tetto dichiarato, e allora se ne suppone una: e' il caso delle prove che
## costruiscono un mondo a mano, e la casella deve poterle servire.
static func _tokens_left(world: Dictionary, entity_id: String, data) -> int:
	var house: Variant = (world.get("entities", {}) as Dictionary).get(entity_id)
	if house == null:
		return 0
	var posate: int = ((house as Dictionary).get("presence", []) as Array).size()
	if data == null:
		return 1
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return 1
	var cap: int = int((chronicle as Dictionary).get("presence_tokens", 0))
	return 1 if cap <= 0 else cap - posate


## Il rapporto fra due case, o "" se non esiste. La chiave e' la stessa che il
## motore usa, e le due direzioni sono lo stesso filo.
static func _relation_level(world: Dictionary, one: String, other: String) -> String:
	var relations: Dictionary = world.get("relations", {}) as Dictionary
	for key in ["%s|%s" % [one, other], "%s|%s" % [other, one]]:
		if relations.has(key):
			return str((relations[key] as Dictionary).get("level", ""))
	return ""


## La chiave con cui il mondo tiene il rapporto fra due case, nel verso in cui
## e' scritta. Vuota se quel filo non c'e'.
static func _relation_key(world: Dictionary, one: String, other: String) -> String:
	var relations: Dictionary = world.get("relations", {}) as Dictionary
	for key in ["%s|%s" % [one, other], "%s|%s" % [other, one]]:
		if relations.has(key):
			return key
	return ""


## Di chi e' la Pietra di questo tipo, o "" se non c'e' o non e' di nessuno.
##
## `owner` vale **null** su una Pietra senza padrone, e `str(null)` in GDScript
## e' `"<null>"`, non la stringa vuota: e' la stessa trappola di `_control_of`,
## e qui faceva sembrare comprabile una Pietra che non aveva niente da passare.
static func _stone_owner(world: Dictionary, region_id: String, type_id: String) -> String:
	var region: Variant = (world.get("regions", {}) as Dictionary).get(region_id)
	if region == null:
		return ""
	for structure in ((region as Dictionary).get("structures", []) as Array):
		if str((structure as Dictionary).get("structure_type", "")) == type_id:
			var owner: Variant = (structure as Dictionary).get("owner", null)
			return "" if owner == null else str(owner)
	return ""


## Questo tipo di Pietra ha un padrone? Una strada e un ponte non ce l'hanno, e
## intestarli a qualcuno non vuol dire niente.
static func _stone_is_owned(data, type_id: String) -> bool:
	var definition: Variant = data.structure_types.get(type_id)
	if definition == null:
		return false
	return bool((definition as Dictionary).get("owned", false))


## C'e' gia' una Pietra di questo tipo, in questo luogo?
static func _stone_stands(world: Dictionary, region_id: String, type_id: String) -> bool:
	var region: Variant = (world.get("regions", {}) as Dictionary).get(region_id)
	if region == null or type_id == "":
		return false
	for structure in ((region as Dictionary).get("structures", []) as Array):
		if str((structure as Dictionary).get("structure_type", "")) == type_id:
			return true
	return false


## A che grado sta la Pietra di questo tipo, o -1 se non c'e'.
static func _stone_grade(world: Dictionary, region_id: String, type_id: String) -> int:
	var region: Variant = (world.get("regions", {}) as Dictionary).get(region_id)
	if region == null or type_id == "":
		return -1
	for structure in ((region as Dictionary).get("structures", []) as Array):
		if str((structure as Dictionary).get("structure_type", "")) == type_id:
			return int((structure as Dictionary).get("grade", 1))
	return -1


## Quanti gradi ha questo tipo di Pietra. Senza il set dei dati non si sa, e
## allora si suppone che ce ne sia ancora uno sopra: meglio offrire una casella
## che non si sarebbe potuta offrire che tacere su una che si puo'. E' la stessa
## scelta di `_question_top`.
static func _stone_grades(data, type_id: String) -> int:
	if data == null or type_id == "":
		return 99
	var definition: Variant = data.structure_types.get(type_id)
	if definition == null:
		return 99
	return ((definition as Dictionary).get("grades", []) as Array).size()


## Gli Effetti di una voce.
##
## `context` e' quello che il Consiglio gia' calcola (`effect_context`):
## `region_focus`, `proponent`, `rival`, `tension`, `adjacent`, `capital`,
## `rival_seat`. `world` serve alle voci che devono **guardare il tavolo** prima
## di parlare — togliere una condizione vuol dire togliere *quella che c'e'*, e
## risolvere `dove: REGION_WITH` vuol dire trovare la tessera che porta il segno.
static func effects_for(
	voice: Dictionary, verb_kind: String, context: Dictionary,
	world: Dictionary, theme_id: String, source: Dictionary
) -> Array:
	var verb: String = str(voice.get("verb", ""))
	var region: String = region_of(voice, context, world)
	var house: String = house_of(voice, context, world)
	var out: Array = []
	match verb:
		"REOPEN":
			if region == "":
				return out
			out.append(Effect.make(
				"REMOVE_REGION_TAG", "region", region,
				{"tag": CLOSED_TAG, "optional": true}, source
			))
		"CLEAR_CONDITION":
			var named: String = str(voice.get("tag", ""))
			var found: String = named if named != "" else _a_condition_on(world, region)
			if region == "" or found == "":
				return out
			out.append(Effect.make(
				"REMOVE_REGION_TAG", "region", region,
				{"tag": found, "optional": true}, source
			))
		"BUILD_STONE":
			if region == "":
				return out
			var stone: String = str(voice.get("structure", ""))
			# **Al tavolo c'e' un Granaio solo** (D-305). Se la Pietra sta gia'
			# li' — perche' l'ha alzata la frase d'autore in questo stesso
			# Consiglio, o perche' c'era da prima — un secondo BUILD sarebbe un
			# no-op silenzioso, e il beneficio comprato e pagato non lascerebbe
			# niente. Quello che il Consiglio ha comprato e' *quella* Pietra:
			# passa a chi l'ha comprata.
			if _stone_stands(world, region, stone):
				out.append(Effect.make(
					"SET_STRUCTURE_OWNER", "region", region,
					{"structure_type": stone, "entity_id": house}, source
				))
				return out
			out.append(Effect.make(
				"BUILD_STRUCTURE", "region", region,
				{"structure_type": stone, "grade": 1, "owner": house}, source
			))
		"TAKE_CONTROL":
			if region == "":
				return out
			out.append(Effect.make(
				"SET_CONTROL", "region", region, {"entity_id": house}, source
			))
		"COOL_THEME":
			if theme_id == "":
				return out
			out.append(Effect.make("ADJUST_THEME_HEAT", "theme", theme_id, {"delta": -1}, source))
		"COOL_QUESTION", "HEAT_QUESTION":
			# **Quale domanda.** Di suo quella di cui si sta discutendo, che e'
			# il segnalino che tutti hanno davanti; con `dove: QUESTION` quella
			# che la carta chiama per nome (D-366). Il committente ne ha decisa
			# una terza — *«la sceglie chi propone»* — e quella chiede che la
			# pedina posata porti con se' il nome della domanda: e' ISSUES 106,
			# perche' tocca l'API con cui si comprano i benefici, i due cervelli
			# e il tabellone.
			var asked: String = question_of(voice, context, world)
			if asked == "":
				return out
			out.append(Effect.make(
				"ADJUST_TENSION", "tension", asked,
				{"delta": -1 if verb == "COOL_QUESTION" else 1}, source
			))
		"UNVEIL_QUESTION":
			var veiled: String = question_of(voice, context, world)
			if veiled == "":
				return out
			out.append(Effect.make(
				"SET_TENSION_VISIBILITY", "tension", veiled, {"visibility": "OPEN"}, source
			))
		"REMEMBER", "FORGET":
			# La memoria si posa sul **mondo**, non sul luogo: e' un fatto che
			# dura, e il dizionario lo dichiara di ambito GLOBAL. Il validatore
			# rifiuta una voce RICORDA che nomini un segno di altro ambito.
			var fact: String = str(voice.get("tag", ""))
			if fact == "":
				return out
			out.append(Effect.make(
				"SET_GLOBAL_TAG" if verb == "REMEMBER" else "REMOVE_GLOBAL_TAG",
				"world", "WORLD", {"tag": fact}, source
			))
		"MARK_HOUSE", "UNMARK_HOUSE":
			# **Il segno addosso a una casa**, non alla tessera (D-366): viaggia
			# con lei, e resta anche quando la Regione cambia padrone.
			var mark: String = str(voice.get("tag", ""))
			if house == "" or mark == "":
				return out
			out.append(Effect.make(
				"SET_ENTITY_TAG" if verb == "MARK_HOUSE" else "REMOVE_ENTITY_TAG",
				"entity", house, {"tag": mark}, source
			))
		"BIND_HOUSES":
			# Il filo fra chi propone e la casa nominata. La chiave e' quella
			# con cui il mondo lo tiene: cercarla nei due versi e' necessario,
			# perche' `relations` ne scrive uno solo e un bersaglio inventato
			# fallirebbe dentro l'applicatore, dove nessuno lo vede.
			var key: String = _relation_key(world, str(context.get("proponent", "")), house)
			if key == "" or str(voice.get("level", "")) == "":
				return out
			out.append(Effect.make(
				"SET_RELATION", "relation", key, {"level": str(voice["level"])}, source
			))
		"MOVE_IN", "MOVE_OUT":
			# **Una pedina che entra o che esce senza che nessuno abbia fatto
			# MUOVERE.** `optional` perche' il tetto delle presenze e' del
			# motore: se la casa non ha piu' pedine, la casella non fallisce —
			# non lascia niente, che al tavolo e' quello che si vede.
			if house == "" or region == "":
				return out
			out.append(Effect.make(
				"ADD_PRESENCE" if verb == "MOVE_IN" else "REMOVE_PRESENCE",
				"entity", house, {"region_id": region, "optional": true}, source
			))
		"RAISE_STONE", "LOWER_STONE":
			var raised: String = str(voice.get("structure", ""))
			var grade: int = _stone_grade(world, region, raised)
			if region == "" or raised == "" or grade < 0:
				return out
			out.append(Effect.make(
				"SET_STRUCTURE_GRADE", "region", region,
				{
					"structure_type": raised,
					"grade": grade + (1 if verb == "RAISE_STONE" else -1),
					"optional": true,
				}, source
			))
		"SEAL_ROAD":
			var there: String = other_region_of(voice, context, world)
			if region == "" or there == "" or region == there:
				return out
			out.append(Effect.make(
				"CLOSE_PASSAGE", "region", region,
				{"region_id": there, "optional": true}, source
			))
		"LEAVE_TABLE":
			if house == "":
				return out
			out.append(Effect.make("SET_ENTITY_ACTIVE", "entity", house, {"active": false}, source))
		"ADD_CONDITION":
			if region == "":
				return out
			out.append(Effect.make(
				"SET_REGION_TAG", "region", region, {"tag": str(voice.get("tag", ""))}, source
			))
		"TOLL":
			if region == "":
				return out
			out.append(Effect.make("SET_REGION_TAG", "region", region, {"tag": TOLL_TAG}, source))
		"YIELD_CONTROL":
			# **Cedere e' cedere a qualcuno**: al rivale della questione se c'e',
			# altrimenti alla terra — un posto che nessuno tiene e' un fatto del
			# tavolo, non un buco.
			if region == "":
				return out
			var to_whom: String = _yield_target(voice, context, world)
			out.append(Effect.make(
				"SET_CONTROL", "region", region,
				{"entity_id": to_whom if to_whom != "" else null}, source
			))
		"HEAT_THEME":
			if theme_id == "":
				return out
			out.append(Effect.make("ADJUST_THEME_HEAT", "theme", theme_id, {"delta": 1}, source))
		"TAKE_DEBT":
			if region == "":
				return out
			out.append(Effect.make("SET_REGION_TAG", "region", region, {"tag": DEBT_TAG}, source))
		"SCAR":
			if region == "":
				return out
			out.append(Effect.make(
				"ADD_SCAR", "region", region,
				{
					"region_id": region,
					"scar_id": "%s:%s" % [str(context.get("tension", "")), str(voice.get("id", ""))],
					"tag": str(voice.get("tag", "")),
					"description": str(voice.get("text", "")),
				}, source
			))
		_:
			return out
	# `verb_kind` non cambia gli Effetti: serve al verbale e alla guardia, che
	# devono sapere se una voce era un beneficio o un prezzo.
	return out


## **Quanto vale una voce, guardando il tavolo** (D-280, taratura d'autore).
##
## Il cervello sapeva pesare solo quello che un Destino nomina: davanti a un
## vocabolario di verbi generici leggeva **zero** su tutto, comprava il primo
## beneficio — quello gratis — e non pagava mai. Un'economia che nessuno gioca
## e' contenuto che esiste nei dati e non esiste al tavolo (lezione di D-035).
##
## Questi numeri sono piccoli e **situazionali**: un titolo che gia' tieni non
## vale prenderlo, una condizione su una tessera che non e' tua non ti pesa
## come su una che e' tua, una Cicatrice pesa sempre perche' resta. Si sommano
## a quello che il Destino dice, che resta il metro fine.
##
## **E adesso guardano anche `chi`** (D-366): la stessa casella vale il
## contrario se la pedina e' posata su di te o sul rivale, ed e' quello che il
## tavolo legge in un colpo d'occhio.
## `theme_id` e' il Tema della carta in discussione: serve solo a RAFFREDDA
## TEMA, che senza di lui non sa che cosa sta raffreddando. Ha un valore di
## riposo perche' l'unico chiamante lo calcola gia' due righe sopra, e un
## chiamante nuovo che lo dimenticasse otterrebbe il vecchio comportamento
## invece di un errore.
static func intrinsic_value(
	voice: Dictionary, kind: String, context: Dictionary, world: Dictionary,
	theme_id: String = ""
) -> int:
	var region_id: String = region_of(voice, context, world)
	var proponent: String = str(context.get("proponent", ""))
	var house: String = house_of(voice, context, world)
	var on_me: bool = house != "" and house == proponent
	var regions: Dictionary = world.get("regions", {}) as Dictionary
	var region: Dictionary = (regions.get(region_id, {}) as Dictionary)
	var mine: bool = str(region.get("control", "")) == proponent and proponent != ""
	var tags: Array = region.get("tags", []) as Array
	match str(voice.get("verb", "")):
		"TAKE_CONTROL":
			if not on_me:
				return -2 if mine else 0
			return 0 if mine else 3
		"BUILD_STONE":
			return 2 if on_me else 0
		"CLEAR_CONDITION":
			for tag in tags:
				if str(tag).begins_with("condition:"):
					return 2 if mine else 1
			return 0
		"REOPEN":
			return 2 if tags.has(CLOSED_TAG) else 0
		# **RAFFREDDA TEMA vale se il Tema e' quello che sta per aprirsi.**
		#
		# Stessa forma di ABBASSA LA DOMANDA, e per la stessa ragione: dando un
		# valore alla domanda e lasciando il Tema a 1, gli acquisti di RAFFREDDA
		# TEMA sono crollati da 22 a 2 su cento saghe. Non si cura una casella
		# morta facendone morire un'altra.
		#
		# Il rombo piu' avanti e' il Tema su cui si aprira' il prossimo
		# Consiglio: raffreddare quello e' una cosa, raffreddare un rombo
		# indietro e' un'altra — e al tavolo si vede senza contare.
		"COOL_THEME":
			return 2 if _is_hottest(world, theme_id) else 1
		# **ABBASSA LA DOMANDA vale quanto e' alta la domanda** (ISSUES 117).
		#
		# Con un valore fisso di 1 questa casella era offerta **730 volte in
		# cento saghe e comprata zero**: il primo beneficio e' gratis, e chi
		# propone prendeva sempre quello che cambia la mappa. Una casella che
		# nessuno compra e', per il gioco, identica a una che non esiste.
		#
		# Non e' un numero piu' alto: e' il numero **giusto**. Raffreddare una
		# domanda a terra non vale niente; raffreddarne una a un passo dal
		# Consiglio vale quanto alzare una Pietra, perche' e' esattamente
		# quello che impedisce a qualcun altro di prendersi il posto.
		#
		# **Provata prima a 3 quando la domanda e' alta**, cioe' alla pari con
		# CAMBIA CONTROLLO: comprata 393 volte su 716, e le altre caselle si
		# svuotavano — COSTRUISCI PIETRA da 141 acquisti a 23, RAFFREDDA TEMA a
		# zero. Una casella che mangia le altre e' sbagliata quanto una che
		# nessuno compra, e il numero e' sceso a 2.
		#
		# La soglia non sta nel mondo — sta nei dati della carta, che qui non
		# arrivano — ma **53 Tensioni su 60 hanno soglia 6** e partono da 2:
		# la scala legge il valore, e la cosa e' dichiarata invece che nascosta.
		"COOL_QUESTION":
			var quanto: int = _question_heat(world, question_of(voice, context, world))
			if quanto <= 0:
				return 0
			return 2 if quanto >= 4 else 1
		"HEAT_QUESTION":
			return -1
		"YIELD_CONTROL":
			return -3 if mine else -1
		"ADD_CONDITION":
			return -2 if mine else -1
		"TAKE_DEBT":
			return -2 if mine else -1
		"TOLL":
			return -1
		"HEAT_THEME":
			return -1
		"SCAR":
			return -2
		# Le caselle di D-366. Il segno addosso lo pesa gia' il Destino, che
		# sa se quel segno lo vuole: qui resta solo il verso — un segno posato
		# su di me e' mio, uno tolto a me e' una perdita.
		"MARK_HOUSE":
			return 1 if on_me else 0
		"UNMARK_HOUSE":
			return -1 if on_me else 1
		"FORGET":
			return 1
		"UNVEIL_QUESTION":
			return 1
		"RAISE_STONE":
			return 2 if _stone_owner(world, region_id, str(voice.get("structure", ""))) == proponent else 0
		"LOWER_STONE":
			return -2 if _stone_owner(world, region_id, str(voice.get("structure", ""))) == proponent else -1
		"MOVE_IN":
			return 1 if on_me else -1
		"MOVE_OUT":
			return -2 if on_me else 2
		# **Un legame vale piu' di una pedina, perche' capita quasi mai.**
		# MUOVI UN RAPPORTO e' offerto **nove volte in cento saghe**: dare a
		# due caselle comuni lo stesso valore lo aveva spento del tutto, e la
		# prova che chiede *«su cinque anni almeno un legame si scalda»* e'
		# caduta. Quando il tavolo lo offre, e' la cosa piu' grossa sul piatto.
		"BIND_HOUSES":
			match str(voice.get("level", "")):
				"BOUND", "ALLY":
					return 3
				"HOSTILE", "ENEMY":
					return -2
			return 0
		"SEAL_ROAD":
			return -2 if mine else -1
		# La piu' grossa di tutte: una casa che esce dal tavolo. Se e' la tua
		# non c'e' beneficio che la paghi.
		"LEAVE_TABLE":
			return -6 if on_me else 2
	return 0


## La prima condizione posata su una tessera, o "": e' quella che RIMUOVI
## CONDIZIONE toglie quando la carta non ne nomina una.
static func _a_condition_on(world: Dictionary, region_id: String) -> String:
	var regions: Dictionary = world.get("regions", {}) as Dictionary
	var region: Variant = regions.get(region_id)
	if region == null:
		return ""
	for tag in ((region as Dictionary).get("tags", []) as Array):
		if str(tag).begins_with("condition:"):
			return str(tag)
	return ""


## Il vocabolario conosce questo verbo, e in quale delle due liste sta?
static func knows(verb: String, kind: String) -> bool:
	return (BENEFIT_VERBS if kind == "benefits" else COST_VERBS).has(verb)


## I parametri che una voce deve portare per essere giocabile: quelli del verbo,
## piu' quelli che il **posto** e la **casa** chiedono (D-366). «In una Regione
## col segno» senza il segno e' una pedina posata su un'icona vuota.
static func missing_parameters(voice: Dictionary, kind: String) -> Array:
	var book: Dictionary = BENEFIT_VERBS if kind == "benefits" else COST_VERBS
	var entry_: Dictionary = book.get(str(voice.get("verb", "")), {}) as Dictionary
	var wanted: Array = (entry_.get("needs", []) as Array).duplicate()
	var place: Dictionary = PLACES.get(str(voice.get("dove", "FOCUS")), {}) as Dictionary
	wanted.append_array(place.get("needs", []) as Array)
	var who: Dictionary = HOUSES.get(str(voice.get("chi", "PROPONENT")), {}) as Dictionary
	wanted.append_array(who.get("needs", []) as Array)
	var missing: Array = []
	for needed in wanted:
		if str(voice.get(str(needed), "")) == "" and not missing.has(str(needed)):
			missing.append(str(needed))
	return missing


## Dov'e' il segnalino di una domanda sulla sua traccia; -1 se quella domanda
## non e' al tavolo in questa Cronaca (D-028: la libreria ne nomina piu' di
## quante ne escono).
static func _question_value(world: Dictionary, tension_id: String) -> int:
	if tension_id == "":
		return -1
	var asked: Variant = (world.get("tensions", {}) as Dictionary).get(tension_id)
	if asked == null:
		return -1
	return int((asked as Dictionary).get("current_value", 0))


## L'ultima tacca della traccia di una domanda: la soglia stampata sulla carta.
## Senza il set dei dati non si sa, e allora la casella morde — meglio offrire
## una casella che non si sarebbe potuta offrire che tacere su una che si puo'.
static func _question_top(tension_id: String, data) -> int:
	if data == null or tension_id == "":
		return 99
	var card: Variant = (data.tensions as Dictionary).get(tension_id)
	if card == null:
		return 99
	return int((card as Dictionary).get("threshold", 99))
