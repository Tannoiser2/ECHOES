extends "res://tests/test_case.gd"
## D-069: la policy gioca CLAIM - il diritto di proporre (issue #22).
##
## Il proponente lo decide il posto (D-036), e il posto e' di chi vuole l'esito
## ovvio (D-063): le proposte scritte per i seggi senza parola erano contenuto
## morto. CLAIM e' l'azione che sposta la parola, e la policy non l'ha mai
## giocata. Questi test fissano il *quando*: la moderazione e' stata misurata
## una vite alla volta, e ogni condizione qui dentro corrisponde a un tavolo
## che senza di lei si rompeva (i numeri stanno in D-069).

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Effect := preload("res://scripts/core/effect.gd")

## Quattro carte AUTHORITY: due per la coppia prenota-e-forza, due per tenere
## la mano sopra COMFORTABLE_HAND anche dopo lo scarto.
const AUTHORITY_CARDS: Array = [
	"AST_AUTHORITY_EDICT", "AST_AUTHORITY_SEAL",
	"AST_AUTHORITY_CENSUS", "AST_AUTHORITY_CROWN_RIGHT",
]


func before_each() -> void:
	new_session()
	# Lyra fuori dalle Miniere: il proponente naturale del Risveglio diventa
	# Vaerax, e Lyra - che per la sua prima Scoperta ha bisogno proprio di quel
	# Consiglio - resta senza parola. E' il caso che D-063 ha descritto.
	session.applier.apply(Effect.make(
		"REMOVE_PRESENCE", "entity", "ENT_LYRA",
		{"region_id": "REG_MINIERE_ANTICHE"}, _source()
	))


func _source() -> Dictionary:
	return Effect.source("developer", "TEST", "", 1, 1, 0)


func _arm(entity_id: String, cards: int) -> void:
	for i in range(cards):
		session.applier.apply(Effect.make(
			"GRANT_ASSET", "entity", entity_id,
			{"asset_id": str(AUTHORITY_CARDS[i]), "source": "VOID"}, _source()
		))


func _heat(tension_id: String, value: int) -> void:
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", tension_id,
		{"delta": value - session.tensions.value(tension_id)}, _source()
	))


## Il resto del tavolo spento.
##
## Da D-207 CHR_01 porta anche `CNF_ANY_SURVIVAL`, perche' la sua biblioteca
## puo' pescare la Febbre Bassa e i Pozzi Bassi, che un Consiglio proprio non
## ce l'hanno. L'effetto collaterale e' che **la Carestia diventa una strada**
## per una clausola che prima poteva passare solo dal Risveglio: questi test
## trovavano `{}` perche' Lyra non aveva altro da chiedere, non perche' la
## regola dicesse di no. Adesso lo dicono spegnendo il resto del tavolo, che e'
## quello che intendevano da sempre.
func _cool_the_table(except_id: String) -> void:
	for tension_id in session.world["tensions"]:
		if str(tension_id) == except_id:
			continue
		_heat(str(tension_id), 0)


## Armata e con la domanda che scotta, Lyra prenota il dominio che il suo
## Destino aspetta e di cui non avrebbe mai la parola.
func test_a_wordless_seat_books_the_domain_it_needs() -> void:
	_arm("ENT_LYRA", 4)
	_heat("TEN_AWAKENING", 5)
	var request: Dictionary = PolicyDecider.new(null)._claim_the_word("ENT_LYRA", session)
	assert_eq(str(request.get("template", "")), "CLAIM", "Lyra si prenota la parola")
	assert_eq(str(request["params"]["mode"]), "CREATE", "prima si prenota il dominio")
	assert_eq(str(request["params"]["domain"]), "ANCIENT", "il dominio del Risveglio")


## Una domanda fredda non vale la carta: prenotarsi su un Consiglio lontano e'
## un Consiglio che il tavolo non voleva (prima stesura: FAIL 219 -> 339).
func test_a_cold_question_is_not_worth_the_card() -> void:
	_arm("ENT_LYRA", 4)
	_cool_the_table("TEN_AWAKENING")
	_heat("TEN_AWAKENING", 1)
	assert_eq(
		PolicyDecider.new(null)._claim_the_word("ENT_LYRA", session), {},
		"a Tensione fredda non si prenota niente"
	)


## Con una sola AUTHORITY non si comincia: la prenotazione senza la carta per
## riscuoterla e' una carta e un'azione bruciate (124 creati, 45 forzati).
func test_booking_needs_the_card_to_cash_it() -> void:
	_arm("ENT_LYRA", 1)
	_heat("TEN_AWAKENING", 5)
	assert_eq(
		PolicyDecider.new(null)._claim_the_word("ENT_LYRA", session), {},
		"senza la coppia di AUTHORITY non si prenota"
	)


## Prenotato in un round, si forza da quello dopo - e il Consiglio forzato
## arriva in un round che sarebbe rimasto muto.
func test_the_claim_is_cashed_the_round_after() -> void:
	_arm("ENT_LYRA", 4)
	_cool_the_table("TEN_AWAKENING")
	_heat("TEN_AWAKENING", 5)
	var policy: RefCounted = PolicyDecider.new(null)
	var create: Dictionary = policy._claim_the_word("ENT_LYRA", session)
	var outcome: Dictionary = session.actions.execute("ENT_LYRA", create)
	assert_true(bool(outcome["ok"]), "la prenotazione e' legale: %s" % str(outcome.get("error", "")))

	# Nello stesso round il Claim non si riscuote (§10)...
	assert_eq(
		str(policy._claim_the_word("ENT_LYRA", session).get("params", {}).get("mode", "")), "",
		"nel round della prenotazione non si forza"
	)
	# ...dal round dopo si'.
	session.world["round"] = 2
	var force: Dictionary = policy._claim_the_word("ENT_LYRA", session)
	assert_eq(str(force.get("params", {}).get("mode", "")), "FORCE", "il round dopo si riscuote")
	assert_eq(str(force["params"]["tension_id"]), "TEN_AWAKENING", "sul Consiglio che il Destino aspetta")


## La parola ruota (D-051): chi ha parlato per ultimo su una domanda non se la
## riprenota - senza questo, chi forzava monopolizzava i Consigli e affamava
## chi li aspettava per posizione.
func test_the_word_rotates() -> void:
	_arm("ENT_LYRA", 4)
	_cool_the_table("TEN_AWAKENING")
	_heat("TEN_AWAKENING", 5)
	session.world["last_proponent"] = {"TEN_AWAKENING": "ENT_LYRA"}
	assert_eq(
		PolicyDecider.new(null)._claim_the_word("ENT_LYRA", session), {},
		"ho gia' parlato per ultimo qui: tocca a qualcun altro"
	)


## E chi la parola l'avrebbe comunque non spreca carte per chiederla.
func test_the_natural_proponent_does_not_claim() -> void:
	_arm("ENT_VAERAX", 4)
	# Col resto del tavolo acceso la prova misurava un caso: da D-461 la
	# Carestia porta «Chi puo', se ne va», e Vaerax la prenotava. Qui si prova
	# che il proponente naturale non compra la parola che ha, non che il resto
	# del tavolo taccia.
	_cool_the_table("TEN_AWAKENING")
	_heat("TEN_AWAKENING", 5)
	assert_eq(
		PolicyDecider.new(null)._claim_the_word("ENT_VAERAX", session), {},
		"il proponente naturale non prenota quello che ha gia'"
	)


## D-191, la deroga a §10 chiesta dal committente: **non si prenota una domanda
## che e' gia' matura**. Con `claim_rules.same_round_when_ready` acceso,
## strappare il Consiglio e' un'azione sola, senza prenotazione.
func test_a_ripe_question_is_taken_in_one_move() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	var before: Variant = chronicle.get("claim_rules")
	chronicle.erase("claim_rules")
	session.actions.set("_chronicle", chronicle)
	# La Carestia parte a 3: matura per §10, ma senza prenotazione non si tocca.
	var force: Dictionary = {"mode": "FORCE", "tension_id": "TEN_FAMINE"}
	var refused: String = session.actions.check("ENT_ALDRIC", "CLAIM", force)
	assert_ne(refused, "", "col §10 di sempre serve un Claim posato prima")
	assert_true(refused.contains("nessun Claim"), "e il motivo lo dice: «%s»" % refused)

	chronicle["claim_rules"] = {"same_round_when_ready": true, "ready_at": 3}
	session.actions.set("_chronicle", chronicle)
	assert_eq(
		session.actions.check("ENT_ALDRIC", "CLAIM", force), "",
		"con la deroga, una domanda matura si strappa in un colpo"
	)
	if before == null:
		chronicle.erase("claim_rules")
	else:
		chronicle["claim_rules"] = before


## E la maturita' resta una condizione: una domanda fredda non si strappa,
## deroga o no. E' quello che tiene in vita la prenotazione.
func test_a_cold_question_still_needs_the_booking() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_TEST"] as Dictionary
	var before: Variant = chronicle.get("claim_rules")
	chronicle["claim_rules"] = {"same_round_when_ready": true, "ready_at": 3}
	session.actions.set("_chronicle", chronicle)
	# Il Risveglio parte a 2: sotto la maturita'.
	var force: Dictionary = {"mode": "FORCE", "tension_id": "TEN_AWAKENING"}
	var refused: String = session.actions.check("ENT_ALDRIC", "CLAIM", force)
	assert_ne(refused, "", "una domanda fredda non si strappa")
	assert_true(
		refused.contains("almeno 3"), "e il motivo e la maturita: «%s»" % refused
	)
	if before == null:
		chronicle.erase("claim_rules")
	else:
		chronicle["claim_rules"] = before
