class_name PlayerController extends CharacterBody3D

@export_group("Nodes")
@export var cam_controller: CameraController
@export_subgroup("Components")
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: AdvancedJumpComponent
@export var stance_component: StanceComponent

func _physics_process(delta: float) -> void:
	gravity_component.handle_gravity(self, delta)
	
	movement_component.handle_horizontal_movement(
		self,input_component.input_horizontal,
		 input_component.get_sprint_input()
	)
	
	var requested_stance := StanceComponent.Stance.STAND

	if input_component.get_prone_input():
		requested_stance = StanceComponent.Stance.PRONE
	elif input_component.get_crouch_input():
		requested_stance = StanceComponent.Stance.CROUCH

	stance_component.change_stance(self, delta, requested_stance)
	
	
	jump_component.handle_jump(
		self, 
		input_component.get_jump_input(), 
		input_component.get_jump_input_released()
	)
		
	move_and_slide()
	
func update_rotation(new_rotation: Vector3) -> void:
	global_rotation = new_rotation
