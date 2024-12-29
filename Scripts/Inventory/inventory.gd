extends Resource
class_name ImmsInventory

signal inventory_interact(inventory_data: ImmsInventory, index: int, mouse_button: int)
signal inventory_button_press(inventory_data: ImmsInventory, index: int, action: String)
signal inventory_updated(inventory_data: ImmsInventory)

@export var slot_datas : Array[InventorySlotPD]

func _reset_state() -> void:
	print(get_local_scene())

func grab_slot_data(index : int):
	var slot_data = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func drop_slot_data(grab_slot_data : InventorySlotPD, index : int) -> InventorySlotPD:
	var slot_data = slot_datas[index]
	
	var return_slot_data : InventorySlotPD
	if slot_data and slot_data.can_fully_merge_with(grab_slot_data):
		slot_data.fully_merge_with(grab_slot_data)
	else:
		slot_datas[index] = grab_slot_data
		return_slot_data = slot_data
		
	inventory_updated.emit(self)
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data : InventorySlotPD, index : int) -> InventorySlotPD:
	var slot_data = slot_datas[index]
	
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)

	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func use_slot_data(index : int) -> void:
	if index == -1:
		return
		
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return
		
	var use_successful : bool = slot_data.item_data.use(get_local_scene())
	if slot_data.item_data.has_method("is_consumable") and use_successful:
		slot_data.quantity -= 1
		if slot_data.quantity < 1:
			slot_datas[index] = null
			
	inventory_updated.emit(self)

func pick_up_slot_data(slot_data : InventorySlotPD) -> bool:
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
			
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
			
	return false
	
func on_slot_clicked(index : int, mouse_button : int) -> void:
	inventory_interact.emit(self, index, mouse_button)
