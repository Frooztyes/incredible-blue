extends RigidBody2D


var velocity = Vector2.ZERO
var acceleration = 2

#func _physics_process(delta: float) -> void:
#	linear_velocity *= acceleration

func launch(norm_speed):
	linear_velocity = norm_speed

func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Blocks":
		queue_free()
	if body.name == "Player":
		PlayerData.health -= 5
		body.slow(0.5, 2)
		queue_free()
		
