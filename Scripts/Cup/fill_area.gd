extends Area3D

var has_water :bool =false
var has_ground_coffee :bool =false

func fill_water() -> void:
	if has_water:
		return

	has_water = true
	print("filled water")
	check_coffee_ready()

func fill_ground_coffee() -> void:
	if has_ground_coffee:
		return

	has_ground_coffee = true
	print("filled coffee")
	check_coffee_ready()

func check_coffee_ready() -> void:
	if has_water and has_ground_coffee:
		print("ok")
