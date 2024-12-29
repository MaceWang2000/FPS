extends Node3D
class_name PlayerInteractionComponent

@export var interaction_raycast : RayCast3D
@export var interaction_target : Marker3D
@export var interaction_food_target : Node3D
@export var throw_power : float = 10.0
@export var pistol : Node3D

@export_group("Wieldable Settings")
@export var wieldable_nodes : Array[Node]
@onready var wieldable_container: Node3D = $"../Nek/Head/Eyes/WieldableContainer"

var player_rid
var is_changing_wieldables : bool
#用于可持有的各种变量
var equipped_wieldable_item : WieldableItemPD
var is_wielding: bool:
	get: return equipped_wieldable_item != null
var equipped_wieldable_node = null

var interactable: #通过信号IneractionRayCast更新
	set = _set_interactable

var carried_object:
	set = _set_carried_object

var is_carrying : bool:
	get: return carried_object != null

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("food_interaction"):
		var action : String = "interact" if event.is_action_pressed("interact") else "interact2"
		_handle_interaction(action)
	
	#投掷物体
	if is_carrying and is_instance_valid(carried_object):
		if event.is_action_pressed("action_primary"):
			carried_object.throw(throw_power)
			
	##可持有物品的主要输入
	if is_wielding and not get_parent().is_movement_paused:
		if Input.is_action_just_pressed("action_primary"):
			print(":wdwd")
			
func _handle_interaction(action : String) -> void:
	#如果有携带物品，那么再次按下Interact键，将停止携带
	if is_carrying:
		if is_instance_valid(carried_object) and carried_object.input_map_action == action:
			carried_object.throw(1)
			return
		elif not is_instance_valid(carried_object):
			stop_carrying()
			return
	
	if interactable != null and not is_carrying:
		for node : InteractionComponent in interactable.interaction_nodes:
			if node.input_map_action == action and not node.is_disabled:
				node.interact(self)

func start_carrying(_carried_object) -> void:
	carried_object = _carried_object

func stop_carrying() -> void:
	carried_object = null
	_rebuild_interaction_prompts()

#region 可持有物品管理器
func equip_wieldable(wieldable_item : WieldableItemPD) -> void:
	if wieldable_item != null:
		equipped_wieldable_item = wieldable_item #设置库存数据
		
		var wieldable_node = wieldable_item.build_wieldable_scene()
		wieldable_container.add_child(wieldable_node)
		equipped_wieldable_node = wieldable_node
		equipped_wieldable_node.item_reference = wieldable_item
		equipped_wieldable_node.equip(self)
		await get_tree().create_timer(equipped_wieldable_node.animation_player.current_animation_length).timeout
		is_changing_wieldables = false
	else:
		is_changing_wieldables = false

func change_wieldable_to(next_wieldable: InventoryItemPD) -> void:
	is_changing_wieldables = true
	if equipped_wieldable_item != null:
		equipped_wieldable_item.is_being_wielded = false
		if equipped_wieldable_node != null:
			equipped_wieldable_node.unequip()
			if equipped_wieldable_node.animation_player.is_playing(): # Wait until unequip animation finishes.
				await get_tree().create_timer(equipped_wieldable_node.animation_player.current_animation_length).timeout 
	equipped_wieldable_item = null
	if equipped_wieldable_node != null:
		equipped_wieldable_node.queue_free() 
	equipped_wieldable_node = null
	equip_wieldable(next_wieldable)
#endregion

func _set_interactable(new_interactable) -> void:
	interactable = new_interactable
	
	if is_carrying:
		return
	if interactable == null:
		Events.nothing_detected.emit()
	else:
		Events.interactive_object_detected.emit(interactable.interaction_nodes)

func _set_carried_object(new_carried_object) -> void:
	carried_object = new_carried_object
	if carried_object != null:
		Events.started_carrying.emit(carried_object)

func _on_interact_ray_interactable_seen(new_interactable: Variant) -> void:
	interactable = new_interactable
	 
	if is_instance_valid(interactable.mesh):
		interactable.mesh.material_overlay = interactable.outline_material

func _on_interact_ray_interactable_unseen() -> void: 
	if interactable != null: 
		interactable.mesh.material_overlay = null
		
	interactable = null	

#始终获取光线投射目标点的辅助函数
func get_interaction_raycast_tip(distance_offset: float) -> Vector3:
	var destination_point = interaction_raycast.global_position + (interaction_raycast.target_position.z - 
	distance_offset) * get_viewport().get_camera_3d().get_global_transform().basis.z
	if interaction_raycast.is_colliding():
		#if destination_point == interaction_raycast.get_collision_point():
		return interaction_raycast.get_collision_point()
	else:
		return destination_point
		
#获取玩家面对方向的标准化Vector3量
func _get_look_direction() -> Vector3:
	var viewport = get_viewport().get_visible_rect().size
	var camera = get_viewport().get_camera_3d()
	return camera.project_ray_normal(viewport/2)

func _rebuild_interaction_prompts() -> void:
	if is_carrying:
		return
	Events.nothing_detected.emit() #清除交互提示
	if interactable != null:
		Events.interactive_object_detected.emit(interactable.interaction_nodes) #显示交互提示

func exclude_player(rid: RID):
	player_rid = rid
	interaction_raycast.add_exception_rid(rid)

func get_camera_collision() -> Vector3:
	var viewport = get_viewport().get_visible_rect().size
	var camera = get_viewport().get_camera_3d()
	
	var Ray_Origin = camera.project_ray_origin(viewport/2)
	var Ray_End = Ray_Origin + camera.project_ray_normal(viewport / 2)
	
	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin, Ray_End)
	New_Intersection.exclude = [player_rid]
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	if not Intersection.is_empty():
		var Col_Point = Intersection.position
		return Col_Point
	else:
		return Ray_End

	
	
