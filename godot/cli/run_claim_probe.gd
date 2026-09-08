extends SceneTree
## **La moneta del RIVENDICARE, e quanto costerebbe usarla** (ISSUES 129,
## parola del committente: *«il Rivendicare dovrebbe sempre dare i gettoni con
## cui "comprare" benefici e costi»*).
##
##   godot --headless --path godot --script res://cli/run_claim_probe.gd -- --runs=100
##
## La faccia RIVENDICARE conia un gettone (D-387), e da [D-472](../../docs/DECISIONS.md#d-472)
## **nessuno lo spende**: il Consiglio a due domande conta il prezzo per parte,
## e il gettone non entra da nessuna parte. Rimettergli un uso e' una decisione
## presa; **a che cambio** e' una taratura, e una taratura si misura prima.
##
## Le tre cose che decidono il cambio, e questa sonda le conta insieme perche'
## e' il loro rapporto a contare, non i tre numeri separati:
##
##   1. **quanti gettoni si coniano** in un anno, su tutto il tavolo;
##   2. **quanti Consigli** si tengono in quell'anno;
##   3. **quante pedine** le due parti posano su quei Consigli.
##
## Se le pedine sono molte piu' dei gettoni, far pagare **ogni** pedina un
## gettone non e' un'economia: e' un Consiglio spento. Il numero che si cerca e'
## quante pedine un gettone deve comprare perche' il tavolo resti pieno.
##
## Nessuna regola cambia: la sonda gioca le partite come sono e conta. I gettoni
## non si spendono, quindi quelli in mano a fine anno **sono** quelli coniati.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

var boxes: int = 0
var sides: int = 0


## Un cane da guardia che conta le pedine posate, senza decidere niente: la
## stessa forma dello `Spy` di `run_boxes_probe`.
class Spy extends RefCounted:
	var inner: RefCounted
	var owner: Object

	func _init(who: RefCounted, p_owner: Object) -> void:
		inner = who
		owner = p_owner

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		return await inner.choose_action(entity_id, ao_index, session)

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_question(context, options, session)

	## Prendere posizione posa la prima pedina della parte (D-471).
	func choose_side(entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted) -> Dictionary:
		var choice: Dictionary = await inner.choose_side(entity_id, context, offer, session)
		if str(choice.get("voice_id", "")) != "":
			owner.set("boxes", int(owner.get("boxes")) + 1)
		owner.set("sides", int(owner.get("sides")) + 1)
		return choice

	func choose_box(entity_id: String, context: Dictionary, menu: Array, side: String, session: RefCounted) -> String:
		var picked: String = await inner.choose_box(entity_id, context, menu, side, session)
		if picked != "":
			owner.set("boxes", int(owner.get("boxes")) + 1)
		return picked

	func choose_raise(entity_id: String, context: Dictionary, menu: Array, session: RefCounted) -> String:
		var picked: String = await inner.choose_raise(entity_id, context, menu, session)
		if picked != "":
			owner.set("boxes", int(owner.get("boxes")) + 1)
		return picked

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		return await inner.choose_commit(entity_id, context, limit, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return await inner.choose_recovery(context, session)


func _initialize() -> void:
	var runs: int = 100
	var first: int = 7000
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--runs="):
			runs = int(a.substr(7))
		elif a.begins_with("--seed="):
			first = int(a.substr(7))
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for e in data.errors:
			printerr("  %s" % e)
		quit(3)
		return

	var minted: int = 0
	var councils: int = 0
	var years_without: int = 0
	var most: int = 0
	for run in range(runs):
		var seed_value: int = first + run
		var seats: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup("CHR_00", seats, seed_value):
			printerr(session.last_error)
			quit(3)
			return
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		var brain: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		await session.run(Spy.new(brain, self))
		councils += int(session.world.get("confluence_count", 0))
		# Nessuno li spende: quelli in mano a fine anno sono quelli coniati.
		var year: int = 0
		for entity_id in session.world["entities"]:
			year += int((session.world["entities"][entity_id] as Dictionary).get("claim_tokens", 0))
		minted += year
		if year == 0:
			years_without += 1
		most = maxi(most, year)

	print("LA MONETA DEL RIVENDICARE - %d anni, semi da %d" % [runs, first])
	print("")
	print("  gettoni coniati        %d   (%.2f l'anno su tutto il tavolo)" % [
		minted, float(minted) / float(runs)
	])
	print("  anni senza un gettone  %d su %d" % [years_without, runs])
	print("  l'anno piu' ricco      %d gettoni" % most)
	print("")
	print("  Consigli tenuti        %d   (%.2f l'anno)" % [
		councils, float(councils) / float(runs)
	])
	print("  pedine posate          %d   (%.2f l'anno, %.2f per Consiglio)" % [
		boxes, float(boxes) / float(runs),
		0.0 if councils == 0 else float(boxes) / float(councils),
	])
	print("  posizioni prese        %d" % sides)
	print("")
	if minted == 0:
		print("  IL CAMBIO: nessun gettone coniato. Se una pedina ne costasse uno,")
		print("  il Consiglio non poserebbe niente.")
	else:
		print("  IL CAMBIO: un gettone dovrebbe comprare %.1f pedine perche' il" % (
			float(boxes) / float(minted)
		))
		print("  tavolo resti pieno come adesso.")
	quit(0)
