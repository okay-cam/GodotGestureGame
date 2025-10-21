extends Node

var serial: GdSerial

signal gesture
signal hand_distance
signal hand_present

func _ready():
	# Create serial instance
	serial = GdSerial.new()
	
	# List available ports
	print("Available ports:")
	var ports = serial.list_ports()
	for i in range(ports.size()):
		var port_info = ports[i]
		print("- ", port_info["port_name"], " (", port_info["port_type"], ")")
	
	# Configure and open port
	serial.set_port("COM3")  # Adjust for your system
	serial.set_baud_rate(115200)
	serial.set_timeout(1000)
	
	if serial.open():
		print("Port opened successfully!")
		
		# Send command
		#serial.writeline("From Godot")
		
		# Wait and read response
		#await get_tree().create_timer(0.1).timeout
		#if serial.bytes_available() > 0:
			#var response = serial.readline()
			#print("Response: ", response)
		
		#serial.close()
	else:
		print("Failed to open port")


func _process(_delta: float) -> void:
	
	if not serial.is_open():
		return
	
	await get_tree().create_timer(0.1).timeout
	if serial.bytes_available() > 0:
		var raw_response = serial.readline()
		var response = raw_response.split(":")
		print("received: " + raw_response)
		
		match response[0]:
			"gesture":
				_handle_gesture(response[1])
			"cm":
				_handle_hand_distance(response[1])
			"hand":
				_handle_hand_presence(response[1])
			_:
				printerr("response not recognised: " + response[1])
			

func _handle_gesture(gesture_name : String):
	gesture.emit(gesture_name.to_lower())

func _handle_hand_distance(distance_value : String):
	hand_distance.emit(float(distance_value))

func _handle_hand_presence(hand_presence_value : String):
	var hand_present_bool : bool = hand_presence_value.to_lower() == "true"
	hand_present.emit(hand_present_bool)
