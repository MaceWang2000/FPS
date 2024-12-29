extends Resource
class_name InventoryItemPD

@export var name : String = ""
@export_multiline var description : String = ""
@export var stackable : bool = false
@export var texture : AtlasTexture
##将物品从库存中删除以降落到世界上时将产生的场景路径
@export_file("*.tscn") var drop_scene

# Variables for Wielded Items
var is_being_wielded : bool
var player_interaction_component
var wiedlable_item
