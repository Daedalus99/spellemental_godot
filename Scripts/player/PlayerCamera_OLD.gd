extends Node3D

# Looking
const MOUSE_SENSE = 0.03
var player_controller

func _ready() -> void:
	player_controller = get_parent()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player_controller.rotate_y(-event.relative.x * MOUSE_SENSE / 10.0)
		player_controller.cam_anchor.rotate_x(-event.relative.y * MOUSE_SENSE / 10.0)
		player_controller.cam_anchor.rotation.x = clamp(player_controller.cam_anchor.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _process(delta: float) -> void:
	global_transform = player_controller.cam_anchor.get_global_transform_interpolated()
