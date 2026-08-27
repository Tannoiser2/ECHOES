extends "res://tests/test_case.gd"
## **`$any` e `$rival` sulle Regioni** (D-315).
##
## Un obiettivo del pool lo pesca chiunque, in qualunque Chronicle, e da D-265
## **la mappa si pesca**: nominare REG_EREDAN lo renderebbe muto meta' delle
## volte, e il validatore giustamente lo vieta. Il risultato e' che fino a
## D-315 **nessun obiettivo del mazzo poteva chiedere un segno di Regione**, e
## i segni di Regione temuti restavano temuti da tutti e voluti da nessuno.
##
## Le due forme che aprono quella porta si provano qui, e si prova soprattutto
## la differenza fra loro: `$any` guarda tutta la mappa, `$rival` **solo le
## terre che tiene un altro** — la forma che non si puo' soddisfare in casa
## propria.

const MARK: String = "condition:exploited"


func before_each() -> void:
	new_session()


func _mine() -> String:
	for entity_id in session.world["entities"]:
		return str(entity_id)
	return ""


## La Regione che tiene il seggio, e una che tiene qualcun altro. Fabbricate:
## una prova che aspetta la mappa giusta smette di provare senza dirlo.
func _stage(me: String) -> Array:
	var others: Array = []
	for entity_id in session.world["entities"]:
		if str(entity_id) != me:
			others.append(str(entity_id))
	var ids: Array = []
	for region_id in session.world["regions"]:
		ids.append(str(region_id))
	ids.sort()
	assert_true(ids.size() >= 2, "servono due Regioni per la prova")
	assert_false(others.is_empty(), "serve un'altra casa al tavolo")
	var mine: Dictionary = session.world["regions"][ids[0]] as Dictionary
	var theirs: Dictionary = session.world["regions"][ids[1]] as Dictionary
	mine["control"] = me
	theirs["control"] = str(others[0])
	(mine["tags"] as Array).erase(MARK)
	(theirs["tags"] as Array).erase(MARK)
	return [str(ids[0]), str(ids[1])]


func _holds(region_slot: String, me: String) -> bool:
	return session.destinies.conditions.holds(
		{
			"type": "state_tag_present",
			"scope": "REGION",
			"region_id": region_slot,
			"tag": MARK,
		},
		{"self": me}
	)


## Senza il segno da nessuna parte, nessuna delle due forme e' vera: e' il caso
## che deve dare **falso**, e senza di lui un `true` costante passerebbe.
func test_neither_form_holds_on_a_clean_map() -> void:
	var me: String = _mine()
	_stage(me)
	assert_false(_holds("$any", me), "$any non deve trovare niente su una mappa pulita")
	assert_false(_holds("$rival", me), "$rival non deve trovare niente su una mappa pulita")


## Il segno **in casa propria**: `$any` lo vede, `$rival` no. E' tutta la
## differenza fra le due forme, ed e' la ragione per cui `$rival` esiste.
func test_only_any_sees_the_sign_on_your_own_land() -> void:
	var me: String = _mine()
	var places: Array = _stage(me)
	(session.world["regions"][places[0]]["tags"] as Array).append(MARK)
	assert_true(_holds("$any", me), "$any deve vedere il segno sulla propria terra")
	assert_false(_holds("$rival", me), "$rival non deve contare la propria terra")


## Il segno **in casa d'altri**: le vedono tutte e due.
func test_both_forms_see_the_sign_on_a_rival_land() -> void:
	var me: String = _mine()
	var places: Array = _stage(me)
	(session.world["regions"][places[1]]["tags"] as Array).append(MARK)
	assert_true(_holds("$any", me), "$any deve vedere il segno in casa d'altri")
	assert_true(_holds("$rival", me), "$rival deve vedere il segno in casa d'altri")


## Una terra **di nessuno** non e' la terra di un rivale: `$rival` la salta.
## Senza questo, «sfrutta una terra altrui» si soddisferebbe su una Regione
## vuota, cioe' senza togliere niente a nessuno — e sarebbe un altro punto
## regalato, che e' esattamente il difetto da cui nasce D-315.
func test_an_unheld_land_is_nobody_s_land() -> void:
	var me: String = _mine()
	var places: Array = _stage(me)
	var free_land: Dictionary = session.world["regions"][places[1]] as Dictionary
	free_land["control"] = ""
	(free_land["tags"] as Array).append(MARK)
	assert_true(_holds("$any", me), "$any deve vedere anche una terra di nessuno")
	assert_false(_holds("$rival", me), "$rival non deve contare una terra di nessuno")
