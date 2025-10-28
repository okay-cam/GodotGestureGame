extends Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		print("RESTARTING SCENE")
		get_tree().reload_current_scene()
