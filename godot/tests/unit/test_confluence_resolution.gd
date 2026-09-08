extends "res://tests/test_case.gd"
## §18.3, riscritto a due domande (D-467, D-472): l'aritmetica del voto
## **contro il mucchio**, senza dado.
##
## `test_the_council_of_two_questions` tiene i sei casi tipici dei tre esiti;
## qui stanno **i bordi**: il mucchio a zero, la parte che arriva al mucchio
## esatto o resta sotto di uno, la B che vince di molto senza fasce sue, i
## bonus dei fronti su un fronte vuoto. Ogni riga dice il conto in chiaro,
## cosi' una Strategia che sposta un confine cade qui e non in un playtest.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")


## **Arrivare al mucchio conta, restarci sotto di uno no.** E' la soglia che
## rende il mucchio una cosa da guardare prima di impegnare le carte.
func test_reaching_the_pile_exactly_is_enough() -> void:
	assert_eq(ConfluenceResolution.two_sides_outcome(4, 1, 4), ConfluenceResolution.SUCCESS, "A al mucchio esatto passa")
	assert_eq(ConfluenceResolution.two_sides_outcome(3, 1, 4), ConfluenceResolution.FAILURE, "A sotto di uno non passa")
	assert_eq(ConfluenceResolution.two_sides_outcome(1, 4, 4), ConfluenceResolution.COUNTER, "B al mucchio esatto vince")
	assert_eq(ConfluenceResolution.two_sides_outcome(1, 3, 4), ConfluenceResolution.FAILURE, "B sotto di uno no")


## **Col mucchio a zero basta una carta**, e a zero contro zero non passa
## nessuno: la parita' non e' una vittoria nemmeno quando non c'e' soglia.
func test_an_empty_pile_still_needs_a_winner() -> void:
	assert_eq(ConfluenceResolution.two_sides_outcome(0, 0, 0), ConfluenceResolution.FAILURE, "zero contro zero: nessuna")
	assert_eq(ConfluenceResolution.two_sides_outcome(1, 0, 0), ConfluenceResolution.SUCCESS_WITH_COST, "una carta sola basta, di misura")
	assert_eq(ConfluenceResolution.two_sides_outcome(0, 1, 0), ConfluenceResolution.COUNTER, "e vale per la B")
	assert_eq(ConfluenceResolution.two_sides_outcome(6, 6, 0), ConfluenceResolution.FAILURE, "a parita' alta, lo stesso")


## **Le fasce di A sul margine su B**: 1 e' «si paga», 2 e 4 sono «passa»,
## 5 e' «senza discussione». I totali alti non cambiano la fascia: conta la
## distanza fra le due parti, non quanto e' pieno il tavolo.
func test_the_bands_of_a_are_on_the_margin() -> void:
	assert_eq(ConfluenceResolution.two_sides_outcome(2, 0, 0), ConfluenceResolution.SUCCESS, "M=2 e' il primo «passa»")
	assert_eq(ConfluenceResolution.two_sides_outcome(4, 0, 0), ConfluenceResolution.SUCCESS, "M=4 l'ultimo")
	assert_eq(ConfluenceResolution.two_sides_outcome(5, 0, 0), ConfluenceResolution.DECISIVE, "M=5 e' senza discussione")
	assert_eq(ConfluenceResolution.two_sides_outcome(7, 6, 7), ConfluenceResolution.SUCCESS_WITH_COST, "sette contro sei e' ancora di misura")
	assert_eq(ConfluenceResolution.two_sides_outcome(12, 3, 7), ConfluenceResolution.DECISIVE, "dodici contro tre no")


## **La B non ha fasce**: che vinca di uno o di nove, e' COUNTER. Per chi
## propone e' una sconfitta, per il mondo e' una decisione presa.
func test_b_wins_without_bands() -> void:
	assert_eq(ConfluenceResolution.two_sides_outcome(0, 9, 0), ConfluenceResolution.COUNTER, "di molto")
	assert_eq(ConfluenceResolution.two_sides_outcome(8, 9, 0), ConfluenceResolution.COUNTER, "di misura")
	assert_eq(ConfluenceResolution.two_sides_outcome(8, 9, 10), ConfluenceResolution.FAILURE, "ma sotto il mucchio non e' niente")


## Chi ha vinto, e se per chi propone e' un successo: i cinque esiti uno per
## uno, cosi' un esito nuovo che nessuno ha messo in tabella cade qui.
func test_winner_and_success_for_every_outcome() -> void:
	var rows: Array = [
		[ConfluenceResolution.FAILURE, "", false],
		[ConfluenceResolution.SUCCESS_WITH_COST, "A", true],
		[ConfluenceResolution.SUCCESS, "A", true],
		[ConfluenceResolution.DECISIVE, "A", true],
		[ConfluenceResolution.COUNTER, "B", false],
	]
	for row in rows:
		assert_eq(ConfluenceResolution.winner_of(str(row[0])), str(row[1]), "chi vince con %s" % str(row[0]))
		assert_eq(ConfluenceResolution.is_success(str(row[0])), bool(row[2]), "successo di A con %s" % str(row[0]))


## §12.3: full strength only when the family is relevant, otherwise 1.
func test_asset_value_relevance() -> void:
	var strong: Dictionary = {
		"family": "WEALTH", "strength": 2, "confluence_modifier": {"kind": "NONE", "value": 0}
	}
	assert_eq(
		ConfluenceResolution.asset_value(strong, ["WEALTH", "PEOPLE"], "SUPPORT"),
		2,
		"famiglia rilevante: forza piena"
	)
	assert_eq(
		ConfluenceResolution.asset_value(strong, ["KNOWLEDGE"], "SUPPORT"),
		1,
		"famiglia non rilevante: vale 1"
	)


func test_asset_value_modifiers() -> void:
	var relevant_bonus: Dictionary = {
		"family": "AUTHORITY",
		"strength": 2,
		"confluence_modifier": {"kind": "RELEVANT_BONUS", "value": 1},
	}
	assert_eq(
		ConfluenceResolution.asset_value(relevant_bonus, ["AUTHORITY"], "SUPPORT"),
		3,
		"RELEVANT_BONUS si applica sulla famiglia rilevante"
	)
	assert_eq(
		ConfluenceResolution.asset_value(relevant_bonus, ["WEALTH"], "SUPPORT"),
		1,
		"RELEVANT_BONUS non si applica fuori dalla famiglia rilevante"
	)

	var oppose_bonus: Dictionary = {
		"family": "PEOPLE",
		"strength": 2,
		"confluence_modifier": {"kind": "OPPOSE_BONUS", "value": 1},
	}
	assert_eq(
		ConfluenceResolution.asset_value(oppose_bonus, ["PEOPLE"], "OPPOSE"),
		3,
		"OPPOSE_BONUS vale sul fronte contrario"
	)
	assert_eq(
		ConfluenceResolution.asset_value(oppose_bonus, ["PEOPLE"], "SUPPORT"),
		2,
		"OPPOSE_BONUS non vale sul fronte a favore"
	)

	var flat: Dictionary = {
		"family": "KNOWLEDGE",
		"strength": 1,
		"confluence_modifier": {"kind": "FLAT_BONUS", "value": 2},
	}
	assert_eq(
		ConfluenceResolution.asset_value(flat, ["WEALTH"], "SUPPORT"),
		3,
		"FLAT_BONUS si somma anche fuori dalla famiglia rilevante"
	)
	flat["confluence_modifier"] = {"kind": "FLAT_BONUS", "value": -3}
	assert_eq(
		ConfluenceResolution.asset_value(flat, ["WEALTH"], "SUPPORT"),
		0,
		"e una carta non vale mai meno di zero"
	)


## §12.3 (D-055): a Condition that is paid for argues *for* the proposition - its
## commits join S - and one that is not paid for argues for nothing.
func test_abstain_commits_are_ignored() -> void:
	var assets: Dictionary = {
		"AST_WEALTH_GRAIN": {
			"family": "WEALTH", "strength": 1, "confluence_modifier": {"kind": "NONE", "value": 0}
		},
	}
	var result: Dictionary = ConfluenceResolution.resolve(
		"ENT_A",
		{"ENT_B": {"stance": "ABSTAIN"}},
		{"ENT_A": ["AST_WEALTH_GRAIN"], "ENT_B": ["AST_WEALTH_GRAIN"]},
		assets,
		["WEALTH"]
	)
	assert_eq(result["support_total"], 1, "chi si astiene non contribuisce")
	assert_eq(result["oppose_total"], 0, "chi si astiene non contribuisce")


## **`resolve` conta le carte delle due parti, e basta** (D-472): chi propone
## e chi sta con A sommano a favore, chi sta con B contro; i bonus dei fronti
## entrano solo dove c'e' almeno una carta — un bonus su zero carte sarebbe
## un voto gratis — e l'esito non c'e': lo dice `two_sides_outcome` col
## mucchio, che qui non entra.
func test_resolve_counts_the_two_fronts_with_their_bonuses() -> void:
	var assets: Dictionary = {
		"AST_GRAIN": {"family": "WEALTH", "strength": 2, "confluence_modifier": {"kind": "NONE", "value": 0}},
		"AST_SWORD": {"family": "FORCE", "strength": 3, "confluence_modifier": {"kind": "NONE", "value": 0}},
	}
	var result: Dictionary = ConfluenceResolution.resolve(
		"ENT_A",
		{"ENT_B": {"stance": "SUPPORT"}, "ENT_C": {"stance": "OPPOSE"}, "ENT_D": {"stance": "OPPOSE"}},
		{"ENT_A": ["AST_GRAIN"], "ENT_B": ["AST_SWORD"], "ENT_C": ["AST_GRAIN"], "ENT_D": ["AST_NON_ESISTE"]},
		assets,
		["WEALTH"],
		1,
		2
	)
	assert_eq(int(result["support_total"]), 2 + 1 + 1, "A: 2 di grano, 1 di spada fuori famiglia, +1 di bonus")
	assert_eq(int(result["oppose_total"]), 2 + 2, "B: 2 di grano e +2 di bonus; la carta che non esiste non conta")
	assert_eq(result["support_assets"], ["AST_GRAIN", "AST_SWORD"], "le carte di A, nell'ordine di chi le ha messe")
	assert_eq(result["oppose_assets"], ["AST_GRAIN", "AST_NON_ESISTE"], "e quelle di B, anche quella che non vale")
	assert_eq(str(result["strategy"]), ConfluenceResolution.STRATEGY_ID, "firmato dalla Strategia")
	for gone in ["outcome", "margin", "world_factor", "die"]:
		assert_false(result.has(gone), "«%s» non e' piu' un affare del conto delle carte" % gone)

	var empty_front: Dictionary = ConfluenceResolution.resolve(
		"ENT_A", {"ENT_C": {"stance": "OPPOSE"}}, {"ENT_A": ["AST_GRAIN"], "ENT_C": []}, assets, ["WEALTH"], 1, 2
	)
	assert_eq(int(empty_front["support_total"]), 3, "il bonus entra dove c'e' una carta")
	assert_eq(int(empty_front["oppose_total"]), 0, "e resta zero dove non ce n'e': nessun voto gratis")
