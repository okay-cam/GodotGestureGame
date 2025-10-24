extends Node3D

signal on_held
signal on_released

func held():
	on_held.emit()

func released():
	on_released.emit()
