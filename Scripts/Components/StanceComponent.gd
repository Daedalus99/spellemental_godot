class_name StanceComponent extends Node

enum Stance {STAND, CROUCH, PRONE}

@export var stance_scales: Dictionary[Stance, Vector3]= {
	Stance.STAND: Vector3(1, 1, 1),
	Stance.CROUCH: Vector3(1, 0.5, 1),
	Stance.PRONE: Vector3(1, 0.25, 1)
}

@export var current_stance = Stance.STAND
@export var stance_change_speed: float = 10.0
@onready var current_scale: Vector3 = stance_scales.get(current_stance, Vector3.ONE)
var original_scale: Vector3 = Vector3.ZERO

# call this in _physics_process()
func change_stance(body: CharacterBody3D, delta: float, stance: Stance):
	# basically just set the og scale once at the start.
	if original_scale == Vector3.ZERO:
		original_scale = body.scale
		print("Original Scale is %s" %original_scale)
		
	if stance == current_stance:
		return
		
	var target_scale: Vector3 = original_scale * stance_scales.get(stance)
	print("target: %s" %target_scale)
	var weight := 1.0 - exp(-stance_change_speed * delta)
	
	# otherwise lerp height to stance height
	body.scale = lerp(body.scale, target_scale, weight)
	print("body Scale: %s" %body.scale)
	if body.scale.is_equal_approx(target_scale):
		print("Scale reached: %s" %body.scale)
		current_stance = stance
