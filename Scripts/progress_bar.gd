extends ProgressBar


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if self.value == 100.0:
		var fade_tween : Tween = get_tree().create_tween()
		fade_tween.tween_property(self, "modulate:a", 0.0, 1.0)
		await fade_tween.finished
		self.value = 0.0
