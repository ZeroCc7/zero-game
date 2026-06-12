extends Control

signal skill_selected(skill: Skill)
signal end_turn_requested

const GOLD := Color(0.92, 0.70, 0.36, 1.0)
const PALE_GOLD := Color(1.0, 0.88, 0.58, 1.0)
const DARK_PANEL := Color(0.05, 0.045, 0.04, 0.86)

var current_actor: Combatant
var skill_buttons: Array[Button] = []
var selected_skill: Skill

@onready var round_label: Label = $TopInfoPanel/RoundLabel
@onready var condition_label: Label = $TopInfoPanel/ConditionLabel
@onready var current_name: Label = $BottomHud/ActorPanel/CurrentName
@onready var current_hp: ProgressBar = $BottomHud/ActorPanel/CurrentHp
@onready var current_resource: ProgressBar = $BottomHud/ActorPanel/CurrentResource
@onready var portrait_label: Label = $BottomHud/ActorPanel/PortraitFrame/PortraitLabel
@onready var end_turn_button: Button = $BottomHud/EndTurnButton
@onready var result_label: Label = $ResultLabel
@onready var target_hint: Label = $BottomHud/TargetHint
@onready var action_log: Label = $LeftLogPanel/ActionLog
@onready var turn_track: HBoxContainer = $BottomHud/TurnTrack
@onready var round_plate: Label = $BottomHud/RoundPlate

func _ready() -> void:
	skill_buttons = [
		$BottomHud/SkillBar/Skill0,
		$BottomHud/SkillBar/Skill1,
		$BottomHud/SkillBar/Skill2,
		$BottomHud/SkillBar/Skill3
	]
	for index in range(skill_buttons.size()):
		skill_buttons[index].pressed.connect(_on_skill_pressed.bind(index))
	end_turn_button.pressed.connect(func() -> void: emit_signal("end_turn_requested"))
	_style_panels()
	_style_buttons()
	_apply_bar_style(current_hp, Color(0.68, 0.08, 0.07, 1.0), Color(0.13, 0.02, 0.02, 0.95))
	_apply_bar_style(current_resource, Color(0.05, 0.38, 0.85, 1.0), Color(0.02, 0.05, 0.12, 0.95))

func bind_actor(actor: Combatant) -> void:
	current_actor = actor
	current_name.text = actor.display_name
	portrait_label.text = _badge_text(actor)
	current_hp.max_value = actor.max_hp
	current_hp.value = actor.hp
	current_resource.max_value = actor.max_resource
	current_resource.value = actor.resource
	for index in range(skill_buttons.size()):
		var button := skill_buttons[index]
		var skill := actor.skills[index]
		button.text = "%s\n%d" % [skill.display_name, skill.cost]
		button.disabled = actor.resource < skill.cost or actor.team != BattleConstants.Team.PLAYER
		button.modulate = Color.WHITE
	clear_selected_skill()

func set_round(round_number: int) -> void:
	round_label.text = "回合 %d/20" % round_number
	round_plate.text = "第 %d 回合" % round_number
	condition_label.text = "胜利条件：击败敌方所有单位"

func set_turn_order(turn_queue: Array[Combatant]) -> void:
	for child in turn_track.get_children():
		child.queue_free()
	var shown := 0
	for unit in turn_queue:
		if unit == null or not unit.is_alive():
			continue
		turn_track.add_child(_create_turn_badge(unit, shown == 0))
		shown += 1
		if shown >= 14:
			break

func show_result(winner_team: BattleConstants.Team) -> void:
	result_label.text = "胜利" if winner_team == BattleConstants.Team.PLAYER else "失败"
	result_label.visible = true
	target_hint.visible = false
	for button in skill_buttons:
		button.disabled = true
	end_turn_button.disabled = true

func set_selected_skill(skill: Skill) -> void:
	selected_skill = skill
	target_hint.text = "已选择「%s」，点击敌方目标" % skill.display_name
	target_hint.visible = true
	for index in range(skill_buttons.size()):
		var button := skill_buttons[index]
		button.modulate = Color(1.0, 0.82, 0.35, 1.0) if current_actor.skills[index] == skill else Color(0.68, 0.68, 0.68, 1.0)

func clear_selected_skill() -> void:
	selected_skill = null
	target_hint.visible = false
	for button in skill_buttons:
		button.modulate = Color.WHITE

func show_action(actor: Combatant, skill: Skill, affected_count: int) -> void:
	action_log.text = "%s 使用 %s，命中 %d 个目标" % [actor.display_name, skill.display_name, affected_count]

func _create_turn_badge(unit: Combatant, is_current: bool) -> Control:
	var holder := VBoxContainer.new()
	holder.custom_minimum_size = Vector2(58, 50)
	holder.add_theme_constant_override("separation", 1)
	var badge := Label.new()
	badge.custom_minimum_size = Vector2(52, 34)
	badge.text = _badge_text(unit)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_color_override("font_color", PALE_GOLD if unit.team == BattleConstants.Team.PLAYER else Color(1.0, 0.58, 0.48, 1.0))
	badge.add_theme_font_size_override("font_size", 18 if unit.unit_type == BattleConstants.UnitType.PET else 22)
	var fill := Color(0.10, 0.08, 0.045, 0.96) if unit.team == BattleConstants.Team.PLAYER else Color(0.13, 0.035, 0.025, 0.96)
	var border := PALE_GOLD if is_current else (Color(0.35, 0.58, 0.95, 1.0) if unit.team == BattleConstants.Team.PLAYER else Color(0.85, 0.24, 0.18, 1.0))
	badge.add_theme_stylebox_override("normal", _box(fill, border, 2 if is_current else 1, 18))
	holder.add_child(badge)
	var type_label := Label.new()
	type_label.custom_minimum_size = Vector2(52, 12)
	type_label.text = "宠物" if unit.unit_type == BattleConstants.UnitType.PET else "角色"
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_color_override("font_color", Color(0.74, 0.63, 0.42, 1.0))
	type_label.add_theme_font_size_override("font_size", 9)
	holder.add_child(type_label)
	return holder

func _badge_text(unit: Combatant) -> String:
	if unit.team == BattleConstants.Team.PLAYER:
		return "我" if unit.unit_type == BattleConstants.UnitType.CHARACTER else "宠"
	return "敌" if unit.unit_type == BattleConstants.UnitType.CHARACTER else "兽"

func _style_panels() -> void:
	for panel_path in ["TopInfoPanel", "LeftLogPanel", "BottomHud", "BottomHud/ActorPanel", "BottomHud/ActorPanel/PortraitFrame"]:
		var panel := get_node(panel_path) as Control
		panel.add_theme_stylebox_override("panel", _box(DARK_PANEL, Color(0.55, 0.38, 0.18, 0.95), 2, 4))
	round_label.add_theme_color_override("font_color", PALE_GOLD)
	condition_label.add_theme_color_override("font_color", Color(0.94, 0.84, 0.62, 1.0))
	current_name.add_theme_color_override("font_color", PALE_GOLD)
	action_log.add_theme_color_override("font_color", Color(0.95, 0.84, 0.62, 1.0))
	target_hint.add_theme_color_override("font_color", PALE_GOLD)
	round_plate.add_theme_color_override("font_color", PALE_GOLD)

func _style_buttons() -> void:
	for button in skill_buttons:
		button.add_theme_stylebox_override("normal", _box(Color(0.06, 0.055, 0.05, 0.95), Color(0.46, 0.32, 0.16, 1.0), 2, 4))
		button.add_theme_stylebox_override("hover", _box(Color(0.12, 0.095, 0.055, 0.98), GOLD, 2, 4))
		button.add_theme_stylebox_override("pressed", _box(Color(0.20, 0.13, 0.05, 1.0), PALE_GOLD, 2, 4))
		button.add_theme_color_override("font_color", PALE_GOLD)
		button.add_theme_font_size_override("font_size", 22)
	end_turn_button.add_theme_stylebox_override("normal", _box(Color(0.25, 0.08, 0.035, 0.96), Color(0.78, 0.48, 0.20, 1.0), 3, 44))
	end_turn_button.add_theme_stylebox_override("hover", _box(Color(0.38, 0.12, 0.04, 0.98), PALE_GOLD, 3, 44))
	end_turn_button.add_theme_color_override("font_color", PALE_GOLD)
	end_turn_button.add_theme_font_size_override("font_size", 38)
	for path in ["TopRightButtons/SettingsButton", "TopRightButtons/SpeedButton", "TopRightButtons/AutoButton", "TopRightButtons/MenuButton", "BottomHud/ItemButton"]:
		var button := get_node(path) as Button
		button.add_theme_stylebox_override("normal", _box(Color(0.035, 0.03, 0.025, 0.94), Color(0.64, 0.44, 0.20, 1.0), 2, 28))
		button.add_theme_stylebox_override("hover", _box(Color(0.12, 0.08, 0.04, 0.98), PALE_GOLD, 2, 28))
		button.add_theme_color_override("font_color", PALE_GOLD)
		button.add_theme_font_size_override("font_size", 20)

func _apply_bar_style(bar: ProgressBar, fill_color: Color, background_color: Color) -> void:
	bar.add_theme_stylebox_override("fill", _box(fill_color, Color.TRANSPARENT, 0, 4))
	bar.add_theme_stylebox_override("background", _box(background_color, Color(0.35, 0.24, 0.12, 0.95), 1, 4))

func _box(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style

func _on_skill_pressed(index: int) -> void:
	if current_actor == null:
		return
	if index < 0 or index >= current_actor.skills.size():
		return
	emit_signal("skill_selected", current_actor.skills[index])
