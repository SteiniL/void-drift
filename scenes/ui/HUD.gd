# res://scenes/ui/HUD.gd
extends CanvasLayer

@onready var hp_label: Label = $MarginContainer/HBox/HPLabel
@onready var energy_label: Label = $MarginContainer/HBox/EnergyLabel
@onready var draw_label: Label = $MarginContainer/HBox/DrawLabel
@onready var discard_label: Label = $MarginContainer/HBox/DiscardLabel
@onready var block_label: Label = $MarginContainer/HBox/BlockLabel
@onready var turn_label: Label = $TurnLabel

var status_label: Label
var preview_label: Label
var play_button: Button
var current_preview: Dictionary = {}

func _ready() -> void:
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.modulate = Color(1.0, 0.4, 0.4)
	$MarginContainer/HBox.add_child(status_label)

	preview_label = Label.new()
	preview_label.add_theme_font_size_override("font_size", 14)
	preview_label.modulate = Color(0.7, 1.0, 0.7)
	add_child(preview_label)
	preview_label.position = Vector2(10, 50)

	play_button = Button.new()
	play_button.text = "PLAY [P]"
	play_button.custom_minimum_size = Vector2(100, 40)
	play_button.disabled = true
	add_child(play_button)
	play_button.position = Vector2(10, 100)
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	if current_preview.is_empty() or !current_preview.get("affordable", false):
		return
	var battle_scene: Node = get_parent()
	if battle_scene and battle_scene.has_method("play_selected_cards"):
		var selected_cards: Array[CardData] = []
		for card in DeckManager.hand:
			var card_ui = battle_scene.card_hand.card_ui_map.get(card)
			if card_ui and card_ui.is_selected:
				selected_cards.append(card)
		battle_scene.play_selected_cards(selected_cards)

func update_all(player_block: int = 0, turn: int = 1, player_status: Dictionary = {}) -> void:
	hp_label.text = "HP: %d/%d" % [GameState.current_hp, GameState.max_hp]
	energy_label.text = "Energy: %d/%d" % [GameState.current_energy, GameState.BASE_ENERGY]
	draw_label.text = "Draw: %d" % DeckManager.draw_pile.size()
	discard_label.text = "Disc: %d" % DeckManager.discard_pile.size()
	block_label.text = "Block: %d" % player_block
	turn_label.text = "Turn %d" % turn
	_update_status(player_status)

func update_preview(preview: Dictionary) -> void:
	current_preview = preview
	var lines: Array[String] = []

	if preview.get("cost", 0) > 0:
		var cost_str: String = "Cost: %d/%d" % [preview.cost, GameState.current_energy]
		lines.append(cost_str)

	if preview.get("damage", 0) > 0:
		lines.append("Dmg: %d" % preview.damage)

	if preview.get("block", 0) > 0:
		lines.append("Blk: %d" % preview.block)

	if preview.get("draw", 0) > 0:
		lines.append("Draw: %d" % preview.draw)

	if preview.get("drift_level", 0) > 0:
		lines.append("DRIFT %d" % preview.drift_level)

	if not preview.get("status_effects", {}).is_empty():
		var effects: Array[String] = []
		for effect in preview.status_effects:
			var key: String = GameEnums.StatusEffect.keys()[effect]
			effects.append("%s:%d" % [key.left(3), preview.status_effects[effect]])
		lines.append("Eff: " + ", ".join(effects))

	if lines.is_empty():
		preview_label.text = ""
		play_button.disabled = true
	else:
		preview_label.text = " | ".join(lines)
		play_button.disabled = !preview.get("affordable", false)

func _update_status(status: Dictionary) -> void:
	if status.is_empty():
		status_label.text = ""
		return
	var parts: Array[String] = []
	for effect in status:
		var key: String = GameEnums.StatusEffect.keys()[effect]
		parts.append("%s:%d" % [key.left(3), status[effect]])
	status_label.text = "| " + " ".join(parts)
