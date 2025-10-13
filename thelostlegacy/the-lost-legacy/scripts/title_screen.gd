extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Bring the user from the title screen to the main game.
func _start():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# Bring the user from the title screen to the credits page.
func _credits():
	get_tree().change_scene_to_file("res://scenes/credits-page.tscn")

# Allow the user to quit and close the program.
func _quit():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
