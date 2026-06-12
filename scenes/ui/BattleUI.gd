extends Control

signal skill_selected(skill: Skill)
signal end_turn_requested

var current_actor: Combatant
var skill_buttons: Array[Button] = []
var selected_skill: Skill

@onready var round_label: Label = $TopPanel/RoundLabel
@onready var current_name: Label = $CurrentPanel/CurrentName
@onready var current_hp: ProgressBar = $CurrentPanel/CurrentHp
@onready var current_resource: ProgressBar = $CurrentPanel/CurrentResource
@onready var end_turn_button: Button = $EndTurnButton
@onready var result_label: Label = $ResultLabel
@onready var target_hint: Label = $TargetHint
@onready var action_log: Label = $ActionLog

func _ready() -> void:
	skill_buttons = [$SkillBar/Skill0, $SkillBar/Skill1, $SkillBar/Skill2, $SkillBar/Skill3]
	for index in range(skill_buttons.size()):
		skill_buttons[index].pressed.connect(_on_skill_pressed.bind(index))
	end_turn_button.pressed.connect(func() -> void: emit_signal("end_turn_requested"))
	_apply_bar_style(current_hp, Color(0.72, 0.05, 0.04, 1.0), Color(0.12, 0.02, 0.02, 0.95))
	_apply_bar_style(current_resource, Color(0.08, 0.45, 0.95, 1.0), Color(0.02, 0.05, 0.12, 0.95))

func bind_actor(actor: Combatant) -> void:
	current_actor = actor
	current_name.text = actor.display_name
	current_hp.max_value = actor.max_hp
	current_hp.value = actor.hp
	current_resource.max_value = actor.max_resource
	current_resource.value = actor.resource
	for index in range(skill_buttons.size()):
		var button := skill_buttons[index]
		var skill := actor.skills[index]
		button.text = "%s\n%d" % [skill.display_name, skill.cost]
		button.disabled = actor.resource < skill.cost or actor.team != BattleConstants.Team.PLAYER
	clear_selected_skill()

func set_round(round_number: int) -> void:
	round_label.text = "回合 %d" % round_number

func show_result(winner_team: BattleConstants.Team) -> void:
	result_label.text = "胜利" if winner_team == BattleConstants.Team.PLAYER else "失败"
	result_label.visible = true
	target_hint.visible = false
	for button in skill_buttons:
		button.disabled = true
	end_turn_button.disabled = true

func set_selected_skill(skill: Skill) -> void:
	selected_skill = skill
	target_hint.text = "已选择：%s，点击敌方目标" % skill.display_name
	target_hint.visible = true
	for index in range(skill_buttons.size()):
		var button := skill_buttons[index]
		button.modulate = Color(1.0, 0.82, 0.32, 1.0) if current_actor.skills[index] == skill else Color.WHITE

func clear_selected_skill() -> void:
	selected_skill = null
	target_hint.visible = false
	for button in skill_buttons:
		button.modulate = Color.WHITE

func show_action(actor: Combatant, skill: Skill, affected_count: int) -> void:
	action_log.text = "%s 施放 %s，命中 %d 个目标" % [actor.display_name, skill.display_name, affected_count]

func _apply_bar_style(bar: ProgressBar, fill_color: Color, background_color: Color) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 4
	fill.corner_radius_top_right = 4
	fill.corner_radius_bottom_left = 4
	fill.corner_radius_bottom_right = 4
	var background := StyleBoxFlat.new()
	background.bg_color = background_color
	background.corner_radius_top_left = 4
	background.corner_radius_top_right = 4
	background.corner_radius_bottom_left = 4
	background.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", background)

func _on_skill_pressed(index: int) -> void:
	if current_actor == null:
		return
	if index < 0 or index >= current_actor.skills.size():
		return
	emit_signal("skill_selected", current_actor.skills[index])
