extends Node3D

@export var area_object_paths : Array[NodePath]
var area_objects_array : Array[AreaObjects]

@onready var path := $Path3D

var area := 0

func _ready():
	
	for node_path in area_object_paths:
		var area_object_node := get_node(node_path)
		area_object_node.all_died.connect(all_died)
		area_objects_array.append(area_object_node)
	
	area_objects_array[area].start()
	

func all_died():
	path.move(area)

func _on_next_area_reached(specific_area := -1):
	if specific_area == -1:
		area += 1
	else:
		area = specific_area
	
	# stop previous area
	if area > 0:
		area_objects_array[area-1].stop()
	
	# start new area
	area_objects_array[area].start()
	
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		print("RESTARTING SCENE")
		get_tree().reload_current_scene()
		return
	
	if event.is_action_pressed("debug"):
		path.move(area)
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.keycode:
			KEY_1:
				key_press(1)
			KEY_2:
				key_press(2)
			KEY_3:
				print("Key 3")
				# Code for Key 3
			KEY_4:
				print("Key 4")
				# Code for Key 4

func key_press(key_int : int):
	area_objects_array[area].stop()
	print("Key ", key_int)
	path.move(key_int-1, true)
	_on_next_area_reached(key_int)
	
	pass
