extends Node3D
class_name EnvironmentObject

@export var mesh : MeshInstance3D

var outline_material = preload("res://Assets/Materials/interactable_prompts.tres")
var interaction_nodes : Array[Node]

func _ready() -> void:
	self.add_to_group("interactable")
	find_interaction_nodes()
	
func _process(delta: float) -> void:
	pass

func find_interaction_nodes():
	interaction_nodes = find_children("", "InteractionComponent", true)
