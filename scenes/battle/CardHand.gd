# res://scenes/battle/CardHand.gd
extends HBoxContainer

signal card_selection_changed(selected_cards: Array[CardData])

const CardUIScene: PackedScene = preload("res://scenes/ui/CardUI.tscn")

var card_ui_map: Dictionary = {}

func _ready() -> void:
	EventBus.card_drawn.connect(_on_card_drawn)
	EventBus.turn_ended.connect(_clear_hand)

func _on_card_drawn(_card: CardData) -> void:
	_rebuild_hand()

func _rebuild_hand() -> void:
	for child in get_children():
		child.queue_free()
	card_ui_map.clear()
	for card in DeckManager.hand:
		var card_ui: Control = CardUIScene.instantiate()
		add_child(card_ui)
		card_ui.setup(card)
		card_ui_map[card] = card_ui
		card_ui.card_selected.connect(_on_card_selected)

func _on_card_selected(card: CardData) -> void:
	var card_ui: Control = card_ui_map[card]
	card_ui.set_selected(!card_ui.is_selected)
	_emit_selection_changed()

func _emit_selection_changed() -> void:
	var selected: Array[CardData] = []
	for card in card_ui_map:
		if card_ui_map[card].is_selected:
			selected.append(card)
	card_selection_changed.emit(selected)

func clear_selection() -> void:
	for card in card_ui_map:
		card_ui_map[card].set_selected(false)
	_emit_selection_changed()

func _clear_hand() -> void:
	for child in get_children():
		child.queue_free()
	card_ui_map.clear()
