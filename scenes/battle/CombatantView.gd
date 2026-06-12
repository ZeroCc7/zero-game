extends Node2D

const PLAYER_GOLD_IDLE_FRAMES := [
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-1.png",
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-2.png",
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-3.png",
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-4.png",
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-5.png",
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-6.png",
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-7.png",
	"res://assets/art/units/gold_swordsman/idle/gold_swordsman_idle-8.png"
]
const PET_GOLD_IDLE_FRAMES := [
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-1.png",
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-2.png",
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-3.png",
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-4.png",
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-5.png",
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-6.png",
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-7.png",
	"res://assets/art/units/gold_lion_pet/idle/gold_lion_pet_idle-8.png"
]

var combatant: Combatant
var last_hp: int = -1
var base_scale := Vector2.ONE

@onready var click_area: Area2D = $ClickArea
@onready var ring: ColorRect = $Ring
@onready var body: ColorRect = $Body
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var name_label: Label = $NameLabel
@onready var hp_bar: ProgressBar = $HpBar
@onready var hp_value_label: Label = $HpBar/HpValueLabel
@onready var resource_bar: ProgressBar = $ResourceBar
@onready var status_label: Label = $StatusLabel
@onready var damage_label: Label = $DamageLabel

func _ready() -> void:
	_apply_bar_style(hp_bar, Color(0.72, 0.05, 0.04, 1.0), Color(0.12, 0.02, 0.02, 0.95))
	_apply_bar_style(resource_bar, Color(0.08, 0.45, 0.95, 1.0), Color(0.02, 0.05, 0.12, 0.95))
	damage_label.visible = false

func bind(p_combatant: Combatant) -> void:
	combatant = p_combatant
	last_hp = combatant.hp
	base_scale = Vector2(0.68, 0.68) if combatant.unit_type == BattleConstants.UnitType.PET else Vector2(0.82, 0.82)
	scale = base_scale
	_update_static_colors()
	_apply_unit_sprite()
	refresh()

func refresh() -> void:
	if combatant == null:
		return
	var hp_delta := 0
	if last_hp >= 0:
		hp_delta = last_hp - combatant.hp
	name_label.text = combatant.display_name
	hp_bar.max_value = combatant.max_hp
	hp_bar.value = combatant.hp
	hp_value_label.text = "%d/%d" % [combatant.hp, combatant.max_hp]
	resource_bar.max_value = combatant.max_resource
	resource_bar.value = combatant.resource
	visible = combatant.is_alive()
	var status_names: Array[String] = []
	for status in combatant.statuses:
		status_names.append(status.display_name)
	status_label.text = " ".join(status_names)
	if hp_delta > 0:
		_show_damage(hp_delta)
	last_hp = combatant.hp

func set_active(is_active: bool) -> void:
	scale = base_scale * 1.12 if is_active else base_scale

func set_selectable(is_selectable: bool) -> void:
	modulate = Color(1.25, 1.16, 0.72, 1.0) if is_selectable else Color.WHITE
	click_area.input_pickable = is_selectable

func _show_damage(amount: int) -> void:
	damage_label.text = "-%d" % amount
	damage_label.visible = true
	damage_label.modulate = Color(1.0, 0.16, 0.08, 1.0)
	damage_label.position = Vector2(-58, -150)
	body.modulate = Color(1.8, 1.8, 1.8, 1.0)
	sprite.modulate = Color(1.8, 1.8, 1.8, 1.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position", Vector2(-58, -190), 0.55)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.55)
	tween.tween_property(body, "modulate", Color.WHITE, 0.22)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.22)
	tween.finished.connect(func() -> void: damage_label.visible = false)

func _apply_bar_style(bar: ProgressBar, fill_color: Color, background_color: Color) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_left = 3
	fill.corner_radius_bottom_right = 3
	var background := StyleBoxFlat.new()
	background.bg_color = background_color
	background.corner_radius_top_left = 3
	background.corner_radius_top_right = 3
	background.corner_radius_bottom_left = 3
	background.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", background)

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

func _apply_unit_sprite() -> void:
	var frame_paths := _sprite_frame_paths()
	if frame_paths.is_empty():
		sprite.visible = false
		body.visible = true
		return

	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 8.0)

	var playback_paths := frame_paths.duplicate()
	for index in range(frame_paths.size() - 2, 0, -1):
		playback_paths.append(frame_paths[index])

	for path in playback_paths:
		var texture := load(path) as Texture2D
		if texture == null:
			sprite.visible = false
			body.visible = true
			return
		frames.add_frame("idle", texture)

	sprite.sprite_frames = frames
	sprite.animation = "idle"
	sprite.visible = true
	body.visible = false
	sprite.play("idle")

func _sprite_frame_paths() -> Array:
	if combatant.id == "player_gold":
		return PLAYER_GOLD_IDLE_FRAMES
	if combatant.id == "pet_gold":
		return PET_GOLD_IDLE_FRAMES
	return []
