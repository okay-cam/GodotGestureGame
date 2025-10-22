extends Node3D

@export var test_object_path : NodePath
@onready var test_object : RigidBody3D = get_node(test_object_path)
@onready var mouse_selector := $MouseSelector

# store object if held with right click
var held_object = null
# store the initial object height to find relative height change
var initial_object_height : float = 0.0
var initial_object_x : float = 0.0

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
	if Input.is_action_pressed("hold") and not held_object:
		var selection = mouse_selector.select()
		if not selection: return
		held_object = selection["object"]
		
		initial_hand_height = hand_height
		initial_object_height = held_object.global_transform.origin.y
		initial_object_x = held_object.global_transform.origin.x
	
	if Input.is_action_pressed("hold") and held_object:
		# --- motion constants
		var hand_multiplier := 0.5  # how much to multiply real-life distance to in-game distance
		# goal height should be how much the hand moves after holding the object
		var goal_height = initial_object_height + (hand_height - initial_hand_height) * hand_multiplier
		var stiffness = 50.0  # how strong the pull is
		var damping = 15.0    # how much velocity is damped
		# ---
		
		var current_pos = held_object.global_transform.origin
		var velocity = held_object.linear_velocity
		
		# PD control
		# move y to certain height
		var force_y = stiffness * (goal_height - current_pos.y) - damping * velocity.y
		# keep x the same
		var force_x = stiffness * (initial_object_x - current_pos.x) - damping * velocity.x
		
		
		# Apply force only in the y-axis
		held_object.apply_central_force(Vector3(force_x, force_y, 0))
		
		
		pass
	
	if Input.is_action_just_released("hold") and held_object:
		held_object = null
	
	# below are debug inputs when sensors aren't available
	
	if Input.is_action_just_pressed("increase_height"):
		hand_height += 1
		print("hand height: " + str(hand_height))
	
	if Input.is_action_just_pressed("decrease_height"):
		hand_height -= 1
		print("hand height: " + str(hand_height))
	
	if Input.is_action_just_pressed("left_force"):
		var selection = mouse_selector.select()
		if not selection: return
		
		#selection["object"].apply_impulse(Vector3(-10, 1, 0), selection["position"])
		selection["object"].apply_central_impulse(Vector3(-10, 1, 0))
		
		#test_object.apply_central_impulse(Vector3(-10, 1, 0))
	
	if Input.is_action_just_pressed("right_force"):
		var selection = mouse_selector.select()
		if not selection: return
		
		selection["object"].apply_central_impulse(Vector3(10, 1, 0))
		
		#test_object.apply_central_impulse(Vector3(10, 1, 0))
	
	
	
