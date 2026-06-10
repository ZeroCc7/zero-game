class_name Combatant
extends RefCounted

var id: String
var display_name: String
var team: BattleConstants.Team
var element: BattleConstants.Element
var level: int
var max_hp: int
var hp: int
var max_resource: int
var resource: int
var attack: int
var magic: int
var defense: int
var speed: int
var skills: Array[Skill]
var statuses: Array[StatusEffect] = []
var position_index: int

func _init(
	p_id: String,
	p_display_name: String,
	p_team: BattleConstants.Team,
	p_element: BattleConstants.Element,
	p_level: int,
	p_max_hp: int,
	p_max_resource: int,
	p_attack: int,
	p_magic: int,
	p_defense: int,
	p_speed: int,
	p_skills: Array[Skill],
	p_position_index: int
) -> void:
	id = p_id
	display_name = p_display_name
	team = p_team
	element = p_element
	level = p_level
	max_hp = p_max_hp
	hp = p_max_hp
	max_resource = p_max_resource
	resource = p_max_resource / 2
	attack = p_attack
	magic = p_magic
	defense = p_defense
	speed = p_speed
	skills = p_skills
	position_index = p_position_index

func is_alive() -> bool:
	return hp > 0

func has_status(kind: BattleConstants.StatusKind) -> bool:
	for status in statuses:
		if status.kind == kind and status.remaining_turns > 0:
			return true
	return false

func add_status(status: StatusEffect) -> void:
	for existing in statuses:
		if existing.kind == status.kind:
			existing.remaining_turns = max(existing.remaining_turns, status.remaining_turns)
			existing.power = max(existing.power, status.power)
			return
	statuses.append(status)

func spend_resource(amount: int) -> bool:
	if resource < amount:
		return false
	resource -= amount
	return true

func gain_resource(amount: int) -> void:
	resource = min(max_resource, resource + amount)
