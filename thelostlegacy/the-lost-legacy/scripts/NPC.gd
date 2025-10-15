extends CharacterBody3D

# === CONSTANTS (no magic strings) ===
# Dialogue defaults and warnings for missing data.
const DEFAULT_START_NODE: String = "start"
const WARNING_NO_DIALOGUE: String = "Dialogue resource not set!"
const WARNING_FAILED_BALLOON: String = "Failed to open dialogue balloon."
const WARNING_NO_FINISH_SIGNAL: String = "Dialogue balloon has no valid finish signal."

# Small cooldown to prevent opening multiple balloons back-to-back.
const TALK_COOLDOWN: float = 0.5


# === EXPORTED VARIABLES ===
# Dialogue resource reference and starting node name.
@export var dialogue: DialogueResource
@export var start_node: String = DEFAULT_START_NODE


# === STATE ===
# Tracks if a dialogue is currently open and blocks re-entry briefly after close.
var is_talking: bool = false
var talk_cooldown_left: float = 0.0


# === LIFECYCLE ===
# Tick down the cooldown so interact() can work again shortly after closing.
func _process(delta: float) -> void:
	if talk_cooldown_left > 0.0:
		talk_cooldown_left = max(talk_cooldown_left - delta, 0.0)


# === DIALOGUE INTERACTION FUNCTION ===
# Starts a conversation with the player when interacted with.
func interact() -> void:
	# Invalid cases guarded: missing resource, already talking, or cooling down.
	if dialogue == null:
		push_warning(WARNING_NO_DIALOGUE)
		return
	if is_talking or talk_cooldown_left > 0.0:
		return

	# Use a safe default if the provided start node is empty.
	if start_node.is_empty():
		start_node = DEFAULT_START_NODE

	# Open the dialogue balloon.
	is_talking = true
	Global.in_dialogue = true
	var balloon: Node = DialogueManager.show_dialogue_balloon(dialogue, start_node)

	# If the balloon failed to spawn, reset state gracefully.
	if balloon == null:
		push_warning(WARNING_FAILED_BALLOON)
		_reset_dialogue_state()
		return

	# Connect whichever "finished" signal exists (covers different addon versions).
	if balloon.has_signal("dialogue_finished"):
		balloon.dialogue_finished.connect(_on_dialogue_end)
	elif balloon.has_signal("tree_exited"):
		balloon.tree_exited.connect(_on_dialogue_end)
	else:
		push_warning(WARNING_NO_FINISH_SIGNAL)
		_reset_dialogue_state()


# === CLEANUP ===
# Called when the dialogue finishes; returns control to the player.
func _on_dialogue_end() -> void:
	_reset_dialogue_state()


# === INTERNAL UTILITY ===
# Centralised reset keeps code DRY and handles cooldown start.
func _reset_dialogue_state() -> void:
	is_talking = false
	Global.in_dialogue = false
	talk_cooldown_left = TALK_COOLDOWN
