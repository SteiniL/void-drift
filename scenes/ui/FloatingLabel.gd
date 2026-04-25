# res://scenes/ui/FloatingLabel.gd
class_name FloatingLabel
extends Label

func spawn(text_val: String, pos: Vector2, color: Color) -> void:
	text = text_val
	position = pos
	modulate = color
	add_theme_font_size_override("font_size", 22)
	var tween := create_tween()
	tween.tween_property(self, "position:y", pos.y - 50.0, 0.7)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.7)
	tween.chain().tween_callback(queue_free)
