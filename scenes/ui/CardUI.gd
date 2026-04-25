# res://scenes/ui/CardUI.gd
extends Control

signal card_selected(card: CardData)

var card_data: CardData
var is_hovered: bool = false
var is_selected: bool = false

@onready var name_label: Label = $VBox/NameLabel
@onready var cost_label: Label = $CostLabel
@onready var desc_label: Label = $VBox/DescLabel
@onready var type_label: Label = $VBox/TypeLabel
@onready var bg_panel: Panel = $BgPanel

const TYPE_COLORS: Dictionary = {
	GameEnums.CardType.ENERGY: Color(0.8, 0.3, 0.1),
	GameEnums.CardType.KINETIC: Color(0.6, 0.4, 0.1),
	GameEnums.CardType.HACK: Color(0.2, 0.7, 0.5),
	GameEnums.CardType.SHIELD: Color(0.2, 0.4, 0.9),
}

const TYPE_NAMES: Dictionary = {
	GameEnums.CardType.ENERGY: "ENERGY",
	GameEnums.CardType.KINETIC: "KINETIC",
	GameEnums.CardType.HACK: "HACK",
	GameEnums.CardType.SHIELD: "SHIELD",
}

func setup(data: CardData) -> void:
	card_data = data
	name_label.text = data.name
	cost_label.text = str(data.cost)
	desc_label.text = data.description
	type_label.text = TYPE_NAMES.get(data.type, "?")
	_apply_type_color()

func _apply_type_color() -> void:
	var color: Color = TYPE_COLORS.get(card_data.type, Color.WHITE)
	type_label.modulate = color

func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_visual()

func _update_visual() -> void:
	if is_selected:
		modulate = Color(1.5, 1.5, 0.8)
		bg_panel.modulate = Color(1.2, 1.2, 0.5)
	elif is_hovered:
		modulate = Color(1.3, 1.3, 1.3)
		bg_panel.modulate = Color.WHITE
	else:
		modulate = Color.WHITE
		bg_panel.modulate = Color.WHITE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_selected.emit(card_data)

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_visual()

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visual()
