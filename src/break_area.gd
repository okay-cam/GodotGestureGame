extends Area3D

@export var broken_scene : PackedScene

func explode_react():
	
	var broken = broken_scene.instantiate()
	
	get_parent().get_parent().add_child(broken)
	broken.global_position = global_position
	
	get_parent().queue_free()
