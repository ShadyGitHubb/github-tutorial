extends Area3D

@export var dialogue_resource: DialogueResource
@export var start_node: String = "start"

var is_talking = false

func interact():
	# Don’t start if already talking or dialogue not set
	if is_talking or dialogue_resource == null:
		return

	is_talking = true
	Global.in_dialogue = true

	# Show dialogue balloon
	var balloon = DialogueManager.show_dialogue_balloon(dialogue_resource, start_node)

	# If no balloon, reset states
	if balloon == null:
		Global.in_dialogue = false
		is_talking = false
		return

	# Connect when the dialogue ends
	if balloon.has_signal("dialogue_finished"):
		balloon.dialogue_finished.connect(_on_dialogue_end)
	elif balloon.has_signal("tree_exited"):
		balloon.tree_exited.connect(_on_dialogue_end)

func _on_dialogue_end():
	is_talking = false
	Global.in_dialogue = false
