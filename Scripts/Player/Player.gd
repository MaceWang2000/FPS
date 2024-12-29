extends CharacterBody3D
class_name Player

@onready var nek: Node3D = %Nek
@onready var head: Node3D = %Head
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouhching_collision_shape: CollisionShape3D = $CrouhchingCollisionShape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var main_camera: Camera3D = %MainCamera
@onready var eyes: Node3D = %Eyes

@export_group("MovementParameters")
@export var jump_peak_time: float = 0
@export var jump_fall_time: float = 0
@export var jump_height: float = 0
@export var MOUSEN_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var lerp_speed : float = 10.0
@export var air_speed : float = 3.0
@export var interact_distance : float = 3.0
@export var climb_speed := 7.0
@export var FALLING_DAMAGE := 0.0 ##掉落伤害
##由游戏配置控制。如果是为false，则玩家必须持续按住Crouch键才能保持蹲伏。
@export var TOGGLE_CROUCH : bool = false

@export_group("LeanParameters")
@export_range(0.0, 2.0, 0.1) var lean_position : float = 0.4 #倾斜值
@export_range(1.0, 20.0, 0.1) var lean_rotation : float = 4.0 #倾斜角度
@export_range(1.0, 20.0, 0.1) var lean_collider_rotation : float = 4.0 #碰撞，摄像机倾斜角度

@export_group("NodeUse")
@export var ANIMATION_PLAYER : AnimationPlayer 
@export var iteam_target : Node3D #交互点
@export var interact_ray : RayCast3D #交互射线
@export var food_target : Node3D
@export var LEAN_RIGHT_COLLIDER : ShapeCast3D
@export var LEAN_LEFHT_COLLIDER : ShapeCast3D
@export var crouch_shape_cast : ShapeCast3D
@export var crouch_overlay : ColorRect
@export var jump_buffer_time : Timer
@export var CHEST_RAY : RayCast3D
@export var PLAYER_HEALTH_COMPONENT : PlayerHealthComponent
@export var crosshair: TextureRect ##准星PlayerInteraction调用
@export var player_interaction_component : PlayerInteractionComponent
@export_group("", "")
#region Variavle
@export var player_hud : NodePath
@export var inventory_data : ImmsInventory
#endregion

#Uncategorized
var input_dir : Vector2
var crouching_depth = -0.5
var direction : Vector3
var last_velocity : Vector3 = Vector3.ZERO
var _saved_camera_global_pos = null
var is_interact : bool = false #可交互
var level_parent
var obstacles : Array
var wish_dir := Vector3.ZERO
var cam_aligned_wish_dir := Vector3.ZERO
var jump_buffer : bool = false
var free_look_tilt_amount = 8
var try_crouch : bool = false
var rid_array : Array[RID]
var is_showing_ui : bool #控制打开/关闭库存界面
var is_movement_paused : bool #移动暂停
#staris
var _snapped_to_stairs_last_frame : bool = false #捕捉到楼梯最后一个帧
var _last_frame_was_on_floor : float = -INF  #无穷大
var crouch : bool = false
const MAX_STEP_HEIGHT : float = 0.5  #楼梯台阶最大高度
#jum fall
var jump_velocity: float
var jump_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall_gravity: float = -5.0
#State
var can_jump : bool = true
var camera_can_move : bool = true
var is_crouching : bool = false
var is_climbing : bool = false
var walking : bool = false
var sprinting : bool = false
var crouching : bool = false
var free_looking : bool = false
var sliding : bool = false
#Slide Var
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

##Head Bobbing Vars
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

#Sound
var sliding_sound = preload("res://Assets/Sound/537275__laughingfish78__dirt-sliding.ogg")

const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

const push_force = 80.0
##Movement
var current_speed : float = 5.0
const WALKING_SPEED : float = 5.0
const SPRINTING_SPEED : float = 8.0
const CROUCHING_SPEED : float = 3.0

#signal
signal step
signal toggle_inventory_interface()

func _init() -> void:
	pass

func _ready() -> void:
	Global.player = self
	SceneManager._current_player_node = self
	Establish_Speed()
	level_parent = get_parent()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rid_array.append(self.get_rid())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event is InputEventMouseMotion and not is_movement_paused:
		if sliding:
			nek.rotate_y(deg_to_rad(-event.relative.x * MOUSEN_SENSITIVITY))
		else:
			rotate_y(deg_to_rad(-event.relative.x * MOUSEN_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSEN_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	#打开/关闭库存界面
	if event.is_action_pressed("inventory"):
		if not is_showing_ui:
			toggle_inventory_interface.emit()
			_on_pause_movement()
		elif is_showing_ui and get_node(player_hud).inventory_interface.is_inventory_open:
			toggle_inventory_interface.emit()
			_on_resume_movement()
			
#计算重力/跳跃高度
func Establish_Speed()->void:
	jump_gravity = (2*jump_height)/ pow(jump_peak_time,2)
	fall_gravity = (2*jump_height)/ pow(jump_fall_time,2)
	jump_velocity = ((jump_gravity)*(jump_peak_time))
	
func _physics_process(delta : float) -> void:
	
	#获取运动输入/暂停运动
	if not is_movement_paused:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	else:
		input_dir = Vector2.ZERO
	
	#Handle ToggleCrouch
	if TOGGLE_CROUCH and Input.is_action_just_pressed("crouch"):
		try_crouch = !try_crouch
	elif !TOGGLE_CROUCH:
		try_crouch = Input.is_action_pressed("crouch")
		
	#Crouching
	if try_crouch or sliding:
		current_speed = lerp(current_speed, CROUCHING_SPEED, delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
		
		standing_collision_shape.disabled = true
		crouhching_collision_shape.disabled = false
		
		#Silding Begine 
		if sprinting and input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			
			SoundManager.play_sound(sliding_sound, "SFX")
			
			print_debug("Sliding is Begine")
		
		walking = false
		sprinting = false
		crouching = true
		
	elif !ray_cast_3d.is_colliding():
		
		#Standing
		standing_collision_shape.disabled = false
		crouhching_collision_shape.disabled = true
		
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		
		if Input.is_action_pressed("sprint"):
			#Sprinting
			current_speed = lerp(current_speed, SPRINTING_SPEED, delta * lerp_speed)
			
			walking = false
			sprinting = true
			crouching = false
		else:
			#Walking
			current_speed = lerp(current_speed, WALKING_SPEED, delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
		
	if sliding:
		slide_timer -= delta
		#滑动时摄像机旋转偏移
		main_camera.rotation.z = lerp(main_camera.rotation.z, -deg_to_rad(4.0), delta * lerp_speed)
		if slide_timer <= 0:
			sliding = false
			self.rotation.y += nek.rotation.y
			nek.rotation.y = 0.0
			
			SoundManager.stop_sound(sliding_sound)
			
			print_debug("Sliding End")
	else:
		main_camera.rotation.z = lerp(main_camera.rotation.z, -deg_to_rad(0.0), delta * lerp_speed)
	#头部摄像机摇晃
	handle_headbob(delta)
	
	#Add the gravity
	if not is_on_floor():
		velocity.y -= fall_gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false
		ANIMATION_PLAYER.play("jump", -1, 1)
	
	if is_on_floor():
		#Handle lastvelocity
		if last_velocity.y < -4.0:
			ANIMATION_PLAYER.play("landing", -1, 1)
			
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
		_last_frame_was_on_floor = Engine.get_physics_frames()
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	#摄像机倾斜
	#lean(delta)
	last_velocity = velocity
	move_and_slide()
	
	#if Input.is_action_just_pressed("jump") and can_climb() == true and not is_on_floor() and CHEST_RAY.is_colliding():
		#climb()
	
	#手扶椅
	#_handle_ladder_physics(delta)
	#if not _handle_ladder_physics():
		#if is_on_floor() or _snapped_to_stairs_last_frame:
				#if Input.is_action_just_pressed("jump"):
					#self.velocity.y = jump_velocity
			#else:
				#_handle_air_physics(delta)
	#if not _snap_up_stairs_check(delta):
		#_push_away_rigid_bodies()
	#
		#_snap_down_to_stairs_check()
			#
	#_slide_camera_smooth_back_to_origin(delta)

#func lean(delta : float) -> void:
	#if Input.is_action_pressed("left_tilt") and LEAN_LEFHT_COLLIDER.is_colliding() == false:
		#CAMERA_CONTROLLER.position.x = lerp(CAMERA_CONTROLLER.position.x, -lean_position, lerp_speed * delta)
		#CAMERA_CONTROLLER.rotation_degrees.z = lerp(CAMERA_CONTROLLER.rotation_degrees.z, lean_rotation, lerp_speed * delta)
	#elif Input.is_action_pressed("left_tilt") and LEAN_LEFHT_COLLIDER.is_colliding():
		#CAMERA_CONTROLLER.rotation_degrees.z = lerp(CAMERA_CONTROLLER.rotation_degrees.z, lean_collider_rotation, lerp_speed * delta)
	#if Input.is_action_pressed("right_tilt") and LEAN_RIGHT_COLLIDER.is_colliding() == false:
		#CAMERA_CONTROLLER.position.x = lerp(CAMERA_CONTROLLER.position.x, lean_position, lerp_speed * delta)
		#CAMERA_CONTROLLER.rotation_degrees.z = lerp(CAMERA_CONTROLLER.rotation_degrees.z, -lean_rotation, lerp_speed * delta)
	#elif Input.is_action_pressed("right_tilt") and LEAN_RIGHT_COLLIDER.is_colliding():
		#CAMERA_CONTROLLER.rotation_degrees.z = lerp(CAMERA_CONTROLLER.rotation_degrees.z, -lean_collider_rotation, lerp_speed * delta)
	#if !(Input.is_action_pressed("left_tilt") or Input.is_action_pressed("right_tilt")):
		#CAMERA_CONTROLLER.position.x = lerp(CAMERA_CONTROLLER.position.x, 0.0, lerp_speed * delta)
		#CAMERA_CONTROLLER.rotation_degrees.z = lerp(CAMERA_CONTROLLER.rotation_degrees.z, 0.0, lerp_speed * delta)

func _on_pause_movement() -> void:
	if !is_movement_paused:
		is_movement_paused = true
		
		if InputHelper.device_index == -1:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_movement():
	if is_movement_paused:
		is_movement_paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Handle headbob
func handle_headbob(delta : float) -> void:
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
		
	if is_on_floor() and not sliding and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)

func _get_look_direction() -> Vector3:
	var viewport = get_viewport().get_visible_rect().size
	var camera = get_viewport().get_camera_3d()
	return camera.project_ray_normal(viewport / 2)

func can_climb():
	for ray in $CamerController/HeadRays.get_children():
		if ray.is_colliding():
			return false
		else: #处在捡东西状态不能进行climb
			return true

#func climb():
	#velocity = Vector3.ZERO
	#can_jump = false
	#camera_can_move = false
	#
	#var v_move_time := 0.4
	#var h_move_time := 0.2
	#if !is_crouching:
		#%Climb.play() #播放音效
		#var vertical_movement = global_transform.origin + Vector3(0, 1.85, 0)
		#var vm_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		#var camera_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
#
		#vm_tween.tween_property(self, "global_transform:origin", vertical_movement, v_move_time)
		#camera_tween.tween_property(CAMERA_CONTROLLER, "rotation_degrees:x", clamp(CAMERA_CONTROLLER.rotation_degrees.x - 20.0, -85, 90), v_move_time)
		#camera_tween.tween_property(CAMERA_CONTROLLER, "rotation_degrees:z", -5.0 * sign(randf_range(-10000, 10000)), v_move_time)
		#
		#await vm_tween.finished
		#
		#var forward_movement = global_transform.origin + (-global_basis.z * 1.2)
		#var fm_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		#var camera_rest = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		#fm_tween.tween_property(self, "global_transform:origin", forward_movement, h_move_time)
		#camera_rest.tween_property(CAMERA_CONTROLLER, "rotation_degrees:x", 0.0, h_move_time)
		#camera_rest.tween_property(CAMERA_CONTROLLER, "rotation_degrees:z", 0.0, h_move_time)
	#
	#else:
		#pass
#
	#can_jump = true
	#camera_can_move = true
#
#func update_gravity(delta) -> void:
	#if not is_on_floor():
		#if velocity.y>0:
			#velocity.y -= jump_gravity * delta
		#else:
			#velocity.y -= fall_gravity * delta
	#
#func update_input(speed : float, accleration : float, deceleration : float) -> void:
	#wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	#cam_aligned_wish_dir = CAMERA_CONTROLLER.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	#
	#if direction:
		#velocity.x = lerp(velocity.x, direction.x * speed, accleration) 
		#velocity.z = lerp(velocity.z, direction.z * speed, accleration) 
	#else:
		#velocity.x = move_toward(velocity.x, 0, deceleration)
		#velocity.z = move_toward(velocity.z, 0, deceleration)
#
#func update_velocity() -> void:
	#if last_velocity.y < 0:
		#pass
		###掉落伤害
		##var distance = velocity.y - last_velocity.y
		##if distance > PLAYER_HEALTH_COMPONENT.fall_damage_threshold and distance < PLAYER_HEALTH_COMPONENT.max_fall_damage_threshold:
			##PLAYER_HEALTH_COMPONENT.player_hurt(FALLING_DAMAGE)
		##elif distance > PLAYER_HEALTH_COMPONENT.max_fall_damage_threshold:
			##print("Player is Death")		
	#last_velocity = velocity
#
#var _cur_ladder_climbing : Area3D = null
#
###Player与Rigidbody碰撞交互
#func _push_away_rigid_bodies():
	#for i in get_slide_collision_count():
		#var c := get_slide_collision(i)
		#if c.get_collider() is RigidBody3D:
			#var push_dir = -c.get_normal()
			## How much velocity the object needs to increase to match player velocity in the push direction
			#var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			## Only count velocity towards push dir, away from character
			#velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			## Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			#const MY_APPROX_MASS_KG = 80.0
			#var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			## Optional add: Don't push object at all if it's 4x heavier or more
			#if mass_ratio < 0.25:
				#continue
			### Don't push object from above/below
			#push_dir.y = 0
			## 5.0 is a magic number, adjust to your needs
			#var push_force = mass_ratio * 5.0
			#c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position) 
#
#func _handle_ladder_physics(delta) -> bool:
	## Keep track of whether already on ladder. If not already, check if overlapping a ladder area3d.
	#var was_climbing_ladder := _cur_ladder_climbing and _cur_ladder_climbing.overlaps_body(self)
	#if not was_climbing_ladder:
		#_cur_ladder_climbing = null
		#for ladder in get_tree().get_nodes_in_group("ladder_area3d"):
			#if ladder.overlaps_body(self):
				#_cur_ladder_climbing = ladder
				#break
	#if _cur_ladder_climbing == null:
		#return false
	#
	## Set up variables. Most of this is going to be dependent on the player's relative position/velocity/input to the ladder.
	#var ladder_gtransform : Transform3D = _cur_ladder_climbing.global_transform
	#var pos_rel_to_ladder := ladder_gtransform.affine_inverse() * self.global_position
	#
	#var forward_move := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	#var side_move := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#var ladder_forward_move = ladder_gtransform.affine_inverse().basis * CAMERA.global_transform.basis * Vector3(0, 0, -forward_move)
	#var ladder_side_move = ladder_gtransform.affine_inverse().basis * CAMERA.global_transform.basis * Vector3(side_move, 0, 0)
	#
	## Strafe velocity is simple. Just take x component rel to ladder of both
	#var ladder_strafe_vel : float = climb_speed * (ladder_side_move.x + ladder_forward_move.x)
	## For climb velocity, there are a few things to take into account:
	## If strafing directly into the ladder, go up, if strafing away, go down
	#var ladder_climb_vel : float = climb_speed * -ladder_side_move.z
	## When pressing forward & facing the ladder, the player likely wants to move up. Vice versa with down.
	## So we will bias the direction (up/down) towards where we are looking by 45 degrees to give a greater margin for up/down detect.
	#var up_wish := Vector3.UP.rotated(Vector3(1,0,0), deg_to_rad(-45)).dot(ladder_forward_move)
	#ladder_climb_vel += climb_speed * up_wish
	#
	## Only begin climbing ladders when moving towards them & prevent sticking to top of ladder when dismounting
	## Trying to best match the player's intention when climbing on ladder
	#var should_dismount = false
	#if not was_climbing_ladder:
		#var mounting_from_top = pos_rel_to_ladder.y > _cur_ladder_climbing.get_node("TopOfLadder").position.y
		#if mounting_from_top:
			## They could be trying to get on from the top of the ladder, or trying to leave the ladder.
			#if ladder_climb_vel > 0: should_dismount = true
		#else:
			## If not mounting from top, they are either falling or on floor.
			## In which case, only stick to ladder if intentionally moving towards
			#if (ladder_gtransform.affine_inverse().basis * wish_dir).z >= 0: should_dismount = true
		## Only stick to ladder if very close. Helps make it easier to get off top & prevents camera jitter
		#if abs(pos_rel_to_ladder.z) > 0.1: should_dismount = true
	#
		## Let player step off onto floor
	#if is_on_floor() and ladder_climb_vel <= 0: should_dismount = true
	#
	#if should_dismount:
		#_cur_ladder_climbing = null
		#return false
	#
	## Allow jump off ladder mid climb
	#if was_climbing_ladder and Input.is_action_just_pressed("jump"):
		#self.velocity = _cur_ladder_climbing.global_transform.basis.z * jump_velocity * 1.5
		#_cur_ladder_climbing = null
		#return false
	#
	#self.velocity = ladder_gtransform.basis * Vector3(ladder_strafe_vel, ladder_climb_vel, 0)
	#
	## Snap player onto ladder
	#pos_rel_to_ladder.z = 0
	#self.global_position = ladder_gtransform * pos_rel_to_ladder
	#
	#return true
	#
##region 楼梯
#func is_surface_too_step(normal : Vector3) -> bool:
	#return normal.angle_to(Vector3.UP) > self.floor_max_angle
	#
#func _run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	#if not result : result = PhysicsTestMotionResult3D.new()
	#var params = PhysicsTestMotionParameters3D.new()
	#params.from = from
	#params.motion = motion
	#return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)
#
##摄像机平滑
#func _save_camera_pos_for_smoothing() -> void:
	#if _saved_camera_global_pos == null:
		#_saved_camera_global_pos = CAMERA_CONTROLLER.global_position
#
#func _slide_camera_smooth_back_to_origin(delta):
	#if _saved_camera_global_pos == null: return
	#CAMERA_CONTROLLER.global_position.y = _saved_camera_global_pos.y
	#CAMERA_CONTROLLER.position.y = clampf(CAMERA_CONTROLLER.position.y, -0.7, 0.7) # Clamp incase teleported
	#var move_amount = max(self.velocity.length() * delta, WALKING_SPEED/2 * delta)
	#CAMERA_CONTROLLER.position.y = move_toward(CAMERA_CONTROLLER.position.y, 0.0, move_amount)
	#_saved_camera_global_pos = CAMERA_CONTROLLER.global_position
	#if CAMERA_CONTROLLER.position.y == 0:
		#_saved_camera_global_pos = null # Stop smoothing camera
#
##下楼检查
#func _snap_down_to_stairs_check() -> void:
	#var did_snap : bool = false
	#var floor_below : bool = %StaidsBelowRayCast3D.is_colliding() and not is_surface_too_step(%StaidsBelowRayCast3D.get_collision_normal())
	#var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	#if not is_on_floor() and velocity.y <= 0.0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		#var body_test_result = PhysicsTestMotionResult3D.new()
		#if _run_body_test_motion(self.global_transform, Vector3(0.0, -MAX_STEP_HEIGHT, 0.0), body_test_result):
			#_save_camera_pos_for_smoothing()
			#var translate_y = body_test_result.get_travel().y
			#self.position.y += translate_y
			#apply_floor_snap()
			#did_snap = true
	#_snapped_to_stairs_last_frame = did_snap
#
#func _snap_up_stairs_check(delta) -> bool:
	#if not is_on_floor() and not _snapped_to_stairs_last_frame: 
		#return false
	#if self.velocity.y > 0 or (self.velocity * Vector3(1, 0, 1)).length() == 0: 
		#return false
	#var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	#var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	## Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	##  We give some clearance above to ensure there's ample room for the player.
	##  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	##  along with their intended motion forward.
	#var down_check_result = KinematicCollision3D.new()
	#if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	#and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		#var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		## Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		## 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		## The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		#if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		#%StaidsAheadRayCast3D.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		#%StaidsAheadRayCast3D.force_raycast_update()
		#if %StaidsAheadRayCast3D.is_colliding() and not is_surface_too_step(%StaidsAheadRayCast3D.get_collision_normal()):
			#_save_camera_pos_for_smoothing()
			#self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			#apply_floor_snap()
			#_snapped_to_stairs_last_frame = true
			#return true
	#return false
