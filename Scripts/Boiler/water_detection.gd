extends Area3D

var filled : bool = false

func fill() -> void:
	if filled:
		return

	filled = true
	print("filled")
