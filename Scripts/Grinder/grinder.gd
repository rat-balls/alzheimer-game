extends Node3D

@onready var grinder_handle: Node3D = $Grinder_handle
@onready var grinder_drawer: Node3D = $Grinder_drawer
var handle_grabbed :bool= false
var drawer_grabbed :bool= false
var virtual_mouse_pos :Vector2= Vector2.ZERO
var previous_angle :float= 0.0
var rotation_sensitivity :float= 1.0

func start_grabbing_handle() -> void:
	handle_grabbed = true
	var viewport_size = get_viewport().get_visible_rect().size
	virtual_mouse_pos = viewport_size / 2.0 + Vector2(100, 0)
	previous_angle = get_virtual_mouse_angle()

func stop_grabbing_handle() -> void:
	handle_grabbed = false

func rotate_handle(mouse_delta: Vector2) -> void:
	if not handle_grabbed:
		return
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2.0
	virtual_mouse_pos += mouse_delta
	virtual_mouse_pos = virtual_mouse_pos.clamp(center - Vector2(200, 200), center + Vector2(200, 200))
	var current_angle = get_virtual_mouse_angle()
	var delta_angle = wrapf(current_angle - previous_angle, -PI, PI)
	grinder_handle.rotate_object_local(Vector3.UP, -delta_angle * rotation_sensitivity)
	previous_angle = current_angle

func get_virtual_mouse_angle() -> float:
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2.0
	var dir = virtual_mouse_pos - center
	return atan2(dir.y, dir.x)
