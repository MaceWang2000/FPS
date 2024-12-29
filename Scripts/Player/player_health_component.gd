class_name PlayerHealthComponent

extends Node

#@export_group("Parameters")
#@export var MAX_HEALTH := 100
#@export var fall_damage_threshold := 15 # 开始掉落伤害的门槛高度
#@export var max_fall_damage_threshold := 30 # 最大掉落伤害的门槛高度
#@export var decline_health := 0 ## 减少的生命值
#
#@export_group("Food")
#@export var canned_herring := 0 ##鲱鱼罐头回复血量
#@export var canned_fruit := 0 ##水果罐头回复血量
#
#@export_group("UseNode")
#@export var hurt_overlay: TextureRect
#@export var hurt_bar: ProgressBar
#@export var hurt_bar_bg: ProgressBar
#
#var current_health := 0
#var hurt_tween: Tween
#
#func _ready() -> void:
	#Global.player_heath_component = self
	##Events.drink_eat.connect(regain_health)
	#current_health = MAX_HEALTH
	#hurt_bar.value = current_health
	#hurt_bar_bg.value = hurt_bar.value
#
#func _process(delta: float) -> void:
	#if current_health > MAX_HEALTH:
		#current_health = MAX_HEALTH
#
##PlayerdHurt
#func player_hurt(damage: int) -> void:
	#current_health -= damage
	#hurt_bar.value -= damage
	#if current_health > 0.0:
		#hurt_overlay.modulate = Color.WHITE
		#%Hurt.play()
		#hurt_bar_tween()
	#elif current_health <= 0.0:
		#print("Player is Death")
#
##血量UI的Tween变化
#func hurt_bar_tween() -> void:
	#if hurt_tween:
		#hurt_tween.kill()
	#
	#hurt_tween = create_tween()
	#hurt_tween.parallel().tween_property(hurt_overlay, "modulate", Color.TRANSPARENT, 0.5)
	#hurt_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	#hurt_tween.parallel().tween_property(hurt_bar_bg, "value", hurt_bar.value, 0.6)
#
##回复血量UI
#func regain_health() -> void:
	#if current_health < MAX_HEALTH:
		#current_health += canned_herring
		#hurt_bar.value += canned_herring
		#hurt_bar_tween()
