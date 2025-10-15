extends Node2D

# Duration in seconds for fade in and fade out animations
const FADE_IN_DURATION := 4.0
const FADE_OUT_DURATION := 3.0

# Names of fade in and fade out animations in AnimationPlayer
const FADE_IN_ANIM := "fade in"
const FADE_OUT_ANIM := "fade out"

# Path to next scene file to load after fade out
const NEXT_SCENE_PATH := "res://scenes/title-screen.tscn"

func _ready() -> void:
    # Check if required animations exist before playing
    if $AnimationPlayer.has_animation(FADE_IN_ANIM) and $AnimationPlayer.has_animation(FADE_OUT_ANIM):
        # Play fade in animation and wait for it to finish
        $AnimationPlayer.play(FADE_IN_ANIM)
        await get_tree().create_timer(FADE_IN_DURATION).timeout
        
        # Play fade out animation and wait for it to finish
        $AnimationPlayer.play(FADE_OUT_ANIM)
        await get_tree().create_timer(FADE_OUT_DURATION).timeout
        
        # Check if next scene resource exists, then switch scene
        if ResourceLoader.exists(NEXT_SCENE_PATH):
            get_tree().change_scene_to_file(NEXT_SCENE_PATH)
        else:
            push_error("Scene path does not exist: %s" % NEXT_SCENE_PATH)
    else:
        push_error("Required animations not found in AnimationPlayer")
