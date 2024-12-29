class_name ImpulseComponent

extends Node

@export var impulse : float = 10.0

func _ready() -> void:
	Global.weapon.weapon_hit.connect(add_impulse)
	
func add_impulse(collider : RigidBody3D) -> void:
	if Global.player.CAMERA != null:
		$"../BulletHit".play()
		collider.apply_impulse((-Global.player.CAMERA.global_transform.basis.z.normalized() * impulse) / get_parent().mass)
