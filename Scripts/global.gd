extends Node

var debug
#Scripts
var player : Player
var weapon : WeaponController
var wine_barrel : WineBarrel
var explode_barrel : ExplodeBarrel
var light_detect : LightDetect
#Component
var iteam_health_component : ItemHealthComponent
#var player_heath_component : PlayerHealthComponent
var food_health_component : FoodHealthComponent
var light_detection_component : LightDetectionComponent #光线检测
#变量
var is_explode : bool = false #物品爆破状态
