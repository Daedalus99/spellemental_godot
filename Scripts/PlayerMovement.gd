extends CharacterBody3D

const GRAVITY = 10.0
const AIR_CROUCH_GRAV = 100.0
var gravity = GRAVITY

# Movement
enum State {WALK, RUN, CROUCH, SLIDE, FALL}
var current_state: State = State.WALK
const MOVE_SPEED = {"WALK": 10.0, "RUN": 20.0, "CROUCH": 5.0}
const GROUND_ACCEL = 10.0
const CROUCH_SPEED = 20.0
const SLIDE_DRAG = 0.5
var move_accel
var speed
var crouching: bool = false
var sliding: bool = false
var slide_start_velocity: Vector3
var crouch_val: float = 0

# TODO: Add wall running on slopes between 75-105 degrees
# TODO: decrease uphill walking speed until 45-50 degrees where the player can no longer walk upwards

# Jumping
const JUMP_HEIGHT = 1.5
const JUMP_VELOCITY = 5
const AIR_STRAFE_SPEED = 2.5
const COYOTE_TIME = 0.1
const JUMP_BUFF_TIME = 0.15
var curr_coyote = 0
var curr_jump_buff = 10.0
var prev_grounded=false

# Head bobbing
const BOB_FREQ = 1.5
const BOB_AMP = 0.04
var t_bob = 0
@onready var cam_anchor = $CameraAnchor
var cam_anchor_initial_pos: Vector3
@onready var player_audio: PlayerAudio = $AudioManager

#Strafe leaning
const STRAFE_LEAN_MAX_DEG : float = 2
const STRAFE_LEAN_REACTIVITY : float = 10
const STRAFE_LEAN_SMOOTH: float = 10
var strafe_lean_deg: float = 0

func _ready() -> void:
	cam_anchor_initial_pos = cam_anchor.position

func _physics_process(delta: float) -> void:
	# Get movement input
	var movement_input = Input.get_vector("walk_l", "walk_r", "walk_f", "walk_b")
	var move_dir = (transform.basis * Vector3(movement_input.x, 0, movement_input.y)).normalized()

	# Gravity and coyote time
	if _airborn():
		velocity.y -= gravity * delta
		curr_coyote += delta
		reparent(null)
	else:
		# reparent(get_floor_collider())
		curr_coyote = 0
	
	# Jump buffering for b-hopping
	if curr_jump_buff <= JUMP_BUFF_TIME:
		curr_jump_buff += delta
	
	speed = MOVE_SPEED.get("RUN") if Input.is_action_pressed("sprint") else MOVE_SPEED.get("WALK")
	move_accel = GROUND_ACCEL if is_on_floor() else AIR_STRAFE_SPEED
	
	_do_jump()
	_do_crouch_slide(delta)
	
	# if you're airborne or crouch-sliding, don't lerp the speed unless you're inputting.
	if not (_airborn() or sliding) or move_dir.length() > 0:
		velocity.x = lerp(velocity.x, move_dir.x * speed, delta * move_accel)
		velocity.z = lerp(velocity.z, move_dir.z * speed, delta * move_accel)
		
		# Stop the sliding once the player changes the starting slide-velocity significantly
		if sliding and velocity.dot(slide_start_velocity) < 0.7:
			sliding = false
			slide_start_velocity = Vector3.ZERO
	elif sliding:
		# use SLIDE_DRAG to slow down the player a little bit over time.
		velocity *= (1.0 / (1.0 + delta * SLIDE_DRAG))
	
	if not sliding and is_on_floor():
		_headbob(delta)	
	_strafe_lean(delta)
	move_and_slide()

func _headbob(delta: float) -> void:
	var speed := velocity.length()
	# threshold (prevents footsteps while standing still)
	if speed < 0.1:
		t_bob = 0.0
		cam_anchor.transform.origin = cam_anchor_initial_pos
		return
	# save previous phase before updating
	var prev_phase := fmod(BOB_FREQ * t_bob, TAU)
	# advance bob timer
	t_bob += delta * speed
	# compute new phase
	var new_phase := fmod(BOB_FREQ * t_bob, TAU)
	# apply bob offset
	var pos := cam_anchor_initial_pos
	pos.y += sin(new_phase) * BOB_AMP
	cam_anchor.transform.origin = pos
	# detect wrap-around -> footstep
	if new_phase < prev_phase:
		player_audio.step()
		
func _strafe_lean(delta: float) -> void:
	# Disable leaning in states where it shouldn't happen, if you want
	if _airborn() or sliding:
		# ease back to 0 lean
		var target_lean := 0.0
		strafe_lean_deg = lerpf(strafe_lean_deg, target_lean, delta * STRAFE_LEAN_SMOOTH)
		cam_anchor.rotation_degrees.z = strafe_lean_deg
		return
	# 1. Horizontal velocity (ignore y)
	var horizontal_vel: Vector3 = velocity
	horizontal_vel.y = 0.0

	if horizontal_vel.length() < 0.1:
		# No movement → ease lean back to 0
		var target_lean := 0.0
		strafe_lean_deg = lerpf(strafe_lean_deg, target_lean, delta * STRAFE_LEAN_SMOOTH)
		cam_anchor.rotation_degrees.z = strafe_lean_deg
		return

	# 2. Player's local right direction (positive X)
	var right_dir: Vector3 = -global_transform.basis.x.normalized()

	# 3. Signed strafe speed: >0 = moving right, <0 = moving left
	var strafe_speed: float = horizontal_vel.dot(right_dir)

	# 4. Normalize into [-1, 1] range using a "reactivity" speed
	var target_factor: float = clamp(strafe_speed / STRAFE_LEAN_REACTIVITY, -1.0, 1.0)

	# 5. Target lean in degrees (you can invert sign if you want lean opposite direction)
	var target_lean: float = STRAFE_LEAN_MAX_DEG * target_factor
	# If you want to lean opposite to direction of motion:
	# var target_lean: float = -STRAFE_LEAN_MAX_DEG * target_factor

	# 6. Smooth interpolation
	strafe_lean_deg = lerp(strafe_lean_deg, target_lean, delta * STRAFE_LEAN_SMOOTH)

	# 7. Apply to cam anchor. Use rotation_degrees for degrees.
	cam_anchor.rotation_degrees.z = strafe_lean_deg

func _do_jump():
	if not prev_grounded and is_on_floor():
		player_audio.jumpland()
	prev_grounded = is_on_floor()
	if (Input.is_action_just_pressed("jump")):
		curr_jump_buff = 0
	var jump_queued = curr_jump_buff < JUMP_BUFF_TIME
	if jump_queued and curr_coyote <= COYOTE_TIME:
		velocity.y = JUMP_VELOCITY
		curr_jump_buff = JUMP_BUFF_TIME + 1.0

func _do_crouch_slide(delta):
	if is_on_floor():
		gravity = GRAVITY
		# Start crouching
		if Input.is_action_pressed("crouch_slide") and not crouching:
			crouching = true
			speed = MOVE_SPEED.get("CROUCH")
			# Toggle sliding
			if velocity.length() > 0.5:
				sliding = true
				slide_start_velocity = velocity
	
	# Disable crouching?
	if (_airborn() or Input.is_action_just_released("crouch_slide")) and crouching:
		crouching = false
		sliding = false
		slide_start_velocity = Vector3.ZERO
	
	# Increase the gravity for ground pounding	
	if(_airborn()):
		if Input.is_action_just_pressed("crouch_slide"):
			gravity = AIR_CROUCH_GRAV
	
	var target_scale = 0.5 if crouching else 1.0
	scale.y = lerp(scale.y, target_scale, delta * CROUCH_SPEED)

func _airborn():
	return not is_on_floor()
