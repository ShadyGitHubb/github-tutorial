extends Control

const MAIN_SCENE_PATH : String = "res://scenes/main.tscn"
const CREDITS_SCENE_PATH : String = "res://scenes/credits-page.tscn"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _start():
	if _is_scene_path_valid(MAIN_SCENE_PATH):
		get_tree().change_scene_to_file(MAIN_SCENE_PATH)
	else:
		print("Error: Main scene path invalid.")

func _credits():
	if _is_scene_path_valid(CREDITS_SCENE_PATH):
		get_tree().change_scene_to_file(CREDITS_SCENE_PATH)
	else:
		print("Error: Credits scene path invalid.")

func _quit():
	if Engine.is_editor_hint():
		print("Quit requested in editor, ignored.")
	else:
		get_tree().quit()

func _is_scene_path_valid(path: String) -> bool:
	# Basic check for empty or malformed path (example only)
	return path != "" and path.ends_with(".tscn")
