extends InteractionComponent
class_name PickUpComponent

@export var slot_data : InventorySlotPD
@export var collision_shape : CollisionShape3D

var player_interaction_component : PlayerInteractionComponent
var parent_object
var pick_sound = preload("res://Assets/Sound/pickup.wav")

func _ready() -> void:
	parent_object = get_parent()

func interact(_player_interaction_component : PlayerInteractionComponent) -> void:
	if not is_disabled:
		pick_up(_player_interaction_component)
		
func pick_up(_player_interaction_component : PlayerInteractionComponent) -> void:
	SoundManager.play_sound(pick_sound, "SFX")
	
	if not _player_interaction_component.get_parent().inventory_data.pick_up_slot_data(slot_data):
		return
	
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(parent_object, "global_position", 
	_player_interaction_component.interaction_food_target.global_position, 0.1).set_trans(Tween.TRANS_CUBIC)

	if collision_shape != null:
		collision_shape.disabled = true
	await tween.finished
	self.get_parent().queue_free()

func get_item_type() -> int:
	if slot_data and slot_data.inventory_item:
		return slot_data.inventory_item.item_type
	else:
		return -1
