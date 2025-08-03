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

func _physics_process(delta):

	%InteractText.hide()
	if %InteractCast.is_colliding():
		var target = %InteractCast.get_collider()
		if target.has_method("interact"):
			%InteractText.show()
			print("You can pickup this item")
		


	var mouse_motion = Input.get_last_mouse_velocity()
	yaw -= mouse_motion.x * sensitivity
	pitch -= mouse_motion.y * sensitivity
	pitch = clamp(pitch, -look_down_limit, look_up_limit)

	camera.rotation_degrees.x = pitch
	rotation_degrees.y = yaw

	var direction = Vector3()

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	if direction != Vector3.ZERO:
		if not anim_player.is_playing():
			anim_player.play("ArmatureAction")
	else:
		if anim_player.is_playing():
			anim_player.stop()
