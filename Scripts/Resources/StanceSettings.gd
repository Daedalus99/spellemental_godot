class_name StanceSettings extends Resource

@export var id : StringName
@export var move_speed_mult := 1.0
@export var collider_scale := Vector3.ONE
@export var transition_speed: float = 1.0
@export var blocked_abilities: Array[AbilityIds.Ability] = []

# func _init(
# 	_id: StringName, 
# 	m_speed := 1.0, 
# 	c_scale := Vector3.ONE, 
# 	t_speed := 1.0
# ) -> void:
# 	id = _id
# 	move_speed_mult = m_speed
# 	collider_scale = c_scale
# 	transition_speed = t_speed
