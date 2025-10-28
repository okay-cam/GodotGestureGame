extends Node3D

func _ready():
	for node in get_children():
		if node is GPUParticles3D:
			node.emitting = true
	
	$QueueFree.start()
	
