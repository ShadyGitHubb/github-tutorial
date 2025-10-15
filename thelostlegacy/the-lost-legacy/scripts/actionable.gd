extends Area3D

# === CONSTANTS (no magic strings) ===
# Defaults and warnings for safer behaviour.
const DEFAULT_START_NODE: String = "start"
const WARNING_NO_DIALOGUE: String = "Dialogue resource not set!"
const WARNING_NO_BALLOON: String = "Failed to open dialogue balloon."
const WARNING_NO_FINISH_SIGNAL: String = "Dialogue balloon has no finish signal."

# Cooldown so the player can’t reopen the balloon immediately after closing.
const TALK_COOLDOWN: float = 0.5


# === EXPORTED VARIABLES ===
# Dialogue resource to use and the starting node id.
@export var dialogue_resource: DialogueResource
@export var start_node: String = DEFAULT_START_NODE


# === STATE ===
# Prevents opening multiple balloons at once and handles post-close cooldown.
var is_talking: bool = false
var talk_cooldown_left: float = 0.0


# === LIFECYCLE ===
# Count down the anti-spam cooldown.
func _process(delta: float) -> void:
	if talk_cooldown_left > 0.0:
		talk_cooldown_left = max(0.0, talk_cooldown_left - delta)


# === INTERACTION ENTRYPOINT ===
# Called by the player when the raycast hits this node and the user presses Interact.
func interact() -> void:
	# --- VALIDATION: Dialogue data must exist and game must be ready to talk ---
	if dialogue_resource == null:
		push_warning(WARNING_NO_DIALOGUE)
		return
	if is_talking or talk_cooldown_left > 0.0:
		return
	if Global.in_dialogue:
		return

	# Fallback to a safe default start node.
	if start_node.is_empty():
		start_node = DEFAULT_START_NODE

	# --- START DIALOGUE BALLOON ---
	is_talking = true
	Global.in_dialogue = true

	var balloon: Node = DialogueManager.show_dialogue_balloon(dialogue_resource, start_node)

	# --- VALIDATION: Ensure balloon was created ---
	if balloon == null:
		push_warning(WARNING_NO_BALLOON)
		_reset_dialogue_state()
		return

	# --- CONNECT END EVENTS SAFELY (cover addon variants) ---
	if balloon.has_signal("dialogue_finished"):
		balloon.dialogue_finished.connect(_on_dialogue_end)
	elif balloon.has_signal("tree_exited"):
		balloon.tree_exited.connect(_on_dialogue_end)
	else:
		push_warning(WARNING_NO_FINISH_SIGNAL)
		_reset_dialogue_state()


# === CLEANUP ===
# Resets flags when the dialogue sequence ends.
func _on_dialogue_end() -> void:
	_reset_dialogue_state()


# === INTERNAL UTILITY ===
# Centralised reset to keep code DRY and readable.
func _reset_dialogue_state() -> void:
	is_talking = false
	Global.in_dialogue = false
	talk_cooldown_left = TALK_COOLDOWN
