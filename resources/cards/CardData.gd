# res://resources/cards/CardData.gd
class_name CardData
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var cost: int = 1
@export var type: GameEnums.CardType = GameEnums.CardType.ENERGY
@export var rarity: GameEnums.Rarity = GameEnums.Rarity.COMMON
@export var damage: int = 0
@export var block: int = 0
@export var draw: int = 0
@export var status_effect: GameEnums.StatusEffect = GameEnums.StatusEffect.NONE
@export var status_stacks: int = 0
@export var upgraded: bool = false
@export var sprite: Texture2D

func duplicate_card() -> CardData:
	var copy := CardData.new()
	copy.id = id
	copy.name = name
	copy.description = description
	copy.cost = cost
	copy.type = type
	copy.rarity = rarity
	copy.damage = damage
	copy.block = block
	copy.draw = draw
	copy.status_effect = status_effect
	copy.status_stacks = status_stacks
	copy.upgraded = upgraded
	copy.sprite = sprite
	return copy
