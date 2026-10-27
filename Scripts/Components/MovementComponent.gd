class_name MovementComponent
extends Node

@export_subgroup("Settings")
@export var speed: float = 10
@export var ground_accel_speed: float = 6.0
@export var ground_decel_speed: float = 8.0
@export var air_accel_speed: float = 10.0
@export var air_decel_speed: float = 3.0

func handle_horizontal_movement(body: CharacterBody3D, direction: Vector2) -> void:
	var dir_len = direction.length()
	if dir_len >= 1:
		direction = direction.normalized()
	
	# 1. Convert the 2D input into a 3D direction vector
	var input_dir := Vector3(direction.x, 0, direction.y)
	
	# 2. Rotate the direction vector to match the body's global orientation
	var rotated_dir: Vector3 = (body.global_basis * input_dir).normalized() * dir_len
		
	var velocity_change_speed: float
	if body.is_on_floor():
		velocity_change_speed = ground_accel_speed if dir_len != 0 else ground_decel_speed
	else:
		velocity_change_speed = air_accel_speed if dir_len != 0 else air_decel_speed
		
	# 3. Apply the rotated direction to X and Z velocities
	body.velocity.x = move_toward(body.velocity.x, rotated_dir.x * speed, velocity_change_speed)
	body.velocity.z = move_toward(body.velocity.z, rotated_dir.z * speed, velocity_change_speed)
