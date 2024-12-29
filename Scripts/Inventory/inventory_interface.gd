extends Control

@onready var inventory_ui: PanelContainer = $InventoryUI
@onready var grabbed_slot : PanelContainer = $GrabbedSlot
@onready var external_inventory: PanelContainer = $ExternalInventory

var is_inventory_open : bool
var grabbed_slot_data : InventorySlotPD
var external_inventory_owner : Node

signal drop_slot_data(slot_data : InventorySlotPD)

func _ready() -> void:
	is_inventory_open = false
	
func _physics_process(delta: float) -> void:
	if grabbed_slot_data:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)

func open_inventory() -> void:
	if not is_inventory_open:
		is_inventory_open = true
		inventory_ui.show()
		Global.player.is_showing_ui = true
		
func close_inventory() -> void:
	if is_inventory_open:
		is_inventory_open = false
		inventory_ui.hide()
		Global.player.is_showing_ui = false
#
func set_player_inventory_data(inventory_data : ImmsInventory) -> void:
	if not inventory_data.inventory_interact.is_connected(on_inventory_interact):
			inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory_ui.set_inventory_data(inventory_data)
	
func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	if not inventory_data.inventory_interact.is_connected(on_inventory_interact):
			inventory_data.inventory_interact.connect(on_inventory_interact)
			
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show() 

func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		if not inventory_data.inventory_interact.is_connected(on_inventory_interact):
			inventory_data.inventory_interact.connect(on_inventory_interact)
			
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

func on_inventory_interact(inventory_data : ImmsInventory, index : int, mouse_button : int) -> void:
	match [grabbed_slot_data, mouse_button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
			
			
	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.set_slot_data(grabbed_slot_data)
		grabbed_slot.show()
	else:
		grabbed_slot.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data:
				
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		
		update_grabbed_slot()


func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
