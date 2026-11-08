class_name StanceComponent extends Node

# TODO: Link stances to animations? Animate the scale of the colliders, or
# 	scale via the resource's field?

# EXPORTS
@export var stances: Array[StanceSettings] = []
@export var current_stance: StringName = &"stand"
@export_range(0.01, 2.0) var stance_change_duration: float = 0.3

# ONREADY
@onready var _target_stance := current_stance

# var current_scale: Vector3
var _original_scale: Vector3 = Vector3.ZERO
var _stances_by_id: Dictionary[StringName, StanceSettings] = {}
var _stance_tween: Tween


func _ready() -> void:
	# print("Stances: %s" %stances)
	
	# populate _stances_by_id dictionary
	for stance in stances:
		if stance == null or _stances_by_id.has(stance.id):
			print("Skipping stance: %s" %stance)
			continue
		
		print("Adding stance: %s" %stance)
		_stances_by_id[stance.id] = stance
	# current_scale = get_stance(current_stance).collider_scale

# Returns the settings associated with a stance ID, or null if unavailable.
func get_stance(id: StringName) -> StanceSettings:
	return _stances_by_id.get(id)


# Returns whether this character supports the requested stance.
func has_stance(id: StringName) -> bool:
	return _stances_by_id.has(id)

func allows_ability(ability: AbilityIds.Ability) -> bool:
	var stance := get_stance(current_stance)
	if stance == null:
		return true
	return not stance.blocked_abilities.has(ability)

# Returns the movement speed multiplier for the current stance.
func get_speed_multiplier() -> float:
	var stance := get_stance(current_stance)
	if stance == null:
		return 1.0
	return stance.move_speed_mult


# Requests a stance change. Safe to call every physics frame.
func change_stance(body: CharacterBody3D, id: StringName) -> void:
	# Remember the body's original scale before modifying it.
	if _original_scale == Vector3.ZERO:
		_original_scale = body.scale

	# Ignore requests for stances this character doesn't support.
	var stance := get_stance(id)
	if stance == null:
		return

	# Avoid restarting the transition every physics frame.
	if id == current_stance:
		return

	# Stop the previous transition without resetting the body's scale.
	# This allows smooth transitions between any two stances.
	if _stance_tween != null and _stance_tween.is_valid():
		_stance_tween.kill()

	# Update the logical stance immediately.
	current_stance = id

	# Calculate the target relative to the original body scale.
	var target_scale: Vector3 = _original_scale * stance.collider_scale

	# Animate the body from its current scale to the target scale.
	_stance_tween = body.create_tween()
	_stance_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_stance_tween.set_trans(Tween.TRANS_CUBIC)
	_stance_tween.set_ease(Tween.EASE_OUT)

	_stance_tween.tween_property(
		body,
		"scale",
		target_scale,
		stance_change_duration
	)
