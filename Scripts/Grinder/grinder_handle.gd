extends Area3D

@export var grinder: Node3D

func interact() -> void:
	grinder.start_grabbing_handle()
