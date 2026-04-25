# res://scenes/ui/CardRewardOverlay.gd
class_name CardRewardOverlay
extends Control

signal card_chosen(card: CardData)
signal closed()

const CardUIScene = preload("res://scenes/ui/CardUI.tscn")

func setup(cards: Array[CardData]) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.1, 0.82)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(700, 320)
	vbox.position = -vbox.custom_minimum_size / 2.0
	add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Card"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)

	for card_data in cards:
		var card_ui := CardUIScene.instantiate()
		hbox.add_child(card_ui)
		card_ui.setup(card_data)
		card_ui.card_selected.connect(_on_card_selected)

	var skip_btn := Button.new()
	skip_btn.text = "Skip"
	skip_btn.custom_minimum_size = Vector2(120, 36)
	skip_btn.pressed.connect(_on_skip_pressed)
	vbox.add_child(skip_btn)

func _on_card_selected(card: CardData) -> void:
	card_chosen.emit(card)
	closed.emit()
	queue_free()

func _on_skip_pressed() -> void:
	closed.emit()
	queue_free()
