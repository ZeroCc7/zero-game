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
