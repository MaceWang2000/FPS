extends CharacterBody3D

enum STATES{
	patrol,
	chasing, #追逐
	hunting, #狩猎
	waiting
}

@export var navigation_agent : NavigationAgent3D
@export var waypoints : Array
@export var SPEED : float
@export var patrol_timer : Timer
@export var HEAD : Marker3D


var current_state : STATES
var waypoint_index : int
var light_level : float
#听力
var player_in_earshot_far : bool
var player_in_earshot_close : bool
#视力
var player_in_singht_far : bool
var player_in_singht_close : bool

func _ready() -> void:
	current_state = STATES.patrol
	waypoints = get_tree().get_nodes_in_group("enemy_waypoint")

	navigation_agent.set_target_position(waypoints[0].global_position)

func _physics_process(delta: float) -> void:
	await get_tree().physics_frame
	match current_state:
		STATES.patrol:
			if navigation_agent.is_navigation_finished():
				current_state = STATES.waiting
				patrol_timer.start()

			move_towards_point(delta, SPEED)

		STATES.chasing:
			if navigation_agent.is_navigation_finished():
				current_state = STATES.waiting

			navigation_agent.set_target_position(Global.player.global_position)
			move_towards_point(delta, SPEED)

		STATES.hunting:
			if navigation_agent.is_navigation_finished():
				current_state = STATES.waiting
				patrol_timer.start()

			navigation_agent.set_target_position(Global.player.global_position)
			move_towards_point(delta, SPEED)

		STATES.waiting:
			if navigation_agent.is_navigation_finished():
				current_state = STATES.waiting

			navigation_agent.set_target_position(Global.player.global_position)
			move_towards_point(delta, SPEED)

#巡逻
func move_towards_point(delta : float, speed : float) -> void:
	var target_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_position)

	face_direction(target_position)

	velocity = direction * SPEED
	move_and_slide()

func face_direction(direction : Vector3) -> void:
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _on_patrol_timer_timeout() -> void:
	current_state = STATES.patrol
	waypoint_index += 1
	if waypoint_index > waypoints.size() - 1:
		waypoint_index = 0
	navigation_agent.set_target_position(waypoints[waypoint_index].global_position)


func _on_hearing_close_body_exited(body:Node3D) -> void:
	if body is Player:
		player_in_earshot_close = false

func _on_hearing_close_body_entered(body:Node3D) -> void:
	if body is Player:
		player_in_earshot_close = true
	
	if body is RigidBody3D:
		Events.object_explode.connect(_on_explode_object)

func _on_explode_object() -> void:
	current_state = STATES.chasing

func _on_hearing_far_body_exited(body:Node3D) -> void:
	if body is Player:
		player_in_earshot_far = false

func _on_hearing_far_body_entered(body:Node3D) -> void:
	if body is Player:
		player_in_earshot_far = true
	



func _on_sight_far_body_exited(body:Node3D) -> void:
	if body is Player:
		player_in_singht_far = false
		

func _on_sight_far_body_entered(body:Node3D) -> void:
	if body is Player:
		player_in_singht_far = true
		

func _on_sight_close_body_exited(body:Node3D) -> void:
	if body is Player:
		player_in_singht_close = false
		

func _on_sight_close_body_entered(body:Node3D) -> void:
	if body is Player and Global.light_detection_component.light_level > 0.5:
		player_in_singht_close = true
		current_state = STATES.chasing
	
