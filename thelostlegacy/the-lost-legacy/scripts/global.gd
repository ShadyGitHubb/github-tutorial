extends Node3D

# === CONSTANTS ===
# Default values for global flags to avoid magic literals.
const DEFAULT_KEY_HELD: bool = false
const DEFAULT_IN_DIALOGUE: bool = false

# === GLOBAL VARIABLES ===
# Tracks whether the player currently holds the key item.
var key_held: bool = DEFAULT_KEY_HELD

# Tracks if a dialogue is active (used to prevent player movement).
var in_dialogue: bool = DEFAULT_IN_DIALOGUE
