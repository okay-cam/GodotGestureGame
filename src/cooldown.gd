extends Node3D


# when above the threshold, the gesture is ready.
# !! mostly unused? used for showing gestures on led matrix
var gesture_ready := false

var cooldown : float = 100.0

const LENIENCE = 95.0

# total cooldown in seconds
const COOLDOWN_TIME := 0.75

signal cooldown_changed

func _ready() -> void:
	set_cooldown(0)

func is_charging() -> bool:
	return cooldown < LENIENCE

func set_cooldown(val):
	cooldown = val
	cooldown_changed.emit(cooldown)
	update_gesture_ready()

func start():
	if is_charging(): return
	
	SerialManager.send("gd:cooldown_start")
	
	set_cooldown(0)
	

func _process(delta: float) -> void:
	
	
	
	#if cooldown >= 100: return
	
	if SerialManager.is_hand_very_present:
		if cooldown == 100: return
		set_cooldown( min(cooldown + (delta*100)/COOLDOWN_TIME, 100) )
		
		# clear matrix on fully charged
		if cooldown == 100:
			SerialManager.send("gd:clear")
		
		#if cooldown <= LENIENCE:
			#SerialManager.send("gd:cooldown_end")
	elif cooldown < LENIENCE:
		set_cooldown( max(cooldown - (delta*100)/(COOLDOWN_TIME*4), 0) )
	else:
		set_cooldown( max(cooldown - (delta*100)/(COOLDOWN_TIME*10), 0) )
	
	update_gesture_ready()
	
	#print(cooldown)

func update_gesture_ready():
	if cooldown >= LENIENCE and not gesture_ready:
		gesture_ready = true
		print("gesture ready!")
		SerialManager.send("gd:gesture_ready")
	if cooldown < LENIENCE and gesture_ready:
		gesture_ready = false
		print("gesture gone")
		SerialManager.send("gd:gesture_gone")
