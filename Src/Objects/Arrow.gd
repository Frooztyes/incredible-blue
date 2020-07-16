extends RigidBody2D

onready var timer: Timer = $DissapTimer

var launched = false
var velocity = Vector2.ZERO

export (int) var arrow_damage = 10

func _ready() -> void:
	timer.start()

#func _process(delta: float) -> void:
##	rotation = get_angle_to(PlayerData.position.normalized())
#	pass
#
#
#
#func _on_Arrow_body_entered(body: Node) -> void:
#	if body.name != "Player":
#		timer.start()

func _on_DissapTimer_timeout() -> void:
	queue_free()


func _on_HitBox_body_entered(body: Node) -> void:
	print(PlayerData.health)
	PlayerData.health -= arrow_damage
	print(PlayerData.health)
	queue_free()
