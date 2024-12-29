class_name LightDetectionComponent

extends SubViewport

var light_level : float

@export var light_detection : Node3D
@export var sub_viewport : SubViewport

func _ready() -> void:
	Global.light_detection_component = self

	sub_viewport.debug_draw = 2

func _process(delta: float) -> void:
	light_detection.global_position = Global.player.global_position
	var texture = sub_viewport.get_texture()
	var color = get_average_color(texture)
	light_level = color.get_luminance()

func get_average_color(texture: ViewportTexture) -> Color:
	var image = texture.get_image() # Get the Image of the input texture
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS) # Resize the image to one pixel
	return image.get_pixel(0, 0) # Read the color of that pixel
