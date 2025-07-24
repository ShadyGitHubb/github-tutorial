extends CharacterBody3D

var speed = 5.0
var sensitivity = 0.003
var look_up_limit = 80
var look_down_limit = 80
@onready var anim_player = $AnimationPlayer

@onready var camera = $Camera3D

var pitch = 0
var yaw = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var mouse_motion = Input.get_last_mouse_velocity()
	yaw -= mouse_motion.x * sensitivity
	pitch -= mouse_motion.y * sensitivity
	pitch = clamp(pitch, -look_down_limit, look_up_limit)

	camera.rotation_degrees.x = pitch
	rotation_degrees.y = yaw

	var direction = Vector3()

	if Input.is_action_just_pressed("move_forward"):
		direction -= transform.basis.z
		if Input.is_action_just_pressed("move_forward"):
			anim_player.play("ArmatureAction")
		elif Input.is_action_just_released("move_forward"):
			anim_player.stop("ArmatureAction")
		print("forwards")

	if Input.is_action_pressed("move_backwards"):
		direction += transform.basis.z
		if Input.is_action_just_pressed("move_backwards"):
			anim_player.play("ArmatureAction")
		print("backwards")

	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
		if Input.is_action_just_pressed("move_left"):
			anim_player.play("ArmatureAction")
		print("left")

	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
		if Input.is_action_just_pressed("move_right"):
			anim_player.play("ArmatureAction")
		print("right")



	direction = direction.normalized()

	velocity = direction * speed

	move_and_slide()
