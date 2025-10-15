extends Control

# Constant for the scene path instead of magic string
const TITLE_SCREEN_PATH = "res://scenes/title-screen.tscn"

func _back():
	# Check if the scene file exists and is valid before changing scene
	if ResourceLoader.exists(TITLE_SCREEN_PATH):
		get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
	else:
		push_error("Scene file missing or invalid: " + TITLE_SCREEN_PATH)
