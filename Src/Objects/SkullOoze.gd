extends KinematicBody2D


onready var raycast: RayCast2D = $RayCast2D
onready var anim_player: AnimationPlayer = $AnimationPlayer
var velocity = Vector2(0, -1)
var movespeed = 2 * Global.UNIT_SIZE

func _physics_process(delta: float) -> void:
	velocity.y += Global.gravity * delta
	
	if raycast.is_colliding():
		queue_free()
	
	move_and_slide(velocity)
	

func launch(direction):
	raycast = $RayCast2D
	anim_player = $AnimationPlayer
	anim_player.play("rotate_inverse" if direction == -1 else "rotate")
	velocity.x = direction * movespeed
	raycast.cast_to *= direction
	


func _on_Hitbox_body_entered(body: Node) -> void:
	print(body.name)
	if body.name == "Player":
		PlayerData.health -= 10
		queue_free()
