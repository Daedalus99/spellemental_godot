class_name CameraController extends Node3D

@export var player_controller: PlayerController
@export var mouse_capture_component: MouseCaptureComponent
@export_group("Settings")
@export_range(-90, -60) var tilt_lower_limit: int = -90
@export_range(60, 90) var tilt_upper_limit: int = 90

var _rotation: Vector3

func _process(delta: float) -> void:
	update_camera_rotation(mouse_capture_component.consume_mouse_input())

func update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x 
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))
	
	var _player_rotation := Vector3(0.0, _rotation.y, 0.0)
	var _camera_rotation := Vector3(_rotation.x, 0.0, 0.0)
	
	rotation = Vector3(_rotation.x, 0.0, 0.0)
	player_controller.update_rotation(Vector3(0.0, _rotation.y, 0.0))
	
	_rotation.z = 0

# func update_camera_height(delta: float, direction: int) -> void:
# 	if position.y >= crouch_offset and position.y <= DEFAULT_HEIGHT:
# 		position.y = clampf(position.y + (crouch_speed * direction) * delta, crouch_offset, DEFAULT_HEIGHT)
