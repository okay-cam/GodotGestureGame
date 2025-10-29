extends Node3D

class_name AreaObjects

var enemies = []
var enemies_alive := 99

@onready var bounds := $Bounds

signal all_died


func start():
	enable_bounds()
	unfreeze()

func stop():
	freeze()
	disable_bounds()

func _ready():
	disable_bounds()
	
	for child in get_children():
		if child is RigidEnemy:
			enemies.append(child)
			child.died.connect(_enemy_died)
			
	
	enemies_alive = enemies.size()

func _enemy_died():
	enemies_alive -= 1
	if enemies_alive <= 0:
		all_died.emit()

func enable_bounds():
	for child in bounds.get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", false)

func disable_bounds():
	for child in bounds.get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", true)

func freeze():
	for child in get_children():
		if child is RigidBody3D:
			child.freeze = true

func unfreeze():
	for child in get_children():
		if child is RigidBody3D:
			child.freeze = false
