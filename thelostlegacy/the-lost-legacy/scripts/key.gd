extends Area3D


func interact():
	print("interacted")
	Global.key_held = true
	queue_free()
