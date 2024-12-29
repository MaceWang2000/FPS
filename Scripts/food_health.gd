extends InteractionComponent
class_name FoodHealthComponent

@export var prompt_food : String 

var player_interaction_component : PlayerInteractionComponent
var parent_object
var food_interact_sound = preload("res://Assets/Sound/EatFood.wav")

func _ready() -> void:
	parent_object = get_parent()

func interact(_player_interaction_component : PlayerInteractionComponent) -> void:
	if not is_disabled:
		food_interact(_player_interaction_component)
		
func food_interact(_player_interaction_component : PlayerInteractionComponent) -> void:
	SoundManager.play_sound(food_interact_sound, "SFX")
	self.get_parent().queue_free()
