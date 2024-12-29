extends PanelContainer

const SLOT = preload("res://Scenes/UI/slot.tscn")

@onready var iteam_grid: GridContainer = $MarginContainer/IteamGrid

func set_inventory_data(inventory_data : ImmsInventory) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)

func clear_inventory_data(inventory_data : ImmsInventory) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data : ImmsInventory) -> void:
	for child in iteam_grid.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slot_datas:
		var slot = SLOT.instantiate()
		iteam_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
			
