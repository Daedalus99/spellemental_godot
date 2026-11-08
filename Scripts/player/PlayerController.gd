class_name PlayerController extends CharacterBody3D

@export_group("Nodes")
@export var cam_controller: CameraController
@export_subgroup("Components")
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: AdvancedJumpComponent
@export var stance_component: StanceComponent
@export var sprint_component: SprintComponent

var speed_mult := 1.0
var use_gravity := true
var _can_sprint := true

func _physics_process(delta: float) -> void:
	if use_gravity and stance_component.allows_ability(AbilityIds.Ability.FALL):
		gravity_component.handle_gravity(self, delta)
		
	# reset speed multiplier every frame.
	speed_mult = 1
	
	var requested_stance := &"stand"
	if input_component.get_prone_input():
		requested_stance = &"prone"
	elif input_component.get_crouch_input():
		requested_stance = &"crouch"
		
	if stance_component.allows_ability(AbilityIds.Ability.STANCE):	
		stance_component.change_stance(self, requested_stance)
	speed_mult *= stance_component.get_speed_multiplier()
	
	# Get sprinting. The last thing to get before handling movement?
	if stance_component.allows_ability(AbilityIds.Ability.SPRINT):
		speed_mult *= sprint_component.get_speed_multiplier(
			input_component.get_sprint_input(),
			input_component.input_horizontal
		)
		
	if stance_component.allows_ability(AbilityIds.Ability.MOVE):
		movement_component.handle_horizontal_movement(
			self, 
			input_component.input_horizontal, 
			speed_mult
		)
	
	if stance_component.allows_ability(AbilityIds.Ability.JUMP):
		jump_component.handle_jump(
			self, 
			input_component.get_jump_input(), 
			input_component.get_jump_input_released()
		)
		
	move_and_slide()
	
func update_rotation(new_rotation: Vector3) -> void:
	global_rotation = new_rotation
