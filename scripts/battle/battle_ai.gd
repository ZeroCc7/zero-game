class_name BattleAI
extends RefCounted

static func choose_action(actor: Combatant, units: Array[Combatant]) -> Dictionary:
	if actor == null or actor.skills.is_empty():
		return {"skill": null, "targets": []}

	var enemies: Array[Combatant] = []
	var allies: Array[Combatant] = []
	for unit in units:
		if not unit.is_alive():
			continue
		if unit.team == actor.team:
			allies.append(unit)
		else:
			enemies.append(unit)

	var usable: Array[Skill] = []
	for skill in actor.skills:
		if actor.resource >= skill.cost:
			usable.append(skill)
	if usable.is_empty():
		usable.append(actor.skills[0])

	allies.sort_custom(func(a: Combatant, b: Combatant) -> bool: return _hp_ratio(a) < _hp_ratio(b))
	for skill in usable:
		if skill.kind != BattleConstants.SkillKind.SUPPORT or skill.status_kind != BattleConstants.StatusKind.REGEN:
			continue
		var low_allies: Array[Combatant] = []
		for ally in allies:
			if ally.hp < ally.max_hp * 0.45:
				low_allies.append(ally)
		if not low_allies.is_empty():
			return {"skill": skill, "targets": low_allies.slice(0, skill.max_targets)}

	var damage_skills: Array[Skill] = []
	for skill in usable:
		if skill.kind == BattleConstants.SkillKind.PHYSICAL or skill.kind == BattleConstants.SkillKind.SPELL or skill.kind == BattleConstants.SkillKind.ULTIMATE:
			damage_skills.append(skill)

	var selected_skill := damage_skills[0] if not damage_skills.is_empty() else usable[0]
	enemies.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.hp < b.hp)
	return {"skill": selected_skill, "targets": enemies.slice(0, selected_skill.max_targets)}

static func _hp_ratio(unit: Combatant) -> float:
	if unit.max_hp <= 0:
		return 0.0
	return float(unit.hp) / float(unit.max_hp)
