extends Control

# Path to the title screen scene file
const TITLE_SCREEN_PATH = "res://scenes/title-screen.tscn"

# Handles going back to the title screen
func _back():
	# Verify the scene file exists and is valid before attempting to change scene
	if ResourceLoader.exists(TITLE_SCREEN_PATH):
		get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
	else:
		# Log an error if the target scene is missing or invalid
		push_error("Scene file missing or invalid: " + TITLE_SCREEN_PATH)
