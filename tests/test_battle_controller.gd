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
