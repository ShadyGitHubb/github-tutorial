extends Area3D

# === CONSTANTS ===
const SUCCESS_PICKUP_MSG: String = "Key picked up successfully."
const DEBUG_INTERACT_MSG: String = "Player interacted with key."
const WARNING_NO_GLOBAL: String = "Global script missing or key_held variable not found."
const GLOBAL_NODE_PATH: String = "/root/Global"

# === INTERACTION FUNCTION ===
func interact() -> void:
	# --- VALIDATION: Ensure Global singleton exists ---
	if not Engine.has_singleton("Global"):
		push_warning(WARNING_NO_GLOBAL)
		return

	# --- VALIDATION: Attempt to retrieve Global node ---
	var global_ref: Node = get_node_or_null(GLOBAL_NODE_PATH)
	if global_ref == null:
		push_warning(WARNING_NO_GLOBAL)
		return
	
	if not global_ref.has_variable("key_held"):
		push_warning(WARNING_NO_GLOBAL)
		return

	# --- MAIN ACTION: Mark key as collected ---
	print(DEBUG_INTERACT_MSG)
	global_ref.key_held = true
	print(SUCCESS_PICKUP_MSG)

	# --- CLEANUP: Remove the key from the scene safely ---
	if is_inside_tree():
		queue_free()
	else:
		push_warning("Attempted to remove key, but node not in scene tree.")
