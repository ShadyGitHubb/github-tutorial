extends Node3D

const MINUTE_HAND_STEPS := 60
const HOUR_HAND_STEPS := 12
const QUARTER_TURN_RAD := deg_to_rad(90)
const ANGLE_TOLERANCE := deg_to_rad(0.1)
const KEY_POSITION := Vector3(46.806, 0, 58.069)

@export var hour_hand: Node
@export var minute_hand: Node
@export var minute_hand_timer: Timer
@export var hour_hand_timer: Timer
@export var key: PackedScene
var can_rotate_minute = true
var can_rotate_hour = true
@onready var confetti = $CPUParticles3D

func _process(delta: float):
	if Input.is_action_pressed("ui_accept") and can_rotate_minute:
		if is_instance_valid(minute_hand) and is_instance_valid(minute_hand_timer):
			on_rotate_button_pressed(minute_hand, MINUTE_HAND_STEPS)
			can_rotate_minute = false
			minute_hand_timer.start()
		
	if Input.is_action_pressed("ui_cancel") and can_rotate_hour:
		if is_instance_valid(hour_hand) and is_instance_valid(hour_hand_timer):
			on_rotate_button_pressed(hour_hand, HOUR_HAND_STEPS)
			can_rotate_hour = false
			hour_hand_timer.start()

func on_rotate_button_pressed(hand, steps):
	if not is_instance_valid(hand):
		return
	
	var rotation_amount = deg_to_rad(360 / steps)
	var rotation_axis = Vector3(0, 0, 1) # Rotate around the Z-axis
	hand.rotate_object_local(rotation_axis, rotation_amount)
	
	# Check for puzzle completion
	if is_clock_solved():
		show_confetti_and_spawn_key()

func is_clock_solved() -> bool:
	var min_valid = abs(minute_hand.rotation.z - QUARTER_TURN_RAD) <= ANGLE_TOLERANCE
	var hour_valid = abs(hour_hand.rotation.z) <= ANGLE_TOLERANCE
	return min_valid and hour_valid

func show_confetti_and_spawn_key():
	if is_instance_valid(confetti):
		confetti.emitting = true
	if is_instance_valid(key):
		var spawned_key = key.instantiate()
		spawned_key.position = KEY_POSITION
		add_sibling(spawned_key)

func _on_timer_timeout() -> void:
	can_rotate_minute = true

func _on_timer_2_timeout() -> void:
	can_rotate_hour = true
