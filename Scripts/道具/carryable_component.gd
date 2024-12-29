extends InteractionComponent
class_name CarryableComponent

@export_group("携带设置")
@export var carry_distance_offset : float = 0
##设置Object跟随速度
@export var carrying_velocity_multiplier : float = 10
##设置被携带的物体在被放下之前需要距离 carry_position 多远
@export var drop_distance : float = 1.5

var parent_object
var is_being_carried : bool
var player_interaction_component : PlayerInteractionComponent
var carry_position : Vector3
var pick_sound = preload("res://Assets/Sound/pickup.wav")

func _ready() -> void:
	parent_object = get_parent()
	#携带过程中碰到Player，停止携带
	if parent_object.has_signal("body_entered"):
		parent_object.body_entered.connect(_on_body_entered)
	else:
		print(parent_object.name, ": CarriableComponent needs to be child to a RigidBody3D to work.")

func interact(_player_interaction_component : PlayerInteractionComponent) -> void:
	if not is_disabled:
		carry(_player_interaction_component)
	
func carry(_player_interaction_component : PlayerInteractionComponent) -> void:
	player_interaction_component = _player_interaction_component
	
	if is_being_carried:
		leave()
	else:
		SoundManager.play_sound_with_pitch(pick_sound, randf_range(1.0, 1.3), "SFX")
		
		hold()

func _physics_process(delta: float) -> void:
	if is_being_carried:
		carry_position = player_interaction_component.get_interaction_raycast_tip(carry_distance_offset)
		parent_object.set_linear_velocity((carry_position - parent_object.global_position) * carrying_velocity_multiplier)
		
		if(carry_position - parent_object.global_position).length() >= drop_distance:
			leave()

func leave() -> void:
	parent_object.set_lock_rotation_enabled(false)
	if player_interaction_component and is_instance_valid(player_interaction_component):
		player_interaction_component.stop_carrying()
		player_interaction_component.interaction_raycast.remove_exception(parent_object)
	is_being_carried = false
	Events.carry_state_changed.emit(is_being_carried)
	
func hold() -> void:
	parent_object.set_lock_rotation_enabled(true)
	parent_object.freeze = false
	player_interaction_component.start_carrying(self)
	player_interaction_component.interaction_raycast.add_exception(parent_object)
	is_being_carried = true
	Events.carry_state_changed.emit(is_being_carried)

func throw(power) ->void:
	leave()
	
	var impulse = player_interaction_component._get_look_direction() * power
	parent_object.apply_central_impulse(impulse)
	Events.throw.emit(impulse)

func _on_body_entered(body) -> void:
	if body is Player and is_being_carried:
		leave()
