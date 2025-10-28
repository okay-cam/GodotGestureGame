extends Node3D

var enemies = []
var enemies_alive := 99

signal all_died

func _ready():
	
	for child in get_children():
		if child is RigidEnemy:
			enemies.append(child)
			child.died.connect(_enemy_died)
			
	
	enemies_alive = enemies.size()

func _enemy_died():
	enemies_alive -= 1
	if enemies_alive <= 0:
		all_died.emit()
