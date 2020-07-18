extends Area2D

onready var animation_player: = $AnimationPlayer
onready var timer: = $TimerDisappear

func _ready() -> void:
	PlayerData.time_level = 0 
	
func _on_TimerDisappear_timeout() -> void:
	animation_player.play("disappear")
