extends Node3D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

@export var _weapon_resource : Array[WeaponResource]
@export var start_weapon : Array[String]

var current_weapon = null
var weapon_stack = []
var weapon_indicator = 0
var next_weapon : String
var weapon_list : Dictionary = {}

signal weapon_changed
signal update_ammo
signal update_weapon_stack

func _ready() -> void:
	Initialize(start_weapon)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon1"):
		weapon_indicator = max(weapon_indicator - 1, 0)
		exit(weapon_stack[weapon_indicator])
		
	if event.is_action_pressed("weapon2"):
		weapon_indicator = min(weapon_indicator + 1, weapon_stack.size() - 1)
		exit(weapon_stack[weapon_indicator])
		
	if event.is_action_pressed("fire"):
		shoot()
	
	if event.is_action_pressed("reload"):
		reload()
		
func Initialize(_start_weapons : Array):
	for weapon in _weapon_resource:
		weapon_list[weapon.weapon_name] = weapon
		
	for i in _start_weapons:
		weapon_stack.push_back(i)
		
	current_weapon = weapon_list[weapon_stack[0]]
	enter()
	
func enter():
	animation_player.queue(current_weapon.activate_animate)
	
func exit(_next_weapon : String):
	if _next_weapon != current_weapon.weapon_name:
		if animation_player.get_current_animation() != current_weapon.deactivate_animate:
			animation_player.play(current_weapon.deactivate_animate)
			next_weapon = _next_weapon
	
func change_weapon(weapon_name : String):
	current_weapon = weapon_list[weapon_name]
	next_weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == current_weapon.deactivate_animate:
		change_weapon(next_weapon)

func shoot() -> void:
	animation_player.play(current_weapon.shoot_animate)
	
func reload() -> void:
	animation_player.play(current_weapon.reload_animate)
