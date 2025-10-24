extends RigidBody3D

class_name RigidEnemy

@onready var grounded_ray := $GroundedRay

func is_grounded():
	return grounded_ray.is_colliding()
