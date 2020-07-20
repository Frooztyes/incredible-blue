extends "res://src/Actors/Actor.gd"

var actual_flip: = false

var in_collision: = false

#onready var projectile = preload("res://src/Projectile/Bubble.tscn").instance()
onready var animation_player = $AnimationPlayer

export var score: = 100

var time_start = 0
var time_now = 0
var time_marker = 0

func _ready() -> void:
	set_physics_process(false)
	_velocity.x = -speed.x
	get_node("ennemy").set_flip_h(actual_flip)
	time_start = OS.get_unix_time()

func _on_StompDetector_body_entered(body: PhysicsBody2D) -> void:
	if body != null:
		if body.global_position.y > get_node("StompDetector").global_position.y:
			return
		$StompDetector.queue_free()
		$CollisionShape2D.queue_free()
		in_collision = true
		die()
	
func _physics_process(delta: float) -> void:
	if !in_collision :
		_velocity.y += gravity * delta
		if is_on_wall():
			actual_flip = !actual_flip
			get_node("ennemy").set_flip_h(actual_flip)
			_velocity.x *= -1.0
		_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y
	else:
#		add_child(projectile)
		pass

func die() -> void:
	PlayerData.level_score += score
	animation_player.play("stomped")
	yield(animation_player, "animation_finished")
	queue_free()
	
func get_running_time() -> int:
	return OS.get_unix_time() - time_start
