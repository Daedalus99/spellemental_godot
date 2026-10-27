class_name InputComponent
extends Node

var input_horizontal: Vector2

func _process(_delta: float) -> void:
	input_horizontal = Input.get_vector("walk_l", "walk_r", "walk_f", "walk_b")

func get_jump_input() -> bool:
	return Input.is_action_just_pressed("jump")

func get_jump_input_released() -> bool:
	return Input.is_action_just_released("jump")
	
func get_sprint_input() -> bool:
	return Input.is_action_pressed("sprint")
	
func get_crouch_input() -> bool:
	return Input.is_action_pressed("crouch_slide")
