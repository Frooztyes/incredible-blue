extends Control

func _ready() -> void:
	if get_tree().paused:
		get_tree().paused = false
	MusicController.play_music() if not MusicController.is_playing() else ''
