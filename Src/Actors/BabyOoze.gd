extends KinematicBody2D

enum EnnemyState {
	WALK,
	DIE,
	ATTACK,
	HURT
}

const BASE_MOVESPEED = 2 * Global.UNIT_SIZE

onready var animation_player = $AnimationPlayer
onready var raycast_attack = $RayCast2D
onready var cooldown_attack = $CooldownAttack
onready var raycast_wall: RayCast2D = $RayCast2Wall
export (EnnemyState) var mode = EnnemyState.WALK

var touched = 2
var velocity: Vector2 = Vector2(1, 1)
var movespeed = BASE_MOVESPEED
var flip = -1
var gravity
var jump_duration = 0.5
var jump_height = 1.2 * Global.UNIT_SIZE
var jump_velocity
var can_attack = true
var dead = false

func _ready() -> void:
	gravity = 2 * jump_height / pow(jump_duration, 2)
	jump_velocity = -sqrt(2 * gravity * jump_height)

func _physics_process(delta: float) -> void:
	match mode:
		EnnemyState.WALK:
			_walk()
			
		EnnemyState.ATTACK:
			_attack()
			
	velocity.y += gravity * delta
	if not dead:
		if raycast_wall.is_colliding():
			flip *= -1
			scale.x *= -1
			
		
		if raycast_attack.is_colliding():
			mode = EnnemyState.ATTACK
			
			
		velocity.x = movespeed * flip
		move_and_slide(velocity)
	
func _walk():
	if animation_player.current_animation != "walk" and not dead:
		animation_player.play("walk")
		

func _attack():
	if animation_player.current_animation != "attack" && can_attack and not dead:
		animation_player.play("attack")
		_jump()
		cooldown_attack.start()
		can_attack = false
	
func _jump():
	velocity.y = jump_velocity
	movespeed = 2 * BASE_MOVESPEED
	
func _walk_again():
	movespeed = BASE_MOVESPEED
	mode = EnnemyState.WALK
	
func awake(direction):
	flip = direction
	scale.x *= -direction

func _on_Hitbox_body_entered(body: Node) -> void:
	if body.name == "Player":
		PlayerData.health -= 5

func ennemy_takes_damage(amount):
	print("outch")
	mode = EnnemyState.HURT
	movespeed = 0
	touched -= 1
	if touched <= 0:
		animation_player.play("death")
		dead = true
	else:
		animation_player.play("hurt")

func die():
	animation_player.play("death")
	dead = true
	
	
func _rewake_afterhit():
	movespeed = BASE_MOVESPEED * 1.5
	mode = EnnemyState.WALK
	
func _on_CooldownAttack_timeout() -> void:
	can_attack = true
	cooldown_attack.stop()
