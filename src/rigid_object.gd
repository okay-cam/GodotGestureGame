extends RigidBody3D

class_name ExplosiveBarrel

@export var particles_scene : PackedScene

var is_exploded := false

#var _initial_frames = 0

#func _ready():
	#is_exploded = false
	#
	## Reset all physics state on ready
	#constant_force = Vector3.ZERO
	#linear_velocity = Vector3.ZERO
	#angular_velocity = Vector3.ZERO
	#linear_damp = 100



# !! stupid fix, just prevent rotations.
func _integrate_forces(state):
	
	#if _initial_frames < 25 and not freeze:
		#state.linear_velocity = Vector3.ZERO
		#state.angular_velocity = Vector3.ZERO
		#_initial_frames += 1
		#
		#if _initial_frames == 25:
			#linear_damp = 0
			#contact_monitor = true
	
	if is_exploded:
		return
	
	var contact_count = state.get_contact_count()
	
	for contact_idx in range(contact_count):
		var body_velocity = state.get_contact_local_velocity_at_position(contact_idx)
		var collider_velocity = state.get_contact_collider_velocity_at_position(contact_idx)
		var contact_normal = state.get_contact_local_normal(contact_idx)
		var relative_velocity = body_velocity - collider_velocity
		var approach_speed = relative_velocity.dot(contact_normal)
		
		if approach_speed < -7.5:
			print("Explosion triggered at speed: ", approach_speed)
			#print("body speed: ", body_velocity)
			print("body speed: ", state.linear_velocity)
			print("collider speed: ", collider_velocity)
			explode()
			return  # Exit early after exploding
	


func explode():
	
	print("EXPLODE CALLED - Instance ID: ", get_instance_id(), " is_exploded: ", is_exploded)
	
	if is_exploded:
		return
	
	is_exploded = true
	$BarrelMesh.hide()
	
	var particles : Node3D = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	
	apply_explode_force()
	
	queue_free()
	
func apply_explode_force():
	for object in $ExplodeArea.get_overlapping_bodies():
		if object == self:
			continue 
		
		if object.is_in_group("ExplodeReact"):
			object.explode_react()
			continue
			
		if object is RigidBody3D:
			var difference : Vector3 = object.global_position - global_position
			#print(difference.normalized() * (17 - difference.length()) * 1)
			if object.find_child("Z-Manager"):
				object.get_node("Z-Manager").allow()
			object.apply_impulse(difference.normalized() * (17 - difference.length()) * 1)

func explode_react():
	explode()
