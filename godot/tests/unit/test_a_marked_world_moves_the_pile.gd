extends "res://tests/test_case.gd"
## **Un mondo segnato cambia quanto e' difficile decidere**
## ([D-477](DECISIONS.md#d-477)).
##
## Il mucchio e' la soglia che le due parti devono battere per far passare la
## loro domanda (D-467). Le ventun regole `COUNCIL_MODIFIER` dicono quanto il
## mondo la muove: la fame sparsa in giro alza la soglia di un Consiglio sulla
## Carestia, una citta' che parla forte la abbassa.
##
## **Spingevano il World Factor**, cioe' il dado, uscito con D-467: da allora
## nessuno le chiamava, e ventun righe d'autore non muovevano piu' niente. Sono
## la ragione per cui questa prova esiste — un gancio spento non fallisce, tace.
##
## I casi sono **fabbricati**, e devono esserlo: aspettare che un seme metta la
## fame nel posto giusto mentre si apre proprio il Consiglio della Carestia
## vorrebbe dire una prova che smette di provare appena cambia il seme. E' la
## regola di casa, e in questo progetto e' costata sette volte.

const TagRules := preload("res://scripts/world/tag_rules.gd")


func before_each() -> void:
	new_session()


## La fame in una Regione qualsiasi alza di uno il mucchio del Consiglio sulla
## Carestia — «se da qualche parte si muore di fame, la fame siede al tavolo».
func test_hunger_anywhere_raises_the_pile_on_famine() -> void:
	var region_id: String = str((session.world["regions"] as Dictionary).keys()[0])
	var before: Dictionary = TagRules.council_pile_shift(
		session.data, session.world, "TEN_FAMINE", str(session.world["turn_order"][0])
	)
	assert_eq(int(before["delta"]), 0, "senza fame il mondo non pesa")

	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).append(
		"condition:starving"
	)
	var after: Dictionary = TagRules.council_pile_shift(
		session.data, session.world, "TEN_FAMINE", str(session.world["turn_order"][0])
	)
	assert_eq(int(after["delta"]), 1, "con la fame la soglia sale di uno")
	assert_true(
		(after["titles"] as Array).has("La fame siede al tavolo"),
		"e il Consiglio sa dire perche': %s" % str(after["titles"])
	)


## E la regola nomina la sua questione: la fame non pesa su un Consiglio che
## non parla di fame.
func test_the_rule_only_bites_on_its_own_question() -> void:
	var region_id: String = str((session.world["regions"] as Dictionary).keys()[0])
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).append(
		"condition:starving"
	)
	var elsewhere: Dictionary = TagRules.council_pile_shift(
		session.data, session.world, "TEN_SUCCESSION", str(session.world["turn_order"][0])
	)
	assert_eq(int(elsewhere["delta"]), 0, "sulla Successione la fame non c'entra")


## **E il mucchio del Consiglio vero se ne accorge.** La prova sopra guarda la
## regola; questa guarda il tavolo: si apre il Consiglio della Carestia col
## mondo segnato, e la soglia che le due parti devono battere e' piu' alta.
func test_the_open_council_reads_the_marked_world() -> void:
	var theme_id: String = str(session.data.tensions["TEN_FAMINE"].get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = 3

	var clean: Dictionary = session.confluence.open("TEN_FAMINE", {"kind": "THRESHOLD"})
	assert_false(clean.is_empty(), "il Consiglio della Carestia si apre")
	assert_eq(session.confluence.pile(), 3, "col mondo pulito il mucchio e' quello dei gettoni")
	session.confluence.current = {}

	var region_id: String = str((session.world["regions"] as Dictionary).keys()[0])
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).append(
		"condition:starving"
	)
	var marked: Dictionary = session.confluence.open("TEN_FAMINE", {"kind": "THRESHOLD"})
	assert_false(marked.is_empty(), "e si riapre col mondo segnato")
	assert_eq(session.confluence.pile(), 4, "la fame alza la soglia di uno")
	session.confluence.current = {}


## **La soglia non scende sotto zero.** Un mucchio negativo vorrebbe dire una
## parte che passa senza aver messo niente sul tavolo, e quel gesto non esiste.
func test_the_pile_never_goes_below_nothing() -> void:
	var theme_id: String = str(session.data.tensions["TEN_FAMINE"].get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = 0
	# «La citta' parla piu' forte al Consiglio» abbassa di uno, su ogni domanda.
	var region_id: String = str((session.world["regions"] as Dictionary).keys()[0])
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).append(
		"settlement:city"
	)
	var shift: Dictionary = TagRules.council_pile_shift(
		session.data, session.world, "TEN_FAMINE", str(session.world["turn_order"][0])
	)
	assert_eq(int(shift["delta"]), -1, "la citta' abbassa la soglia")

	var context: Dictionary = session.confluence.open("TEN_FAMINE", {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio si apre")
	assert_eq(session.confluence.pile(), 0, "e con zero gettoni il mucchio resta zero")
	session.confluence.current = {}
