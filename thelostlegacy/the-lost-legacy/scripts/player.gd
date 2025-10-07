extends CharacterBody3D

var speed = 9.0
var sensitivity = 0.002
var look_up_limit = 80
var look_down_limit = 80

@onready var anim_player = $AnimationPlayer
@onready var camera = $Camera3D
@onready var interact_cast = %InteractCast
@onready var interact_text = %InteractText
@onready var dialogue_cast = %DialogueCast

var pitch = 0.0
var yaw = 0.0

# simple camera bob
var bob_time = 0.0
var cam_base_pos = Vector3.ZERO
var cam_roll = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam_base_pos = camera.position

func _physics_process(delta):
	# interact
	if interact_cast.enabled and interact_cast.is_colliding():
		interact_text.show()
		var target = interact_cast.get_collider()
		if target != null and Input.is_action_just_pressed("interact") and target.has_method("interact"):
			target.interact()
	else:
		interact_text.hide()

	# mouse look
	var m = Input.get_last_mouse_velocity()
	yaw -= m.x * sensitivity
	pitch -= m.y * sensitivity
	pitch = clamp(pitch, -look_down_limit, look_up_limit)
	camera.rotation_degrees.x = pitch
	rotation_degrees.y = yaw

	# dialogue
	if not dialogue_cast == null:
		var dialogue_option = false
		var dialogue_target = dialogue_cast.get_collider()
		if dialogue_cast.is_colliding():
			if dialogue_cast == dialogue_target.has_mask("Actionables"):
				dialogue_option = true
			if Input.is_action_just_pressed("ui_accept") and dialogue_option == true:
				DialogueManager.show_example_dialogue_balloon(load("res://dialogue/main.dialogue"), "start")
				return
	
	# movement
	var dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir -= transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += transform.basis.x
	dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

	# camera bob + lean
	var move_amount = dir.length()  
	var freq = lerp(1.0, 8.0, move_amount)   
	var amp_y = lerp(0.01, 0.05, move_amount) 
	bob_time += delta * freq
	var y_off = abs(sin(bob_time)) * amp_y
	camera.position = cam_base_pos + Vector3(0, y_off, 0)

	# small roll when strafing
	var strafe = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var target_roll = strafe * 2.0  # degrees
	cam_roll = lerp(cam_roll, target_roll, 0.1)
	camera.rotation_degrees.z = cam_roll

	# animations
	if move_amount > 0.0:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
