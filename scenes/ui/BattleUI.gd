extends Control

signal skill_selected(skill: Skill)
signal end_turn_requested

var current_actor: Combatant
var skill_buttons: Array[Button] = []

@onready var round_label: Label = $TopPanel/RoundLabel
@onready var current_name: Label = $CurrentPanel/CurrentName
@onready var current_hp: ProgressBar = $CurrentPanel/CurrentHp
@onready var current_resource: ProgressBar = $CurrentPanel/CurrentResource
@onready var end_turn_button: Button = $EndTurnButton
@onready var result_label: Label = $ResultLabel

func _ready() -> void:
	skill_buttons = [$SkillBar/Skill0, $SkillBar/Skill1, $SkillBar/Skill2, $SkillBar/Skill3]
	for index in range(skill_buttons.size()):
		skill_buttons[index].pressed.connect(_on_skill_pressed.bind(index))
	end_turn_button.pressed.connect(func() -> void: emit_signal("end_turn_requested"))

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

func set_round(round_number: int) -> void:
	round_label.text = "回合 %d" % round_number

func show_result(winner_team: BattleConstants.Team) -> void:
	result_label.text = "胜利" if winner_team == BattleConstants.Team.PLAYER else "失败"
	result_label.visible = true
	for button in skill_buttons:
		button.disabled = true
	end_turn_button.disabled = true

func _on_skill_pressed(index: int) -> void:
	if current_actor == null:
		return
	if index < 0 or index >= current_actor.skills.size():
		return
	emit_signal("skill_selected", current_actor.skills[index])
