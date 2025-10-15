extends Node3D

# Constants defining steps and angles for clock hands
const MINUTE_HAND_STEPS := 60           # Number of steps for full minute hand rotation (1 minute per step)
const HOUR_HAND_STEPS := 12             # Number of steps for full hour hand rotation (1 hour per step)
const QUARTER_TURN_RAD := deg_to_rad(90)  # 90 degrees in radians (target minute hand position)
const ANGLE_TOLERANCE := deg_to_rad(0.1)  # Allowed error tolerance for angle checking in radians
const KEY_POSITION := Vector3(46.806, 0, 58.069)  # Position to spawn the key when puzzle is solved

# Exported nodes assigned in editor
@export var hour_hand: Node              # Reference to hour hand node
@export var minute_hand: Node            # Reference to minute hand node
@export var minute_hand_timer: Timer     # Timer controlling minute hand rotation cooldown
@export var hour_hand_timer: Timer       # Timer controlling hour hand rotation cooldown
@export var key: PackedScene             # Packed scene for the key to spawn

# State flags to control hand rotation availability
var can_rotate_minute = true
var can_rotate_hour = true

# Reference to confetti particle system node
@onready var confetti = $CPUParticles3D

func _process(delta: float):
	# Rotate minute hand when "ui_accept" action is pressed and rotation is allowed
	if Input.is_action_pressed("ui_accept") and can_rotate_minute:
		if is_instance_valid(minute_hand) and is_instance_valid(minute_hand_timer):
			on_rotate_button_pressed(minute_hand, MINUTE_HAND_STEPS)
			can_rotate_minute = false
			minute_hand_timer.start()
		
	# Rotate hour hand when "ui_cancel" action is pressed and rotation is allowed
	if Input.is_action_pressed("ui_cancel") and can_rotate_hour:
		if is_instance_valid(hour_hand) and is_instance_valid(hour_hand_timer):
			on_rotate_button_pressed(hour_hand, HOUR_HAND_STEPS)
			can_rotate_hour = false
			hour_hand_timer.start()

# Rotates a specified hand by a fraction of a full rotation and checks for puzzle completion
func on_rotate_button_pressed(hand, steps):
	if not is_instance_valid(hand):
		return
	
	var rotation_amount = deg_to_rad(360 / steps)  # Angle to rotate (360 degrees divided by steps)
	var rotation_axis = Vector3(0, 0, 1)            # Rotation axis (Z-axis)
	hand.rotate_object_local(rotation_axis, rotation_amount)
	
	# If clock is solved after this rotation, show confetti and spawn the key
	if is_clock_solved():
		show_confetti_and_spawn_key()

# Checks if the clock hands are set to the correct positions with tolerance
func is_clock_solved() -> bool:
	var min_valid = abs(minute_hand.rotation.z - QUARTER_TURN_RAD) <= ANGLE_TOLERANCE
	var hour_valid = abs(hour_hand.rotation.z) <= ANGLE_TOLERANCE
	return min_valid and hour_valid

# Enables confetti particles and spawns the key at the defined position
func show_confetti_and_spawn_key():
	if is_instance_valid(confetti):
		confetti.emitting = true
	if is_instance_valid(key):
		var spawned_key = key.instantiate()
		spawned_key.position = KEY_POSITION
		add_sibling(spawned_key)

# Timer callback to re-enable minute hand rotation
func _on_timer_timeout() -> void:
	can_rotate_minute = true

# Timer callback to re-enable hour hand rotation
func _on_timer_2_timeout() -> void:
	can_rotate_hour = true
