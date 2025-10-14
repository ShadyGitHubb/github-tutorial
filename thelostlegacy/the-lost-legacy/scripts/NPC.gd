extends CharacterBody3D

# === CONSTANTS ===
const DEFAULT_START_NODE: String = "start"
const WARNING_NO_DIALOGUE: String = "Dialogue resource not set!"
const WARNING_FAILED_BALLOON: String = "Failed to open dialogue balloon."

# === EXPORTED VARIABLES ===
@export var dialogue: DialogueResource
@export var start_node: String = DEFAULT_START_NODE

# === DIALOGUE INTERACTION FUNCTION ===
func interact() -> void:
	# --- VALIDATION: dialogue resource ---
	if dialogue == null:
		push_warning(WARNING_NO_DIALOGUE)
		return

	# --- VALIDATION: start node ---
	if start_node.is_empty():
		start_node = DEFAULT_START_NODE

	# --- START DIALOGUE ---
	Global.in_dialogue = true
	var balloon: Node = DialogueManager.show_dialogue_balloon(dialogue, start_node)

	# --- VALIDATION: balloon creation ---
	if balloon == null:
		push_warning(WARNING_FAILED_BALLOON)
		Global.in_dialogue = false
		return

	# --- CONNECT END EVENTS SAFELY ---
	if balloon.has_signal("dialogue_finished"):
		balloon.dialogue_finished.connect(_on_dialogue_end)
	elif balloon.has_signal("tree_exited"):
		balloon.tree_exited.connect(_on_dialogue_end)
	else:
		# Handles unexpected dialogue system variations
		push_warning("Dialogue balloon has no valid finish signal.")
		Global.in_dialogue = false


# === CLEANUP FUNCTION ===
func _on_dialogue_end() -> void:
	Global.in_dialogue = false
