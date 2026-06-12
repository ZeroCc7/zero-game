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
		view.refresh()
		view.set_active(view.combatant == actor)
		view.set_selectable(actor.team == BattleConstants.Team.PLAYER and view.combatant.team != actor.team and view.combatant.is_alive())
	if actor.team == BattleConstants.Team.ENEMY:
		await get_tree().create_timer(0.6).timeout
		controller.enemy_take_turn_if_needed()

func _on_skill_selected(skill: Skill) -> void:
	var actor := controller.current_actor()
	if actor == null or actor.team != BattleConstants.Team.PLAYER:
		return
	if skill.target_rule == BattleConstants.TargetRule.MULTI_ALLY or skill.target_rule == BattleConstants.TargetRule.ALL_ALLIES or skill.target_rule == BattleConstants.TargetRule.SELF:
		controller.player_use_skill(skill, _targets_for_skill(actor, skill, actor))
		selected_skill = null
		return
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
	selected_skill = null
	battle_ui.show_result(winner_team)
	for view in combatant_views.values():
		view.set_selectable(false)

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
