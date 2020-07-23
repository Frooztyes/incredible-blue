extends Node2D

onready var boss_health_bar = $UserInterface/BossHealthBar
onready var ooze_boss = $Radiant
onready var canvas_light = $CanvasModulate
onready var light = $Light2D
onready var camera = $Player/Camera2D
onready var animation_player = $AnimationPlayer
onready var start_boss_timer = $StartBossTimer

func _stop_any_action():
	MusicController.play_boss_swamp()
	light.visible = true
	boss_health_bar.visible = true
	canvas_light.visible = true
	camera.zoom = Vector2(1.3, 1.3)
	
func _start_timer():
	start_boss_timer.start()

func _on_StartBoss_body_entered(body: Node) -> void:
	animation_player.play("Appear")
	
func _on_StartBossTimer_timeout() -> void:
	animation_player.play("Disappear")
	start_boss_timer.stop()
	ooze_boss.start()
	
