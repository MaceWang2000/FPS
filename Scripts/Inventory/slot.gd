extends PanelContainer
class_name SlotPanel

@onready var quantity_label: Label = $QuantityLabel
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

var grid : bool 
var test_data
var origin_index = -1
var quantity_slot : bool

signal slot_clicked(index : int, mouse_button : int)
signal slot_pressed(index : int, action : String)
signal highight_slot(index : int, highight : bool)

func set_slot_data(slot_data : InventorySlotPD) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
