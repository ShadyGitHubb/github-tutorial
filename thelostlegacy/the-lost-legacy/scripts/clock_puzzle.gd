extends Node3D

@export var clockpuzzle: Node


@warning_ignore("unused_parameter")
func _process(delta: float):
	# Connect the button's 'pressed' signal to a function in this script
	if Input.is_action_just_pressed("ui_accept"):
		on_rotate_button_pressed()
	
		

func on_rotate_button_pressed():
	# Define the rotation amount (e.g., 90 degrees around the Y-axis)
	var rotation_amount = deg_to_rad(45)
	var rotation_axis = Vector3(0, 1, 0) # Rotate around the Y-axis

	# Apply the rotation
	rotate_object_local(rotation_axis, rotation_amount)
	print(rotation.y)

	if rotation.y >= deg_to_rad(44.9) and rotation.y <= deg_to_rad(45.1):
		if clockpuzzle.rotation.x >= deg_to_rad(44.9) and clockpuzzle.rotation.x <= deg_to_rad(45.1):
			print("Done")
	
