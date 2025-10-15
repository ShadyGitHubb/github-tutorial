extends Node3D

const ANSWERS = ["128", "One hundred and twenty eight", "128 roses", "64 red, 64 black", "64, 64"]
const TEXTURE_PATH = "res://Sprite3D"  # Replace with your actual PNG path

@export var ui : Control
@export var input_field : TextEdit  # Export a TextEdit node to get user input
@export var roses_sprite : Sprite3D  # Export a Sprite3D to display the PNG

func _ready() -> void:
	ui.hide()

func interact():
	ui.show()

func _answer() -> void:
	var user_text = input_field.text.strip_edges().to_lower()
	
	# Normalize answers for case-insensitive comparison
	var normalized_answers = []
	for ans in ANSWERS:
		normalized_answers.append(ans.to_lower())
	
	if user_text in normalized_answers:
		roses_sprite.texture = load(TEXTURE_PATH)
		roses_sprite.show()
	else:
		roses_sprite.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_DELETE:
			ui.hide()
