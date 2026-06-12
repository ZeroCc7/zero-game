extends RefCounted

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const BattleData = preload("res://scripts/battle/battle_data.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	_test_first_actor_is_highest_speed(failures)
	_test_victory_when_enemies_dead(failures)
	_test_controlled_actor_is_skipped(failures)
	_test_player_party_has_front_row_pets(failures)
	_test_enemy_party_supports_ten_units(failures)
	return failures

func _test_first_actor_is_highest_speed(failures: Array[String]) -> void:
	var controller := BattleController.new()
	controller.start_battle(BattleData.create_combatants())
	var actor := controller.current_actor()
	if actor == null:
		failures.append("first actor should exist")
	elif actor.id != "player_fire":
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

func _test_controlled_actor_is_skipped(failures: Array[String]) -> void:
	var controller := BattleController.new()
	var units := BattleData.create_combatants()
	controller.start_battle(units)
	if controller.turn_queue.size() < 2:
		failures.append("controlled actor setup should have at least two actors")
		return
	var first_actor := controller.current_actor()
	var controlled_actor := controller.turn_queue[1]
	controlled_actor.add_status(StatusEffect.new(BattleConstants.StatusKind.FREEZE, "Freeze", 1, 0))
	controller.player_use_skill(first_actor.skills[0], [])
	var next_actor := controller.current_actor()
	if next_actor == null:
		failures.append("controlled actor skip should leave another actor")
	elif next_actor == controlled_actor:
		failures.append("controlled actor should be skipped after acting unit advances")

func _test_player_party_has_front_row_pets(failures: Array[String]) -> void:
	var counts := _count_team(BattleConstants.Team.PLAYER)
	if counts["characters"] != 5:
		failures.append("player party should keep five characters")
	if counts["pets"] != 5:
		failures.append("player party should add one pet per character")

func _test_enemy_party_supports_ten_units(failures: Array[String]) -> void:
	var counts := _count_team(BattleConstants.Team.ENEMY)
	if counts["characters"] != 5:
		failures.append("enemy party should keep five characters")
	if counts["pets"] != 5:
		failures.append("enemy party should support five pets")

func _count_team(team: BattleConstants.Team) -> Dictionary:
	var counts := {"characters": 0, "pets": 0}
	for unit in BattleData.create_combatants():
		if unit.team != team:
			continue
		if unit.unit_type == BattleConstants.UnitType.CHARACTER:
			counts["characters"] += 1
		elif unit.unit_type == BattleConstants.UnitType.PET:
			counts["pets"] += 1
			if unit.skills.size() < 4:
				counts["pets"] = -99
	return counts
