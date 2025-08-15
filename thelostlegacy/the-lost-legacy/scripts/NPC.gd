extends CharacterBody3D

@onready var anim := %AnimationPlayer

func _ready():
	anim.play("ArmatureAction")
	anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(name: StringName) -> void:
	if name == "ArmatureAction":
		anim.play("ArmatureAction")
