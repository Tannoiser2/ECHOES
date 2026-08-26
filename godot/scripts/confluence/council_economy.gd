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
## 1. **Un vocabolario chiuso di verbi**, non frasi d'autore. Cinque benefici e
##    sei costi, gli stessi su ogni carta — come le caselle di un tabellone.
##    Quello che cambia da carta a carta e' la Domanda, i segni che chiede sul
##    tavolo, e i **parametri**: quale condizione lascia, quale Pietra alza,
##    quale Cicatrice incide.
## 2. **Un'economia**: *un beneficio e' gratis; ogni beneficio in piu' costa un
##    costo.* Massimo tre benefici, massimo due costi — e il tetto non si
##    sfonda: la Cicatrice e' un costo come gli altri (D-303).
## 3. **Due mani**: il proponente compra i benefici, **gli avversari scelgono in
##    che moneta paga** (parola del committente, scelta fra tre). Lui sa
##    *quanto* paga; non sa *in cosa*.
##
## I verbi stanno qui e non nei dati perche' ognuno **produce Effetti**: e'
## codice, e il codice si prova. La carta li nomina e li parametrizza; questo
## modulo li esegue sul luogo di cui si sta discutendo.

const Effect := preload("res://scripts/core/effect.gd")

## Quante pedine stanno sulla carta, se la carta non dice altro.
const MAX_BENEFITS: int = 3
const MAX_COSTS: int = 2

## Il tetto del Calore, per sapere se SCALDA TEMA ha ancora spazio (D-306).
## E' lo stesso numero di `EffectApplier.HEAT_MAX`, e la prova lo verifica.
const MAX_HEAT: int = 6

## Il vocabolario. `needs` dice quali parametri la voce deve portare sulla
## carta: una voce senza il suo parametro non e' giocabile, e il validatore la
## rifiuta prima che il tavolo se ne accorga.
const BENEFIT_VERBS: Dictionary = {
	"REOPEN": {"label": "RIAPRI", "needs": []},
	"CLEAR_CONDITION": {"label": "RIMUOVI CONDIZIONE", "needs": []},
	"BUILD_STONE": {"label": "COSTRUISCI PIETRA", "needs": ["structure"]},
	"TAKE_CONTROL": {"label": "CAMBIA CONTROLLO", "needs": []},
	"COOL_THEME": {"label": "RAFFREDDA TEMA", "needs": []},
}
const COST_VERBS: Dictionary = {
	"ADD_CONDITION": {"label": "AGGIUNGI CONDIZIONE", "needs": ["tag"]},
	"TOLL": {"label": "PEDAGGIO", "needs": []},
	"YIELD_CONTROL": {"label": "CEDI CONTROLLO", "needs": []},
	"HEAT_THEME": {"label": "SCALDA TEMA", "needs": []},
	"TAKE_DEBT": {"label": "PRENDI DEBITO", "needs": []},
	"SCAR": {"label": "CICATRICE", "needs": ["tag"]},
}

## Il segno che il pedaggio lascia sulla tessera, e quello del debito: due
## parole del dizionario, non due invenzioni di questo modulo.
const TOLL_TAG: String = "structure:tollgate"
const DEBT_TAG: String = "condition:indebted"
const CLOSED_TAG: String = "condition:cut_off"


## **Il prezzo di un carrello di benefici.** Uno e' gratis; ogni altro costa un
## costo. Il tetto e' tre, e non si sfonda: **la Cicatrice non compra niente**
## (D-303, parola del committente: *«io a questo punto toglierei la cicatrice,
## la lascerei come effetto malus o passivo»*). Resta uno dei sei costi, che e'
## quello che al tavolo era gia' — misurato, si posava 17 volte in 40 anni
## **come prezzo**, e mai come moneta d'acquisto: il quarto beneficio valeva
## uno e costava quattro (D-302), e nessun seggio sano lo comprava.
static func costs_due(benefits: int) -> int:
	return maxi(0, mini(benefits - 1, MAX_COSTS))


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
	var region: String = str(context.get("region_focus", ""))
	var proponent: String = str(context.get("proponent", ""))
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
			return _stone_owner(world, region, stone) != proponent
		"TAKE_CONTROL":
			return region != "" and _control_of(world, region) != proponent
		"COOL_THEME":
			return _heat_of(world, theme_id) > 0
		"ADD_CONDITION":
			return not _region_has(world, region, str(voice.get("tag", "")))
		"TOLL":
			return not _region_has(world, region, TOLL_TAG)
		"YIELD_CONTROL":
			# Cedere morde se c'e' qualcosa da cedere, e se non lo si sta
			# cedendo a chi lo tiene gia'.
			if region == "":
				return false
			var to_whom: String = str(context.get("rival", ""))
			return _control_of(world, region) != to_whom
		"HEAT_THEME":
			return theme_id != "" and _heat_of(world, theme_id) < MAX_HEAT
		"TAKE_DEBT":
			return not _region_has(world, region, DEBT_TAG)
		"SCAR":
			return region != ""
	return false


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


## Gli Effetti di una voce, sul luogo di cui si discute.
##
## `context` e' quello che il Consiglio gia' calcola (`effect_context`):
## `region_focus`, `proponent`, `rival`, `tension`. `world` serve solo alle due
## voci che devono **guardare la tessera** prima di parlare — togliere una
## condizione vuol dire togliere *quella che c'e'*.
static func effects_for(
	voice: Dictionary, verb_kind: String, context: Dictionary,
	world: Dictionary, theme_id: String, source: Dictionary
) -> Array:
	var verb: String = str(voice.get("verb", ""))
	var region: String = str(context.get("region_focus", ""))
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
					{
						"structure_type": stone,
						"entity_id": str(context.get("proponent", "")),
					}, source
				))
				return out
			out.append(Effect.make(
				"BUILD_STRUCTURE", "region", region,
				{
					"structure_type": stone,
					"grade": 1, "owner": str(context.get("proponent", "")),
				}, source
			))
		"TAKE_CONTROL":
			if region == "":
				return out
			out.append(Effect.make(
				"SET_CONTROL", "region", region,
				{"entity_id": str(context.get("proponent", ""))}, source
			))
		"COOL_THEME":
			if theme_id == "":
				return out
			out.append(Effect.make("ADJUST_THEME_HEAT", "theme", theme_id, {"delta": -1}, source))
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
			var to_whom: Variant = context.get("rival", "")
			out.append(Effect.make(
				"SET_CONTROL", "region", region,
				{"entity_id": to_whom if str(to_whom) != "" else null}, source
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
static func intrinsic_value(
	voice: Dictionary, kind: String, context: Dictionary, world: Dictionary
) -> int:
	var region_id: String = str(context.get("region_focus", ""))
	var proponent: String = str(context.get("proponent", ""))
	var regions: Dictionary = world.get("regions", {}) as Dictionary
	var region: Dictionary = (regions.get(region_id, {}) as Dictionary)
	var mine: bool = str(region.get("control", "")) == proponent and proponent != ""
	var tags: Array = region.get("tags", []) as Array
	match str(voice.get("verb", "")):
		"TAKE_CONTROL":
			return 0 if mine else 3
		"BUILD_STONE":
			return 2
		"CLEAR_CONDITION":
			for tag in tags:
				if str(tag).begins_with("condition:"):
					return 2 if mine else 1
			return 0
		"REOPEN":
			return 2 if tags.has(CLOSED_TAG) else 0
		"COOL_THEME":
			return 1
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


## I parametri che una voce deve portare per essere giocabile.
static func missing_parameters(voice: Dictionary, kind: String) -> Array:
	var book: Dictionary = BENEFIT_VERBS if kind == "benefits" else COST_VERBS
	var entry: Dictionary = book.get(str(voice.get("verb", "")), {}) as Dictionary
	var missing: Array = []
	for needed in (entry.get("needs", []) as Array):
		if str(voice.get(str(needed), "")) == "":
			missing.append(str(needed))
	return missing
