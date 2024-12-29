class_name ExplodeBarrel

extends RigidBody3D

@export var impulse : float = 10.0

@export_group("节点引用")
@export var mesh : MeshInstance3D
@export var area : Area3D
@export var COLLISION_SHAPE : CollisionShape3D
@export var SHAPE_CAST : ShapeCast3D
@export var DETERCTION_EXPLODE : Area3D

@export_group("粒子特效")
@export var damage_effect : Node3D
@export var explode_effect : Node3D

@export_group("音效")
@export var explode_sound : AudioStreamPlayer3D

@export_group("参数")
@export var damage_value := 100

signal _explode

var is_damage : bool = false

func _ready() -> void:
	Global.explode_barrel = self
	area.monitoring = false
	DETERCTION_EXPLODE.monitoring = false
	Global.iteam_health_component.hurt.connect(damage)
	Global.iteam_health_component.death.connect(explode)

func explode() -> void:
	for child in damage_effect.get_children():
		if child is GPUParticles3D:
			child.emitting = false
			
	for child in explode_effect.get_children():
		if child is GPUParticles3D:
			child.emitting = true
	
	_explode.emit()
	freeze = true
	COLLISION_SHAPE.disabled = true #禁用碰撞体 射击射线不再与它交互
	explode_sound.play()	
	mesh.visible = false
	area.monitoring = true #开启区域检测
	DETERCTION_EXPLODE.monitoring = true
	await get_tree().create_timer(3.0).timeout
	queue_free()
	
func damage() -> void:
	for child in damage_effect.get_children():
		if child is GPUParticles3D:
			child.emitting = true
			is_damage = true

#Area与物体相交
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.apply_impulse((body.global_position.normalized() - self.global_position.normalized()) * 10.0 / body.mass)


#相邻爆炸桶爆炸
func _on_detection_explode_area_entered(area: Area3D) -> void:
	if area.get_parent() is RigidBody3D and area.get_parent().has_method("explode"):
		area.get_parent().explode()

func _on_body_entered(body: Node) -> void:
	if is_damage:
		if body is not Player:
			explode()
			is_damage = false
	
