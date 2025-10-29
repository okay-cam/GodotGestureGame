extends RigidBody3D

class_name RigidEnemy

@onready var grounded_ray := $GroundedRay

@onready var visual_manager := $VisualManager

@export var x_goal : float = 0.0
@export var x_range := 30.0

# how long to walk, and which direction
@export var walking := -2.0

var impact_velocity = Vector3.ZERO

var is_dead := false
signal died

func _ready():
	start_walking()

func is_grounded():
	return grounded_ray.is_colliding()

func _process(_delta):
	process_walking_goal()
	

func process_walking_goal():
	if is_dead: return
	if walking != 0: return
	if not is_grounded(): return
	if abs(linear_velocity.x) > 0.5: return 
	
	if position.x < x_goal - x_range:
		walking = 1.0
		start_walking()
	elif x_goal + x_range < position.x:
		walking = -1.0
		start_walking()

func _integrate_forces(state):
	
	if walking != 0:
		state.linear_velocity.x = sign(walking) * 4
		
	
	var contact_count = state.get_contact_count()
	
	for contact_idx in range(contact_count):
		
		var body_velocity = state.get_contact_local_velocity_at_position(contact_idx)
		var collider_velocity = state.get_contact_collider_velocity_at_position(contact_idx)
		var contact_normal = state.get_contact_local_normal(contact_idx)
		var relative_velocity = body_velocity - collider_velocity
		var approach_speed = relative_velocity.dot(contact_normal)
		
		var collider_object = state.get_contact_collider_object(contact_idx)
		
		if collider_object is RigidBody3D:
			approach_speed *= collider_object.mass
		
		
		if approach_speed < -7.5:
			print(approach_speed)
			die()
		elif approach_speed < -3:
			minor_hit()
		

func die():
	if is_dead: return
	if walking: stop_walking()
	is_dead = true
	died.emit()

func minor_hit():
	if is_dead: return
	if walking: stop_walking()

func dead_hitbox():
	$NormalCollision.set_deferred("disabled", true)
	$DeadCollision.set_deferred("disabled", false)


func _on_hold():
	stop_walking()

func start_walking():
	
	if walking == 0: return
	
	visual_manager.start_walking(sign(walking))
	$WalkEnd.start(abs(walking))
	constant_force.x = sign(walking) * 20

func stop_walking():
	visual_manager.stop_walking()
	walking = 0
	constant_force.x = 0
	$WalkEnd.stop()

func _on_forced():
	if walking != 0: stop_walking()
