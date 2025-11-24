class_name PlayerAudio extends Node
@onready var footstep_stream :AudioStreamPlayer = $FootstepStream
@onready var jumpland_stream :AudioStreamPlayer = $JumpLandStream

func step():
	footstep_stream.play()

func jumpland():
	jumpland_stream.play()
