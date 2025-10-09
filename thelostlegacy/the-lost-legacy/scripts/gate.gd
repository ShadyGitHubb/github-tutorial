extends Node3D


func interact():
	if Global.key_held:
		$AnimationPlayer.play("Open_Both")
	
	else:
		pass
	
