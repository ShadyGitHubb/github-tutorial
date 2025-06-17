extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _start():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _credits():
	get_tree().change_scene_to_file("res://scenes/credits-page.tscn")

func _quit():
	get_tree().quit()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
