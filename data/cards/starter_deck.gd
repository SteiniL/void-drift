# res://data/cards/starter_deck.gd
# Factory that builds the default starter deck (10 cards, 2-3 per type)
class_name StarterDeck

static func create() -> Array[CardData]:
	var deck: Array[CardData] = []

	# ENERGY x3
	deck.append(_make("plasma_bolt", "Plasma Bolt", "Deal 6 damage.", 1,
		GameEnums.CardType.ENERGY, 6, 0, 0))
	deck.append(_make("laser_burst", "Laser Burst", "Deal 4 damage.", 1,
		GameEnums.CardType.ENERGY, 4, 0, 0))
	deck.append(_make("beam_cannon", "Beam Cannon", "Deal 10 damage.", 2,
		GameEnums.CardType.ENERGY, 10, 0, 0))

	# KINETIC x3
	deck.append(_make("torpedo", "Torpedo", "Deal 8 damage.", 1,
		GameEnums.CardType.KINETIC, 8, 0, 0))
	deck.append(_make("rail_shot", "Rail Shot", "Deal 5 damage. Draw 1.", 1,
		GameEnums.CardType.KINETIC, 5, 0, 1))
	deck.append(_make("mass_driver", "Mass Driver", "Deal 12 damage.", 2,
		GameEnums.CardType.KINETIC, 12, 0, 0))

	# HACK x2
	deck.append(_make("system_breach", "System Breach", "Apply 2 EXPOSED.", 1,
		GameEnums.CardType.HACK, 0, 0, 0, GameEnums.StatusEffect.EXPOSED, 2))
	deck.append(_make("jam_signal", "Jam Signal", "Apply 1 JAMMED.", 1,
		GameEnums.CardType.HACK, 0, 0, 0, GameEnums.StatusEffect.JAMMED, 1))

	# SHIELD x2
	deck.append(_make("barrier", "Barrier", "Gain 6 block.", 1,
		GameEnums.CardType.SHIELD, 0, 6, 0))
	deck.append(_make("deflector", "Deflector", "Gain 4 block. Draw 1.", 1,
		GameEnums.CardType.SHIELD, 0, 4, 1))

	return deck

static func _make(
	id: String, name: String, desc: String, cost: int,
	type: GameEnums.CardType, dmg: int, blk: int, drw: int,
	status: GameEnums.StatusEffect = GameEnums.StatusEffect.NONE,
	stacks: int = 0
) -> CardData:
	var c := CardData.new()
	c.id = id
	c.name = name
	c.description = desc
	c.cost = cost
	c.type = type
	c.damage = dmg
	c.block = blk
	c.draw = drw
	c.status_effect = status
	c.status_stacks = stacks
	return c
