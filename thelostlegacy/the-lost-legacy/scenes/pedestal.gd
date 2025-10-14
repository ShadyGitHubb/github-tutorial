extends Node3D
@export var ui : Control
@export var input_field : TextEdit  # Export a TextEdit node to get user input
@export var roses_sprite : Sprite3D  # Export a Sprite2D to display the PNG

var answers = ["128", "One hundred and twenty eight", "128 roses", "64 red, 64 black", "64, 64"]

func _ready() -> void:
	ui.hide()


func interact():
	ui.show()


func _answer() -> void:
	if input_field.text in answers:
		roses_sprite.texture = load("res://Sprite3D")
		roses_sprite.show()
	else:
		roses_sprite.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_DELETE:
			ui.hide()
