# res://data/enemies/EnemyFactory.gd
class_name EnemyFactory

static func _atk(dmg: int) -> EnemyAction:
	var a := EnemyAction.new()
	a.damage = dmg
	a.description = "Attack for %d" % dmg
	return a

static func _blk(amount: int) -> EnemyAction:
	var a := EnemyAction.new()
	a.block = amount
	a.description = "Shields up (%d)" % amount
	return a

static func _status(effect: GameEnums.StatusEffect, stacks: int) -> EnemyAction:
	var a := EnemyAction.new()
	a.status_effect = effect
	a.status_stacks = stacks
	a.description = "%s x%d" % [GameEnums.StatusEffect.keys()[effect], stacks]
	return a

static func _atk_status(dmg: int, effect: GameEnums.StatusEffect, stacks: int) -> EnemyAction:
	var a := EnemyAction.new()
	a.damage = dmg
	a.status_effect = effect
	a.status_stacks = stacks
	a.description = "Attack %d + %s x%d" % [dmg, GameEnums.StatusEffect.keys()[effect], stacks]
	return a

static func _blk_status(blk: int, effect: GameEnums.StatusEffect, stacks: int) -> EnemyAction:
	var a := EnemyAction.new()
	a.block = blk
	a.status_effect = effect
	a.status_stacks = stacks
	a.description = "Block %d + %s x%d" % [blk, GameEnums.StatusEffect.keys()[effect], stacks]
	return a

# ── Enemies ──────────────────────────────────────────────────────────────────

static func create_scout_drone() -> EnemyData:
	var e := EnemyData.new()
	e.id = "drone_scout"
	e.display_name = "Scout Drone"
	e.max_hp = 30
	e.actions = [
		_atk(8),
		_atk(8),
		_atk(12),
	]
	return e

static func create_armored_sentinel() -> EnemyData:
	var e := EnemyData.new()
	e.id = "armored_sentinel"
	e.display_name = "Armored Sentinel"
	e.max_hp = 52
	e.actions = [
		_blk(12),
		_atk(15),
		_atk(15),
		_blk(8),
		_atk(20),
	]
	return e

static func create_hack_probe() -> EnemyData:
	var e := EnemyData.new()
	e.id = "hack_probe"
	e.display_name = "Hack Probe"
	e.max_hp = 28
	e.actions = [
		_status(GameEnums.StatusEffect.JAMMED, 2),
		_atk(6),
		_atk_status(8, GameEnums.StatusEffect.JAMMED, 1),
		_atk(6),
	]
	return e

static func create_plasma_wraith() -> EnemyData:
	var e := EnemyData.new()
	e.id = "plasma_wraith"
	e.display_name = "Plasma Wraith"
	e.max_hp = 42
	e.actions = [
		_status(GameEnums.StatusEffect.BURN, 3),
		_atk(9),
		_atk_status(10, GameEnums.StatusEffect.BURN, 2),
		_status(GameEnums.StatusEffect.BURN, 5),
		_atk(14),
	]
	return e

static func create_void_stalker() -> EnemyData:
	var e := EnemyData.new()
	e.id = "void_stalker"
	e.display_name = "Void Stalker"
	e.max_hp = 38
	e.actions = [
		_status(GameEnums.StatusEffect.EXPOSED, 2),
		_atk(12),
		_atk(18),
		_atk_status(14, GameEnums.StatusEffect.EXPOSED, 1),
	]
	return e

# Elite encounter — much harder, meant for late-sector nodes
static func create_corrupted_turret() -> EnemyData:
	var e := EnemyData.new()
	e.id = "corrupted_turret"
	e.display_name = "Corrupted Turret"
	e.max_hp = 72
	e.actions = [
		_blk(18),
		_atk(22),
		_atk_status(12, GameEnums.StatusEffect.BURN, 3),
		_atk(22),
		_blk_status(10, GameEnums.StatusEffect.JAMMED, 2),
		_atk(26),
	]
	return e

static func create_random_common() -> EnemyData:
	var pool: Array[EnemyData] = [
		create_scout_drone(),
		create_armored_sentinel(),
		create_hack_probe(),
		create_plasma_wraith(),
		create_void_stalker(),
	]
	return pool[randi() % pool.size()]

static func get_all() -> Array[EnemyData]:
	return [
		create_scout_drone(),
		create_armored_sentinel(),
		create_hack_probe(),
		create_plasma_wraith(),
		create_void_stalker(),
		create_corrupted_turret(),
	]
