extends Control
class_name PlayerHUDManager

@export_group("Interaction Prompts")
@export var prompt_component : PackedScene
@export var prompt_text : String
@export var prompt_text2 : String ##Food
@export var throw_prompt : String  ##Food
@export var drop_text : String 
@export_group("", "")
##此选项设置掉落物品出现在距离玩家多远的位置。等于0时物品出现在玩家互动光线投射的顶端。负值表示距离较近，正值表示距离较远
@export var item_drop_distance_offset : float = -1

@export var player : Node

@onready var take_texture_rect: TextureRect = %TextureRect
@onready var take_label: Label = %Label
@onready var interact_texture_2: TextureRect = %InteractTexture2
@onready var interact_prompt_2: Label = %InteractPrompt2
@onready var food_name: Label = $Prompt/VBoxContainer/FoodName
@onready var inventory_interface: Control = $InventoryInterface

var interact_texture = preload("res://Assets/Texture/ui/keyboard_f.png")
var food_input_texture = preload("res://Assets/Texture/ui/keyboard_g.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	take_texture_rect.texture = null
	take_label.text = ""
	interact_prompt_2.text = ""
	interact_texture_2.texture = null
	food_name.text = ""
	
	player.toggle_inventory_interface.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	
	connect_to_external_inventories.call_deferred()
	
func connect_to_player_signals() -> void:
	Events.interactive_object_detected.connect(set_interaction_prompts)
	Events.nothing_detected.connect(delete_interaction_prompts)
	Events.started_carrying.connect(set_drop_prompts)

#连接外部库存
func connect_to_external_inventories():
	for node in get_tree().get_nodes_in_group("external_inventory"):
		print(node)
		if !node.is_connected("toggle_inventory", toggle_inventory_interface):
			node.toggle_inventory.connect(toggle_inventory_interface)

###交互UI提示
func set_interaction_prompts(passed_interaction_nodes : Array[Node]) -> void:
	delete_interaction_prompts()
	
	for node in passed_interaction_nodes:
		take_label.text = node.interaction_text
		take_texture_rect.texture = interact_texture
		if node.is_disabled:
			continue
		if node is FoodHealthComponent:
			interact_texture_2.texture = food_input_texture
			interact_prompt_2.text = node.food_interaction_text
			food_name.text = node.food_name

func delete_interaction_prompts() -> void:
	take_texture_rect.texture = null
	take_label.text = ""
	interact_prompt_2.text = ""
	interact_texture_2.texture = null
	food_name.text = ""

func set_drop_prompts(_carry_node) -> void:
	delete_interaction_prompts()
	#take_texture_rect.texture = interact_texture
	#for node in _carry_node:
		#print(node)
	#take_label.text = drop_text


func toggle_inventory_interface(external_inventory_owner = null) -> void:
	if not inventory_interface.is_inventory_open:
		inventory_interface.open_inventory()
		_on_external_ui_toggle(true)
	else:
		inventory_interface.close_inventory()
		_on_external_ui_toggle(false)
	
	if external_inventory_owner and inventory_interface.is_inventory_open:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func _on_external_ui_toggle(is_showing : bool) -> void:
	if is_showing:
		player._on_pause_movement()
	else:
		player._on_resume_movement()


func _on_inventory_interface_drop_slot_data(slot_data: InventorySlotPD) -> void:
	var scene_to_drop = load(slot_data.item_data.drop_scene)
	var dropped_item = scene_to_drop.instantiate()
	dropped_item.position = player.player_interaction_component.get_interaction_raycast_tip(item_drop_distance_offset)
	dropped_item.find_interaction_nodes()
	for node in dropped_item.interaction_nodes:
		if node.has_method("get_item_type"):
			node.slot_data = slot_data
	
	SceneManager._current_scene_root_node.add_child(dropped_item)
