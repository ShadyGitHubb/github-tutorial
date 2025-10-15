extends Area3D

# === CONSTANTS: Messages for interaction feedback and warnings ===
const SUCCESS_PICKUP_MSG: String = "Key picked up successfully."
const DEBUG_INTERACT_MSG: String = "Player interacted with key."
const WARNING_NO_GLOBAL: String = "Global singleton missing or 'key_held' variable not found."
const GLOBAL_NODE_PATH: String = "res://scripts/global.gd"

# === FUNCTION: Handles player interaction with the key ===
func interact() -> void:
	"""
	Called when the player interacts with the key.
	Checks for Global singleton and key_held variable, sets key_held true, and removes the key from the scene.
	"""
	
	# --- VALIDATION: Check if Global singleton exists ---
	if not Engine.has_singleton("Global"):
		push_warning(WARNING_NO_GLOBAL)
		return

	# --- VALIDATION: Retrieve the Global script node ---
	var global_ref: Node = get_node_or_null(GLOBAL_NODE_PATH)
	if global_ref == null:
		push_warning(WARNING_NO_GLOBAL)
		return
	
	# --- VALIDATION: Confirm the 'key_held' variable exists in Global ---
	if not global_ref.has_variable("key_held"):
		push_warning(WARNING_NO_GLOBAL)
		return

	# --- MAIN ACTION: Mark the key as collected ---
	print(DEBUG_INTERACT_MSG)
	global_ref.key_held = true
	print(SUCCESS_PICKUP_MSG)

	# --- CLEANUP: Safely remove the key node from the scene ---
	if is_inside_tree():
		queue_free()
	else:
		push_warning("Attempted to remove key, but node is not inside the scene tree.")
