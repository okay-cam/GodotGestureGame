extends Path3D

@export var paths : Array[Curve3D]

@onready var path_follow := $PathFollow3D

var moving := false

var total_path_length

var tween : Tween

signal next_area_reached

func move(path_num : int, instant := false):
	
	curve = paths[path_num]
	total_path_length = curve.get_baked_length()
	
	if instant:
		path_follow.progress_ratio = 1
		if tween:
			next_area_reached.emit(path_num + 1)
			tween.kill()
		return
	
	# distance travelling at a constant speed
	var constant_speed_distance = total_path_length - 10
	# distance&time for accel&decel
	var accel_distance := 5.0
	var accel_time := 1.0
	# distance for constant speed
	var constant_speed := 8.0
	
	if tween:
		tween.kill()
	
	path_follow.progress_ratio = 0
	tween = create_tween()
	tween.tween_property(path_follow, "progress", accel_distance, accel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(path_follow, "progress", total_path_length-accel_distance, constant_speed_distance / constant_speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(next_area_reached.emit)
	tween.tween_property(path_follow, "progress", total_path_length, accel_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


#func _process(_delta):
	#
	#if moving:
		#
	#
