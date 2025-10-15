extends Area3D

# === CONSTANTS ===
const ANIM_OPEN: String = "Open_Both"
const MSG_GATE_OPENED: String = "Gate opened successfully."
const MSG_NO_KEY: String = "Player attempted to open gate without key."
const WARNING_NO_ANIM: String = "AnimationPlayer node missing or animation not found."
const WARNING_NO_GLOBAL: String = "Global script missing or key_held variable not found."
const KEY_HELD_VAR_NAME: String = "key_held"

# === INTERACTION FUNCTION ===
func interact() -> void:
	# --- VALIDATION: Check if Global singleton exists and has the key_held variable ---
	if not Engine.has_singleton("Global"):
		push_warning(WARNING_NO_GLOBAL)
		return

	var global_ref: Node = get_node_or_null("/root/Global")
	if global_ref == null or not global_ref.has_variable(KEY_HELD_VAR_NAME):
		push_warning(WARNING_NO_GLOBAL)
		return

	# --- Validate key_held's type and get the value ---
	var key_held = global_ref.get(KEY_HELD_VAR_NAME)
	if typeof(key_held) != TYPE_BOOL:
		push_warning(WARNING_NO_GLOBAL)
		return

	# --- MAIN LOGIC: Check if player holds the key ---
	if key_held:
		# Check if AnimationPlayer node exists before playing animation
		var anim_player: AnimationPlayer = $AnimationPlayer
		if anim_player == null:
			push_warning(WARNING_NO_ANIM)
			return

		# Play the gate opening animation if available
		if anim_player.has_animation(ANIM_OPEN):
			anim_player.play(ANIM_OPEN)
			print(MSG_GATE_OPENED)
		else:
			push_warning(WARNING_NO_ANIM)
	else:
		# Player does not have the key
		print(MSG_NO_KEY)
