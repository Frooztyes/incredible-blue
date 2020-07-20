extends KinematicBody2D

const THROW_VELOCITY = Vector2(800, -400)

var velocity = Vector2.ZERO
var stick_wall: = false

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not stick_wall:
		velocity.y += Global.gravity * delta
		
		if velocity.x > 0:
			rotation += delta
		else:
			rotation -= delta
			
		var collision = move_and_collide(velocity * delta)
	
		if collision != null:
			_on_impact(collision.normal)

func launch(target_position, power):
	# Reparent
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	
	# Set velocity
	target_position += Vector2(rand_range(-64, 64), rand_range(-64, 64))
	var arc_height = target_position.y - global_position.y - 32
	arc_height = min(arc_height, -32)
	velocity = PhysicsHelper.calculate_arc_velocity(global_position, target_position, arc_height)
	velocity = velocity.clamped(1000)
	velocity = velocity.rotated(rand_range(-0.1, 0.1))
	set_physics_process(true)
	
	if velocity.x < 0:
		$Sprite.set_flip_h(true)
	
	velocity *= power
	
func _on_impact(normal: Vector2):
	stick_wall = not stick_wall
#	velocity = velocity.bounce(normal)
#	velocity *= 0.5 + rand_range(-0.05, 0.05)


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.has_method("ennemy_takes_damage"):
		body.ennemy_takes_damage(10)
		queue_free()
	if body.name == "Blocks":
		queue_free()
