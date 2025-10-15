extends Control

# Paths to key scenes used for navigation
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const CREDITS_SCENE_PATH: String = "res://scenes/credits-page.tscn"

func _ready() -> void:
	# Show the mouse cursor when this UI is ready
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _start() -> void:
	# Load and switch to the main gameplay scene, if valid
	if _is_scene_path_valid(MAIN_SCENE_PATH):
		get_tree().change_scene_to_file(MAIN_SCENE_PATH)
	else:
		print("Error: Main scene path invalid.")

func _credits() -> void:
	# Load and switch to the credits scene, if valid
	if _is_scene_path_valid(CREDITS_SCENE_PATH):
		get_tree().change_scene_to_file(CREDITS_SCENE_PATH)
	else:
		print("Error: Credits scene path invalid.")

func _quit() -> void:
	# Quit the game unless running inside the editor (in which case print a message)
	if Engine.is_editor_hint():
		print("Quit requested in editor, ignored.")
	else:
		get_tree().quit()

func _is_scene_path_valid(path: String) -> bool:
	# Check if the provided path is non-empty and ends with the expected .tscn extension
	return path != "" and path.ends_with(".tscn")
