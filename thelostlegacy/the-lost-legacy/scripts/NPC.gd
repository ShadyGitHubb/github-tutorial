extends CharacterBody3D

# === CONSTANTS ===
const DEFAULT_START_NODE: String = "start"

# === EXPORTED PROPERTIES ===
@export var dialogue_resource: DialogueResource
@export var start_node: String = DEFAULT_START_NODE
@export var talk_cooldown: float = 0.5   # seconds between allowed opens

# Optional: if you connect an Area3D->body_entered signal to _on_body_entered(),
# this will auto-start dialogue when the Player walks into the NPC's trigger.
@export var auto_trigger_from_area: bool = true

# === STATE ===
var _is_talking: bool = false
var _cooldown_left: float = 0.0


func _process(delta: float) -> void:
	# Cooldown tick
	if _cooldown_left > 0.0:
		_cooldown_left = max(0.0, _cooldown_left - delta)


# Call this from your Player raycast when pressing "E" on the NPC.
func interact() -> void:
	# Block if another dialogue is active, we're cooling down, or already open
	if _is_talking or _cooldown_left > 0.0:
		return
	if Global.in_dialogue:
		return

	# Validate dialogue resource
	if dialogue_resource == null:
		push_warning("Dialogue resource not set on NPC.")
		return

	# Clean / safe start node
	var from_node := start_node.strip_edges()
	if from_node.is_empty():
		from_node = DEFAULT_START_NODE

	# Open balloon
	_is_talking = true
	Global.in_dialogue = true

	var balloon: Node = DialogueManager.show_dialogue_balloon(dialogue_resource, from_node)

	# If the balloon couldn't be created, reset safely
	if balloon == null:
		push_warning("Failed to open dialogue balloon. Check Dialogue Manager settings (balloon scene).")
		_reset_dialogue_state()
		return

	# Connect whichever finish signal exists
	if balloon.has_signal("dialogue_finished"):
		balloon.dialogue_finished.connect(_on_dialogue_end)
	elif balloon.has_signal("tree_exited"):
		balloon.tree_exited.connect(_on_dialogue_end)
	else:
		push_warning("Dialogue balloon has no finish signal; resetting state.")
		_reset_dialogue_state()


func _on_dialogue_end() -> void:
	_reset_dialogue_state()


func _reset_dialogue_state() -> void:
	_is_talking = false
	Global.in_dialogue = false
	_cooldown_left = talk_cooldown


# OPTIONAL: hook your Area3D's "body_entered" to this if you want auto-start on proximity.
# The NPC scene needs an Area3D + CollisionShape3D for this to fire.
func _on_body_entered(body: Node3D) -> void:
	if not auto_trigger_from_area:
		return
	# Match by name or put your Player in a "player" group and check body.is_in_group("player")
	if body.name == "Player" and not Global.in_dialogue:
		interact()
