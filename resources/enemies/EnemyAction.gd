# res://resources/enemies/EnemyAction.gd
class_name EnemyAction
extends Resource

@export var damage: int = 0
@export var block: int = 0
@export var status_effect: GameEnums.StatusEffect = GameEnums.StatusEffect.NONE
@export var status_stacks: int = 0
@export var description: String = "Attack"
