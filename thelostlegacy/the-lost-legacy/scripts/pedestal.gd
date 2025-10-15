extends Node3D

const ANSWERS = [
	"128",
	"one hundred and twenty eight",
	"128 roses",
	"64 red, 64 black",
	"64, 64"
]

const TEXTURE_PATH = "res://Sprite3D"  # Replace with your actual texture path (e.g., res://images/roses.png)

@export var ui: Control
@export var input_field: TextEdit
@export var roses_sprite: Sprite3D

func _ready() -> void:
	ui.hide()

func interact() -> void:
	ui.show()

func _answer() -> void:
	var user_text: String = input_field.text.strip_edges().to_lower()

	# Normalize answers for case-insensitive comparison
	var normalized_answers: Array[String] = []
	for ans in ANSWERS:
		normalized_answers.append(ans.to_lower())

	if user_text in normalized_answers:
		var texture = load(TEXTURE_PATH)
		if texture:
			roses_sprite.texture = texture
			roses_sprite.show()
		else:
			push_warning("Texture not found at " + TEXTURE_PATH)
	else:
		roses_sprite.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DELETE:
			ui.hide()
