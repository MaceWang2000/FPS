class_name LightDetect

extends Node3D

@export var sub_viewport : SubViewport
@export var camera: Camera3D

var light_level : float

func _ready() -> void:
	Global.light_detect = self

func _process(delta: float) -> void:
	var image : Image = sub_viewport.get_texture().get_image()
	var floats : Array[float]
	var mesh = get_node("MeshInstance3D")

	camera.global_position = Vector3(mesh.global_position.x, mesh.global_position.y + 0.3, mesh.global_position.z)

	for y in range(0, image.get_height()):
		for x in range(0, image.get_width()):
			var pixel = image.get_pixel(x, y)
			var light_value = (pixel.r + pixel.g + pixel.b) / 3
			floats.append(light_value)
	light_level = average(floats)

func average(numbers : Array) -> float:
	var sum = 0.0
	
	for n in numbers:
		sum += n
	return sum / numbers.size()
