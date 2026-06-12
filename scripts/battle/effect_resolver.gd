class_name EffectResolver
extends RefCounted

static func apply_skill(attacker: Combatant, skill: Skill, targets: Array) -> Dictionary:
	if attacker == null or skill == null:
		return {"success": false, "reason": "invalid_skill_context"}
	if not attacker.is_alive():
		return {"success": false, "reason": "attacker_dead"}
	if attacker.resource < skill.cost:
		return {"success": false, "reason": "not_enough_resource"}

	attacker.spend_resource(skill.cost)

	var affected: Array[String] = []
	for raw_target in targets.slice(0, skill.max_targets):
		if not raw_target is Combatant:
			continue
		var target := raw_target as Combatant
		if not target.is_alive() and skill.kind != BattleConstants.SkillKind.SUPPORT:
			continue
		_apply_single_target(attacker, skill, target)
		affected.append(target.id)

	attacker.gain_resource(10)
	return {"success": true, "affected": affected}

static func apply_turn_start_statuses(target: Combatant) -> void:
	if target == null:
		return

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

	var active_statuses: Array[StatusEffect] = []
	for status in target.statuses:
		if status.remaining_turns > 0:
			active_statuses.append(status)
	target.statuses = active_statuses

static func can_act(combatant: Combatant) -> bool:
	if combatant == null or not combatant.is_alive():
		return false
	if combatant.has_status(BattleConstants.StatusKind.FREEZE):
		return false
	if combatant.has_status(BattleConstants.StatusKind.SLEEP_LOCK):
		return false
	return true

static func _apply_single_target(attacker: Combatant, skill: Skill, target: Combatant) -> void:
	match skill.kind:
		BattleConstants.SkillKind.PHYSICAL:
			_apply_physical(attacker, skill, target)
		BattleConstants.SkillKind.SPELL:
			_apply_spell(attacker, skill, target)
		BattleConstants.SkillKind.OBSTACLE:
			_apply_obstacle(skill, target)
		BattleConstants.SkillKind.SUPPORT:
			_apply_support(skill, target)
		BattleConstants.SkillKind.ULTIMATE:
			_apply_ultimate(attacker, skill, target)

static func _apply_physical(attacker: Combatant, skill: Skill, target: Combatant) -> void:
	_apply_damage(target, max(1, attacker.attack + skill.power - target.defense / 2))

static func _apply_spell(attacker: Combatant, skill: Skill, target: Combatant) -> void:
	_apply_damage(target, max(1, attacker.magic + skill.power - target.defense / 3))

static func _apply_obstacle(skill: Skill, target: Combatant) -> void:
	if skill.status_kind < 0:
		return
	if skill.status_chance >= 1.0 or randf() <= skill.status_chance:
		target.add_status(StatusEffect.new(skill.status_kind, skill.display_name, skill.status_duration, skill.power))

static func _apply_support(skill: Skill, target: Combatant) -> void:
	if skill.status_kind >= 0:
		target.add_status(StatusEffect.new(skill.status_kind, skill.display_name, skill.status_duration, skill.power))

static func _apply_ultimate(attacker: Combatant, skill: Skill, target: Combatant) -> void:
	_apply_damage(target, max(1, attacker.magic + skill.power * 2 - target.defense / 3))

static func _apply_damage(target: Combatant, amount: int) -> void:
	if target.has_status(BattleConstants.StatusKind.FREEZE):
		return
	var final_amount := amount
	for status in target.statuses:
		if status.kind == BattleConstants.StatusKind.DEFENSE_UP and status.remaining_turns > 0:
			final_amount = max(1, final_amount - status.power)
	target.hp = max(0, target.hp - final_amount)
	if target.has_status(BattleConstants.StatusKind.SLEEP_LOCK):
		_remove_status(target, BattleConstants.StatusKind.SLEEP_LOCK)

static func _remove_status(target: Combatant, kind: BattleConstants.StatusKind) -> void:
	var kept_statuses: Array[StatusEffect] = []
	for status in target.statuses:
		if status.kind != kind:
			kept_statuses.append(status)
	target.statuses = kept_statuses
