# res://scenes/battle/BattleScene.gd
extends Node2D

const DRAW_PER_TURN: int = 5
const DRIFT_THRESHOLDS: Array[int] = [3, 4, 5]
const FloatingLabelScene = preload("res://scenes/ui/FloatingLabel.gd")

var enemy_data: EnemyData
var enemy_hp: int
var enemy_block: int = 0
var player_block: int = 0
var action_index: int = 0

# Status effect stacks: StatusEffect -> int
var enemy_status: Dictionary = {}
var player_status: Dictionary = {}

var cards_played_this_turn: Array[CardData] = []
var turn_number: int = 0
var battle_over: bool = false

@onready var card_hand: Node = $CardHand
@onready var hud: Node = $HUD
@onready var enemy_node: Node = $EnemyNode
@onready var drift_indicator: Node = $DriftIndicator
@onready var end_turn_button: Button = $HUD/EndTurnButton

func _ready() -> void:
	EventBus.battle_lost.connect(_on_battle_lost)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	card_hand.card_selection_changed.connect(_on_card_selection_changed)
	_start_battle()

func setup(data: EnemyData) -> void:
	enemy_data = data
	enemy_hp = data.max_hp
	enemy_block = 0

func _start_battle() -> void:
	if GameState.deck.is_empty():
		GameState.start_new_run(StarterDeck.create())
	if not enemy_data:
		enemy_data = EnemyFactory.create_random_common()
		enemy_hp = enemy_data.max_hp
	DeckManager.setup_battle()
	action_index = 0
	enemy_node.update_display(enemy_hp, enemy_block, enemy_data, enemy_status)
	_refresh_intent()
	_start_player_turn()

func _refresh_intent() -> void:
	if enemy_data.actions.is_empty():
		enemy_node.show_intent_text(enemy_data.intent_description)
		return
	var action: EnemyAction = enemy_data.actions[action_index % enemy_data.actions.size()]
	enemy_node.show_intent_text(action.description)

func _start_player_turn() -> void:
	turn_number += 1
	cards_played_this_turn = []
	player_block = 0
	GameState.reset_energy()

	# JAMMED: lose energy equal to stacks, then decay
	var jammed: int = player_status.get(GameEnums.StatusEffect.JAMMED, 0)
	if jammed > 0:
		GameState.current_energy = max(0, GameState.current_energy - jammed)
		_decay_status(player_status, GameEnums.StatusEffect.JAMMED)

	# BURN: take damage equal to stacks, then decay
	var burn: int = player_status.get(GameEnums.StatusEffect.BURN, 0)
	if burn > 0:
		GameState.take_damage(burn)
		_spawn_float("BURN -%d" % burn, Vector2(120, 80), Color(1.0, 0.5, 0.1))
		_decay_status(player_status, GameEnums.StatusEffect.BURN)

	# SHIELD_UP: gain block equal to stacks, then decay
	var shield_up: int = player_status.get(GameEnums.StatusEffect.SHIELD_UP, 0)
	if shield_up > 0:
		player_block += shield_up
		_decay_status(player_status, GameEnums.StatusEffect.SHIELD_UP)

	# OVERLOAD: take stacks damage, gain stacks energy (risk/reward), then decay
	var overload: int = player_status.get(GameEnums.StatusEffect.OVERLOAD, 0)
	if overload > 0:
		GameState.take_damage(overload)
		GameState.current_energy += overload
		_decay_status(player_status, GameEnums.StatusEffect.OVERLOAD)

	DeckManager.draw_cards(DRAW_PER_TURN)
	drift_indicator.reset()
	_refresh_hud()

func _on_card_selection_changed(selected_cards: Array[CardData]) -> void:
	if battle_over:
		return
	var preview: Dictionary = _calculate_preview(selected_cards)
	hud.update_preview(preview)

func _calculate_preview(selected_cards: Array[CardData]) -> Dictionary:
	var total_cost: int = 0
	var total_damage: int = 0
	var total_block: int = 0
	var total_draw: int = 0
	var status_effects: Dictionary = {}
	var damage_cards: int = 0

	# Sum up all card values
	for card in selected_cards:
		total_cost += card.cost
		if card.damage > 0 and _check_card_condition(card):
			var card_dmg: int = card.damage
			if card.scale_by == GameEnums.ScaleTarget.HAND_SIZE:
				card_dmg = card.damage * DeckManager.hand.size()
			total_damage += card_dmg * card.hits
			damage_cards += 1
		total_block += card.block
		total_draw += card.draw
		if card.status_effect != GameEnums.StatusEffect.NONE and card.status_stacks > 0:
			status_effects[card.status_effect] = status_effects.get(card.status_effect, 0) + card.status_stacks

	# Apply module damage modifiers
	if GameState.module_hp[GameEnums.Module.WEAPONS] <= 0:
		total_damage = max(0, total_damage - 1)

	# Check for EXPOSED bonus (each damage card gets +2 per stack)
	var exposed: int = enemy_status.get(GameEnums.StatusEffect.EXPOSED, 0)
	total_damage += exposed * 2 * damage_cards

	# Check for drift bonus
	var drift_info: Dictionary = _calculate_drift(selected_cards)
	var drift_damage: int = 0
	if drift_info.level > 0:
		match drift_info.level:
			1: drift_damage = 3
			2: drift_damage = 6
			3: drift_damage = 12
	total_damage += drift_damage

	# Check shields module
	if GameState.module_hp[GameEnums.Module.SHIELDS] <= 0:
		total_block = max(0, total_block - 2)

	return {
		"cost": total_cost,
		"damage": total_damage,
		"block": total_block,
		"draw": total_draw,
		"status_effects": status_effects,
		"drift_level": drift_info.level,
		"drift_type": drift_info.type,
		"affordable": total_cost <= GameState.current_energy
	}

func _calculate_drift(selected_cards: Array[CardData]) -> Dictionary:
	var type_counts: Dictionary = {}
	for card in selected_cards:
		var t: GameEnums.CardType = card.type
		type_counts[t] = type_counts.get(t, 0) + 1

	var best_type: GameEnums.CardType = GameEnums.CardType.ENERGY
	var best_count: int = 0
	for t in type_counts:
		if type_counts[t] > best_count:
			best_count = type_counts[t]
			best_type = t

	var drift_level: int = 0
	if best_count >= 5:
		drift_level = 3
	elif best_count >= 4:
		drift_level = 2
	elif best_count >= 3:
		drift_level = 1

	return {"level": drift_level, "type": best_type}

func play_selected_cards(selected_cards: Array[CardData]) -> void:
	if battle_over or selected_cards.is_empty():
		return

	var total_cost: int = 0
	for card in selected_cards:
		total_cost += card.cost

	if total_cost > GameState.current_energy or !GameState.spend_energy(total_cost):
		return

	# Apply all cards and move to discard
	for card in selected_cards:
		cards_played_this_turn.append(card)
		_apply_card_effects(card)
		DeckManager.hand.erase(card)
		DeckManager.discard_pile.append(card)

	# Check final drift
	_check_drift()

	# Clear selection and rebuild hand display
	card_hand.clear_selection()
	card_hand._rebuild_hand()
	_refresh_hud()

func _check_card_condition(card: CardData) -> bool:
	match card.condition:
		GameEnums.Condition.ENEMY_HAS_BURN:
			return enemy_status.get(GameEnums.StatusEffect.BURN, 0) > 0
		GameEnums.Condition.ENEMY_HAS_EXPOSED:
			return enemy_status.get(GameEnums.StatusEffect.EXPOSED, 0) > 0
	return true

func _apply_card_effects(card: CardData) -> void:
	var weapon_damaged: bool = GameState.module_hp[GameEnums.Module.WEAPONS] <= 0
	var base_dmg: int = card.damage

	# ScaleTarget: multiply base damage by hand size
	if card.scale_by == GameEnums.ScaleTarget.HAND_SIZE:
		base_dmg = card.damage * DeckManager.hand.size()

	if weapon_damaged:
		base_dmg = max(0, base_dmg - 1)

	if base_dmg > 0 and _check_card_condition(card):
		for _i in range(card.hits):
			var exposed: int = enemy_status.get(GameEnums.StatusEffect.EXPOSED, 0)
			var hit_dmg: int = base_dmg + exposed * 2
			_deal_damage_to_enemy(hit_dmg)
			if battle_over:
				return

	if card.self_damage > 0:
		GameState.take_damage(card.self_damage)

	if card.block > 0:
		var shields_damaged: bool = GameState.module_hp[GameEnums.Module.SHIELDS] <= 0
		var block_gain: int = card.block
		if shields_damaged:
			block_gain = max(0, block_gain - 2)
		player_block += block_gain

	if card.draw > 0:
		DeckManager.draw_cards(card.draw)

	if card.status_effect != GameEnums.StatusEffect.NONE and card.status_stacks > 0:
		enemy_status[card.status_effect] = enemy_status.get(card.status_effect, 0) + card.status_stacks
		EventBus.status_applied.emit("enemy", card.status_effect, card.status_stacks)
		enemy_node.update_display(enemy_hp, enemy_block, enemy_data, enemy_status)

func _deal_damage_to_enemy(dmg: int) -> void:
	var absorbed: int = min(enemy_block, dmg)
	enemy_block = max(0, enemy_block - absorbed)
	var remaining: int = dmg - absorbed
	enemy_hp = max(0, enemy_hp - remaining)
	EventBus.damage_dealt.emit("enemy", remaining)
	if remaining > 0:
		_spawn_float("-%d" % remaining, enemy_node.position + Vector2(20, -60), Color(1.0, 0.3, 0.3))
	enemy_node.update_display(enemy_hp, enemy_block, enemy_data, enemy_status)
	if enemy_hp <= 0:
		_on_battle_won()

func _check_drift() -> void:
	var type_counts: Dictionary = {}
	for played_card in cards_played_this_turn:
		var t: GameEnums.CardType = played_card.type
		type_counts[t] = type_counts.get(t, 0) + 1

	var best_type: GameEnums.CardType = GameEnums.CardType.ENERGY
	var best_count: int = 0
	for t in type_counts:
		if type_counts[t] > best_count:
			best_count = type_counts[t]
			best_type = t

	var drift_level: int = 0
	if best_count >= 5:
		drift_level = 3
	elif best_count >= 4:
		drift_level = 2
	elif best_count >= 3:
		drift_level = 1

	drift_indicator.update_drift(best_type, best_count, drift_level)

	if drift_level > 0 and best_count == DRIFT_THRESHOLDS[drift_level - 1]:
		_apply_drift_bonus(best_type, drift_level)
		EventBus.drift_triggered.emit(best_type, drift_level)

func _apply_drift_bonus(type: GameEnums.CardType, level: int) -> void:
	var bonus_dmg: int = 0
	match level:
		1: bonus_dmg = 3
		2: bonus_dmg = 6
		3: bonus_dmg = 12

	if bonus_dmg > 0:
		_deal_damage_to_enemy(bonus_dmg)
		var vp_center := get_viewport_rect().size / 2.0
		_spawn_float("DRIFT +%d!" % bonus_dmg, vp_center + Vector2(-40, 0), Color(1.0, 0.85, 0.0))

func _on_end_turn_pressed() -> void:
	if battle_over:
		return
	EventBus.turn_ended.emit()
	DeckManager.discard_hand()
	_enemy_turn()

func _enemy_turn() -> void:
	EventBus.enemy_turn_started.emit()

	# BURN on enemy triggers at start of their turn
	var burn: int = enemy_status.get(GameEnums.StatusEffect.BURN, 0)
	if burn > 0:
		enemy_hp = max(0, enemy_hp - burn)
		EventBus.damage_dealt.emit("enemy", burn)
		_spawn_float("BURN -%d" % burn, enemy_node.position + Vector2(20, -60), Color(1.0, 0.5, 0.1))
		_decay_status(enemy_status, GameEnums.StatusEffect.BURN)
		enemy_node.update_display(enemy_hp, enemy_block, enemy_data, enemy_status)
		if enemy_hp <= 0:
			_on_battle_won()
			return

	# EXPOSED decays at start of enemy turn
	if enemy_status.get(GameEnums.StatusEffect.EXPOSED, 0) > 0:
		_decay_status(enemy_status, GameEnums.StatusEffect.EXPOSED)

	# Enemy block resets each turn (same as player block)
	enemy_block = 0

	# Execute current action
	if not enemy_data.actions.is_empty():
		_execute_enemy_action()
	else:
		_deal_player_damage(enemy_data.damage)

	action_index = (action_index + 1) % enemy_data.actions.size() if not enemy_data.actions.is_empty() else 0

	if not battle_over:
		enemy_node.update_display(enemy_hp, enemy_block, enemy_data, enemy_status)
		_refresh_intent()
		_start_player_turn()

func _execute_enemy_action() -> void:
	var action: EnemyAction = enemy_data.actions[action_index % enemy_data.actions.size()]

	if action.block > 0:
		enemy_block += action.block

	if action.damage > 0:
		_deal_player_damage(action.damage)

	if action.status_effect != GameEnums.StatusEffect.NONE and action.status_stacks > 0:
		player_status[action.status_effect] = player_status.get(action.status_effect, 0) + action.status_stacks
		EventBus.status_applied.emit("player", action.status_effect, action.status_stacks)

func _deal_player_damage(dmg: int) -> void:
	var absorbed: int = min(player_block, dmg)
	var remaining: int = dmg - absorbed
	player_block = max(0, player_block - absorbed)
	if remaining > 0:
		GameState.take_damage(remaining)
		_spawn_float("-%d" % remaining, Vector2(120, 80), Color(1.0, 0.3, 0.3))

func _decay_status(status_dict: Dictionary, effect: GameEnums.StatusEffect) -> void:
	if status_dict.has(effect):
		status_dict[effect] -= 1
		if status_dict[effect] <= 0:
			status_dict.erase(effect)

func _spawn_float(text: String, pos: Vector2, color: Color) -> void:
	var label := FloatingLabelScene.new()
	add_child(label)
	label.spawn(text, pos, color)

func _refresh_hud() -> void:
	hud.update_all(player_block, turn_number, player_status)

func _on_battle_won() -> void:
	battle_over = true
	EventBus.battle_won.emit(enemy_data)
	end_turn_button.disabled = true

func _on_battle_lost() -> void:
	battle_over = true
	end_turn_button.disabled = true
