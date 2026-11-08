class_name SprintComponent extends Node

@export var speed_multiplier: float = 1.6
@export_range(-1.0, 1.0) var min_forward_dot: float = 0.0


func get_speed_multiplier(wants_to_sprint: bool, direction: Vector2) -> float:
	if not wants_to_sprint:
		return 1.0

	var forward_dot := direction.normalized().dot(Vector2.UP)

	if forward_dot <= min_forward_dot:
		return 1.0

	return speed_multiplier
