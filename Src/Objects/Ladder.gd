extends Area2D

func _on_Ladder_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.set_on_ladder(true)
	
func _on_Ladder_body_exited(body: Node) -> void:
	if body.name == "Player":
		body.set_on_ladder(false)
