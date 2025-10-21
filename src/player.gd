extends Node3D

@export var test_object_path : NodePath
@onready var test_object : RigidBody3D = get_node(test_object_path)
@onready var mouse_selector := $MouseSelector

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("left_force"):
		var selection = mouse_selector.select()
		if not selection: return
		
		selection["object"].apply_impulse(Vector3(-10, 1, 0), selection["position"])
		
		
		#test_object.apply_central_impulse(Vector3(-10, 1, 0))
	
	if Input.is_action_just_pressed("right_force"):
		mouse_selector.select()
		#test_object.apply_central_impulse(Vector3(10, 1, 0))
	
