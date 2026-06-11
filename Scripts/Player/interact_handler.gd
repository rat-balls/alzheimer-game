extends Node3D

const INTERACT_DISTANCE = 4.0
const HOLD_FORCE = 15.0
const THROW_FORCE = 6.0
const OBJECT_ROTATE_SENSITIVITY = 0.005
const MIN_HOLD_DISTANCE = 1.0
const MAX_HOLD_DISTANCE = 3.0
const SCROLL_SPEED = 0.3

var player: CharacterBody3D
var camera: Camera3D

var default_hold_distance: float = 1.0
var hold_distance: float = default_hold_distance
var valid_hold_target: RigidBody3D = null
var valid_interact_target: Area3D = null
var held_object: RigidBody3D = null
var held_rotation_offset: Quaternion = Quaternion.IDENTITY
var grabbed_grinder: Node3D = null
var is_rotating_object: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	camera = get_tree().get_first_node_in_group("PlayerCamera")

func _process(_delta: float) -> void:
	find_valid_grab_target()

func _physics_process(_delta: float) -> void:
	if not held_object:
		return
	var hold_position = global_position - global_transform.basis.z * hold_distance
	held_object.linear_velocity = (hold_position - held_object.global_position) * HOLD_FORCE
	if held_object.is_in_group("Rotatable"):
		var target_rotation = global_transform.basis.get_rotation_quaternion() * held_rotation_offset
		held_object.global_transform = Transform3D(Basis(target_rotation), held_object.global_position)
		held_object.angular_velocity = Vector3.ZERO
	if held_object.global_position.distance_to(global_position) > MAX_HOLD_DISTANCE + 1.5:
		drop_object()

func _input(event: InputEvent) -> void:
	if camera.mouse_visible:
		return

	if event is InputEventMouseMotion:
		if grabbed_grinder:
			grabbed_grinder.rotate_handle(event.relative)
			return
		if held_object and is_rotating_object:
			rotate_held_object(event.relative)

	if event.is_action_pressed("Interact"):
		if held_object or grabbed_grinder:
			drop_object()
		else:
			try_interact_object()
	elif event.is_action_pressed("Throw") and held_object:
		throw_object()
	elif event.is_action_pressed("RotateObject") and held_object and held_object.is_in_group("Rotatable"):
		is_rotating_object = true
	elif event.is_action_released("RotateObject"):
		is_rotating_object = false
	elif event.is_action_pressed("WHEEL_UP"):
		hold_distance = clamp(hold_distance + SCROLL_SPEED, MIN_HOLD_DISTANCE, MAX_HOLD_DISTANCE)
	elif event.is_action_pressed("WHEEL_DOWN"):
		hold_distance = clamp(hold_distance - SCROLL_SPEED, MIN_HOLD_DISTANCE, MAX_HOLD_DISTANCE)

func rotate_held_object(mouse_delta: Vector2) -> void:
	var camera_right = global_transform.basis.x.normalized()
	var camera_up = global_transform.basis.y.normalized()
	var current_rotation = global_transform.basis.get_rotation_quaternion() * held_rotation_offset
	var delta_rotation = Quaternion(camera_right, -mouse_delta.y * OBJECT_ROTATE_SENSITIVITY) * Quaternion(camera_up, -mouse_delta.x * OBJECT_ROTATE_SENSITIVITY)
	held_rotation_offset = global_transform.basis.get_rotation_quaternion().inverse() * delta_rotation * current_rotation

func throw_object() -> void:
	var obj = held_object
	drop_object()
	obj.apply_central_impulse(-global_transform.basis.z * THROW_FORCE)

func drop_object() -> void:
	if grabbed_grinder:
		grabbed_grinder.stop_grabbing_handle()
		grabbed_grinder = null
		is_rotating_object = false
		return
	if not held_object:
		return
	held_object.gravity_scale = 1.0
	held_object.angular_damp = 0.05
	held_object.linear_damp = 0.05
	held_object = null
	held_rotation_offset = Quaternion.IDENTITY

func find_valid_grab_target() -> void:
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position - global_transform.basis.z * INTERACT_DISTANCE)
	query.collide_with_areas = true
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		valid_hold_target = null
		valid_interact_target = null
		return
	var obj = result.collider
	if obj is Area3D:
		valid_interact_target = obj
		valid_hold_target = null
	elif obj is RigidBody3D:
		valid_hold_target = obj
		valid_interact_target = null
	else:
		valid_hold_target = null
		valid_interact_target = null

func try_interact_object() -> void:
	if valid_hold_target:
		if valid_hold_target.has_method("interact"):
			valid_hold_target.interact()
		else:
			grab()
	if valid_interact_target:
		interact()

func grab() -> void:
	hold_distance = valid_hold_target.global_position.distance_to(global_position)
	held_object = valid_hold_target
	held_object.gravity_scale = 0.0
	held_object.linear_damp = 6.0
	held_object.angular_damp = 6.0
	held_rotation_offset = global_transform.basis.get_rotation_quaternion().inverse() * held_object.global_transform.basis.get_rotation_quaternion()

func interact() -> void:
	print("name:", valid_interact_target.name, "type:", valid_interact_target.get_class())
	if valid_interact_target.is_in_group("GrinderHandle"):
		grabbed_grinder = valid_interact_target.grinder
		is_rotating_object = true
	if valid_interact_target.has_method("interact"):
		valid_interact_target.interact()
