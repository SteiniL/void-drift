# res://resources/enemies/EnemyData.gd
class_name EnemyData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 30
@export var damage: int = 8
@export var block: int = 0
@export var intent_description: String = "Attack"
@export var sprite: Texture2D
@export var actions: Array[EnemyAction] = []
