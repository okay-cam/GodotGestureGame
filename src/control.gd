extends Control


func _on_cooldown_changed(val) -> void:
	$ProgressBar.value = val
	
	if val == 100:
		$ProgressBar.get_theme_stylebox("fill").bg_color = Color("5ec6ffff")
	else:
		$ProgressBar.get_theme_stylebox("fill").bg_color = Color("787878")
	
