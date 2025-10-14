extends CharacterBody3D

# === CONSTANTS ===
const DEFAULT_SPEED: float = 9.0
const DEFAULT_SPRINT_SPEED: float = 14.0
const SPRINT_DURATION: float = 2.0
const SPRINT_COOLDOWN: float = 3.0
const INTERACT_RANGE: float = 3.0

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

# === CAMERA BOBBING ===
var bob_time: float = 0.0
var cam_base_pos: Vector3 = Vector3.ZERO
var cam_roll: float = 0.0

# === SPRINT SYSTEM ===
var can_sprint: bool = true
var is_sprinting: bool = false
var sprint_timer: float = 0.0
var cooldown_timer: float = 0.0


func _ready() -> void:
	set_process_input(true)
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam_base_pos = camera.position


func _physics_process(delta: float) -> void:
	if Global.in_dialogue:
		interact_text.hide()
		return

	_handle_interaction()
	_handle_look()
	_handle_sprint(delta)
	_handle_movement(delta)
	_check_nearby_interactables()


# === INTERACTION SYSTEM ===
func _handle_interaction() -> void:
	if interact_cast.enabled and interact_cast.is_colliding():
		interact_text.text = "Press [E] to interact"
		interact_text.show()

		var hit: Object = interact_cast.get_collider()
		if Input.is_action_just_pressed("interact") and hit != null:
			var obj: Node = hit as Node
			while obj != null and not obj.has_method("interact"):
				obj = obj.get_parent()
			if obj != null and obj.has_method("interact"):
				obj.interact()
	else:
		interact_text.hide()


# === CAMERA ROTATION ===
func _handle_look() -> void:
	var m: Vector2 = Input.get_last_mouse_velocity()
	yaw -= m.x * sensitivity
	pitch -= m.y * sensitivity
	pitch = clamp(pitch, -look_down_limit, look_up_limit)
	camera.rotation_degrees.x = pitch
	rotation_degrees.y = yaw


# === SPRINT LOGIC ===
func _handle_sprint(delta: float) -> void:
	if can_sprint and Input.is_action_pressed("sprint"):
		if sprint_timer < SPRINT_DURATION:
			is_sprinting = true
			sprint_timer += delta
		else:
			is_sprinting = false
			can_sprint = false
			cooldown_timer = 0.0
	elif not can_sprint:
		cooldown_timer += delta
		if cooldown_timer >= SPRINT_COOLDOWN:
			can_sprint = true
			sprint_timer = 0.0
	else:
		is_sprinting = false


# === MOVEMENT + CAMERA BOB + ANIMATIONS ===
func _handle_movement(delta: float) -> void:
	var current_speed: float = sprint_speed if is_sprinting else speed

	var dir: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir -= transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += transform.basis.x

	dir = dir.normalized()
	velocity = dir * current_speed
	move_and_slide()

	# Camera bobbing
	var move_amount: float = dir.length()
	var freq: float = lerp(1.0, 8.0, move_amount)
	var amp_y: float = lerp(0.01, 0.05, move_amount)
	bob_time += delta * freq
	var y_off: float = abs(sin(bob_time)) * amp_y
	camera.position = cam_base_pos + Vector3(0.0, y_off, 0.0)

	# Camera roll while strafing
	var strafe: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var target_roll: float = strafe * 2.0
	cam_roll = lerp(cam_roll, target_roll, 0.1)
	camera.rotation_degrees.z = cam_roll

	# Animation handling
	if move_amount > 0.0:
		if is_sprinting and anim_player.current_animation != "run":
			anim_player.play("walk")
		elif not is_sprinting and anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")


# === NEARBY INTERACTABLES ===
func _check_nearby_interactables() -> void:
	for node_obj in get_tree().get_nodes_in_group("actionables"):
		var n3d: Node3D = node_obj as Node3D
		if n3d == null or not n3d.has_method("interact"):
			continue
		var distance: float = global_position.distance_to(n3d.global_position)
		if distance < INTERACT_RANGE:
			print("%s is nearby and can be interacted with." % n3d.name)
