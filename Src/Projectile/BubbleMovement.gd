extends RigidBody2D

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	var range_rng = Vector2.ZERO
	if rng.randf() > 0.5:
		range_rng = Vector2(-70, -30)
	else:
		range_rng = Vector2(30, 70)
		
	var force = Vector2(
		rng.randf_range(range_rng.x, range_rng.y),
		-100
	)
	apply_impulse(Vector2(20,0), force)

func _physics_process(delta: float) -> void:
#	print(get_colliding_bodies())
	if get_colliding_bodies().size() > 0:
		get_tree().remove_child(self)
