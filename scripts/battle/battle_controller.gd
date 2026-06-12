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
	winner_team = -1
	round_number = 1
	_rebuild_turn_queue()
	phase = BattleConstants.BattlePhase.WAITING_FOR_PLAYER_SKILL
	emit_signal("battle_started", units)
	_check_victory()
	if not is_finished():
		var actor := _prepare_next_actor()
		if actor != null:
			_update_phase_for_actor(actor)
			emit_signal("actor_changed", actor)

func current_actor() -> Combatant:
	while not turn_queue.is_empty() and not turn_queue[0].is_alive():
		turn_queue.pop_front()
	return null if turn_queue.is_empty() else turn_queue[0]

func is_finished() -> bool:
	return phase == BattleConstants.BattlePhase.FINISHED

func player_use_skill(skill: Skill, targets: Array) -> Dictionary:
	var actor := current_actor()
	if actor == null or actor.team != BattleConstants.Team.PLAYER or is_finished():
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
	var skill = action["skill"]
	if skill == null:
		_advance_turn()
		return

	var result := EffectResolver.apply_skill(actor, skill, action["targets"])
	emit_signal("skill_resolved", actor, skill, action["targets"], result)
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

	var actor := _prepare_next_actor()
	if actor == null:
		return
	_update_phase_for_actor(actor)
	emit_signal("actor_changed", actor)

func _rebuild_turn_queue() -> void:
	turn_queue = []
	for unit in units:
		if unit.is_alive():
			turn_queue.append(unit)
	turn_queue.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.speed > b.speed)

func _check_victory() -> void:
	var player_alive := false
	var enemy_alive := false
	for unit in units:
		if not unit.is_alive():
			continue
		if unit.team == BattleConstants.Team.PLAYER:
			player_alive = true
		elif unit.team == BattleConstants.Team.ENEMY:
			enemy_alive = true

	if player_alive and enemy_alive:
		return

	winner_team = BattleConstants.Team.PLAYER if player_alive else BattleConstants.Team.ENEMY
	phase = BattleConstants.BattlePhase.FINISHED
	emit_signal("battle_finished", winner_team)

func _update_phase_for_actor(actor: Combatant) -> void:
	if actor == null:
		return
	if actor.team == BattleConstants.Team.PLAYER:
		phase = BattleConstants.BattlePhase.WAITING_FOR_PLAYER_SKILL
	else:
		phase = BattleConstants.BattlePhase.ENEMY_ACTING

func _prepare_next_actor() -> Combatant:
	while true:
		if turn_queue.is_empty():
			round_number += 1
			_rebuild_turn_queue()
		var actor := current_actor()
		if actor == null:
			return null

		var can_act_before_tick := EffectResolver.can_act(actor)
		EffectResolver.apply_turn_start_statuses(actor)
		_check_victory()
		if is_finished():
			return null

		if can_act_before_tick:
			return actor

		turn_queue.pop_front()
	return null
