class_name StanceComponent extends Node

enum Stance {STAND, CROUCH, PRONE}

@export var stance_scales: Dictionary[Stance, Vector3]= {
	Stance.STAND: Vector3(1, 1, 1),
	Stance.CROUCH: Vector3(1, 0.5, 1),
	Stance.PRONE: Vector3(1, 0.25, 1)
}

@export var current_stance = Stance.STAND
@export_range(0.01, 2.0) var stance_change_duration: float = 0.3

@onready var _target_stance: Stance = current_stance
var _stance_tween: Tween
@onready var current_scale: Vector3 = stance_scales.get(current_stance, Vector3.ONE)
var original_scale: Vector3 = Vector3.ZERO

# call this in _physics_process()
func change_stance(
	body: CharacterBody3D,
	_delta: float,
	stance: Stance
) -> void:
	if original_scale == Vector3.ZERO:
		original_scale = body.scale

	# Avoid restarting the animation every physics tick.
	if stance == _target_stance:
		return

	_target_stance = stance

	# Interrupt the previous transition at its current scale.
	if _stance_tween != null and _stance_tween.is_valid():
		_stance_tween.kill()

	var target_scale: Vector3 = original_scale * stance_scales[stance]

	_stance_tween = body.create_tween()
	_stance_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_stance_tween.set_trans(Tween.TRANS_CUBIC)
	_stance_tween.set_ease(Tween.EASE_OUT)

	_stance_tween.tween_property(
		body, "scale", target_scale, stance_change_duration
	)

	_stance_tween.tween_callback(
		func(): current_stance = stance
	)
