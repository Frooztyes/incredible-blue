extends Button


func _on_button_up() -> void:
	PlayerData.score = 0
	PlayerData.health = PlayerData.max_health
	get_tree().paused = false
	get_tree().reload_current_scene()
