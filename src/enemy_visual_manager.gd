extends Node3D

@export var rigid_enemy_path : NodePath
@onready var rigid_enemy : RigidEnemy = get_node(rigid_enemy_path)

@onready var sprite := $Sprite

enum {STAND, SHOOT, WALK_1, WALK_2, WALK_3, WALK_4, HOLD_UP, HOLD_MID, HOLD_DOWN, SIDE, SIDE_IMPACT, BACK_1, BACK_2, DEAD}

# MAIN PRIORITY

# stand, shoot at the player?

# react to being held in the air
# react to being swiped left and right

# die on big impacts? idk

var is_held := false

var sideways := false

func _process(_delta):
	
	#print(rigid_enemy.linear_velocity)
	
	if is_held:
		sideways = false
		process_held()
		return
	
	if 5 < abs(rigid_enemy.linear_velocity.x):
		sideways = true
		sprite.frame = SIDE
		sprite.flip_h = rigid_enemy.linear_velocity.x < 0  # flip sprite when pushed left
		return
	
	if (not sideways) and (not rigid_enemy.is_grounded()):
		process_held()
		return
	
	if rigid_enemy.is_grounded():
		sideways = false
		sprite.frame = STAND
		return
	

func process_held():
	
	if abs(rigid_enemy.linear_velocity.y) < 2:
		sprite.frame = HOLD_MID
	elif rigid_enemy.linear_velocity.y < 0:
		sprite.frame = HOLD_DOWN
	elif rigid_enemy.linear_velocity.y > 0:
		sprite.frame = HOLD_UP

	

func _on_body_entered(_body):
	pass # Replace with function body.


func _on_hold():
	is_held = true

func _on_released():
	is_held = false
