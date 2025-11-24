extends Path3D
@onready var follower: PathFollow3D = $PathFollow3D
@export var speed := 1.0

func _process(delta: float) -> void:
	follower.progress += delta*speed
