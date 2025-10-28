extends Node3D

@export var camera_path : NodePath
@onready var camera : Camera3D = get_node(camera_path)

const RAY_LENGTH := 100.0

# temporarially store recent hover selection
var selection_buffer

func _on_update_buffer_timeout():
	var selection = update_selection()
	if selection:
		selection_buffer = selection
		$ClearBufferTimer.start()
		#print("updated buffer with new selection")

func _on_clear_buffer_timeout():
	selection_buffer = update_selection()
	#print("clear buffer timeout")

# cast a ray from camera at mouse position, and get the object colliding with the ray
func update_selection():
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world_3d().direct_space_state
	
	# 1 << 4 = bit 10000 = collision mask 5
	var ray_param := PhysicsRayQueryParameters3D.create(ray_from, ray_to, 1 << 4)
	ray_param.collide_with_areas = true
	ray_param.collide_with_bodies = true
	
	var selection = space_state.intersect_ray(ray_param)
	
	if not selection:
		return null
	
	selection["object"] = selection["collider"].get_parent()
	#selection["position_offset"] = selection["position"] - selection["object"].global_transform.origin
	
	if selection["object"].freeze:
		return null
	
	#object: the parent of the selection area
	#collider: The colliding object.
	#collider_id: The colliding object's ID.
	#position: The intersection point.
	
	return selection

func select():
	var selection = update_selection()
	if selection: return selection
	return selection_buffer
