extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("fade in")
	await get_tree().create_timer(4).timeout
	$AnimationPlayer.play("fade out")
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://scenes/title-screen.tscn")
pass
