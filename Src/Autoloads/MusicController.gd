extends Node

var battle_music = load("res://assets/Audio/music.wav")
var boss_swamp = load("res://assets/Audio/boss_swamp.wav")
var wide = load("res://assets/Audio/wide.wav")
	
func play_music() -> void:
	$Music.stream = battle_music
	$Music.play()

func is_playing() -> bool:
	return $Music.playing

func play_boss_swamp():
	$Music.stream = boss_swamp
	$Music.play()
	
func play_cheat_code_music():
	$Music.stream = wide
	$Music.play()
