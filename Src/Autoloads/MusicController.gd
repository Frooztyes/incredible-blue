extends Node

var battle_music = load("res://assets/Audio/music.wav")

func _ready() -> void:
	pass
	
func play_music() -> void:
	$Music.stream = battle_music
	$Music.play()

func is_playing() -> bool:
	return $Music.playing
