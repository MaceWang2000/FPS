extends InventoryItemPD
class_name WieldableItemPD

@export_group("Wiedlable Settings")
@export var wieldable_scene : PackedScene

func use(target) -> bool:
	if target == null or target.is_in_group("external_inventory"):
		target = SceneManager._current_player_node
		
	player_interaction_component = target.player_interaction_component
	
	if is_being_wielded:
		put_away()
		return true
	else:
		take_out()
		return true

func take_out():
	if player_interaction_component.is_changing_wieldables:
		return
	
	is_being_wielded = true
	player_interaction_component.change_wieldable_to(self)

func put_away():
	if player_interaction_component.is_changing_wieldables:
		return
	
	is_being_wielded = false
	player_interaction_component.change_wieldable_to(null)

func build_wieldable_scene():
	var scene = wieldable_scene.instantiate()
	scene.item_reference = self
	return scene
