extends ImmsWieldable

var inventory_item : WieldableItemPD

func action_primary(_passed_item_reference : InventoryItemPD, _is_released : bool) -> void:
	inventory_item = _passed_item_reference
	
	if _is_released:
		return
	
	#控制射击速率
	if animation_player.is_playing():
		return
		
	animation_player.play("shoot", -1, 1)
