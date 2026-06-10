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
