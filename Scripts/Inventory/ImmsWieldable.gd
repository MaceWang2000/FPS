extends Node3D
class_name ImmsWieldable

#可持有物品资源
var item_reference : WieldableItemPD
var player_interaction_component : PlayerInteractionComponent

##可持有物品的可见部分，用于装备和取消装备是显示和隐藏
@export var wielbale_mesh : Node3D

@export_group("Animation Settings")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var anim_equip: String = "equip"
@export var anim_unequip: String = "unequip"
@export var anim_action_primary: String = "action_primary"
@export var anim_action_secondary: String = "action_secondary"
@export var anim_reload: String = "reload"

func _ready() -> void:
	if wielbale_mesh:
		wielbale_mesh.show()

func equip(_player_interaction_component : PlayerInteractionComponent) -> void:
	animation_player.play("equip")
	player_interaction_component = _player_interaction_component
	
func unequip() -> void:
	animation_player.play("unequip")
	
func action_primary(_passed_item_reference:InventoryItemPD, _is_released: bool):
	pass


func reload():
	pass
