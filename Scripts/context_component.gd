class_name ContextComponent extends Control

@onready var food_name: Label = $FoodName
@onready var take: HBoxContainer = $Take
@onready var food: HBoxContainer = $Food

func _ready() -> void:
	food_name.visible = false
	food.visible = false
	
func update_icon() -> void:
	pass
