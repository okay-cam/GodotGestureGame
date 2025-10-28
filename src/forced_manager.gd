extends Node3D

signal on_forced

func forced():
	on_forced.emit()
