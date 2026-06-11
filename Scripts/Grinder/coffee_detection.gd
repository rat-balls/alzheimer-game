extends Area3D

@export var grinder: Node3D

var already_filled : bool = false

func fill() -> void:
	if already_filled:
		return

	already_filled = true

	if grinder:
		grinder.fill_coffee()
