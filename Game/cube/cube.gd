extends RigidBody2D


func _physics_process(delta):
	if linear_velocity.x != 0:
		linear_velocity.x = move_toward(linear_velocity.x, 0, 1500 * delta)
	

