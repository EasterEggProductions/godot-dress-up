@tool
extends Node

@export var mesh : MeshInstance3D
@export var look_range : float = 0.08
@export var min_interval : float = 1.5
@export var max_interval : float = 4.0
@export var move_speed : float = 4.0

@export var blink_min_interval : float = 2.0
@export var blink_max_interval : float = 8.0
@export var blink_close_time : float = 0.08
@export var blink_hold_time : float = 0.03
@export var blink_open_time : float = 0.15

var target := Vector2.ZERO
var current := Vector2.ZERO
var time_until_next := 0.0
var time_until_blink := 0.0
var time_until_mouth = 0.0

func _ready() -> void:
	_pick_new_target()
	_reset_blink_timer()

func _process(delta: float) -> void:
	if mesh == null:
		return

	time_until_next -= delta
	if time_until_next <= 0.0:
		_pick_new_target()

	time_until_blink -= delta
	if time_until_blink <= 0.0:
		_reset_blink_timer()
		_blink()

	time_until_mouth -= delta
	if time_until_mouth <= 0:
		mesh.get_surface_override_material(1).set_shader_parameter("mouth_state", randi_range(0,8))
		time_until_mouth = randf_range(0.2, 3)

	current = current.lerp(target, 1.0 - exp(-move_speed * delta))

	var mat : ShaderMaterial = mesh.get_surface_override_material(1)
	mat.set_shader_parameter("eye_look", current)

func _pick_new_target() -> void:
	target = Vector2(randf_range(-look_range, look_range), randf_range(-look_range, look_range))
	time_until_next = randf_range(min_interval, max_interval)

func _reset_blink_timer() -> void:
	time_until_blink = randf_range(blink_min_interval, blink_max_interval)

func _blink(left := true, right := true) -> void:
	var mat : ShaderMaterial = mesh.get_surface_override_material(1)
	if mat == null:
		return

	if left:
		_blink_one_eye(mat, "shader_parameter/blink_left")
	if right:
		_blink_one_eye(mat, "shader_parameter/blink_right")

func _blink_one_eye(mat: ShaderMaterial, param: String) -> void:
	var tween := create_tween()
	tween.tween_property(mat, param, 0.0, blink_close_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(blink_hold_time)
	tween.tween_property(mat, param, 1.0, blink_open_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)