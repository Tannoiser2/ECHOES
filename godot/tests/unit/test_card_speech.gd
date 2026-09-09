extends "res://tests/test_case.gd"
## Una carta deve dire cosa fa, prima che la si cali.
##
## Il committente lo ha trovato giocando: «le carte che vengono giocate ora non
## si capisce quale effetto hanno, le frasi sono belle ma non si capiscono e
## alla fine non hanno effetti sul gioco». Gli effetti c'erano — 39 carte del
## Narratore su 39 ne portano almeno uno — ma la scelta al tavolo diceva solo
## «Cala la carta del Narratore: Mancanza», e una carta che non dichiara il
## proprio mestiere e' indistinguibile da una che non ne ha.
##
## Le carte Asset lo facevano gia' (D-042). Questi test tengono ferme le due
## cose che mancavano: le carte del Narratore parlano, e i segni della mappa si
## dicono in italiano invece che come identificativi.

const EffectText := preload("res://scripts/core/effect_text.gd")
const AssetText := preload("res://scripts/core/asset_text.gd")


func before_each() -> void:
	new_session()


## Nessun identificativo grezzo davanti a chi gioca.
func test_no_raw_identifiers_reach_the_table() -> void:
	var ugly: Array = []
	for card_id in data().assets:
		var note: String = AssetText.note(data().assets[card_id] as Dictionary, data())
		for mark in ["condition:", "structure:", "scar:", "$", "_TAG", "REG_", "TEN_", "ENT_"]:
			if note.contains(mark) and not ugly.has(str(card_id)):
				ugly.append(str(card_id))
	assert_eq(ugly.size(), 0, "carte che parlano in identificativi: %s" % str(ugly))


## I segni della mappa hanno una frase, e una frase diversa per quando spariscono.
func test_the_map_signs_have_words_both_ways() -> void:
	assert_eq(
		EffectText.tag_words("condition:starving"), "si muore di fame", "il segno detto a voce"
	)
	assert_eq(
		EffectText.tag_gone("condition:starving"), "la fame e' passata", "e quando finisce"
	)
	assert_ne(
		EffectText.tag_gone("structure:granary"),
		"non piu %s" % EffectText.tag_words("structure:granary"),
		"una struttura che cade non si dice col «non piu»"
	)


## Un segno che nessuno ha ancora tradotto non stampa mai l'identificativo cosi'
## com'e': si legge almeno come una frase.
func test_an_untranslated_sign_still_reads() -> void:
	assert_eq(EffectText.tag_words("debt_called"), "debt called", "gli underscore spariscono")
	assert_false(EffectText.tag_words("discovery:relic").contains("discovery:"), "il prefisso no")
	assert_true(EffectText.tag_words("discovery:relic").contains("Scoperta"), "e si dice cos'e'")


## Le caselle da riempire non arrivano mai al tavolo come `$rival`.
func test_slots_are_words_in_preview() -> void:
	for slot in ["$rival", "$proponent", "$region_focus"]:
		var said: String = EffectText.say(
			{
				"type": "REMOVE_PRESENCE",
				"target": {"kind": "entity", "id": slot},
				"payload": {"region_id": "$region_focus"},
			},
			data()
		)
		assert_false(said.contains("$"), "«%s» non arriva grezzo: %s" % [slot, said])
