extends Node3D

@export var hour_hand: Node
@export var minute_hand: Node

@warning_ignore("unused_parameter")
func _process(delta: float):
	# Connect the button's 'pressed' signal to a function in this script
	if Input.is_action_just_pressed("ui_accept"):
		on_rotate_button_pressed(minute_hand)
	if Input.is_action_just_pressed("ui_cancel"):
		on_rotate_button_pressed(hour_hand)
	
		

func on_rotate_button_pressed(hand):
	# Define the rotation amount (e.g., 90 degrees around the Y-axis)
	var rotation_amount = deg_to_rad(45)
	var rotation_axis = Vector3(0, 1, 0) # Rotate around the Y-axis

	# Apply the rotation
	hand.rotate_object_local(rotation_axis, rotation_amount)
	#print(rad_to_deg(minute_hand.rotation.y))
	#print(rad_to_deg(hour_hand.rotation.y))

	if minute_hand.rotation.y >= deg_to_rad(44.9) and minute_hand.rotation.y <= deg_to_rad(45.1):
		if hour_hand.rotation.y >= deg_to_rad(44.9) and hour_hand.rotation.y <= deg_to_rad(45.1):
			print("Done")
	
