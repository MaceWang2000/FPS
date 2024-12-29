class_name ItemHealthComponent

extends Node

@export var health_damage : float ##伤害值
@export var max_health : float = 100
var current_health : float

signal hurt
signal death

func _ready() -> void:
	Global.iteam_health_component = self
	current_health = max_health

func damage() -> void:
	current_health -= health_damage
	if current_health <= 0:
		death.emit()
	else:
		hurt.emit()
