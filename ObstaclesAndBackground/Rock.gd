extends RigidBody2D
export var draft_factor = 10.0
var max_speed = 0

func _integrate_forces(state):
	if state.linear_velocity.length()>max_speed:
		state.linear_velocity=state.linear_velocity.normalized()*max_speed
