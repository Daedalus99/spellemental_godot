class_name AdvancedJumpComponent
extends Node

@export_group("Settings")
@export var jump_velocity: float = 20.0
@export var num_air_jumps: int = 0

@export_group("Nodes")
@export var buffer_timer: Timer
@export var coyote_timer: Timer

var was_on_floor: bool = false
var air_jumps_remaining: int = 0


func handle_jump(body: CharacterBody3D, want_to_jump: bool, jump_released: bool) -> void:
	var on_floor := body.is_on_floor()

	# Landing
	if on_floor:
		air_jumps_remaining = num_air_jumps

	# Coyote time
	if was_on_floor and not on_floor:
		coyote_timer.start()
	# if not coyote_timer.is_stopped() and not :
	# 	body.velocity.y *= 0.1

	# Jump buffering
	if want_to_jump:
		buffer_timer.start()

	# Execute jump
	if not buffer_timer.is_stopped() and can_jump(on_floor):
		jump(body)

	# Variable jump height
	if jump_released and body.velocity.y > 0:
		body.velocity.y *= 0.5

	was_on_floor = on_floor


func can_jump(on_floor: bool) -> bool:
	return on_floor or not coyote_timer.is_stopped() or air_jumps_remaining > 0


func jump(body: CharacterBody3D) -> void:
	if not body.is_on_floor() and coyote_timer.is_stopped():
		air_jumps_remaining -= 1

	body.velocity.y = jump_velocity
	buffer_timer.stop()
	coyote_timer.stop()
