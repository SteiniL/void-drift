# res://autoloads/EventBus.gd
extends Node

signal card_played(card: CardData)
signal card_drawn(card: CardData)
signal turn_ended
signal enemy_turn_started
signal damage_dealt(target: String, amount: int)
signal status_applied(target: String, effect: GameEnums.StatusEffect, stacks: int)
signal drift_triggered(type: GameEnums.CardType, level: int)
signal battle_won(enemy: EnemyData)
signal battle_lost
signal relic_acquired(relic: RelicData)
signal map_node_selected(node_type: String)
signal run_ended(victory: bool)
