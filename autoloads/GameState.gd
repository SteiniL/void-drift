# res://autoloads/GameState.gd
extends Node

const MAX_HP: int = 80
const BASE_ENERGY: int = 3
const MAX_HAND_SIZE: int = 8
const DECK_LIMIT: int = 30

var current_hp: int = MAX_HP
var max_hp: int = MAX_HP
var current_energy: int = BASE_ENERGY
var gold: int = 0
var sector: int = 1
var battles_won: int = 0

var deck: Array[CardData] = []
var relics: Array[RelicData] = []

var module_hp: Dictionary = {
	GameEnums.Module.REACTOR: 20,
	GameEnums.Module.WEAPONS: 20,
	GameEnums.Module.SHIELDS: 20,
	GameEnums.Module.THRUSTERS: 20,
}
var module_max_hp: Dictionary = {
	GameEnums.Module.REACTOR: 20,
	GameEnums.Module.WEAPONS: 20,
	GameEnums.Module.SHIELDS: 20,
	GameEnums.Module.THRUSTERS: 20,
}

func reset_energy() -> void:
	current_energy = BASE_ENERGY
	var reactor_hp: int = module_hp[GameEnums.Module.REACTOR]
	if reactor_hp <= 0:
		current_energy = max(1, BASE_ENERGY - 2)
	elif reactor_hp <= 10:
		current_energy = max(1, BASE_ENERGY - 1)

func spend_energy(amount: int) -> bool:
	if current_energy < amount:
		return false
	current_energy -= amount
	return true

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	if current_hp <= 0:
		EventBus.battle_lost.emit()

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)

func add_card_to_deck(card: CardData) -> void:
	if deck.size() < DECK_LIMIT:
		deck.append(card)

func start_new_run(starter_deck: Array[CardData]) -> void:
	current_hp = MAX_HP
	max_hp = MAX_HP
	current_energy = BASE_ENERGY
	gold = 0
	sector = 1
	battles_won = 0
	deck = starter_deck.duplicate()
	relics = []
	module_hp = {
		GameEnums.Module.REACTOR: 20,
		GameEnums.Module.WEAPONS: 20,
		GameEnums.Module.SHIELDS: 20,
		GameEnums.Module.THRUSTERS: 20,
	}
