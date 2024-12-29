class_name Fragment

extends RigidBody3D

@export var life_time : float = 2.0 #存在时间

var elapsed_time : float = 0.0

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > life_time:
		queue_free()
		
func init_frome_mesh(source : MeshInstance3D) -> void:
	global_transform = source.global_transform
	
	var mesh_init : MeshInstance3D = source.duplicate()
	mesh_init.transform = Transform3D.IDENTITY #Transform设为1
	add_child(mesh_init)
	
	$CollisionShape3D.shape = source.mesh.create_convex_shape()
