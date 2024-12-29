class_name HealthComponent

extends Node

@export var health : float = 100.0

var current_health : float

signal explode
signal damge

func _ready() -> void:
	Global.health_component = self
	current_health = health
	
func _damage() -> void:
	current_health -= 40
	
	if current_health <= 0.0:
		explode.emit()
	else:
		damge.emit()
	
