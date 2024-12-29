extends RayCast3D

@export var transition : Tween.TransitionType
@export var easing : Tween.EaseType
@export var override_icon : bool
@export var new_icon : Texture2D
@export var prompt : Label

signal interactable_seen(interactable)
signal interactable_unseen()

var _interactable = null:
	set = _set_interactable

func _process(delta: float) -> void:
	_update_interactable()

func _set_interactable(value) -> void:
	_interactable = value
	if _interactable == null:
		interactable_unseen.emit()
	else:
		interactable_seen.emit(_interactable)

func _update_interactable() -> void:
	var raycasted_collider = get_collider()
	var collider = raycasted_collider
	
	if not is_instance_valid(_interactable):
		if typeof(_interactable) != 0:
			_interactable = null
			return

	if collider != null and not collider.is_in_group("interactable"):
		collider = null
		
	if collider == _interactable:
		return
	
	if collider == null and typeof(collider) != 0:
		collider = null
	
	_interactable = collider
