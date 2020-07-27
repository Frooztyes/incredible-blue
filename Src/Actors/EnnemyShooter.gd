extends "res://src/Actors/Actor.gd"

var actual_flip: = false
var in_collision: = false
var corpse_in: bool = false

onready var projectile: PackedScene = preload("res://src/Objects/Arrow.tscn")
onready var animation_player = $AnimationPlayer
onready var raycast: RayCast2D = get_node("Vision")
onready var timer: Timer = get_node("ShootTimer")

export var score: = 100

var time_start = 0
var time_now = 0
var time_marker = 0
var player_position = Vector2.ZERO
var is_dead = false

func _ready() -> void:
#	set_physics_process(false)
	_velocity.x = -speed.x
	get_node("ennemy").set_flip_h(actual_flip)
	time_start = OS.get_unix_time()

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
	
func get_running_time() -> int:
	return OS.get_unix_time() - time_start

func instanciateProjectile():
	var new_projectile: RigidBody2D = projectile.instance()
	
	new_projectile.rotation = get_angle_to(player_position) + new_projectile.rotation
	
	new_projectile.position = Vector2(global_position.x, global_position.y-10)
	
	get_parent().add_child(new_projectile)
	
	var direction_proj = (player_position - global_position)
	new_projectile.apply_impulse(Vector2(), direction_proj.normalized()*400)
	
func _on_DetectionZone_body_entered(body: Node) -> void:
	if body.name == "Player":
		raycast.cast_to = body.global_position - global_position
		corpse_in = true
		in_collision = true
		if timer.time_left == 0:
			timer.start()
			if not raycast.is_colliding():
				player_position = PlayerData.position
				instanciateProjectile()
	
func _on_DetectionZone_body_exited(body: Node) -> void:
	if body.name == "Player":
		corpse_in = false
		in_collision = false
		player_position = Vector2.ZERO

func _on_ShootTimer_timeout() -> void:
	if not is_dead:
		if corpse_in:
			player_position = PlayerData.position
			raycast.cast_to = player_position - global_position
			timer.start()
			player_position = PlayerData.position
			instanciateProjectile()

func be_bounced_upon(bouncer):
	if bouncer.has_method("bounce"):
		bouncer.bounce()

func ennemy_takes_damage(damage):
	animation_player.play("hit")
	$BounceArea/CollisionShape2D.disabled = true
	$CollisionShape2D.disabled = true
	yield(animation_player, "animation_finished")
	die()
	queue_free()

		
