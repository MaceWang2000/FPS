class_name WeaponController

extends Node3D

@export_group("Parameters")
@export var weapon_rotation_amount : float = 0.05
@export var LERP_SPEED : float = 10.0
@export var sway_min : Vector2 = Vector2(-20.0, -20.0)
@export var camera_tilt : float = 0.05 #左右移动摄像机倾斜量
@export var sway_max : Vector2 = Vector2(20.0, 20.0)
@export var usp_damage : float = 0.0 #usp攻击伤害
@export var pipewrench_damage : float = 0.0 #扳手攻击伤害
@export_range(0.0 , 10.0) var switch_weapon_speed : float = 1.0 #切换武器的动画速度
@export var weapon_bobbing_sprinting_intensity : float = 0.2
@export var weapon_bobbing_walking_intensity : float = 0.02
@export var weapon_bobbing_crouching_intensity : float= 0.05
@export var WEAPON_TYPE : Weapons

@export_group("NodeUse")
@export var weapon_holder : Node3D
@export var cam_controller : Node3D
@export var ANIMATION_PLAYER : AnimationPlayer
@export var audio_usp : AudioStreamPlayer
@export var can_interact : bool = false
@export_category("Weapon Idle Animation")
@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2

var mouse_movement : Vector2
var hit_effect = preload("res://Scenes/hit_effect.tscn")
var random_sway_x
var random_sway_y
var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength
var can_fire : bool = true

#Head Bobbing Vars
var weapon_bobbing_vector = Vector2.ZERO
var weapon_bobbing_index = 0.0
var weapon_bobbing_current_intensity = 0.0

const weapon_bobbing_sprinting_speed = 22.0
const weapon_bobbing_walking_speed = 14.0
const weapon_bobbing_crouching_speed = 10.0

signal weapon_fired
signal weapon_hit #命中了

enum WEAPON_STATE{idle, shoot, reload_fast, reload_full}
@export var weapon_state : WEAPON_STATE

func _ready() -> void:
	Global.weapon = self
	
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		
	
	if event.is_action_pressed("fire") and Global.carryable_component.is_being_carried == false and can_fire:
		weapon_state = WEAPON_STATE.shoot
	
	if event.is_action_pressed("reload"):
		weapon_state = WEAPON_STATE.reload_fast
	
func _physics_process(delta: float) -> void:
	sway_weapon(delta)
	
	match weapon_state:
		WEAPON_STATE.idle:
			ANIMATION_PLAYER.play("Idle", -1, 1)
		WEAPON_STATE.shoot:
			ANIMATION_PLAYER.play("Shoot", -1, 1)
		WEAPON_STATE.reload_fast:
			ANIMATION_PLAYER.play("ReloadFast", -1, 1)

func _process(delta: float) -> void:
	pass

func weapon_bobing(delta : float) -> void:
	if Global.player.is_on_floor() and Global.player.input_dir != Vector2.ZERO:
		weapon_bobbing_vector.y = sin(weapon_bobbing_index)
		weapon_bobbing_vector.x = sin(weapon_bobbing_index / 2) + 0.5

		weapon_holder.position.y = lerp(weapon_holder.position.y, weapon_bobbing_vector.y * (weapon_bobbing_current_intensity / 2.0), delta * LERP_SPEED)
		weapon_holder.position.x = lerp(weapon_holder.position.x, weapon_bobbing_vector.x * weapon_bobbing_current_intensity, delta * LERP_SPEED)
	else:
		weapon_holder.position.y = lerp(weapon_holder.position.y, 0.0, delta * LERP_SPEED)
		weapon_holder.position.x = lerp(weapon_holder.position.x, 0.0, delta * LERP_SPEED)

func sway_weapon(delta : float) -> void:
	var sway_random : float = get_sway_noise()
	var sway_random_adjusted : float = sway_random * idle_sway_adjustment
	
	time += delta * (sway_speed * sway_random)
	random_sway_x = sin(time * 1.5 * sway_random_adjusted) / random_sway_amount
	random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount
	
	mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	
	weapon_holder.position.x = lerp(weapon_holder.position.x, position.x - (mouse_movement.x * WEAPON_TYPE.sway_amount_position + random_sway_x) 
	* delta, WEAPON_TYPE.sway_speed_position)
	weapon_holder.position.y = lerp(weapon_holder.position.y,  (mouse_movement.y * WEAPON_TYPE.sway_amount_position + random_sway_y) 
	* delta, WEAPON_TYPE.sway_speed_position)
	
	weapon_holder.rotation_degrees.y = lerp(weapon_holder.rotation_degrees.y, rotation.y + (mouse_movement.x * WEAPON_TYPE.sway_amount_rotation +
	(random_sway_y * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
	weapon_holder.rotation_degrees.x = lerp(weapon_holder.rotation_degrees.x, rotation.x - (mouse_movement.y * WEAPON_TYPE.sway_amount_rotation +
	(random_sway_x * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)

func get_sway_noise() -> float:
	var player_position : Vector3 = Vector3(0.0, 0.0, 0.0)
	
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
	
	var noise_location : float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	return noise_location

#每次射击都创建一个屏幕射线,在animationplayer调用
func _attack() -> void:
	weapon_fired.emit() #每次射击发出信号
	$AudioStreamPlayer.play()
	
	var rid_array : Array[RID]
	rid_array.append(Global.player.get_rid()) #排除Player
	var camera = Global.player.CAMERA
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	query.exclude = rid_array
	var result = space_state.intersect_ray(query)
	if result and not result.get("collider").is_in_group("enemy"):
		hit_particles(result.get("position"))
		
	var collider = result.get("collider") 
	if collider != null:
		for child in collider.get_children(): 
			if child is ItemHealthComponent:
				child.damage()
			if child is ImpulseComponent: #添加冲量
				weapon_hit.emit(collider)
			
		if collider.is_in_group("enemy"):
			#产生粒子
			Global.enemy.enemy_damage(result.get("position"))
	else:
		pass

#子弹接触物体产生粒子特效
func hit_particles(position : Vector3) -> void:
	var instance = hit_effect.instantiate()
	add_child(instance)
	instance.global_position = 	position
	if instance is GPUParticles3D:
		instance.emitting = true
	await get_tree().create_timer(3.0).timeout
	instance.queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Shoot":
		weapon_state = WEAPON_STATE.idle
	elif anim_name == "ReloadFast":
		weapon_state = WEAPON_STATE.idle
