class_name PlayerController extends CharacterBody3D

@export_group("Nodes")
@export var cam_controller: CameraController
@onready var state_chart: StateChart = $StateChartRoot
@export_subgroup("Components")
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: AdvancedJumpComponent
@export var stance_component: StanceComponent
@export var sprint_component: SprintComponent
@export var footstep_component: FootstepComponent

var speed_mults: Dictionary[StringName,float] = {}

func _physics_process(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event(&"grounded")
	else:
		state_chart.send_event(&"airborn")
		
	# TODO: check if the 'Air' state is active
	gravity_component.handle_gravity(self, delta)
		
	if input_component.get_prone_input():
		state_chart.send_event(&"stance_prone")
	elif input_component.get_crouch_input():
		state_chart.send_event(&"stance_crouch")
	else:
		state_chart.send_event(&"stance_stand")
	# Set the speed multiplier for whatever stnace we're in.
	speed_mults[&"stance"] = stance_component.get_speed_multiplier()
	
	# Get sprinting. The last thing to get before handling movement?
	var has_input := input_component.input_horizontal.length() > 0.1
	if sprint_component.can_sprint(input_component.get_sprint_input(), input_component.input_horizontal):
		state_chart.send_event(&"move_sprint")
	elif has_input:
		state_chart.send_event(&"move_walk")
	else:
		state_chart.send_event(&"move_idle")
		
	# this basically is like multiplying all mults together :)
	var speed_mult: float = speed_mults.values().reduce(func(acc, n): return acc * n, 1)
	movement_component.handle_horizontal_movement(
		self, 
		input_component.input_horizontal, 
		speed_mult
	)
	
	jump_component.handle_jump(
		self, 
		input_component.get_jump_input(), 
		input_component.get_jump_input_released()
	)
		
	move_and_slide()
	
func update_rotation(new_rotation: Vector3) -> void:
	global_rotation = new_rotation

# State Machine Signals

## Stance Signals
func _on_stand_state_entered() -> void:
	stance_component.change_stance(self, &"stand")

func _on_crouch_state_entered() -> void:
	stance_component.change_stance(self, &"crouch")

func _on_prone_state_entered() -> void:
	stance_component.change_stance(self, &"prone")

func _on_sprint_state_entered() -> void:
	speed_mults[&"sprint"] = sprint_component.get_speed_mult()
	
func _on_sprint_state_exited() -> void: 
	speed_mults.erase(&"sprint")

## "Where" Signals
func _on_ground_state_entered() -> void:
	print("Landed!")

func _on_air_state_entered() -> void:
	print("Falling!")

func _on_wall_state_entered() -> void:
	print("Wallbound!")
