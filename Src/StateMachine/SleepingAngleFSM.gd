extends StateMachine

func _state_logic(delta):
	add_state("sleep")
	add_state("chase")
	add_state("attack")
	call_deferred("set_state", states.sleep)

func _get_transition(delta):
	return null

func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass
