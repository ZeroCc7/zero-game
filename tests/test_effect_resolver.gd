extends RefCounted

const EffectResolver = preload("res://scripts/battle/effect_resolver.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	_test_spell_deals_damage(failures)
	_test_resource_gate_blocks_skill(failures)
	_test_poison_ticks_damage(failures)
	return failures

func _test_spell_deals_damage(failures: Array[String]) -> void:
	var skill := _spell_skill()
	var attacker := _combatant("attacker", BattleConstants.Team.PLAYER, 100, 80, 18, _skills(skill))
	var target := _combatant("target", BattleConstants.Team.ENEMY, 100, 20, 12, _no_skills())
	var before_hp := target.hp
	var result := EffectResolver.apply_skill(attacker, skill, [target])
	if not result["success"]:
		failures.append("spell should succeed")
	if target.hp >= before_hp:
		failures.append("spell should reduce target hp")

func _test_resource_gate_blocks_skill(failures: Array[String]) -> void:
	var skill := _spell_skill()
	var attacker := _combatant("attacker", BattleConstants.Team.PLAYER, 100, 80, 18, _skills(skill))
	var target := _combatant("target", BattleConstants.Team.ENEMY, 100, 20, 12, _no_skills())
	attacker.resource = 0
	var before_hp := target.hp
	var result := EffectResolver.apply_skill(attacker, skill, [target])
	if result["success"]:
		failures.append("skill should fail when resource is insufficient")
	if target.hp != before_hp:
		failures.append("failed skill should not change target hp")

func _test_poison_ticks_damage(failures: Array[String]) -> void:
	var target := _combatant("target", BattleConstants.Team.ENEMY, 100, 20, 12, _no_skills())
	target.add_status(StatusEffect.new(BattleConstants.StatusKind.POISON, "Poison", 2, 120))
	var before_hp := target.hp
	EffectResolver.apply_turn_start_statuses(target)
	if target.hp != before_hp - 120:
		failures.append("poison should tick exact power damage")

func _spell_skill() -> Skill:
	return Skill.new(
		"spell",
		"Spell",
		BattleConstants.Element.FIRE,
		BattleConstants.SkillKind.SPELL,
		24,
		BattleConstants.TargetRule.SINGLE_ENEMY,
		60,
		1
	)

func _skills(skill: Skill) -> Array[Skill]:
	var skills: Array[Skill] = []
	skills.append(skill)
	return skills

func _no_skills() -> Array[Skill]:
	var skills: Array[Skill] = []
	return skills

func _combatant(
	id: String,
	team: BattleConstants.Team,
	magic: int,
	defense: int,
	speed: int,
	skills: Array[Skill]
) -> Combatant:
	return Combatant.new(
		id,
		id,
		team,
		BattleConstants.Element.FIRE,
		1,
		1000,
		100,
		40,
		magic,
		defense,
		speed,
		skills,
		0
	)
