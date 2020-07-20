extends KinematicBody2D


onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var raycast: RayCast2D = $RaycastsMovement/RayCast2D
onready var run_timer: Timer = $RunTimer
onready var next_mode_timer: Timer = $NextModeTimer
onready var poison_position: = $PoisonPosition
onready var skull_position: = $SkullPosition
onready var baby_position: = $BabyOozePosition
onready var ooze_poison: PackedScene = preload("res://src/Objects/PoisonOoze.tscn")
onready var ooze_skull: PackedScene = preload("res://src/Objects/SkullOoze.tscn")
onready var ooze_baby: PackedScene = preload("res://src/Actors/BabyOoze.tscn")
onready var parent = get_parent()
onready	var health_bar = get_parent().get_node("UserInterface/BossHealthBar")

const BASE_MOVESPEED = 4 * Global.UNIT_SIZE

var health = 100
var move_speed = BASE_MOVESPEED
var velocity = Vector2.ZERO
var flip = -1
var knockback_type = Vector2.ZERO
var summon_done = false
enum BossMode {
	WALK,
	RUN,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
	ATTACK_4,
	SNEER
}

var range_mode: Array = []

export (BossMode) var mode = BossMode.WALK

func _ready() -> void:
	for i in range(0, 1):
		range_mode.append(BossMode.ATTACK_1)

	for i in range(0, 1):
		range_mode.append(BossMode.ATTACK_3)

	for i in range(0, 1):
		range_mode.append(BossMode.ATTACK_4)

	for i in range(0, 1):
		range_mode.append(BossMode.SNEER)
	
	for i in range(0, 1):
		range_mode.append(BossMode.RUN)


func _physics_process(delta: float) -> void:	
	if health <= 0:
		animation_player.play("die")
	
	match mode:
		BossMode.WALK: 
			# Boss moves normally
			_walk()
		BossMode.RUN:
			# Boss has move speed powered up
			_run()
			
		BossMode.ATTACK_1:
			# Boss will stomp the floor
			_attack_1()
			
		BossMode.ATTACK_2:
			# Boss will summon a creature
			_attack_2()
			
		BossMode.ATTACK_3:
			# Boss will throw a bubble of poison
			_attack_3()
			
		BossMode.ATTACK_4:
			# Boss will launch a midair shot
			_attack_4()
			
		BossMode.SNEER:
			# Boss will throw a skull to the floor
			_sneer()
			
	velocity.x = move_speed * flip
	_check_wall()
			
	move_and_slide(velocity)
		
func _check_wall():
	if raycast.is_colliding():
		flip *= -1
		scale.x *= -1

func _invock_mini_it():
	var new_baby = ooze_baby.instance()
	new_baby.global_position = baby_position.global_position
	var direction = (PlayerData.position - new_baby.global_position).normalized()
	direction = -1 if direction.x < 0 else 1
	new_baby.awake(direction)
	parent.add_child(new_baby)
	
func _invock_skull():
	var new_skull = ooze_skull.instance()
	new_skull.global_position = skull_position.global_position
	var direction = (PlayerData.position - new_skull.global_position).normalized()
	direction = -1 if direction.x < 0 else 1
	new_skull.launch(direction)
	parent.add_child(new_skull)
	
func _invock_poison():
	var new_poison = ooze_poison.instance()
	new_poison.global_position = poison_position.global_position
	var direction = PlayerData.position - new_poison.global_position
	new_poison.launch(direction)
	parent.add_child(new_poison)
	
func _walk():
	if next_mode_timer.is_stopped():
		next_mode_timer.start()
		move_speed = BASE_MOVESPEED
		animation_player.play("walk")
	
func _run():
	if run_timer.is_stopped():
		raycast.cast_to = raycast.cast_to * 2
		animation_player.play("run")
		move_speed = move_speed  + 0.5 * BASE_MOVESPEED
		run_timer.start()
		knockback_type = Vector2(-1, -1)
	
func _attack_1():
	animation_player.play("attack_1")
	move_speed = 0
	knockback_type = Vector2(-1, -1)
	
func _attack_2():
	animation_player.play("attack_2")
	move_speed = 0
	
func _attack_3():
	animation_player.play("attack_3")
	move_speed = 0
	
func _attack_4():
	animation_player.play("attack_4")
	move_speed = 0
	knockback_type = Vector2(-1, -2)
	
func _sneer():
	if animation_player.current_animation != "sneer":
		var direction = (PlayerData.position - global_position).normalized()
		scale.x *= 1 if direction.x < 0 else -1
	animation_player.play("sneer")
	move_speed = 0
	
	
func _set_mode_base():
	mode = BossMode.WALK
	
func run_timer_end() -> void:
	move_speed = BASE_MOVESPEED
	animation_player.play("walk")
	_set_mode_base()
	raycast.cast_to = raycast.cast_to / 2
	run_timer.stop()


func _NextModeTimer_timeout() -> void:	
	if health < 50 and not summon_done:
		mode = BossMode.ATTACK_2
		summon_done = true
	else:
		mode = range_mode[randi() % range_mode.size()]
		next_mode_timer.stop()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	mode = range_mode[randi() % range_mode.size()]

func _calculate_boss_knockback():
	var velocity_boss
	var norm_position: Vector2 = (global_position - PlayerData.position).normalized()
	velocity_boss = norm_position * knockback_type
	velocity_boss.x *= scale.x
	return velocity_boss * Global.UNIT_SIZE * 20
	
func ennemy_takes_damage(damage):
	health -= damage
	health_bar._on_health_updated(health, 10)
		

func _on_HitBox_body_entered(body: Node) -> void:
	if body.name == "Player":
		PlayerData.health -= 10
		if mode == BossMode.ATTACK_4:
			body.jump()
		body.apply_boss_knockback(_calculate_boss_knockback())
	if body.name == "Projectile":
		body.queue_free()
