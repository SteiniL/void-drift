# res://autoloads/DeckManager.gd
extends Node

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []
var exhaust_pile: Array[CardData] = []

func setup_battle() -> void:
	draw_pile = GameState.deck.duplicate()
	draw_pile.shuffle()
	hand = []
	discard_pile = []
	exhaust_pile = []

func draw_cards(count: int) -> void:
	for i in count:
		if hand.size() >= GameState.MAX_HAND_SIZE:
			break
		if draw_pile.is_empty():
			_reshuffle_discard()
		if draw_pile.is_empty():
			break
		var card: CardData = draw_pile.pop_back()
		hand.append(card)
		EventBus.card_drawn.emit(card)

func _reshuffle_discard() -> void:
	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()
	discard_pile = []

func play_card(card: CardData) -> bool:
	if not hand.has(card):
		return false
	if not GameState.spend_energy(card.cost):
		return false
	hand.erase(card)
	discard_pile.append(card)
	EventBus.card_played.emit(card)
	return true

func discard_hand() -> void:
	for card in hand:
		discard_pile.append(card)
	hand = []

func exhaust_card(card: CardData) -> void:
	hand.erase(card)
	discard_pile.erase(card)
	exhaust_pile.append(card)
