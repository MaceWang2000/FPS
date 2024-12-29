class_name WineBarrel

extends RigidBody3D

@export var wood_explode: AudioStreamPlayer3D 
@export var wood_damage : AudioStreamPlayer3D

@export_range(0.0, 10.0, 0.1) var explode_power : float = 1.0 #爆炸冲击力
@export var impulse : float = 10.0

func _ready() -> void:
	contact_monitor = false
	
func explode() -> void:
	get_node("Destruction").destroy(explode_power)
	wood_explode.play()
	
func _on_body_entered(body: Node) -> void:
	explode()

func damage() -> void:
	wood_damage.play()
