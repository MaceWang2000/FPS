extends RigidBody3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_node("Destruction").destroy()
