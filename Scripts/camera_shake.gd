class_name CameraShake

extends Node

@export var trauma_reduction_rate : float = 1.0
@export var max_x = 10.0
@export var max_y = 10.0
@export var max_z = 5.0
@export var noise : FastNoiseLite
@export var noise_speed = 50.0
@export var CMAERA : Node3D
@export var weapon : WeaponController
@export_range(0.0, 1.0) var trauma_amount : float = 0.0

@onready var inital_rotation = CMAERA.rotation_degrees as Vector3

var trauma = 0.0
var time = 0.0

func _ready() -> void:
	weapon.weapon_fired.connect(add_trauma.bind(trauma_amount))

func _process(delta: float) -> void:
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	CMAERA.rotation_degrees.x = inital_rotation.x + max_x * get_snake_intensity() * get_noise_frome_seed(0)
	CMAERA.rotation_degrees.y = inital_rotation.y + max_y * get_snake_intensity() * get_noise_frome_seed(1)
	CMAERA.rotation_degrees.z = inital_rotation.z + max_z * get_snake_intensity() * get_noise_frome_seed(2)
	
func add_trauma(trauma_amount : float) -> void:
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)
	
func get_snake_intensity() -> float:
	return trauma * trauma 

func get_noise_frome_seed(_seed : float) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
