extends Node3D


var cooldown : float = 100.0

const LENIENCE = 95.0

# total cooldown in seconds
const COOLDOWN_TIME := 0.75

signal cooldown_changed

func _ready() -> void:
	set_cooldown(100)

func is_charging() -> bool:
	return cooldown < LENIENCE

func set_cooldown(val):
	cooldown = val
	cooldown_changed.emit(cooldown)

func start():
	if is_charging(): return
	
	SerialManager.send("gd:cooldown_start")
	
	set_cooldown(0)
	

func _process(delta: float) -> void:
	
	if cooldown >= 100: return
	
	if SerialManager.is_hand_very_present:
		set_cooldown( min(cooldown + (delta*100)/COOLDOWN_TIME, 100) )
		
		#if cooldown <= LENIENCE:
			#SerialManager.send("gd:cooldown_end")
	elif cooldown < LENIENCE:
		set_cooldown( max(cooldown - (delta*100)/(COOLDOWN_TIME*4), 0) )
	
	#print(cooldown)
