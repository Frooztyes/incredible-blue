extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
#	position = get_global_mouse_position()
#	position.y = get_global_mouse_position().y + 140
	look_at(get_global_mouse_position())
	rotation_degrees = rotation_degrees + 90
	
#	print(get_global_mouse_position().distance_to(position))
	
	move_and_slide(get_global_mouse_position() - global_position)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
