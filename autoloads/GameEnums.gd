# res://autoloads/GameEnums.gd
extends Node

enum CardType { ENERGY, KINETIC, HACK, SHIELD }

enum StatusEffect { NONE, BURN, SHIELD_UP, OVERLOAD, JAMMED, EXPOSED }

enum Rarity { COMMON, UNCOMMON, RARE }

enum NodeType { COMBAT, ELITE, MERCHANT, EVENT, REST, BOSS }

enum Module { REACTOR, WEAPONS, SHIELDS, THRUSTERS }

enum Condition { NONE, ENEMY_HAS_BURN, ENEMY_HAS_EXPOSED }

enum ScaleTarget { NONE, HAND_SIZE }
