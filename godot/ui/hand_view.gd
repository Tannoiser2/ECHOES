extends HBoxContainer
## The seat's hand, as cards rather than a comma-separated list.
##
## An Asset is worth its **full strength** in a Tension that finds its family
## relevant, and **1** otherwise (§9). That is the single fact a player needs
## when deciding what to commit, so a card carries its family colour and, when a
## Council is open, what it is worth in *that* question.
##
## 0.1.1 drew that as "forza 2 ×2 = 4", which is not the rule: relevance does not
## double anything, it is the difference between counting for what you are and
## counting for one. The card was telling a player their hand was worth twice
## what the resolver would give them (D-040).
##
## The card itself is `ui/asset_card.gd` - it knows how to draw itself and what
## to say under the cursor. This just decides which cards are in the row.

const AssetCard := preload("res://ui/asset_card.gd")
const CardArt := preload("res://ui/card_art.gd")

var _cards: Array = []


func _ready() -> void:
	add_theme_constant_override("separation", 6)


## `tension_id` empty means no Council is open: cards are drawn plain, because
## relevance has no meaning outside a question.
## `offers` lega ogni carta alle scelte che porta adesso: `asset_id ->
## [{region, index}]`. Vuoto quando non si sta chiedendo un'azione, e allora le
## carte si guardano e basta. **E' quello che le rende trascinabili** (D-230):
## una carta senza offerte non si puo' prendere, esattamente come una Regione
## senza cerchio d'oro non si puo' cliccare.
## Una carta della mano e' stata scelta col clic (D-238).
signal card_chosen(asset_id: String)

## Quale carta e' in mano adesso, o "": la si vede alzata rispetto alle altre.
var _held: String = ""


## Alza la carta scelta e riabbassa le altre (D-239). Prendere in mano una carta
## deve **vedersi**, altrimenti i posti accesi sul tavolo sembrano accendersi da
## soli e non si capisce cosa si sta per fare.
func hold(asset_id: String) -> void:
	_held = asset_id
	for card in _cards:
		if card.has_method("set_held"):
			card.call("set_held", str(card.get("asset").get("id", "")) == asset_id)


func render(
	session: RefCounted, viewer_id: String, tension_id: String = "",
	offers: Dictionary = {}
) -> void:
	for card in _cards:
		card.queue_free()
		remove_child(card)
	_cards.clear()
	if viewer_id == "":
		return

	var relevant: Array = []
	var council_open: bool = tension_id != "" and session.world["tensions"].has(tension_id)
	if council_open:
		relevant = session.data.tensions[tension_id]["relevant_asset_families"]

	for asset_id in session.service.hand(viewer_id):
		var asset: Variant = session.data.assets.get(str(asset_id))
		if asset == null:
			continue
		var card: PanelContainer = AssetCard.new()
		_cards.append(card)
		add_child(card)
		card.render(asset, relevant, council_open, session.data)
		card.offers = offers.get(str(asset_id), [])
		# **Quando qualcosa si puo' giocare, quello che non si puo' si spegne**
		# (D-281). La carta da sola non lo sa — sa solo cosa porta lei — e il
		# contesto ce l'ha soltanto la mano: fuori da una domanda le carte si
		# guardano tutte uguali, dentro una domanda la differenza fra «adesso
		# questa parla» e «questa no» e' l'unica cosa che serve vedere.
		card.modulate = Color(1, 1, 1, 1.0 if (
			offers.is_empty() or not (card.offers as Array).is_empty()
		) else 0.5)
		card.chosen.connect(func(chosen_id: String) -> void: card_chosen.emit(chosen_id))
		card.set_held(str(asset_id) == _held)

	# La mano del Narratore (ISSUES 23, D-118): le carte di Propp accanto agli
	# Asset, spente quando la storia non le accetta ancora - il motivo sta
	# sotto il cursore. Il bottone per calarle arriva dal SeatDecider, lo
	# stesso del terminale: qui si mostra soltanto cosa si ha in mano.
	var echo_hand: Array = (session.world["entities"].get(viewer_id, {}) as Dictionary).get("echo_hand", [])
	for card_id in echo_hand:
		var echo: Variant = session.data.echo_cards.get(str(card_id))
		if echo == null:
			continue
		var picture := TextureRect.new()
		picture.texture = CardArt.texture_for("echo", str(card_id), session.data)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.custom_minimum_size = Vector2(70.0, 120.0)
		var refusal: String = session.actions.check(
			viewer_id, "PLAY_ECHO", {"echo_card_id": str(card_id)}
		)
		picture.modulate = Color(1, 1, 1, 1.0 if refusal == "" else 0.45)
		picture.tooltip_text = "%s\n%s%s" % [
			str(echo["title"]), str(echo["description"]),
			"" if refusal == "" else "\n(non calabile: %s)" % refusal,
		]
		_cards.append(picture)
		add_child(picture)
