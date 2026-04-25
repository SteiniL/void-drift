# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Running the Game

```bash
# Run the project (main scene is BattleScene)
godot --path .

# Run a specific scene directly
godot --path . res://scenes/battle/BattleScene.tscn

# Headless syntax check (no display needed)
godot --headless --check-only --path .
```

No build step — Godot runs GDScript interpreted. Main scene (`project.godot → run/main_scene`) is `BattleScene.tscn`.

---

## Architecture: How the Systems Connect

### Autoload boot order (defined in `project.godot`)
`GameEnums` → `EventBus` → `GameState` → `DeckManager` → `SaveManager`

`GameEnums` must be first — all other autoloads reference its enums in typed declarations. Never reorder.

### BattleScene self-bootstraps
`BattleScene._ready()` → `_start_battle()`:
- If `GameState.deck.is_empty()`: calls `StarterDeck.create()` and `GameState.start_new_run()`
- If `enemy_data` not set: calls `EnemyFactory.create_random_common()`

Scene is playable standalone. When a map is added, call `BattleScene.setup(enemy_data)` before adding to scene tree — this sets `enemy_data` and `enemy_hp` so `_start_battle()` skips auto-init.

### Card play flow (multi-select model)
Cards are **selected** first, then played together in one batch:

1. Player clicks card → `CardUI._gui_input()` emits `card_selected`
2. `CardHand._on_card_selected()` toggles `CardUI.is_selected`, emits `card_selection_changed`
3. `BattleScene._on_card_selection_changed()` calls `_calculate_preview()` → `HUD.update_preview()`
4. Player clicks "PLAY [P]" button → `HUD._on_play_pressed()` → `BattleScene.play_selected_cards()`
5. `play_selected_cards()` spends total energy, calls `_apply_card_effects()` per card, moves cards to `DeckManager.discard_pile` directly, then calls `_check_drift()`

`DeckManager.play_card()` is **not** used in combat — `BattleScene` handles energy + discard directly for multi-card batching. `EventBus.card_played` is also not emitted per-card in this flow.

### Drift system
`_check_drift()` runs after every multi-card play. Counts `cards_played_this_turn` (cumulative per turn).
- 3 of same type → DRIFT I (+3 dmg)
- 4 of same type → DRIFT II (+6 dmg)
- 5+ of same type → DRIFT III (+12 dmg)

Bonus fires only when the threshold is crossed exactly (tracked via `DRIFT_THRESHOLDS`). `DriftIndicator` also shows live preview during selection via `_calculate_preview()`, which mirrors the same logic.

### Enemy action system
`EnemyData.actions: Array[EnemyAction]` — cycling turn list. `BattleScene.action_index` advances mod `actions.size()` after every enemy turn. `EnemyFactory` is the single source of truth for all enemies — never define enemies inline.

EnemyAction fields: `damage`, `block`, `status_effect`, `status_stacks`, `description`. Actions can combine (e.g. `_atk_status()`, `_blk_status()`).

### Status effect system
`BattleScene` owns `enemy_status` and `player_status` — `Dictionary[GameEnums.StatusEffect → int]` (stacks).

| Effect | Who it hits | When it triggers | Decay |
|--------|-------------|-----------------|-------|
| BURN | Either | Start of afflicted entity's own turn | −1 per trigger |
| JAMMED | Player | Start of player turn — loses energy equal to stacks (capped at 0) | −1 per trigger |
| EXPOSED | Enemy | Passive — each damage card hit deals +2 per stack | −1 at start of enemy turn |

`SHIELD_UP` and `OVERLOAD` are defined in `GameEnums` but **not yet implemented** in combat logic.

Block resets to 0 at the start of each entity's own turn (player: `_start_player_turn()`, enemy: `_enemy_turn()`).

### Module damage modifiers (applied in `_apply_card_effects()` and `_calculate_preview()`)
- `WEAPONS ≤ 0` → all card damage −1 (min 0)
- `SHIELDS ≤ 0` → all block gain −2 (min 0)
- `REACTOR ≤ 10` → −1 energy/turn; `≤ 0` → −2 energy/turn (min 1), applied in `GameState.reset_energy()`
- `THRUSTERS` — tracked in `module_hp` but combat logic not yet implemented

### Dynamic UI nodes
`HUD.gd` creates `status_label`, `preview_label`, and `play_button` dynamically in `_ready()`.
`EnemyNode.gd` creates `status_label` dynamically in `_ready()`.
Do not add `@onready` refs for these — append via `add_child()` instead.

`HUD._on_play_pressed()` directly accesses `battle_scene.card_hand.card_ui_map` to gather selected cards — this is an intentional parent→child reference, not a cross-scene violation.

### SaveManager
Saves to `user://save_data.json` via `JSON.stringify`. Tracks meta-progression only (runs completed, gold earned, unlocked relics, ascension level). Run state (deck, HP, etc.) lives in `GameState` in-memory and is not persisted.

---

## Data Factory Classes

| Class | File | Purpose |
|-------|------|---------|
| `StarterDeck` | `data/cards/starter_deck.gd` | Static factory — `StarterDeck.create()` returns 10-card starting deck |
| `EnemyFactory` | `data/enemies/EnemyFactory.gd` | Static factory — one method per enemy, `create_random_common()` picks from common pool |

Both are `class_name` classes without `extends` — pure static utilities. Add new enemies in `EnemyFactory`, not inline in scenes.

---

## Current Implementation State

**Working:**
- BattleScene: full combat loop (player turn, enemy turn, drift, status effects)
- Multi-card selection with live damage/block/drift preview in HUD
- DeckManager: draw, reshuffle, discard
- GameState: HP, energy, module HP, run reset
- CardUI: click-to-toggle selection, type colors
- EnemyNode: HP/block/intent/status display
- DriftIndicator: live type + count + level display
- EnemyFactory: 5 common enemies + 1 elite
- StarterDeck: 10 cards across all 4 types
- SaveManager: meta-progression JSON persistence

**Not yet implemented:**
- MapScene / sector map
- Merchant scene
- Event system
- Relic effects (RelicData resource exists, no effect logic)
- THRUSTERS module effect (can't flee)
- SHIELD_UP and OVERLOAD status effects
- Card upgrade system
- Card reward after combat

---

## VOID DRIFT — Game Design Reference

### Genre & Feel
Deckbuilder Roguelite — inspired by Balatro (synergies, multipliers), Slay the Spire (card structure, map), FTL (ship systems, sci-fi atmosphere). Core decision each turn: build toward a Drift, or cash out now?

### Core Mechanics

**Card Types:** `ENERGY`, `KINETIC`, `HACK`, `SHIELD`

**Drift Bonus:** Playing same-type cards in one turn accumulates toward thresholds:
- 3 → DRIFT I (+3 dmg)
- 4 → DRIFT II (+6 dmg)
- 5+ → DRIFT III (+12 dmg)

**Ship Modules** (each 20 HP max):
- `REACTOR` — energy per turn
- `WEAPONS` — card damage
- `SHIELDS` — block gain
- `THRUSTERS` — flee ability (not implemented)

**Limits:** Max hand size: 8. Deck limit: 30. Base energy: 3. Base HP: 80.

### Planned Systems
- **Map:** 3 sectors (Asteroid Belt → Pulsar Zone → Void Core), branching nodes: COMBAT / ELITE / MERCHANT / EVENT / REST / BOSS
- **Relics:** Passive run modifiers (e.g. *Black Hole Core* — first card each turn costs 0)
- **Meta-progression:** New starter sets, ship skins, relic pool unlocks, Ascension levels
- **Target:** Steam Early Access (~$5–8), GodotSteam plugin later phase

---

## Code Conventions

```gdscript
# Always typed GDScript
var deck: Array[CardData] = []

# EventBus for cross-scene signals
EventBus.card_played.emit(card_data)

# Constants SCREAMING_SNAKE_CASE
const MAX_HAND_SIZE: int = 8

# Enums for all categorical types — defined in GameEnums autoload
enum CardType { ENERGY, KINETIC, HACK, SHIELD }
```

**Rules:**
1. Autoloads are singletons — `GameState`, `DeckManager`, `EventBus`, `SaveManager`
2. Scenes communicate via `EventBus` — no direct cross-scene `get_node()` chains
3. Card/Enemy/Relic data as `Resource` subclasses, never plain dictionaries
4. No magic numbers — constants or resource fields only
5. One system per `.gd` file

**Naming:** Scenes `PascalCase.tscn`, scripts `PascalCase.gd`, signals/vars/functions `snake_case`, constants/enums `SCREAMING_SNAKE_CASE`.

---

## EventBus Signals

```gdscript
signal card_played(card: CardData)       # not currently emitted in multi-card flow
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
```

---

## Development Phases

- **Phase 1 (Prototype):** BattleScene + 20 cards + 3 enemies + Drift ✓ (in progress)
- **Phase 2 (Alpha):** Full map, 60–80 cards, 3 ship types, 15+ relics, 20+ events
- **Phase 3 (Early Access):** 100+ cards, sound/music, Steam page + achievements
- **Phase 4 (v1.0):** 150+ cards, trading cards, full Ascension system (10 levels)
