extends Node3D

# List of acceptable answers (in various formats) for user input verification
const ANSWERS = [
	"128",
	"one hundred and twenty eight",
	"128 roses",
	"64 red, 64 black",
	"64, 64"
]

# Path to the texture to be displayed when the answer is correct
const TEXTURE_PATH = "res://Sprite3D"  # Replace with your actual texture path (e.g., res://images/roses.png)

# Exported nodes for UI interaction and visual display
@export var ui: Control             # UI container to show/hide input interface
@export var input_field: TextEdit  # TextEdit node to receive user input
@export var roses_sprite: Sprite3D # Sprite3D to display the roses image in the 3D world

# Called when the node enters the scene tree
func _ready() -> void:
	ui.hide()  # Hide the UI initially on scene start

# Called when user interaction happens to show the input UI
func interact() -> void:
	ui.show()

# Checks the user input and displays the roses image if it matches any accepted answers
func _answer() -> void:
	# Get user input text, strip whitespace and convert to lowercase for consistent comparison
	var user_text: String = input_field.text.strip_edges().to_lower()

	# Normalize list of acceptable answers to lowercase for comparison
	var normalized_answers: Array[String] = []
	for ans in ANSWERS:
		normalized_answers.append(ans.to_lower())

	# If user input matches any accepted answer, load and show the texture
	if user_text in normalized_answers:
		var texture = load(TEXTURE_PATH)
		if texture:
			roses_sprite.texture = texture
			roses_sprite.show()
		else:
			push_warning("Texture not found at " + TEXTURE_PATH)
	else:
		# Hide the roses sprite if answer is incorrect or empty
		roses_sprite.hide()

# Handles key input events - hides UI when the Delete key is pressed
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DELETE:
			ui.hide()
