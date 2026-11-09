class_name FootstepComponent extends Node

# TODO: Footsteps should have different sounds depending on the material
# 	being walked on.
@export var step_sound: AudioStreamPlayer3D
@export var enabled_states: Array[AtomicState]
@export var step_freq: float = 2.4
@export var foot_target: Node3D


func _ready() -> void:
	if not foot_target:
		push_warning("Footstep audio will not play if foot_target is not set!")
	else:
		step_sound.reparent(foot_target)
		step_sound.position = Vector3.ZERO
		_play_audio_loop()

func _play_audio_loop() -> void:
	print("Starting audio loop!")
	while is_inside_tree():
		await get_tree().create_timer(1.0/step_freq).timeout
		if should_play_loop():
			_step()
		
func _step() -> void:
	step_sound.play()
	print("STEP!")

func change_freq(new_freq: float) -> void:
	step_freq = new_freq

func should_play_loop() -> bool:
	for state in enabled_states:
		print("State %s is %s" %[state.name, state.active] )
		if state.active:
			return true
		
	return false
