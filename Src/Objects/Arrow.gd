extends RigidBody2D

onready var timer: Timer = $DissapTimer

const GRAVITY = 10000

var launched = false
var velocity = Vector2.ZERO

export (int) var arrow_damage = 10

func _ready() -> void:
	timer.start()

func _process(delta: float) -> void:
#	velocity.y += GRAVITY * delta
	pass

func _on_DissapTimer_timeout() -> void:
	queue_free()


func _on_HitBox_body_entered(body: Node) -> void:
	if body.name == "Player":
		PlayerData.health -= arrow_damage
		body.apply_knockback(global_position)
		queue_free()
	else:
		queue_free()
