extends Control

# Path to the title screen scene resource file
const TITLE_SCREEN_PATH = "res://scenes/title-screen.tscn"

# Switches the current scene to the title screen
func _back() -> void:
	# Check if the title screen scene resource exists before changing scenes
	if ResourceLoader.exists(TITLE_SCREEN_PATH):
		get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
	else:
		# Log an error if the target scene file is missing or invalid
		push_error("Scene file missing or invalid: " + TITLE_SCREEN_PATH)
