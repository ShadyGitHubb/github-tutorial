extends CharacterBody3D

# === CONSTANTS (no magic numbers) ===
# Movement & interaction
const DEFAULT_SPEED: float = 9.0
const DEFAULT_SPRINT_SPEED: float = 14.0
const SPRINT_DURATION: float = 2.0
const SPRINT_COOLDOWN: float = 3.0
const INTERACT_RANGE: float = 3.0

# Camera bob & roll
const CAM_BOB_FREQ_MIN: float = 1.0
const CAM_BOB_FREQ_MAX: float = 8.0
const CAM_BOB_AMP_MIN: float = 0.01
const CAM_BOB_AMP_MAX: float = 0.05
const STRAFE_ROLL_PER_UNIT: float = 2.0     # deg per strafe strength
const ROLL_LERP: float = 0.1

# UI / Anim names
const INTERACT_PROMPT: String = "Press [E] to interact"
const ANIM_IDLE: String = "idle"
const ANIM_WALK: String = "walk"
const ANIM_RUN: String = "run"

# Input names (so we can validate against InputMap)
const ACTION_MOVE_FWD := "move_forward"
const ACTION_MOVE_BACK := "move_backwards"
const ACTION_MOVE_LEFT := "move_left"
const ACTION_MOVE_RIGHT := "move_right"
const ACTION_INTERACT := "interact"
const ACTION_SPRINT := "sprint"

# === PLAYER VARIABLES ===
var speed: float = DEFAULT_SPEED
var sprint_speed: float = DEFAULT_SPRINT_SPEED
var sensitivity: float = 0.002
var look_up_limit: float = 80.0
var look_down_limit: float = 80.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera3D = $Camera3D
@onready var interact_cast: RayCast3D = %InteractCast
@onready var interact_text: Label = %InteractText

var pitch: float = 0.0
var yaw: float = 0.0

# Camera bob state
var bob_time: float = 0.0
var cam_base_pos: Vector3 = Vector3.ZERO
var cam_roll: float = 0.0

# Sprint state
var can_sprint: bool = true
var is_sprinting: bool = false
var sprint_timer: float = 0.0
var cooldown_timer: float = 0.0


# === INITIALISATION ===
# Prepare player input and mouse control when the scene loads.
func _ready() -> void:
	# Validate required nodes & inputs (robustness)
	_validate_setup()

	set_process_input(true)
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera != null:
		cam_base_pos = camera.position


# === PHYSICS LOOP ===
# Main update loop controlling all gameplay logic per frame.
func _physics_process(delta: float) -> void:
	# Invalid/blocked case: dialogue open -> no player actions
	if Global.in_dialogue:
		if interact_text != null:
			interact_text.hide()
		return

	_handle_interaction()
	_handle_look()
	_handle_sprint(delta)
	_handle_movement(delta)
	_check_nearby_interactables()


# === INTERACTION SYSTEM ===
# Handles player interaction with nearby objects using a RayCast.
func _handle_interaction() -> void:
	if interact_cast == null or interact_text == null:
		return  # invalid setup guarded

	if interact_cast.enabled and interact_cast.is_colliding():
		interact_text.text = INTERACT_PROMPT
		interact_text.show()

		var hit: Object = interact_cast.get_collider()
		if Input.is_action_just_pressed(ACTION_INTERACT) and hit != null:
			# Walk up the tree to find a node with interact()
			var obj: Node = hit as Node
			while obj != null and not obj.has_method("interact"):
				obj = obj.get_parent()
			# Expected case: valid interact target
			if obj != null and obj.has_method("interact"):
				obj.interact()
			# Invalid case: nothing with interact() found -> safely do nothing
	else:
		interact_text.hide()


# === CAMERA ROTATION ===
# Controls player camera rotation based on mouse movement.
func _handle_look() -> void:
	if camera == null:
		return
	var mouse_velocity: Vector2 = Input.get_last_mouse_velocity()
	yaw -= mouse_velocity.x * sensitivity
	pitch -= mouse_velocity.y * sensitivity
	# Boundary case: clamp pitch to limits so it never flips
	pitch = clamp(pitch, -look_down_limit, look_up_limit)
	camera.rotation_degrees.x = pitch
	rotation_degrees.y = yaw


# === SPRINT LOGIC ===
# Manages sprinting ability, duration, and cooldown timing.
func _handle_sprint(delta: float) -> void:
	# Expected case: sprint while allowed and key held
	if can_sprint and Input.is_action_pressed(ACTION_SPRINT):
		if sprint_timer < SPRINT_DURATION:
			is_sprinting = true
			sprint_timer = clamp(sprint_timer + delta, 0.0, SPRINT_DURATION)
		else:
			# Boundary reached -> lock & start cooldown
			is_sprinting = false
			can_sprint = false
			cooldown_timer = 0.0
	# Cooldown phase
	elif not can_sprint:
		cooldown_timer += delta
		if cooldown_timer >= SPRINT_COOLDOWN:
			can_sprint = true
			sprint_timer = 0.0
	else:
		# Invalid attempt (e.g., not pressing sprint) -> clear sprint
		is_sprinting = false


# === MOVEMENT + CAMERA BOB + ANIMATIONS ===
# Moves the player, applies camera bobbing, and controls animations.
func _handle_movement(delta: float) -> void:
	var current_speed: float = sprint_speed if is_sprinting else speed

	# Gather input (expected case)
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed(ACTION_MOVE_FWD):
		direction -= transform.basis.z
	if Input.is_action_pressed(ACTION_MOVE_BACK):
		direction += transform.basis.z
	if Input.is_action_pressed(ACTION_MOVE_LEFT):
		direction -= transform.basis.x
	if Input.is_action_pressed(ACTION_MOVE_RIGHT):
		direction += transform.basis.x

	direction = direction.normalized()
	velocity = direction * current_speed
	move_and_slide()

	# Apply camera bobbing to simulate natural movement.
	if camera != null:
		var move_amount: float = direction.length()
		var frequency: float = lerp(CAM_BOB_FREQ_MIN, CAM_BOB_FREQ_MAX, move_amount)
		var amplitude_y: float = lerp(CAM_BOB_AMP_MIN, CAM_BOB_AMP_MAX, move_amount)
		bob_time += delta * frequency
		var y_offset: float = abs(sin(bob_time)) * amplitude_y
		camera.position = cam_base_pos + Vector3(0.0, y_offset, 0.0)

		# Add camera roll when strafing left or right.
		var strafe: float = Input.get_action_strength(ACTION_MOVE_RIGHT) - Input.get_action_strength(ACTION_MOVE_LEFT)
		var target_roll: float = strafe * STRAFE_ROLL_PER_UNIT
		cam_roll = lerp(cam_roll, target_roll, ROLL_LERP)
		camera.rotation_degrees.z = cam_roll

	# Switch between walk, run, and idle animations (validate names)
	_play_movement_animation(direction.length())


# === NEARBY INTERACTABLES ===
# Detects interactable objects within a defined radius.
func _check_nearby_interactables() -> void:
	for node_obj in get_tree().get_nodes_in_group("actionables"):
		var n3d: Node3D = node_obj as Node3D
		if n3d == null or not n3d.has_method("interact"):
			continue  # invalid entry -> skip safely

		var distance: float = global_position.distance_to(n3d.global_position)
		# Boundary: use <= so exactly 3.0 still counts
		if distance <= INTERACT_RANGE:
			print("%s is nearby and can be interacted with." % n3d.name)


# === INTERNAL: animation helper with validation ===
func _play_movement_animation(move_amount: float) -> void:
	if anim_player == null:
		return
	# If the animation names don't exist, avoid errors
	var has_idle := anim_player.has_animation(ANIM_IDLE)
	var has_walk := anim_player.has_animation(ANIM_WALK)
	var has_run := anim_player.has_animation(ANIM_RUN)

	if move_amount > 0.0:
		if is_sprinting and has_run:
			if anim_player.current_animation != ANIM_RUN:
				anim_player.play(ANIM_RUN)
		elif has_walk:
			if anim_player.current_animation != ANIM_WALK:
				anim_player.play(ANIM_WALK)
	else:
		if has_idle and anim_player.current_animation != ANIM_IDLE:
			anim_player.play(ANIM_IDLE)


# === INTERNAL: startup validation (nodes, inputs, animations) ===
func _validate_setup() -> void:
	# Node checks
	if camera == null:
		push_warning("Camera3D is missing.")
	if anim_player == null:
		push_warning("AnimationPlayer is missing.")
	if interact_cast == null:
		push_warning("Interact RayCast3D is missing.")
	if interact_text == null:
		push_warning("InteractText Label is missing.")

	# InputMap checks
	var required_actions: Array[String] = [
		ACTION_MOVE_FWD, ACTION_MOVE_BACK, ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT,
		ACTION_INTERACT, ACTION_SPRINT
	]
	for a in required_actions:
		if not InputMap.has_action(a):
			push_warning("Input action not found: %s" % a)

	# Animation name checks (only if anim_player exists)
	if anim_player != null:
		var names_ok := true
		for n in [ANIM_IDLE, ANIM_WALK, ANIM_RUN]:
			if not anim_player.has_animation(n):
				names_ok = false
				push_warning("Missing animation: %s" % n)
		if names_ok == false:
			push_warning("Consider renaming or adding animations to match constants.")
