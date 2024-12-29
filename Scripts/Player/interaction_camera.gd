extends Camera3D

@export var MAIN_CAMERA : Camera3D

func _process(delta: float) -> void:
	global_transform = MAIN_CAMERA.global_transform
