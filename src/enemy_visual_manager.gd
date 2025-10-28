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

var is_walking := false
var is_held := false
var is_dead := false

var sideways := false

var dead_progress := 0.0
const DYING_TIME := 0.15

func _process(_delta):
	
	if is_walking: return
	
	#if is_dead and rigid_enemy.is_grounded():
	if is_dead and not sideways:
		if dead_progress <= 0:
			rigid_enemy.dead_hitbox()
		dead_progress = min(dead_progress + (_delta/DYING_TIME), 1.0)
	
	## spaghetti frames
	
	# prioritise being held in the air
	if is_held:
		sideways = false
		process_held()
		return
	
	# prioritise sideways movement over standing grounded
	if 5 < abs(rigid_enemy.linear_velocity.x) and not is_dead:
		sideways = true
		process_sideways()
		return
	
	# do frames when in air (not held)
	if (is_dead or not sideways) and (not rigid_enemy.is_grounded()):
		process_held()
		return
	
	if rigid_enemy.is_grounded():
		process_grounded()
		sideways = false
		return
	

func process_held():
	
	if is_dead and dead_progress > 0:
		if rigid_enemy.linear_velocity.y > 1:
			sprite.frame = BACK_2
		else:
			sprite.frame = DEAD
		return
	
	
	if abs(rigid_enemy.linear_velocity.y) < 2:
		sprite.frame = HOLD_MID
	elif rigid_enemy.linear_velocity.y < 0:
		sprite.frame = HOLD_DOWN
	elif rigid_enemy.linear_velocity.y > 0:
		sprite.frame = HOLD_UP

func process_sideways():
	sprite.frame = SIDE
	sprite.flip_h = rigid_enemy.linear_velocity.x < 0  # flip sprite when pushed left

func process_grounded():
	if is_dead:
		if dead_progress >= 1:
			sprite.frame = DEAD
		elif dead_progress >= 0.5:
			sprite.frame = BACK_2
		else:
			sprite.frame = BACK_1
		return
	
	sprite.frame = STAND

func _on_body_entered(_body):
	
	pass # Replace with function body.


func _on_hold():
	is_held = true

func _on_released():
	is_held = false

func _on_died() -> void:
	is_dead = true

func start_walking(direction : int):
	sprite.flip_h = direction == 1
	is_walking = true
	if $AnimationPlayer.current_animation != "walking":
		$AnimationPlayer.play("walking")

func stop_walking():
	is_walking = false
	if $AnimationPlayer.current_animation == "walking":
		$AnimationPlayer.stop()
