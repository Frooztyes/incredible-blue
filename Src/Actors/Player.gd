extends KinematicBody2D

signal throw_item()

const UP = Vector2(0, -1)
const SLOPE_STOP = 64
const BOUNCE_VELOCITY = -(5 * Global.UNIT_SIZE)
const KNOCKBACK_VELOCITY = Vector2(
	2 * Global.UNIT_SIZE,
	-2 * Global.UNIT_SIZE
)
const BASE_MOVESPEED = 5 * Global.UNIT_SIZE


onready var timer: Timer = $TimerArrow
onready var attack_bar: = $AttackBar
onready var sprite: AnimatedSprite= $Scaler/AnimatedSprite
onready var anim_player: = $AnimationPlayer
onready var anim_player_damage: = $TakeDamageAnim
onready var raycasts = $Scaler/Raycasts
onready var bounce_raycasts = $Scaler/BounceRaycasts
onready var coyote_timer: Timer = $CoyoteTimer
onready var jump_buffer: Timer = $JumpBuffer
onready var slow_timer: Timer = $SlowTimer
onready var arrow_position: = $Scaler/ArrowPosition
onready var scaler: = $Scaler

# arrow scene to instance
var projectile: PackedScene = preload("res://src/Objects/Projectile.tscn")

var dobby: PackedScene = preload("res://src/Actors/Dobby.tscn")

# needs int to handle multiple ladders
var is_on_ladder: int = 0
var attack_pressed: bool = false
var can_move: bool = true
var key_stop: bool = false
var shoot_finished: bool = false
var move_direction

# move variable
var velocity = Vector2()
# corresponds to N tiles per seconds
var move_speed = 5 * Global.UNIT_SIZE
# corresponds to N tiles per seconds
var ladder_speed = 7 * Global.UNIT_SIZE
var gravity 
var max_jump_velocity
var min_jump_velocity 
var is_grounded
var is_jumping = false

# corresponds to N tiles per jump_duration seconds
var max_jump_height = 2.25 * Global.UNIT_SIZE
var min_jump_height = 0.8 * Global.UNIT_SIZE
var jump_duration = 0.4

var attack_type = "Bow"

# konami code
var sequence = [
	KEY_UP,
	KEY_UP,
	KEY_DOWN,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_B,
	KEY_A	
]
var sequence_index = 0

# func run when this scene appear
func _ready() -> void:
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	PlayerData.connect("player_damaged", self, "_damage_take")
	attack_bar.visible = false

# charge power attack bar
func _charge_bar():
	attack_bar.value = ((timer.wait_time - timer.time_left)/timer.wait_time)*100

# this func runs every frame
func _physics_process(delta: float) -> void:
	PlayerData.position = global_position
	_apply_gravity(delta)
	_handle_movement_input()
	_apply_movement(delta)
	_assign_animation()
	
func _apply_gravity(delta):
	# remove gravity in case of ladder or when coyote is on
	if coyote_timer.is_stopped() or is_on_ladder == 0:
			velocity.y += gravity * delta
			if is_jumping && velocity.y > 0:
				is_jumping = false
	
func _apply_movement(delta):
	_check_bounce(delta)
	var was_on_floor = is_on_floor()
	if can_move:
		velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	if !is_on_floor() && was_on_floor && !is_jumping:
		coyote_timer.start()
		velocity.y = 0
	if is_on_floor() && !jump_buffer.is_stopped():
		jump_buffer.stop()
		jump()
		
	is_grounded = _check_is_grounded()
	
	if is_grounded:
		pass
	
	_check_attack()
	
# check if the player is pressing attack to instantiate an arrow
func _check_attack():
	if Input.is_action_just_pressed("change_attack"):
		attack_type = "Sword" if attack_type == "Bow" else "Bow"
		
	if attack_type == "Bow" && PlayerData.arrows > 0:
		# attack start only if player is grounded
		if Input.is_action_just_pressed("attack"):
			sprite.play("shoot_charge")
			attack_bar.visible = true
			attack_pressed = true
			timer.start()
		elif Input.is_action_just_released("attack"):
			attack_pressed = false
			anim_player.play("shoot")
		elif timer.time_left > 0 and not attack_pressed:
			anim_player.play("shoot")
		elif attack_pressed:
			_charge_bar()
			
	elif attack_type == "Sword":
		if Input.is_action_just_pressed("attack"):
			anim_player.play("attack")

func jump():
	velocity.y = max_jump_velocity		
	is_jumping = true
	
# handle jump and interrupted jumped
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if is_on_floor() || !coyote_timer.is_stopped():	
			coyote_timer.stop()
			jump()
		else:
			jump_buffer.start()
			
	if event.is_action_released("jump") and velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity
		
#	if event.is_action_pressed("move_left"):
#		scale.x = -1
#		print(scale)
#	if event.is_action_pressed("move_right"):
#		scale.x = 1
	cheat_code(event)
		
# change the velocity from the input pressed. Don't handle jump, but handle vertical flip
func _handle_movement_input():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
		
	if move_direction < 0:
		scaler.scale.x = -1
	elif move_direction > 0:
		scaler.scale.x = 1
		
	if is_on_ladder > 0:
		var move_up: = -int(Input.is_action_pressed("jump")) + int(Input.is_action_pressed("down"))
		if move_up == 0:
			velocity.y = 0
		else:
			velocity.y = lerp(velocity.y, ladder_speed * move_up, 0.2)
	
# 0.05 is a bit too low
func _get_h_weight():
	if is_on_floor() || !coyote_timer.is_stopped():
		return 0.2
	else:
		return 0.1
	
# return true if one raycast is in ground
func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
# change animation in each situation (run, jump, idle)
func _assign_animation():
				
#	var anim = "idle"
#	if !is_grounded && coyote_timer.is_stopped():
#		anim = "jump"
#	elif velocity.x != 0:
#		anim = "run"

	if attack_pressed && (timer.wait_time-timer.time_left)/timer.wait_time >= 0.75:
#		anim = "shoot"
		sprite.play("shoot_max")
#	if sprite.animation != anim:
#		sprite.play(anim)
		
# instantiate arrow to mouse coordinate
func _instantiate_arrow():
	# reset attack_bar
	attack_bar.visible = false
	attack_bar.value = 0
		
	var arrow_power = (timer.wait_time-timer.time_left)/timer.wait_time
	# remove charge bar
	attack_bar.visible = false
	
	var projectile_ins = projectile.instance()
	
	projectile_ins.position = arrow_position.global_position
	
	get_parent().add_child(projectile_ins)
	
	projectile_ins.launch(get_global_mouse_position(), 1)
	
	timer.stop()
	
	PlayerData.arrows -= 1
	
	sprite.play("idle")

# if player collides with an ennemy
func _on_EnnemyDetector_body_entered(body: PhysicsBody2D) -> void:
	PlayerData.health -= 10
	apply_knockback(body.global_position)
	
# event on death of player
func die() -> void:
	PlayerData.deaths += 1
	queue_free()

# set the is_on_ladder bool (func used in ladder script)
func set_on_ladder(is_it: bool) -> void:
	if is_it:
		is_on_ladder += 1
	else:
		is_on_ladder -= 1

# when the timer arrives to the end
func _on_TimerArrow_timeout() -> void:
	anim_player.play("shoot")

# to stop all movement of player
func stop_movement() -> void:
	can_move = false

func _check_bounce(delta):
	if velocity.y > 0:
		for raycast in bounce_raycasts.get_children():
			raycast.cast_to = Vector2.DOWN * velocity * delta + Vector2.DOWN
			raycast.force_raycast_update()
			if raycast.is_colliding() && raycast.get_collision_normal() == Vector2.UP:
				velocity.y = (raycast.get_collision_point() - raycast.global_position - Vector2.DOWN).y / delta
				raycast.get_collider().entity.call_deferred("be_bounced_upon", self)
				break

func bounce(bounce_velocity = BOUNCE_VELOCITY):
	velocity.y = bounce_velocity

func _damage_take():
	anim_player_damage.play("take_damage")
	
func slow(percentage, duration):
	move_speed *= percentage
	slow_timer.wait_time = duration
	slow_timer.start()

func _on_SlowTimer_timeout() -> void:
	slow_timer.stop()
	move_speed = BASE_MOVESPEED
	
func apply_knockback(projectile_position):
	var norm_position: Vector2 = (global_position - projectile_position).normalized()
	
	velocity += KNOCKBACK_VELOCITY * (-1 if norm_position.x < 0 else 1)
	
func apply_boss_knockback(velocity_boss):
	print(velocity_boss)
	velocity += velocity_boss
	
func _on_SwordHit_body_entered(body: Node) -> void:
	print("touch")
	if body.has_method("ennemy_takes_damage"):
		body.ennemy_takes_damage(5)

func cheat_code(ev: InputEvent):
	if ev is InputEventKey && not ev.pressed:
		if ev.scancode == sequence[sequence_index]:
			sequence_index += 1
			if sequence_index == sequence.size():
				var new_dobby = dobby.instance()
				get_parent().add_child(new_dobby)
				new_dobby.global_position = get_global_mouse_position()
				sequence_index = 0
		else:
			sequence_index = 0

