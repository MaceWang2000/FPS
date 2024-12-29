extends Node3D
class_name InteractionDoor

@export var mesh : MeshInstance3D
@export_group("Door settings")
##门的旋转角度
@export var open_rotation_deg : float = 0.0 
##关门时门的旋转角度
@export var closed_rotation_deg : float = 0.0 
##双向摆动
@export var bidirectional_swing : bool = false
##门的各种类型
@export var door_type := DoorType.ROTATING:
	set(value):
		door_type = value
		notify_property_list_changed()#编辑器跟类型一致
##打开时变换的局部位置
@export var open_position : Vector3
##关闭时变换的局部位置
@export var closed_position : Vector3
##门在打开和关闭位置之间移动的速度。通常约为 0.1
@export var door_speed : float = .1 
@export var forward_direction : ForwardDirection
@export_group("音效")
@export var open_sound : AudioStream
@export var close_sound : AudioStream
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var interaction_text_when_open : String = "打开" ##关闭时交互提示上显示的文本
@export var interaction_text_when_close : String = "关闭" ##开启时交互提示上显示的文本

var player_interaction_component : PlayerInteractionComponent
var target_rotation_rad : float
var interaction_nodes : Array[Node]
var outline_material = preload("res://Assets/Shader/out_line.gdshader")
var is_moving : bool #门是否开始移动过
var is_open : bool #门是否开启

var rotation_adjustment : float
var door_direction : Vector3

var interaction_text : String

signal object_state_updated(interaction_text:String) #头一开始或者门的打开或关闭状态发出该信号

enum DoorType {
  ROTATING,
  SLIDING,
  ANIMATED
}

enum ForwardDirection {X, Y, Z}

func _ready() -> void:
	self.add_to_group("interactable")
	interaction_nodes = find_children("", "InteractionComponent", true)
	target_rotation_rad = rotation.y
	
	if is_open:
		interaction_text = interaction_text_when_open
	else:
		interaction_text = interaction_text_when_close
	
	object_state_updated.emit(interaction_text)

func _physics_process(delta: float) -> void:
	check_door()
	if door_type == DoorType.ROTATING:
		if is_moving:
			rotation.y = lerp_angle(rotation.y, rotation_adjustment * target_rotation_rad, door_speed)
		
	if abs(rotation.y - target_rotation_rad) <= 0.01:
		is_moving = false
		
func interact(interactor : Node3D) -> void:
	player_interaction_component = interactor
	if !is_open:
		open_door(interactor)
	else:
		close_door(interactor)
	
func open_door(interactor : Node3D) -> void:
	audio_stream_player_3d.stream = open_sound
	audio_stream_player_3d.play()
	
	if door_type == DoorType.ANIMATED:
		pass
	elif door_type == DoorType.ROTATING:
		target_rotation_rad = deg_to_rad(open_rotation_deg)
		var swing_direction = 1
		
		if bidirectional_swing:
			var offset : Vector3 = interactor.global_transform.origin - global_transform.origin
			var offset_dot_product: float = offset.dot(global_transform.basis.x)
			swing_direction = -1 if offset_dot_product < 0 else 1
			
		target_rotation_rad = deg_to_rad(open_rotation_deg * swing_direction)
		is_moving = true
	else:
		var tween_door = get_tree().create_tween()
		tween_door.tween_property(self, "position", open_position, door_speed)
		
	is_open = true
	interaction_text = interaction_text_when_open
	object_state_updated.emit(interaction_text)

func close_door(_interactor : Node3D) -> void:
	audio_stream_player_3d.stream = close_sound
	audio_stream_player_3d.play()
	
	if door_type == DoorType.ANIMATED:
		pass
	elif door_type == DoorType.ROTATING:
		target_rotation_rad = deg_to_rad(closed_rotation_deg)
		is_moving = true
	else:
		var tween_door = get_tree().create_tween()
		tween_door.tween_property(self, "position", closed_position, door_speed)
		
	is_open = false
	interaction_text = interaction_text_when_close
	object_state_updated.emit(interaction_text)

func check_door() -> void:
	match forward_direction:
		ForwardDirection.X:
			door_direction = global_transform.basis.x
		ForwardDirection.Y:
			door_direction = global_transform.basis.y
		ForwardDirection.Z:
			door_direction = global_transform.basis.z
	
	var door_position : Vector3 = global_position
	var player_position : Vector3 = Global.player.global_position
	var direction_to_player : Vector3 = door_position.direction_to(player_position)
	var door_dot : float = direction_to_player.dot(door_direction)
	if door_dot < 0:
		rotation_adjustment = -1
	else:
		rotation_adjustment = 1
