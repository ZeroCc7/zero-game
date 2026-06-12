class_name BattleData
extends RefCounted

static func create_combatants() -> Array[Combatant]:
	var player_skills: Dictionary = _create_player_skills()
	var enemy_skills: Dictionary = _create_enemy_skills()
	var units: Array[Combatant] = []

	units.append(Combatant.new("player_gold", "金阙剑修", BattleConstants.Team.PLAYER, BattleConstants.Element.GOLD, 68, 15236, 100, 820, 880, 420, 75, _typed_skills(player_skills, "gold"), 0))
	units.append(Combatant.new("player_wood", "青木医师", BattleConstants.Team.PLAYER, BattleConstants.Element.WOOD, 68, 13390, 100, 520, 760, 460, 66, _typed_skills(player_skills, "wood"), 1))
	units.append(Combatant.new("player_water", "玄水术士", BattleConstants.Team.PLAYER, BattleConstants.Element.WATER, 68, 14561, 100, 480, 740, 720, 58, _typed_skills(player_skills, "water"), 2))
	units.append(Combatant.new("player_fire", "赤焰道君", BattleConstants.Team.PLAYER, BattleConstants.Element.FIRE, 68, 13980, 100, 560, 920, 390, 92, _typed_skills(player_skills, "fire"), 3))
	units.append(Combatant.new("player_earth", "厚土武尊", BattleConstants.Team.PLAYER, BattleConstants.Element.EARTH, 68, 15236, 100, 760, 520, 760, 52, _typed_skills(player_skills, "earth"), 4))

	units.append(Combatant.new("enemy_gold", "断金剑客", BattleConstants.Team.ENEMY, BattleConstants.Element.GOLD, 68, 14589, 100, 760, 780, 400, 70, _typed_skills(enemy_skills, "gold"), 0))
	units.append(Combatant.new("enemy_wood", "腐木咒师", BattleConstants.Team.ENEMY, BattleConstants.Element.WOOD, 68, 13852, 100, 500, 720, 430, 62, _typed_skills(enemy_skills, "wood"), 1))
	units.append(Combatant.new("enemy_water", "幽冥巫师", BattleConstants.Team.ENEMY, BattleConstants.Element.WATER, 68, 14226, 100, 460, 700, 690, 56, _typed_skills(enemy_skills, "water"), 2))
	units.append(Combatant.new("enemy_fire", "黑焰狂徒", BattleConstants.Team.ENEMY, BattleConstants.Element.FIRE, 68, 14127, 100, 540, 860, 380, 88, _typed_skills(enemy_skills, "fire"), 3))
	units.append(Combatant.new("enemy_earth", "岩甲兽灵", BattleConstants.Team.ENEMY, BattleConstants.Element.EARTH, 68, 15236, 100, 720, 480, 740, 50, _typed_skills(enemy_skills, "earth"), 4))

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
			Skill.new("wood_obstacle", "蛇蝎", BattleConstants.Element.WOOD, BattleConstants.SkillKind.OBSTACLE, 24, BattleConstants.TargetRule.MULTI_ENEMY, 90, 5, BattleConstants.StatusKind.POISON, 0.75, 3),
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
			Skill.new("fire_obstacle", "离魂", BattleConstants.Element.FIRE, BattleConstants.SkillKind.OBSTACLE, 26, BattleConstants.TargetRule.MULTI_ENEMY, 0, 5, BattleConstants.StatusKind.SLEEP_LOCK, 0.60, 2),
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

static func _typed_skills(skill_sets: Dictionary, key: String) -> Array[Skill]:
	var typed: Array[Skill] = []
	for skill in skill_sets[key]:
		typed.append(skill)
	return typed
