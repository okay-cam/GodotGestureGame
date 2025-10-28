extends Path3D

@export var paths : Array[Curve3D]

@onready var path_follow := $PathFollow3D

var moving := false

var total_path_length

var tween : Tween

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.keycode:
			KEY_1:
				print("Key 1")
				curve = paths[0]
				total_path_length = curve.get_baked_length()
				
				if Input.is_action_pressed("debug"):
					path_follow.progress_ratio = 1
					if tween:
						tween.kill()
					return
				
				# distance travelling at a constant speed
				var constant_speed_distance = total_path_length - 10
				# distance&time for accel&decel
				var accel_distance := 5.0
				var accel_time := 1.0
				# distance for constant speed
				var constant_speed := 5.0
				
				if tween:
					tween.kill()
				
				path_follow.progress_ratio = 0
				tween = create_tween()
				tween.tween_property(path_follow, "progress", accel_distance, accel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				tween.tween_property(path_follow, "progress", total_path_length-accel_distance, constant_speed_distance / constant_speed).set_trans(Tween.TRANS_LINEAR)
				tween.tween_property(path_follow, "progress", total_path_length, accel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				
				
				
			KEY_2:
				print("Key 2")
				# Code for Key 2
			KEY_3:
				print("Key 3")
				# Code for Key 3
			KEY_4:
				print("Key 4")
				# Code for Key 4

#func _process(_delta):
	#
	#if moving:
		#
	#
