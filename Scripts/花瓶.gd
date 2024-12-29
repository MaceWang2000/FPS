extends RigidBody3D

@export var impulse : float = 10.0
@export var interactable : Interactable
@export var area : Area3D
@export var broken : AudioStreamPlayer3D
@export_range(10.0, 20.0, 1.0) var damage : float

func _ready() -> void:
	contact_monitor = false
	Global.iteam_health_component.death.connect(explode)
	
func _process(delta: float) -> void:
	pass

func explode() -> void:
	Events.object_explode.emit()
	play_audio()
	area.queue_free()
	get_node("Destruction").destroy()
	Global.is_explode = true

func _on_body_entered(body: Node) -> void:
	explode()
	if body is Enemy:
		Global.enemy_health_component.enemy_hurt(damage)

func play_audio() -> void:
	broken.play()
