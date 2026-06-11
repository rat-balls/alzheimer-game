extends Node3D

@export var grinder_handle: Node3D
@export var grinder_drawer: RigidBody3D
var handle_grabbed :bool= false
var drawer_grabbed :bool= false
var coffee_filled: bool = false
var drawer_filled: bool = false
var virtual_mouse_pos :Vector2= Vector2.ZERO
var previous_angle :float= 0.0
var rotation_sensitivity :float= 1.0
var grind_progress: float = 0.0
@export var grind_needed: float = 20.0

func fill_coffee() -> void:
	if coffee_filled:
		return
	coffee_filled = true
	print("coffee filled")
	
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
	if not coffee_filled:
		return
	
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2.0
	virtual_mouse_pos += mouse_delta
	virtual_mouse_pos = virtual_mouse_pos.clamp(center - Vector2(200, 200), center + Vector2(200, 200))
	var current_angle = get_virtual_mouse_angle()
	var delta_angle = wrapf(current_angle - previous_angle, -PI, PI)
	grinder_handle.rotate_object_local(Vector3.UP, -delta_angle * rotation_sensitivity)
	grind_progress += abs(delta_angle)
	if grind_progress >= grind_needed:
		fill_drawer()
	previous_angle = current_angle

func get_virtual_mouse_angle() -> float:
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2.0
	var dir = virtual_mouse_pos - center
	return atan2(dir.y, dir.x)
	
func fill_drawer() -> void:
	if drawer_filled:
		return
	drawer_filled = true
	coffee_filled = false
	print("drawer filled")
	if grinder_drawer.has_method("fill_ground_coffee"):
		grinder_drawer.fill_ground_coffee()
		
