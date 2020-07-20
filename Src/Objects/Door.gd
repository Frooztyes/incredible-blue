tool
extends Area2D

export var next_scene: PackedScene
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_sprite: AnimatedSprite = $AnimatedSprite

var player: PhysicsBody2D
var is_in_portal: = false

func _on_body_entered(body: PhysicsBody2D) -> void:
	player = body
	is_in_portal = true
	
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and is_in_portal:
		player.stop_movement()
		anim_sprite.playing = true
		yield(anim_sprite, "animation_finished")
		player.get_node('AnimationPlayer').play("TakeDoor")
		yield(player.get_node('AnimationPlayer'), "animation_finished")
		PlayerData.score += PlayerData.level_score
		PlayerData.level_score = 0
		teleport()
		
func _get_configuration_warning() -> String:
	return "The next scene property can't be empty" if not next_scene else ""

func teleport() -> void:
	anim_player.play("fade_in")
	yield(anim_player, "animation_finished")
	get_tree().change_scene_to(next_scene)


