# res://data/cards/CardPool.gd
class_name CardPool

static func get_all() -> Array[CardData]:
	var pool: Array[CardData] = []

	# ENERGY
	pool.append(_card("scatter_pulse", "Scatter Pulse", "Deal 3 damage 3 times.", 1,
		GameEnums.CardType.ENERGY, GameEnums.Rarity.UNCOMMON, 3, 0, 0,
		GameEnums.StatusEffect.NONE, 0, 3))
	pool.append(_card("ion_surge", "Ion Surge", "Deal 14 damage.", 2,
		GameEnums.CardType.ENERGY, GameEnums.Rarity.COMMON, 14))
	pool.append(_card("incendiary_core", "Incendiary Core", "Apply 3 BURN.", 1,
		GameEnums.CardType.ENERGY, GameEnums.Rarity.COMMON, 0, 0, 0,
		GameEnums.StatusEffect.BURN, 3))
	pool.append(_card("static_burst", "Static Burst", "Deal 5 damage.", 0,
		GameEnums.CardType.ENERGY, GameEnums.Rarity.COMMON, 5))
	pool.append(_card("arc_cannon", "Arc Cannon", "Deal 22 damage.", 3,
		GameEnums.CardType.ENERGY, GameEnums.Rarity.RARE, 22))

	# KINETIC
	pool.append(_card("broadside", "Broadside", "Deal 2 damage per card in hand.", 2,
		GameEnums.CardType.KINETIC, GameEnums.Rarity.UNCOMMON, 2, 0, 0,
		GameEnums.StatusEffect.NONE, 0, 1,
		GameEnums.Condition.NONE, GameEnums.ScaleTarget.HAND_SIZE))
	pool.append(_card("overclock", "Overclock", "Deal 18 damage. Take 4 damage.", 1,
		GameEnums.CardType.KINETIC, GameEnums.Rarity.UNCOMMON, 18, 0, 0,
		GameEnums.StatusEffect.NONE, 0, 1,
		GameEnums.Condition.NONE, GameEnums.ScaleTarget.NONE, 4))
	pool.append(_card("frag_salvo", "Frag Salvo", "Deal 4 damage 4 times.", 2,
		GameEnums.CardType.KINETIC, GameEnums.Rarity.UNCOMMON, 4, 0, 0,
		GameEnums.StatusEffect.NONE, 0, 4))
	pool.append(_card("point_blank", "Point Blank", "Deal 9 damage.", 1,
		GameEnums.CardType.KINETIC, GameEnums.Rarity.COMMON, 9))
	pool.append(_card("kinetic_ram", "Kinetic Ram", "Deal 28 damage.", 3,
		GameEnums.CardType.KINETIC, GameEnums.Rarity.RARE, 28))

	# HACK
	pool.append(_card("exploit", "Exploit", "Deal 20 damage. Requires EXPOSED.", 2,
		GameEnums.CardType.HACK, GameEnums.Rarity.UNCOMMON, 20, 0, 0,
		GameEnums.StatusEffect.NONE, 0, 1,
		GameEnums.Condition.ENEMY_HAS_EXPOSED))
	pool.append(_card("deep_scan", "Deep Scan", "Draw 3 cards.", 1,
		GameEnums.CardType.HACK, GameEnums.Rarity.COMMON, 0, 0, 3))
	pool.append(_card("cascade_virus", "Cascade Virus", "Apply 2 BURN. Draw 1.", 1,
		GameEnums.CardType.HACK, GameEnums.Rarity.COMMON, 0, 0, 1,
		GameEnums.StatusEffect.BURN, 2))
	pool.append(_card("expose_weakness", "Expose Weakness", "Apply 3 EXPOSED.", 2,
		GameEnums.CardType.HACK, GameEnums.Rarity.UNCOMMON, 0, 0, 0,
		GameEnums.StatusEffect.EXPOSED, 3))
	pool.append(_card("ghost_protocol", "Ghost Protocol", "Apply 1 EXPOSED. Draw 1.", 0,
		GameEnums.CardType.HACK, GameEnums.Rarity.COMMON, 0, 0, 1,
		GameEnums.StatusEffect.EXPOSED, 1))

	# SHIELD
	pool.append(_card("reactive_shell", "Reactive Shell", "Deal 4 damage. Gain 6 block.", 1,
		GameEnums.CardType.SHIELD, GameEnums.Rarity.UNCOMMON, 4, 6))
	pool.append(_card("ablative_armor", "Ablative Armor", "Gain 14 block.", 2,
		GameEnums.CardType.SHIELD, GameEnums.Rarity.COMMON, 0, 14))
	pool.append(_card("mirror_field", "Mirror Field", "Gain 5 block. Apply 1 EXPOSED.", 1,
		GameEnums.CardType.SHIELD, GameEnums.Rarity.UNCOMMON, 0, 5, 0,
		GameEnums.StatusEffect.EXPOSED, 1))
	pool.append(_card("aegis_protocol", "Aegis Protocol", "Gain 10 block. Draw 1.", 2,
		GameEnums.CardType.SHIELD, GameEnums.Rarity.UNCOMMON, 0, 10, 1))
	pool.append(_card("pulse_ward", "Pulse Ward", "Gain 4 block. Draw 1.", 1,
		GameEnums.CardType.SHIELD, GameEnums.Rarity.COMMON, 0, 4, 1))

	return pool

static func get_random_rewards(count: int, _current_deck: Array[CardData]) -> Array[CardData]:
	var pool := get_all()
	pool.shuffle()
	var result: Array[CardData] = []
	for card in pool:
		if result.size() >= count:
			break
		result.append(card)
	return result

static func _card(
	id: String, name_str: String, desc: String, cost: int,
	type: GameEnums.CardType, rarity: GameEnums.Rarity,
	dmg: int = 0, blk: int = 0, drw: int = 0,
	status: GameEnums.StatusEffect = GameEnums.StatusEffect.NONE, stacks: int = 0,
	hits: int = 1,
	condition: GameEnums.Condition = GameEnums.Condition.NONE,
	scale_by: GameEnums.ScaleTarget = GameEnums.ScaleTarget.NONE,
	self_dmg: int = 0
) -> CardData:
	var c := CardData.new()
	c.id = id
	c.name = name_str
	c.description = desc
	c.cost = cost
	c.type = type
	c.rarity = rarity
	c.damage = dmg
	c.block = blk
	c.draw = drw
	c.status_effect = status
	c.status_stacks = stacks
	c.hits = hits
	c.condition = condition
	c.scale_by = scale_by
	c.self_damage = self_dmg
	return c
