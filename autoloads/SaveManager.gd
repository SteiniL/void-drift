# res://autoloads/SaveManager.gd
extends Node

const SAVE_PATH: String = "user://save_data.json"

var meta: Dictionary = {
	"runs_completed": 0,
	"total_gold_earned": 0,
	"unlocked_relics": [],
	"ascension_level": 0,
}

func save_meta() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(meta))

func load_meta() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			meta.merge(parsed, true)
