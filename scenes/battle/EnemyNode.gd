# res://scenes/battle/EnemyNode.gd
extends VBoxContainer

@onready var name_label: Label = $NameLabel
@onready var hp_label: Label = $HPLabel
@onready var block_label: Label = $BlockLabel
@onready var intent_label: Label = $IntentLabel
@onready var sprite_rect: ColorRect = $SpriteRect

var status_label: Label

func _ready() -> void:
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.modulate = Color(1.0, 0.6, 0.2)
	add_child(status_label)

func update_display(hp: int, block: int, data: EnemyData, status: Dictionary = {}) -> void:
	name_label.text = data.display_name
	hp_label.text = "HP: %d / %d" % [hp, data.max_hp]
	block_label.text = "Block: %d" % block
	block_label.visible = block > 0
	_update_status_label(status)

func show_intent_text(text: String) -> void:
	intent_label.text = "Intent: %s" % text

func show_intent(data: EnemyData) -> void:
	intent_label.text = "Intent: %s" % data.intent_description

func _update_status_label(status: Dictionary) -> void:
	if status.is_empty():
		status_label.text = ""
		return
	var parts: Array[String] = []
	for effect in status:
		var key: String = GameEnums.StatusEffect.keys()[effect]
		parts.append("%s:%d" % [key.left(3), status[effect]])
	status_label.text = " ".join(parts)
