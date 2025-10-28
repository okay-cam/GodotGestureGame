extends Node3D

@onready var object : RigidBody3D = get_parent()

@onready var timer := $"Z-Time"

var is_z_allowed = false

func _physics_process(_delta):
	
	if is_z_allowed: return
	
	if abs(object.linear_velocity.z) < 1.5 and not object.axis_lock_linear_z:
		object.axis_lock_linear_z = true


func allow():
	is_z_allowed = true
	object.axis_lock_linear_z = false
	timer.start()

func _on_z_timeout():
	is_z_allowed = false
