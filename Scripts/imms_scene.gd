extends Node

func _enter_tree() -> void:
	SceneManager._current_scene_root_node = self
