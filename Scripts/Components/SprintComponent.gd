class_name SprintComponent extends Node

@export var _speed_multiplier: float = 1.6
@export_range(-1.0, 1.0) var min_forward_dot: float = 0.0

func can_sprint(wants_to_sprint: bool, direction: Vector2) -> bool:
	if not wants_to_sprint:
		return false
	var forward_dot := direction.normalized().dot(Vector2.UP)
	return forward_dot >= min_forward_dot

func get_speed_mult() -> float:
	return _speed_multiplier
