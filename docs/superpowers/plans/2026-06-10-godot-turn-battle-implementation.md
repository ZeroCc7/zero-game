# Godot 5v5 Turn Battle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a playable Godot 2D desktop prototype for a 5v5 traditional turn-based battle, using the approved reference-image layout and five-element sect skill system.

**Architecture:** Keep battle rules data-driven and separate from visual presentation. `BattleController` owns the turn state machine, `EffectResolver` owns deterministic effect application, and UI nodes only display state and forward player input.

**Tech Stack:** Godot 4.x, GDScript, built-in scene system, custom headless test runner in GDScript.

---

## File Structure

- Create: `project.godot` - Godot project metadata and main scene pointer.
- Create: `scenes/battle/BattleScene.tscn` - Main battle scene.
- Create: `scenes/battle/BattleScene.gd` - Scene bootstrap and node wiring.
- Create: `scenes/battle/CombatantView.tscn` - One unit's visual node: body, ring, name, HP/resource bars, status icons.
- Create: `scenes/battle/CombatantView.gd` - Updates one unit visual from combatant data.
- Create: `scenes/ui/BattleUI.tscn` - Top HUD, side buttons, current character panel, skill bar, end-turn button.
- Create: `scenes/ui/BattleUI.gd` - Emits player skill and target selection signals.
- Create: `scripts/battle/combatant.gd` - Combatant data model.
- Create: `scripts/battle/skill.gd` - Skill data model.
- Create: `scripts/battle/status_effect.gd` - Status effect data model.
- Create: `scripts/battle/effect_resolver.gd` - Damage, healing, buffs, control, death, and resource calculation.
- Create: `scripts/battle/battle_controller.gd` - Battle state machine and turn queue.
- Create: `scripts/battle/battle_ai.gd` - Enemy action choice.
- Create: `scripts/battle/battle_data.gd` - Creates first-version five-element characters and skills.
- Create: `scripts/battle/battle_constants.gd` - Enums and shared constants.
- Create: `tests/run_tests.gd` - Headless unit test entrypoint.
- Create: `tests/test_effect_resolver.gd` - Effect resolver tests.
- Create: `tests/test_battle_controller.gd` - Turn flow and victory tests.

The workspace is currently not a git repository. Use the checkpoint steps below as `git status` replacements until the repository is initialized.

---

### Task 1: Create Godot Project Skeleton

**Files:**
- Create: `project.godot`
- Create: `scenes/battle/BattleScene.tscn`
- Create: `scenes/battle/BattleScene.gd`

- [ ] **Step 1: Add project metadata**

Create `project.godot`:

```ini
; Engine configuration file.

config_version=5

[application]

config/name="Zero Game Battle Prototype"
run/main_scene="res://scenes/battle/BattleScene.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[rendering]

renderer/rendering_method="gl_compatibility"
```

- [ ] **Step 2: Add the main battle scene**

Create `scenes/battle/BattleScene.tscn`:

```ini
[gd_scene load_steps=2 format=3 uid="uid://battle_scene"]

[ext_resource type="Script" path="res://scenes/battle/BattleScene.gd" id="1"]

[node name="BattleScene" type="Node2D"]
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
offset_right = 1920.0
offset_bottom = 1080.0
color = Color(0.10, 0.09, 0.08, 1)

[node name="Units" type="Node2D" parent="."]

[node name="UIRoot" type="CanvasLayer" parent="."]
```

- [ ] **Step 3: Add a minimal scene script**

Create `scenes/battle/BattleScene.gd`:

```gdscript
extends Node2D

func _ready() -> void:
	print("Zero Game battle prototype started")
```

- [ ] **Step 4: Verify the project opens**

Run:

```powershell
godot --path G:\code\zero-game --headless --quit
```

Expected: Godot exits with code `0`. If `godot` is not found, install Godot 4.x or add it to PATH before continuing.

- [ ] **Step 5: Checkpoint**

Run:

```powershell
Get-ChildItem -Recurse -File project.godot, scenes | Select-Object FullName
```

Expected: `project.godot`, `BattleScene.tscn`, and `BattleScene.gd` exist.

---

### Task 2: Add Battle Data Models

**Files:**
- Create: `scripts/battle/battle_constants.gd`
- Create: `scripts/battle/skill.gd`
- Create: `scripts/battle/status_effect.gd`
- Create: `scripts/battle/combatant.gd`

- [ ] **Step 1: Write shared constants**

Create `scripts/battle/battle_constants.gd`:

```gdscript
class_name BattleConstants
extends RefCounted

enum Team { PLAYER, ENEMY }
enum Element { GOLD, WOOD, WATER, FIRE, EARTH, NONE }
enum SkillKind { PHYSICAL, SPELL, OBSTACLE, SUPPORT, ULTIMATE }
enum TargetRule { SINGLE_ENEMY, MULTI_ENEMY, SINGLE_ALLY, MULTI_ALLY, SELF, ALL_ENEMIES, ALL_ALLIES }
enum StatusKind { FORGET, POISON, FREEZE, SLEEP_LOCK, CONFUSION, ATTACK_UP, REGEN, DEFENSE_UP, SPEED_UP, DODGE_UP }
enum BattlePhase { START, WAITING_FOR_PLAYER_SKILL, WAITING_FOR_PLAYER_TARGET, ENEMY_ACTING, RESOLVING, FINISHED }
```

- [ ] **Step 2: Write skill model**

Create `scripts/battle/skill.gd`:

```gdscript
class_name Skill
extends RefCounted

var id: String
var display_name: String
var element: BattleConstants.Element
var kind: BattleConstants.SkillKind
var cost: int
var target_rule: BattleConstants.TargetRule
var power: int
var max_targets: int
var status_kind: int
var status_chance: float
var status_duration: int
var description: String

func _init(
	p_id: String,
	p_display_name: String,
	p_element: BattleConstants.Element,
	p_kind: BattleConstants.SkillKind,
	p_cost: int,
	p_target_rule: BattleConstants.TargetRule,
	p_power: int,
	p_max_targets: int,
	p_status_kind: int = -1,
	p_status_chance: float = 0.0,
	p_status_duration: int = 0,
	p_description: String = ""
) -> void:
	id = p_id
	display_name = p_display_name
	element = p_element
	kind = p_kind
	cost = p_cost
	target_rule = p_target_rule
	power = p_power
	max_targets = p_max_targets
	status_kind = p_status_kind
	status_chance = p_status_chance
	status_duration = p_status_duration
	description = p_description
```

- [ ] **Step 3: Write status effect model**

Create `scripts/battle/status_effect.gd`:

```gdscript
class_name StatusEffect
extends RefCounted

var kind: BattleConstants.StatusKind
var display_name: String
var remaining_turns: int
var power: int

func _init(
	p_kind: BattleConstants.StatusKind,
	p_display_name: String,
	p_remaining_turns: int,
	p_power: int = 0
) -> void:
	kind = p_kind
	display_name = p_display_name
	remaining_turns = p_remaining_turns
	power = p_power
```

- [ ] **Step 4: Write combatant model**

Create `scripts/battle/combatant.gd`:

```gdscript
class_name Combatant
extends RefCounted

var id: String
var display_name: String
var team: BattleConstants.Team
var element: BattleConstants.Element
var level: int
var max_hp: int
var hp: int
var max_resource: int
var resource: int
var attack: int
var magic: int
var defense: int
var speed: int
var skills: Array[Skill]
var statuses: Array[StatusEffect] = []
var position_index: int

func _init(
	p_id: String,
	p_display_name: String,
	p_team: BattleConstants.Team,
	p_element: BattleConstants.Element,
	p_level: int,
	p_max_hp: int,
	p_max_resource: int,
	p_attack: int,
	p_magic: int,
	p_defense: int,
	p_speed: int,
	p_skills: Array[Skill],
	p_position_index: int
) -> void:
	id = p_id
	display_name = p_display_name
	team = p_team
	element = p_element
	level = p_level
	max_hp = p_max_hp
	hp = p_max_hp
	max_resource = p_max_resource
	resource = p_max_resource / 2
	attack = p_attack
	magic = p_magic
	defense = p_defense
	speed = p_speed
	skills = p_skills
	position_index = p_position_index

func is_alive() -> bool:
	return hp > 0

func has_status(kind: BattleConstants.StatusKind) -> bool:
	for status in statuses:
		if status.kind == kind and status.remaining_turns > 0:
			return true
	return false

func add_status(status: StatusEffect) -> void:
	for existing in statuses:
		if existing.kind == status.kind:
			existing.remaining_turns = max(existing.remaining_turns, status.remaining_turns)
			existing.power = max(existing.power, status.power)
			return
	statuses.append(status)

func spend_resource(amount: int) -> bool:
	if resource < amount:
		return false
	resource -= amount
	return true

func gain_resource(amount: int) -> void:
	resource = min(max_resource, resource + amount)
```

- [ ] **Step 5: Verify scripts parse**

Run:

```powershell
godot --path G:\code\zero-game --headless --check-only --script res://scripts/battle/combatant.gd
```

Expected: No parser errors.

- [ ] **Step 6: Checkpoint**

Run:

```powershell
Get-ChildItem scripts\battle -File | Select-Object Name
```

Expected: Four model scripts exist.

---

### Task 3: Add Five-Element Battle Data

**Files:**
- Create: `scripts/battle/battle_data.gd`

- [ ] **Step 1: Write first-version skills and combatants**

Create `scripts/battle/battle_data.gd`:

```gdscript
class_name BattleData
extends RefCounted

static func create_combatants() -> Array[Combatant]:
	var player_skills := _create_player_skills()
	var enemy_skills := _create_enemy_skills()
	var units: Array[Combatant] = []

	units.append(Combatant.new("player_gold", "金阙剑修", BattleConstants.Team.PLAYER, BattleConstants.Element.GOLD, 68, 15236, 100, 820, 880, 420, 75, player_skills["gold"], 0))
	units.append(Combatant.new("player_wood", "青木医师", BattleConstants.Team.PLAYER, BattleConstants.Element.WOOD, 68, 13390, 100, 520, 760, 460, 66, player_skills["wood"], 1))
	units.append(Combatant.new("player_water", "玄水术士", BattleConstants.Team.PLAYER, BattleConstants.Element.WATER, 68, 14561, 100, 480, 740, 720, 58, player_skills["water"], 2))
	units.append(Combatant.new("player_fire", "赤焰道君", BattleConstants.Team.PLAYER, BattleConstants.Element.FIRE, 68, 13980, 100, 560, 920, 390, 92, player_skills["fire"], 3))
	units.append(Combatant.new("player_earth", "厚土武尊", BattleConstants.Team.PLAYER, BattleConstants.Element.EARTH, 68, 15236, 100, 760, 520, 760, 52, player_skills["earth"], 4))

	units.append(Combatant.new("enemy_gold", "断金剑客", BattleConstants.Team.ENEMY, BattleConstants.Element.GOLD, 68, 14589, 100, 760, 780, 400, 70, enemy_skills["gold"], 0))
	units.append(Combatant.new("enemy_wood", "腐木咒师", BattleConstants.Team.ENEMY, BattleConstants.Element.WOOD, 68, 13852, 100, 500, 720, 430, 62, enemy_skills["wood"], 1))
	units.append(Combatant.new("enemy_water", "幽冥巫师", BattleConstants.Team.ENEMY, BattleConstants.Element.WATER, 68, 14226, 100, 460, 700, 690, 56, enemy_skills["water"], 2))
	units.append(Combatant.new("enemy_fire", "黑焰狂徒", BattleConstants.Team.ENEMY, BattleConstants.Element.FIRE, 68, 14127, 100, 540, 860, 380, 88, enemy_skills["fire"], 3))
	units.append(Combatant.new("enemy_earth", "岩甲兽灵", BattleConstants.Team.ENEMY, BattleConstants.Element.EARTH, 68, 15236, 100, 720, 480, 740, 50, enemy_skills["earth"], 4))

	return units

static func _create_player_skills() -> Dictionary:
	return {
		"gold": [
			_common_physical(),
			Skill.new("gold_spell", "天罚金阙", BattleConstants.Element.GOLD, BattleConstants.SkillKind.SPELL, 24, BattleConstants.TargetRule.MULTI_ENEMY, 190, 5),
			Skill.new("gold_obstacle", "隔世", BattleConstants.Element.GOLD, BattleConstants.SkillKind.OBSTACLE, 28, BattleConstants.TargetRule.MULTI_ENEMY, 0, 5, BattleConstants.StatusKind.FORGET, 0.65, 2),
			Skill.new("gold_support", "锋锐", BattleConstants.Element.GOLD, BattleConstants.SkillKind.SUPPORT, 20, BattleConstants.TargetRule.MULTI_ALLY, 180, 5, BattleConstants.StatusKind.ATTACK_UP, 1.0, 3)
		],
		"wood": [
			_common_physical(),
			Skill.new("wood_spell", "万木归墟", BattleConstants.Element.WOOD, BattleConstants.SkillKind.SPELL, 24, BattleConstants.TargetRule.MULTI_ENEMY, 160, 5),
			Skill.new("wood_obstacle", "蚀骨", BattleConstants.Element.WOOD, BattleConstants.SkillKind.OBSTACLE, 24, BattleConstants.TargetRule.MULTI_ENEMY, 90, 5, BattleConstants.StatusKind.POISON, 0.75, 3),
			Skill.new("wood_support", "繁花", BattleConstants.Element.WOOD, BattleConstants.SkillKind.SUPPORT, 28, BattleConstants.TargetRule.MULTI_ALLY, 420, 5, BattleConstants.StatusKind.REGEN, 1.0, 3)
		],
		"water": [
			_common_physical(),
			Skill.new("water_spell", "沧海龙吟", BattleConstants.Element.WATER, BattleConstants.SkillKind.SPELL, 24, BattleConstants.TargetRule.MULTI_ENEMY, 170, 5),
			Skill.new("water_obstacle", "玄冰劫", BattleConstants.Element.WATER, BattleConstants.SkillKind.OBSTACLE, 30, BattleConstants.TargetRule.MULTI_ENEMY, 0, 5, BattleConstants.StatusKind.FREEZE, 0.55, 2),
			Skill.new("water_support", "镜潮", BattleConstants.Element.WATER, BattleConstants.SkillKind.SUPPORT, 20, BattleConstants.TargetRule.MULTI_ALLY, 160, 5, BattleConstants.StatusKind.DEFENSE_UP, 1.0, 3)
		],
		"fire": [
			_common_physical(),
			Skill.new("fire_spell", "焚天业火", BattleConstants.Element.FIRE, BattleConstants.SkillKind.SPELL, 26, BattleConstants.TargetRule.MULTI_ENEMY, 205, 5),
			Skill.new("fire_obstacle", "离魄", BattleConstants.Element.FIRE, BattleConstants.SkillKind.OBSTACLE, 26, BattleConstants.TargetRule.MULTI_ENEMY, 0, 5, BattleConstants.StatusKind.SLEEP_LOCK, 0.60, 2),
			Skill.new("fire_support", "虎驰", BattleConstants.Element.FIRE, BattleConstants.SkillKind.SUPPORT, 20, BattleConstants.TargetRule.MULTI_ALLY, 150, 5, BattleConstants.StatusKind.SPEED_UP, 1.0, 3)
		],
		"earth": [
			_common_physical(),
			Skill.new("earth_spell", "山河崩岳", BattleConstants.Element.EARTH, BattleConstants.SkillKind.SPELL, 24, BattleConstants.TargetRule.MULTI_ENEMY, 175, 5),
			Skill.new("earth_obstacle", "荒古", BattleConstants.Element.EARTH, BattleConstants.SkillKind.OBSTACLE, 26, BattleConstants.TargetRule.MULTI_ENEMY, 0, 5, BattleConstants.StatusKind.CONFUSION, 0.60, 2),
			Skill.new("earth_support", "虚境", BattleConstants.Element.EARTH, BattleConstants.SkillKind.SUPPORT, 20, BattleConstants.TargetRule.MULTI_ALLY, 150, 5, BattleConstants.StatusKind.DODGE_UP, 1.0, 3)
		]
	}

static func _create_enemy_skills() -> Dictionary:
	var skills := _create_player_skills()
	return skills

static func _common_physical() -> Skill:
	return Skill.new("common_cleave", "裂阵千锋", BattleConstants.Element.NONE, BattleConstants.SkillKind.PHYSICAL, 0, BattleConstants.TargetRule.MULTI_ENEMY, 135, 2, -1, 0.0, 0, "物理群攻")
```

- [ ] **Step 2: Verify the data script parses**

Run:

```powershell
godot --path G:\code\zero-game --headless --check-only --script res://scripts/battle/battle_data.gd
```

Expected: No parser errors.

- [ ] **Step 3: Checkpoint**

Run:

```powershell
Select-String -Path scripts\battle\battle_data.gd -Pattern "天罚金阙|万木归墟|沧海龙吟|焚天业火|山河崩岳|裂阵千锋"
```

Expected: All six skill names appear.

---

### Task 4: Add Effect Resolver With Tests

**Files:**
- Create: `scripts/battle/effect_resolver.gd`
- Create: `tests/test_effect_resolver.gd`
- Create: `tests/run_tests.gd`

- [ ] **Step 1: Write failing tests**

Create `tests/test_effect_resolver.gd`:

```gdscript
extends RefCounted

const EffectResolver = preload("res://scripts/battle/effect_resolver.gd")
const BattleData = preload("res://scripts/battle/battle_data.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	_test_spell_deals_damage(failures)
	_test_resource_gate_blocks_skill(failures)
	_test_poison_ticks_damage(failures)
	return failures

func _test_spell_deals_damage(failures: Array[String]) -> void:
	var units := BattleData.create_combatants()
	var attacker := units[0]
	var target := units[5]
	var skill := attacker.skills[1]
	var before_hp := target.hp
	var result := EffectResolver.apply_skill(attacker, skill, [target])
	if not result["success"]:
		failures.append("spell should succeed")
	if target.hp >= before_hp:
		failures.append("spell should reduce target hp")

func _test_resource_gate_blocks_skill(failures: Array[String]) -> void:
	var units := BattleData.create_combatants()
	var attacker := units[0]
	var target := units[5]
	var skill := attacker.skills[1]
	attacker.resource = 0
	var before_hp := target.hp
	var result := EffectResolver.apply_skill(attacker, skill, [target])
	if result["success"]:
		failures.append("skill should fail when resource is insufficient")
	if target.hp != before_hp:
		failures.append("failed skill should not change target hp")

func _test_poison_ticks_damage(failures: Array[String]) -> void:
	var units := BattleData.create_combatants()
	var target := units[5]
	target.add_status(StatusEffect.new(BattleConstants.StatusKind.POISON, "中毒", 2, 120))
	var before_hp := target.hp
	EffectResolver.apply_turn_start_statuses(target)
	if target.hp != before_hp - 120:
		failures.append("poison should tick exact power damage")
```

Create `tests/run_tests.gd`:

```gdscript
extends SceneTree

const TestEffectResolver = preload("res://tests/test_effect_resolver.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	failures.append_array(TestEffectResolver.new().run())
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```powershell
godot --path G:\code\zero-game --headless --script res://tests/run_tests.gd
```

Expected: FAIL because `effect_resolver.gd` does not exist.

- [ ] **Step 3: Implement resolver**

Create `scripts/battle/effect_resolver.gd`:

```gdscript
class_name EffectResolver
extends RefCounted

static func apply_skill(attacker: Combatant, skill: Skill, targets: Array) -> Dictionary:
	if not attacker.is_alive():
		return {"success": false, "reason": "attacker_dead"}
	if attacker.resource < skill.cost:
		return {"success": false, "reason": "not_enough_resource"}
	attacker.spend_resource(skill.cost)

	var affected: Array[String] = []
	for raw_target in targets.slice(0, skill.max_targets):
		var target: Combatant = raw_target
		if not target.is_alive() and skill.kind != BattleConstants.SkillKind.SUPPORT:
			continue
		_apply_single_target(attacker, skill, target)
		affected.append(target.id)

	attacker.gain_resource(10)
	return {"success": true, "affected": affected}

static func apply_turn_start_statuses(target: Combatant) -> void:
	for status in target.statuses:
		if status.remaining_turns <= 0:
			continue
		if status.kind == BattleConstants.StatusKind.POISON:
			target.hp = max(0, target.hp - status.power)
		elif status.kind == BattleConstants.StatusKind.REGEN:
			if target.hp <= 0:
				target.hp = min(target.max_hp, max(1, status.power))
			else:
				target.hp = min(target.max_hp, target.hp + status.power)
		status.remaining_turns -= 1
	target.statuses = target.statuses.filter(func(s: StatusEffect) -> bool: return s.remaining_turns > 0)

static func can_act(combatant: Combatant) -> bool:
	if not combatant.is_alive():
		return false
	if combatant.has_status(BattleConstants.StatusKind.FREEZE):
		return false
	if combatant.has_status(BattleConstants.StatusKind.SLEEP_LOCK):
		return false
	return true

static func _apply_single_target(attacker: Combatant, skill: Skill, target: Combatant) -> void:
	match skill.kind:
		BattleConstants.SkillKind.PHYSICAL:
			_apply_damage(target, max(1, attacker.attack + skill.power - target.defense / 2))
		BattleConstants.SkillKind.SPELL:
			_apply_damage(target, max(1, attacker.magic + skill.power - target.defense / 3))
		BattleConstants.SkillKind.OBSTACLE:
			_apply_obstacle(skill, target)
		BattleConstants.SkillKind.SUPPORT:
			_apply_support(skill, target)
		BattleConstants.SkillKind.ULTIMATE:
			_apply_damage(target, max(1, attacker.magic + skill.power * 2 - target.defense / 3))

static func _apply_damage(target: Combatant, amount: int) -> void:
	if target.has_status(BattleConstants.StatusKind.FREEZE):
		return
	target.hp = max(0, target.hp - amount)
	if target.has_status(BattleConstants.StatusKind.SLEEP_LOCK):
		target.statuses = target.statuses.filter(func(s: StatusEffect) -> bool: return s.kind != BattleConstants.StatusKind.SLEEP_LOCK)

static func _apply_obstacle(skill: Skill, target: Combatant) -> void:
	if skill.status_kind < 0:
		return
	if skill.status_chance >= 1.0 or randf() <= skill.status_chance:
		target.add_status(StatusEffect.new(skill.status_kind, skill.display_name, skill.status_duration, skill.power))

static func _apply_support(skill: Skill, target: Combatant) -> void:
	if skill.status_kind == BattleConstants.StatusKind.REGEN:
		target.add_status(StatusEffect.new(skill.status_kind, skill.display_name, skill.status_duration, skill.power))
	elif skill.status_kind >= 0:
		target.add_status(StatusEffect.new(skill.status_kind, skill.display_name, skill.status_duration, skill.power))
```

- [ ] **Step 4: Run tests to verify pass**

Run:

```powershell
godot --path G:\code\zero-game --headless --script res://tests/run_tests.gd
```

Expected: `ALL TESTS PASSED`.

- [ ] **Step 5: Checkpoint**

Run:

```powershell
Select-String -Path scripts\battle\effect_resolver.gd -Pattern "apply_skill|apply_turn_start_statuses|can_act"
```

Expected: All three functions appear.

---

### Task 5: Add Battle Controller and AI

**Files:**
- Create: `scripts/battle/battle_controller.gd`
- Create: `scripts/battle/battle_ai.gd`
- Create: `tests/test_battle_controller.gd`
- Modify: `tests/run_tests.gd`

- [ ] **Step 1: Add controller tests**

Create `tests/test_battle_controller.gd`:

```gdscript
extends RefCounted

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const BattleData = preload("res://scripts/battle/battle_data.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	_test_first_actor_is_highest_speed(failures)
	_test_victory_when_enemies_dead(failures)
	return failures

func _test_first_actor_is_highest_speed(failures: Array[String]) -> void:
	var controller := BattleController.new()
	controller.start_battle(BattleData.create_combatants())
	var actor := controller.current_actor()
	if actor == null:
		failures.append("first actor should exist")
	elif actor.display_name != "赤焰道君":
		failures.append("highest speed player fire unit should act first")

func _test_victory_when_enemies_dead(failures: Array[String]) -> void:
	var controller := BattleController.new()
	var units := BattleData.create_combatants()
	for unit in units:
		if unit.team == BattleConstants.Team.ENEMY:
			unit.hp = 0
	controller.start_battle(units)
	if not controller.is_finished():
		failures.append("battle should finish when enemies are dead")
	if controller.winner_team != BattleConstants.Team.PLAYER:
		failures.append("player should be winner when all enemies are dead")
```

Modify `tests/run_tests.gd`:

```gdscript
extends SceneTree

const TestEffectResolver = preload("res://tests/test_effect_resolver.gd")
const TestBattleController = preload("res://tests/test_battle_controller.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	failures.append_array(TestEffectResolver.new().run())
	failures.append_array(TestBattleController.new().run())
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```powershell
godot --path G:\code\zero-game --headless --script res://tests/run_tests.gd
```

Expected: FAIL because `battle_controller.gd` does not exist.

- [ ] **Step 3: Implement enemy AI**

Create `scripts/battle/battle_ai.gd`:

```gdscript
class_name BattleAI
extends RefCounted

static func choose_action(actor: Combatant, units: Array[Combatant]) -> Dictionary:
	var enemies := units.filter(func(unit: Combatant) -> bool: return unit.team != actor.team and unit.is_alive())
	var allies := units.filter(func(unit: Combatant) -> bool: return unit.team == actor.team and unit.is_alive())
	var usable := actor.skills.filter(func(skill: Skill) -> bool: return actor.resource >= skill.cost)
	if usable.is_empty():
		usable = [actor.skills[0]]

	for skill in usable:
		if skill.kind == BattleConstants.SkillKind.SUPPORT:
			var low_allies := allies.filter(func(unit: Combatant) -> bool: return unit.hp < unit.max_hp * 0.45)
			if not low_allies.is_empty():
				return {"skill": skill, "targets": low_allies.slice(0, skill.max_targets)}

	var damage_skills := usable.filter(func(skill: Skill) -> bool: return skill.kind == BattleConstants.SkillKind.SPELL or skill.kind == BattleConstants.SkillKind.PHYSICAL)
	var selected_skill: Skill = damage_skills[0] if not damage_skills.is_empty() else usable[0]
	enemies.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.hp < b.hp)
	return {"skill": selected_skill, "targets": enemies.slice(0, selected_skill.max_targets)}
```

- [ ] **Step 4: Implement controller**

Create `scripts/battle/battle_controller.gd`:

```gdscript
class_name BattleController
extends RefCounted

signal battle_started(units: Array[Combatant])
signal actor_changed(actor: Combatant)
signal skill_resolved(actor: Combatant, skill: Skill, targets: Array, result: Dictionary)
signal battle_finished(winner_team: BattleConstants.Team)

var units: Array[Combatant] = []
var turn_queue: Array[Combatant] = []
var phase: BattleConstants.BattlePhase = BattleConstants.BattlePhase.START
var winner_team: int = -1
var round_number: int = 1

func start_battle(p_units: Array[Combatant]) -> void:
	units = p_units
	round_number = 1
	_rebuild_turn_queue()
	phase = BattleConstants.BattlePhase.WAITING_FOR_PLAYER_SKILL
	emit_signal("battle_started", units)
	_check_victory()
	if not is_finished():
		emit_signal("actor_changed", current_actor())

func current_actor() -> Combatant:
	while not turn_queue.is_empty() and not turn_queue[0].is_alive():
		turn_queue.pop_front()
	return null if turn_queue.is_empty() else turn_queue[0]

func is_finished() -> bool:
	return phase == BattleConstants.BattlePhase.FINISHED

func player_use_skill(skill: Skill, targets: Array) -> Dictionary:
	var actor := current_actor()
	if actor == null or actor.team != BattleConstants.Team.PLAYER:
		return {"success": false, "reason": "not_player_turn"}
	var result := EffectResolver.apply_skill(actor, skill, targets)
	if result["success"]:
		emit_signal("skill_resolved", actor, skill, targets, result)
		_advance_turn()
	return result

func enemy_take_turn_if_needed() -> void:
	var actor := current_actor()
	if actor == null or actor.team != BattleConstants.Team.ENEMY or is_finished():
		return
	var action := BattleAI.choose_action(actor, units)
	var result := EffectResolver.apply_skill(actor, action["skill"], action["targets"])
	emit_signal("skill_resolved", actor, action["skill"], action["targets"], result)
	_advance_turn()

func _advance_turn() -> void:
	if not turn_queue.is_empty():
		turn_queue.pop_front()
	_check_victory()
	if is_finished():
		return
	if turn_queue.is_empty():
		round_number += 1
		_rebuild_turn_queue()
	var actor := current_actor()
	if actor != null:
		EffectResolver.apply_turn_start_statuses(actor)
	emit_signal("actor_changed", actor)

func _rebuild_turn_queue() -> void:
	turn_queue = units.filter(func(unit: Combatant) -> bool: return unit.is_alive())
	turn_queue.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.speed > b.speed)

func _check_victory() -> void:
	var player_alive := units.any(func(unit: Combatant) -> bool: return unit.team == BattleConstants.Team.PLAYER and unit.is_alive())
	var enemy_alive := units.any(func(unit: Combatant) -> bool: return unit.team == BattleConstants.Team.ENEMY and unit.is_alive())
	if player_alive and enemy_alive:
		return
	winner_team = BattleConstants.Team.PLAYER if player_alive else BattleConstants.Team.ENEMY
	phase = BattleConstants.BattlePhase.FINISHED
	emit_signal("battle_finished", winner_team)
```

- [ ] **Step 5: Run tests**

Run:

```powershell
godot --path G:\code\zero-game --headless --script res://tests/run_tests.gd
```

Expected: `ALL TESTS PASSED`.

- [ ] **Step 6: Checkpoint**

Run:

```powershell
Select-String -Path scripts\battle\battle_controller.gd -Pattern "start_battle|player_use_skill|enemy_take_turn_if_needed|battle_finished"
```

Expected: All controller methods and signal appear.

---

### Task 6: Build Combatant Visuals

**Files:**
- Create: `scenes/battle/CombatantView.tscn`
- Create: `scenes/battle/CombatantView.gd`

- [ ] **Step 1: Create combatant view scene**

Create `scenes/battle/CombatantView.tscn`:

```ini
[gd_scene load_steps=3 format=3 uid="uid://combatant_view"]

[ext_resource type="Script" path="res://scenes/battle/CombatantView.gd" id="1"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_click"]
size = Vector2(110, 180)

[node name="CombatantView" type="Node2D"]
script = ExtResource("1")

[node name="ClickArea" type="Area2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="ClickArea"]
shape = SubResource("RectangleShape2D_click")

[node name="Ring" type="ColorRect" parent="."]
offset_left = -42.0
offset_top = 54.0
offset_right = 42.0
offset_bottom = 66.0
color = Color(0.1, 0.45, 1.0, 0.65)

[node name="Body" type="ColorRect" parent="."]
offset_left = -32.0
offset_top = -48.0
offset_right = 32.0
offset_bottom = 56.0
color = Color(0.25, 0.35, 0.70, 1.0)

[node name="NameLabel" type="Label" parent="."]
offset_left = -80.0
offset_top = -100.0
offset_right = 80.0
offset_bottom = -78.0
horizontal_alignment = 1

[node name="HpBar" type="ProgressBar" parent="."]
offset_left = -70.0
offset_top = -76.0
offset_right = 70.0
offset_bottom = -58.0
show_percentage = false

[node name="ResourceBar" type="ProgressBar" parent="."]
offset_left = -70.0
offset_top = -56.0
offset_right = 70.0
offset_bottom = -42.0
show_percentage = false

[node name="StatusLabel" type="Label" parent="."]
offset_left = -80.0
offset_top = -40.0
offset_right = 80.0
offset_bottom = -18.0
horizontal_alignment = 1
```

- [ ] **Step 2: Create combatant view script**

Create `scenes/battle/CombatantView.gd`:

```gdscript
extends Node2D

var combatant: Combatant

@onready var click_area: Area2D = $ClickArea
@onready var ring: ColorRect = $Ring
@onready var body: ColorRect = $Body
@onready var name_label: Label = $NameLabel
@onready var hp_bar: ProgressBar = $HpBar
@onready var resource_bar: ProgressBar = $ResourceBar
@onready var status_label: Label = $StatusLabel

func bind(p_combatant: Combatant) -> void:
	combatant = p_combatant
	_update_static_colors()
	refresh()

func refresh() -> void:
	if combatant == null:
		return
	name_label.text = combatant.display_name
	hp_bar.max_value = combatant.max_hp
	hp_bar.value = combatant.hp
	resource_bar.max_value = combatant.max_resource
	resource_bar.value = combatant.resource
	visible = combatant.is_alive()
	status_label.text = " ".join(combatant.statuses.map(func(status: StatusEffect) -> String: return status.display_name))

func set_active(is_active: bool) -> void:
	scale = Vector2(1.12, 1.12) if is_active else Vector2.ONE

func set_selectable(is_selectable: bool) -> void:
	modulate = Color(1.25, 1.25, 1.25, 1.0) if is_selectable else Color.WHITE
	click_area.input_pickable = is_selectable

func _update_static_colors() -> void:
	if combatant.team == BattleConstants.Team.PLAYER:
		ring.color = Color(0.1, 0.45, 1.0, 0.65)
	else:
		ring.color = Color(0.9, 0.18, 0.12, 0.65)

	match combatant.element:
		BattleConstants.Element.GOLD:
			body.color = Color(0.85, 0.70, 0.25, 1.0)
		BattleConstants.Element.WOOD:
			body.color = Color(0.20, 0.70, 0.35, 1.0)
		BattleConstants.Element.WATER:
			body.color = Color(0.25, 0.65, 0.90, 1.0)
		BattleConstants.Element.FIRE:
			body.color = Color(0.90, 0.25, 0.15, 1.0)
		BattleConstants.Element.EARTH:
			body.color = Color(0.65, 0.48, 0.25, 1.0)
```

- [ ] **Step 3: Verify scene parses**

Run:

```powershell
godot --path G:\code\zero-game --headless --quit
```

Expected: No parse errors.

- [ ] **Step 4: Checkpoint**

Run:

```powershell
Get-ChildItem scenes\battle -File | Select-Object Name
```

Expected: `CombatantView.tscn` and `CombatantView.gd` exist.

---

### Task 7: Build Battle UI

**Files:**
- Create: `scenes/ui/BattleUI.tscn`
- Create: `scenes/ui/BattleUI.gd`

- [ ] **Step 1: Create UI scene matching the reference layout**

Create `scenes/ui/BattleUI.tscn`:

```ini
[gd_scene load_steps=2 format=3 uid="uid://battle_ui"]

[ext_resource type="Script" path="res://scenes/ui/BattleUI.gd" id="1"]

[node name="BattleUI" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1")

[node name="TopPanel" type="VBoxContainer" parent="."]
offset_left = 690.0
offset_top = 12.0
offset_right = 1230.0
offset_bottom = 100.0

[node name="TitleLabel" type="Label" parent="TopPanel"]
text = "断金门之战"
horizontal_alignment = 1

[node name="RoundLabel" type="Label" parent="TopPanel"]
text = "回合 1"
horizontal_alignment = 1

[node name="LeftTopButtons" type="HBoxContainer" parent="."]
offset_left = 28.0
offset_top = 24.0
offset_right = 360.0
offset_bottom = 82.0

[node name="RetreatButton" type="Button" parent="LeftTopButtons"]
text = "撤退"

[node name="SpeedButton" type="Button" parent="LeftTopButtons"]
text = "倍速"

[node name="AutoButton" type="Button" parent="LeftTopButtons"]
text = "自动"

[node name="SkipButton" type="Button" parent="LeftTopButtons"]
text = "跳过"

[node name="LeftSideButtons" type="VBoxContainer" parent="."]
offset_left = 34.0
offset_top = 420.0
offset_right = 120.0
offset_bottom = 760.0

[node name="ChatButton" type="Button" parent="LeftSideButtons"]
text = "聊天"

[node name="CommandButton" type="Button" parent="LeftSideButtons"]
text = "指挥"

[node name="StatusButton" type="Button" parent="LeftSideButtons"]
text = "状态"

[node name="FormationButton" type="Button" parent="LeftSideButtons"]
text = "布阵"

[node name="RightSideButtons" type="VBoxContainer" parent="."]
offset_left = 1790.0
offset_top = 120.0
offset_right = 1884.0
offset_bottom = 360.0

[node name="WeatherButton" type="Button" parent="RightSideButtons"]
text = "天气"

[node name="BattleInfoButton" type="Button" parent="RightSideButtons"]
text = "战场"

[node name="EnemyInfoButton" type="Button" parent="RightSideButtons"]
text = "敌情"

[node name="CurrentPanel" type="Panel" parent="."]
offset_left = 150.0
offset_top = 820.0
offset_right = 530.0
offset_bottom = 1038.0

[node name="CurrentName" type="Label" parent="CurrentPanel"]
offset_left = 130.0
offset_top = 24.0
offset_right = 360.0
offset_bottom = 54.0
text = "当前角色"

[node name="CurrentHp" type="ProgressBar" parent="CurrentPanel"]
offset_left = 130.0
offset_top = 72.0
offset_right = 350.0
offset_bottom = 94.0
show_percentage = false

[node name="CurrentResource" type="ProgressBar" parent="CurrentPanel"]
offset_left = 130.0
offset_top = 104.0
offset_right = 350.0
offset_bottom = 126.0
show_percentage = false

[node name="SkillBar" type="HBoxContainer" parent="."]
offset_left = 560.0
offset_top = 842.0
offset_right = 1290.0
offset_bottom = 1018.0

[node name="Skill0" type="Button" parent="SkillBar"]
custom_minimum_size = Vector2(170, 150)

[node name="Skill1" type="Button" parent="SkillBar"]
custom_minimum_size = Vector2(170, 150)

[node name="Skill2" type="Button" parent="SkillBar"]
custom_minimum_size = Vector2(170, 150)

[node name="Skill3" type="Button" parent="SkillBar"]
custom_minimum_size = Vector2(170, 150)

[node name="ItemButton" type="Button" parent="."]
offset_left = 1430.0
offset_top = 872.0
offset_right = 1534.0
offset_bottom = 1000.0
text = "道具"

[node name="EndTurnButton" type="Button" parent="."]
offset_left = 1600.0
offset_top = 820.0
offset_right = 1870.0
offset_bottom = 1040.0
text = "结束回合"
```

- [ ] **Step 2: Create UI script**

Create `scenes/ui/BattleUI.gd`:

```gdscript
extends Control

signal skill_selected(skill: Skill)
signal end_turn_requested

var current_actor: Combatant
var skill_buttons: Array[Button] = []

@onready var round_label: Label = $TopPanel/RoundLabel
@onready var current_name: Label = $CurrentPanel/CurrentName
@onready var current_hp: ProgressBar = $CurrentPanel/CurrentHp
@onready var current_resource: ProgressBar = $CurrentPanel/CurrentResource
@onready var end_turn_button: Button = $EndTurnButton

func _ready() -> void:
	skill_buttons = [$SkillBar/Skill0, $SkillBar/Skill1, $SkillBar/Skill2, $SkillBar/Skill3]
	for index in range(skill_buttons.size()):
		skill_buttons[index].pressed.connect(_on_skill_pressed.bind(index))
	end_turn_button.pressed.connect(func() -> void: emit_signal("end_turn_requested"))

func bind_actor(actor: Combatant) -> void:
	current_actor = actor
	current_name.text = actor.display_name
	current_hp.max_value = actor.max_hp
	current_hp.value = actor.hp
	current_resource.max_value = actor.max_resource
	current_resource.value = actor.resource
	for index in skill_buttons.size():
		var button := skill_buttons[index]
		var skill := actor.skills[index]
		button.text = "%s\n%d" % [skill.display_name, skill.cost]
		button.disabled = actor.resource < skill.cost or actor.team != BattleConstants.Team.PLAYER

func set_round(round_number: int) -> void:
	round_label.text = "回合 %d" % round_number

func _on_skill_pressed(index: int) -> void:
	if current_actor == null:
		return
	if index < 0 or index >= current_actor.skills.size():
		return
	emit_signal("skill_selected", current_actor.skills[index])
```

- [ ] **Step 3: Verify UI scene parses**

Run:

```powershell
godot --path G:\code\zero-game --headless --quit
```

Expected: No parse errors.

- [ ] **Step 4: Checkpoint**

Run:

```powershell
Select-String -Path scenes\ui\BattleUI.tscn -Pattern "断金门之战|结束回合|Skill0|天气|布阵"
```

Expected: All reference-layout UI labels appear.

---

### Task 8: Wire Scene, Units, Targeting, and Enemy Turns

**Files:**
- Modify: `scenes/battle/BattleScene.tscn`
- Modify: `scenes/battle/BattleScene.gd`

- [ ] **Step 1: Add scene resource references**

Modify `scenes/battle/BattleScene.tscn` to include:

```ini
[gd_scene load_steps=4 format=3 uid="uid://battle_scene"]

[ext_resource type="Script" path="res://scenes/battle/BattleScene.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/battle/CombatantView.tscn" id="2"]
[ext_resource type="PackedScene" path="res://scenes/ui/BattleUI.tscn" id="3"]
```

Keep existing nodes, and add this child:

```ini
[node name="BattleUI" parent="UIRoot" instance=ExtResource("3")]
```

- [ ] **Step 2: Implement battle scene wiring**

Replace `scenes/battle/BattleScene.gd`:

```gdscript
extends Node2D

const BattleControllerScript = preload("res://scripts/battle/battle_controller.gd")
const BattleData = preload("res://scripts/battle/battle_data.gd")

@export var combatant_view_scene: PackedScene

var controller: BattleController
var combatant_views: Dictionary = {}
var selected_skill: Skill

@onready var units_root: Node2D = $Units
@onready var battle_ui = $UIRoot/BattleUI

func _ready() -> void:
	if combatant_view_scene == null:
		combatant_view_scene = preload("res://scenes/battle/CombatantView.tscn")
	controller = BattleControllerScript.new()
	controller.battle_started.connect(_on_battle_started)
	controller.actor_changed.connect(_on_actor_changed)
	controller.skill_resolved.connect(_on_skill_resolved)
	controller.battle_finished.connect(_on_battle_finished)
	battle_ui.skill_selected.connect(_on_skill_selected)
	battle_ui.end_turn_requested.connect(_on_end_turn_requested)
	controller.start_battle(BattleData.create_combatants())

func _on_battle_started(units: Array[Combatant]) -> void:
	for unit in units:
		var view = combatant_view_scene.instantiate()
		units_root.add_child(view)
		view.position = _position_for(unit)
		view.bind(unit)
		view.click_area.input_event.connect(_on_unit_input.bind(unit))
		combatant_views[unit.id] = view

func _on_actor_changed(actor: Combatant) -> void:
	if actor == null:
		return
	battle_ui.set_round(controller.round_number)
	battle_ui.bind_actor(actor)
	for unit_id in combatant_views:
		var view = combatant_views[unit_id]
		view.set_active(view.combatant == actor)
		view.set_selectable(actor.team == BattleConstants.Team.PLAYER and view.combatant.team != actor.team and view.combatant.is_alive())
	if actor.team == BattleConstants.Team.ENEMY:
		await get_tree().create_timer(0.6).timeout
		controller.enemy_take_turn_if_needed()

func _on_skill_selected(skill: Skill) -> void:
	selected_skill = skill

func _on_unit_input(_viewport, event: InputEvent, _shape_idx: int, target: Combatant) -> void:
	if selected_skill == null:
		return
	if not event is InputEventMouseButton:
		return
	if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var actor := controller.current_actor()
	if actor == null or actor.team != BattleConstants.Team.PLAYER:
		return
	var targets := _targets_for_skill(actor, selected_skill, target)
	controller.player_use_skill(selected_skill, targets)
	selected_skill = null

func _on_end_turn_requested() -> void:
	var actor := controller.current_actor()
	if actor == null or actor.team != BattleConstants.Team.PLAYER:
		return
	controller.player_use_skill(actor.skills[0], _living_enemies(actor).slice(0, actor.skills[0].max_targets))

func _on_skill_resolved(_actor: Combatant, _skill: Skill, _targets: Array, _result: Dictionary) -> void:
	for view in combatant_views.values():
		view.refresh()

func _on_battle_finished(winner_team: BattleConstants.Team) -> void:
	var result := "胜利" if winner_team == BattleConstants.Team.PLAYER else "失败"
	print("Battle finished: %s" % result)

func _targets_for_skill(actor: Combatant, skill: Skill, clicked_target: Combatant) -> Array:
	match skill.target_rule:
		BattleConstants.TargetRule.MULTI_ENEMY:
			return _living_enemies(actor).slice(0, skill.max_targets)
		BattleConstants.TargetRule.ALL_ENEMIES:
			return _living_enemies(actor)
		BattleConstants.TargetRule.MULTI_ALLY:
			return _living_allies(actor).slice(0, skill.max_targets)
		BattleConstants.TargetRule.ALL_ALLIES:
			return _living_allies(actor)
		BattleConstants.TargetRule.SELF:
			return [actor]
		_:
			return [clicked_target]

func _living_enemies(actor: Combatant) -> Array:
	return controller.units.filter(func(unit: Combatant) -> bool: return unit.team != actor.team and unit.is_alive())

func _living_allies(actor: Combatant) -> Array:
	return controller.units.filter(func(unit: Combatant) -> bool: return unit.team == actor.team and unit.is_alive())

func _position_for(unit: Combatant) -> Vector2:
	var enemy_positions := [
		Vector2(430, 285),
		Vector2(625, 250),
		Vector2(820, 230),
		Vector2(1015, 250),
		Vector2(1210, 285)
	]
	var player_positions := [
		Vector2(790, 735),
		Vector2(970, 695),
		Vector2(1150, 695),
		Vector2(1330, 735),
		Vector2(1510, 695)
	]
	return player_positions[unit.position_index] if unit.team == BattleConstants.Team.PLAYER else enemy_positions[unit.position_index]
```

- [ ] **Step 3: Verify combatant input shape**

Confirm `CombatantView.tscn` contains `ClickArea` and `CollisionShape2D`, and `BattleScene.gd` connects `view.click_area.input_event`.

- [ ] **Step 4: Run the scene**

Run:

```powershell
godot --path G:\code\zero-game
```

Expected: A 1920x1080 battle scene opens, with five enemy units in the upper area, five player units in the lower area, and UI laid out like the reference image.

- [ ] **Step 5: Manual interaction test**

In the running scene:

1. Confirm current actor is highlighted.
2. Click a skill button.
3. Click an enemy unit.
4. Confirm HP changes.
5. Wait for enemy turns.
6. Confirm dead units disappear.

Expected: The battle continues until one side dies.

---

### Task 9: Add Battle Result and UI Refresh Polish

**Files:**
- Modify: `scenes/ui/BattleUI.tscn`
- Modify: `scenes/ui/BattleUI.gd`
- Modify: `scenes/battle/BattleScene.gd`

- [ ] **Step 1: Add result label**

Add to `scenes/ui/BattleUI.tscn`:

```ini
[node name="ResultLabel" type="Label" parent="."]
visible = false
offset_left = 760.0
offset_top = 430.0
offset_right = 1160.0
offset_bottom = 540.0
theme_override_font_sizes/font_size = 72
horizontal_alignment = 1
vertical_alignment = 1
```

- [ ] **Step 2: Add UI result method**

Add to `scenes/ui/BattleUI.gd`:

```gdscript
@onready var result_label: Label = $ResultLabel

func show_result(winner_team: BattleConstants.Team) -> void:
	result_label.text = "胜利" if winner_team == BattleConstants.Team.PLAYER else "失败"
	result_label.visible = true
	for button in skill_buttons:
		button.disabled = true
	end_turn_button.disabled = true
```

- [ ] **Step 3: Wire battle result**

Modify `_on_battle_finished` in `scenes/battle/BattleScene.gd`:

```gdscript
func _on_battle_finished(winner_team: BattleConstants.Team) -> void:
	battle_ui.show_result(winner_team)
	for view in combatant_views.values():
		view.set_selectable(false)
```

- [ ] **Step 4: Manual result test**

Run:

```powershell
godot --path G:\code\zero-game
```

Expected: When one side is defeated, input locks and either `胜利` or `失败` appears.

- [ ] **Step 5: Checkpoint**

Run:

```powershell
Select-String -Path scenes\ui\BattleUI.gd, scenes\battle\BattleScene.gd -Pattern "show_result|ResultLabel|battle_finished"
```

Expected: Result display code exists.

---

### Task 10: Final Verification

**Files:**
- Read: `docs/superpowers/specs/2026-06-10-godot-turn-battle-design.md`
- Read: all created files

- [ ] **Step 1: Run headless tests**

Run:

```powershell
godot --path G:\code\zero-game --headless --script res://tests/run_tests.gd
```

Expected: `ALL TESTS PASSED`.

- [ ] **Step 2: Run parser check**

Run:

```powershell
godot --path G:\code\zero-game --headless --quit
```

Expected: No parser or scene load errors.

- [ ] **Step 3: Manual layout verification**

Run:

```powershell
godot --path G:\code\zero-game
```

Verify:

- Top center shows level title and round.
- Left top has retreat, speed, auto, skip.
- Left side has chat, command, status, formation.
- Right side has weather, battle, enemy info.
- Enemy units are in the upper battlefield.
- Player units are in the lower battlefield.
- Unit name, HP, resource, and statuses are visible.
- Current actor panel is in the lower left.
- Four skill buttons are in the bottom center.
- End-turn button is in the lower right.

- [ ] **Step 4: Manual combat verification**

In the running scene:

- Use `裂阵千锋` and confirm it hits 2 enemies.
- Use a sect spell and confirm it spends resource and damages enemies.
- Use a sect obstacle and confirm status text appears on targets.
- Use a sect support skill and confirm status text appears on allies.
- Let enemy AI act and confirm it uses skills without player input.
- Defeat all enemies and confirm victory appears.

- [ ] **Step 5: Spec coverage check**

Open `docs/superpowers/specs/2026-06-10-godot-turn-battle-design.md` and confirm each accepted requirement has working coverage:

- Godot 2D desktop project.
- 5v5 combat.
- Traditional turn order.
- Four active buttons per role.
- Five-element skill structure.
- Resource-gated skills.
- Enemy AI.
- Extermination victory.
- Reference-image UI layout.

Expected: All requirements are covered.
