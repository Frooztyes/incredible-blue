extends Actor

export var stomp_impulse: = 1000.0
onready var timer: Timer = get_node("TimerArrow")

var arrow: PackedScene = load("res://Src/Objects/Arrow.tscn")
var can_start: bool = false
var is_on_ladder: int = 0
var attack_pressed: bool = false

func _on_EnnemyDetector_area_entered(area: Area2D) -> void:
	if area.name == "Ennemy":
		_velocity = calculate_stomp_velocity(_velocity, stomp_impulse)
	
func _on_EnnemyDetector_body_entered(body: PhysicsBody2D) -> void:
	die()
	
func _ready() -> void:
	get_node("AnimationPlayer").play("appear_portal")
	yield(get_node("AnimationPlayer"), "animation_finished")
	can_start = true
	
	timer.set_wait_time(2)
	
func _physics_process(delta: float) -> void:
	PlayerData.position = position
	if can_start:
		
		if Input.is_action_just_pressed("attack"):
			attack_pressed = true
			timer.start()
		elif Input.is_action_just_released("attack"):
			attack_pressed = false
		elif timer.time_left > 0 and not attack_pressed:
#			instanciateArrow((2-timer.time_left)/2)
			timer.stop()
			
		var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
		var direction: = get_direction()
		
		if direction.x == 0.0:
			get_node("AnimatedSprite").play("idle")
		else:
			get_node("AnimatedSprite").play("walk")
			if direction.x == -1.0:
				get_node("AnimatedSprite").set_flip_h(true)
			else:
				get_node("AnimatedSprite").set_flip_h(false)
				
			
		_velocity  = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
		_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	
	if position.y > 800:
		PlayerData.health = 0
		PlayerData.deaths += 1
		
func get_direction() -> Vector2:
	var jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump = -1.0
	elif is_on_ladder:
		jump = 0
	else:
		jump = 1.0	
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		jump
	)

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	
	if is_on_ladder == 0:
		out.y += gravity * get_physics_process_delta_time()
		if direction.y == -1.0:
			out.y = speed.y * direction.y
		if is_jump_interrupted:
			out.y = 0.0
	else:
		out.y = (speed.y * (Input.get_action_strength("jump") - Input.get_action_strength("down")) * -1.0)/1.5
			
	return out

func calculate_stomp_velocity(
		linear_velocity: Vector2,
		impulse: float
	) -> Vector2:
	var out: = linear_velocity
	out.y = -impulse
	return out

func die() -> void:
	PlayerData.deaths += 1
	queue_free()

func stop_movement() -> void:
	can_start = false
	
func set_on_ladder(is_it: bool) -> void:
	if is_it:
		is_on_ladder += 1
	else:
		is_on_ladder -= 1

func _on_TimerArrow_timeout() -> void:
#	instanciateArrow(2/2)
	timer.stop()
	
func instanciateArrow(speed: float) -> void:
	print("floutch")
	var new_arrow: Area2D = arrow.instance()
	new_arrow.rotation = get_angle_to(get_global_mouse_position()) + self.rotation
	
	new_arrow.position = Vector2(position.x, position.y)
	get_parent().add_child(new_arrow)
	new_arrow.launch(
		(get_global_mouse_position()).normalized()
	)
	
	
