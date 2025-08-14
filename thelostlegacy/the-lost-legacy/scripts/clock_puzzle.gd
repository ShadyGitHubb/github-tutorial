extends Node3D

@export var hour_hand: Node
@export var minute_hand: Node
@export var minute_hand_timer: Node
@export var hour_hand_timer: Node
@export var music_box_scene: PackedScene
var can_rotate_minute = true
var can_rotate_hour = true
@onready var confetti = $CPUParticles3D

@warning_ignore("unused_parameter")
func _process(delta: float):
	# Connect the button's 'pressed' signal to a function in this script
	if Input.is_action_pressed("ui_accept") and can_rotate_minute:
		on_rotate_button_pressed(minute_hand, 60)
		can_rotate_minute = false
		minute_hand_timer.start()
		
	if Input.is_action_pressed("ui_cancel") and can_rotate_hour:
		on_rotate_button_pressed(hour_hand, 12)
		can_rotate_hour = false
		hour_hand_timer.start()
	
		

func on_rotate_button_pressed(hand, time):
	# Define the rotation amount (e.g., 90 degrees around the Z-axis)
	var starting_rotation = hand.rotation.z
	var rotation_amount = deg_to_rad(360/time)
	var rotation_axis = Vector3(0, 0, 1) # Rotate around the Z-axis

	# Apply the rotation
	hand.rotate_object_local(rotation_axis, rotation_amount)
	#print(rad_to_deg(minute_hand.rotation.z))
	#print(rad_to_deg(hour_hand.rotation.z))

	if minute_hand.rotation.z >= deg_to_rad(89.9) and minute_hand.rotation.z <= deg_to_rad(90.1):
		if hour_hand.rotation.z >= deg_to_rad(-0.1) and hour_hand.rotation.z <= deg_to_rad(0.1):
			var confetti = $CPUParticles3D
			confetti.emitting = true
			var music_box = music_box_scene.instantiate()
			music_box.position.x = 17.723
			music_box.position.z = 7.356
			add_sibling(music_box)

func _on_timer_timeout() -> void:
	can_rotate_minute = true

func _on_timer_2_timeout() -> void:
	can_rotate_hour = true
