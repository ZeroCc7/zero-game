extends Node2D

var combatant: Combatant

@onready var click_area: Area2D = $ClickArea
@onready var ring: ColorRect = $Ring
@onready var body: ColorRect = $Body
@onready var name_label: Label = $NameLabel
@onready var hp_bar: ProgressBar = $HpBar
@onready var resource_bar: ProgressBar = $ResourceBar
@onready var status_label: Label = $StatusLabel

func bind(p_combatant: Combatant) -> void:
	combatant = p_combatant
	_update_static_colors()
	refresh()

func refresh() -> void:
	if combatant == null:
		return
	name_label.text = combatant.display_name
	hp_bar.max_value = combatant.max_hp
	hp_bar.value = combatant.hp
	resource_bar.max_value = combatant.max_resource
	resource_bar.value = combatant.resource
	visible = combatant.is_alive()
	var status_names: Array[String] = []
	for status in combatant.statuses:
		status_names.append(status.display_name)
	status_label.text = " ".join(status_names)

func set_active(is_active: bool) -> void:
	scale = Vector2(1.12, 1.12) if is_active else Vector2.ONE

func set_selectable(is_selectable: bool) -> void:
	modulate = Color(1.25, 1.25, 1.25, 1.0) if is_selectable else Color.WHITE
	click_area.input_pickable = is_selectable

func _update_static_colors() -> void:
	if combatant.team == BattleConstants.Team.PLAYER:
		ring.color = Color(0.1, 0.45, 1.0, 0.65)
	else:
		ring.color = Color(0.9, 0.18, 0.12, 0.65)

	match combatant.element:
		BattleConstants.Element.GOLD:
			body.color = Color(0.85, 0.70, 0.25, 1.0)
		BattleConstants.Element.WOOD:
			body.color = Color(0.20, 0.70, 0.35, 1.0)
		BattleConstants.Element.WATER:
			body.color = Color(0.25, 0.65, 0.90, 1.0)
		BattleConstants.Element.FIRE:
			body.color = Color(0.90, 0.25, 0.15, 1.0)
		BattleConstants.Element.EARTH:
			body.color = Color(0.65, 0.48, 0.25, 1.0)
