class_name UserInterface
#
extends Control

#@export var enemy_health_ui : ProgressBar
#
#@onready var take: HBoxContainer = $ContextComponent/Take
#@onready var food: HBoxContainer = $ContextComponent/Food
#@onready var take_name: Label = %TakeName
#@onready var food_name: Label = $ContextComponent/FoodName
#@onready var crosshair: TextureRect = $Reticle/Crosshair
#@onready var hand_interaction: TextureRect = $Reticle/HandInteraction
#
#func _ready() -> void:
	#await owner.ready
	#enemy_health_ui.visible = false
	#conncet_to_player_signals()
	#
	#take.visible = false
	#food.visible = false
	#food_name.visible = false
	#food_name.text = ""
	#take_name.text = ""
	#
#func _process(delta: float) -> void:
	#pass
#
#func conncet_to_player_signals():
	#Global.player_interaction_component.interactive_object_detected.connect(set_interaction_prompts)
	#Global.player_interaction_component.nothing_detected.connect(delete_interaction_prompts)
#
#func set_interaction_prompts():
	#if Global.player_interaction_component.interactable is PropSwitch:
		#take.visible = true
		#take_name.text = Global.player_interaction_component.interactable.context_take
		#return
	#
	#for child in Global.player_interaction_component.interactable.get_children():
		#if child is CarryableComponent:
			#take.visible = true
			#crosshair.visible = false
			#take_name.text = Global.player_interaction_component.interactable.context_take
		#
		#if child is FoodInteractionComponet:
			#take.visible = true
			#food.visible = true
			#food_name.visible = true
			#food_name.text = Global.player_interaction_component.interactable.context_food
			#take_name.text = Global.player_interaction_component.interactable.context_take
			#crosshair.visible = false
			#
#
#func delete_interaction_prompts() -> void:
	#take.visible = false
	#food.visible = false
	#food_name.visible = false
	#crosshair.visible = true
	#food_name.text = ""
	#take_name.text = ""
