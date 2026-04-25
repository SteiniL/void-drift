# res://scenes/battle/DriftIndicator.gd
extends VBoxContainer

const TYPE_NAMES: Dictionary = {
	GameEnums.CardType.ENERGY: "ENERGY",
	GameEnums.CardType.KINETIC: "KINETIC",
	GameEnums.CardType.HACK: "HACK",
	GameEnums.CardType.SHIELD: "SHIELD",
}

const DRIFT_COLORS: Array[Color] = [
	Color.WHITE,
	Color(1.0, 0.8, 0.2),
	Color(1.0, 0.5, 0.0),
	Color(1.0, 0.1, 0.8),
]

@onready var type_label: Label = $TypeLabel
@onready var count_label: Label = $CountLabel
@onready var drift_label: Label = $DriftLabel

func reset() -> void:
	type_label.text = ""
	count_label.text = ""
	drift_label.text = ""
	modulate = Color.WHITE

func update_drift(type: GameEnums.CardType, count: int, level: int) -> void:
	if count == 0:
		reset()
		return

	type_label.text = TYPE_NAMES.get(type, "?")
	count_label.text = "x%d" % count

	match level:
		0: drift_label.text = "%d/3 to DRIFT I" % count
		1: drift_label.text = "DRIFT I — x1.5"
		2: drift_label.text = "DRIFT II — x2.5"
		3: drift_label.text = "DRIFT III — x4 !!!"

	modulate = DRIFT_COLORS[level]
