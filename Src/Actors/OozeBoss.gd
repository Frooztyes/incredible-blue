extends KinematicBody2D


onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var raycast: RayCast2D = $RaycastsMovement/RayCast2D
onready var run_timer: Timer = $RunTimer
onready var next_mode_timer: Timer = $NextModeTimer
onready var disable_platform_timer: Timer = $DisablePlatforms
onready var poison_position: = $PoisonPosition
onready var skull_position: = $SkullPosition
onready var baby_position: = $BabyOozePosition
onready var ooze_poison: PackedScene = preload("res://src/Objects/PoisonOoze.tscn")
onready var ooze_skull: PackedScene = preload("res://src/Objects/SkullOoze.tscn")
onready var ooze_baby: PackedScene = preload("res://src/Actors/BabyOoze.tscn")
onready var parent = get_parent()
onready	var health_bar = parent.get_node("UserInterface/BossHealthBar")
onready	var platforms = parent.get_node("Tiles/Platform")
onready	var ladders = parent.get_node("Ladders")

const BASE_MOVESPEED = 5 * Global.UNIT_SIZE
const DROP_THRU_BIT = 3

var health = 100
var move_speed = BASE_MOVESPEED
var velocity = Vector2.ZERO
var flip = -1
var summon_done = false
var summon_done_second = false
var dead = false
var baby_created = []
var buffer_animation = null

enum BossMode {
	WALK,
	RUN,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
	ATTACK_4,
	SNEER,
	HURT,
	DIE,
	STOP
}

var range_mode: Array = []

export (BossMode) var mode = BossMode.STOP

func _ready() -> void:
	mode = BossMode.STOP
	for i in range(0, 1):
		range_mode.append(BossMode.ATTACK_1)

	for i in range(0, 1):
		range_mode.append(BossMode.ATTACK_3)

	for i in range(0, 1):
		range_mode.append(BossMode.ATTACK_4)
#
	for i in range(0, 1):
		range_mode.append(BossMode.SNEER)

	for i in range(0, 1):
		range_mode.append(BossMode.RUN)


func _physics_process(delta: float) -> void:
	print(mode)
	if not dead:			
		velocity.y += Global.gravity * delta
		
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
				
			BossMode.HURT:
				# Boss will turn red
				_hurt()
				
			BossMode.DIE:
				# Boss will die
				_die()
			
		if not mode == BossMode.STOP:
			var vect_bet: = (PlayerData.position - global_position).normalized() 
			var ratio = -1 if vect_bet.x < 0 else 1 
			
			if ratio != flip:
				if randf() < 0.01 && move_speed != 0:
					flip *= -1
					scale.x *= -1
				
				
			velocity.x = move_speed * flip
			_check_wall()
					
			move_and_slide(velocity)
		else:
			if animation_player.current_animation != "stop":
				animation_player.play("stop")
				
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
	baby_created.append(new_baby)
	
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

func _disable_platforms():
	platforms.visible = false
	platforms.set_collision_layer_bit(DROP_THRU_BIT, false)
	disable_platform_timer.start()
	platforms.set_occluder_light_mask(2)
	
	for ladder in ladders.get_children():
		ladder.visible = false
		ladder.get_node("CollisionShape2D").disabled = true
	
func _walk():
	if buffer_animation != null:
		mode = buffer_animation
		buffer_animation = null
		
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
	
func _attack_1():
	animation_player.play("attack_1")
	move_speed = 0
	
func _attack_2():
	animation_player.play("attack_2")
	move_speed = 0
	
func _attack_3():
	animation_player.play("attack_3")
	move_speed = 0
	
func _attack_4():
	animation_player.play("attack_4")
	move_speed = 0
	
func _sneer():
	animation_player.play("sneer")
	move_speed = 0
	
func _hurt():
	animation_player.play("hurt")
	move_speed = 0
	
func _die():
	if animation_player.current_animation != "die":
		dead = true
		animation_player.play("die")
		move_speed = 0
		for baby in baby_created:
			baby.die()
	
	
func _set_mode_base():
	if not mode == BossMode.STOP:
		mode = BossMode.WALK
	
func run_timer_end() -> void:
	move_speed = BASE_MOVESPEED
	animation_player.play("walk")
	_set_mode_base()
	raycast.cast_to = raycast.cast_to / 2
	run_timer.stop()


func _NextModeTimer_timeout() -> void:	
	if not dead:
		if health < 50 and not summon_done:
			if mode == BossMode.WALK:
				mode = BossMode.ATTACK_2
			else:
				buffer_animation = BossMode.ATTACK_2
			summon_done = true
		elif health < 25 and not summon_done_second:
			if mode == BossMode.WALK:
				mode = BossMode.ATTACK_2
			else:
				buffer_animation = BossMode.ATTACK_2
			summon_done_second = true
		else:
			mode = range_mode[randi() % range_mode.size()]
			next_mode_timer.stop()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if mode != BossMode.STOP:
		mode = range_mode[randi() % range_mode.size()]

func _calculate_boss_knockback():
	var norm_position: Vector2 = (global_position - PlayerData.position).normalized()
	return -1 if norm_position.x < 0 else 1
	
func ennemy_takes_damage(damage):
	mode = BossMode.HURT
	health -= damage
	health_bar._on_health_updated(health, 10)
	if health <= 0:
		mode = BossMode.DIE
		

func _on_HitBox_body_entered(body: Node) -> void:
	if body.name == "Player":
		PlayerData.health -= 10
		var direction = _calculate_boss_knockback()
		body.apply_jump_knockback(direction)
	if body.name == "Projectile":
		body.queue_free()


func _on_DisablePlatforms_timeout() -> void:
	platforms.visible = true
	platforms.set_collision_layer_bit(DROP_THRU_BIT, true)
	platforms.set_occluder_light_mask(1)
	
	for ladder in ladders.get_children():
		ladder.visible = true
		ladder.get_node("CollisionShape2D").disabled = false

func start():
	mode = BossMode.WALK

