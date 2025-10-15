extends Node3D

# === GLOBAL GAME STATE ===
# Manages shared game values accessible from anywhere.
# Acts as a simple global data manager for flags such as dialogue state, quest progress, or item possession.

# === CONSTANTS ===
# Default values for global flags to avoid magic literals.
const DEFAULT_KEY_HELD: bool = false
const DEFAULT_IN_DIALOGUE: bool = false

# === GLOBAL VARIABLES ===
# Tracks whether the player currently holds the key item.
var key_held: bool = DEFAULT_KEY_HELD

# Tracks if a dialogue is active (used to prevent player movement).
var in_dialogue: bool = DEFAULT_IN_DIALOGUE

# === VALIDATION FUNCTION ===
# Ensures all global variables are in a valid state during initialization.
func _ready() -> void:
	_validate_state()

# === UTILITY FUNCTIONS ===
# Validates that globals are booleans; resets invalid values to defaults.
func _validate_state() -> void:
	if typeof(key_held) != TYPE_BOOL:
		push_warning("Invalid type for key_held, resetting to default.")
		key_held = DEFAULT_KEY_HELD

	if typeof(in_dialogue) != TYPE_BOOL:
		push_warning("Invalid type for in_dialogue, resetting to default.")
		in_dialogue = DEFAULT_IN_DIALOGUE

# === SAFE ACCESSORS ===
# Returns whether the player currently holds the key.
func has_key() -> bool:
	return key_held

# Sets the key possession status and validates globals.
func set_key(value: bool) -> void:
	key_held = value
	_validate_state()

# Returns whether a dialogue is currently active.
func is_in_dialogue() -> bool:
	return in_dialogue

# Sets the dialogue active status and validates globals.
func set_in_dialogue(value: bool) -> void:
	in_dialogue = value
	_validate_state()
