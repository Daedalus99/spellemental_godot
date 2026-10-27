class_name MouseCaptureComponent extends Node

@export_group("Settings")
@export var current_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity: float = 0.001

var _mouse_input: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_input -= event.screen_relative * mouse_sensitivity

func _ready() -> void:
	Input.mouse_mode = current_mouse_mode

func consume_mouse_input():
	var input := _mouse_input
	_mouse_input = Vector2.ZERO
	return input
