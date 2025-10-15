extends Node3D

# === GLOBAL GAME STATE ===
# Stores shared values that can be accessed from anywhere in the game.
# This acts as a simple and reliable global data manager for common variables
# such as dialogue state, quest progress, or key possession.


# === CONSTANTS ===
# Default values for global flags (avoids magic literals).
const DEFAULT_KEY_HELD: bool = false
const DEFAULT_IN_DIALOGUE: bool = false


# === GLOBAL VARIABLES ===
# Tracks whether the player has collected the key item.
var key_held: bool = DEFAULT_KEY_HELD

# Tracks if a dialogue is currently active (prevents player movement).
var in_dialogue: bool = DEFAULT_IN_DIALOGUE


# === VALIDATION FUNCTION ===
# Ensures all globals are in a valid state and not left undefined.
func _ready() -> void:
	_validate_state()


# === UTILITY FUNCTIONS ===
# Ensures global values are valid booleans, reassigning defaults if not.
func _validate_state() -> void:
	if typeof(key_held) != TYPE_BOOL:
		push_warning("Invalid type for key_held, resetting to default.")
		key_held = DEFAULT_KEY_HELD

	if typeof(in_dialogue) != TYPE_BOOL:
		push_warning("Invalid type for in_dialogue, resetting to default.")
		in_dialogue = DEFAULT_IN_DIALOGUE


# === SAFE ACCESSORS ===
# These helper methods make the script flexible for future expansion.
func has_key() -> bool:
	return key_held


func set_key(value: bool) -> void:
	key_held = value
	_validate_state()


func is_in_dialogue() -> bool:
	return in_dialogue


func set_in_dialogue(value: bool) -> void:
	in_dialogue = value
	_validate_state()
