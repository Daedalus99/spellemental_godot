class_name PlayerController extends CharacterBody3D

@export_group("Nodes")
@export var cam_controller: CameraController
@export_subgroup("Components")
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: AdvancedJumpComponent

func _physics_process(delta: float) -> void:
	gravity_component.handle_gravity(self, delta)
	movement_component.handle_horizontal_movement(self,input_component.input_horizontal)
	
	jump_component.handle_jump(
		self, 
		input_component.get_jump_input(), 
		input_component.get_jump_input_released()
	)
		
	move_and_slide()
	
func update_rotation(new_rotation: Vector3):
	global_transform.basis = Basis.from_euler(new_rotation)
