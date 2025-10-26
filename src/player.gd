extends Node3D

@export var test_object_path : NodePath
@onready var test_object : RigidBody3D = get_node(test_object_path)
@onready var mouse_selector := $MouseSelector

@onready var cooldown := $Cooldown

# store object if held with right click
var held_object = null

# debug hand height variable (cm)
var hand_height = 5
# !! may need a raw height, and a processed height
# !! arduino should send a processed height?

# store the initial hand height to find relative height change
var initial_hand_height : int = 0

# assume hand is at max height if above this value but less than ceiling
const MAX_HAND_HEIGHT := 30
# assume no hand if hand height is above this value
const CEILING_HEIGHT := 60




func _ready() -> void:
	# connect to serial manager by default
	SerialManager.gesture.connect(_on_gesture)
	SerialManager.hand_distance.connect(_on_hand_distance)
	SerialManager.hand_present.connect(_on_hand_present)


func _on_gesture(gesture : String) -> void:
	
	if cooldown.is_charging(): return
	
	match gesture:
		"left":
			Input.action_press("left_force")
			Input.action_release("left_force")
		"right":
			Input.action_press("right_force")
			Input.action_release("right_force")
	

func _on_hand_distance(distance : float) -> void:
	hand_height = distance


func _on_hand_present(is_present : bool) -> void:
	
	# !! unused for now.
	
	if is_present:
		pass
	
	pass # Replace with function body.



func _physics_process(_delta: float) -> void:
	
	# !! only run holding if hand is in range too
	if Input.is_action_just_pressed("hold") and not held_object:
		var selection = mouse_selector.select()
		if not selection: return
		hold_object(selection["object"])
	
	if Input.is_action_pressed("hold") and held_object:
		
		# --- motion constants
		var hand_multiplier := 0.03  # how much to multiply real-life distance to in-game distance
		var stiffness = 50.0  # how strong the pull is
		var damping = 15.0    # how much velocity is damped
		# ---
		
		# objects further away should move more
		var distance_factor = 1.0 # how many units away for 100% increase
		var z_distance = absf(global_transform.origin.z - held_object.global_transform.origin.z)
		
		# goal height is the hand height. bigger if the object is further.
		var goal_height = (hand_height-5) * hand_multiplier * (1 + z_distance / distance_factor)
		
		# keep object at roughly same x
		var goal_x = held_object.global_transform.origin.x
		
		var current_pos = held_object.global_transform.origin
		var velocity = held_object.linear_velocity
		
		# PD control
		# move y to certain height
		var force_y = stiffness * (goal_height - current_pos.y) - damping * velocity.y
		# keep x roughly the same
		var force_x = stiffness * (goal_x - current_pos.x) - damping * velocity.x
		
		
		# Apply force only in the y-axis
		held_object.apply_central_force(Vector3(force_x, force_y, 0))
		
		
	
	if Input.is_action_just_released("hold") and held_object:
		release_held_object()
	
	# below are debug inputs when sensors aren't available
	
	if Input.is_action_just_pressed("increase_height"):
		hand_height += 1
		print("hand height: " + str(hand_height))
	
	if Input.is_action_just_pressed("decrease_height"):
		hand_height -= 1
		print("hand height: " + str(hand_height))
	
	# DONT DO OTHER PROCESSES if held?
	if held_object:
		return
	
	if Input.is_action_just_pressed("left_force"):
		var object = get_priority_object()
		if not object: return
		
		cooldown.start()
		
		#selection["object"].apply_impulse(Vector3(-10, 1, 0), selection["position"])
		object.apply_central_impulse(Vector3(-10, 1, 0))
		
		release_held_object()
	
	if Input.is_action_just_pressed("right_force"):
		var object = get_priority_object()
		if not object: return
		
		cooldown.start()
		
		object.apply_central_impulse(Vector3(10, 1, 0))
		
		release_held_object()

# prioritise a held object. otherwise, get whatever object is being hovered over
func get_priority_object():
	if held_object: return held_object
	var selection = mouse_selector.select()
	if not selection: return null
	return selection["object"]

func hold_object(object):
	
	SerialManager.send("gd:hold")
	
	held_object = object
	if held_object.is_in_group("Holdable"):
		held_object.get_node("HoldManager").held()
	

func release_held_object():
	if held_object and held_object.is_in_group("Holdable"):
		held_object.get_node("HoldManager").released()
	held_object = null
	
	SerialManager.send("gd:release")
