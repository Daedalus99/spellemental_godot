class_name MovementComponent
extends Node

@export_group("Settings")
@export var dflt_speed: float = 10

@export_subgroup("Grounded")
@export var ground_accel_speed: float = 50
@export var ground_decel_speed: float = 100

@export_subgroup("Airborn")
@export var air_accel_speed: float = 20
@export var air_decel_speed: float = 5 #3.0
# If going over this, lerp back down even if momentum is being preserved.
@export var max_air_speed: float = 20
@export var momentum_cancel_decel_speed = 0.1

@export_group("Debug")
@export var speed_display: RichTextLabel


# This function is intended to be called during the player controller's _physics_process()
func handle_horizontal_movement(body: CharacterBody3D, delta: float, direction: Vector2, speed_mult: float = 1) -> void:
	direction = direction.limit_length(1.0)
	var dir_len := direction.length() # maybe user is using analog input and just barely touching.
		
	# 1. Convert the 2D input into a 3D direction vector
	var input_dir := Vector3(direction.x, 0, direction.y)
	
	# 2. Rotate the direction vector to match the body's global orientation
	var rotated_dir: Vector3 = (body.global_basis * input_dir).normalized() * dir_len
		
	var velocity_change_speed: float
	if body.is_on_floor():
		velocity_change_speed = ground_accel_speed if dir_len != 0 else ground_decel_speed
	else:
		velocity_change_speed = air_accel_speed if dir_len != 0 else air_decel_speed
	
	# TODO: If airborn, only lerp velocity if the input will increase the velocity in that direction
	# i.e. if you're going faster than the normal airstrafe peed, don't slow the player down if they
	# try to move in the direction they're already going. But if they try to move to the side or 
	# backwards, then it's okay to slow them down to change the velocity, but it won't keep their
	# previous momentum and will then use the default air move speed.
	# Well, actually there's a maximum velocity that we try to stay under regardless of momentum,
	# but that's bigger than the strafe speed.
	var dot = rotated_dir.normalized().dot(current_horizontal_velocity(body).normalized())
	if dot > 0:
		var potential_v = _lerp_ho_velocity(
			body.velocity, 
			rotated_dir * dot * body.velocity, 
			momentum_cancel_decel_speed * delta
		)
	# if the potential new velocity is greater than the max velocity and greater than the current
	# velocity, then don't do anything 
	
	var speed = dflt_speed * speed_mult
	# 3. Apply the rotated direction to X and Z velocities
	body.velocity = _lerp_ho_velocity(
		body.velocity, 
		rotated_dir * speed, 
		velocity_change_speed * delta
	)

	# Slow down the player if they're going over the maximum airspeed
	if not body.is_on_floor() and current_horizontal_velocity(body).length() > max_air_speed:
		var target_velocity: Vector3 = current_horizontal_velocity(body).limit_length(max_air_speed)
		body.velocity = _lerp_ho_velocity(body.velocity, target_velocity, momentum_cancel_decel_speed * delta)
	
	if speed_display:
		speed_display.text="Velocity: %s\nSpeed: %s" %[body.velocity, body.velocity.length()]

func _lerp_ho_velocity(v_start: Vector3, v_target: Vector3, change_speed: float) -> Vector3:
	var v: Vector3 = v_start
	# Move the horizontal velocity as a single vector, not per-axis.
	# Per-axis move_toward causes perpendicular drift at non-cardinal angles
	# because X and Z reach their targets at different times.
	var h_start := Vector3(v_start.x, 0.0, v_start.z)
	var h_target := Vector3(v_target.x, 0.0, v_target.z)
	var h_result := h_start.move_toward(h_target, change_speed)
	v.x = h_result.x
	v.z = h_result.z
	return v
	
func current_horizontal_velocity(body: CharacterBody3D):
	return Vector3(body.velocity.x, 0, body.velocity.z)
