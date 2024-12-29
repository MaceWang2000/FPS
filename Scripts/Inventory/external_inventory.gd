extends StaticBody3D

signal toggle_inventory(external_inventory_owner)

@export var mesh : MeshInstance3D

var interaction_nodes : Array[Node]
var outline_material = preload("res://Assets/Materials/interactable_prompts.tres")
var inventory_data = preload("res://Resource/Inventory/冰箱inventroy.tres")

func _ready() -> void:
	add_to_group("external_inventory")
	add_to_group("interactable")
	print(inventory_data)
	interaction_nodes = find_children("","InteractionComponent",true) #Grabs all attached interaction components

func interact() -> void:
	toggle_inventory.emit(self) 
