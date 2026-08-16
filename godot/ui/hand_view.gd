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

var _cards: Array = []


func _ready() -> void:
	add_theme_constant_override("separation", 6)


## `tension_id` empty means no Council is open: cards are drawn plain, because
## relevance has no meaning outside a question.
func render(session: RefCounted, viewer_id: String, tension_id: String = "") -> void:
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
