class_name FootstepComponent extends Node

# TODO: Footsteps should have different sounds depending on the material
# 	being walked on.
@export var step_sound: AudioStreamPlayer3D
@export var enabled_states: Array[AtomicState]
@export var step_freq: float = 2


func _ready() -> void:
	changeFreq(step_freq)

func _play_audio_loop() -> void:
	while is_inside_tree():
		_step()
		await get_tree().create_timer(1.0/step_freq).timeout

func _step() -> void:
	step_sound.play()

func changeFreq(new_freq: float) -> void:
	step_freq = new_freq

func shouldPlayLoop() -> bool:
	for state in enabled_states:
		if state.active:
			return true
	return false
